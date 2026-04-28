import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tokokita/core/bucket.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  double totalSales = 0;
  double totalPurchases = 0;
  int totalProducts = 0;
  int todayOrders = 0;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      final sales = await supabase
          .from('orders')
          .select('total_price');

      totalSales = sales.fold<double>(
        0,
        (sum, item) => sum + (item['total_price'] ?? 0),
      );

      final purchases = await supabase
          .from('purchases')
          .select('total_price');

      totalPurchases = purchases.fold<double>(
        0,
        (sum, item) => sum + (item['total_price'] ?? 0),
      );

      final products = await supabase
          .from('products')
          .select('id');

      totalProducts = products.length;

      final today = DateTime.now();
      final start = DateTime(today.year, today.month, today.day);

      final ordersToday = await supabase
          .from('orders')
          .select('id')
          .gte('created_at', start.toIso8601String());

      todayOrders = ordersToday.length;

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  String formatRupiah(num value) {
    return NumberFormat.currency(locale: 'id', symbol: 'Rp ')
        .format(value);
  }

  Widget buildCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 10),
              Text(title,
                  style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                buildCard(
                  'Penjualan',
                  formatRupiah(totalSales),
                  Icons.attach_money,
                  Colors.green,
                ),
                const SizedBox(width: 10),
                buildCard(
                  'Pembelian',
                  formatRupiah(totalPurchases),
                  Icons.shopping_cart,
                  Colors.orange,
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                buildCard(
                  'Produk',
                  totalProducts.toString(),
                  Icons.inventory,
                  Colors.blue,
                ),
                const SizedBox(width: 10),
                buildCard(
                  'Hari Ini',
                  todayOrders.toString(),
                  Icons.today,
                  Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}