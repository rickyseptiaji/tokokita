import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tokokita/core/bucket.dart';

class RiwayatPenjualan extends StatefulWidget {
  const RiwayatPenjualan({super.key});

  @override
  State<RiwayatPenjualan> createState() => _RiwayatPenjualanState();
}

class _RiwayatPenjualanState extends State<RiwayatPenjualan> {
  late Future<List<Map<String, dynamic>>> future;

  @override
  void initState() {
    super.initState();
    future = getPenjualan();
  }

  Future<List<Map<String, dynamic>>> getPenjualan() async {
    final response = await supabase
        .from('orders')
        .select('*, order_items(count)')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> refresh() async {
    setState(() {
      future = getPenjualan();
    });
  }

  String formatRupiah(num value) {
    return NumberFormat.currency(locale: 'id', symbol: 'Rp ')
        .format(value);
  }

  String formatTanggal(String? date) {
    if (date == null) return '-';
    final parsed = DateTime.parse(date);
    return DateFormat('dd MMM yyyy, HH:mm').format(parsed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Penjualan')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [

            Row(
              children: [
                Expanded(
                  child: SearchBar(
                    hintText: 'Cari Penjualan...',
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
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                        child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData ||
                      snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('Belum ada penjualan'));
                  }

                  final data = snapshot.data!;

                  return RefreshIndicator(
                    onRefresh: refresh,
                    child: ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final item = data[index];

                        final itemCount =
                            (item['order_items'] as List?)?.isNotEmpty == true
                                ? item['order_items'][0]['count']
                                : 0;

                        return Card(
                          child: ListTile(
                            leading:
                                const Icon(Icons.point_of_sale),

                            title: Text(
                              item['customer_name'] ?? 'Umum',
                            ),

                            subtitle: Text(
                              'Item: $itemCount\n'
                              'Status: ${item['status'] ?? '-'}\n'
                              'Tanggal: ${formatTanggal(item['created_at'])}',
                            ),

                            trailing: Text(
                              formatRupiah(
                                (item['total_price'] ?? 0) as num,
                              ),
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