<?php

namespace App\Http\Controllers;

use App\Http\Requests\FilterReservationRequest;
use App\Models\Reservation;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;

class ReservationController extends Controller
{

    public function makeReservation(Request $request, $postId){
    $user_id=Auth::user()->id;
    $validatedData=$request->validated();
    $validatedData['post_id']=$postId;
    $validatedData['user_id']=$user_id;

    $noConflict=$this->checkAvailability($request,$postId);

    if(!$noConflict){
        return response()->json(['message'=>'Consider choosing another time'],409,);
    }

    DB::beginTransaction();
    try{

        $reservation=Reservation::query()->create($validatedData);

            DB::commit();

            return response()->json([
            'message'=>'Your reservation has been done successfully'
        ],201);

    }catch (\Exception $e){
        DB::rollBack();

    return response()->json([
        'message'=>'something went wrong during reservation,try again '
    ],500);
    }
    }

private function checkAvailability(Request $request,$postId){

        $newCheckIn=$request->input('checkIn');
        $newCheckOut=$request->input('checkOut');

        $conflict=Reservation::query()
            ->where('post_id',$postId)
            ->whereNotIn('status',['Cancelled','Rejected','Completed'])
            ->where('check_in','<=',$newCheckOut)
            ->where('check_out','>=',$newCheckIn)
            ->count();

        return $conflict === 0;
}

public function myReservations(FilterReservationRequest $request)
{
    $user_id = Auth::user()->id;
    $query = Reservation::query();
    if ($request->filled('Current')) {
        $query = $query
            ->where('user_id', $user_id)
            ->where('status', '=', ['Pending', 'Accepted'])
            ->latest()
            ->paginate(10);
    }

    if ($request->filled('Previous')) {
        $query = $query
            ->where('user_id', $user_id)
            ->where('status', '=', 'Completed')
            ->latest()
            ->paginate(10);
    }

    if($request->filled('Canceled')){
        $query = $query
            ->where('user_id', $user_id)
            ->where('status', '=', 'Canceled')
            ->latest()
            ->paginate(10);

    }

    return response()->json([$query],200);
}

       public function cancelReservation(Request $request,$reservationId){
        $user_id=Auth::user()->id;

        $reservation=Reservation::query()
            ->where('id',$reservationId)
            ->where('user_id',$user_id)
            ->first();

        if(!$reservation){
            return response()->json([
                'message'=>'Reservation not found'
            ],404);
        }
            $cancelingStatuses=['Pending','Accepted'];
        if(!in_array($reservation->status,$cancelingStatuses)){
            return response()->json([
                'message'=>'You cannot cancel this reservation due to its current status' ,
                'reservation_status'=>$reservation->status
            ],403);
           
        }

        $reservation->status='Canceled';
        $reservation->save();

        return response()->json([
            'message'=>'Reservation canceled successfully' ,
            'reservation_status'=>$reservation->status
        ],200);
       }
      
       public function updateReservation(Request $request,$reservationId){
        $user_id=Auth::user()->id;

        $reservation=Reservation::query()
            ->where('id',$reservationId)
            ->where('user_id',$user_id)
            ->first();

        if(!$reservation){
            return response()->json([
                'message'=>'Reservation not found'
            ],404);
        }

        $updatingStatuses=['Pending','Accepted'];
        if(!in_array($reservation->status,$updatingStatuses)){
            return response()->json([
                'message'=>'You cannot update this reservation due to its current status' ,
                'reservation_status'=>$reservation->status
            ],403);
           
        }
           $request->validate([
            'checkIn'=>'required|date|after_or_equal:today',
            'checkOut'=>'required|date|after:checkIn',
           ]);

           $newCheckIn=$request->input('checkIn');
           $newCheckOut=$request->input('checkOut');
           
        $noConflict=$this->checkUpdateAvailability($newCheckIn,$newCheckOut,$reservation->post_id,$reservationId);

        if(!$noConflict){
            return response()->json(['message'=>'Consider choosing another time'],409,);
        }

        $reservation->request_check_in=$newCheckIn;
        $reservation->request_check_out=$newCheckOut;
        $reservation->status='Pending';
        $reservation->save();

        return response()->json([
            'message'=>'Reservation updated successfully . Waiting for approval' ,
        ],200);
       }
         private function checkUpdateAvailability($newCheckIn,$newCheckOut,$postId,$reservationId){
    
          $conflict=Reservation::query()
                ->where('post_id',$postId)
                ->where('id','!=',$reservationId)
                ->whereNotIn('status',['Cancelled','Rejected','Completed'])
                ->where('check_in','<=',$newCheckOut)
                ->where('check_out','>=',$newCheckIn)
                ->count();
    
          return $conflict === 0;   
        }
}
