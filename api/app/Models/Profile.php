<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
class Profile extends Model
{
    protected $guarded = [];
public function user(){
    return $this->belongsTo(User::class);
}
    public function posts(){
        return $this->hasMany(Post::class);
    }


}
