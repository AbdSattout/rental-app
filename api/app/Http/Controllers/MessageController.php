<?php

namespace App\Http\Controllers;

use App\Events\Message;
use Illuminate\Http\Request;

class MessageController extends Controller
{
    public function message(Request $request){

        event(new Message($request->input('first_name'),$request->input('message')));

        return  [];

    }
}
