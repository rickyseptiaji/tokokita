import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class RiwayatPenjualan extends StatelessWidget {
  const RiwayatPenjualan({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Penjualan'),
      ),
      body: const Center(
        child: Text('Halaman Riwayat Penjualan'),
      )
    );
  }
}