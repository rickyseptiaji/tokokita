import 'package:flutter/material.dart';
import 'package:tokokita/core/bucket.dart';
import 'package:tokokita/core/image_service.dart';

class FormProduk extends StatefulWidget {
  const FormProduk({super.key});

  @override
  State<FormProduk> createState() => _FormProdukState();
}

class _FormProdukState extends State<FormProduk> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final descController = TextEditingController();
  final priceController = TextEditingController();

  String? imageUrl;
  bool isUploading = false;
  bool isLoading = false;

  Future<void> pickAndUploadImage() async {
    try {
      final url = await ImageService.pickAndUpload();

      if (url == null) return;

      setState(() {
        imageUrl = url;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (imageUrl == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Upload gambar dulu')));
      return;
    }

    setState(() => isLoading = true);

    try {
      await supabase.from('products').insert({
        'name': nameController.text,
        'description': descController.text,
        'price': double.parse(priceController.text),
        'image_url': imageUrl,
      });

      Navigator.pop(context);
    } catch (e) {
      print(e);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Produk')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Produk',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Harga',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              GestureDetector(
                onTap: pickAndUploadImage,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            imageUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        )
                      : const Center(child: Text('Tap untuk upload gambar')),
                ),
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: isLoading || isUploading ? null : submit,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

}