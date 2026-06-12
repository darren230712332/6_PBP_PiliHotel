<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\BookingController;
use App\Http\Controllers\Api\HotelController;
use App\Http\Controllers\Api\ProfilController;
use App\Http\Controllers\Api\ReviewController;
use Illuminate\Support\Facades\Route;

// Auth routes (public)
Route::post('/auth/register', [AuthController::class, 'register']);
Route::post('/auth/login', [AuthController::class, 'login']);
Route::post('/auth/google', [AuthController::class, 'googleLogin']);

// Protected routes (require authentication)
Route::middleware('auth:sanctum')->group(function () {
    // Auth
    Route::post('/auth/logout', [AuthController::class, 'logout']);
    Route::post('/auth/change-password', [AuthController::class, 'changePassword']);
    
    // Profile
    Route::get('/profile', [ProfilController::class, 'show']);
    Route::put('/profile', [ProfilController::class, 'update']);
    Route::post('/profile/photo', [ProfilController::class, 'uploadPhoto']);
    Route::post('/profile/fcm-token', [ProfilController::class, 'saveFcmToken']);
    Route::get('/profile/devices', [ProfilController::class, 'getDevices']);
    // Bookings
    Route::get('/bookings', [BookingController::class, 'index']);
    Route::post('/bookings', [BookingController::class, 'store']);
    Route::get('/bookings/{booking}', [BookingController::class, 'show']);
    Route::post('/bookings/{booking}/pay', [BookingController::class, 'pay']);

    // Reviews
    Route::post('/reviews', [ReviewController::class, 'store']);
    Route::put('/reviews/{review}', [ReviewController::class, 'update']);
    Route::delete('/reviews/{review}', [ReviewController::class, 'destroy']);
});

// Public hotel endpoints (no auth)
Route::get('/hotels', [HotelController::class, 'index']);
Route::get('/hotels/nearby', [HotelController::class, 'nearby']);
Route::get('/hotels/{hotel}', [HotelController::class, 'show']);
Route::get('/reviews', [ReviewController::class, 'index']);
Route::get('/bookings/{booking}/download-pdf', [BookingController::class, 'downloadPdf']);
