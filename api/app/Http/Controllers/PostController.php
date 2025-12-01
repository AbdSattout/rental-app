<?php

namespace App\Http\Controllers;

use App\Http\Requests\FilterPostRequest;
use App\Http\Requests\PostRequest;
use App\Http\Requests\UpdatePostRequest;
use App\Models\Post;
use App\Models\Profile;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

class PostController extends Controller
{

    public function store(PostRequest $request)
    {
        $user_id = Auth::user()->id;
        $profile = Profile::query()->where('user_id', $user_id)->firstOrFail();
        $profile_id = $profile->id;

        $postData=$request->validated();
        $postData['profile_id'] = $profile_id;
        unset($postData['photos']);


        $uploadedPhotoPaths = [];
        DB::beginTransaction();

        try {
            $post = Post::create($postData);


            if ($request->hasFile('photos')) {
                $uploadedPhotoPaths=$this->storePhotosToPost($post, $request->file('photos'));
            }

            DB::commit();

            return response()->json([
                'message' => 'Post created successfully',
                'post' => $post->load('photos')
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();
            \Log::error('Failed to create post', [
                             'user_id' => $user_id,
                              'error' => $e->getMessage(),
                               'trace' => $e->getTraceAsString()
            ]);

                 foreach ($uploadedPhotoPaths as $path) {
                     Storage::disk('public')->delete($path);
                             }
            return response()->json([
                'error' => 'Failed to create post',
            ], 500);
        }
    }

    public function update(UpdatePostRequest $request, $PostId)
    {
        $user_id = Auth::user()->id;
        $profile = Profile::query()->where('user_id', $user_id)->firstOrFail();

        $post = Post::query()
            ->where("profile_id", $profile->id)
            ->findOrFail($PostId);

        DB::beginTransaction();

        try {
            $post->update($request->except('photos'));

            if ($request->hasFile('photos')) {
                $this->deleteOldPhotos($post);
                $this->storePhotosToPost($post, $request->file('photos'));
            }

            DB::commit();

            return response()->json([
                'message' => 'Post updated successfully',
                'post' => $post->load('photos')
            ], 200);

        } catch (\Exception $e) {
            DB::rollBack();

            return response()->json([
                'error' => 'Failed to update post',
                'message' => $e->getMessage()
            ], 500);
        }
    }


    private function storePhotosToPost(Post $post, array $photos)
    {
        foreach ($photos as $photoFile) {
            $path = $photoFile->store('post_photos', 'public');

            $post->photos()->create([
                'file_path' => $path
            ]);
        }
    }

    private function deleteOldPhotos(Post $post)
    {
        foreach ($post->photos as $photo) {
            Storage::disk('public')->delete($photo->file_path);
        }
        $post->photos()->delete();
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

    public function getPostDetails($PostId)
    {
        $details=Post::query()->with('photos')->findOrFail($PostId);
        $details->makeHidden('latest_photo_path');
        return response()->json([$details],200);
    }

    public function getUsersPosts($ProfileId){
        $posts=Post::query()->with(['photos' => function ($query){
            $query->orderBy('created_at','desc');
            $query->limit(1);
        }])->where('profile_id', $ProfileId)
            ->select(['id','type','price'])
            ->latest()
            ->paginate(20);

        return response()->json(["posts"=>$posts],200);
    }

    public function getOwnPosts(){
        $user_id=Auth::user()->id;
        $profile=Profile::query()->where('user_id', $user_id)->firstOrFail();
        $posts=$profile->posts()->with(['photos' => function ($query){ $query->orderBy('created_at','desc');
            $query->limit(1);
        }])->select(['id','type','price'])
            ->latest()
            ->paginate(20);

        return response()->json(["posts"=>$posts],200);
    }


    public function filterPosts(FilterPostRequest $request){
       $query=Post::query();

        if($request->filled('type')){
            $query->where('type','=',$request->input('type'));
        }
        if($request->filled('min_price')){
            $query->where('price','>=',$request->input('min_price'));
        }
        if($request->filled('max_price')){
            $query->where('price','<=',$request->input('max_price'));
        }
        if($request->filled('min_rooms')){
            $query->where('rooms','>=',$request->input('min_rooms'));
        }
        if($request->filled('max_rooms')){
            $query->where('rooms','<=',$request->input('max_rooms'));
        }

        $posts=$query->paginate(20);
        return response()->json([$posts],200);
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
