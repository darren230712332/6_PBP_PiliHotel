<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Booking;
use App\Models\Review;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ReviewController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json([
            'data' => Review::query()
                ->with(['hotel', 'room', 'booking.room'])
                ->latest()
                ->get(),
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $payload = $request->validate([
            'booking_id' => ['required', 'exists:bookings,id'],
            'rating' => ['required', 'integer', 'min:1', 'max:5'],
            'comment' => ['nullable', 'string'],
            'photos' => ['nullable', 'array'],
            'photos.*' => ['nullable', 'file', 'image', 'mimes:jpeg,png,jpg,gif', 'max:5120'],
        ]);

        $booking = Booking::query()->findOrFail($payload['booking_id']);

        if ($booking->user_id !== $request->user()->id) {
            return response()->json([
                'message' => 'Anda tidak berhak menambahkan review untuk booking ini.',
            ], 403);
        }

        if ($booking->payment_status !== 'paid') {
            return response()->json([
                'message' => 'Review hanya dapat dibuat setelah booking dibayar.',
            ], 422);
        }

        if ($booking->check_out->isFuture()) {
            return response()->json([
                'message' => 'Review baru tersedia setelah tanggal check-out.',
            ], 422);
        }

        $review = Review::query()->updateOrCreate(
            ['booking_id' => $booking->id],
            [
                'user_id' => $request->user()->id,
                'hotel_id' => $booking->hotel_id,
                'room_id' => $booking->room_id,
                'rating' => $payload['rating'],
                'comment' => $payload['comment'] ?? null,
                'photos' => $this->resolvePhotos($request, $payload['photos'] ?? []),
            ],
        );

        return response()->json([
            'message' => 'Ulasan berhasil disimpan.',
            'data' => $review->load(['hotel', 'room', 'booking.room']),
        ], 201);
    }

    public function update(Request $request, Review $review): JsonResponse
    {
        if ($review->user_id !== $request->user()->id) {
            return response()->json([
                'message' => 'Anda tidak berhak mengubah review ini.',
            ], 403);
        }

        $payload = $request->validate([
            'rating' => ['required', 'integer', 'min:1', 'max:5'],
            'comment' => ['nullable', 'string'],
            'photos' => ['nullable', 'array'],
            'photos.*' => ['nullable', 'file', 'image', 'mimes:jpeg,png,jpg,gif', 'max:5120'],
        ]);

        $review->update([
            'rating' => $payload['rating'],
            'comment' => $payload['comment'] ?? null,
            'photos' => $this->resolvePhotos($request, $payload['photos'] ?? []),
        ]);

        return response()->json([
            'message' => 'Ulasan berhasil diperbarui.',
            'data' => $review->load(['hotel', 'room', 'booking.room']),
        ]);
    }

    public function destroy(Request $request, Review $review): JsonResponse
    {
        if ($review->user_id !== $request->user()->id) {
            return response()->json([
                'message' => 'Anda tidak berhak menghapus review ini.',
            ], 403);
        }

        $review->delete();

        return response()->json([
            'message' => 'Ulasan berhasil dihapus.',
        ]);
    }

    private function resolvePhotos(Request $request, array $existingPhotos = []): array
    {
        $storedPhotos = [];
        $uploadedPhotos = $request->file('photos', []);

        if (is_array($uploadedPhotos)) {
            foreach ($uploadedPhotos as $photo) {
                if ($photo) {
                    $path = $photo->store('review-photos', 'public');
                    $storedPhotos[] = asset('storage/' . $path);
                }
            }
        }

        if (!empty($existingPhotos)) {
            foreach ($existingPhotos as $photo) {
                if (is_string($photo) && $photo !== '') {
                    $storedPhotos[] = $photo;
                }
            }
        }

        return array_values(array_unique($storedPhotos));
    }
}
