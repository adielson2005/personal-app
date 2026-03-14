import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _error;

  AuthStatus get status => _status;
  User? get user => _user;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isTrainer => _user?.isTrainer ?? false;
  bool get isStudent => _user?.isStudent ?? false;

  AuthProvider() {
    _checkAuthStatus();
  }

  // Verificar status de autenticação
  Future<void> _checkAuthStatus() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final isLoggedIn = await AuthService.isLoggedIn();
      if (isLoggedIn) {
        _user = await AuthService.getMe();
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      await ApiService.deleteToken();
    }

    notifyListeners();
  }

  // Login
  Future<bool> login(String email, String password) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final result = await AuthService.login(email, password);
      _user = result['user'] as User;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  // Registro
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String role = 'student',
  }) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final result = await AuthService.register(
        name: name,
        email: email,
        password: password,
        role: role,
      );
      _user = result['user'] as User;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  // Atualizar perfil
  Future<bool> updateProfile({
    String? name,
    String? email,
    String? profileImage,
  }) async {
    try {
      _user = await AuthService.updateProfile(
        name: name,
        email: email,
        profileImage: profileImage,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Alterar senha
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await AuthService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Esqueci minha senha
  Future<bool> forgotPassword(String email) async {
    try {
      await AuthService.forgotPassword(email);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await AuthService.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // Limpar erro
  void clearError() {
    _error = null;
    if (_status == AuthStatus.error) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }
}
