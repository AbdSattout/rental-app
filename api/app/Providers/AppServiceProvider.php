<?php

namespace App\Providers;

use App\Http\Middleware\CheckAdmin;
use Illuminate\Console\Scheduling\Schedule;
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


        if ($this->app->runningInConsole()) {

            // This closure runs immediately after the service providers have finished booting.
            $this->app->booted(function () {

                // Manually resolve the Schedule instance
                $schedule = $this->app->make(Schedule::class);

                // Manually register the command
                $schedule->command('reservations:complete')->everyMinute();
            });
        }

        Route::aliasMiddleware('admin', CheckAdmin::class);
        Route::aliasMiddleware('check_approval', CheckUserApproval::class);
    }
}
