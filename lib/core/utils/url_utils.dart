// Utility helpers for working with URLs.
//
// This file is used by UI code and therefore needs Flutter imports so that
// types like [Widget], [BoxFit], [Image], and [Icon] are available.
import 'package:flutter/material.dart';

bool isHttpImageUrl(String? url) {
  if (url == null) return false;
  final lower = url.toLowerCase().trim();
  if (!lower.startsWith('http')) return false;
  
  // Strip query parameters to check the true extension
  final uri = Uri.tryParse(lower);
  final path = uri?.path ?? lower;
  
  return path.endsWith('.png') ||
      path.endsWith('.jpg') ||
      path.endsWith('.jpeg') ||
      path.endsWith('.gif') ||
      path.endsWith('.webp');
}

/// Returns true when the string refers to a local asset path.
bool isLocalAsset(String? url) {
  if (url == null) return false;
  return url.trim().startsWith('assets/');
}

/// Attempts to create a widget for a book cover.
///
/// - If [url] points to a local asset (checked by [isLocalAsset]) an
///   [Image.asset] is returned.
/// - Otherwise if [url] looks like an http image ([isHttpImageUrl]) we try
///   [Image.network] and fall back to an icon on error.  A debug message is
///   printed which includes [context] if provided.
/// - Finally, a placeholder icon is shown when [url] is null or doesn't match
///   either rule.
Widget coverFromUrl(String? url,
    {BoxFit fit = BoxFit.cover, String? context}) {
  if (isLocalAsset(url)) {
    return Image.asset(
      url!,
      fit: fit,
    );
  }
  if (isHttpImageUrl(url)) {
    return Image.network(
      url!,
      fit: fit,
      errorBuilder: (c, error, stack) {
        final label = context != null ? '$context image error' : 'image error';
        print('$label: $url -> $error');
        return const Icon(Icons.image);
      },
    );
  }
  return const Icon(Icons.image);
}
