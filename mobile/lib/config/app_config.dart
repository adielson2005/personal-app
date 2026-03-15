// Configurações da API
class AppConfig {
  // URL base da API.
  // Em producao (Netlify), defina no build:
  // --dart-define=API_BASE_URL=https://seu-backend.com/api
  static const String _apiBaseUrlFromEnv = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api',
  );

  static String get baseUrl {
    return _apiBaseUrlFromEnv.endsWith('/')
        ? _apiBaseUrlFromEnv.substring(0, _apiBaseUrlFromEnv.length - 1)
        : _apiBaseUrlFromEnv;
  }

  // Timeouts
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;

  // App Info
  static const String appName = 'Personal Trainer';
  static const String appVersion = '1.0.0';
}
