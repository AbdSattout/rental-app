<?php

namespace App\Http\Controllers;
use App\Models\Post;
use App\Models\Profile;
use App\Http\Requests\ProfileRequest;
use App\Http\Requests\UpdatePostRequest;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Http\Requests\UpdateProfileRequest;
use Illuminate\Support\Facades\Storage;

class ProfileController extends Controller
{
    public function update(UpdateProfileRequest $request){

        $user = Auth::user();
        $profile = $user->profile;
        if(!$profile){
            return response()->json([
                'message'=>'Profile not found. You must complete the registration or profile creation.',
            ],404);
        }
        $validatedData = $request->validated();
        if($request->hasFile('ID_image')){
            if ($profile->ID_image) {
                Storage::delete($profile->ID_image);
            }
            $newPath = $request->file("ID_image")->store("user_ids");
            $validatedData["ID_image"] = $newPath;
        }

        if ($request->hasFile("profile_image")) {
            if ($profile->profile_image) {
                Storage::delete($profile->profile_image);
            }

            $newPath = $request->file("profile_image")->store("profile_images");
            $validatedData["profile_image"] = $newPath;
        }

        $profile->update($validatedData);

        return response()->json([
            'message'=>'Profile updated successfully',
            'data'=>$profile,
        ],200);
    }


    public function getOwnProfile(){
        $user_id = Auth::id();
        $profile=Profile::query()
            ->where('user_id',$user_id)
            ->firstOrFail();

        return response()->json($profile,200);

    }

    public function getUserProfile($post_id){

        $profile=Post::query()->with('profile')
            ->find($post_id);

        if(is_null($profile)){
            return response()->json([
                'message'=>'Profile not found. You must complete the registration or profile creation.'
            ],404);
        }

        return response()->json($profile['profile'],200);
    }

}
