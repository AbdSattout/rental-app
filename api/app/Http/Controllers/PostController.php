<?php

namespace App\Http\Controllers;

use App\Http\Requests\PostRequest;
use App\Http\Requests\UpdatePostRequest;
use App\Models\Post;
use App\Models\Profile;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;

class PostController extends Controller
{

    public function getPostDetails($PostId)
    {
    $details=Post::query()->with('photos')->findOrFail($PostId);
    $details->makeHidden('latest_photo_path');
    return response()->json([$details],200);
    }

    public function store(PostRequest $request)
    {
        $user_id=Auth::user()->id;
        $profiles=Profile::query()->where('user_id',$user_id)->firstOrFail();

        $validatedData = $request->validated();
        $validatedData['profile_id']=$profiles->id;

        $post=Post::query()->create($validatedData);
        if ($request->hasFile('photos')) {
            foreach ($request->file('photos') as $file) {
                $path = $file->store('post_photos', 'public');
                $post->photos()->create([
                    'file_path' => $path,
                ]);
            }
        }
$post->makeHidden('latest_photo_path');
        $photos=$post->photos()->get();
        if(is_null($post)){
            return response()->json([
                "message"=>"you have to add contents in order to create a post"
            ],404);
        }
        return response()->json(["message"=>"Posted Successfully",
            "contents"=>$post,'photos'=>$photos],201);

    }


    public function getHomepageFeed(){
        $posts=Post::query()->with(['photos' => function ($query){
            $query->orderBy('created_at','desc');
            $query->limit(1);
        }])
            ->select(['id','type','price'])
            ->latest()
            ->paginate(20);

        return response()->json(["posts"=>$posts],200);
    }

    public function update(UpdatePostRequest $request,  $PostId)
    {
        //needs edits to make it efficient for photos
        $user_id=Auth::user()->id;
        $profile=Profile::query()->where('user_id',$user_id)->firstOrFail();
        $validatedData = $request->validated();
        $post = Post::query()
            ->where('profile_id', $profile->id)
            ->findOrFail($PostId);


        $post->update(['type'=>$validatedData['type'] ?? $post->type,
            'space'=>$validatedData['space'] ?? $post->space,
            'rooms'=>$validatedData['rooms'] ?? $post->rooms,
            'price'=>$validatedData['price'] ?? $post->price,
            'latitude'=>$validatedData['latitude'] ?? $post->latitude,
            'longitude'=>$validatedData['longitude'] ?? $post->longitude,
            ]);
        if ($request->hasFile('photos')) {
//            $post->photos->each(function ($photo) {
//                Storage::disk('public')->delete($photo->file_path);
//
//                $photo->delete();
//            });
            foreach ($request->file('photos') as $file) {
                $path = $file->store('post_photos', 'public');
                $post->photos()->update([
                    'file_path' => $path,
                ]);
            }
        }
        return response()->json(["message"=>"Updated Successfully"],200);
    }


    public function deletePost($Postid)
    {
        $user_id=Auth::user()->id;
        $profiles=Profile::query()->where('user_id',$user_id)->firstOrFail();
        $post=Post::query()->where('profile_id',$profiles->id)->findOrFail($Postid);
        $post->delete();
        return response()->json(["message"=>"Deleted Successfully"],201);
    }
}
