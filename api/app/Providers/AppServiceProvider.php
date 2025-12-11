<?php

namespace App\Providers;

use App\Http\Middleware\CheckAdmin;
use App\Http\Middleware\CheckHost;
use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\Route;
use \App\Http\Middleware\CheckUserApproval;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Route::aliasMiddleware('admin',CheckAdmin::class);
        Route::aliasMiddleware('check_approval', CheckUserApproval::class);
        Route::aliasMiddleware('host', CheckHost::class);
    }
}
