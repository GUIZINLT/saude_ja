/// Validações de formulário usadas pelos ViewModels.
///
/// Seguem as mesmas regras de docs/API.md, para o usuário ver o erro antes
/// de enviar. Cada função devolve a mensagem de erro, ou null se estiver ok.
class Validators {
  Validators._();

  static final _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? email(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'Informe o e-mail.';
    if (!_emailRe.hasMatch(v)) return 'E-mail inválido.';
    return null;
  }

  static String? requiredPassword(String value) =>
      value.isEmpty ? 'Informe a senha.' : null;

  static String? newPassword(String value) {
    if (value.isEmpty) return 'Informe a senha.';
    if (value.length < 6) return 'A senha deve ter pelo menos 6 caracteres.';
    return null;
  }

  static String? confirmPassword(String password, String confirmation) {
    if (confirmation.isEmpty) return 'Confirme a senha.';
    if (password != confirmation) return 'As senhas não conferem.';
    return null;
  }

  static String? fullName(String value) =>
      value.trim().length < 3 ? 'Informe o nome completo.' : null;

  static String? phone(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return 'Informe o telefone.';
    if (digits.length < 10 || digits.length > 11) {
      return 'Telefone deve ter DDD + número.';
    }
    return null;
  }
}
