import 'package:flutter/material.dart';

/// Returns a widget that attempts to load a network image and falls back to
/// an asset or colored placeholder on error. Use this instead of using
/// `Image.network` directly when running on environments that may block DNS.
Widget safeNetworkImage(String url,
    {double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    String? assetFallback}) {
  return Image.network(
    url,
    width: width,
    height: height,
    fit: fit,
    errorBuilder: (context, error, stackTrace) {
      if (assetFallback != null && assetFallback.isNotEmpty) {
        return Image.asset(assetFallback,
            width: width, height: height, fit: fit);
      }
      return Container(
        width: width,
        height: height,
        color: const Color(0xFFEDEFF5),
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image, color: Color(0xFF9AA4B2)),
      );
    },
  );
}
