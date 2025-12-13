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
            $table->enum('type',['house','apartment','villa','office'])->default('house');
            $table->double('space');
            $table->integer('rooms');
            $table->integer('bathrooms');
            $table->decimal('price', 10, 2);
            $table->decimal('latitude',10,8);
            $table->decimal('longitude',11,8);
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
