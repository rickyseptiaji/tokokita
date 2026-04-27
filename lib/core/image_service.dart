import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:tokokita/core/bucket.dart';

class ImageService {
  static Future<String?> pickAndUpload() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return null;

    File file = File(picked.path);

    final compressed = await FlutterImageCompress.compressAndGetFile(
      file.path,
      "${file.path}_compressed.jpg",
      quality: 70,
    );

    file = File(compressed!.path);

    final size = await file.length();
    if (size > 5 * 1024 * 1024) {
      throw Exception("Ukuran gambar maksimal 5MB");
    }

    final url = await uploadImage(file);

    return url;
  }
}