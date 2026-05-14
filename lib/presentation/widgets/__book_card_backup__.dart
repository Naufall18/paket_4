// backup of original BookCard before adding safer network image handling
// This file is for backup purposes only and not used by the app.
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/glassmorphism.dart';

class BookCardOriginal extends StatelessWidget {
  final String title;
  final String author;
  final String? imageUrl;
  final String? subtitle;
  final Color? subtitleColor;
  final Widget actionWidget;

  const BookCardOriginal({
    super.key,
    required this.title,
    required this.author,
    this.imageUrl,
    this.subtitle,
    this.subtitleColor,
    required this.actionWidget,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                color: AppColors.darkSlate,
                child: imageUrl != null && imageUrl!.isNotEmpty
                    ? Image.network(imageUrl!, fit: BoxFit.cover)
                    : Icon(Icons.image, size: 50, color: AppColors.textMuted),
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            author,
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null) ...[
            SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 12,
                color: subtitleColor ?? AppColors.success,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          SizedBox(height: 8),
          actionWidget,
        ],
      ),
    );
  }
}
