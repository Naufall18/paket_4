import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paket44/core/theme/app_colors.dart';
import 'package:paket44/core/utils/url_utils.dart';
import '../../../../../../data/models/anggota_model.dart';
import 'package:paket44/presentation/shared/widgets/detail_info_row.dart';

/// Anggota detail bottom sheet.
class AnggotaDetailSheet {
  static void show(BuildContext context, AnggotaModel anggota) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.cardLight,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              _buildAvatar(anggota),
              const SizedBox(height: 16),
              Text(
                anggota.name,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(anggota.email,
                  style: TextStyle(fontSize: 14, color: AppColors.textMuted),
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),

              // Status badge
              _buildStatusBadge(anggota),

              // Support request
              if (!anggota.statusAktif &&
                  anggota.supportRequest != null &&
                  anggota.supportRequest!.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildSupportRequest(anggota),
              ],

              const SizedBox(height: 24),

              // Detail rows
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    DetailKeyValueRow(
                        icon: Icons.person_outline,
                        label: 'Username',
                        value: anggota.username),
                    _divider(),
                    DetailKeyValueRow(
                        icon: Icons.badge_outlined,
                        label: 'NIS',
                        value: anggota.nis),
                    _divider(),
                    DetailKeyValueRow(
                        icon: Icons.class_outlined,
                        label: 'Kelas',
                        value: anggota.kelas),
                    _divider(),
                    DetailKeyValueRow(
                        icon: Icons.phone_outlined,
                        label: 'No. Telepon',
                        value: anggota.noHp?.isNotEmpty == true
                            ? anggota.noHp!
                            : '-'),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    side: BorderSide(color: AppColors.border),
                  ),
                  child: Text('Tutup',
                      style: TextStyle(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                          fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  static Widget _buildAvatar(AnggotaModel anggota) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFFe0e7ff), Color(0xFFc7d2fe)]),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: _buildProfileImage(anggota),
      ),
    );
  }

  static Widget _buildProfileImage(AnggotaModel anggota) {
    final hasProfileUrl = anggota.fotoProfilUrl != null &&
        anggota.fotoProfilUrl!.isNotEmpty &&
        (isHttpImageUrl(anggota.fotoProfilUrl) ||
            isLocalAsset(anggota.fotoProfilUrl));

    if (!hasProfileUrl) return _buildFallbackAvatar(anggota);

    if (isLocalAsset(anggota.fotoProfilUrl)) {
      return Image.asset(anggota.fotoProfilUrl!, fit: BoxFit.cover);
    }
    return Image.network(
      anggota.fotoProfilUrl!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildFallbackAvatar(anggota),
    );
  }

  static Widget _buildFallbackAvatar(AnggotaModel anggota) {
    return Center(
      child: Text(
        anggota.name.isNotEmpty
            ? anggota.name.substring(0, 1).toUpperCase()
            : '?',
        style: TextStyle(
            color: AppColors.indigo,
            fontWeight: FontWeight.w700,
            fontSize: 18),
      ),
    );
  }

  static Widget _buildStatusBadge(AnggotaModel anggota) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: anggota.statusAktif
            ? const Color(0xFFecfdf5)
            : const Color(0xFFfff1f2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            anggota.statusAktif ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: anggota.statusAktif
                ? const Color(0xFF059669)
                : const Color(0xFFe11d48),
          ),
          const SizedBox(width: 6),
          Text(
            anggota.statusAktif ? 'Akun Aktif' : 'Akun Nonaktif',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: anggota.statusAktif
                  ? const Color(0xFF059669)
                  : const Color(0xFFe11d48),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildSupportRequest(AnggotaModel anggota) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.support_agent,
                  color: Color(0xFFDC2626), size: 20),
              const SizedBox(width: 8),
              Text(
                'Permohonan Reaktivasi',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF991B1B)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            anggota.supportRequest!,
            style: TextStyle(
                fontSize: 13, color: const Color(0xFFB91C1C), height: 1.4),
          ),
        ],
      ),
    );
  }

  static Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Divider(height: 1, color: AppColors.border),
    );
  }
}
