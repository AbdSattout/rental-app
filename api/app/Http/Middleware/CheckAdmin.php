<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Symfony\Component\HttpFoundation\Response;

class CheckAdmin
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        if(!Auth::check() ){
            return response()->json(['message'=>'unauthenticated'],401);
        }
        if(Auth::user()->role !== 'admin'){
            return response()->json(['message'=>'forbidden . you do not have admin access'],403);
        }
    
        return $next($request);
        
    }
}
