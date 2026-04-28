import 'package:flutter/material.dart';

class DetailPenjualan extends StatefulWidget {
  final String id;
  const DetailPenjualan({super.key , required this.id});

  @override
  State<DetailPenjualan> createState() => _DetailPenjualanState();
}

class _DetailPenjualanState extends State<DetailPenjualan> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Penjualan'),
      ),
      body: const Center(
        child: Text('Detail penjualan akan ditampilkan di sini'),
      ),
    );
  }
}