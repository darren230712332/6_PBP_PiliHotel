<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('rooms', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('hotel_id')->constrained()->cascadeOnDelete();
            $table->string('name');
            $table->unsignedTinyInteger('capacity')->default(2);
            $table->unsignedTinyInteger('bed_count')->default(1);
            $table->unsignedTinyInteger('bathroom_count')->default(1);
            $table->unsignedInteger('price_per_night');
            $table->text('description')->nullable();
            $table->json('facilities')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('rooms');
    }
};
