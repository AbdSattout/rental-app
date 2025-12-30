<?php

namespace App\Http\Controllers;

use App\Models\Post;
use App\Models\Reservation;
use App\Services\FcmService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class HostController extends Controller
{
    public function PendingReservationRequests(){
        $host_id = Auth::user()->id;
        $profileId = Auth::user()->profile?->id;
        if(!$profileId){
            return response()->json([
                'message'=>'Host profile not found'
            ] , 404);
        }
        $hostPostID = Post::where('profile_id' , $profileId)->pluck('id');
        if($hostPostID->isEmpty()){
            return response()->json([
                'message'=>'No posts found for this host'
            ] , 404);
        }

        $pendingReservations = Reservation::whereIn('post_id' , $hostPostID)
        ->where('status' , 'Pending')
        ->whereNull('request_check_in')
        ->with('user' , 'post')
        ->get();

        return response()->json($pendingReservations , 200);
    }

    public function approveReservation($reservationId){
        $host_id = Auth::user()->id;
        $reservation = Reservation::where('id' , $reservationId)
        ->where('status' , 'Pending')
        ->whereNull('request_check_in')
        ->whereHas('post' , function($query) use ($host_id){
            $query->whereHas('profile' , function($query) use ($host_id){
                $query->where('user_id' , $host_id);
            });
        })->first();
        if(!$reservation){
            return response()->json([
                'message'=>'Reservation not found or you are not authorized to approve this reservation'
            ] , 404);
        }
        $reservation->status = 'Accepted';
        $reservation->save();
        $tenant = $reservation->user;
        if($tenant && $tenant->fcm_token){
            FcmService::sendNotification(
                $tenant->fcm_token,
                'Reservation Approved',
                "Your reservation for post ID {$reservation->post_id} has been approved.",
                ['reservation_id' => $reservation->id]
            );
        }

        return response()->json([
            'message' => 'Reservation approved successfully',
            'reservation' => $reservation
        ], 200);
    }

    public function rejectReservation($reservationId){
        $host_id = Auth::user()->id;
         $reservation = Reservation::where('id' , $reservationId)
        ->where('status' , 'Pending')
        ->whereNull('request_check_in')
        ->whereHas('post' , function($query) use ($host_id){
            $query->whereHas('profile' , function($query) use ($host_id){
                $query->where('user_id' , $host_id);
            });
        })->first();
        if(!$reservation){
            return response()->json([
                'message'=>'Reservation not found or you are not authorized to reject this reservation'
            ] , 404);
        }
        $reservation->status = 'Rejected';
        $reservation->save();
        $tenant = $reservation->user;
        if($tenant && $tenant->fcm_token){
            FcmService::sendNotification(
                $tenant->fcm_token,
                'Reservation Rejected',
                "Your reservation for post ID {$reservation->post_id} has been rejected.",
                ['reservation_id' => $reservation->id]
            );
        }

        return response()->json([
            'message' => 'Reservation rejected successfully',
            'reservation' => $reservation
        ], 200);
    }

    public function pendingReservationUpdates(){
        $host_id = Auth::user()->id;
        $hostPostID = Auth::user()->posts()->pluck('id');

        $pendingReservations = Reservation::whereIn('post_id' , $hostPostID)
        ->where('status' , 'Pending')
        ->whereNotNull('request_check_in')
        ->with('user' , 'post')
        ->get();

        return response()->json($pendingReservations , 200);

    }
    public function approveReservationUpdate($reservationId){
        $host_id = Auth::user()->id;
        $reservation = Reservation::where('id' , $reservationId)
        ->whereIn('status' ,[ 'Pending','Accepted'])
        ->whereNotNull('request_check_in')->first();
        if(!$reservation){
            return response()->json([
                'message'=>'Reservation not found or you are not authorized to approve this update'
            ] , 404);
        }
        $reservation->check_in = $reservation->request_check_in;
        $reservation->check_out = $reservation->request_check_out;
        $reservation->status = 'Accepted';
        $reservation->request_check_in = null;
        $reservation->request_check_out = null;
        $reservation->save();
        $tenant = $reservation->user;
        if($tenant && $tenant->fcm_token){
            FcmService::sendNotification(
                $tenant->fcm_token,
                'Reservation Update Approved',
                "Your reservation update for post ID {$reservation->post_id} has been approved.",
                ['reservation_id' => $reservation->id]
            );
        }

        return response()->json([
            'message' => 'Reservation update approved successfully',
            'reservation' => $reservation
        ], 200);
    }

    public function rejectReservationUpdate($reservationId){
        $host_id = Auth::user()->id;
        $reservation = Reservation::where('id' , $reservationId)
        ->where('status' , 'Pending')
        ->whereNotNull('request_check_in')
        ->first();
        if(!$reservation){
            return response()->json([
                'message'=>'Reservation not found or you are not authorized to reject this update'
            ] , 404);
        }
        $reservation->request_check_in = null;
        $reservation->request_check_out = null;
        $reservation->status = 'Rejected';
        $reservation->save();

        $tenant = $reservation->user;
        if($tenant && $tenant->fcm_token){
            FcmService::sendNotification(
                $tenant->fcm_token,
                'Reservation Update Rejected',
                "Your reservation update for post ID {$reservation->post_id} has been rejected.",
                ['reservation_id' => $reservation->id]
            );
        }

        return response()->json([
            'message' => 'Reservation update rejected successfully',
            'reservation' => $reservation
        ], 200);
    }

}
