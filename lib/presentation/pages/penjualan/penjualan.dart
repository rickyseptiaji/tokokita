import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:tokokita/core/bucket.dart';
import 'package:tokokita/presentation/pages/penjualan/detail.dart';
import 'package:tokokita/presentation/pages/penjualan/form.dart';

class PenjualanPage extends StatefulWidget {
  const PenjualanPage({super.key});

  @override
  State<PenjualanPage> createState() => _PenjualanPageState();
}

class _PenjualanPageState extends State<PenjualanPage> {
  late Future<List<Map<String, dynamic>>> future;

  Future<List<Map<String, dynamic>>> getPenjualan() async {
    final response = await supabase
        .from('orders')
        .select()
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  @override
  void initState() {
    super.initState();
    future = getPenjualan();
  }

  Future<void> refresh() async {
    setState(() {
      future = getPenjualan();
    });
  }

  String formatRupiah(num value) {
    return NumberFormat.currency(locale: 'id', symbol: 'Rp ').format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Penjualan')),
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
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FormPenjualan(),
                      ),
                    );
                    refresh();
                  },
                  child: const Text('Tambah'),
                ),
              ],
            ),
            SizedBox(height: 12),


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
                    return const Center(child: Text('Tidak ada penjualan'));
                  }

                  final penjualan = snapshot.data!;

                  return ListView.builder(
                    itemCount: penjualan.length,
                    itemBuilder: (context, index) {
                      final order = penjualan[index];

                      return Card(
                        child: Slidable(
                          key: ValueKey(order['id']),
                          endActionPane: ActionPane(
                            motion: const DrawerMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (context) async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DetailPenjualan(id: order['id']),
                                    ),
                                  );
                                  refresh();
                                },
                                backgroundColor: Colors.blue,
                                icon: Icons.info,
                                label: 'Detail',
                              ),

  
                              SlidableAction(
                                onPressed: (context) async {
                                  await supabase
                                      .from('orders')
                                      .delete()
                                      .eq('id', order['id']);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Penjualan dihapus'),
                                    ),
                                  );

                                  refresh();
                                },
                                backgroundColor: Colors.red,
                                icon: Icons.delete,
                                label: 'Delete',
                              ),
                            ],
                          ),

                          child: ListTile(
                            title: Text(order['customer_name'] ?? 'Umum'),
                            subtitle: Text(
                              'Status: ${order['status'] ?? '-'}\n'
                              'Tanggal: ${order['created_at']}',
                            ),
                            trailing: Text(
                              formatRupiah((order['total_price'] ?? 0) as num),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
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
