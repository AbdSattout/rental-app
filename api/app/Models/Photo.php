<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Photo extends Model
{
    const TYPE_OUTSIDE='outside';
    const TYPE_INSIDE='inside';
    protected $guarded = [];
    public function post()
    {
        return $this->belongsTo(Post::class, 'post_id');
    }

    public function isOutside():bool
    {
        return $this->type===self::TYPE_OUTSIDE;
    }

    public function isInside():bool
    {
    return $this->type===self::TYPE_INSIDE;
    }
}
