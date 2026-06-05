<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Booking;
use App\Models\Room;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class BookingController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        return response()->json([
            'data' => Booking::query()
                ->where('user_id', $request->user()->id)
                ->with(['hotel', 'room', 'review'])
                ->latest()
                ->get(),
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $payload = $request->validate([
            'room_id' => ['required', 'exists:rooms,id'],
            'check_in' => ['required', 'date'],
            'check_out' => ['required', 'date', 'after:check_in'],
            'extras' => ['nullable', 'array'],
        ]);

        $room = Room::query()->with('hotel')->findOrFail($payload['room_id']);
        $checkIn = Carbon::parse($payload['check_in']);
        $checkOut = Carbon::parse($payload['check_out']);
        $nights = $checkIn->diffInDays($checkOut);
        $extras = $payload['extras'] ?? [];
        $extrasTotal = collect($extras)->sum(fn (array $item): int => (int) ($item['price'] ?? 0));

        $booking = Booking::query()->create([
            'user_id' => $request->user()->id,
            'hotel_id' => $room->hotel_id,
            'room_id' => $room->id,
            'booking_code' => 'BH-'.strtoupper(Str::random(5)),
            'check_in' => $checkIn,
            'check_out' => $checkOut,
            'nights' => $nights,
            'extras' => $extras,
            'total_price' => ($room->price_per_night * $nights) + $extrasTotal,
        ]);

        return response()->json([
            'message' => 'Booking berhasil dibuat.',
            'data' => $booking->load(['hotel', 'room']),
        ], 201);
    }

    public function show(Booking $booking): JsonResponse
    {
        if ($booking->user_id !== request()->user()->id) {
            return response()->json([
                'message' => 'Anda tidak berhak melihat booking ini.',
            ], 403);
        }

        return response()->json([
            'data' => $booking->load(['hotel', 'room', 'review']),
        ]);
    }

    public function pay(Request $request, Booking $booking): JsonResponse
    {
        if ($booking->user_id !== $request->user()->id) {
            return response()->json([
                'message' => 'Anda tidak berhak membayar booking ini.',
            ], 403);
        }

        $payload = $request->validate([
            'payment_method' => ['required', 'string', 'max:80'],
        ]);

        $booking->update([
            'payment_method' => $payload['payment_method'],
            'payment_status' => 'paid',
            'status' => 'Menunggu Check-in',
            'qr_code' => 'PH-'.$booking->booking_code.'-'.Str::upper(Str::random(8)),
        ]);

        return response()->json([
            'message' => 'Pembayaran berhasil.',
            'data' => $booking->load(['hotel', 'room']),
        ]);
    }
}
