<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class MessageResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [ 'id' => $this->id,
            'conversation_id' => $this->conversation_id,
            'sender' => new UserResource($this->whenLoaded('sender')),
            'body' => $this->body,
            'type' => $this->type,
            'attachment_path' => $this->attachment_path,
            'status' => $this->when(
                $this->sender_id === auth()->id(),
                function() {
                    return $this->conversation->getMessageStatusFor($this->resource, auth()->user());
                }
            ),
            'created_at' => $this->created_at?->toISOString(),
        ];
    }
}
