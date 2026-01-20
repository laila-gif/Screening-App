import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  // Ganti dengan Cloudinary credentials Anda
  // Untuk keamanan, sebaiknya simpan di environment variables atau backend
  static const String _cloudName = 'dzuqeq5rb';
  static const String _uploadPreset = 'unsigned_upload';
  static const String _apiKey = 'YOUR_API_KEY';
  static const String _apiSecret = 'YOUR_API_SECRET';

  /// Upload image ke Cloudinary
  /// Returns URL dari gambar yang diupload
  static Future<Map<String, dynamic>> uploadImage({
    required XFile imageFile,
    String? folder,
  }) async {
    try {
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
      );

      // Baca file sebagai bytes
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Buat multipart request
      final request = http.MultipartRequest('POST', url);
      request.fields['upload_preset'] = _uploadPreset;
      request.fields['api_key'] = _apiKey;
      
      if (folder != null) {
        request.fields['folder'] = folder;
      }

      // Tambahkan file
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: imageFile.name,
        ),
      );

      // Generate signature untuk keamanan (opsional, jika menggunakan signed upload)
      // Untuk unsigned upload dengan preset, signature tidak diperlukan

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseBody);
        return {
          'success': true,
          'url': jsonResponse['secure_url'],
          'publicId': jsonResponse['public_id'],
        };
      } else {
        return {
          'success': false,
          'message': 'Gagal mengupload gambar: ${response.statusCode}',
          'error': responseBody,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }


  /// Delete image dari Cloudinary
  static Future<bool> deleteImage(String publicId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final signature = _generateDeleteSignature(publicId, timestamp);

      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudName/image/destroy',
      );

      final response = await http.post(
        url,
        body: {
          'public_id': publicId,
          'api_key': _apiKey,
          'timestamp': timestamp,
          'signature': signature,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  /// Generate signature untuk delete
  static String _generateDeleteSignature(String publicId, String timestamp) {
    final StringToSign = 'public_id=$publicId&timestamp=$timestamp$_apiSecret';
    // Implementasi hash SHA-1 atau gunakan package crypto
    // Untuk sekarang, return empty string (tidak digunakan jika unsigned)
    return '';
  }
}
