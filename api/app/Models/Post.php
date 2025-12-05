<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Database\Eloquent\Model;

class Post extends Model
{
    protected $appends = [
        'latest_photo_path'
    ];
//    protected $hidden = [
//        'photos'
//    ];
protected $guarded =[];
public function profile(){
    return $this->belongsTo(Profile::class);
}
public function photos(){
    return $this->hasMany(Photo::class,'post_id');
}

public function reservations(){
    return $this->hasMany(Reservation::class,'post_id');
}
protected function latestPhotoPath() : Attribute
{
    return Attribute::make(
        get: function(){
            return $this->photos()
                ->limit(1)
                ->value('file_path');

}
    );
}
}
