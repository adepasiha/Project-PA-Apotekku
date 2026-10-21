import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ApotekKu'),
      ),
      body: const Center(
        child: Text(
          'Selamat Datang di ApotekKu!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}