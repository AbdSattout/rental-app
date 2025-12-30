<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Http\Requests\RatingRequest;
use App\Models\Post;
use App\Models\Rating;
use Illuminate\Support\Facades\Auth;

class RatingController extends Controller
{
    public function StoreRating(RatingRequest $request , Post $post){
      $this->authorize('create' , $post);
        $user=Auth::user();
        $ratings=$post->ratings()->where('user_id',$user->id)->get();
        if($ratings->isEmpty()){
      $rating = Rating::create([
        'user_id' => Auth::id(),
        'post_id' => $post->id ,
        'rating' => $request->rating ,
        'review' => $request->review ,
      ]);
        return response()->json([
            'message' => 'Rating submitted successfully',
            'rating' => $rating
        ] , 201);}
        else{
            return response()->json(['message' => 'You have already rated this post'], 409);
        }
    }

    public function GetPostRatings(Request $request, Post $post){
        $sortOrder = $request->get('sort', 'desc');
        $reviews = $post->ratings()->with(['user'=>function($query){
            $query->select('id')->with('profile');
        }])->orderBy('created_at' , $sortOrder)->paginate(10);
        return response()->json($reviews , 200);
    }
}
