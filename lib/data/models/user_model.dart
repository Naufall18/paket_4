import '../services/api_service.dart';

class UserModel {
  int? id;
  String? name;
  String? username;
  String? email;
  String? role;
  String? noHp;
  String? fotoProfilUrl;
  String? nis; // added for student identifier
  String? kelas; // student class

  UserModel({
    this.id,
    this.name,
    this.username,
    this.email,
    this.role,
    this.noHp,
    this.fotoProfilUrl,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] is int ? json['id'] : int.tryParse(json['id'].toString());
    name = json['name']?.toString();
    username = json['username']?.toString();
    email = json['email']?.toString();
    role = json['role']?.toString();
    noHp = json['no_hp']?.toString();

    // Parse image
    if (json['foto_profil_url'] != null &&
        json['foto_profil_url'].toString().isNotEmpty) {
      final raw = json['foto_profil_url'].toString();
      // allow network URLs or local asset paths
      if (raw.startsWith('http') || raw.startsWith('assets/')) {
        fotoProfilUrl = raw;
      } else {
        fotoProfilUrl =
            '${ApiService.storageUrl}/${raw.replaceFirst('http://localhost:8000/storage/', '')}';
      }
    } else if (json['foto_profil'] != null &&
        json['foto_profil'].toString().isNotEmpty) {
      fotoProfilUrl = '${ApiService.storageUrl}/${json['foto_profil']}';
    }
    // parse nis if available
    if (json['nis'] != null && json['nis'].toString().isNotEmpty) {
      nis = json['nis'].toString();
    }
    // parse kelas if available
    if (json['kelas'] != null && json['kelas'].toString().isNotEmpty) {
      kelas = json['kelas'].toString();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['username'] = username;
    data['email'] = email;
    data['role'] = role;
    data['no_hp'] = noHp;
    data['foto_profil_url'] = fotoProfilUrl;
    data['nis'] = nis;
    data['kelas'] = kelas;
    return data;
  }
}
