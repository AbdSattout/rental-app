<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;    
use App\Models\Order;     

class OrderController extends Controller
{
    public function index(){
        $orders = Order::all();
        return response()->json(['data'=>$orders],200);
    }
    public function approve(Order $order){
        if($order->status !== 'pending'){
            return response()->json(['message'=>'only pending orders can be approved'],400);
        }
        $order->status = 'approved';
        $order->save();
        return response()->json(['message'=>'order approved successfully'],200);
    }
    public function reject(Order $order){
        if($order->status !== 'pending'){
            return response()->json(['message'=>'only pending orders can be rejected'],400);
        }
        $order->status = 'rejected';
        $order->save();
        return response()->json(['message'=>'order rejected successfully'],200);
    }
}
