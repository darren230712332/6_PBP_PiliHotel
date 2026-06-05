<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Hotel;
use Illuminate\Http\JsonResponse;

class HotelController extends Controller
{
    public function index(): JsonResponse
    {
        $hotels = Hotel::query()
            ->with(['rooms' => fn ($query) => $query->withAvg('reviews', 'rating')])
            ->withAvg('reviews', 'rating')
            ->latest()
            ->get()
            ->map(fn (Hotel $hotel): Hotel => $this->applyAverageRating($hotel));

        return response()->json([
            'data' => $hotels,
        ]);
    }

    public function nearby(): JsonResponse
    {
        $hotels = Hotel::query()
            ->with(['rooms' => fn ($query) => $query->withAvg('reviews', 'rating')])
            ->withAvg('reviews', 'rating')
            ->orderByRaw("CAST(REPLACE(REPLACE(distance, ' km', ''), ' m', '') AS DECIMAL(8,2))")
            ->get()
            ->map(fn (Hotel $hotel): Hotel => $this->applyAverageRating($hotel));

        return response()->json([
            'data' => $hotels,
        ]);
    }

    public function show(Hotel $hotel): JsonResponse
    {
        $hotel
            ->load(['rooms' => fn ($query) => $query->withAvg('reviews', 'rating')])
            ->loadAvg('reviews', 'rating');

        return response()->json([
            'data' => $this->applyAverageRating($hotel),
        ]);
    }

    private function applyAverageRating(Hotel $hotel): Hotel
    {
        if ($hotel->reviews_avg_rating !== null) {
            $hotel->rating = round((float) $hotel->reviews_avg_rating, 1);
        }

        if ($hotel->relationLoaded('rooms')) {
            $hotel->rooms->each(function ($room): void {
                if ($room->reviews_avg_rating !== null) {
                    $room->rating = round((float) $room->reviews_avg_rating, 1);
                }
            });
        }

        return $hotel;
    }
}
