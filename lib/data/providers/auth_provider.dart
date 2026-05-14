import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

class AuthProvider {
  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = '${ApiService.baseUrl}/login';
    print('DEBUG LOGIN → URL: $url');
    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'username': username, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));

      print('DEBUG LOGIN → Status: ${response.statusCode}');
      print('DEBUG LOGIN → Body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': jsonDecode(response.body)['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      print('DEBUG LOGIN → ERROR: $e');
      return {'success': false, 'message': 'Terjadi kesalahan sistem: $e'};
    }
  }

  Future<Map<String, dynamic>> register(
    String name,
    String username,
    String email,
    String password,
    String nis,
    String kelas, {
    String? noHp,
    String? adminCode,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiService.baseUrl}/register'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'name': name,
              'username': username,
              'email': email,
              'password': password,
              'password_confirmation': password,
              'nis': nis,
              'kelas': kelas,
              'no_hp': noHp ?? '',
              if (adminCode != null && adminCode.isNotEmpty)
                'admin_code': adminCode,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message':
              jsonDecode(response.body)['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan koneksi: $e'};
    }
  }

  Future<Map<String, dynamic>> updateProfile(
    String token,
    String? name,
    String? username,
    String? email,
    String? noHp,
    String? password,
    String? imagePath,
  ) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiService.baseUrl}/profile/update'),
      );
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      if (name != null) request.fields['name'] = name;
      if (username != null) request.fields['username'] = username;
      if (email != null) request.fields['email'] = email;
      if (noHp != null) request.fields['no_hp'] = noHp;
      if (password != null && password.isNotEmpty)
        request.fields['password'] = password;

      if (imagePath != null && imagePath.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath('foto_profil', imagePath),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        var errorBody = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorBody['message'] ?? 'Gagal memperbarui profil',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan sistem: $e'};
    }
  }

  Future<Map<String, dynamic>> sendOtp(String token, String noHp) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiService.baseUrl}/send-otp'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'no_hp': noHp}),
          )
          .timeout(const Duration(seconds: 10));

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server: $e'};
    }
  }

  Future<Map<String, dynamic>> verifyOtp(
    String token,
    String noHp,
    String otp,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiService.baseUrl}/verify-otp'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'no_hp': noHp, 'otp': otp}),
          )
          .timeout(const Duration(seconds: 10));

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server: $e'};
    }
  }

  Future<Map<String, dynamic>> submitSupportRequest(String username, String message) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/support-request'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'username_or_nis': username, 'message': message}),
      ).timeout(const Duration(seconds: 10));

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server: $e'};
    }
  }

  Future<Map<String, dynamic>> sendResetOtp(String noHp) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/send-reset-otp'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'no_hp': noHp}),
      ).timeout(const Duration(seconds: 10));

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server: $e'};
    }
  }

  Future<Map<String, dynamic>> verifyResetOtp(String noHp, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/verify-reset-otp'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'no_hp': noHp, 'otp': otp}),
      ).timeout(const Duration(seconds: 10));

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server: $e'};
    }
  }

  Future<Map<String, dynamic>> resetPassword(String noHp, String otp, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/reset-password'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'no_hp': noHp,
          'otp': otp,
          'password': newPassword,
          'password_confirmation': newPassword,
        }),
      ).timeout(const Duration(seconds: 10));

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server: $e'};
    }
  }
}
