<?php

namespace App\Events;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PresenceChannel;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class MessageRead
{
    use Dispatchable, InteractsWithSockets, SerializesModels;
    public $messageId;
    public $conversationId;
    public $userId;
    public function __construct($messageId, $conversationId, $userId)
    {
        $this->messageId = $messageId;
        $this->conversationId = $conversationId;
        $this->userId = $userId;
    }

    /**
     * Get the channels the event should broadcast on.
     *
     * @return array<int, \Illuminate\Broadcasting\Channel>
     */
    public function broadcastOn(): array
    {
        return [
            new PrivateChannel('conversation.'.$this->conversationId),
        ];
    }
    public function broadcastWith()
    {
        return [
            'message_id' => $this->messageId,
            'read_by' => $this->userId,
            'status' => 'read'
        ];
    }

}
