import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AnggotaProvider {
  String? get _token => Get.find<StorageService>().getToken();

  Map<String, String> get _headers => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $_token',
  };

  Future<Map<String, dynamic>> getAnggotas({
    String? search,
    String? kelas,
    String? jurusan,
  }) async {
    try {
      String url = '${ApiService.baseUrl}/admin/anggota';
      List<String> queryParams = [];

      if (search != null && search.isNotEmpty) {
        queryParams.add('search=$search');
      }
      if (kelas != null && kelas.isNotEmpty) {
        queryParams.add('kelas=$kelas');
      }
      if (jurusan != null && jurusan.isNotEmpty) {
        queryParams.add('jurusan=$jurusan');
      }

      if (queryParams.isNotEmpty) {
        url += '?${queryParams.join('&')}';
      }

      final response = await http
          .get(Uri.parse(url), headers: _headers)
          .timeout(const Duration(seconds: 10));

      print('GET ANGGOTA RESPONSE: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Gagal memuat data anggota'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi timeout: $e'};
    }
  }

  Future<Map<String, dynamic>> addAnggota(Map<String, dynamic> data) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiService.baseUrl}/admin/anggota'),
            headers: _headers,
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message':
              jsonDecode(response.body)['message'] ?? 'Gagal menambah anggota',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi timeout: $e'};
    }
  }

  Future<Map<String, dynamic>> updateAnggota(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http
          .put(
            Uri.parse('${ApiService.baseUrl}/admin/anggota/$id'),
            headers: _headers,
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message':
              jsonDecode(response.body)['message'] ??
              'Gagal memperbarui anggota',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi timeout: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteAnggota(int id) async {
    try {
      final response = await http
          .delete(
            Uri.parse('${ApiService.baseUrl}/admin/anggota/$id'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message':
              jsonDecode(response.body)['message'] ?? 'Gagal menghapus anggota',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi timeout: $e'};
    }
  }

  Future<Map<String, dynamic>> toggleAnggotaStatus(int id) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiService.baseUrl}/admin/anggota/$id/toggle-status'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message':
              jsonDecode(response.body)['message'] ?? 'Gagal mengubah status anggota',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi timeout: $e'};
    }
  }
}
