import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class BookProvider {
  String? get _token => Get.find<StorageService>().getToken();

  Map<String, String> get _headers => {
    'Accept': 'application/json',
    'Authorization': 'Bearer $_token',
  };

  Future<Map<String, dynamic>> getBooks() async {
    try {
      final response = await http
          .get(Uri.parse('${ApiService.baseUrl}/buku'), headers: _headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Gagal memuat daftar buku'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi timeout: $e'};
    }
  }

  Future<Map<String, dynamic>> getBook(int id) async {
    try {
      final response = await http
          .get(Uri.parse('${ApiService.baseUrl}/buku/$id'), headers: _headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Gagal memuat detail buku'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi timeout: $e'};
    }
  }

  Future<Map<String, dynamic>> addBook(
    Map<String, String> data,
    XFile? image,
  ) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiService.baseUrl}/buku'),
    );
    request.headers.addAll(_headers);

    request.fields.addAll(data);

    if (image != null) {
      if (kIsWeb) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'cover',
            await image.readAsBytes(),
            filename: image.name,
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath('cover', image.path),
        );
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      return {
        'success': false,
        'message':
            jsonDecode(response.body)['message'] ?? 'Gagal menambahkan buku',
      };
    }
  }

  Future<Map<String, dynamic>> updateBook(
    int id,
    Map<String, String> data,
    XFile? image,
  ) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiService.baseUrl}/buku/$id'),
    );
    request.headers.addAll(_headers);

    request.fields.addAll(data);

    if (image != null) {
      if (kIsWeb) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'cover',
            await image.readAsBytes(),
            filename: image.name,
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath('cover', image.path),
        );
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      return {
        'success': false,
        'message':
            jsonDecode(response.body)['message'] ?? 'Gagal memperbarui buku',
      };
    }
  }

  Future<Map<String, dynamic>> deleteBook(int id) async {
    try {
      final response = await http
          .delete(
            Uri.parse('${ApiService.baseUrl}/buku/$id'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Gagal menghapus buku'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi timeout: $e'};
    }
  }
}
