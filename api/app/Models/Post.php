<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Post extends Model
{
protected $guarded =[
    'id'
];
public function profile(){
    return $this->belongsTo(Profile::class);
}
public function photos(){
    return $this->hasMany(Photo::class);
}
}
