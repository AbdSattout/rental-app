<?php

namespace App\Http\Controllers;
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
                'status'=>404
            ]);
        }
        $validatedData = $request->validated();
        if($request->hasFile('ID_image')){  
            if ($profile->ID_image) {
                 Storage::disk('public')->delete($profile->ID_image);
            }
            $newPath = $request->file('ID_image')->store('user_ids' , 'public') ; 
            $validatedData['ID_image'] = $newPath;
        }

        if($request->hasFile('profile_image')){
            
            if ($profile->Profile_image) {
                 Storage::disk('public')->delete($profile->Profile_image);
            }
            
            $newPath = $request->file('profile_image')->store('profile_photos' , 'public') ;
            $validatedData['profile_image'] = $newPath;
        }
        
        $profile->update($validatedData);
        
        return response()->json([
            'message'=>'Profile updated successfully',
            'data'=>$profile,
            'status'=>200
        ]);
    }
    
    
}

