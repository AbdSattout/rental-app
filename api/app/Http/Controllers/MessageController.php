<?php

namespace App\Http\Controllers;

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

        $messages =$conversation->messages()
            ->with([
                'sender:id',
                'sender.profile:user_id,first_name,last_name,profile_image'
            ])->latest()
            ->cursorPaginate(50);
        $messages->setCollection($messages->getCollection()->reverse()->values());
        return MessageResource::collection($messages);
    }

    // Send a message in a conversation
    public function store(Request $request, $conversationId)
    {
        $validated = $request->validate([
            'body' => 'nullable|string|max:1000',
            'attachment' => 'nullable|file|mimes:jpg,jpeg,png,pdf,doc,docx,mp4|max:20480',
        ]);

        $attachmentPath = null;
        $type = 'text';

        if ($request->hasFile('attachment')) {
            $file = $request->file('attachment');
            $attachmentPath = $file->store('messages/attachments', 'public');

            // Determine type based on mime type
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
            'conversation_id' => $conversationId,
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


    public function markRead(Request $request, Conversation $conversation)
    {
        abort_unless($conversation->users()->where('users.id', $request->user()->id)->exists(), 403);

        $data = $request->validate([
            'last_read_message_id' => ['required','integer','exists:messages,id'],
        ]);

        // Update the `last_read_message_id` for the user in the conversation
        $conversation->users()->updateExistingPivot($request->user()->id, [
            'last_read_message_id' => $data['last_read_message_id'],
        ]);

        return response()->json(['message' => 'Read updated']);
    }
}
