<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use App\Models\Profile;

class UserController extends Controller
{
    public function register(Request $request){
       $request->validate([
        'phone_number'=>'required|string|max:10',
        'password'=>'required|string|min:8|confirmed',
         'role'=>'in:tenant,host,guest',
         //-----------------------rpofile requirements
         'first_name'=>'string|max:50',
         'last_name'=>'string|max:50',
         'Date_Of_Birth'=>'required|date',
         'ID_image'=>'image|mimes:jpeg,png,jpg,gif,svg|max:5120',
         'profile_image'=>'image|mimes:jpeg,png,jpg,gif,svg|max:5120',

       ]);

         DB::beginTransaction();
         try{

             $id_image_path = $request->file('ID_image')->store('ID_images' , 'public');
             $profile_image_path = $request->file('profile_image')->store('profile_images' , 'public');

                $user = User::query()->create([
                'phone_number'=>$request->phone_number,

                'password'=>Hash::make($request->password),
                    'role'=>$request->role ?? 'tenant',
                ]);

                Profile::query()->create([
                    'user_id'=>$user->id,
                    'first_name'=>$request->first_name,
                    'last_name'=>$request->last_name,
                    'Date_Of_Birth'=>$request->Date_Of_Birth,
                    'ID_image'=>$id_image_path,
                    'profile_image'=>$profile_image_path,
                ]);

                DB::commit();

                   return response()->json([
                       'message'=>'Registeration completed. user and profile
                        created. Waiting for admin approval',
                        'data'=>$user ,
                        'status'=>201
                        ]);
         }

            catch(\Exception $e){
                DB::rollBack();
                if(isset($id_image_path)){
                    Storage::disk('public')->delete($id_image_path);
                }
                if(isset($profile_image_path)){
                    Storage::disk('public')->delete($profile_image_path);
                return response()->json([
                    'message'=>'Registeration failed.'.$e->getMessage(),
                    'status'=>500
                ]);
            }
        }
    }
    public function login(Request $request){
        $request->validate([
              'phone_number'=>'string',
        'password'=>'string|'
        ]);
        if(!Auth::attempt($request->only('phone_number' , 'password')))
            return response()->json(['message'=>'invalid phone number or password']);
        $user = User::where('phone_number' , $request->phone_number)->FirstOrFail();
        if(!$user->is_approved){
            Auth::logout();            return response()->json(['message'=>'your account is not approved yet'],403);
        }
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
