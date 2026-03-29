// sync_service.dart
// Fire-and-forget sync to the Sakhya online backend.
// All calls are:
//   • Guarded by ConnectivityService — skipped immediately if offline.
//   • Wrapped in try/catch — exceptions are silently logged, never thrown.
//   • Subject to a 5 s HTTP timeout — server slowness won't block the UI.

import 'dart:convert';
import 'dart:developer' as dev;

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/day_summary.dart';
import '../models/user_profile.dart';
import 'connectivity_service.dart';

class SyncService {
  SyncService._();
  static final SyncService instance = SyncService._();

  static const _timeout = Duration(seconds: 5);
  static final _baseUri = Uri.parse(AppConfig.backendUrl);

  /// Sync a UserProfile to the online backend.
  /// Returns silently on no internet or any error.
  Future<void> syncUser(UserProfile user) async {
    await _trySend(
      path: '/sync/user',
      body: user.toJson(),
      label: 'syncUser(${user.id})',
    );
  }

  /// Sync a DaySummary to the online backend.
  /// Adds [userId] to the payload (backend needs it as foreign key).
  Future<void> syncSummary(String userId, DaySummary summary) async {
    final body = summary.toJson()..['userId'] = userId;
    await _trySend(
      path: '/sync/summary',
      body: body,
      label: 'syncSummary($userId / ${summary.date})',
    );
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  Future<void> _trySend({
    required String path,
    required Map<String, dynamic> body,
    required String label,
  }) async {
    // 1. Skip immediately when offline — no UI disruption
    final online = await ConnectivityService.instance.hasInternet();
    if (!online) {
      dev.log('[$label] Skipped — no internet', name: 'SyncService');
      return;
    }

    // 2. POST with timeout — any failure is caught and logged only
    try {
      final uri = _baseUri.replace(path: path);
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        dev.log('[$label] ✅ Synced', name: 'SyncService');
      } else {
        dev.log('[$label] ⚠️ HTTP ${response.statusCode}', name: 'SyncService');
      }
    } catch (e) {
      // Network errors, timeouts, server errors — none of these should
      // ever surface to the user. Log and move on.
      dev.log('[$label] ❌ Error: $e', name: 'SyncService');
    }
  }
}
