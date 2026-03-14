import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';

  // Obter token salvo
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Salvar token
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // Remover token
  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // Headers padrão
  static Future<Map<String, String>> _getHeaders({bool withAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (withAuth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // GET request
  static Future<Map<String, dynamic>> get(
    String endpoint, {
    bool withAuth = true,
    Map<String, String>? queryParams,
  }) async {
    try {
      var uri = Uri.parse('${AppConfig.baseUrl}$endpoint');
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http.get(
        uri,
        headers: await _getHeaders(withAuth: withAuth),
      ).timeout(const Duration(milliseconds: AppConfig.connectionTimeout));

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Erro de conexão: ${e.toString()}');
    }
  }

  // POST request
  static Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool withAuth = true,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}$endpoint'),
        headers: await _getHeaders(withAuth: withAuth),
        body: body != null ? jsonEncode(body) : null,
      ).timeout(const Duration(milliseconds: AppConfig.connectionTimeout));

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Erro de conexão: ${e.toString()}');
    }
  }

  // PUT request
  static Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool withAuth = true,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${AppConfig.baseUrl}$endpoint'),
        headers: await _getHeaders(withAuth: withAuth),
        body: body != null ? jsonEncode(body) : null,
      ).timeout(const Duration(milliseconds: AppConfig.connectionTimeout));

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Erro de conexão: ${e.toString()}');
    }
  }

  // DELETE request
  static Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool withAuth = true,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('${AppConfig.baseUrl}$endpoint'),
        headers: await _getHeaders(withAuth: withAuth),
      ).timeout(const Duration(milliseconds: AppConfig.connectionTimeout));

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Erro de conexão: ${e.toString()}');
    }
  }

  // Multipart POST (para upload de arquivos)
  static Future<Map<String, dynamic>> postMultipart(
    String endpoint, {
    required String filePath,
    required String fileField,
    Map<String, String>? fields,
    bool withAuth = true,
  }) async {
    try {
      final uri = Uri.parse('${AppConfig.baseUrl}$endpoint');
      final request = http.MultipartRequest('POST', uri);

      // Adicionar headers
      final token = await getToken();
      if (withAuth && token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Adicionar arquivo
      request.files.add(await http.MultipartFile.fromPath(fileField, filePath));

      // Adicionar campos
      if (fields != null) {
        request.fields.addAll(fields);
      }

      final streamedResponse = await request.send()
          .timeout(const Duration(minutes: 5)); // Timeout maior para uploads
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Erro de conexão: ${e.toString()}');
    }
  }

  // Processar resposta
  static Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      final message = body['message'] ?? 'Erro desconhecido';
      throw ApiException(message, statusCode: response.statusCode);
    }
  }
}
