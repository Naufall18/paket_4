import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class PengaturanProvider {
  String? get _token => Get.find<StorageService>().getToken();

  Map<String, String> get _headers => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $_token',
  };

  Future<Map<String, dynamic>> getSettings() async {
    try {
      final response = await http
          .get(Uri.parse('${ApiService.baseUrl}/admin/pengaturan'), headers: _headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Gagal memuat pengaturan'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi timeout: $e'};
    }
  }

  Future<Map<String, dynamic>> updateSettings(List<Map<String, dynamic>> settings) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiService.baseUrl}/admin/pengaturan'),
            headers: _headers,
            body: jsonEncode({'settings': settings}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': jsonDecode(response.body)['message'] ?? 'Gagal memperbarui pengaturan',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi timeout: $e'};
    }
  }
}
