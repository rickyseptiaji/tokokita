import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

Future<String> uploadImage(File file) async {
  final fileName = DateTime.now().millisecondsSinceEpoch.toString();

  final path = 'images/$fileName.jpg';

  await supabase.storage
      .from('products')
      .upload(path, file);

  final publicUrl = supabase.storage
      .from('products')
      .getPublicUrl(path);

  return publicUrl.toString();
}