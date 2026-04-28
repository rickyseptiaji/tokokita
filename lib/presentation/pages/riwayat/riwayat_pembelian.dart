import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tokokita/core/bucket.dart';

class RiwayatPembelian extends StatefulWidget {
  const RiwayatPembelian({super.key});

  @override
  State<RiwayatPembelian> createState() => _RiwayatPembelianState();
}

class _RiwayatPembelianState extends State<RiwayatPembelian> {
  late Future<List<Map<String, dynamic>>> future;

  @override
  void initState() {
    super.initState();
    future = getPembelian();
  }

  Future<List<Map<String, dynamic>>> getPembelian() async {
    final response = await supabase
        .from('purchases')
        .select('*, suppliers(name)')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> refresh() async {
    setState(() {
      future = getPembelian();
    });
  }

  String formatRupiah(num value) {
    return NumberFormat.currency(locale: 'id', symbol: 'Rp ').format(value);
  }

  String formatTanggal(String? date) {
    if (date == null) return '-';
    final parsed = DateTime.parse(date);
    return DateFormat('dd MMM yyyy, HH:mm').format(parsed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Pembelian')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [

            Row(
              children: [
                Expanded(
                  child: SearchBar(
                    hintText: 'Cari Pembelian...',
                    leading: const Icon(Icons.search),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),


            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Belum ada pembelian'));
                  }

                  final data = snapshot.data!;
                  return RefreshIndicator(
                    onRefresh: refresh,
                    child: ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final item = data[index];

                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.shopping_cart),

                            title: Text(
                              'Supplier: ${item['supplier']?['name'] ?? '-'}',
                            ),

                            subtitle: Text(
                              'Tanggal: ${formatTanggal(item['created_at'])}',
                            ),

                            trailing: Text(
                              formatRupiah((item['total_price'] ?? 0) as num),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            onTap: () {

                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
