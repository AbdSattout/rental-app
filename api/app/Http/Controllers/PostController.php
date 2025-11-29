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

    public function store(PostRequest $request)
    {
        $user_id=Auth::user()->id;
        $profiles=Profile::query()->where('user_id',$user_id)->firstOrFail();

        $validatedData = $request->validated();

        $validatedData['profile_id']=$profiles->id;

        Post::query()->create($validatedData);
        return response()->json(["message"=>'success'],200);

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
