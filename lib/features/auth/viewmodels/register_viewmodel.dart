import 'package:flutter/foundation.dart';

import '../../../core/utils/validators.dart';
import '../../../data/models/register_request.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/api_exception.dart';

/// Estado e regras da tela de Cadastro.
class RegisterViewModel extends ChangeNotifier {
  RegisterViewModel(this._auth);

  final AuthRepository _auth;

  String _name = '';
  String _email = '';
  String _phone = '';
  String _password = '';
  String _confirmPassword = '';
  bool _acceptedTerms = false;

  bool _submitted = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  Map<String, String> _serverErrors = const {};

  bool get isLoading => _isLoading;
  bool get obscurePassword => _obscurePassword;
  bool get acceptedTerms => _acceptedTerms;
  String? get errorMessage => _errorMessage;

  String? get nameError => _error('name', () => Validators.fullName(_name));

  String? get emailError => _error('email', () => Validators.email(_email));

  String? get phoneError => _error('phone', () => Validators.phone(_phone));

  String? get passwordError =>
      _error('password', () => Validators.newPassword(_password));

  /// Só existe no app: a API não recebe a confirmação.
  String? get confirmPasswordError => _error(
    'confirmPassword',
    () => Validators.confirmPassword(_password, _confirmPassword),
  );

  String? get termsError => _error(
    'acceptedTerms',
    () => _acceptedTerms ? null : 'É preciso aceitar os termos de uso.',
  );

  bool get _hasErrors =>
      nameError != null ||
      emailError != null ||
      phoneError != null ||
      passwordError != null ||
      confirmPasswordError != null ||
      termsError != null;

  void setName(String v) => _update('name', () => _name = v);
  void setEmail(String v) => _update('email', () => _email = v);
  void setPhone(String v) => _update('phone', () => _phone = v);
  void setPassword(String v) => _update('password', () => _password = v);
  void setConfirmPassword(String v) =>
      _update('confirmPassword', () => _confirmPassword = v);
  void setAcceptedTerms(bool v) =>
      _update('acceptedTerms', () => _acceptedTerms = v);

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  /// Valida, cria a conta e devolve true se deu certo (usuário já logado).
  Future<bool> submit() async {
    if (_isLoading) return false;
    _submitted = true;
    _serverErrors = const {};
    _errorMessage = null;

    if (_hasErrors) {
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();
    try {
      await _auth.register(
        RegisterRequest(
          name: _name.trim(),
          email: _email.trim(),
          phone: _phone,
          password: _password,
          acceptedTerms: _acceptedTerms,
        ),
      );
      return true;
    } on ApiException catch (e) {
      if (e.code == 'EMAIL_ALREADY_IN_USE') {
        // Mostra no próprio campo de e-mail.
        _serverErrors = {'email': e.message};
      } else {
        _serverErrors = e.fields;
        _errorMessage = e.fields.isEmpty ? e.message : null;
      }
      return false;
    } catch (_) {
      _errorMessage = 'Não foi possível criar a conta. Tente novamente.';
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
