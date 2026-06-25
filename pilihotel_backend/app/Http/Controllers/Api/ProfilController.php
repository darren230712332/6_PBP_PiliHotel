<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\UserDevice;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rules\Password;

class ProfilController extends Controller
{
    /**
     * Get authenticated user profile
     */
    public function show(Request $request): JsonResponse
    {
        $user = $request->user();

        return response()->json([
            'data' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'photo_url' => $user->photo_url,
                'phone' => $user->phone ?? null,
                'auth_provider' => $user->auth_provider ?? 'local',
                'created_at' => $user->created_at,
                'updated_at' => $user->updated_at,
            ],
        ], 200);
    }

    /**
     * Update user profile
     */
    public function update(Request $request): JsonResponse
    {
        $payload = $request->validate([
            'name' => ['nullable', 'string', 'max:255'],
            'email' => ['nullable', 'email', 'unique:users,email,' . $request->user()->id],
            'phone' => ['nullable', 'string', 'max:20'],
        ]);

        $user = $request->user();
        $user->update($payload);

        return response()->json([
            'message' => 'Profil berhasil diperbarui.',
            'data' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'photo_url' => $user->photo_url,
                'phone' => $user->phone,
                'updated_at' => $user->updated_at,
            ],
        ], 200);
    }

    /**
     * Upload user profile photo
     */
    public function uploadPhoto(Request $request): JsonResponse
    {
        $payload = $request->validate([
            'photo' => ['required', 'image', 'mimes:jpeg,png,jpg,gif,webp,heic', 'max:10240'],
        ]);

        $user = $request->user();

        // Store photo
        $photoPath = $payload['photo']->store('profile-photos', 'public');

        // Update user photo
        $user->update([
            'photo_url' => asset('storage/' . $photoPath),
        ]);

        return response()->json([
            'message' => 'Foto profil berhasil diupload.',
            'data' => [
                'id' => $user->id,
                'photo_url' => $user->photo_url,
            ],
        ], 200);
    }

    /**
     * Change authenticated user's password
     */
    public function changePassword(Request $request): JsonResponse
    {
        $payload = $request->validate([
            'current_password' => ['required', 'string'],
            'password' => ['required', 'string', Password::min(6)],
            'password_confirmation' => ['required', 'same:password'],
        ], [
            'password.min' => 'Password minimal 6 karakter.',
            'password_confirmation.same' => 'Konfirmasi password tidak sesuai.',
        ]);

        $user = $request->user();

        if (!Hash::check($payload['current_password'], $user->password)) {
            return response()->json([
                'message' => 'Password saat ini salah.',
            ], 403);
        }

        $user->update([
            'password' => Hash::make($payload['password']),
        ]);

        return response()->json([
            'message' => 'Password berhasil diubah.',
        ], 200);
    }

    /**
     * Save or update FCM token for the authenticated user's device
     */
    public function saveFcmToken(Request $request): JsonResponse
    {
        $payload = $request->validate([
            'fcm_token' => ['required', 'string', 'min:20'],
            'device_id' => ['nullable', 'string', 'max:255'],
            'platform' => ['nullable', 'string', 'max:30'],
        ]);

        $device = UserDevice::query()->updateOrCreate(
            ['fcm_token' => $payload['fcm_token']],
            [
                'user_id' => $request->user()->id,
                'device_id' => $payload['device_id'] ?? null,
                'platform' => $payload['platform'] ?? 'unknown',
                'is_active' => true,
                'last_seen_at' => now(),
            ],
        );

        return response()->json([
            'message' => 'FCM token berhasil disimpan.',
            'data' => [
                'id' => $device->id,
                'platform' => $device->platform,
            ],
        ], 200);
    }

    /**
     * Get user devices
     */
    public function getDevices(Request $request): JsonResponse
    {
        $user = $request->user();
        $devices = $user->devices()->get();

        return response()->json([
            'data' => $devices->map(fn($device) => [
                'id' => $device->id,
                'device_id' => $device->device_id,
                'platform' => $device->platform,
                'is_active' => $device->is_active,
                'last_seen_at' => $device->last_seen_at,
            ]),
        ], 200);
    }
}
