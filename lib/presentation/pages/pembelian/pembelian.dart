import 'package:flutter/material.dart';
import 'package:tokokita/core/bucket.dart';

class PembelianPage extends StatefulWidget {
  final String id;
  const PembelianPage({super.key, required this.id});

  @override
  State<PembelianPage> createState() => _PembelianPageState();
}

class _PembelianPageState extends State<PembelianPage> {
  final _formKey = GlobalKey<FormState>();

  late Future<List<Map<String, dynamic>>> futureProducts;

  List<Map<String, dynamic>> selectedProducts = [];

  Map<String, dynamic>? selectedDropdown;

  @override
  void initState() {
    super.initState();
    futureProducts = getProducts();
  }

  Future<List<Map<String, dynamic>>> getProducts() async {
    final response = await supabase
        .from('products')
        .select()
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> refresh() async {
    setState(() {
      futureProducts = getProducts();
    });
  }

  void addProduct(Map<String, dynamic> product) {
    final existingIndex = selectedProducts.indexWhere(
      (item) => item['product']['id'] == product['id'],
    );

    setState(() {
      if (existingIndex != -1) {
        selectedProducts[existingIndex]['qty'] += 1;
      } else {
        selectedProducts.add({
          'product': product,
          'qty': 1,
          'price': (product['price'] as num).toDouble(),
        });
      }

      selectedDropdown = null;
    });
  }

  double getGrandTotal() {
    double total = 0;
    for (var item in selectedProducts) {
      total += item['qty'] * item['price'];
    }
    return total;
  }

  Future<void> submit() async {
    if (selectedProducts.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pilih produk dulu')));
      return;
    }

    try {
      final purchase = await supabase
          .from('purchases')
          .insert({
            'supplier_id': widget.id,
            'total_price': getGrandTotal(),
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      final purchaseId = purchase['id'];
      await supabase
          .from('purchase_items')
          .insert(
            selectedProducts.map((item) {
              final qty = item['qty'] as int;
              final price = (item['price'] as num).toDouble();

              return {
                'purchase_id': purchaseId,
                'product_id': item['product']['id'],
                'qty': qty,
                'price': price,
                'subtotal': qty * price,
              };
            }).toList(),
          );

      final movements = selectedProducts.map((item) {
        return {
          'product_id': item['product']['id'],
          'type': 'IN',
          'qty': item['qty'],
          'reference_id': purchaseId,
          'created_at': DateTime.now().toIso8601String(),
        };
      }).toList();
      await supabase.from('stock_movements').insert(movements);
      for (var item in selectedProducts) {
        final productId = item['product']['id'];
        final qty = item['qty'];

        final current = await supabase
            .from('products')
            .select('stock')
            .eq('id', productId)
            .single();

        final currentStock = (current['stock'] ?? 0) as int;

        await supabase
            .from('products')
            .update({'stock': currentStock + qty})
            .eq('id', productId);
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Berhasil disimpan')));

      setState(() {
        selectedProducts.clear();
      });
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pembelian')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: futureProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final products = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  DropdownButtonFormField<Map<String, dynamic>>(
                    initialValue: selectedDropdown,
                    hint: const Text("Pilih Produk"),
                    items: products.map((product) {
                      return DropdownMenuItem(
                        value: product,
                        child: Row(
                          children: [
                            Image.network(
                              product['image_url'] ?? '',
                              width: 40,
                              height: 40,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.image_not_supported),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 150,
                              child: Text(
                                product['name'] ?? '',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        addProduct(value);
                      }
                    },
                  ),

                  const SizedBox(height: 20),

                  Column(
                    children: selectedProducts.map((item) {
                      final product = item['product'];

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Image.network(
                                product['image_url'] ?? '',
                                width: 40,
                                height: 40,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.image_not_supported),
                              ),
                              const SizedBox(width: 10),

                              Expanded(child: Text(product['name'])),

                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: () {
                                      setState(() {
                                        if (item['qty'] > 1) {
                                          item['qty']--;
                                        }
                                      });
                                    },
                                  ),
                                  Text(item['qty'].toString()),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () {
                                      setState(() {
                                        item['qty']++;
                                      });
                                    },
                                  ),
                                ],
                              ),

                              const SizedBox(width: 10),

                              Text(
                                '${item['qty'] * item['price']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    selectedProducts.remove(item);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'Total Semua: ${getGrandTotal()}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: submit,
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
