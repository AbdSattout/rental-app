<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    /** @use HasFactory<\Database\Factories\UserFactory> */
    use HasFactory, Notifiable, HasApiTokens;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        "phone_number",
        "password",
        "is_approved",
        "role",
        "requesting_host",
        "fcm_token",
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var list<string>
     */
    protected $hidden = ["password", "remember_token"];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            "is_approved" => "boolean",
            "requesting_host" => "boolean",
            //  'email_verified_at' => 'datetime',
            // 'password' => 'hashed',
        ];
    }

    public function profile()
    {
        return $this->hasOne(Profile::class);
    }
    public function orders()
    {
        return $this->hasMany(Order::class);
    }
    public function reservations()
    {
        return $this->hasMany(Reservation::class);
    }

    public function favorites(){

        return $this->belongsToMany(Post::class,'favorites','user_id','post_id');

    }
    public function posts(){
        return $this->hasMany(Post::class , 'profile_id' , 'id');
    }
    public function ratings(){
        return $this->hasMany(Rating::class );
    }
}
