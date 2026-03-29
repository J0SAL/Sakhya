// lib/config/app_config.dart
// ─────────────────────────────────────────────────────────────────────────────
// Single source of truth for the backend URL.
// Change backendUrl to your ngrok URL or deployed server URL.
// Example ngrok:  'https://your-ngrok-id.ngrok-free.app'
// Example remote: 'https://api.yourdomain.com'
// ─────────────────────────────────────────────────────────────────────────────

class AppConfig {
  AppConfig._();

  /// Base URL for the Sakhya sync backend.
  /// Change this to an ngrok tunnel or remote server when running on a real device.
  static const String backendUrl = 'http://192.168.0.106:5001'; // Local Wi-Fi network
  // static const String backendUrl = 'http://localhost:5001'; // iOS simulator / web
  // static const String backendUrl = 'https://xxxx.ngrok-free.app'; // ngrok
  // static const String backendUrl = 'https://api.yourdomain.com';  // production
}
