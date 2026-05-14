import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService extends GetxService {
  late SharedPreferences _prefs;

  final userName = ''.obs;
  final userRole = ''.obs;
  final userPhoto = ''.obs;
  final themeMode = 'system'.obs;

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    userName.value = _prefs.getString('user_name') ?? '';
    userRole.value = _prefs.getString('user_role') ?? '';
    userPhoto.value = _prefs.getString('user_photo') ?? '';
    themeMode.value = _prefs.getString('theme_mode') ?? 'system';
    return this;
  }

  Future<void> saveToken(String token) async {
    await _prefs.setString('auth_token', token);
  }

  Future<void> saveUserData(
    String name,
    String role, {
    String? fotoProfilUrl,
  }) async {
    await _prefs.setString('user_name', name);
    await _prefs.setString('user_role', role);
    userName.value = name;
    userRole.value = role;

    if (fotoProfilUrl != null && fotoProfilUrl.isNotEmpty) {
      await _prefs.setString('user_photo', fotoProfilUrl);
      userPhoto.value = fotoProfilUrl;
    } else {
      await _prefs.remove('user_photo');
      userPhoto.value = '';
    }
  }

  Future<void> saveThemeMode(String mode) async {
    await _prefs.setString('theme_mode', mode);
    themeMode.value = mode;
  }

  String? getToken() {
    return _prefs.getString('auth_token');
  }

  String? getUserName() {
    return _prefs.getString('user_name');
  }

  String? getUserRole() {
    return _prefs.getString('user_role');
  }

  String? getUserPhoto() {
    return _prefs.getString('user_photo');
  }

  Future<void> clearToken() async {
    await _prefs.remove('auth_token');
    await _prefs.remove('user_name');
    await _prefs.remove('user_role');
    await _prefs.remove('user_photo');

    userName.value = '';
    userRole.value = '';
    userPhoto.value = '';
  }

  bool get isLoggedIn => getToken() != null;
}
