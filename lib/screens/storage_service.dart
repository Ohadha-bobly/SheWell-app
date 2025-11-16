import 'dart:io';
import 'package:mime/mime.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final supabase = Supabase.instance.client;

  /// Upload a file to Supabase Storage
  Future<String?> uploadFile({
    required File file,
    required String bucket,
  }) async {
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();

      final mimeType = lookupMimeType(file.path);

      final response = await supabase.storage.from(bucket).upload(
            fileName,
            file,
            fileOptions: FileOptions(contentType: mimeType),
          );

      if (response.isEmpty) {
        return null;
      }

      // Return PUBLIC URL
      return supabase.storage.from(bucket).getPublicUrl(fileName);
    } catch (e) {
      print("Upload error: $e");
      return null;
    }
  }
}
