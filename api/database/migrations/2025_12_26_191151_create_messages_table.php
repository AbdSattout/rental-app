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
        Schema::create('messages', function (Blueprint $table) {
            $table->id();
            $table->foreignId('conversation_id')->constrained()->cascadeOnDelete();
            $table->foreignId('sender_id')->constrained('users')->cascadeOnDelete();

            $table->text('body')->nullable();
            $table->string('type')->default('text');
            $table->string('attachment_path')->nullable();
            $table->timestamps();


            $table->index(['conversation_id', 'created_at']);
        });

        Schema::table('conversation_user', function (Blueprint $table) {
            $table->foreign('last_read_message_id')
                ->references('id')
                ->on('messages')
                ->onDelete('set null');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('conversation_user', function (Blueprint $table) {
            $table->dropForeign(['last_read_message_id']);
        });
        Schema::dropIfExists('messages');
    }
};
