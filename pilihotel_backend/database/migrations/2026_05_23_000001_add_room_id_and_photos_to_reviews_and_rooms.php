<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('rooms', function (Blueprint $table): void {
            $table->json('photos')->nullable()->after('facilities');
        });

        Schema::table('reviews', function (Blueprint $table): void {
            $table->foreignId('room_id')->nullable()->after('hotel_id')->constrained()->nullOnDelete();
        });
    }

    public function down(): void
    {
        Schema::table('reviews', function (Blueprint $table): void {
            $table->dropForeign(['room_id']);
            $table->dropColumn('room_id');
        });

        Schema::table('rooms', function (Blueprint $table): void {
            $table->dropColumn('photos');
        });
    }
};
