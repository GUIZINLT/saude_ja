import 'package:shared_preferences/shared_preferences.dart';

/// Onde o token da sessão fica guardado entre uma abertura do app e outra.
abstract interface class SessionStorage {
  Future<String?> readToken();
  Future<void> saveToken(String token);
  Future<void> clear();
}

/// Guarda no aparelho (SharedPreferences no Android/iOS, localStorage na
/// web).
class SharedPrefsSessionStorage implements SessionStorage {
  SharedPrefsSessionStorage(this._prefs);

  static const _key = 'saude_ja.session_token';

  final SharedPreferences _prefs;

  static Future<SharedPrefsSessionStorage> create() async =>
      SharedPrefsSessionStorage(await SharedPreferences.getInstance());

  @override
  Future<String?> readToken() async => _prefs.getString(_key);

  @override
  Future<void> saveToken(String token) => _prefs.setString(_key, token);

  @override
  Future<void> clear() => _prefs.remove(_key);
}

/// Guarda só na memória. Usado nos testes e como padrão.
class InMemorySessionStorage implements SessionStorage {
  InMemorySessionStorage([this._token]);

  String? _token;

  @override
  Future<String?> readToken() async => _token;

  @override
  Future<void> saveToken(String token) async => _token = token;

  @override
  Future<void> clear() async => _token = null;
}
