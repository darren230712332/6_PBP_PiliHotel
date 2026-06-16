import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../core/services/notification_service.dart';
import '../core/widgets/custom_appbar.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final NotificationService _notificationService = NotificationService();
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final list = await _notificationService.getNotifications();
    setState(() {
      _notifications = list;
      _isLoading = false;
    });
  }

  Future<void> _deleteNotification(String timestamp) async {
    setState(() {
      _notifications.removeWhere((item) => item['timestamp']?.toString() == timestamp);
    });
    await _notificationService.deleteNotificationByTimestamp(timestamp);
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'review':
        return Icons.rate_review_outlined;
      case 'promo':
        return Icons.local_offer_outlined;
      case 'booking':
        return Icons.receipt_long_outlined;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  String _formatTime(dynamic timestampStr) {
    if (timestampStr == null) return 'Hari ini';
    try {
      final dateTime = DateTime.parse(timestampStr.toString());
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'Baru saja';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m lalu';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} jam lalu';
      } else if (difference.inDays == 1) {
        return 'Kemarin';
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } catch (_) {
      return 'Hari ini';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Notifikasi'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadNotifications,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                children: _notifications.isEmpty
                    ? [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: const Center(
                            child: Text(
                              'Tidak ada notifikasi baru',
                              style: TextStyle(
                                color: AppColors.muted,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ]
                    : List.generate(_notifications.length, (i) {
                        final item = _notifications[i];
                        final timestamp = item['timestamp']?.toString() ?? '';
                        return Dismissible(
                          key: Key(timestamp.isNotEmpty ? timestamp : i.toString()),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) {
                            _deleteNotification(timestamp);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Notifikasi dihapus'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: AppColors.danger,
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: const Icon(
                              Icons.delete_outline,
                              color: Colors.white,
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(11),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: .04),
                                  blurRadius: 12,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  backgroundColor: const Color(0xFFEAF4FF),
                                  child: Icon(
                                    _getIconForType(item['type'] ?? 'info'),
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            item['title'] ?? '',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w900,
                                              color: AppColors.text,
                                            ),
                                          ),
                                          Text(
                                            _formatTime(item['timestamp']),
                                            style: const TextStyle(
                                              fontSize: 9.5,
                                              color: AppColors.muted,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        item['body'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          height: 1.4,
                                          color: Color(0xFF5A667A),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
              ),
            ),
    );
  }
}
