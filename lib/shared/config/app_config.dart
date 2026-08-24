abstract final class AppConfig {
  static const String appName = 'Centrow Sales';
  static const String appVersion = '1.0.0';
  static const bool isProd = false;
  static const String apiBaseUrl = isProd
      ? 'https://erp.nohama.id/api'
      // : 'http://10.0.2.2:8000/api';
      : 'http://192.168.68.188:8001/api';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);
}
