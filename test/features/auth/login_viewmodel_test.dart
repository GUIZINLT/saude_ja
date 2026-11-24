import 'package:flutter_test/flutter_test.dart';
import 'package:saude_ja/data/repositories/auth_repository.dart';
import 'package:saude_ja/features/auth/viewmodels/login_viewmodel.dart';

import '../../helpers/test_api.dart';

void main() {
  late AuthRepository auth;
  late LoginViewModel vm;

  setUpAll(loadMockAssets);

  setUp(() {
    auth = AuthRepository(createTestApi());
    vm = LoginViewModel(auth);
  });

  test('não mostra erros antes de tentar entrar', () {
    expect(vm.emailError, isNull);
    expect(vm.passwordError, isNull);
  });

  test('campos vazios: valida sem chamar a API', () async {
    expect(await vm.submit(), isFalse);
    expect(vm.emailError, 'Informe o e-mail.');
    expect(vm.passwordError, 'Informe a senha.');
    expect(auth.isLoggedIn, isFalse);
  });

  test('e-mail inválido', () async {
    vm
      ..setEmail('maria')
      ..setPassword('123456');
    expect(await vm.submit(), isFalse);
    expect(vm.emailError, 'E-mail inválido.');
  });

  test('o erro some quando o campo é corrigido', () async {
    await vm.submit();
    vm.setEmail('maria@saudeja.com');
    expect(vm.emailError, isNull);
    expect(vm.passwordError, isNotNull);
  });

  test('senha errada mostra a mensagem da API', () async {
    vm
      ..setEmail('maria@saudeja.com')
      ..setPassword('errada');
    expect(await vm.submit(), isFalse);
    expect(vm.errorMessage, 'E-mail ou senha incorretos.');
    expect(vm.isLoading, isFalse);

    vm.setPassword('errad');
    expect(vm.errorMessage, isNull);
  });

  test('login válido guarda o usuário na sessão', () async {
    vm
      ..setEmail(' maria@saudeja.com ')
      ..setPassword('123456');
    expect(await vm.submit(), isTrue);
    expect(auth.currentUser?.firstName, 'Maria');
    expect(vm.errorMessage, isNull);
  });

  test('alterna a visibilidade da senha', () {
    expect(vm.obscurePassword, isTrue);
    vm.togglePasswordVisibility();
    expect(vm.obscurePassword, isFalse);
  });
}
