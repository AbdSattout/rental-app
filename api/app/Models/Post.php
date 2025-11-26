<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Post extends Model
{
protected $guarded =[
    'id',
    'profile_id'
];
public function profile(){
    return $this->belongsTo(Profile::class);
}

}
