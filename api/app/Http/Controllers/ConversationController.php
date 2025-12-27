<?php

namespace App\Http\Controllers;

use App\Http\Resources\ConversationResource;
use App\Models\Conversation;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;

class ConversationController extends Controller
{
    public function index(Request $request){
        $user=Auth::user();
        $conversations= $user->conversations()
            ->wiht(['users:id,profile.first_name,profile.profile_image',
        'lastMessage.sender:id,profile.first_name,profile.profile_image'])
            ->orederByDesc(
                Conversation::select('updated_at')
                ->whereColumn('conversations.id','conversation_user.conversation_id')
            )->paginate(50);
        return ConversationResource::collection($conversations);
    }

    public function store(Request $request){
        $me = Auth::user();

        $data = $request->validate([
            'user_id' => 'required|integer|exists:users,id',
        ]);

        $other = User::query()->findOrFail($data['user_id']);

        $existing = Conversation::query()
            ->with([
                'users:id',
                'users.profile:user_id,first_name,profile_image',
                'lastMessage.sender:id',
                'lastMessage.sender.profile:user_id,first_name,profile_image'
            ])
            ->where('type', 'direct')
            ->whereHas('users', fn($q) => $q->where('users.id', $me->id))
            ->whereHas('users', fn($q) => $q->where('users.id', $other->id))
            ->withCount('users')
            ->having('users_count', '=', 2)
            ->first();

        if($existing){
            return new ConversationResource($existing);
        }

        $conversation = DB::transaction(function () use ($me, $other){
            $c = Conversation::query()->create([
                'type' => 'direct',
                'created_by' => $me->id,
            ]);
            $c->users()->attach([$me->id, $other->id]);

            return $c;
        });

        $conversation->load([
            'users:id',
            'users.profile:user_id,first_name,profile_image',
            'lastMessage.sender:id',
            'lastMessage.sender.profile:user_id,first_name,profile_image'
        ]);

        return new ConversationResource($conversation);
    }

    public function show(Request $request,Conversation $conversation){
        $user=Auth::user();
        abort_unless($conversation->users()->where('users.id',$user->id)->exists(), 403);
        $conversation->load(['users:id,name,email', 'lastMessage.sender:id,name,email']);
        return new ConversationResource($conversation);
    }

}
