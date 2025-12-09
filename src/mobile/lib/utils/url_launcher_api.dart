import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:android_intent_plus/android_intent.dart';

/// Attempts to open [urlStr] in an external application (browser).
/// Strategy:
/// 1. Try `launchUrl`.
/// 2. If that fails, try `launchUrlString`.
/// 3. If still failing and on Android, try an explicit Android intent.
/// 4. Otherwise return false so caller can show fallback UI.
Future<bool> openExternalUrl(BuildContext context, String urlStr) async {
  final uri = Uri.tryParse(urlStr);
  if (uri == null) return false;

  // 1) Primary attempt using launchUrl
  try {
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (launched) return true;
  } catch (_) {}

  // 2) Try older `launch` as an alternative (some url_launcher versions)
  try {
    final launched2 = await launch(urlStr);
    if (launched2 == true) return true;
  } catch (_) {}

  // 3) Android explicit intent fallback
  String? lastErr;
  try {
    if (Platform.isAndroid) {
      final intent = AndroidIntent(
        action: 'action_view',
        data: urlStr,
      );
      await intent.launch();
      return true;
    }
  } catch (e) {
    lastErr = e.toString();
  }

  // If we reach here, no method succeeded — surface a helpful error
  final message = lastErr ?? 'No available handler for opening the URL.';
  throw Exception(message);
}
