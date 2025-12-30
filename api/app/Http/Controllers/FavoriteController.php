<?php

namespace App\Http\Controllers;

use App\Models\Favorite;
use App\Models\Post;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class FavoriteController extends Controller
{
    public function Toggle(Post $post){
        $user = Auth::user();

       $result= $user->favorites()->toggle($post->id);

         $isFavorited=!empty($result['attached']);

         return response()->json([
             'results'=>$isFavorited,
         'message'=>$isFavorited ? 'Post added to favorites'
                : 'Post removed from favorites'],200);
        }


    public function showFavorites(){

        $user = Auth::user();

        $favorites =$user->favorites()->with('photos')->get();

                if($favorites->isEmpty()){
                    return response()->json([
                        'message'=>'No favorite posts found'
                    ],404);
                }
                return response()->json([
                    'favorites'=>$favorites
                ],200);
    }


}
