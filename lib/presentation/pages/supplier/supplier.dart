import 'package:flutter/material.dart';
import 'package:tokokita/core/bucket.dart';
import 'package:tokokita/presentation/pages/pembelian/pembelian.dart';
import 'package:tokokita/presentation/pages/supplier/detail.dart';
import 'package:tokokita/presentation/pages/supplier/form.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class SupplierPage extends StatefulWidget {
  const SupplierPage({super.key});

  @override
  State<SupplierPage> createState() => _SupplierPageState();
}

class _SupplierPageState extends State<SupplierPage> {
  late Future<List<Map<String, dynamic>>> future;
  Future<List<Map<String, dynamic>>> getSuppliers() async {
    final response = await supabase
        .from('suppliers')
        .select()
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  @override
  void initState() {
    super.initState();
    future = getSuppliers();
  }

  Future<void> refresh() async {
    setState(() {
      future = getSuppliers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: SearchBar(
                    hintText: 'Cari supplier...',
                    leading: const Icon(Icons.search),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FormSupplier(),
                      ),
                    );
                  },
                  child: const Text('Tambah'),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Tidak ada supplier'));
                  } else {
                    final suppliers = snapshot.data!;
                    return ListView.builder(
                      itemCount: suppliers.length,
                      itemBuilder: (context, index) {
                        final supplier = suppliers[index];
                        return Card(
                          child: Slidable(
                            key: ValueKey(supplier['id']),
                            endActionPane: ActionPane(
                              motion: const DrawerMotion(),
                              children: [
                                // EDIT
                                SlidableAction(
                                  onPressed: (context) async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            DetailSupplier(id: supplier['id']),
                                      ),
                                    );
                                    refresh();
                                  },
                                  backgroundColor: Colors.blue,
                                  icon: Icons.edit,
                                  label: 'Detail',
                                ),
                                SlidableAction(
                                  onPressed: (context) async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PembelianPage(id: supplier['id']),
                                      ),
                                    );
                                    refresh();
                                  },
                                  backgroundColor: Colors.blue,
                                  icon: Icons.shopping_cart,
                                  label: 'Beli',
                                ),

                                // DELETE
                                SlidableAction(
                                  onPressed: (context) async {
                                    await supabase
                                        .from('suppliers')
                                        .delete()
                                        .eq('id', supplier['id']);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Supplier dihapus'),
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
                              title: Text(supplier['name']),
                              subtitle: Text(supplier['phone']),
                              trailing: const Text('Geser'),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
