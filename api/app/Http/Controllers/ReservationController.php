<?php

namespace App\Http\Controllers;

use App\Http\Requests\FilterReservationRequest;
use App\Http\Requests\ReservationRequest;
use App\Models\Reservation;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use carbon\carbon;
class ReservationController extends Controller
{

    public function makeReservation(ReservationRequest $request, $postId){
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
    $query = Reservation::query();
    if ($request->filled('Current')) {
        $query = $query
            ->where('user_id', $user_id)
            ->whereIn('status', '=', ['Pending', 'Accepted'])
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


}
