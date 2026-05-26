import 'dart:convert';
import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:pilihotel_pbp_6/core/models/index.dart';

import '../constants/api_constants.dart';
import '../exceptions/api_exceptions.dart';
import 'http_client.dart';

/// Service for handling authentication-related API calls
class AuthService {
  final HttpClient _httpClient = HttpClient();
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  /// Helper method to safely parse error response
  Map<String, dynamic> _parseErrorResponse(String body) {
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      return {'message': 'Unknown error'};
    }
  }

  /// Helper method to handle API responses consistently
  Map<String, dynamic> _handleSuccess(String body, {required bool isUserResponse}) {
    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      
      if (isUserResponse) {
        final authResponse = AuthResponse.fromJson(data);
        return {
          'success': true,
          'user': authResponse.user,
          'token': authResponse.token,
          'message': authResponse.message,
        };
      }
      
      return {'success': true, 'data': data};
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to parse response: ${e.toString()}',
      };
    }
  }

  /// Helper method to handle API exceptions
  Map<String, dynamic> _handleException(Object e) {
    if (e is ValidationException) {
      return {
        'success': false,
        'message': e.message,
        'errors': e.errorData,
      };
    } else if (e is AuthenticationException) {
      return {
        'success': false,
        'message': e.message,
      };
    } else if (e is ServerException) {
      return {
        'success': false,
        'message': e.message,
        'errors': e.errorData,
      };
    }
    
    return {
      'success': false,
      'message': e.toString(),
    };
  }

  /// Register user with email and password
  Future<Map<String, dynamic>> register({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _httpClient.post(
        ApiConstants.authRegister,
        body: {
          'name': name,
          'phone': phone,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      if (response.statusCode == 201) {
        final authResponse = AuthResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );

        if (authResponse.token.isNotEmpty) {
          await _httpClient.saveToken(authResponse.token);
        }

        return {
          'success': true,
          'user': authResponse.user,
          'token': authResponse.token,
          'message': authResponse.message,
        };
      }

      final error = _parseErrorResponse(response.body);
      return {
        'success': false,
        'message': error['message'] ?? 'Registration failed',
        'errors': error['errors'],
      };
    } catch (e) {
      return _handleException(e);
    }
  }

  /// Login user with email and password
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _httpClient.post(
        ApiConstants.authLogin,
        body: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );

        await _httpClient.saveToken(authResponse.token);

        return {
          'success': true,
          'user': authResponse.user,
          'token': authResponse.token,
        };
      }

      final error = _parseErrorResponse(response.body);
      return {
        'success': false,
        'message': error['message'] ?? 'Login failed',
      };
    } catch (e) {
      return _handleException(e);
    }
  }

  /// Login or register using Google Sign-In
  Future<Map<String, dynamic>> loginWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        return {
          'success': false,
          'message': 'Google login cancelled',
        };
      }

      final response = await _httpClient.post(
        '/auth/google',
        body: {
          'google_id': account.id,
          'name': account.displayName ?? account.email.split('@').first,
          'email': account.email,
          'photo_url': account.photoUrl,
        },
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
        await _httpClient.saveToken(authResponse.token);

        return {
          'success': true,
          'user': authResponse.user,
          'token': authResponse.token,
        };
      }

      final error = _parseErrorResponse(response.body);
      return {
        'success': false,
        'message': error['message'] ?? 'Google login failed',
        'errors': error['errors'],
      };
    } catch (e) {
      return _handleException(e);
    }
  }

  /// Get current user profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _httpClient.get(ApiConstants.userProfile);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final user = User.fromJson(data['data'] as Map<String, dynamic>);

        return {
          'success': true,
          'user': user,
        };
      }

      return {
        'success': false,
        'message': 'Failed to fetch profile',
      };
    } catch (e) {
      return _handleException(e);
    }
  }

  /// Update user profile (name, email, phone)
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? email,
    String? phone,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (email != null) body['email'] = email;
      if (phone != null) body['phone'] = phone;

      final response = await _httpClient.put(
        ApiConstants.userUpdate,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final user = User.fromJson(data['data'] as Map<String, dynamic>);

        return {
          'success': true,
          'user': user,
          'message': data['message'],
        };
      }

      final error = _parseErrorResponse(response.body);
      return {
        'success': false,
        'message': error['message'] ?? 'Update failed',
        'errors': error['errors'],
      };
    } catch (e) {
      return _handleException(e);
    }
  }

  /// Logout user and clear token
  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await _httpClient.post(
        ApiConstants.authLogout,
        body: {},
      );

      if (response.statusCode == 200) {
        await _httpClient.clearToken();

        return {
          'success': true,
          'message': 'Logout successful',
        };
      }

      return {
        'success': false,
        'message': 'Logout failed',
      };
    } catch (e) {
      // Even if request fails, clear token locally
      await _httpClient.clearToken();
      return _handleException(e);
    }
  }

  /// Change user password
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      final response = await _httpClient.post(
        '/auth/change-password',
        body: {
          'current_password': currentPassword,
          'password': newPassword,
          'password_confirmation': newPasswordConfirmation,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return {
          'success': true,
          'message': data['message'] ?? 'Password changed successfully',
        };
      }

      final error = _parseErrorResponse(response.body);
      return {
        'success': false,
        'message': error['message'] ?? 'Failed to change password',
        'errors': error['errors'],
      };
    } catch (e) {
      return _handleException(e);
    }
  }

  /// Upload user profile photo from File
  Future<Map<String, dynamic>> uploadPhoto({
    required File photo,
  }) async {
    try {
      final response = await _httpClient.uploadFile(
        '/profile/photo',
        photo,
        fieldName: 'photo',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return {
          'success': true,
          'message': data['message'] ?? 'Photo uploaded successfully',
          'data': data['data'],
        };
      }

      final error = _parseErrorResponse(response.body);
      return {
        'success': false,
        'message': error['message'] ?? 'Failed to upload photo',
        'errors': error['errors'],
      };
    } catch (e) {
      return _handleException(e);
    }
  }

  /// Upload user profile photo from bytes (for web)
  Future<Map<String, dynamic>> uploadPhotoBytes({
    required String filename,
    required List<int> bytes,
  }) async {
    try {
      final response = await _httpClient.uploadFileBytes(
        '/profile/photo',
        bytes,
        filename: filename,
        fieldName: 'photo',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return {
          'success': true,
          'message': data['message'] ?? 'Photo uploaded successfully',
          'data': data['data'],
        };
      }

      final error = _parseErrorResponse(response.body);
      return {
        'success': false,
        'message': error['message'] ?? 'Failed to upload photo',
        'errors': error['errors'],
      };
    } catch (e) {
      return _handleException(e);
    }
  }
}

