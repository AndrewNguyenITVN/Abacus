import 'dart:async';
import 'package:pocketbase/pocketbase.dart';
import '../models/account.dart';
import 'pocketbase_client.dart';

class AuthService {
  final Function(Account?)? onAuthChange;
  late PocketBase _pb;
  bool _initialized = false;

  AuthService({this.onAuthChange}) {
    _initialize();
  }

  Future<void> _initialize() async {
    if (!_initialized) {
      _pb = await getPocketbaseInstance();
      _initialized = true;
      
      // Listen to auth changes
      _pb.authStore.onChange.listen((event) {
        if (event.token.isEmpty) {
          onAuthChange?.call(null);
        } else {
          _loadUser();
        }
      });
    }
  }

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await _initialize();
    }
  }

  void _loadUser() {
    if (_pb.authStore.isValid && _pb.authStore.record != null) {
      final record = _pb.authStore.record!;
      final account = Account(
        id: record.id,
        fullName: record.data['name'] ?? '',
        email: record.data['email'] ?? '',
        phone: record.data['phone'] ?? '',
        address: record.data['address'] ?? '',
        dateOfBirth: record.data['dateOfBirth'] != null 
            ? DateTime.parse(record.data['dateOfBirth']) 
            : DateTime(2000, 1, 1),
        gender: record.data['gender'] ?? '',
        isVerified: record.data['verified'] ?? false,
      );
      onAuthChange?.call(account);
    }
  }

  Future<Account> signup(String email, String password, String name) async {
    await _ensureInitialized();
    
    try {
      final record = await _pb.collection('users').create(body: {
        'email': email,
        'password': password,
        'passwordConfirm': password,
        'name': name,
      });

      return Account(
        id: record.id,
        fullName: record.data['name'] ?? '',
        email: record.data['email'] ?? '',
        phone: '',
        address: '',
        dateOfBirth: DateTime(2000, 1, 1),
        gender: '',
        isVerified: false,
      );
    } catch (error) {
      throw _handleError(error);
    }
  }

  Future<Account> login(String email, String password) async {
    await _ensureInitialized();
    
    try {
      final authData = await _pb.collection('users').authWithPassword(
        email,
        password,
      );

      final record = authData.record;
      return Account(
        id: record.id,
        fullName: record.data['name'] ?? '',
        email: record.data['email'] ?? '',
        phone: record.data['phone'] ?? '',
        address: record.data['address'] ?? '',
        dateOfBirth: record.data['dateOfBirth'] != null 
            ? DateTime.parse(record.data['dateOfBirth']) 
            : DateTime(2000, 1, 1),
        gender: record.data['gender'] ?? '',
        isVerified: record.data['verified'] ?? false,
      );
    } catch (error) {
      throw _handleError(error);
    }
  }

  Future<Account?> getUserFromStore() async {
    await _ensureInitialized();
    
    if (_pb.authStore.isValid && _pb.authStore.record != null) {
      final record = _pb.authStore.record!;
      return Account(
        id: record.id,
        fullName: record.data['name'] ?? '',
        email: record.data['email'] ?? '',
        phone: record.data['phone'] ?? '',
        address: record.data['address'] ?? '',
        dateOfBirth: record.data['dateOfBirth'] != null 
            ? DateTime.parse(record.data['dateOfBirth']) 
            : DateTime(2000, 1, 1),
        gender: record.data['gender'] ?? '',
        isVerified: record.data['verified'] ?? false,
      );
    }
    return null;
  }

  Future<void> logout() async {
    await _ensureInitialized();
    _pb.authStore.clear();
    onAuthChange?.call(null);
  }

  String _handleError(dynamic error) {
    if (error is ClientException) {
      if (error.statusCode == 400) {
        return 'Email hoặc mật khẩu không đúng';
      } else if (error.statusCode == 401) {
        return 'Không có quyền truy cập';
      }
      return error.response['message'] ?? 'Đã xảy ra lỗi';
    }
    return error.toString();
  }
}

