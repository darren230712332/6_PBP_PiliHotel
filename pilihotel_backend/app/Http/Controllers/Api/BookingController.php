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
    public function downloadPdf($bookingCode)
    {
        $booking = Booking::query()->where('booking_code', $bookingCode)->with(['hotel', 'room'])->firstOrFail();

        $checkInFormatted = Carbon::parse($booking->check_in)->translatedFormat('d M Y');
        $checkOutFormatted = Carbon::parse($booking->check_out)->translatedFormat('d M Y');
        
        $checkInFormatted = Carbon::parse($booking->check_in)->translatedFormat('d M Y');
        $checkOutFormatted = Carbon::parse($booking->check_out)->translatedFormat('d M Y');
        
        $logoPath = base_path('../pilihotel_mobile/assets/images/logo.jpg');
        $logoImg = '';
        if (file_exists($logoPath)) {
            $logoBase64 = base64_encode(file_get_contents($logoPath));
            $logoImg = "<img src='data:image/jpeg;base64,{$logoBase64}' style='width: 40px; height: 40px; vertical-align: middle; margin-right: 12px;' />";
        }
        
        $qrUrl = url('/api/bookings/' . $booking->booking_code . '/download-pdf');
        // generate SVG
        $qrCodeSvg = \SimpleSoftwareIO\QrCode\Facades\QrCode::size(60)->margin(0)->generate($qrUrl);
        // Base64 encode for DomPDF compatibility just in case
        $qrCodeBase64 = base64_encode($qrCodeSvg);
        $qrImg = "<img src='data:image/svg+xml;base64,{$qrCodeBase64}' style='width: 60px; height: 60px;' />";
        
        $html = "
        <html>
        <head>
            <title>Invoice {$booking->booking_code}</title>
            <style>
                @page { margin: 40px; }
                body { 
                    font-family: sans-serif; 
                    color: #1E293B; 
                    background-color: #ffffff;
                }
                .watermark-container {
                    position: absolute;
                    top: 250px;
                    left: 0;
                    width: 100%;
                    text-align: center;
                    z-index: -1;
                }
                .watermark {
                    display: inline-block;
                    font-size: 100px;
                    font-weight: bold;
                    color: rgba(39, 174, 96, 0.05);
                    transform: rotate(-25deg);
                    border: 8px solid rgba(39, 174, 96, 0.05);
                    padding: 20px 40px;
                    border-radius: 20px;
                    letter-spacing: 20px;
                }
                .header {
                    width: 100%;
                    margin-bottom: 20px;
                    border-bottom: 1px solid #E2E8F0;
                    padding-bottom: 15px;
                }
                .logo {
                    font-size: 24px;
                    font-weight: bold;
                    color: #1E293B;
                    float: left;
                }
                .receipt-info {
                    float: right;
                    text-align: right;
                }
                .receipt-info .title {
                    font-size: 14px;
                    font-weight: bold;
                    color: #1E293B;
                    letter-spacing: 0.5px;
                }
                .receipt-info .invoice-no {
                    font-size: 10px;
                    color: #94A3B8;
                    margin-top: 6px;
                }
                .clear { clear: both; }
                
                .section {
                    margin-bottom: 30px;
                }
                .section-header {
                    margin-bottom: 20px;
                }
                
                .grid {
                    width: 100%;
                }
                .grid td {
                    vertical-align: top;
                    width: 50%;
                }
                .label {
                    color: #94A3B8;
                    font-size: 10px;
                    font-weight: bold;
                    margin-bottom: 6px;
                }
                .value {
                    color: #1E293B;
                    font-size: 14px;
                    font-weight: bold;
                }
                
                .detail-box {
                    background-color: #F8FAFC;
                    border-radius: 16px;
                    padding: 24px;
                }
                
                .transaction-table {
                    width: 100%;
                }
                .transaction-table td {
                    padding: 8px 0;
                    font-size: 12px;
                }
                .transaction-table .col-label {
                    color: #64748B;
                }
                .transaction-table .col-value {
                    color: #1E293B;
                    font-weight: bold;
                    text-align: right;
                }
                .transaction-divider {
                    border-top: 1px solid #E2E8F0;
                    margin: 15px 0;
                }
                .total-label {
                    font-size: 16px;
                    font-weight: bold;
                    color: #1E293B;
                }
                .total-value {
                    font-size: 24px;
                    font-weight: bold;
                    color: #2563EB;
                    text-align: right;
                }
                
                .footer {
                    position: absolute;
                    bottom: 0;
                    width: 100%;
                }
                .footer-text {
                    font-size: 10px;
                    color: #94A3B8;
                    float: left;
                    width: 70%;
                    line-height: 1.5;
                    padding-top: 30px;
                }
                .footer-qr {
                    float: right;
                    text-align: right;
                }
                .footer-code {
                    font-size: 10px;
                    font-weight: bold;
                    color: #94A3B8;
                    margin-top: 4px;
                }
            </style>
        </head>
        <body>
            <div class='watermark-container'>
                <div class='watermark'>LUNAS</div>
            </div>
            
            <div class='header'>
                <div class='logo'>{$logoImg}PiliHotel</div>
                <div class='receipt-info'>
                    <div class='title'>BUKTI PEMBAYARAN RESMI</div>
                    <div class='invoice-no'>INV/".date('Ymd', strtotime($booking->check_in))."/PH/{$booking->booking_code}</div>
                </div>
                <div class='clear'></div>
            </div>

            <!-- Informasi Pelanggan -->
            <div class='section'>
                <div class='section-header'>
                    <table cellspacing='0' cellpadding='0'>
                        <tr>
                            <td width='30'><hr style='border:0; border-top: 2px solid #2563EB; margin:0;'/></td>
                            <td style='white-space: nowrap; padding-left: 12px; color: #2563EB; font-size: 12px; font-weight: bold; letter-spacing: 1px;'>INFORMASI PELANGGAN</td>
                        </tr>
                    </table>
                </div>
                <table class='grid' cellspacing='0' cellpadding='0'>
                    <tr>
                        <td>
                            <div class='label'>NAMA PEMESAN</div>
                            <div class='value'>{$booking->user->name}</div>
                        </td>
                        <td>
                            <div class='label'>EMAIL</div>
                            <div class='value'>{$booking->user->email}</div>
                        </td>
                    </tr>
                </table>
            </div>

            <!-- Detail Reservasi -->
            <div class='section'>
                <div class='section-header'>
                    <table cellspacing='0' cellpadding='0'>
                        <tr>
                            <td width='30'><hr style='border:0; border-top: 2px solid #2563EB; margin:0;'/></td>
                            <td style='white-space: nowrap; padding-left: 12px; color: #2563EB; font-size: 12px; font-weight: bold; letter-spacing: 1px;'>DETAIL RESERVASI</td>
                        </tr>
                    </table>
                </div>
                <div class='detail-box'>
                    <div class='label'>HOTEL & KAMAR</div>
                    <div class='value'>{$booking->hotel->name} &mdash; {$booking->room->name}</div>
                    <table class='grid' cellspacing='0' cellpadding='0' style='margin-top:20px;'>
                        <tr>
                            <td>
                                <div class='label'>CHECK-IN</div>
                                <div class='value'>{$checkInFormatted}</div>
                            </td>
                            <td>
                                <div class='label'>DURASI</div>
                                <div class='value'>{$booking->nights} Malam</div>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>

            <!-- Rincian Transaksi -->
            <div class='section'>
                <div class='section-header'>
                    <table cellspacing='0' cellpadding='0'>
                        <tr>
                            <td width='30'><hr style='border:0; border-top: 2px solid #2563EB; margin:0;'/></td>
                            <td style='white-space: nowrap; padding-left: 12px; color: #2563EB; font-size: 12px; font-weight: bold; letter-spacing: 1px;'>RINCIAN TRANSAKSI</td>
                        </tr>
                    </table>
                </div>
                
                <table class='transaction-table' cellspacing='0' cellpadding='0'>
                    <tr>
                        <td class='col-label'>Harga ({$booking->nights} Malam)</td>
                        <td class='col-value'>Rp" . number_format(($booking->hotel->price_per_night ?? 0) * $booking->nights, 0, ',', '.') . "</td>
                    </tr>
                    <tr>
                        <td class='col-label'>Layanan Tambahan (Add-ons)</td>
                        <td class='col-value'>Rp" . number_format($booking->total_price - (($booking->hotel->price_per_night ?? 0) * $booking->nights), 0, ',', '.') . "</td>
                    </tr>
                </table>
                
                <div class='transaction-divider'></div>
                
                <table class='transaction-table' cellspacing='0' cellpadding='0'>
                    <tr>
                        <td class='total-label'>TOTAL</td>
                        <td class='total-value'>Rp" . number_format($booking->total_price, 0, ',', '.') . "</td>
                    </tr>
                </table>
            </div>

            <div class='footer'>
                <div class='footer-text'>
                    Dokumen sah dari sistem PiliHotel. Simpan sebagai<br>bukti check-in.
                </div>
                <div class='footer-qr'>
                    {$qrImg}
                    <div class='footer-code'>#{$booking->booking_code}</div>
                </div>
                <div class='clear'></div>
            </div>
        </body>
        </html>
        ";

        $pdf = \Barryvdh\DomPDF\Facade\Pdf::loadHTML($html);
        return $pdf->download('Invoice-' . $booking->booking_code . '.pdf');
    }
}
