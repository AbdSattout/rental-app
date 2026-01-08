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
            ->with([
                'users:id',
                'users.profile:user_id,first_name,profile_image',
                'lastMessage.sender:id',
                'lastMessage.sender.profile:user_id,first_name,profile_image'
            ])
            ->orderByDesc(
                Conversation::select('updated_at')
                ->whereColumn('conversations.id','conversation_user.conversation_id')
            )->paginate(50);
        return ConversationResource::collection($conversations);
    }

    public function store(Request $request)
    {
        $me = Auth::user();

        $data = $request->validate([
            'user_id' => 'required|integer|exists:users,id',
        ]);

        if ($data['user_id'] === $me->id) {
            abort(422, 'Cannot start a conversation with yourself');
        }

        $other = User::query()->findOrFail($data['user_id']);


        $relationships = [
            'users:id',
            'users.profile:user_id,first_name,profile_image',
            'lastMessage.sender:id',
            'lastMessage.sender.profile:user_id,first_name,profile_image'
        ];

        $existing = Conversation::query()
            ->with($relationships)
            ->where('type', 'direct')
            ->whereHas('users', fn($q) => $q->where('users.id', $me->id))
            ->whereHas('users', fn($q) => $q->where('users.id', $other->id))
            ->has('users', '=', 2)
            ->first();

        if ($existing) {
            return new ConversationResource($existing);
        }

        $conversation = DB::transaction(function () use ($me, $other) {
            $c = Conversation::query()->create([
                'type' => 'direct',
                'created_by' => $me->id,
            ]);
            $c->users()->attach([$me->id, $other->id]);

            return $c;
        });


        $conversation->load($relationships);

        return new ConversationResource($conversation);
    }

    public function show(Request $request,Conversation $conversation){
        $user=Auth::user();
        abort_unless($conversation->users()->where('users.id',$user->id)->exists(), 403);
        $conversation->load([
            'users:id',
            'users.profile:user_id,first_name,profile_image',
            'lastMessage.sender:id',
            'lastMessage.sender.profile:user_id,first_name,profile_image'
        ]);
        return new ConversationResource($conversation);
    }

}
