<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\User;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    public function index(){
        $statistics = [ 
            'total_users'=>User::count(),
            'total_orders'=>Order::count(),
            'pending_orders'=>Order::where('status' , 'pending')->count(),
            'approved_orders'=>Order::where('status' , 'approved')->count(),
            'rejected_orders'=>Order::where('status' , 'rejected')->count(),
        ];
        return response()->json(['message'=>'admin dashboard statistics',
        'data'=>$statistics
        ],200);
    }
}
