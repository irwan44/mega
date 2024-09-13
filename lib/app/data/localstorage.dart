import 'package:bank_mega/app/data/public.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorages {
  static GetStorage box = GetStorage();

  // Token management
  static Future<bool> hasToken() async {
    String token = getToken;
    return token.isNotEmpty;
  }
  static Future<bool> hasTokenregis() async {
    String tokenregis = getTokenRegis;
    return tokenregis.isNotEmpty;
  }

  static Future<void> setTokenRegis(String token) async {
    await box.write('token', token);
    Publics.controller.getTokenRegis.value = getTokenRegis;
  }

  static String get getTokenRegis => box.read('token') ?? '';

  static Future<void> deleteTokenRegis() async {
    await box.remove('token');
    Publics.controller.getTokenRegis.value = '';
  }

  static Future<void> setToken(String token) async {
    await box.write('token', token);
    Publics.controller.getToken.value = getToken;
  }

  static String get getToken => box.read('token') ?? '';

  static Future<void> deleteToken() async {
    await box.remove('token');
    Publics.controller.getToken.value = '';
  }

  static Future<void> logout() async {
    await deleteToken();
  }

  static Future<String?> getTokenregis() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('registration_token');
  }

  // Email management
  static Future<void> setEmail(String email) async {
    await box.write('email', email);
  }

  static String get getEmail => box.read('email') ?? '';

  // External ID management
  static final _storage = GetStorage();

  static Future<String?> getExternalId() async {
    return _storage.read('external_id');
  }

  // Method to save externalId
  static Future<void> saveExternalId(String externalId) async {
    await _storage.write('external_id', externalId);
  }
// Add similar methods for other fields if needed
}
