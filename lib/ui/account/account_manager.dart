import 'package:flutter/foundation.dart';
import '../../models/account.dart';

class AccountManager with ChangeNotifier {
  Account _account = Account(
    id: '1',
    fullName: 'Nguyễn Minh Nhựt',
    email: 'nminhut@example.com',
    phone: '0389xxxx44',
    address: 'TP. Hồ Chí Minh',
    dateOfBirth: DateTime(2000, 1, 1),
    gender: 'Nam',
    isVerified: true,
  );

  Account get account => _account;

  void updateAccount(Account newAccount) {
    _account = newAccount;
    // In a real app, you would save this to a database or API
    print('Account updated: ${_account.fullName}');
    notifyListeners();
  }
}

