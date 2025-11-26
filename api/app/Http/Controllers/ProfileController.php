<?php

namespace App\Http\Controllers;
use App\Models\Profile;
use App\Http\Requests\ProfileRequest;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class ProfileController extends Controller
{
    public function store(ProfileRequest $request){
    $user_id = Auth::user()->id;
    $validatedData = $request->validated();
    $validatedData['user_id'] = $user_id ;
    if($request->hasFile('ID_image')){
        $path = $request->file('ID_image')->store('my photo' , 'public') ;
        $validatedData['ID_image']=$path;
    }
     if($request->hasFile('profile_image')){
        $path = $request->file('profile_image')->store('my photo' , 'public') ;
        $validatedData['profile_image']=$path;
    }
    $profile = Profile::create($validatedData);
    return response()->json([
    'message'=>'profile created successfully',
    'data'=>$profile,
    'status'=>201
    ]);
    }
}
