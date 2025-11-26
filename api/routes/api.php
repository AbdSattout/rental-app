<?php

use App\Http\Controllers\PostController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\UserController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');
Route::post('register' , [UserController::class , 'register']);
Route::post('login' , [UserController::class , 'login']);
Route::delete('logout' , [UserController::class , 'logout'])->middleware('auth:sanctum');
Route::post('profile' , [ProfileController::class , 'store'])->middleware('auth:sanctum');

Route::post('/posts' , [PostController::class , 'store'])->middleware('auth:sanctum');
