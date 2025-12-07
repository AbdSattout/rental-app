<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{

    public function up(): void
    {
        Schema::create('bookings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('post_id')->constrained('posts')->onDelete('cascade');
            $table->date('check_in');
            $table->date('check_out');
            $table->enum('status',['Accepted','Pending','Rejected','Canceled'])->default('Pending');
            $table->unique(['user_id', 'post_id', 'check_in', 'check_out']);
            $table->date('request_check_in')->nullable()->after('check_out');
            $table->date('request_check_out')->nullable()->after('request_check_in');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('bookings');
    }
};
