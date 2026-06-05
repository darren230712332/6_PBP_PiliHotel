import 'package:flutter/material.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eksplor'),
        automaticallyImplyLeading: false,
      ),
      body: const Center(child: Text('Halaman Eksplor')),
    );
  }
}
