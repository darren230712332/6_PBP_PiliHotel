<?php

namespace Database\Seeders;

use App\Models\Booking;
use App\Models\Hotel;
use App\Models\Review;
use App\Models\Room;
use App\Models\User;
use Illuminate\Support\Str;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        $user = User::query()->firstOrCreate(
            ['email' => 'test@example.com'],
            [
                'name' => 'Test User',
                'password' => 'password',
            ],
        );

        $hotels = [
            [
                'name' => 'Grand Palace Hotel',
                'location' => 'Yogyakarta, Indonesia',
                'price_per_night' => 1500000,
                'rating' => 4.8,
                'image' => 'pool',
                'distance' => '200 m',
                'latitude' => -7.7955800,
                'longitude' => 110.3694900,
            ],
            [
                'name' => 'Urban Stay Suites',
                'location' => 'Yogyakarta, Indonesia',
                'price_per_night' => 720000,
                'rating' => 4.6,
                'image' => 'night',
                'distance' => '1.2 km',
                'latitude' => -7.7828100,
                'longitude' => 110.3670700,
            ],
            [
                'name' => 'Sea Breeze Resort',
                'location' => 'Yogyakarta, Indonesia',
                'price_per_night' => 2200000,
                'rating' => 4.9,
                'image' => 'sea',
                'distance' => '800 m',
                'latitude' => -7.8013900,
                'longitude' => 110.3644400,
            ],
            [
                'name' => 'The Heritage Inn',
                'location' => 'Yogyakarta, Indonesia',
                'price_per_night' => 980000,
                'rating' => 4.7,
                'image' => 'bed',
                'distance' => '1.5 km',
                'latitude' => -7.8080500,
                'longitude' => 110.3705300,
            ],
        ];

        foreach ($hotels as $hotelData) {
            $hotel = Hotel::query()->updateOrCreate(
                ['name' => $hotelData['name']],
                [
                    ...$hotelData,
                    'description' => 'Hotel modern dengan kamar luas, fasilitas premium, area bersih, dan akses mudah ke pusat kota.',
                ],
            );

            $rooms = [
                [
                    'name' => 'Deluxe King Room',
                    'capacity' => 2,
                    'bed_count' => 1,
                    'bathroom_count' => 1,
                    'price_per_night' => $hotel->price_per_night,
                    'description' => 'Deluxe King Room nyaman dengan tempat tidur king-size dan pemandangan.',
                    'facilities' => ['WiFi Gratis', 'AC', 'TV Pintar', 'Kopi', 'Shower Air Panas'],
                    'photos' => ['bed', 'modern', 'pool'],
                ],
                [
                    'name' => 'Family Room',
                    'capacity' => 4,
                    'bed_count' => 2,
                    'bathroom_count' => 1,
                    'price_per_night' => (int) round($hotel->price_per_night * 1.35),
                    'description' => 'Kamar keluarga luas dengan area duduk dan meja kerja.',
                    'facilities' => ['WiFi Gratis', 'AC', 'TV Pintar', 'Sarapan Prasmanan Harian', 'Kulkas Mini'],
                    'photos' => ['modern', 'bed', 'sea'],
                ],
                [
                    'name' => 'Executive Twin',
                    'capacity' => 2,
                    'bed_count' => 2,
                    'bathroom_count' => 1,
                    'price_per_night' => (int) round($hotel->price_per_night * 1.15),
                    'description' => 'Kamar twin modern untuk perjalanan bisnis atau teman.',
                    'facilities' => ['WiFi Gratis', 'AC', 'Smart TV', 'Kopi/Teh', 'Hair Dryer'],
                    'photos' => ['bed', 'night', 'modern'],
                ],
            ];

            foreach ($rooms as $roomData) {
                Room::query()->updateOrCreate(
                    ['hotel_id' => $hotel->id, 'name' => $roomData['name']],
                    $roomData,
                );
            }
        }

        $hotel = Hotel::query()->where('name', 'Grand Palace Hotel')->firstOrFail();
        $room = $hotel->rooms()->firstOrFail();

        $booking = Booking::query()->updateOrCreate(
            ['booking_code' => 'BH-9921'],
            [
                'user_id' => $user->id,
                'hotel_id' => $hotel->id,
                'room_id' => $room->id,
                'check_in' => '2026-05-01',
                'check_out' => '2026-05-03',
                'nights' => 2,
                'extras' => [
                    ['name' => 'Sarapan Prasmanan Harian', 'price' => 50000],
                ],
                'payment_method' => 'Transfer Bank',
                'payment_status' => 'paid',
                'status' => 'Menunggu Check-in',
                'total_price' => 3050000,
                'qr_code' => 'PH-BH-9921-READY',
            ],
        );

        Review::query()->updateOrCreate(
            ['booking_id' => $booking->id],
            [
                'hotel_id' => $hotel->id,
                'room_id' => $room->id,
                'user_id' => $user->id,
                'rating' => 4,
                'comment' => 'Pengalaman menginap yang luar biasa. Kamarnya bersih, nyaman, dan proses check-in cepat.',
                'photos' => ['bed', 'pool', 'sea'],
            ],
        );

        $extraBookings = [
            ['code' => 'BH-AGD1', 'hotel' => 'Urban Stay Suites', 'room' => 'Executive Twin', 'nights' => 1, 'status' => 'Menunggu Pembayaran', 'payment_status' => 'pending'],
            ['code' => 'BH-AGD2', 'hotel' => 'Sea Breeze Resort', 'room' => 'Family Room', 'nights' => 3, 'status' => 'Menunggu Check-in', 'payment_status' => 'paid'],
        ];

        foreach ($extraBookings as $item) {
            $bookingHotel = Hotel::query()->where('name', $item['hotel'])->first();
            if (!$bookingHotel) {
                continue;
            }

            $bookingRoom = Room::query()
                ->where('hotel_id', $bookingHotel->id)
                ->where('name', $item['room'])
                ->first();

            if (!$bookingRoom) {
                continue;
            }

            $checkIn = now()->addDays(random_int(1, 14));
            $nights = max(1, $item['nights']);

            Booking::query()->updateOrCreate(
                ['booking_code' => $item['code']],
                [
                    'user_id' => $user->id,
                    'hotel_id' => $bookingHotel->id,
                    'room_id' => $bookingRoom->id,
                    'check_in' => $checkIn->toDateString(),
                    'check_out' => $checkIn->copy()->addDays($nights)->toDateString(),
                    'nights' => $nights,
                    'extras' => [['name' => 'Airport Shuttle', 'price' => 75000]],
                    'payment_method' => $item['payment_status'] === 'paid' ? 'Virtual Account' : null,
                    'payment_status' => $item['payment_status'],
                    'status' => $item['status'],
                    'total_price' => ($bookingRoom->price_per_night * $nights) + 75000,
                    'qr_code' => $item['payment_status'] === 'paid'
                        ? 'PH-' . $item['code'] . '-' . Str::upper(Str::random(6))
                        : null,
                ],
            );
        }
    }
}
