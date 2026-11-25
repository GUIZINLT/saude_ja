import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/password_reset.dart';
import '../models/register_request.dart';
import '../models/user.dart';
import '../services/api_exception.dart';
import '../services/api_service.dart';
import '../services/session_storage.dart';

/// Fonte única da sessão do usuário.
///
/// Depende só da interface [ApiService], então funciona igual com o mock e
/// com o backend real. É um [ChangeNotifier]: quem precisa saber se o
/// usuário está logado (Home, saudação, logout) escuta este repositório.
///
/// O token fica salvo em [SessionStorage], para o usuário continuar logado
/// ao reabrir o app.
class AuthRepository extends ChangeNotifier {
  AuthRepository(this._api, [SessionStorage? storage])
    : _storage = storage ?? InMemorySessionStorage();

  final ApiService _api;
  final SessionStorage _storage;

  User? _currentUser;

  User? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null;

  /// Chamado ao abrir o app: se houver token salvo e ele ainda valer,
  /// entra direto. Se não valer mais, apaga. Nunca lança erro.
  Future<void> restoreSession() async {
    final token = await _storage.readToken();
    if (token == null) return;
    try {
      _currentUser = await _api.restoreSession(token);
      notifyListeners();
    } on ApiException catch (e) {
      // 401: token vencido ou usuário inexistente. Outros erros (rede)
      // também caem aqui; o usuário simplesmente entra de novo.
      if (e.isUnauthorized) await _storage.clear();
    } catch (_) {
      // Sem rede ou erro inesperado: segue para o Login.
    }
  }

  /// Lança ApiException em caso de erro (401, 422...).
  Future<User> login({required String email, required String password}) async {
    final session = await _api.login(email: email, password: password);
    await _storage.saveToken(session.token);
    _currentUser = session.user;
    notifyListeners();
    return session.user;
  }

  /// Lança ApiException em caso de erro (409, 422...).
  Future<User> register(RegisterRequest request) async {
    final session = await _api.register(request);
    await _storage.saveToken(session.token);
    _currentUser = session.user;
    notifyListeners();
    return session.user;
  }

  /// Pede o código para trocar a senha. Lança ApiException (422...).
  Future<PasswordResetRequest> forgotPassword(String email) =>
      _api.forgotPassword(email);

  /// Troca a senha com o código. Lança ApiException (400 código inválido
  /// ou expirado, 422...).
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) => _api.resetPassword(email: email, code: code, newPassword: newPassword);

  void logout() {
    _api.logout();
    unawaited(_storage.clear());
    _currentUser = null;
    notifyListeners();
  }
}
