<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;

class AdminController extends Controller
{
    public function pending(){
        $pendingUsers = User::where('is_approved' , false)->where('role' , '!=','admin')->get();
        return response()->json([
            'message'=>'pending users retrieved successfully',
            'users'=>$pendingUsers,
            'status'=>200
        ]);
    }
    public function approve(User $user){
        if($user->role === 'admin'){
        
            return response()->json([
                'message'=>'cannot approve admin user',
                'status'=>403]);
        }
        $user->is_approved = true;
        $user->save();
        return response()->json([
            'message'=>"User {$user->id} approved successfully",
            'user'=>$user,
        ],200);
       
    }
    public function reject(User $user){
        if($user->role === 'admin'){
        
            return response()->json([
                'message'=>'cannot reject admin user',
                'status'=>403]);
        }
        $user->delete();
        return response()->json([
            'message'=>"User {$user->id} rejected and deleted successfully",
        ],200);
       
    }
}
