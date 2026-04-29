import 'package:flutter/material.dart';
import 'package:tokokita/core/bucket.dart';
import 'package:tokokita/core/image_service.dart';

class DetailProduk extends StatefulWidget {
  final String id;
  const DetailProduk({super.key, required this.id});

  @override
  State<DetailProduk> createState() => _DetailProdukState();
}

class _DetailProdukState extends State<DetailProduk> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descController = TextEditingController();
  final priceController = TextEditingController();

  String? imageUrl;
  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    fetchProduct();
  }

  Future<void> fetchProduct() async {
    try {
      final data = await supabase
          .from('products')
          .select()
          .eq('id', widget.id)
          .single();

      nameController.text = data['name'] ?? '';
      descController.text = data['description'] ?? '';
      priceController.text = data['price'].toString();
      imageUrl = data['image_url'];

      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal load data: $e')),
      );
    }
  }

  Future<void> pickAndUploadImage() async {
    try {
      final url = await ImageService.pickAndUpload();
      if (url == null) return;

      setState(() {
        imageUrl = url;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> updateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gambar wajib ada')),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      await supabase.from('products').update({
        'name': nameController.text,
        'description': descController.text,
        'price': double.parse(priceController.text),
        'image_url': imageUrl,
      }).eq('id', widget.id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berhasil diupdate')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal update: $e')),
      );
    } finally {
      setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Produk')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    GestureDetector(
                      onTap: pickAndUploadImage,
                      child: Container(
                        height: 180,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: imageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  imageUrl!,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Center(
                                child: Text('Tap untuk upload gambar'),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Produk',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v!.isEmpty ? 'Nama wajib diisi' : null,
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: descController,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Harga',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v!.isEmpty ? 'Harga wajib diisi' : null,
                    ),

                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: isSaving ? null : updateProduct,
                      child: isSaving
                          ? const CircularProgressIndicator()
                          : const Text('Update Produk'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}