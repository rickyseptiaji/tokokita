import 'package:flutter/material.dart';
import 'package:tokokita/core/bucket.dart';

class DetailSupplier extends StatefulWidget {
  final String id;
  const DetailSupplier({super.key, required this.id});

  @override
  State<DetailSupplier> createState() => _DetailSupplierState();
}

class _DetailSupplierState extends State<DetailSupplier> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  bool isLoaded = false;
  late Future<Map<String, dynamic>> future;
  Future<Map<String, dynamic>> getSuppliers() async {
    final response = await supabase
        .from('suppliers')
        .select()
        .eq('id', widget.id)
        .single();

    return response;
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

  Future<void> updateSupplier() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await supabase
          .from('suppliers')
          .update({
            'name': nameController.text,
            'phone': phoneController.text,
            'address': addressController.text,
          })
          .eq('id', widget.id);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Berhasil diupdate')));

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Supplier')),
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
          if (!isLoaded) {
            nameController.text = data['name'] ?? '';
            phoneController.text = data['phone'] ?? '';
            addressController.text = data['address'] ?? '';
            isLoaded = true;
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Supplier',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Nomor Telepon',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: 'Alamat',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: updateSupplier,
                    child: const Text('Simpan Perubahan'),
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
