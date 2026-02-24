import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/storage_service.dart';
import 'user_model.dart';
import 'dart:convert';

class AuthService {
  final StorageService _storage;
  final ApiClient _apiClient;

  AuthService(this._storage, this._apiClient) {
    final currentUser = getCurrentUser();
    _apiClient.setAuthToken(currentUser?.token);
  }

  static const String _userKey = 'auth_user';

  Future<User?> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        '/auth/login',
        data: {
          'email': email.trim(),
          'password': password,
        },
      );

      final user = _mapAuthResponseToUser(response.data);
      await saveUser(user);
      _apiClient.setAuthToken(user.token);
      return user;
    } on DioException {
      return null;
    }
  }

  Future<User?> register(
    String name,
    String email,
    String password, {
    String lastName = '',
    String role = 'FARMER',
    String organization = '',
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/register',
        data: {
          'email': email.trim(),
          'password': password,
          'firstName': name.trim(),
          'lastName': lastName.trim(),
          'role': role,
          'organization': organization,
        },
      );

      final user = _mapAuthResponseToUser(response.data);
      await saveUser(user);
      _apiClient.setAuthToken(user.token);
      return user;
    } on DioException {
      return null;
    }
  }

  User _mapAuthResponseToUser(dynamic data) {
    final json = Map<String, dynamic>.from(data as Map);
    final email = (json['email'] ?? '').toString();
    final firstName = (json['firstName'] ?? '').toString().trim();
    final lastName = (json['lastName'] ?? '').toString().trim();

    return User(
      id: email,
      name: [firstName, lastName].where((part) => part.isNotEmpty).join(' ').trim(),
      email: email,
      token: (json['token'] ?? '').toString(),
    );
  }

  Future<void> saveUser(User user) async {
    await _storage.setString(_userKey, jsonEncode(user.toJson()));
  }

  User? getCurrentUser() {
    final userData = _storage.getString(_userKey);
    if (userData != null) {
      return User.fromJson(jsonDecode(userData));
    }
    return null;
  }

  Future<void> logout() async {
    _apiClient.setAuthToken(null);
    await _storage.remove(_userKey);
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  final storage = ref.watch(storageServiceProvider);
  final apiClient = ref.watch(apiClientProvider);
  return AuthService(storage, apiClient);
});

final authStateProvider = StateProvider<User?>((ref) {
  final service = ref.watch(authServiceProvider);
  return service.getCurrentUser();
});
