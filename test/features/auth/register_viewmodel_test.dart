import 'package:flutter_test/flutter_test.dart';
import 'package:saude_ja/data/repositories/auth_repository.dart';
import 'package:saude_ja/features/auth/viewmodels/register_viewmodel.dart';

import '../../helpers/test_api.dart';

void main() {
  late AuthRepository auth;
  late RegisterViewModel vm;

  setUpAll(loadMockAssets);

  setUp(() {
    auth = AuthRepository(createTestApi());
    vm = RegisterViewModel(auth);
  });

  void fillValid({String email = 'joao@email.com'}) {
    vm
      ..setName('João Silva')
      ..setEmail(email)
      ..setPhone('(63) 98888-7777')
      ..setPassword('segredo1')
      ..setConfirmPassword('segredo1')
      ..setAcceptedTerms(true);
  }

  test('formulário vazio mostra todos os erros', () async {
    expect(await vm.submit(), isFalse);
    expect(vm.nameError, isNotNull);
    expect(vm.emailError, isNotNull);
    expect(vm.phoneError, isNotNull);
    expect(vm.passwordError, isNotNull);
    expect(vm.confirmPasswordError, isNotNull);
    expect(vm.termsError, 'É preciso aceitar os termos de uso.');
  });

  test('senhas diferentes', () async {
    fillValid();
    vm.setConfirmPassword('outra123');
    expect(await vm.submit(), isFalse);
    expect(vm.confirmPasswordError, 'As senhas não conferem.');
    expect(auth.isLoggedIn, isFalse);
  });

  test('sem aceitar os termos não envia', () async {
    fillValid();
    vm.setAcceptedTerms(false);
    expect(await vm.submit(), isFalse);
    expect(vm.termsError, isNotNull);
  });

  test('e-mail já cadastrado aparece no campo de e-mail', () async {
    fillValid(email: 'maria@saudeja.com');
    expect(await vm.submit(), isFalse);
    expect(vm.emailError, 'Já existe uma conta com este e-mail.');
    expect(vm.errorMessage, isNull);

    vm.setEmail('maria2@saudeja.com');
    expect(vm.emailError, isNull);
  });

  test('cadastro válido já deixa o usuário logado', () async {
    fillValid();
    expect(await vm.submit(), isTrue);
    expect(auth.currentUser?.name, 'João Silva');
    expect(auth.currentUser?.phone, '63988887777');
  });
}
