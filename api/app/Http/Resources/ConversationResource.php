<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ConversationResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return[
            'id' => $this->id,
            'type' => $this->type,
            'title' => $this->title,
            'users' => UserResource::collection($this->whenLoaded('users')),
            'last_message' => new MessageResource($this->whenLoaded('lastMessage')),
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }
}
