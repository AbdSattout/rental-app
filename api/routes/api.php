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

Route::post('/posts' , [PostController::class , 'store'])->middleware(['auth:sanctum','CanPost']);

Route::get('/homepage' , [PostController::class , 'getHomepageFeed']);

Route::get('/details/{id}' , [PostController::class , 'getPostDetails']);

Route::post('/updatepost/{id}' , [PostController::class , 'Update'])->middleware(['auth:sanctum','CanPost']);

Route::delete('/deletepost/{id}' , [PostController::class , 'deletePost'])->middleware(['auth:sanctum','CanPost']);

Route::get('/filter' , [PostController::class , 'filterPosts']);

Route::get('/userposts/{id}' , [PostController::class , 'getUsersPosts']);

Route::get('/ownposts' , [PostController::class , 'getOwnPosts'])->middleware(['auth:sanctum','CanPost']);
