<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
class Conversation extends Model
{
    protected $guarded=[];

    public function users():BelongsToMany
    {
        return $this->belongsToMany(User::class,'conversation_user')->withTimestamps()
            ->withPivot(['last_read_message_id','last_delivered_message_id']);
    }
    public function messages():HasMany
    {
        return $this->hasMany(Message::class);
    }
    public function lastMessage()
    {
        return $this->hasOne(Message::class)->latest();
    }
    public function getMessageStatusFor(Message $message, User $viewer)
    {
        $otherUsers = $this->users()
            ->where('users.id', '!=', $message->sender_id)
            ->get();
        $hasRead = false;
        $hasDelivered = false;
        foreach ($otherUsers as $user) {
            if ($user->pivot->last_read_message_id && $user->pivot->last_read_message_id >= $message->id) {
                $hasRead = true;

            }
            if ($user->pivot->last_delivered_message_id && $user->pivot->last_delivered_message_id >= $message->id) {
                $hasDelivered = true;
            }
        }

        if ($hasRead) {
            return 'read';
        }
        if ($hasDelivered) {
            return 'delivered';
        }

        return 'sent';
    }

}
