// Temporary helpers for fixing personalized course issues during development.
import 'package:flutter/material.dart';

/// Returns a safe onPressed callback that shows a SnackBar informing the user
/// that a feature is temporarily disabled.
VoidCallback safeDisabledCallback(BuildContext context,
    {String message = 'Feature temporarily disabled'}) {
  return () {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  };
}

// Keep this file minimal and import where you need a placeholder action.
