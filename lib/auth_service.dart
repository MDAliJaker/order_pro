import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  Future<void> registerUser({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString('user_firstName', firstName);
    await prefs.setString('user_lastName', lastName);
    await prefs.setString('user_email', email);
    await prefs.setString('user_phone', phone);
    await prefs.setString('user_password', password);
    await prefs.setBool('is_logged_in', true);
    
    print('✅ User registered: $email');
  }

  Future<bool> loginUser(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    
    final storedEmail = prefs.getString('user_email');
    final storedPassword = prefs.getString('user_password');
    
    if (storedEmail == email && storedPassword == password) {
      await prefs.setBool('is_logged_in', true);
      print('✅ Login successful: $email');
      return true;
    }
    
    print('❌ Login failed: $email');
    return false;
  }

  Future<Map<String, String>> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'firstName': prefs.getString('user_firstName') ?? '',
      'lastName': prefs.getString('user_lastName') ?? '',
      'email': prefs.getString('user_email') ?? '',
      'phone': prefs.getString('user_phone') ?? '',
    };
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
  }
}