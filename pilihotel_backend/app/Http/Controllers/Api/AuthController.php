<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\UserDevice;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Illuminate\Validation\Rules\Password;

class AuthController extends Controller
{
    /**
     * Register a new user
     */
    public function register(Request $request): JsonResponse
    {
        $payload = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'phone' => ['nullable', 'string', 'max:20'],
            'email' => ['required', 'email', 'unique:users,email'],
            'password' => ['required', 'string', Password::min(6)],
            'password_confirmation' => ['required', 'same:password'],
        ], [
            'email.unique' => 'Email sudah terdaftar.',
            'password.min' => 'Password minimal 6 karakter.',
            'password_confirmation.same' => 'Konfirmasi password tidak sesuai.',
        ]);

        $user = User::query()->create([
            'name' => $payload['name'],
            'email' => $payload['email'],
            'password' => Hash::make($payload['password']),
            'phone' => $payload['phone'] ?? null,
        ]);

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'Registrasi berhasil.',
            'data' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'created_at' => $user->created_at,
            ],
            'token' => $token,
        ], 201);
    }

    /**
     * Login user
     */
    public function login(Request $request): JsonResponse
    {
        $payload = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
        ]);

        $user = User::query()->where('email', $payload['email'])->first();

        if (!$user || !Hash::check($payload['password'], $user->password)) {
            return response()->json([
                'message' => 'Email atau password salah.',
            ], 401);
        }

        // Create API token using Laravel Sanctum
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'Login berhasil.',
            'data' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'photo_url' => $user->photo_url,
            ],
            'token' => $token,
        ], 200);
    }

    /**
     * Login or register a user from Google Sign-In data sent by the mobile app.
     */
    public function googleLogin(Request $request): JsonResponse
    {
        $payload = $request->validate([
            'google_id' => ['required', 'string', 'max:255'],
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email'],
            'photo_url' => ['nullable', 'url'],
        ]);

        $user = User::query()
            ->where('google_id', $payload['google_id'])
            ->orWhere('email', $payload['email'])
            ->first();

        if ($user) {
            $user->update([
                'name' => $payload['name'],
                'google_id' => $payload['google_id'],
                'auth_provider' => 'google',
                'photo_url' => $payload['photo_url'] ?? $user->photo_url,
            ]);
        } else {
            $user = User::query()->create([
                'name' => $payload['name'],
                'email' => $payload['email'],
                'google_id' => $payload['google_id'],
                'auth_provider' => 'google',
                'photo_url' => $payload['photo_url'] ?? null,
                'password' => Hash::make(Str::random(40)),
            ]);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'Login Google berhasil.',
            'data' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'photo_url' => $user->photo_url,
            ],
            'token' => $token,
        ]);
    }

    /**
     * Logout user
     */
    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Logout berhasil.',
        ], 200);
    }

    /**
     * Get authenticated user profile
     */
    public function profile(Request $request): JsonResponse
    {
        $user = $request->user();

        return response()->json([
            'data' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'photo_url' => $user->photo_url,
                'phone' => $user->phone ?? null,
                'created_at' => $user->created_at,
            ],
        ], 200);
    }

    /**
     * Update user profile
     */
    public function updateProfile(Request $request): JsonResponse
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
            ],
        ], 200);
    }

    /**
     * Upload user profile photo
     */
    public function uploadPhoto(Request $request): JsonResponse
    {
        $payload = $request->validate([
            'photo' => ['required', 'image', 'mimes:jpeg,png,jpg,gif', 'max:5120'],
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
}
