import 'package:flutter/material.dart';
import 'package:paket44/core/theme/app_colors.dart';
import 'package:paket44/core/utils/url_utils.dart';
import 'package:paket44/data/models/anggota_model.dart';
import 'anggota_detail_sheet.dart';

class AnggotaCard extends StatelessWidget {
  final AnggotaModel anggota;

  const AnggotaCard({
    super.key,
    required this.anggota,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => AnggotaDetailSheet.show(context, anggota),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black.withOpacity(0.04)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFFe0e7ff), Color(0xFFc7d2fe)]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _buildProfileImage(anggota),
              ),
            ),
            const SizedBox(width: 12),
            // Name + NIS + Kelas
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    anggota.name,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AppColors.textDark),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        'NIS: ${anggota.nis}',
                        style: TextStyle(
                            fontSize: 11, color: AppColors.textMuted),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFeef2ff),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          anggota.kelas,
                          style: const TextStyle(
                              fontSize: 9,
                              color: Color(0xFF4338ca),
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: anggota.statusAktif
                    ? const Color(0xFFD1FAE5)
                    : const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                anggota.statusAktif ? 'Aktif' : 'Nonaktif',
                style: TextStyle(
                    fontSize: 10,
                    color: anggota.statusAktif
                        ? const Color(0xFF059669)
                        : const Color(0xFFDC2626),
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage(AnggotaModel anggota) {
    if (anggota.fotoProfilUrl == null || anggota.fotoProfilUrl!.isEmpty) {
      return _buildFallbackAvatar(anggota);
    }

    if (isLocalAsset(anggota.fotoProfilUrl!)) {
      return Image.asset(anggota.fotoProfilUrl!, fit: BoxFit.cover);
    }

    if (isHttpImageUrl(anggota.fotoProfilUrl!)) {
      return Image.network(
        anggota.fotoProfilUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildFallbackAvatar(anggota),
      );
    }

    return _buildFallbackAvatar(anggota);
  }

  Widget _buildFallbackAvatar(AnggotaModel anggota) {
    return Center(
      child: Text(
        anggota.name.substring(0, 1).toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF4338ca),
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
    );
  }
}

