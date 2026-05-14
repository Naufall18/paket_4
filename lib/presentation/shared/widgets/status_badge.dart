import 'package:flutter/material.dart';

/// Reusable status badge / chip with auto-coloring based on status text.
class StatusBadge extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;

  const StatusBadge({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _resolveColors();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: colors.$2,
        ),
      ),
    );
  }

  (Color bg, Color fg) _resolveColors() {
    if (backgroundColor != null && textColor != null) {
      return (backgroundColor!, textColor!);
    }
    final lower = text.toLowerCase();
    if (lower.contains('pending') ||
        lower.contains('menunggu') ||
        lower.contains('bisa diambil')) {
      return (const Color(0xFFFEF3C7), const Color(0xFF92400E));
    }
    if (lower.contains('dipinjam') || lower.contains('sedang')) {
      return (const Color(0xFFD1FAE5), const Color(0xFF065F46));
    }
    if (lower.contains('ditolak') || lower.contains('rejected')) {
      return (const Color(0xFFFEE2E2), const Color(0xFF991B1B));
    }
    if (lower.contains('selesai') || lower.contains('dikembalikan') || lower.contains('lunas')) {
      return (const Color(0xFFF1F5F9), const Color(0xFF64748B));
    }
    return (const Color(0xFFD1FAE5), const Color(0xFF065F46));
  }
}
