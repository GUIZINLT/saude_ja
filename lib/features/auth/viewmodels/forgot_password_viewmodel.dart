import 'package:flutter/foundation.dart';

import '../../../core/utils/validators.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/api_exception.dart';

enum ForgotPasswordStep {
  /// Informa o e-mail para receber o código.
  email,

  /// Informa o código e a nova senha.
  reset,

  /// Senha trocada.
  done,
}

/// Estado da tela "Esqueci minha senha", em duas etapas.
class ForgotPasswordViewModel extends ChangeNotifier {
  ForgotPasswordViewModel(this._auth);

  final AuthRepository _auth;

  ForgotPasswordStep _step = ForgotPasswordStep.email;
  String _email = '';
  String _code = '';
  String _password = '';
  String _confirmPassword = '';
  bool _submitted = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  String? _info;
  String? _devCode;
  Map<String, String> _serverErrors = const {};

  ForgotPasswordStep get step => _step;
  String get email => _email.trim();
  bool get isLoading => _isLoading;
  bool get obscurePassword => _obscurePassword;
  String? get errorMessage => _errorMessage;

  /// Mensagem depois de pedir o código ("Se houver uma conta...").
  String? get info => _info;

  /// Só no mock: o código que um backend real mandaria por e-mail.
  String? get devCode => _devCode;

  String? get emailError => _error('email', () => Validators.email(_email));

  String? get codeError => _error(
    'code',
    () => RegExp(r'^\d{6}$').hasMatch(_code.trim())
        ? null
        : 'O código tem 6 dígitos.',
  );

  String? get passwordError =>
      _error('newPassword', () => Validators.newPassword(_password));

  String? get confirmPasswordError => _error(
    'confirmPassword',
    () => Validators.confirmPassword(_password, _confirmPassword),
  );

  void setEmail(String v) => _update('email', () => _email = v);
  void setCode(String v) => _update('code', () => _code = v);
  void setPassword(String v) => _update('newPassword', () => _password = v);
  void setConfirmPassword(String v) =>
      _update('confirmPassword', () => _confirmPassword = v);

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  /// Etapa 1: pede o código. Devolve true se passou para a etapa 2.
  Future<bool> requestCode() async {
    _submitted = true;
    _serverErrors = const {};
    _errorMessage = null;
    if (emailError != null) {
      notifyListeners();
      return false;
    }
    return _run(() async {
      final result = await _auth.forgotPassword(email);
      _info = result.message;
      _devCode = result.devCode;
      _step = ForgotPasswordStep.reset;
      _submitted = false; // a etapa 2 começa sem erros à mostra
    });
  }

  /// Etapa 2: troca a senha. Devolve true se deu certo.
  Future<bool> resetPassword() async {
    _submitted = true;
    _serverErrors = const {};
    _errorMessage = null;
    if (codeError != null ||
        passwordError != null ||
        confirmPasswordError != null) {
      notifyListeners();
      return false;
    }
    return _run(() async {
      await _auth.resetPassword(
        email: email,
        code: _code.trim(),
        newPassword: _password,
      );
      _step = ForgotPasswordStep.done;
    });
  }

  /// Volta para a etapa 1 (pedir outro código ou trocar o e-mail).
  void restart() {
    _step = ForgotPasswordStep.email;
    _code = '';
    _info = null;
    _devCode = null;
    _submitted = false;
    _errorMessage = null;
    _serverErrors = const {};
    notifyListeners();
  }

  Future<bool> _run(Future<void> Function() action) async {
    if (_isLoading) return false;
    _isLoading = true;
    notifyListeners();
    try {
      await action();
      return true;
    } on ApiException catch (e) {
      _submitted = true;
      _serverErrors = e.fields;
      _errorMessage = e.fields.isEmpty ? e.message : null;
      return false;
    } catch (_) {
      _errorMessage = 'Não foi possível concluir. Tente novamente.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String? _error(String field, String? Function() validate) =>
      _submitted ? (_serverErrors[field] ?? validate()) : null;

  void _update(String field, VoidCallback change) {
    change();
    _errorMessage = null;
    if (_serverErrors.containsKey(field)) {
      _serverErrors = Map.of(_serverErrors)..remove(field);
    }
    notifyListeners();
  }
}
