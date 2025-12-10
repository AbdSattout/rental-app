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
    public function register(Request $request)
    {
        $request->validate([
            "phone_number" =>
                "required|string|max:10|min:10|unique:users,phone_number",
            "password" => "required|string|min:8|confirmed",
            // profile requirements
            "first_name" => "string|max:50",
            "last_name" => "string|max:50",
            "Date_Of_Birth" => "required|date",
            "ID_image" => "required|image|mimes:jpeg,png,jpg,gif,svg|max:5120",
            "profile_image" =>
                "required|image|mimes:jpeg,png,jpg,gif,svg|max:5120",
        ]);

        DB::beginTransaction();
        try {
            $id_image_path = $request->file("ID_image")->store("ID_images");
            $profile_image_path = $request
                ->file("profile_image")
                ->store("profile_images");

            $user = User::query()->create([
                "phone_number" => $request->phone_number,
                "password" => Hash::make($request->password),
                "role" => "guest",
            ]);

            Profile::query()->create([
                "user_id" => $user->id,
                "first_name" => $request->first_name,
                "last_name" => $request->last_name,
                "Date_Of_Birth" => $request->Date_Of_Birth,
                "ID_image" => $id_image_path,
                "profile_image" => $profile_image_path,
            ]);

            DB::commit();

            return response()->json(
                [
                    "message" =>
                        "Registeration completed, waiting for admin approval.",
                    "data" => $user,
                ],
                201,
            );
        } catch (\Exception $e) {
            DB::rollBack();
            if (isset($id_image_path)) {
                Storage::delete($id_image_path);
            }
            if (isset($profile_image_path)) {
                Storage::delete($profile_image_path);
                return response()->json(
                    ["message" => "Registeration failed." . $e->getMessage()],
                    500,
                );
            }
        }
    }
    public function login(Request $request)
    {
        $request->validate([
            "phone_number" => "required|string",
            "password" => "required|string|min:8",
        ]);
        if (!Auth::attempt($request->only("phone_number", "password"))) {
            return response()->json(
                ["message" => "invalid phone number or password"],
                401,
            );
        }
        $user = $request->user();
        if (!$user->is_approved) {
            Auth::logout();
            return response()->json(
                ["message" => "your account is not approved yet"],
                403,
            );
        }
        $user->tokens()->delete();
        $token = $user->createToken("auth_token")->plainTextToken;
        $profile = $user->profile;
        return response()->json(
            [
                "message" => "login successed",
                "user" => [
                    "phone_number" => $user->phone_number,
                    "role" => $user->role,
                    "requesting_host" => $user->requesting_host,
                    "first_name" => $profile->first_name,
                    "last_name" => $profile->last_name,
                    "Date_Of_Birth" => $profile->Date_Of_Birth,
                    "profile_image" => $profile->profile_image,
                ],
                "token" => $token,
            ],
            200,
        );
    }
    public function logout(Request $request){
       $request->user()->currentAccessToken()->delete();
       return response()->json([
        'message'=>'user deleted successfully',
       ],200);
    }
    public function beHost()
    {
        $user = Auth::user();

        if($user->role !== 'tenant'){
            return response()->json([
                'message'=>'only tenants can request to be hosts',

            ],403);
        }
        if($user->requesting_host){
            return response()->json([
                'message'=>'you have already requested to be a host. waiting for admin approval',
            ],409);
        }
        $user->requesting_host = true;
        $user->save();
        return response()->json(
            [
                "message" =>
                    "host request sent successfully. waiting for admin approval",
            ],
            200,
        );
    }

}
