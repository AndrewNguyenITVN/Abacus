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
          // Don't load user here to avoid loops or race conditions if needed, 
          // or just let the UI trigger load
        }
      });
    }
  }

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await _initialize();
    }
  }

  // Helper to map RecordModel to Account
  Account _mapRecordToAccount(RecordModel record) {
    final bool isVerified = record.data['verified'] ?? false;

    return Account(
      id: record.id,
      fullName: record.data['name'] ?? '',
      email: record.data['email'] ?? '',
      phone: record.data['phone'] ?? '',
      address: record.data['address'] ?? '',
      dateOfBirth: record.data['dateOfBirth'] != null &&
              record.data['dateOfBirth'].toString().isNotEmpty
          ? DateTime.parse(record.data['dateOfBirth'])
          : DateTime(2000, 1, 1),
      gender: record.data['gender'] ?? '',
      isVerified: isVerified,
    );
  }

  Future<Account> signup(String email, String password, String name) async {
    await _ensureInitialized();

    try {
      _pb.authStore.clear();

      final record = await _pb.collection('users').create(
        body: {
          'email': email,
          'password': password,
          'passwordConfirm': password,
          'name': name,
        },
      );

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
      final authData =
          await _pb.collection('users').authWithPassword(email, password);

      final account = _mapRecordToAccount(authData.record!);
      onAuthChange?.call(account);
      return account;
    } catch (error) {
      throw _handleError(error);
    }
  }

  Future<Account> updateProfile(String id, Map<String, dynamic> body) async {
    await _ensureInitialized();

    try {
      final record = await _pb.collection('users').update(id, body: body);
      final account = _mapRecordToAccount(record);

      // Update local auth store if it's the current user
      // Note: Updating the record in authStore manually might be tricky, 
      // usually we rely on authRefresh or just updating the UI state.
      // We call authRefresh to be safe and keep the token valid/extended if configured.
      try {
        await _pb.collection('users').authRefresh();
      } catch (_) {
        // Ignore refresh errors (e.g. network) if the update succeeded
      }

      onAuthChange?.call(account);
      return account;
    } catch (error) {
      throw _handleError(error);
    }
  }

  Future<Account?> getUserFromStore() async {
    await _ensureInitialized();

    if (_pb.authStore.isValid) {
      try {
        // FORCE REFRESH from server to get latest data (like verified status)
        // This updates the local authStore with the fresh record from DB
        final authData = await _pb.collection('users').authRefresh();
        final account = _mapRecordToAccount(authData.record);
        return account;
      } catch (e) {
        print('Auth refresh failed (offline?): $e');
        // Fallback to cached record if refresh fails (e.g. no internet)
        if (_pb.authStore.record != null) {
          return _mapRecordToAccount(_pb.authStore.record!);
        }
      }
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
        return 'Thông tin không hợp lệ hoặc đã tồn tại';
      } else if (error.statusCode == 401) {
        return 'Không có quyền truy cập';
      }
      return error.response['message'] ??
          'Đã xảy ra lỗi: ${error.statusCode}';
    }
    return error.toString();
  }
}
