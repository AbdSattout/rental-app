<?php

namespace App\Policies;

use App\Models\Rating;
use App\Models\Reservation;
use App\Models\User;
use App\Models\Post;
use Illuminate\Auth\Access\Response;

class RatingPolicy
{
    /**
     * Determine whether the user can view any models.
     */
    public function viewAny(User $user): bool
    {
        return false;
    }

    /**
     * Determine whether the user can view the model.
     */
    public function view(User $user, Rating $rating): bool
    {
        return true;
    }

    /**
     * Determine whether the user can create models.
     */
    public function create(User $user, Post $post): Response
    {

        $hasCompletedReservation = Reservation::where('user_id', $user->id)
       ->where('post_id', $post->id)
            ->whereNotIn('status','Rejected')
            ->count();
        return $hasCompletedReservation>0
            ? Response::allow()
            : Response::deny('You cannot rate this post until you reserve it at least once'); // ;
    }

    /**
     * Determine whether the user can update the model.
     */
    public function update(User $user, Rating $rating): bool
    {
        return false;
    }

    /**
     * Determine whether the user can delete the model.
     */
    public function delete(User $user, Rating $rating): bool
    {
        return false;
    }

    /**
     * Determine whether the user can restore the model.
     */
    public function restore(User $user, Rating $rating): bool
    {
        return false;
    }

    /**
     * Determine whether the user can permanently delete the model.
     */
    public function forceDelete(User $user, Rating $rating): bool
    {
        return false;
    }
}
