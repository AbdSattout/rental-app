<?php

use App\Http\Controllers\ConversationController;
use App\Http\Controllers\FavoriteController;
use App\Http\Controllers\MessageController;
use App\Http\Controllers\ReservationController;
use App\Http\Controllers\PostController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\UserController;
use App\Http\Controllers\HostController;
use App\Http\Controllers\RatingController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\OrderController;
use App\Http\Controllers\Admin\AdminController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Broadcast;
use Illuminate\Support\Facades\Route;



Route::middleware(['auth:sanctum'])->group(function(){
Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

Route::delete('/logout' , [UserController::class , 'logout'])->middleware('auth:sanctum');

Route::post('posts/{post}/rate' , [RatingController::class , 'StoreRating'])->middleware('auth:sanctum');

});
Route::post('/register' , [UserController::class , 'register']);

Route::post('/login' , [UserController::class , 'login']);

Route::get('/homepage' , [PostController::class , 'getHomepageFeed']);

Route::get('/detailed/{id}/post' , [PostController::class , 'getPostDetails']);

Route::get('/posts/{post}/reviews' , [RatingController::class , 'GetPostRatings']);

Route::middleware(['auth:sanctum','check_approval'])->group(function(){

Route::post('profile' , [ProfileController::class , 'update'])->middleware('auth:sanctum');

Route::post('/posts' , [PostController::class , 'store'])->middleware(['auth:sanctum','CanPost']);

Route::post('/update/{id}/post' , [PostController::class , 'Update'])->middleware(['auth:sanctum','CanPost']);

Route::delete('/delete/{id}/post' , [PostController::class , 'deletePost'])->middleware(['auth:sanctum','CanPost']);

Route::post('/user/beHost' , [UserController::class , 'beHost'])->middleware('auth:sanctum');

Route::put('reservation/{reservationId}/updateRequest' , [ReservationController::class , 'requestReservationUpdate'])->middleware('auth:sanctum');

Route::put('reservation/{reservationId}/cancel' , [ReservationController::class , 'cancelReservation'])->middleware('auth:sanctum');

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

    Route::get('/hostRequests' , [AdminController::class , 'hostRequests']);

    Route::put('users/{user}/approveHost' , [AdminController::class , 'approveHost']);

    Route::put('users/{user}/rejectHost' , [AdminController::class , 'rejectHost']);


});
Route::get('/filter' , [PostController::class , 'filterPosts']);

Route::get('/user/{id}/posts' , [PostController::class , 'getUsersPosts']);

Route::get('/user/posts' , [PostController::class , 'getOwnPosts'])->middleware(['auth:sanctum','CanPost']);

Route::post('/post/{id}/reserve',[ReservationController::class,'makeReservation'])->middleware('auth:sanctum');

Route::get('/user/reservations',[ReservationController::class,'myReservations'])->middleware('auth:sanctum');


Route::middleware(['auth:sanctum','host'])->prefix('host')->group(function(){

    Route::get('/pending-reservation-requests' , [HostController::class , 'PendingReservationRequests']);

    Route::put('/reservation/{reservationId}/approve' , [HostController::class , 'approveReservation']);

    Route::put('/reservation/{reservationId}/reject' , [HostController::class , 'rejectReservation']);

    Route::get('/reservation/updates' , [HostController::class , 'pendingReservationUpdates']);

    Route::put('/reservation/{reservationId}/approveUpdate' , [HostController::class , 'approveReservationUpdate']);

    Route::put('/reservation/{reservationId}/rejectUpdate' , [HostController::class , 'rejectReservationUpdate']);
});

Route::get('/user/profile' , [ProfileController::class , 'getOwnProfile'])->middleware('auth:sanctum');

Route::get('/post/{id}/profile' , [ProfileController::class , 'getUserProfile']);

Route::get('/user/favorites' , [FavoriteController::class , 'showFavorites'])->middleware('auth:sanctum');

Route::post('/posts/{post}/favorites' , [FavoriteController::class , 'Toggle'])->middleware('auth:sanctum');


Broadcast::routes(['middleware' => ['auth:sanctum']]);


// Conversations routes
Route::get('/conversations', [ConversationController::class, 'index'])->middleware(['auth:sanctum']); // Get all conversations for the logged-in user
Route::post('/conversations', [ConversationController::class, 'store'])->middleware(['auth:sanctum']); // Start a new conversation (1:1 or group)
Route::get('/conversations/{conversation}', [ConversationController::class, 'show'])->middleware(['auth:sanctum']); // Get a specific conversation

// Messages routes for a specific conversation
Route::get('/conversations/{conversation}/messages', [MessageController::class, 'index'])->middleware(['auth:sanctum']); // Get all messages in a conversation
Route::post('/conversations/{conversation}/messages', [MessageController::class, 'store'])->middleware(['auth:sanctum']); // Send a new message in a conversation
Route::post('/conversations/{conversation}/read', [MessageController::class, 'markRead'])->middleware(['auth:sanctum']);
