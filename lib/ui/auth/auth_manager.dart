import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../models/account.dart';
import '../../services/auth_service.dart';

class AuthManager with ChangeNotifier {
  late final AuthService _authService;
  bool _didTryAutoLogin = false;
  Account? _loggedInUser;

  AuthManager() {
    _authService = AuthService(onAuthChange: (Account? account) {
      _loggedInUser = account;
      notifyListeners();
    });
  }

  bool get isAuth {
    return _loggedInUser != null;
  }

  Account? get user {
    return _loggedInUser;
  }

  Future<Account> signup(String email, String password, String name) {
    return _authService.signup(email, password, name);
  }

  Future<Account> login(String email, String password) {
    return _authService.login(email, password);
  }

  Future<void> tryAutoLogin() async {
    if (_didTryAutoLogin) return;
    _didTryAutoLogin = true;
    final account = await _authService.getUserFromStore();
    if (account != null) {
      _loggedInUser = account;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
  }
}

