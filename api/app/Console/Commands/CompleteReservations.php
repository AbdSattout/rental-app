<?php

namespace App\Console\Commands;

use App\Models\Reservation;
use Carbon\Carbon;
use Illuminate\Console\Command;

class CompleteReservations extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'reservations:complete';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Update the Accepted Reservations to Completed when their checkout time has expired';

    /**
     * Execute the console command.
     */
    public function handle()
    {

        $current = Carbon::now();
        $updateReservation=Reservation::query()
            ->where('status','Accepted')
            ->whereDate('check_out','<',$current->toDateString())
            ->update(['status'=>'Completed','updated_at'=>$current]);


        return 0;

    }
}
