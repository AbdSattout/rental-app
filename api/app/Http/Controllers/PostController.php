<?php

namespace App\Http\Controllers;

use App\Http\Requests\PostRequest;
use App\Models\Post;
use App\Models\Profile;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class PostController extends Controller
{

    public function index()
    {
        //
    }

    public function store(Request $request)
    {
        $user_id=Auth::user()->id;
        $profiles=Profile::query()->where('user_id',$user_id)->firstOrFail();

        $validatedData = $request->validate([
            "type"=>"required|in:House,Apartment,Villa,Office",
            "space"=>"required|numeric",
            "rooms"=>"required|integer",
            "price"=>"required|numeric|min:0",
            "latitude"=>"required",
            "longitude"=>"required",
            "availability"=>"nullable|boolean",
            "photos"=>"required|array|max:5",
            "photo.*"=>"required|image|mimes:jpeg,png,jpg,gif,svg|max:2048",
            ]);

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
        return response()->json(["message"=>'success'],200);

    }


    public function getHomepageFeed(){
        $posts=Post::query()
            ->with('photos')
            ->latest()
                ->paginate(20);

        return response()->json(["posts"=>$posts],200);
    }

    public function show(string $id)
    {

    }


    public function update(Request $request, string $id)
    {

    }


    public function destroy(string $id)
    {

    }
}
