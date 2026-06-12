import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../widgets/bottom_navbar.dart';
import '../../review/review_page.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint(
          'DEBUG_NOTIF_CLICK: onDidReceiveNotificationResponse triggered. actionId: ${response.actionId}, payload: ${response.payload}',
        );

        // Save to local storage upon tap so that it is registered in the list
        String hotelName = 'Hotel';
        String? bookingId;
        if (response.payload != null && response.payload!.isNotEmpty) {
          try {
            final data = json.decode(response.payload!) as Map<String, dynamic>;
            hotelName = data['hotelName'] ?? 'Hotel';
            bookingId = data['bookingId']?.toString();
          } catch (_) {}
        }
        _instance.addNotification(
          title: 'Waktu Review Sudah Tersedia',
          body:
              'Bagaimana pengalaman menginap Anda di $hotelName? Silakan berikan ulasan Anda sekarang.',
          type: 'review',
          bookingId: bookingId,
        );

        if (response.actionId != 'action_later') {
          if (response.payload != null && response.payload!.isNotEmpty) {
            _navigateToReview(response.payload!);
          } else {
            _navigateToOrders();
          }
        }
      },
    );

    // Handle case where app is launched from terminated state via notification click
    try {
      final launchDetails = await _localNotifications
          .getNotificationAppLaunchDetails();
      debugPrint(
        'DEBUG_NOTIF_CLICK: didNotificationLaunchApp: ${launchDetails?.didNotificationLaunchApp}',
      );
      if (launchDetails?.didNotificationLaunchApp ?? false) {
        final response = launchDetails?.notificationResponse;
        debugPrint(
          'DEBUG_NOTIF_CLICK: Launch response actionId: ${response?.actionId}, payload: ${response?.payload}',
        );
        if (response != null && response.actionId != 'action_later') {
          if (response.payload != null && response.payload!.isNotEmpty) {
            _navigateToReview(response.payload!);
          } else {
            _navigateToOrders();
          }
        }
      }
    } catch (e) {
      debugPrint('DEBUG_NOTIF_CLICK: Error checking app launch details: $e');
    }
  }

  static void _navigateToOrders() {
    debugPrint(
      'DEBUG_NOTIF_CLICK: _navigateToOrders called. navigatorKey.currentState: ${navigatorKey.currentState}',
    );
    if (navigatorKey.currentState != null) {
      try {
        navigatorKey.currentState!.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainShell(initialIndex: 1)),
          (route) => false,
        );
        debugPrint('DEBUG_NOTIF_CLICK: Navigation successful');
      } catch (e) {
        debugPrint('DEBUG_NOTIF_CLICK: Navigation failed with error: $e');
      }
    } else {
      debugPrint(
        'DEBUG_NOTIF_CLICK: navigatorKey.currentState is null. Retrying in 500ms...',
      );
      Future.delayed(const Duration(milliseconds: 500), _navigateToOrders);
    }
  }

  static void _navigateToReview(String payload) {
    debugPrint(
      'DEBUG_NOTIF_CLICK: _navigateToReview called with payload: $payload. navigatorKey.currentState: ${navigatorKey.currentState}',
    );

    Map<String, dynamic> data;
    try {
      data = json.decode(payload) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('DEBUG_NOTIF_CLICK: Failed to parse payload JSON: $e');
      _navigateToOrders();
      return;
    }

    final bookingId = int.tryParse(data['bookingId']?.toString() ?? '');
    final hotelName = data['hotelName'] as String?;
    final stayInfo = data['stayInfo'] as String?;
    final image = data['image'] as String?;

    if (bookingId == null) {
      _navigateToOrders();
      return;
    }

    if (navigatorKey.currentState != null) {
      try {
        navigatorKey.currentState!.push(
          MaterialPageRoute(
            builder: (_) => ReviewPage(
              bookingId: bookingId,
              hotelName: hotelName,
              stayInfo: stayInfo,
              image: image,
            ),
          ),
        );
        debugPrint(
          'DEBUG_NOTIF_CLICK: Direct Review Page navigation successful',
        );
      } catch (e) {
        debugPrint(
          'DEBUG_NOTIF_CLICK: Direct Review Page navigation failed: $e. Falling back to orders...',
        );
        _navigateToOrders();
      }
    } else {
      debugPrint(
        'DEBUG_NOTIF_CLICK: navigatorKey.currentState is null. Retrying in 500ms...',
      );
      Future.delayed(
        const Duration(milliseconds: 500),
        () => _navigateToReview(payload),
      );
    }
  }

  Future<void> requestPermissions() async {
    final androidImplementation = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  /// Add a notification to local storage
  Future<void> addNotification({
    required String title,
    required String body,
    required String type,
    String? bookingId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? notificationsJson = prefs.getString('local_notifications');
      List<dynamic> list = [];
      if (notificationsJson != null) {
        list = json.decode(notificationsJson) as List<dynamic>;
      }

      // Check if a notification with the exact same title and body or bookingId already exists to avoid duplicates
      final isDuplicate = list.any((item) {
        final itemMap = item as Map<String, dynamic>;
        if (bookingId != null &&
            itemMap['booking_id']?.toString() == bookingId) {
          return true;
        }
        return itemMap['title'] == title && itemMap['body'] == body;
      });

      if (isDuplicate) {
        debugPrint('DEBUG_NOTIF: Duplicate notification entry prevented');
        return;
      }

      list.insert(0, {
        'title': title,
        'body': body,
        'type': type,
        'booking_id': bookingId,
        'timestamp': DateTime.now().toIso8601String(),
      });
      await prefs.setString('local_notifications', json.encode(list));
    } catch (e) {
      // ignore
    }
  }

  /// Delete a notification at a specific index
  Future<void> deleteNotification(int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? notificationsJson = prefs.getString('local_notifications');
      if (notificationsJson == null) return;
      final list = json.decode(notificationsJson) as List<dynamic>;
      if (index >= 0 && index < list.length) {
        list.removeAt(index);
        await prefs.setString('local_notifications', json.encode(list));
      }
    } catch (_) {}
  }

  /// Delete a notification by its unique timestamp
  Future<void> deleteNotificationByTimestamp(String timestamp) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? notificationsJson = prefs.getString('local_notifications');
      if (notificationsJson == null) return;
      final list = json.decode(notificationsJson) as List<dynamic>;
      list.removeWhere((item) {
        final itemMap = item as Map<String, dynamic>;
        return itemMap['timestamp']?.toString() == timestamp;
      });
      await prefs.setString('local_notifications', json.encode(list));
    } catch (_) {}
  }

  /// Get all stored notifications
  Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? notificationsJson = prefs.getString('local_notifications');
      if (notificationsJson == null) return [];
      final list = json.decode(notificationsJson) as List<dynamic>;
      return list.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Clear all stored notifications
  Future<void> clearNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('local_notifications');
    } catch (_) {}
  }

  /// Schedule notification for real checkin time
  Future<void> scheduleCheckinReminder({
    required int bookingId,
    required String hotelName,
    required DateTime checkinTime,
  }) async {
    if (checkinTime.isAfter(DateTime.now())) {
      const title = 'Reminder Check-in';
      final body =
          'Check-in Anda di $hotelName dimulai hari ini! Jangan lupa persiapkan akomodasi Anda.';

      try {
        final scheduleTime = tz.TZDateTime.from(checkinTime.toUtc(), tz.UTC);

        await _localNotifications.zonedSchedule(
          bookingId + 100000, // separate namespace for check-in
          title,
          body,
          scheduleTime,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'checkin_reminders',
              'Check-in Reminders',
              channelDescription:
                  'Notifications reminding users about check-in',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      } catch (_) {
        // ignore
      }
    }
  }

  /// Schedule notification for real checkout time
  Future<void> scheduleCheckoutReminder({
    required int bookingId,
    required String hotelName,
    required DateTime checkoutTime,
    required String stayInfo,
    required String image,
  }) async {
    // Only schedule if checkoutTime is in the future by at least 1 minute to prevent immediate double firing during testing
    if (checkoutTime.difference(DateTime.now()).inMinutes > 1) {
      const title = 'Waktu Review Sudah Tersedia';
      final body =
          'Bagaimana pengalaman menginap Anda di $hotelName? Silakan berikan ulasan Anda sekarang.';

      try {
        final payload = json.encode({
          'bookingId': bookingId,
          'hotelName': hotelName,
          'stayInfo': stayInfo,
          'image': image,
        });

        // Use UTC timezone to avoid timezone lookup exceptions on custom devices/emulators
        final scheduleTime = tz.TZDateTime.from(checkoutTime.toUtc(), tz.UTC);

        await _localNotifications.zonedSchedule(
          bookingId,
          title,
          body,
          scheduleTime,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'checkout_reminders',
              'Checkout Reminders',
              channelDescription:
                  'Notifications reminding users to review hotels after checkout',
              importance: Importance.max,
              priority: Priority.high,
              actions: <AndroidNotificationAction>[
                AndroidNotificationAction(
                  'action_review',
                  'Beri Ulasan',
                  showsUserInterface: true,
                ),
                AndroidNotificationAction('action_later', 'Nanti'),
              ],
            ),
          ),
          payload: payload,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      } catch (e) {
        // Fallback log
      }
    }
  }

  /// Trigger test notification in X seconds for demo purposes
  Future<void> triggerDemoNotification({
    required int bookingId,
    required String hotelName,
    required String stayInfo,
    required String image,
    int delaySeconds = 5,
  }) async {
    const title = 'Waktu Review Sudah Tersedia';
    final body =
        'Bagaimana pengalaman menginap Anda di $hotelName? Silakan berikan ulasan Anda sekarang.';

    // Save to local storage immediately so it shows in the app UI list
    await addNotification(
      title: title,
      body: body,
      type: 'review',
      bookingId: bookingId.toString(),
    );

    final payload = json.encode({
      'bookingId': bookingId,
      'hotelName': hotelName,
      'stayInfo': stayInfo,
      'image': image,
    });

    // Use Future.delayed + show to bypass zonedSchedule timezone issues on custom devices
    Future.delayed(Duration(seconds: delaySeconds), () async {
      try {
        await _localNotifications.show(
          9999, // Constant ID to prevent double/duplicate notifications
          title,
          body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'checkout_reminders',
              'Checkout Reminders',
              channelDescription:
                  'Notifications reminding users to review hotels after checkout',
              importance: Importance.max,
              priority: Priority.high,
              actions: <AndroidNotificationAction>[
                AndroidNotificationAction(
                  'action_review',
                  'Beri Ulasan',
                  showsUserInterface: true,
                ),
                AndroidNotificationAction('action_later', 'Nanti'),
              ],
            ),
          ),
          payload: payload,
        );
      } catch (_) {
        // ignore
      }
    });
  }
}
