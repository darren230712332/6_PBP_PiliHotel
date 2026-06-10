import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/colors.dart';
import '../core/services/review_service.dart';
import '../core/services/http_client.dart';
import '../core/widgets/custom_appbar.dart';
import '../core/widgets/custom_dialog.dart';
import '../core/widgets/hotel_card.dart';
import '../core/widgets/loading_dialog.dart';
import '../core/models/review.dart' as api;

class ReviewPage extends StatefulWidget {
  final int bookingId;
  final String? hotelName;
  final String? stayInfo;
  final String? image;
  final api.Review? existingReview;

  const ReviewPage({
    super.key,
    required this.bookingId,
    this.hotelName,
    this.stayInfo,
    this.image,
    this.existingReview,
  });

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final ReviewService _reviewService = ReviewService();
  final ImagePicker _imagePicker = ImagePicker();
  
  late final TextEditingController _commentController;
  late int _rating;
  
  final List<File> _selectedPhotos = [];
  late List<String> _existingPhotos;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _rating = widget.existingReview?.rating ?? 5;
    _commentController = TextEditingController(text: widget.existingReview?.comment ?? '');
    _existingPhotos = List<String>.from(widget.existingReview?.photos ?? []);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final result = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (result != null) {
        setState(() {
          _selectedPhotos.add(File(result.path));
        });
      }
    } catch (e) {
      showPiliDialog(
        context,
        icon: Icons.error_outline,
        title: 'Gagal',
        message: 'Gagal mengambil gambar: $e',
        color: AppColors.danger,
      );
    }
  }

  void _chooseImageSource() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Pilih Sumber Foto',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.text),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                      icon: const Icon(Icons.camera_alt_outlined, color: AppColors.primaryBlue),
                      label: const Text('Kamera', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w700)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                      icon: const Icon(Icons.photo_library_outlined, color: AppColors.primaryBlue),
                      label: const Text('Galeri', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w700)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitReview() async {
    if (_loading) return;

    setState(() => _loading = true);
    showPiliLoadingDialog(
      context,
      message: widget.existingReview != null ? 'Memperbarui ulasan...' : 'Mengirimkan ulasan Anda...',
    );

    try {
      final commentText = _commentController.text.trim();
      
      if (widget.existingReview != null) {
        // Edit mode
        // Note: review_service updateReview only updates text/rating, so let's pass comment and rating.
        // If photos changed, we will perform update on comment/rating.
        final payload = <String, dynamic>{
          'rating': _rating,
          'comment': commentText,
          'photos': _existingPhotos, // Keep current photos
        };
        
        await _reviewService.updateReview(widget.existingReview!.id, payload);
      } else {
        // Create mode
        final payload = <String, dynamic>{
          'booking_id': widget.bookingId,
          'rating': _rating,
          'comment': commentText,
        };
        await _reviewService.createReview(payload, photos: _selectedPhotos);
      }

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // Dismiss loading

      await showPiliDialog(
        context,
        icon: Icons.check_circle_outline,
        title: 'Ulasan Terkirim',
        message: 'Terima kasih atas ulasan Anda! Masukan Anda sangat berharga bagi kami.',
        buttonText: 'Selesai',
        color: AppColors.success,
      );

      if (!mounted) return;
      Navigator.pop(context); // Go back
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Dismiss loading
      }
      if (!mounted) return;
      showPiliDialog(
        context,
        icon: Icons.error_outline,
        title: 'Gagal',
        message: 'Gagal mengirim ulasan: $e',
        color: AppColors.danger,
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingReview != null;
    final totalPhotosCount = _existingPhotos.length + _selectedPhotos.length;

    return Scaffold(
      appBar: CustomAppBar(title: isEditing ? 'Edit Ulasan' : 'Tulis Ulasan'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 120),
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
          const SizedBox(height: 28),

          // Rating Prompt & Stars
          Center(
            child: Column(
              children: [
                const Text(
                  'Bagaimana pengalaman menginap Anda?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Ketuk bintang untuk memberikan rating keseluruhan',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final isFilled = index < _rating;
                    return GestureDetector(
                      onTap: () => setState(() => _rating = index + 1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          Icons.star,
                          size: 34,
                          color: isFilled ? const Color(0xFFF2994A) : const Color(0xFFE0E0E0),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Comment Field
          const Text(
            'Komentar / Pengalaman',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              controller: _commentController,
              maxLines: 4,
              maxLength: 500,
              style: const TextStyle(fontSize: 12, color: AppColors.text, height: 1.45),
              decoration: const InputDecoration(
                hintText: 'Ceritakan apa yang Anda sukai, atau bagian mana yang perlu ditingkatkan...',
                hintStyle: TextStyle(color: AppColors.muted, fontSize: 11),
                contentPadding: EdgeInsets.all(14),
                border: InputBorder.none,
                counterText: '',
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Photos Upload Section
          const Text(
            'Tambah Foto',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 10),
          
          SizedBox(
            height: 80,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // Dash Box Upload Button (Visible if count < 5)
                if (totalPhotosCount < 5)
                  GestureDetector(
                    onTap: _chooseImageSource,
                    child: Container(
                      width: 80,
                      height: 80,
                      margin: const EdgeInsets.only(right: 10),
                      child: CustomPaint(
                        painter: DashedRectPainter(
                          color: AppColors.primaryBlue,
                          strokeWidth: 1.2,
                          gap: 4.5,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.field,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_outlined, size: 20, color: AppColors.primaryBlue),
                              SizedBox(height: 4),
                              Text(
                                'TAMBAH',
                                style: TextStyle(
                                  color: AppColors.primaryBlue,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                // Existing/Previous Photos (Editing mode)
                ..._existingPhotos.map((photoUrl) {
                  final formattedUrl = HttpClient.formatAssetUrl(photoUrl) ?? photoUrl;
                  return _PhotoThumbnail(
                    imageProvider: NetworkImage(formattedUrl),
                    onDelete: () {
                      setState(() {
                        _existingPhotos.remove(photoUrl);
                      });
                    },
                  );
                }),

                // Newly Selected Photos
                ..._selectedPhotos.map((file) {
                  return _PhotoThumbnail(
                    imageProvider: FileImage(file),
                    onDelete: () {
                      setState(() {
                        _selectedPhotos.remove(file);
                      });
                    },
                  );
                }),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          child: SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _loading ? null : _submitReview,
              icon: const Icon(Icons.send_outlined, size: 16),
              label: Text(
                isEditing ? 'Simpan Perubahan' : 'Kirim Ulasan',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PhotoThumbnail extends StatelessWidget {
  final ImageProvider imageProvider;
  final VoidCallback onDelete;

  const _PhotoThumbnail({
    required this.imageProvider,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      margin: const EdgeInsets.only(right: 10),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image(
                image: imageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 2,
            right: 2,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 13,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DashedRectPainter extends CustomPainter {
  DashedRectPainter({
    this.color = Colors.grey,
    this.strokeWidth = 1.0,
    this.gap = 5.0,
  });

  final Color color;
  final double strokeWidth;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path();
    final double r = 8.0; // border radius matching UI

    // Top
    for (double i = r; i < size.width - r; i += gap * 2) {
      path.moveTo(i, 0);
      path.lineTo((i + gap).clamp(0, size.width - r), 0);
    }
    // Right
    for (double i = r; i < size.height - r; i += gap * 2) {
      path.moveTo(size.width, i);
      path.lineTo(size.width, (i + gap).clamp(0, size.height - r));
    }
    // Bottom
    for (double i = size.width - r; i > r; i -= gap * 2) {
      path.moveTo(i, size.height);
      path.lineTo((i - gap).clamp(r, size.width - r), size.height);
    }
    // Left
    for (double i = size.height - r; i > r; i -= gap * 2) {
      path.moveTo(0, i);
      path.lineTo(0, (i - gap).clamp(r, size.height - r));
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
