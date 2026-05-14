import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class TransactionProvider {
  String? get _token => Get.find<StorageService>().getToken();

  Map<String, String> get _headers => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $_token',
  };

  // --- ADMIN ENDPOINTS ---

  Future<Map<String, dynamic>> getAdminDashboard({String filter = 'semua'}) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiService.baseUrl}/admin/dashboard?filter=$filter'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Gagal memuat dashboard admin'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi timeout: $e'};
    }
  }

  Future<Map<String, dynamic>> getAdminTransactions() async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiService.baseUrl}/admin/transaksi'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Gagal memuat daftar transaksi'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi timeout: $e'};
    }
  }

  Future<Map<String, dynamic>> returnBook(int transactionId, {
    String kondisiBuku = 'baik',
    String? catatanKondisi,
    int? dendaKerusakan,
    List<Map<String, dynamic>>? items,
  }) async {
    try {
      final body = <String, dynamic>{};
      
      if (items != null) {
        body['items'] = items;
      } else {
        body['kondisi_buku'] = kondisiBuku;
        if (catatanKondisi != null) body['catatan_kondisi'] = catatanKondisi;
        if (dendaKerusakan != null) body['denda_kerusakan'] = dendaKerusakan;
      }

      final response = await http
          .post(
            Uri.parse(
              '${ApiService.baseUrl}/admin/transaksi/$transactionId/kembalikan',
            ),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message':
              jsonDecode(response.body)['message'] ??
              'Gagal mengembalikan buku',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi timeout: $e'};
    }
  }

  Future<Map<String, dynamic>> payFine(int transactionId) async {
    try {
      final response = await http
          .post(
            Uri.parse(
              '${ApiService.baseUrl}/admin/transaksi/$transactionId/bayar-denda',
            ),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message':
              jsonDecode(response.body)['message'] ?? 'Gagal membayar denda',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi timeout: $e'};
    }
  }

  Future<Map<String, dynamic>> approveBorrowing(int transactionId, {
    String kondisiBuku = 'baik',
    String? catatanKondisi,
    List<Map<String, dynamic>>? items,
  }) async {
    try {
      final body = <String, dynamic>{};
      
      if (items != null) {
        body['items'] = items;
      } else {
        body['kondisi_buku'] = kondisiBuku;
        if (catatanKondisi != null) body['catatan_kondisi'] = catatanKondisi;
      }

      final response = await http
          .post(
            Uri.parse(
              '${ApiService.baseUrl}/admin/transaksi/$transactionId/approve',
            ),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message':
              jsonDecode(response.body)['message'] ??
              'Gagal menyetujui peminjaman',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi timeout: $e'};
    }
  }

  Future<Map<String, dynamic>> markAsTaken(int transactionId) async {
    try {
      final response = await http
          .post(
            Uri.parse(
              '${ApiService.baseUrl}/admin/transaksi/$transactionId/mark-taken',
            ),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message':
              jsonDecode(response.body)['message'] ??
              'Gagal menandai buku diambil',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi timeout: $e'};
    }
  }

  Future<Map<String, dynamic>> rejectBorrowing(int transactionId) async {
    try {
      final response = await http
          .post(
            Uri.parse(
              '${ApiService.baseUrl}/admin/transaksi/$transactionId/reject',
            ),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message':
              jsonDecode(response.body)['message'] ??
              'Gagal menolak peminjaman',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi timeout: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteTransaction(int transactionId) async {
    try {
      final response = await http
          .delete(
            Uri.parse(
              '${ApiService.baseUrl}/admin/transaksi/$transactionId',
            ),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message':
              jsonDecode(response.body)['message'] ??
              'Gagal menghapus transaksi',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi timeout: $e'};
    }
  }

  // --- SISWA ENDPOINTS ---

  Future<Map<String, dynamic>> getStudentDashboard() async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiService.baseUrl}/siswa/dashboard'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Gagal memuat dashboard siswa'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi timeout: $e'};
    }
  }

  Future<Map<String, dynamic>> getStudentTransactions() async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiService.baseUrl}/siswa/riwayat'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Gagal memuat riwayat peminjaman'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi timeout: $e'};
    }
  }

  Future<Map<String, dynamic>> borrowBook({
    int? bookId,
    int? durasiHari,
    int quantity = 1,
    List<Map<String, dynamic>>? items,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (items != null) {
        body['items'] = items;
      } else {
        body['items'] = [
          {'buku_id': bookId, 'quantity': quantity, 'durasi_hari': durasiHari}
        ];
      }
      
      final response = await http
          .post(
            Uri.parse('${ApiService.baseUrl}/siswa/pinjam'),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message':
              jsonDecode(response.body)['message'] ?? 'Gagal meminjam buku',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi timeout: $e'};
    }
  }

  Future<Map<String, dynamic>> returnBookSiswa(int transactionId) async {
    try {
      final response = await http
          .post(
            Uri.parse(
              '${ApiService.baseUrl}/siswa/transaksi/$transactionId/kembalikan',
            ),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message':
              jsonDecode(response.body)['message'] ??
              'Gagal mengembalikan buku',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi timeout: $e'};
    }
  }

  /// Return a single item from a transaction (per-book return)
  Future<Map<String, dynamic>> returnTransactionItem(
    int transactionId,
    int itemId,
  ) async {
    try {
      final body = <String, dynamic>{
        'item_id': itemId,
        'kondisi_buku': 'baik',
      };

      final response = await http
          .post(
            Uri.parse(
              '${ApiService.baseUrl}/siswa/transaksi/$transactionId/item/$itemId/kembalikan',
            ),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message':
              jsonDecode(response.body)['message'] ??
              'Gagal mengembalikan item',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi timeout: $e'};
    }
  }

  /// Confirm pickup of approved transaction (status: pending → diambil)
  Future<Map<String, dynamic>> confirmPickup(int transactionId) async {
    try {
      final response = await http
          .post(
            Uri.parse(
              '${ApiService.baseUrl}/admin/transaksi/$transactionId/confirm-pickup',
            ),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message':
              jsonDecode(response.body)['message'] ??
              'Gagal confirm pickup',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi timeout: $e'};
    }
  }

  /// Student confirm pickup (sets status to dipinjam)
  Future<Map<String, dynamic>> studentConfirmPickup(int transactionId) async {
    try {
      final response = await http
          .post(
            Uri.parse(
              '${ApiService.baseUrl}/siswa/transaksi/$transactionId/confirm-pickup',
            ),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message':
              jsonDecode(response.body)['message'] ??
              'Gagal confirm pickup',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi timeout: $e'};
    }
  }
}
