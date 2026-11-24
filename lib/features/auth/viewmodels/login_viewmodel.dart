import 'package:flutter/foundation.dart';

import '../../../core/utils/validators.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/api_exception.dart';

/// Estado e regras da tela de Login.
///
/// A View só lê as propriedades e chama os métodos; não valida nem fala
/// com a API diretamente.
class LoginViewModel extends ChangeNotifier {
  LoginViewModel(this._auth);

  final AuthRepository _auth;

  String _email = '';
  String _password = '';
  bool _submitted = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  Map<String, String> _serverErrors = const {};

  bool get isLoading => _isLoading;
  bool get obscurePassword => _obscurePassword;

  /// Erro geral (ex.: "E-mail ou senha incorretos."), mostrado acima do botão.
  String? get errorMessage => _errorMessage;

  String? get emailError =>
      _submitted ? (_serverErrors['email'] ?? Validators.email(_email)) : null;

  String? get passwordError => _submitted
      ? (_serverErrors['password'] ?? Validators.requiredPassword(_password))
      : null;

  void setEmail(String value) {
    _email = value;
    _clearErrorsFor('email');
  }

  void setPassword(String value) {
    _password = value;
    _clearErrorsFor('password');
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  /// Valida, chama a API e devolve true se o login deu certo.
  Future<bool> submit() async {
    if (_isLoading) return false;
    _submitted = true;
    _serverErrors = const {};
    _errorMessage = null;

    if (emailError != null || passwordError != null) {
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();
    try {
      await _auth.login(email: _email.trim(), password: _password);
      return true;
    } on ApiException catch (e) {
      _serverErrors = e.fields;
      _errorMessage = e.fields.isEmpty ? e.message : null;
      return false;
    } catch (_) {
      _errorMessage = 'Não foi possível entrar. Tente novamente.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _clearErrorsFor(String field) {
    _errorMessage = null;
    if (_serverErrors.containsKey(field)) {
      _serverErrors = Map.of(_serverErrors)..remove(field);
    }
    notifyListeners();
  }
}
