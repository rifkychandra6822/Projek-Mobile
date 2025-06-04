import '../models/user_model.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static const String _userKey = 'user_data';
  
  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final userData = json.encode(user.toMap());
    await prefs.setString(_userKey, userData);
  }

  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    if (userData != null) {
      return User.fromMap(json.decode(userData));
    }
    return null;
  }

  Future<void> updateUser(User user) async {
    await saveUser(user);
  }

  Future<void> deleteUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
} 