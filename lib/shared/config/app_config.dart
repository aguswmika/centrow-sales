abstract final class AppConfig {
  static const String appName = 'Centrow Sales';
  static const String appVersion = '1.0.0';
  static const bool isProd = false;
  static const String apiBaseUrl = isProd
      ? 'https://erp.nohama.id/api'
      : 'http://localhost:8000/api';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);
}
