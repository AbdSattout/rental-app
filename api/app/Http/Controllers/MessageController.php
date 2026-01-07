<?php

namespace App\Http\Controllers;

use App\Events\MessageDelivered;
use App\Events\MessageRead;
use App\Events\MessageSent;
use App\Http\Resources\MessageResource;
use App\Models\Conversation;
use App\Models\Message;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;


class MessageController extends Controller
{

    public function index(Request $request, Conversation $conversation)
{
    if (!$conversation->users()->where('users.id', auth()->id())->exists()) {
        abort(403);
    }

    // Use oldest() with cursor pagination - this is the key
    $messages = $conversation->messages()
        ->with([
            'sender:id',
            'sender.profile:user_id,first_name,last_name,profile_image'
        ])
        ->latest() // Use oldest instead of latest
        ->cursorPaginate(10);

    // Messages are already in correct chronological order (oldest to newest)
    // No need to reverse

    $conversationUsers = $conversation->users()
        ->select('users.id')
        ->withPivot('last_read_message_id', 'last_delivered_message_id')
        ->get();

//    $messages->setCollection($messages->getCollection()->reverse()->values());
    $messages->getCollection()->transform(function ($message) use ($conversationUsers) {
        if ($message->sender_id === auth()->id()) {
            $message->status = $this->calculateStatus($message, $conversationUsers);
        }
        return $message;
    });

    return MessageResource::collection($messages);
}


    public function store(Request $request,Conversation $conversation)
    {

        if (!$conversation->users()->where('users.id', auth()->id())->exists()) {
            abort(403);
        }
        $validated = $request->validate([
                'body' => 'required_without:attachment|nullable|string|max:1000',
                'attachment' => 'required_without:body|nullable|file|mimes:jpg,jpeg,png,pdf,doc,docx,mp4|max:20480',
        ]);

        $attachmentPath = null;
        $type = 'text';

        if ($request->hasFile('attachment')) {
            $file = $request->file('attachment');
            $attachmentPath = $file->store('messages/attachments', 'public');


            $mimeType = $file->getMimeType();

            if (str_starts_with($mimeType, 'image/')) {
                $type = 'image';
            } elseif (str_starts_with($mimeType, 'video/')) {
                $type = 'video';
            } else {
                $type = 'file';
            }
        }

        $message = Message::create([
            'conversation_id' => $conversation->id,
            'sender_id' => auth()->id(),
            'body' => $validated['body'] ?? '',
            'type' => $type,
            'attachment_path' => $attachmentPath,
        ]);

        $message->load('sender:id',
            'sender.profile:user_id,first_name,profile_image');


        broadcast(new MessageSent($message))->toOthers();

        return response()->json([
            'success' => true,
            'message' => $message,
            'attachment_url' => $attachmentPath ? asset('storage/' . $attachmentPath) : null
        ], 201);
    }

    public function markDelivered(Request $request, Conversation $conversation)
    {
        abort_unless(
            $conversation->users()->where('users.id', $request->user()->id)->exists(),
            403
        );

        $data = $request->validate([
            'message_id' => [
                'required',
                'integer',
                'exists:messages,id,conversation_id,' . $conversation->id
            ],
        ]);

        $conversation->users()->updateExistingPivot($request->user()->id, [
            'last_delivered_message_id' => $data['message_id'],
            'last_delivered_at' => now(),
        ]);

        // Broadcast to sender
        broadcast(new MessageDelivered(
            $data['message_id'],
            $conversation->id,
            $request->user()->id
        ))->toOthers();

        return response()->json(['message' => 'Delivered']);
    }

    // Update your existing markRead method
    public function markRead(Request $request, Conversation $conversation)
    {
        abort_unless(
            $conversation->users()->where('users.id', $request->user()->id)->exists(),
            403
        );

        $data = $request->validate([
            'last_read_message_id' => [
                'required',
                'integer',
                'exists:messages,id,conversation_id,' . $conversation->id
            ]
        ]);

        $conversation->users()->updateExistingPivot($request->user()->id, [
            'last_read_message_id' => $data['last_read_message_id'],
            'last_delivered_message_id' => $data['last_read_message_id'],
        ]);

        // Broadcast to sender
        broadcast(new MessageRead(
            $data['last_read_message_id'],
            $conversation->id,
            $request->user()->id
        ))->toOthers();

        return response()->json(['message' => 'Read updated']);
    }

    private function calculateStatus($message, $conversationUsers)
    {
        $hasRead = false;
        $hasDelivered = false;

        foreach ($conversationUsers as $user) {
            if ($user->id === $message->sender_id) continue;

            if ($user->pivot->last_read_message_id && $user->pivot->last_read_message_id >= $message->id) {
                $hasRead = true;
            }
            if ($user->pivot->last_delivered_message_id && $user->pivot->last_delivered_message_id >= $message->id) {
                $hasDelivered = true;
            }
        }

        return $hasRead ? 'read' : ($hasDelivered ? 'delivered' : 'sent');
    }

}
