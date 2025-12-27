<?php

namespace App\Events;

use App\Http\Resources\MessageResource;
use App\Models\Message;
use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PresenceChannel;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class MessageSent implements ShouldBroadcastNow
{
    use Dispatchable, SerializesModels;

    public function __construct(public Message $message ) {}

    // Define the broadcast channel
    public function broadcastOn(): array
    {
        return [
            new PrivateChannel('conversation.' . $this->message->conversation_id),
        ];
    }

    // Define the event's name for clients to listen for
    public function broadcastAs(): string
    {
        return 'message.sent';
    }

    // Define the data that will be broadcast
    public function broadcastWith(): array
    {
        // Return the message formatted using MessageResource
        $this->message->loadMissing('sender:id,name,email');
        return (new MessageResource($this->message))->resolve();
    }


}
