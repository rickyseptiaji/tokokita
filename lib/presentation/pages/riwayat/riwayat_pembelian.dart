import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class RiwayatPembelian extends StatelessWidget {
  const RiwayatPembelian({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pembelian'),
      ),
      body: const Center(
        child: Text('Halaman Riwayat Pembelian'),
      ),
    );
  }
}