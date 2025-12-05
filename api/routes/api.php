<?php

use App\Http\Controllers\ReservationController;
use App\Http\Controllers\PostController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\UserController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\OrderController;
use App\Http\Controllers\Admin\AdminController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;



Route::middleware(['auth:sanctum'])->group(function(){
Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

Route::delete('/logout' , [UserController::class , 'logout'])->middleware('auth:sanctum');

});
Route::post('/register' , [UserController::class , 'register']);

Route::post('/login' , [UserController::class , 'login']);

Route::get('/homepage' , [PostController::class , 'getHomepageFeed']);

Route::get('/detailed/{id}/post' , [PostController::class , 'getPostDetails']);

Route::middleware(['auth:sanctum','check_approval'])->group(function(){

Route::post('profile' , [ProfileController::class , 'update'])->middleware('auth:sanctum');

Route::post('/posts' , [PostController::class , 'store'])->middleware(['auth:sanctum','CanPost']);

Route::post('/update/{id}/post' , [PostController::class , 'Update'])->middleware(['auth:sanctum','CanPost']);

Route::delete('/delete/{id}/post' , [PostController::class , 'deletePost'])->middleware(['auth:sanctum','CanPost']);

});

Route::middleware(['auth:sanctum','admin'])->prefix('admin')->group(function(){

  Route::get('/' , [DashboardController::class , 'index']);

  Route::get('/orders',[OrderController::class, 'index']);

  Route::put('/orders/{order}/approve',[OrderController::class, 'approve']);

  Route::patch('/orders/{order}/reject' ,[OrderController::class, 'reject']);

    Route::get('/users/pending' , [AdminController::class , 'pending']);

    Route::put('/users/{user}/approve', [AdminController::class, 'approve']);

    Route::delete('/users/{user}/reject', [AdminController::class, 'reject']);

    Route::delete('/users/{user}/ban', [AdminController::class, 'reject']);

});
Route::get('/filter' , [PostController::class , 'filterPosts']);

Route::get('/user/{id}/posts' , [PostController::class , 'getUsersPosts']);

Route::get('/user/posts' , [PostController::class , 'getOwnPosts'])->middleware(['auth:sanctum','CanPost']);

Route::post('/post/{id}/reserve',[ReservationController::class,'makeReservation'])->middleware('auth:sanctum');

Route::post('/user/reservations',[ReservationController::class,'myReservations'])->middleware('auth:sanctum');
