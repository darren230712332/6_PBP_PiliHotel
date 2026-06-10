import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_constants.dart';
import '../exceptions/api_exceptions.dart';

/// HTTP Client for API communication with singleton pattern
///
/// Base URL resolution order:
///   1. --dart-define=API_BASE_URL=http://YOUR_IP:8000/api  (highest priority)
///   2. Web browser → http://127.0.0.1:8000/api
///   3. Android Emulator → http://10.0.2.2:8000/api  (loopback to host)
///   4. iOS Simulator → http://127.0.0.1:8000/api
///   5. Physical device → set via --dart-define (see run.sh / .vscode/launch.json)
///
/// Quick start for physical device:
///   flutter run --dart-define=API_BASE_URL=http://<YOUR_MAC_IP>:8000/api
///   Or simply run: ./run.sh  (auto-detects Mac IP)
class HttpClient {
  static String get _baseUrl {
    // 1. Highest priority: explicit override via --dart-define
    const envBaseUrl = String.fromEnvironment('API_BASE_URL');
    if (envBaseUrl.isNotEmpty) {
      return envBaseUrl;
    }

    // 2. Web
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    }

    // 3. Android Emulator: 10.0.2.2 is the special alias for host machine's localhost
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api';
    }

    // 4. iOS Simulator: localhost resolves to host machine directly
    if (Platform.isIOS) {
      return 'http://127.0.0.1:8000/api';
    }

    // 5. Fallback (macOS/Linux/Windows desktop)
    return 'http://127.0.0.1:8000/api';
  }

  static final HttpClient _instance = HttpClient._internal();

  factory HttpClient() {
    return _instance;
  }

  HttpClient._internal();

  String? _token;

  /// Set token directly (used for login flows)
  void setToken(String token) {
    _token = token;
  }

  /// Get stored token from memory or SharedPreferences
  Future<String?> getToken() async {
    if (_token != null) {
      return _token;
    }
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(StorageKeys.authToken);
    return _token;
  }

  /// Save token to memory and persistent storage
  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.authToken, token);
  }

  /// Clear stored token from memory and persistent storage
  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StorageKeys.authToken);
  }

  /// Build request headers with authentication
  Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': HttpHeaders.contentTypeJson,
      'Accept': HttpHeaders.accept,
      if (token != null) 'Authorization': '${HttpHeaders.authorizationBearer} $token',
    };
  }

  /// Handle HTTP response and throw appropriate exceptions
  void _handleResponse(http.Response response, String method, String endpoint) {
    final statusCode = response.statusCode;

    // Success responses (2xx)
    if (statusCode >= 200 && statusCode < 300) {
      return;
    }

    // Try to parse error message from response body
    String errorMessage = 'Unknown error';
    Map<String, dynamic>? errorData;

    try {
      final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
      errorMessage = jsonBody['message'] ?? errorMessage;
      errorData = jsonBody['errors'];
    } catch (_) {
      errorMessage = response.body.isNotEmpty ? response.body : 'Unknown error';
    }

    // Handle specific status codes
    switch (statusCode) {
      case 401:
      case 403:
        throw AuthenticationException(
          errorMessage.isEmpty ? 'Unauthorized access' : errorMessage,
        );
      case 404:
        throw NotFoundException(
          errorMessage.isEmpty ? 'Resource not found' : errorMessage,
        );
      case 422:
        throw ValidationException(
          errorMessage.isEmpty ? 'Validation failed' : errorMessage,
          errorData: errorData,
        );
      case 429:
        throw ServerException(
          'Too many requests. Please try again later.',
          statusCode: 429,
        );
      case 500:
      case 502:
      case 503:
      case 504:
        throw ServerException(
          'Server error. Please try again later.',
          statusCode: statusCode,
        );
      default:
        throw ServerException(
          errorMessage,
          statusCode: statusCode,
          errorData: errorData,
        );
    }
  }

  /// Generic request handler to reduce code duplication
  Future<http.Response> _request(
    Future<http.Response> Function() requestFn,
    String method,
    String endpoint,
  ) async {
    try {
      final response = await requestFn.call().timeout(
            ApiTimeouts.defaultTimeout,
            onTimeout: () => throw TimeoutException(),
          );

      _handleResponse(response, method, endpoint);
      return response;
    } on ApiException {
      rethrow;
    } on TimeoutException {
      rethrow;
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  /// GET request
  Future<http.Response> get(String endpoint) async {
    final headers = await _getHeaders();
    final url = Uri.parse('$_baseUrl$endpoint');

    return _request(
      () => http.get(url, headers: headers),
      'GET',
      endpoint,
    );
  }

  /// POST request
  Future<http.Response> post(
    String endpoint, {
    required Map<String, dynamic> body,
  }) async {
    final headers = await _getHeaders();
    final url = Uri.parse('$_baseUrl$endpoint');

    return _request(
      () => http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      ),
      'POST',
      endpoint,
    );
  }

  /// PUT request
  Future<http.Response> put(
    String endpoint, {
    required Map<String, dynamic> body,
  }) async {
    final headers = await _getHeaders();
    final url = Uri.parse('$_baseUrl$endpoint');

    return _request(
      () => http.put(
        url,
        headers: headers,
        body: jsonEncode(body),
      ),
      'PUT',
      endpoint,
    );
  }

  /// DELETE request
  Future<http.Response> delete(String endpoint) async {
    final headers = await _getHeaders();
    final url = Uri.parse('$_baseUrl$endpoint');

    return _request(
      () => http.delete(url, headers: headers),
      'DELETE',
      endpoint,
    );
  }

  /// Helper method to extract filename from file path
  String _getFilename(String filePath) {
    return filePath.split('/').last;
  }

  /// Upload file using multipart/form-data
  /// 
  /// Handles both mobile and web platforms appropriately.
  /// [endpoint]: API endpoint for file upload
  /// [file]: File to upload
  /// [fieldName]: Form field name for the file (default: 'photo')
  Future<http.Response> uploadFile(
    String endpoint,
    File file, {
    String fieldName = 'photo',
  }) async {
    final token = await getToken();
    final uri = Uri.parse('$_baseUrl$endpoint');
    final request = http.MultipartRequest('POST', uri);

    if (token != null) {
      request.headers['Authorization'] =
          '${HttpHeaders.authorizationBearer} $token';
    }

    try {
      if (kIsWeb) {
        // For web, read file as bytes
        final fileBytes = await file.readAsBytes();
        final filename = _getFilename(file.path);
        request.files.add(http.MultipartFile.fromBytes(
          fieldName,
          fileBytes,
          filename: filename,
        ));
      } else {
        // For mobile, use file path
        request.files.add(
          await http.MultipartFile.fromPath(fieldName, file.path),
        );
      }

      final streamed = await request.send().timeout(
            ApiTimeouts.uploadTimeout,
            onTimeout: () => throw TimeoutException(),
          );
      final response = await http.Response.fromStream(streamed);

      _handleResponse(response, 'POST', endpoint);
      return response;
    } on ApiException {
      rethrow;
    } on TimeoutException {
      rethrow;
    } catch (e) {
      throw NetworkException('Upload failed: ${e.toString()}');
    }
  }

  /// Upload multiple files and form fields using multipart/form-data
  /// 
  /// [endpoint]: API endpoint
  /// [fields]: Map of form field names and values
  /// [files]: Map of field names to lists of files
  Future<http.Response> uploadMultipart(
    String endpoint, {
    Map<String, String> fields = const {},
    Map<String, List<File>> files = const {},
  }) async {
    final token = await getToken();
    final uri = Uri.parse('$_baseUrl$endpoint');
    final request = http.MultipartRequest('POST', uri);

    if (token != null) {
      request.headers['Authorization'] =
          '${HttpHeaders.authorizationBearer} $token';
    }

    request.fields.addAll(fields);

    try {
      for (final entry in files.entries) {
        for (final file in entry.value) {
          if (kIsWeb) {
            // For web, read file as bytes
            final fileBytes = await file.readAsBytes();
            final filename = _getFilename(file.path);
            request.files.add(http.MultipartFile.fromBytes(
              entry.key,
              fileBytes,
              filename: filename,
            ));
          } else {
            // For mobile, use file path
            request.files.add(
              await http.MultipartFile.fromPath(entry.key, file.path),
            );
          }
        }
      }

      final streamed = await request.send().timeout(
            ApiTimeouts.uploadTimeout,
            onTimeout: () => throw TimeoutException(),
          );
      final response = await http.Response.fromStream(streamed);

      _handleResponse(response, 'POST', endpoint);
      return response;
    } on ApiException {
      rethrow;
    } on TimeoutException {
      rethrow;
    } catch (e) {
      throw NetworkException('Upload failed: ${e.toString()}');
    }
  }

  /// Upload file from bytes (for web and in-memory files)
  /// 
  /// [endpoint]: API endpoint
  /// [bytes]: File content as bytes
  /// [filename]: Name of the file
  /// [fieldName]: Form field name for the file (default: 'photo')
  Future<http.Response> uploadFileBytes(
    String endpoint,
    List<int> bytes, {
    required String filename,
    String fieldName = 'photo',
  }) async {
    final token = await getToken();
    final uri = Uri.parse('$_baseUrl$endpoint');
    final request = http.MultipartRequest('POST', uri);

    if (token != null) {
      request.headers['Authorization'] =
          '${HttpHeaders.authorizationBearer} $token';
    }

    try {
      request.files.add(http.MultipartFile.fromBytes(
        fieldName,
        bytes,
        filename: filename,
      ));

      final streamed = await request.send().timeout(
            ApiTimeouts.uploadTimeout,
            onTimeout: () => throw TimeoutException(),
          );
      final response = await http.Response.fromStream(streamed);

      _handleResponse(response, 'POST', endpoint);
      return response;
    } on ApiException {
      rethrow;
    } on TimeoutException {
      rethrow;
    } catch (e) {
      throw NetworkException('Upload failed: ${e.toString()}');
    }
  }
}
