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
use Mockery\Exception;
use App\Services\FcmService;

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

    if(!$response->allowed()){
            $message=$response->message();
            return response()->json(['message'=>$message],403);
        }




            DB::beginTransaction();
            try {

                $resourceToLock = Post::query()->where('id', $post_id)->lockForUpdate()->first();

                if(!$resourceToLock){
                throw new Exception('Resource not found');
                }

                $noConflict = $this->checkAvailability($request, $post_id);

                if (!$noConflict) {
                    throw new Exception('Consider choosing another time');
                }


                $reservation = Reservation::query()->create($validatedData);
               
                DB::commit();

                 $host = $post->profile->user;
                if($host && $host->fcm_token){
                    FcmService::sendNotification(
                        $host->fcm_token,
                        'New Reservation Request',
                        'You have a new reservation request for your post: ' . $post->title,
                        [
                            'reservation_id' => $reservation->id,
                            'post_id' => $post->id,
                            'type' => 'new_reservation'
                        ]
                    );
                }


                return response()->json([
                    'message' => 'Your reservation has been done successfully',
                    'check_in'=>$reservation['check_in'],
                    'check_out'=>$reservation['check_out'],
                ], 201);

            } catch (\Exception $e) {
                DB::rollBack();

                $message = $e->getMessage();
                $statusCode = 500;

                if ($message === 'Consider choosing another time') {
                    $statusCode = 409;
                }

                if ($statusCode === 500) {
                    $message = 'A critical error occurred during reservation. Please try again.';
                }

                return response()->json([
                    'message' => $message
                ], $statusCode);
            }
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
//        $user_id = Auth::user()->id;
//        $reservations = Reservation::query()
//            ->where('user_id', $user_id);
//
//        if ($request->filled('Current')) {
//            $reservations =$reservations
//                ->whereIn('status', ['Pending', 'Accepted'])
//                ->latest()
//                ->paginate(10);
//        }
//
//        if ($request->filled('Previous')) {
//            $reservations = $reservations
//                ->where('status', '=', 'Completed')
//                ->latest()
//                ->paginate(10);
//        }
//
//        if($request->filled('Canceled')){
//                $reservations=$reservations
//                ->where('status', '=', 'Canceled')
//                ->latest()
//                ->paginate(10);
//        }
//
//        if ($reservations instanceof Builder || $reservations instanceof Relation) {
//            $reservations = $reservations
//              ->whereIn('status', ['Pending', 'Accepted'])
//              ->latest()
//              ->paginate(10);
//        }
//        if(is_null($reservations['data']) && $request->filled('Current')){
//            return response()->json(['message'=>'No Current reservations found'],404);
//        }
//        if(is_null($reservations['data']) && $request->filled('Previous')){
//            return response()->json(['message'=>'No Previous reservations found'],404);
//        }
//        if(is_null($reservations['data']) && $request->filled('Canceled')){
//            return response()->json(['message'=>'No Canceled reservations found'],404);
//        }
//
//        return response()->json($reservations, 200);



        $user_id = Auth::user()->id;


        $reservationsQuery = Reservation::query()->where('user_id', $user_id);


        $targetStatuses = [];
        $filterApplied = false;


        $requestKeys = array_map('strtolower', array_keys($request->query()));
        $hasCurrent = in_array('current', $requestKeys);
        $hasPrevious = in_array('previous', $requestKeys);
        $hasCanceled = in_array('canceled', $requestKeys);


        if ($hasCurrent) {
            $targetStatuses = array_merge($targetStatuses, ['Pending', 'Accepted']);
            $filterApplied = true;
        }

        if ($hasPrevious) {
            $targetStatuses[] = 'Completed';
            $filterApplied = true;
        }

        if ($hasCanceled) {
            $targetStatuses[] = 'Canceled';
            $filterApplied = true;
        }

        if ($filterApplied) {

            $targetStatuses = array_unique($targetStatuses);
            $reservationsQuery->whereIn('status', $targetStatuses);

        } else {

            $reservationsQuery->whereIn('status', ['Pending', 'Accepted']);
            $targetStatuses = ['Pending', 'Accepted'];
        }

        $reservations = $reservationsQuery->latest()->paginate(10);

        if ($reservations->isEmpty()) {
            $statusList = array_map('ucfirst', $targetStatuses);
            $statusString = count($statusList) > 1
                ? implode(', ', array_slice($statusList, 0, -1)) . ' and ' . end($statusList)
                : reset($statusList);

            return response()->json([
                'message' => "No reservations found matching the status(es): {$statusString}"
            ], 404);
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
        $host=$reservation->post?->profile?->user ;
        if($host && $host->fcm_token){
            FcmService::sendNotification(
                $host->fcm_token,
                'Reservation Canceled',
                'A reservation has been canceled for your post: ' . $reservation->post->title,
                [
                    'reservation_id' =>(string) $reservation->id,
                    'post_id' =>(string) $reservation->post->id,
                    'type' => 'reservation_canceled'
                ]
            );
        }

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
        $host=$reservation->post->profile->user ;
        if($host && $host->fcm_token){
            FcmService::sendNotification(
                $host->fcm_token,
                'Reservation Update Request',
                'A reservation update has been requested for your post: ' . $reservation->post->title,
                [
                    'reservation_id' =>(string) $reservation->id,
                    'post_id' =>(string) $reservation->post->id,
                    'type' => 'reservation_update'
                ]
            );
        }

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
