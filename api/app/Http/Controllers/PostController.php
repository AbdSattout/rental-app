<?php

namespace App\Http\Controllers;

use App\Http\Requests\FilterPostRequest;
use App\Http\Requests\PostRequest;
use App\Http\Requests\UpdatePostRequest;
use App\Models\Favorite;
use App\Models\Photo;
use App\Models\Post;
use App\Models\Profile;
use App\Models\User;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;

class PostController extends Controller
{
    public function store(PostRequest $request)
    {
        $user_id = Auth::user()->id;
        $profile = Profile::query()->where("user_id", $user_id)->firstOrFail();
        $profile_id = $profile->id;

        $postData = $request->validated();
        $postData["profile_id"] = $profile_id;
        unset($postData["outside_photos"],$postData["inside_photos"]);
        $uploadedPhotoPaths = [];
        DB::beginTransaction();

        try {
            $post = Post::query()->create($postData);

            if ($request->hasFile("outside_photos")) {
                $outsidePhotoPaths = $this->storePhotosToPost(
                    $post,
                    $request->file("outside_photos"),
                    Photo::TYPE_OUTSIDE
                );
                $uploadedPhotoPaths = array_merge($uploadedPhotoPaths, $outsidePhotoPaths);
            }
            if ($request->hasFile("inside_photos")) {
                $insidePhotoPaths = $this->storePhotosToPost(
                    $post,
                    $request->file("inside_photos"),
                    Photo::TYPE_INSIDE
                );
                $uploadedPhotoPaths = array_merge($uploadedPhotoPaths, $insidePhotoPaths);
            }

            DB::commit();

            return response()->json(
                [
                    "message" => "Post created successfully",
                    "post" => $post->load(
                        "outsidePhotos",
                    "insidePhotos"),
                ],
                201,
            );
        } catch (\Exception $e) {
            DB::rollBack();
            Log::error("Failed to create post", [
                "user_id" => $user_id,
                "error" => $e->getMessage(),
                "trace" => $e->getTraceAsString(),
            ]);

            foreach ($uploadedPhotoPaths as $path) {
                Storage::delete($path);
            }
            return response()->json(
                [
                    "error" => "Failed to create post",
                ],
                400,
            );
        }
    }


    public function update(UpdatePostRequest $request, $PostId)
    {
        $user_id = Auth::user()->id;
        $profile = Profile::query()->where("user_id", $user_id)->firstOrFail();

        $post = Post::query()
            ->where("profile_id", $profile->id)
            ->findOrFail($PostId);

        DB::beginTransaction();

        try {
            $post->update($request->except(['outside_photos', 'inside_photos']));


            if ($request->hasFile("outside_photos")) {
                $this->deleteOldPhotos($post,Photo::TYPE_OUTSIDE);
                $this->storePhotosToPost($post, $request->file("outside_photos"),Photo::TYPE_OUTSIDE);
            }
            if ($request->hasFile("inside_photos")) {
                $this->deleteOldPhotos($post,Photo::TYPE_INSIDE);
                $this->storePhotosToPost($post, $request->file("inside_photos"),Photo::TYPE_INSIDE);
            }
            DB::commit();

            return response()->json(
                [
                    "message" => "Post updated successfully",
                    "post" => $post->load("outsidePhotos"
                        ,"insidePhotos"),
                ],
                200,
            );
        } catch (\Exception $e) {
            DB::rollBack();

            return response()->json(
                [
                    "error" => "Failed to update post",
                    "message" => $e->getMessage(),
                ],
                400,
            );
        }
    }

    private function storePhotosToPost(Post $post, array $photos,String $type)
    {
        $uploadedPaths = [];

        foreach ($photos as $photoFile) {
            $path = $photoFile->store("post_photos/{$post->id}/$type");

            $post->photos()->create([
                "post_id"=>$post->id,
                "file_path" => $path,
                "type"=>$type
            ]);
            $uploadedPaths[] = $path;
        }
        return $uploadedPaths;
    }

    private function deleteOldPhotos(Post $post,String $type)
    {
        if($type == Photo::TYPE_OUTSIDE){

            foreach ($post->outsidePhotos as $photo) {
                Storage::delete($photo->file_path);
            }
            $post->outsidePhotos()->delete();
        }

        if($type == Photo::TYPE_INSIDE){
            foreach ($post->insidePhotos as $photo) {
                Storage::delete($photo->file_path);
            }

            $post->insidePhotos()->delete();
        }
    }

    public function getHomepageFeed()
    {


        $postQ = Post::query()
            ->with(['outsidePhotos','insidePhotos'])
            ->latest();
        $user = Auth::guard('sanctum')->user();
        if ($user) {
            $profile = $user->profile;

            if ($profile) {

                $postQ->whereNotIn('profile_id', [$profile->id]);

            }
        }

        $posts = $postQ->paginate(20);



        return response()->json(["posts" => $posts], 200);

            }



    public function getPostDetails($PostId)
    {

        $user = Auth::guard('sanctum')->user();
        if($user){
            $userId=$user->id;
            //$isFavorited=$this->isFavorited($user,$PostId);
            $details=Post::query()
                ->with('profile')
                ->with(['outsidePhotos','insidePhotos'])->withCount(['favoritedBy' => function ($query) use ($userId) {
                    $query->where('user_id', $userId);
                }])
                ->withAvg('ratings' , 'rating')
                ->withCount('ratings')
                ->with(['ratings'=>function($query) use ($userId) {
                    $query->with(['user'=>function($q){
                        $q->select('id')->with('profile');
                    }])
                        ->orderBy('created_at' , 'desc')
                        ->limit(5);
                }])
                ->findOrFail($PostId);
            return response()->json($details,200);

        }
        $details=Post::query()
            ->with('profile')
            ->with(['outsidePhotos','insidePhotos'])
            ->withAvg('ratings' , 'rating')
            ->withCount('ratings')
            ->with(['ratings'=>function($query){
                $query->with(['user'=>function($q){
                    $q->select('id')->with('profile');
                }])
                    ->orderBy('created_at' , 'desc')
                    ->limit(5);
            }])
            ->findOrFail($PostId);
        $details->makeHidden('latest_photo_path');
        return response()->json($details,200);
    }

    public function getUsersPosts($ProfileId)
    {
        $posts = Post::query()
            ->with(['outsidePhotos','insidePhotos'])
            ->where("profile_id", $ProfileId)
            ->latest()
            ->paginate(20);

        return response()->json(["posts" => $posts], 200);
    }

    public function getOwnPosts()
    {
        $user_id = Auth::user()->id;
        $profile = Profile::query()->
        where("user_id", $user_id)
            ->firstOrFail();

        $posts = $profile
            ->posts()
            ->with(['outsidePhotos','insidePhotos'])
            ->latest()
            ->paginate(20);

        return response()->json(["posts" => $posts], 200);
    }

    public function filterPosts(FilterPostRequest $request)
    {
        $query = Post::query();
        $user = Auth::guard('sanctum')->user();

        if ($request->filled("type")) {
            $query->where("type", "=", $request->input("type"));
        }

        if ($request->filled("min_price")) {
            $query->where("price", ">=", $request->input("min_price"));
        }
        if ($request->filled("max_price")) {
            $query->where("price", "<=", $request->input("max_price"));
        }
        if ($request->filled("min_rooms")) {
            $query->where("rooms", ">=", $request->input("min_rooms"));
        }
        if ($request->filled("max_rooms")) {
            $query->where("rooms", "<=", $request->input("max_rooms"));
        }

        if ($request->filled('user_lat') && $request->filled('user_lng')) {

            $userLat = $request->input('user_lat');
            $userLng = $request->input('user_lng');

          //10 kilos if you are not allowing inserting radius
            $radius = $request->input('radius', 10);

            $query->withinDistance($userLat, $userLng, $radius);

        }

        if($user){
            $profile=$user->profile;
            $profile_id = $profile->id;

            $posts=$query->with(['outsidePhotos','insidePhotos'])
                ->whereNotIn('profile_id', [$profile_id])
                ->paginate(20);

            return response()->json($posts,200);
        }
        $posts=$query->with(['outsidePhotos','insidePhotos'])
        ->paginate(20);

        return response()->json($posts,200);
    }

    public function deletePost($Postid)
    {
        $user_id = Auth::user()->id;
        $profiles = Profile::query()->where("user_id", $user_id)->firstOrFail();
        $post = Post::query()
            ->where("profile_id", $profiles->id)
            ->findOrFail($Postid);
        $post->delete();
        return response()->json(["message" => "Deleted Successfully"], 202);
    }


}
