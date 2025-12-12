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
    return $this->belongsTo(Profile::class , 'profile_id');
}
public function photos(){
    return $this->hasMany(Photo::class,'post_id');
}

public function reservations(){
    return $this->hasMany(Reservation::class,'post_id');
}
    public function scopeDistance($query, $lat, $lng)
    {

        $radius = 6371;


        $sql = "($radius * acos(
            cos(radians(?)) * cos(radians(latitude)) * cos(radians(longitude) - radians(?))
            + sin(radians(?)) * sin(radians(latitude))
        ))";


        return $query->selectRaw("posts.*, {$sql} AS distance", [$lat, $lng, $lat]);
    }

    public function scopeWithinDistance($query, $lat, $lng, $distanceKm = 5)
    {

        return $query->distance($lat, $lng)
            ->having('distance', '<=', $distanceKm)
            ->orderBy('distance', 'asc');
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
