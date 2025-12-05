<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Support\Facades\Storage;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AdminController extends Controller
{
    public function pending(){
        $pendingUsers = User::where('is_approved' , false)->where('role' , '!=','admin')->get();
        return response()->json([
            'message'=>'pending users retrieved successfully',
            'users'=>$pendingUsers,
             ] , 200);
    }
    public function approve(User $user){
        if($user->role === 'admin'){
        
            return response()->json([
                'message'=>'cannot approve admin user',
                ] , 403);
        }
        $user->is_approved = true;
        $user->save();
        return response()->json([
            'message'=>"User {$user->id} approved successfully",
            'user'=>$user,
        ],200);
       
    }
    public function reject(User $user){
        if($user->role === 'admin' && $user->id === Auth::id()){
        
            return response()->json([
                'message'=>'cannot reject or delete admin user',
                ] , 403);
        }
        $user->tokens()->delete();
        if($user->profile){
            if($user->profile->ID_image){
               Storage::disk('public')->delete($user->profile->ID_image);
            }
            if($user->profile->profile_image){
               Storage::disk('public')->delete($user->profile->profile_image);
            }
        }
        $user->delete();
        return response()->json([
            'message'=>"User {$user->id} has been deleted successfully",
        ],200);
       
    }
}
