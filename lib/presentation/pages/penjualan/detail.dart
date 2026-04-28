import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tokokita/core/bucket.dart';

class DetailPenjualan extends StatefulWidget {
  final String id;
  const DetailPenjualan({super.key, required this.id});

  @override
  State<DetailPenjualan> createState() => _DetailPenjualanState();
}

class _DetailPenjualanState extends State<DetailPenjualan> {
  late Future<Map<String, dynamic>> future;

  @override
  void initState() {
    super.initState();
    future = getDetail();
  }

  Future<Map<String, dynamic>> getDetail() async {
    final response = await supabase
        .from('orders')
        .select('*, order_items(*, products(name, image_url))')
        .eq('id', widget.id)
        .single();

    return response;
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
      appBar: AppBar(title: const Text('Detail Penjualan')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data!;
          final items = data['order_items'] as List;

          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Card(
                  child: ListTile(
                    title: Text(data['customer_name'] ?? '-'),
                    subtitle: Text(
                      'Tanggal: ${formatTanggal(data['created_at'])}',
                    ),
                    trailing: Text(
                      formatRupiah((data['total_price'] ?? 0) as num),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final product = item['products'];

                      return Card(
                        child: ListTile(
                          leading: Image.network(
                            product?['image_url'] ?? '',
                            width: 40,
                            height: 40,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.image_not_supported),
                          ),
                          title: Text(product?['name'] ?? '-'),
                          subtitle: Text(
                            '${item['qty']} x ${formatRupiah((item['price'] ?? 0) as num)}',
                          ),
                          trailing: Text(
                            formatRupiah(
                              (item['subtotal'] ?? 0) as num,
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}