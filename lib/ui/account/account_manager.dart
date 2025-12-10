import 'package:flutter/foundation.dart';
import '../../models/account.dart';
import '../../services/auth_service.dart';

class AccountManager with ChangeNotifier {
  Account? _account;
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Account? get account => _account;
  bool get isLoading => _isLoading;

  AccountManager();

  void update(Account? account) {
    _account = account;
    // notifyListeners(); // update được gọi khi build, tránh notify khi đang build nếu không cần thiết
    // Tuy nhiên ProxyProvider update callback được gọi ngay khi dependency change.
    // Việc gán _account là đủ nếu consumer rebuild.
    // Nhưng nếu logic khác cần trigger thì notify.
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
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
