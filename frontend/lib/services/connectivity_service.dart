// connectivity_service.dart
// Checks whether the device has an active internet connection.
// Uses connectivity_plus to detect network type, then does a lightweight
// HTTP probe to confirm the connection is actually usable (not just "connected").

import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  ConnectivityService._();
  static final ConnectivityService instance = ConnectivityService._();

  /// Returns true only when:
  ///  1. connectivity_plus reports a non-none connection, AND
  ///  2. A DNS probe confirms actual internet reachability.
  Future<bool> hasInternet() async {
    try {
      // Step 1: Quick connectivity_plus check
      final results = await Connectivity().checkConnectivity();
      final hasNetwork = results.any((r) =>
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.ethernet);
      if (!hasNetwork) return false;

      // Step 2: Actual reachability probe (DNS lookup is cheap and reliable)
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
