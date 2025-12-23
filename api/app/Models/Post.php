<?php

namespace App\Models;
use App\Models\Rating;
use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\DB;

class Post extends Model
{
    protected $appends = [
        'latest_photo_path' ,
        'average_rating',
        'ratings_count'
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
    public function scopeWithinDistance($query, $lat, $lng, $distanceKm = 5)
    {

        $radius = 6371;
        $distanceSql = "($radius * acos(
        cos(radians(?)) * cos(radians(latitude)) * cos(radians(longitude) - radians(?))
        + sin(radians(?)) * sin(radians(latitude))
    ))";


        $query->selectRaw("posts.*, {$distanceSql} AS distance", [$lat, $lng, $lat]);

        $query->whereRaw("{$distanceSql} <= ?", [$lat, $lng, $lat, $distanceKm]);

        return $query->orderBy('distance', 'asc');
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
  public function ratings(){
        return $this->hasMany(Rating::class);
    }
    public function rationgWithUsers(){
        return $this->ratings()->with(['user'=>function($query){
            $query->select('id','first_name' , 'last_name')->with('profile');
        }])->limit(5)->orderBy('created_at' , 'desc');
    }
    
    protected function averageRating() : Attribute
    {
        return Attribute::make(
            get: fn()=>round($this->ratings()->avg('rating')?? 0,2)
        );
    }

    protected function ratingsCount() : Attribute
    {
        return Attribute::make(
            get: fn()=> $this->ratings()->count()
        );
    }
}
