import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_user.dart';

class AuthProvider extends ChangeNotifier {
  static const _kUsersKey = "users_db"; // database local
  static const _kSessionKey = "logged_in_user"; // session

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;

  bool _loading = false;
  bool get loading => _loading;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final session = prefs.getString(_kSessionKey);
    if (session != null) {
      _currentUser = AppUser.fromJson(jsonDecode(session));
      _isLoggedIn = true;
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>> _getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kUsersKey);
    if (raw == null) return {};
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> _saveUsers(Map<String, dynamic> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUsersKey, jsonEncode(users));
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _loading = true;
    notifyListeners();

    final users = await _getUsers();
    final key = email.trim().toLowerCase();

    if (users.containsKey(key)) {
      _loading = false;
      notifyListeners();
      throw "Email already exists";
    }

    users[key] = {
      "password": password, // (ملاحظة: للتجربة فقط، بالواقع لازم تشفير)
      "name": name.trim(),
      "email": key,
    };

    await _saveUsers(users);

    // auto-login after sign up
    final prefs = await SharedPreferences.getInstance();
    _currentUser = AppUser(name: name.trim(), email: key);
    await prefs.setString(_kSessionKey, jsonEncode(_currentUser!.toJson()));
    _isLoggedIn = true;

    _loading = false;
    notifyListeners();
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    _loading = true;
    notifyListeners();

    final users = await _getUsers();
    final key = email.trim().toLowerCase();

    if (!users.containsKey(key)) {
      _loading = false;
      notifyListeners();
      throw "User not found";
    }

    final data = users[key] as Map<String, dynamic>;
    if (data["password"] != password) {
      _loading = false;
      notifyListeners();
      throw "Wrong password";
    }

    final prefs = await SharedPreferences.getInstance();
    _currentUser = AppUser(name: data["name"], email: data["email"]);
    await prefs.setString(_kSessionKey, jsonEncode(_currentUser!.toJson()));
    _isLoggedIn = true;

    _loading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kSessionKey);
    _currentUser = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}