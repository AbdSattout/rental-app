<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Message extends Model
{
    protected $guarded=[];

    public function conversation():BelongsTo
    {
        return $this->belongsto(Conversation::class);
    }
    public function sender():BelongsTo
    {
        return $this->belongsTo(User::class,'sender_id');
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
