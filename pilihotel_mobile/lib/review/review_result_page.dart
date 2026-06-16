import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../core/services/review_service.dart';
import '../core/services/http_client.dart';
import '../core/widgets/custom_appbar.dart';
import '../core/widgets/custom_dialog.dart';
import '../core/widgets/hotel_card.dart';
import '../core/widgets/loading_dialog.dart';
import '../core/models/review.dart' as api;
// import 'review_page.dart';

class ReviewResultPage extends StatefulWidget {
  final api.Review review;
  final String? hotelName;
  final String? stayInfo;
  final String? image;

  const ReviewResultPage({
    super.key,
    required this.review,
    this.hotelName,
    this.stayInfo,
    this.image,
  });

  @override
  State<ReviewResultPage> createState() => _ReviewResultPageState();
}

class _ReviewResultPageState extends State<ReviewResultPage> {
  final ReviewService _reviewService = ReviewService();
  late api.Review _currentReview;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _currentReview = widget.review;
  }

  Future<void> _deleteReview() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Ulasan', style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text('Apakah Anda yakin ingin menghapus ulasan ini? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (!mounted) return;
    setState(() => _loading = true);
    showPiliLoadingDialog(context, message: 'Menghapus ulasan...');

    try {
      await _reviewService.deleteReview(_currentReview.id);
      
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // Dismiss loading

      await showPiliDialog(
        context,
        icon: Icons.delete_outline,
        title: 'Ulasan Dihapus',
        message: 'Ulasan Anda berhasil dihapus.',
        buttonText: 'Selesai',
        color: Colors.red,
      );

      if (!mounted) return;
      Navigator.pop(context); // Go back to OrderPage
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // Dismiss loading
      
      showPiliDialog(
        context,
        icon: Icons.error_outline,
        title: 'Gagal',
        message: 'Gagal menghapus ulasan: $e',
        color: AppColors.danger,
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  /*
  Future<void> _editReview() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewPage(
          bookingId: _currentReview.bookingId,
          hotelName: widget.hotelName,
          stayInfo: widget.stayInfo,
          image: widget.image,
          existingReview: _currentReview,
        ),
      ),
    );
    
    // Once they return from editing, we pop back to OrderPage so it fetches fresh data
    if (mounted) {
      Navigator.pop(context);
    }
  }
  */

  @override
  Widget build(BuildContext context) {
    final photos = _currentReview.photos ?? [];

    return Scaffold(
      appBar: const CustomAppBar(title: 'Ulasan Saya'),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          // Header Hotel Info Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: HotelImage(
                    kind: widget.image ?? 'bed',
                    width: 68,
                    height: 68,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: .08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'KUNJUNGAN SEBELUMNYA',
                          style: TextStyle(
                            color: AppColors.primaryBlue,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.hotelName ?? 'Hotel',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w900,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.stayInfo ?? '',
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: AppColors.muted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // Review Content Container
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Star Rating
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final isFilled = index < _currentReview.rating;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          Icons.star,
                          size: 30,
                          color: isFilled ? const Color(0xFFF2994A) : const Color(0xFFE0E0E0),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 22),

                // Comment
                const Text(
                  'Ulasan Anda',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.field,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _currentReview.comment?.isNotEmpty == true
                        ? _currentReview.comment!
                        : 'Tidak ada komentar tertulis.',
                    style: const TextStyle(
                      fontSize: 11,
                      height: 1.45,
                      color: AppColors.text,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

                // Uploaded Photos
                if (photos.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  const Text(
                    'Foto yang Diunggah',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: photos.length,
                      itemBuilder: (context, index) {
                        final rawUrl = photos[index];
                        final formattedUrl = HttpClient.formatAssetUrl(rawUrl) ?? rawUrl;
                        return GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => Dialog(
                                backgroundColor: Colors.transparent,
                                insetPadding: const EdgeInsets.all(10),
                                child: Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    InteractiveViewer(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(formattedUrl, fit: BoxFit.contain),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close, color: Colors.white, size: 28),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: 80,
                            height: 80,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                formattedUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image_outlined, color: AppColors.muted),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Action Buttons: Delete (Edit button commented out)
          /*
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _editReview,
                    icon: const Icon(Icons.edit_outlined, size: 15),
                    label: const Text('Edit Ulasan', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF0F6FE),
                      foregroundColor: AppColors.primaryBlue,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _deleteReview,
                    icon: const Icon(Icons.delete_outline, size: 15),
                    label: const Text('Hapus Ulasan', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFEBEE),
                      foregroundColor: Colors.red,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Color(0xFFFFCDD2)),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          */
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: _loading ? null : _deleteReview,
              icon: const Icon(Icons.delete_outline, size: 15),
              label: const Text('Hapus Ulasan', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFEBEE),
                foregroundColor: Colors.red,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: Color(0xFFFFCDD2)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
