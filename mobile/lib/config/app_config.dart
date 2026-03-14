// Configurações da API
class AppConfig {
  // URL base da API - altere para o IP do seu servidor
  // static const String baseUrl = 'http://10.0.2.2:3000/api'; // Para emulador Android
  static const String baseUrl = 'http://localhost:3000/api'; // Para Chrome/Web e iOS simulator
  // static const String baseUrl = 'http://SEU_IP:3000/api'; // Para dispositivo físico

  // Timeouts
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;

  // App Info
  static const String appName = 'Personal Trainer';
  static const String appVersion = '1.0.0';
}
