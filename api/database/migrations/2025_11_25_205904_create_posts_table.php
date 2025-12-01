<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('posts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('profile_id')->constrained('profiles')->onDelete('cascade');
            $table->enum('type',['House','Apartment','Villa','Office'])->default('House');
            $table->double('space');
            $table->integer('rooms');
            $table->decimal('price', 10, 2);
            $table->Decimal('latitude',10,8);
            $table->Decimal('longitude',11,8);
            $table->boolean("availability")->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('posts');
    }
};
