import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/user.dart';
import '../services/api_client.dart';
import '../services/storage_service.dart';

part 'auth_provider.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    User? user,
    @Default(false) bool isLoading,
    @Default(false) bool isAuthenticated,
    String? error,
  }) = _AuthState;
}

class AuthNotifier extends StateNotifier<AuthState> {
  late ApiClient _apiClient;

  AuthNotifier() : super(const AuthState()) {
    _apiClient = ApiClient(DioProvider.createDio());
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      state = state.copyWith(isLoading: true);
      
      final isLoggedIn = await StorageService.isLoggedIn();
      if (isLoggedIn) {
        final user = await StorageService.getUser();
        final accessToken = await StorageService.getAccessToken();
        
        if (user != null && accessToken != null) {
          // Add token to dio headers
          _apiClient = ApiClient(
            DioProvider.createDio()..options.headers['Authorization'] = 'Bearer $accessToken',
          );
          
          state = state.copyWith(
            user: user,
            isAuthenticated: true,
            isLoading: false,
          );
        }
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to initialize authentication',
      );
    }
  }

  Future<bool> login(String username, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final loginRequest = LoginRequest(username: username, password: password);
      final response = await _apiClient.login(loginRequest);

      await StorageService.saveTokens(response.accessToken, response.refreshToken);
      await StorageService.saveUser(response.user);

      // Update dio headers
      _apiClient = ApiClient(
        DioProvider.createDio()..options.headers['Authorization'] = 'Bearer ${response.accessToken}',
      );

      state = state.copyWith(
        user: response.user,
        isAuthenticated: true,
        isLoading: false,
      );

      return true;
    } on DioException catch (e) {
      final errorMessage = _handleDioError(e);
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
      return false;
    }
  }

  Future<bool> register(String username, String email, String password, String fullName) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final registerRequest = RegisterRequest(
        username: username,
        email: email,
        password: password,
        fullName: fullName,
        role: 'user', // Set default role to 'user'
      );
      final response = await _apiClient.register(registerRequest);

      await StorageService.saveTokens(response.accessToken, response.refreshToken);
      await StorageService.saveUser(response.user);

      // Update dio headers
      _apiClient = ApiClient(
        DioProvider.createDio()..options.headers['Authorization'] = 'Bearer ${response.accessToken}',
      );

      state = state.copyWith(
        user: response.user,
        isAuthenticated: true,
        isLoading: false,
      );

      return true;
    } on DioException catch (e) {
      final errorMessage = _handleDioError(e);
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
      return false;
    }
  }

  Future<bool> refreshToken() async {
    try {
      final refreshToken = await StorageService.getRefreshToken();
      if (refreshToken == null) return false;

      final refreshRequest = RefreshTokenRequest(refreshToken: refreshToken);
      final response = await _apiClient.refreshToken(refreshRequest);

      await StorageService.saveTokens(response.accessToken, response.refreshToken);
      await StorageService.saveUser(response.user);

      // Update dio headers
      _apiClient = ApiClient(
        DioProvider.createDio()..options.headers['Authorization'] = 'Bearer ${response.accessToken}',
      );

      state = state.copyWith(
        user: response.user,
        isAuthenticated: true,
      );

      return true;
    } catch (e) {
      await logout();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      // Try to logout on server - the response is dynamic so we don't need to process it
      await _apiClient.logout();
    } catch (e) {
      // Continue with local logout even if server logout fails
      print('Server logout failed: $e');
    }

    await StorageService.clearAll();
    _apiClient = ApiClient(DioProvider.createDio());
    
    state = const AuthState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;
        
        if (statusCode == 401) {
          return data?['message'] ?? 'Invalid credentials';
        } else if (statusCode == 409) {
          return data?['message'] ?? 'Username or email already exists';
        } else if (statusCode == 429) {
          return data?['message'] ?? 'Too many requests. Please try again later.';
        } else {
          return data?['message'] ?? 'Server error occurred';
        }
      case DioExceptionType.cancel:
        return 'Request was cancelled';
      case DioExceptionType.connectionError:
        return 'No internet connection';
      default:
        return 'An unexpected error occurred';
    }
  }
}

// Provider for auth state
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});