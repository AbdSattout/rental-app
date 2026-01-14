<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Support\Facades\Storage;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Services\FcmService;

class AdminController extends Controller
{
    public function pending(){
        $pendingUsers = User::with('profile')
            ->where('is_approved' , false)
            ->where('role' , '!=','admin')
            ->get();

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
        if ($user->is_approved) {
            return response()->json(
                [
                    "message" => "user is already approved",
                ],
                400,
            );
        }
        if ($user->requesting_host) {
            return response()->json(
                [
                    "message" =>
                        "user has requested to be a host and cannot be approved as a tenant",
                ],
                400,
            );
        }
        $user->is_approved = true;
        $user->save();
        if ($user->role === "guest") {
            $user->role = "tenant";
            $user->save();
        }
        if($user->fcm_token){
            FcmService::sendNotification(
                $user->fcm_token,
                'Account Approved',
                "Your account has been approved. You can now access all features.",
                ['type' => 'account_approval']
            );
        }
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
        if ($user->profile) {
            if ($user->profile->ID_image) {
                Storage::delete($user->profile->ID_image);
            }
            if ($user->profile->profile_image) {
                Storage::delete($user->profile->profile_image);
            }
        }
        $user->delete();
        return response()->json([
            'message'=>"User {$user->id} has been deleted successfully",
        ],200);

    }
    public function hostRequests()
    {
        $hostRequests = User::with('profile')->where("requesting_host", true)->get();
        return response()->json(
            [
                "message" => "host requests retrieved successfully",
                "users" => $hostRequests,
            ],
            200,
        );
    }
    public function approveHost(User $user){
        if($user->role !== 'tenant' || !$user->requesting_host){
            return response()->json([
                'message'=>'user has not requested to be a host or is not a tenant',
                ] , 403);
}
        $user->role = 'host';
        $user->requesting_host = false;
        $user->is_approved = true;
        $user->save();
        if($user->fcm_token){
            FcmService::sendNotification(
                $user->fcm_token,
                'Host Request Approved',
                "Your request to become a host has been approved.",
                ['type' => 'host_approval']
            );
        }
        return response()->json(
            [
                "message" => "User {$user->id} has been approved as a host successfully",
                "user" => $user,
            ],
            200,
        );
    }
     public function rejectHost(User $user){
        if($user->role !== 'tenant' || !$user->requesting_host){
            return response()->json([
                'message'=>'user has not requested to be a host or is not a tenant',
                ] , 403);
}
        $user->requesting_host = false;
        $user->save();

        if($user->fcm_token){
            FcmService::sendNotification(
                $user->fcm_token,
                'Host Request Rejected',
                "Your request to become a host has been rejected.",
                ['type' => 'host_rejection']
            );
        }
        return response()->json(
            [
                "message" => "User {$user->id} host request has been rejected successfully",
                "user" => $user,
            ],
            200,
        );
    }

    public function getTenants(){
        $users = User::with('profile')->whereNotIn('role',  ['guest','admin','host'])->get();
        return response()->json([
            'users'=>$users,
        ],200);
    }

    public function getHosts(){
        $users = User::with('profile')->whereNotIn('role',  ['guest','admin','tenant'])->get();
        return response()->json([
            'users'=>$users,
        ],200);
    }

    public function removeUser(User $user){
        $user->delete();
        return response()->json([
            'message'=>'removed user successfully',
        ],200);
    }
}
