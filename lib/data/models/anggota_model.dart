class AnggotaModel {
  final int id;
  final String name;
  final String username;
  final String email;
  final String role;
  final String nis;
  final String kelas;
  final String? noHp;
  final String noAnggota;
  final String? fotoProfilUrl;
  final bool statusAktif;
  final String? supportRequest;

  AnggotaModel({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.role,
    required this.nis,
    required this.kelas,
    this.noHp,
    required this.noAnggota,
    this.fotoProfilUrl,
    required this.statusAktif,
    this.supportRequest,
  });

  factory AnggotaModel.fromJson(Map<String, dynamic> json) {
    return AnggotaModel(
      id: json['id'],
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'siswa',
      nis: json['nis'] ?? '',
      kelas: json['kelas'] ?? '',
      noHp: json['no_hp'],
      noAnggota: json['no_anggota'] ?? '',
      fotoProfilUrl: json['foto_profil_url'],
      statusAktif: json['status_aktif'] == 1 || json['status_aktif'] == true,
      supportRequest: json['support_request'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'role': role,
      'nis': nis,
      'kelas': kelas,
      'no_hp': noHp,
      'no_anggota': noAnggota,
      'foto_profil_url': fotoProfilUrl,
      'status_aktif': statusAktif,
      'support_request': supportRequest,
    };
  }
}
