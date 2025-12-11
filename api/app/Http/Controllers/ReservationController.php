<?php

namespace App\Http\Controllers;

use App\Http\Requests\FilterReservationRequest;
use App\Http\Requests\ReservationRequest;
use App\Models\Post;
use App\Models\Profile;
use App\Models\Reservation;
use Illuminate\Database\Eloquent\Relations\Relation;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use carbon\carbon;
use Illuminate\Support\Facades\Gate;

class ReservationController extends Controller
{

    public function makeReservation(ReservationRequest $request, $post_id){
    $user_id=Auth::user()->id;
    $validatedData=$request->validated();
    $validatedData['post_id']=$post_id;
    $validatedData['user_id']=$user_id;
    $validatedData['status']='Pending';
    $post=Post::query()->find($post_id);


        $response=Gate::inspect('reserve',$post);

        if($response->allowed()) {

            $noConflict = $this->checkAvailability($request, $post_id);
            /*   if($this->canReserve($user_id,$post_id)){
                   return response()->json([
                       'message'=>'you cannot perform a reservation on your own property'
                   ],403);
               }*/
            if (!$noConflict) {
                return response()->json(['message' => 'Consider choosing another time'], 409,);
            }

            DB::beginTransaction();
            try {

                $reservation = Reservation::query()->create($validatedData);

                DB::commit();

                return response()->json([
                    'message' => 'Your reservation has been made successfully , waiting for approval',
                ], 201);

            } catch (\Exception $e) {
                DB::rollBack();

                return response()->json([
                    'message' => 'something went wrong during reservation,try again '
                ], 500);
            }
        }else{
            $message=$response->message();
            return response()->json(['message'=>$message],403);
        }
    }

    private function canReserve($user_id,$post_id){
        //
    }

private function checkAvailability(Request $request,$postId){

        $newCheckIn=$request->input('check_in');
        $newCheckOut=$request->input('check_out');

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
        $reservations = Reservation::query()
            ->where('user_id', $user_id);

        if ($request->filled('Current')) {
            $reservations =$reservations
                ->whereIn('status', ['Pending', 'Accepted'])
                ->latest()
                ->paginate(10);
        }

        if ($request->filled('Previous')) {
            $reservations = $reservations
                ->where('status', '=', 'Completed')
                ->latest()
                ->paginate(10);
        }

        if($request->filled('Canceled')){
                $reservations=$reservations
                ->where('status', '=', 'Canceled')
                ->latest()
                ->paginate(10);
        }

        if ($reservations instanceof Builder || $reservations instanceof Relation) {
            $reservations = $reservations
              ->whereIn('status', ['Pending', 'Accepted'])
              ->latest()
              ->paginate(10);
        }
        if(is_null($reservations['data']) && $request->filled('Current')){
            return response()->json(['message'=>'No Current reservations found'],404);
        }
        if(is_null($reservations['data']) && $request->filled('Previous')){
            return response()->json(['message'=>'No Previous reservations found'],404);
        }
        if(is_null($reservations['data']) && $request->filled('Canceled')){
            return response()->json(['message'=>'No Canceled reservations found'],404);
        }

        return response()->json($reservations, 200);
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
