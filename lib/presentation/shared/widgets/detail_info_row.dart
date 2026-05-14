import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Row showing "icon label: value" — used in detail sheets across the app.
class DetailIconRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final double iconSize;
  final double spacing;

  const DetailIconRow({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    this.iconSize = 14,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: iconSize, color: AppColors.textMuted),
        SizedBox(width: spacing),
        Expanded(
          child: Text(
            '$label: ${value ?? "-"}',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }
}

/// Row showing "label ............. value" — used in bottom sheet details.
class DetailInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isStatus;
  final bool isError;

  const DetailInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.isStatus = false,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
          if (isStatus)
            _statusBadge()
          else
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isError ? AppColors.error : AppColors.textDark,
              ),
            ),
        ],
      ),
    );
  }

  Widget _statusBadge() {
    final lower = value.toLowerCase();
    final isPending = lower == 'dipinjam' ||
        lower == 'pending' ||
        lower == 'bisa diambil' ||
        lower == 'menunggu approval';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPending ? const Color(0xFFFEF3C7) : const Color(0xFFD1FAE5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        value,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isPending ? const Color(0xFF92400E) : const Color(0xFF065F46),
        ),
      ),
    );
  }
}

/// Key-value detail row used in member detail sheets.
class DetailKeyValueRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const DetailKeyValueRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textMuted),
        const SizedBox(width: 12),
        Text(label,
            style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }
}
