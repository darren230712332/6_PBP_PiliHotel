/// API endpoint constants
class ApiConstants {
  // Auth endpoints
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authLogout = '/auth/logout';
  static const String authOtp = '/auth/otp';
  static const String authVerifyOtp = '/auth/verify-otp';

  // Hotel endpoints
  static const String hotelsGet = '/hotels';
  static const String hotelDetail = '/hotels/:id';

  // Booking endpoints
  static const String bookingsCreate = '/bookings';
  static const String bookingsGet = '/bookings';
  static const String bookingDetail = '/bookings/:id';

  // Payment endpoints
  static const String paymentsCreate = '/payments';
  static const String paymentDetail = '/payments/:id';

  // User endpoints
  static const String userProfile = '/users/profile';
  static const String userUpdate = '/users/profile';
}

/// Storage keys
class StorageKeys {
  static const String authToken = 'auth_token';
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';
}

/// API timeouts
class ApiTimeouts {
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(minutes: 5);
}

/// HTTP headers
class HttpHeaders {
  static const String contentTypeJson = 'application/json';
  static const String accept = 'application/json';
  static const String authorizationBearer = 'Bearer';
}
