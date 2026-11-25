import 'package:flutter_test/flutter_test.dart';
import 'package:saude_ja/data/repositories/auth_repository.dart';
import 'package:saude_ja/data/services/session_storage.dart';

import '../helpers/test_api.dart';

void main() {
  setUpAll(loadMockAssets);

  test('login salva o token e logout apaga', () async {
    final storage = InMemorySessionStorage();
    final auth = AuthRepository(createTestApi(), storage);

    await auth.login(email: 'maria@saudeja.com', password: '123456');
    expect(await storage.readToken(), isNotNull);

    auth.logout();
    await Future<void>.delayed(Duration.zero);
    expect(await storage.readToken(), isNull);
    expect(auth.isLoggedIn, isFalse);
  });

  test('reabrir o app com token salvo entra direto', () async {
    final storage = InMemorySessionStorage();
    await AuthRepository(
      createTestApi(),
      storage,
    ).login(email: 'maria@saudeja.com', password: '123456');

    // "Reabre" o app: API e repositório novos, mesmo armazenamento.
    final reopened = AuthRepository(createTestApi(), storage);
    await reopened.restoreSession();

    expect(reopened.isLoggedIn, isTrue);
    expect(reopened.currentUser?.firstName, 'Maria');
  });

  test('token inválido é apagado e o usuário fica deslogado', () async {
    final storage = InMemorySessionStorage('token-qualquer');
    final auth = AuthRepository(createTestApi(), storage);

    await auth.restoreSession();

    expect(auth.isLoggedIn, isFalse);
    expect(await storage.readToken(), isNull);
  });

  test('sem token salvo não faz nada', () async {
    final auth = AuthRepository(createTestApi(), InMemorySessionStorage());
    await auth.restoreSession();
    expect(auth.isLoggedIn, isFalse);
  });
}
