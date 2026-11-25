import 'package:flutter_test/flutter_test.dart';
import 'package:saude_ja/data/repositories/auth_repository.dart';
import 'package:saude_ja/features/auth/viewmodels/forgot_password_viewmodel.dart';

import '../../helpers/test_api.dart';

void main() {
  late AuthRepository auth;
  late ForgotPasswordViewModel vm;

  setUpAll(loadMockAssets);

  setUp(() {
    auth = AuthRepository(createTestApi());
    vm = ForgotPasswordViewModel(auth);
  });

  test('e-mail inválido não pede o código', () async {
    vm.setEmail('maria');
    expect(await vm.requestCode(), isFalse);
    expect(vm.emailError, 'E-mail inválido.');
    expect(vm.step, ForgotPasswordStep.email);
  });

  test('fluxo completo: pede o código e troca a senha', () async {
    vm.setEmail('maria@saudeja.com');
    expect(await vm.requestCode(), isTrue);
    expect(vm.step, ForgotPasswordStep.reset);
    expect(vm.devCode, '123456');
    expect(vm.codeError, isNull); // etapa 2 começa sem erros

    vm
      ..setCode('123456')
      ..setPassword('nova123')
      ..setConfirmPassword('nova123');
    expect(await vm.resetPassword(), isTrue);
    expect(vm.step, ForgotPasswordStep.done);

    // A senha nova funciona no login.
    await auth.login(email: 'maria@saudeja.com', password: 'nova123');
    expect(auth.isLoggedIn, isTrue);
  });

  test('validações e código errado', () async {
    vm.setEmail('maria@saudeja.com');
    await vm.requestCode();

    vm
      ..setCode('12')
      ..setPassword('nova123')
      ..setConfirmPassword('outra');
    expect(await vm.resetPassword(), isFalse);
    expect(vm.codeError, 'O código tem 6 dígitos.');
    expect(vm.confirmPasswordError, 'As senhas não conferem.');

    vm
      ..setCode('999999')
      ..setConfirmPassword('nova123');
    expect(await vm.resetPassword(), isFalse);
    expect(
      vm.errorMessage,
      'Código inválido. Confira o código ou peça um novo.',
    );
    expect(vm.step, ForgotPasswordStep.reset);
  });

  test('pedir outro código volta para a etapa do e-mail', () async {
    vm.setEmail('maria@saudeja.com');
    await vm.requestCode();
    vm.restart();
    expect(vm.step, ForgotPasswordStep.email);
    expect(vm.devCode, isNull);
    expect(vm.email, 'maria@saudeja.com');
  });
}
