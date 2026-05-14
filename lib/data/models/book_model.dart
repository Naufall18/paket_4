import '../services/api_service.dart';

class BookModel {
  final int id;
  final String judul;
  final String pengarang;
  final String penerbit;
  final String tahun;
  final String kategori;
  final int stok;
  final String? deskripsi;
  final String? cover;
  final String? coverUrl; // Full URL from API (cover_url)
  final String? lokasiRak; // New field

  BookModel({
    required this.id,
    required this.judul,
    required this.pengarang,
    required this.penerbit,
    required this.tahun,
    required this.kategori,
    required this.stok,
    this.deskripsi,
    this.cover,
    this.coverUrl,
    this.lokasiRak,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      judul: json['judul']?.toString() ?? '',
      pengarang: json['pengarang']?.toString() ?? '',
      penerbit: json['penerbit']?.toString() ?? '',
      tahun: json['tahun']?.toString() ?? '',
      kategori: json['kategori']?.toString() ?? '',
      deskripsi: json['deskripsi']?.toString(),
      lokasiRak: json['lokasi_rak']?.toString(),
      stok: json['stok'] is int
          ? json['stok']
          : int.tryParse(json['stok'].toString()) ?? 0,
      cover: json['cover']?.toString(),
      // cover_url returned by API should already be a full URL. If not,
      // fall back to building one from the `cover` path. Previously the
      // base URL was used which added the `/api` segment and produced
      // URLs like `http://.../api/storage/...` causing the server to return
      // an HTML error page. `Image.network` tried to decode that and
      // generated the "unimplemented Input contained an error" exception.
      //
      // Use `storageUrl` (no `/api`) and only assign valid absolute URLs to
      // avoid repeatedly recreating decoders for bad inputs.
      coverUrl: (() {
        String? raw = json['cover_url']?.toString();
        if (raw != null && raw.isNotEmpty) {
          // ensure we return something with a proper scheme or asset path
          if (raw.startsWith('http') || raw.startsWith('assets/')) return raw;
        }
        final dynamic coverField = json['cover'];
        if (coverField != null && coverField.toString().isNotEmpty) {
          final candidate = coverField.toString();
          if (candidate.startsWith('http') || candidate.startsWith('assets/')) {
            return candidate;
          }
          // build from storage URL
          return '${ApiService.storageUrl}/$candidate';
        }
        return null;
      })(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'pengarang': pengarang,
      'penerbit': penerbit,
      'tahun': tahun,
      'kategori': kategori,
      'deskripsi': deskripsi,
      'lokasi_rak': lokasiRak,
      'stok': stok,
      'cover': cover,
      'cover_url': coverUrl,
    };
  }
}
