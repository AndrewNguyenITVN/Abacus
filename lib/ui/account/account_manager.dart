import 'package:flutter/foundation.dart';
import '../../models/account.dart';
import '../../services/auth_service.dart';

class AccountManager with ChangeNotifier {
  Account? _account;
  final AuthService _authService = AuthService();
  bool _isLoading = true;

  Account? get account => _account;
  bool get isLoading => _isLoading;

  AccountManager() {
    loadAccount();
  }

  Future<void> loadAccount() async {
    _isLoading = true;
    notifyListeners();

    try {
      _account = await _authService.getUserFromStore();
    } catch (e) {
      print('Error loading account: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateAccount(Account newAccount) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Prepare body for PocketBase update
      final body = {
        'name': newAccount.fullName,
        'email': newAccount.email, 
        'phone': newAccount.phone,
        'address': newAccount.address,
        'gender': newAccount.gender,
        'dateOfBirth': newAccount.dateOfBirth.toIso8601String(),
      };

      // Update in PocketBase
      final updatedAccount = await _authService.updateProfile(newAccount.id, body);
      
      // Update local state
      _account = updatedAccount;
    } catch (e) {
      print('Error updating account: $e');
      // Revert or show error? For now just print
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
