import 'package:flutter/material.dart';

class ReviewResultPage extends StatelessWidget {
  final String? hotelName;
  final String? stayInfo;
  final String? image;

  const ReviewResultPage({Key? key, this.hotelName, this.stayInfo, this.image})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ulasan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              hotelName ?? 'Hotel',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(stayInfo ?? ''),
            const SizedBox(height: 24),
            const Text('Hasil ulasan (placeholder)'),
          ],
        ),
      ),
    );
  }
}
