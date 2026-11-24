/// Corpo de POST /auth/register.
///
/// A confirmação de senha da tela de Cadastro é validada só no app
/// (ViewModel) e não é enviada para a API.
class RegisterRequest {
  final String name;
  final String email;
  final String phone;
  final String password;
  final bool acceptedTerms;

  const RegisterRequest({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.acceptedTerms,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
    'password': password,
    'acceptedTerms': acceptedTerms,
  };
}
