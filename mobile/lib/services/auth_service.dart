import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  // Login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await ApiService.post(
      '/auth/login',
      body: {
        'email': email,
        'password': password,
      },
      withAuth: false,
    );

    if (response['success'] == true && response['data'] != null) {
      final token = response['data']['token'];
      await ApiService.saveToken(token);
      
      return {
        'user': User.fromJson(response['data']['user']),
        'token': token,
      };
    }

    throw ApiException(response['message'] ?? 'Erro ao fazer login');
  }

  // Registro
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String role = 'student',
  }) async {
    final response = await ApiService.post(
      '/auth/register',
      body: {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      },
      withAuth: false,
    );

    if (response['success'] == true && response['data'] != null) {
      final token = response['data']['token'];
      await ApiService.saveToken(token);
      
      return {
        'user': User.fromJson(response['data']['user']),
        'token': token,
      };
    }

    throw ApiException(response['message'] ?? 'Erro ao registrar');
  }

  // Obter usuário atual
  static Future<User> getMe() async {
    final response = await ApiService.get('/auth/me');

    if (response['success'] == true && response['data'] != null) {
      return User.fromJson(response['data']);
    }

    throw ApiException(response['message'] ?? 'Erro ao obter usuário');
  }

  // Atualizar perfil
  static Future<User> updateProfile({
    String? name,
    String? email,
    String? profileImage,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (email != null) body['email'] = email;
    if (profileImage != null) body['profileImage'] = profileImage;

    final response = await ApiService.put('/auth/update', body: body);

    if (response['success'] == true && response['data'] != null) {
      return User.fromJson(response['data']);
    }

    throw ApiException(response['message'] ?? 'Erro ao atualizar perfil');
  }

  // Alterar senha
  static Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await ApiService.put(
      '/auth/password',
      body: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );

    if (response['success'] != true) {
      throw ApiException(response['message'] ?? 'Erro ao alterar senha');
    }

    // Atualizar token se retornado
    if (response['data'] != null && response['data']['token'] != null) {
      await ApiService.saveToken(response['data']['token']);
    }
  }

  // Esqueci minha senha
  static Future<void> forgotPassword(String email) async {
    final response = await ApiService.post(
      '/auth/forgot-password',
      body: {'email': email},
      withAuth: false,
    );

    if (response['success'] != true) {
      throw ApiException(response['message'] ?? 'Erro ao enviar e-mail de recuperação');
    }
  }

  // Logout
  static Future<void> logout() async {
    await ApiService.deleteToken();
  }

  // Verificar se está logado
  static Future<bool> isLoggedIn() async {
    final token = await ApiService.getToken();
    return token != null;
  }
}
