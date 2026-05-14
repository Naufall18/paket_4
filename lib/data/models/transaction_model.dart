import 'package:intl/intl.dart';
import 'book_model.dart';
import 'user_model.dart';

/// Represents one line item in a borrowing transaction. Can be multiple copies of a book.
class TransactionItem {
  final int id;
  final int bukuId;
  final int quantity;
  final BookModel? book;

  final int? durasiHari;
  final String? kondisiBuku;
  final String? catatanKondisi;
  final String? statusBayarDenda;
  final String? status;
  final String? tglKembaliRencana;
  final String? tglKembaliAktual;
  final int denda;

  TransactionItem({
    required this.id,
    required this.bukuId,
    this.quantity = 1,
    this.book,
    this.durasiHari,
    this.kondisiBuku,
    this.catatanKondisi,
    this.statusBayarDenda,
    this.status,
    this.tglKembaliRencana,
    this.tglKembaliAktual,
    this.denda = 0,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      id: json['id'] is int
          ? json['id']
          : (json['item_id'] is int
              ? json['item_id']
              : int.tryParse(json['id']?.toString() ?? json['item_id']?.toString() ?? '0') ?? 0),
      bukuId: json['buku_id'] is int
          ? json['buku_id']
          : int.tryParse(json['buku_id']?.toString() ?? '0') ?? 0,
      quantity: json['quantity'] != null 
          ? (json['quantity'] is int ? json['quantity'] : int.tryParse(json['quantity'].toString()) ?? 1)
          : (json['jumlah'] is int ? json['jumlah'] : int.tryParse(json['jumlah']?.toString() ?? '1') ?? 1),
      book: json['buku'] != null ? BookModel.fromJson(json['buku']) : null,
      durasiHari: json['durasi_hari'] != null ? (json['durasi_hari'] is int ? json['durasi_hari'] : int.tryParse(json['durasi_hari'].toString())) : null,
      kondisiBuku: json['kondisi_buku']?.toString(),
      catatanKondisi: json['catatan_kondisi']?.toString(),
      statusBayarDenda: json['status_bayar_denda']?.toString(),
      status: json['status']?.toString(),
      tglKembaliRencana: json['tgl_kembali_rencana']?.toString(),
      tglKembaliAktual: json['tgl_kembali_aktual']?.toString(),
      denda: json['denda'] != null ? (json['denda'] is int ? json['denda'] : int.tryParse(json['denda'].toString()) ?? 0) : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buku_id': bukuId,
      'quantity': quantity,
      'buku': book?.toJson(),
      'durasi_hari': durasiHari,
      'kondisi_buku': kondisiBuku,
      'catatan_kondisi': catatanKondisi,
      'status_bayar_denda': statusBayarDenda,
      'status': status,
      'tgl_kembali_rencana': tglKembaliRencana,
      'tgl_kembali_aktual': tglKembaliAktual,
      'denda': denda,
    };
  }
}

class TransactionModel {
  final int id;
  final String? kodeTransaksi;
  final int userId;
  // kept for backward compatibility, but preferentially use items list
  final int bukuId;
  final String tanggalPinjam;
  final String? tanggalKembali;
  final String? tanggalKembaliAktual;
  final String status; // 'dipinjam', 'dikembalikan', 'terlambat'
  final String statusApproval; // 'pending', 'approved', 'rejected'
  final int denda;
  final int durasiHari;
  final String kondisiBuku; // 'baik', 'rusak_ringan', 'rusak_berat', 'hilang'
  final String? catatanKondisi;
  final int dendaKerusakan;
  final String statusBayarDenda; // 'belum_bayar', 'lunas'
  final String createdAt;
  final BookModel? book;
  final UserModel? user;
  final List<TransactionItem> items;
  final String? rawCreatedAt;

  TransactionModel({
    required this.id,
    this.kodeTransaksi,
    required this.userId,
    required this.bukuId,
    required this.tanggalPinjam,
    this.tanggalKembali,
    this.tanggalKembaliAktual,
    required this.status,
    required this.statusApproval,
    required this.denda,
    required this.durasiHari,
    required this.kondisiBuku,
    this.catatanKondisi,
    required this.dendaKerusakan,
    required this.statusBayarDenda,
    required this.createdAt,
    this.book,
    this.user,
    this.items = const [],
    this.rawCreatedAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    String formatTanggal(String? rawDate) {
      if (rawDate == null || rawDate.isEmpty) return '';
      try {
        DateTime parsedDate = DateTime.parse(rawDate);
        return DateFormat('dd MMMM yyyy', 'id_ID').format(parsedDate);
      } catch (e) {
        return rawDate;
      }
    }

    return TransactionModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      kodeTransaksi: json['kode_transaksi']?.toString() ?? 'TRX-${json['id']}',
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse(json['user_id'].toString()) ?? 0,
      bukuId: json['buku_id'] is int
          ? json['buku_id']
          : int.tryParse(json['buku_id'].toString()) ?? 0,
      tanggalPinjam: formatTanggal(
        json['tgl_pinjam'] ?? json['tanggal_pinjam'],
      ),
      tanggalKembali: formatTanggal(
        json['tgl_kembali_rencana'] ?? json['tanggal_kembali'],
      ),
      tanggalKembaliAktual: formatTanggal(json['tgl_kembali_aktual']),
      status: json['status'] ?? 'dipinjam',
      statusApproval: json['status_approval'] ?? 'pending',
      denda: json['denda'] != null
          ? int.tryParse(json['denda'].toString()) ?? 0
          : 0,
      durasiHari: json['durasi_hari'] != null
          ? int.tryParse(json['durasi_hari'].toString()) ?? 7
          : 7,
      kondisiBuku: json['kondisi_buku'] ?? 'baik',
      catatanKondisi: json['catatan_kondisi'],
      dendaKerusakan: json['denda_kerusakan'] != null
          ? int.tryParse(json['denda_kerusakan'].toString()) ?? 0
          : 0,
      statusBayarDenda: json['status_bayar_denda']?.toString() ?? 'belum_bayar',
      createdAt: formatTanggal(json['created_at']),
      book: json['buku'] != null ? BookModel.fromJson(json['buku']) : null,
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      items: json['items'] != null
          ? (json['items'] as List)
              .map((e) => TransactionItem.fromJson(e))
              .toList()
          : [
              TransactionItem(
                id: json['id'] is int
                    ? json['id']
                    : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
                bukuId: json['buku_id'] is int
                    ? json['buku_id']
                    : int.tryParse(json['buku_id']?.toString() ?? '0') ?? 0,
                quantity: json['quantity'] != null 
                    ? (json['quantity'] is int ? json['quantity'] : int.tryParse(json['quantity'].toString()) ?? 1)
                    : (json['jumlah'] is int ? json['jumlah'] : int.tryParse(json['jumlah']?.toString() ?? '1') ?? 1),
                book: json['buku'] != null ? BookModel.fromJson(json['buku']) : null,
                durasiHari: json['durasi_hari'] != null ? (json['durasi_hari'] is int ? json['durasi_hari'] : int.tryParse(json['durasi_hari'].toString())) : null,
              )
            ],
      rawCreatedAt: json['created_at'],
    );
  }

  /// Display-friendly status that considers both status_approval and status
  String get displayStatus {
    if (statusApproval == 'pending') return 'Menunggu Approval';
    if (statusApproval == 'rejected') return 'Ditolak';
    if (statusApproval == 'approved' && status == 'pending') return 'Disetujui / Bisa Diambil';
    if (status == 'dipinjam') return 'Sedang Dipinjam';
    if (status == 'dikembalikan') return 'Dikembalikan / Selesai';
    if (status == 'terlambat') return 'Terlambat';
    return status;
  }

  /// Display-friendly kondisi buku
  String get displayKondisi {
    switch (kondisiBuku) {
      case 'baik': return 'Baik';
      case 'rusak_ringan': return 'Rusak Ringan';
      case 'rusak_berat': return 'Rusak Berat';
      case 'hilang': return 'Hilang';
      default: return kondisiBuku;
    }
  }

  /// Explains the reason for the fine
  String get fineReason {
    if (denda <= 0) return '';
    
    List<String> reasons = [];
    
    // Check for lateness
    if (status == 'terlambat' || (tanggalKembaliAktual != null && status == 'dikembalikan')) {
      // we don't have hari_terlambat field in model yet but we can infer or just say "Keterlambatan"
      reasons.add('Keterlambatan Peminjaman');
    }
    
    // Check for damage
    if (dendaKerusakan > 0) {
      reasons.add('Kondisi Buku: ${displayKondisi}');
    }
    
    if (reasons.isEmpty && denda > 0) {
      return 'Denda Peminjaman';
    }
    
    return reasons.join(' & ');
  }

  int get totalDenda => denda;

  /// total number of books included (summing quantities)
  int get totalBooks => items.fold(0, (sum, it) => sum + it.quantity);

  /// convenience: primary book/title for single‑book transactions
  String get primaryBookTitle =>
      items.isNotEmpty ? (items.first.book?.judul ?? '') : '';

  /// convenience: primary book cover for single-book transactions
  String? get primaryBookCoverUrl =>
      items.isNotEmpty ? items.first.book?.coverUrl : book?.coverUrl;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'buku_id': bukuId,
      'tanggal_pinjam': tanggalPinjam,
      'tanggal_kembali': tanggalKembali,
      'tanggal_kembali_aktual': tanggalKembaliAktual,
      'status': status,
      'status_approval': statusApproval,
      'denda': denda,
      'durasi_hari': durasiHari,
      'kondisi_buku': kondisiBuku,
      'catatan_kondisi': catatanKondisi,
      'denda_kerusakan': dendaKerusakan,
      'status_bayar_denda': statusBayarDenda,
      'buku': book?.toJson(),
      'user': user?.toJson(),
      'items': items.map((i) => i.toJson()).toList(),
    };
  }
}
