import 'package:flutter/foundation.dart';

import '../models/register_request.dart';
import '../models/user.dart';
import '../services/api_service.dart';

/// Fonte única da sessão do usuário.
///
/// Depende só da interface [ApiService], então funciona igual com o mock e
/// com o backend real. É um [ChangeNotifier]: quem precisa saber se o
/// usuário está logado (Home, saudação, logout) escuta este repositório.
class AuthRepository extends ChangeNotifier {
  AuthRepository(this._api);

  final ApiService _api;

  User? _currentUser;

  User? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null;

  /// Lança ApiException em caso de erro (401, 422...).
  Future<User> login({required String email, required String password}) async {
    final session = await _api.login(email: email, password: password);
    _currentUser = session.user;
    notifyListeners();
    return session.user;
  }

  /// Lança ApiException em caso de erro (409, 422...).
  Future<User> register(RegisterRequest request) async {
    final session = await _api.register(request);
    _currentUser = session.user;
    notifyListeners();
    return session.user;
  }

  void logout() {
    _api.logout();
    _currentUser = null;
    notifyListeners();
  }
}
