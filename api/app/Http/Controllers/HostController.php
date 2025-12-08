<?php

namespace App\Http\Controllers;


use App\Models\Reservation;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class HostController extends Controller
{
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
        ->where('status' , 'Pending')
        ->whereNotNull('request_check_in')
        ->whereHas('post' , function($query) use ($host_id){
            $query->where('user_id' , $host_id);
        })->first();
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

        return response()->json([
            'message' => 'Reservation update approved successfully',
            'reservation' => $reservation
        ], 200);
    }
    
}
