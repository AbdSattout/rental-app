<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;

class UserController extends Controller
{
    public function register(Request $request){
       $request->validate([
        'phone_number'=>'required|string|max:10',
        'password'=>'required|string|min:8|confirmed',
           'be_host'=>'nullable|boolean'
       ]);
       $user = User::query()->create([
        'phone_number'=>$request->phone_number,

        'password'=>Hash::make($request->password),
           'be_host'=> $request->be_host ? true : false,
       ]);
       $token = $user->createToken('auth_token')->plainTextToken;
       return response()->json([
        'message'=>'user register successfully',
        'data'=>$user ,
        'token'=>$token,
        'status'=>201
       ]);
    }
    public function login(Request $request){
        $request->validate([
              'phone_number'=>'string',
        'password'=>'string|'
        ]);
        if(!Auth::attempt($request->only('phone_number' , 'password')))
            return response()->json(['message'=>'invalid phone number or password']);
        $user = User::where('phone_number' , $request->phone_number)->FirstOrFail();
        $user->tokens()->delete();
        $token = $user->createToken('auth_token')->plainTextToken;
        return response()->json([
        'message'=>'login successed' ,
      'user'=>$user ,
      'token'=>$token] ,200);

    }
    public function logout(Request $request){
       $request->user()->currentAccessToken()->delete();
       return response()->json([
        'message'=>'user deleted successfully',
        'status'=>200
       ]);
    }
}
