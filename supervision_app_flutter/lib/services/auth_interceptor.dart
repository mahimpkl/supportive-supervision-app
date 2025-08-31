import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'storage_service.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Get access token from storage
    final accessToken = await StorageService.getAccessToken();
    
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Skip token refresh for auth endpoints to avoid loops
    if (err.requestOptions.path.contains('/auth/')) {
      return super.onError(err, handler);
    }

    // Handle 401 Unauthorized errors
    if (err.response?.statusCode == 401) {
      debugPrint('🔑 Token expired, attempting to refresh...');
      
      try {
        final refreshSuccess = await _refreshToken();
        
        if (refreshSuccess) {
          debugPrint('✅ Token refresh successful, retrying original request');
          
          // Get the new access token
          final accessToken = await StorageService.getAccessToken();
          if (accessToken == null) {
            debugPrint('❌ No access token after refresh');
            await _handleAuthFailure();
            return super.onError(err, handler);
          }
          
          // Update the request with new token
          final options = err.requestOptions;
          options.headers['Authorization'] = 'Bearer $accessToken';
          
          // Create a new Dio instance to avoid circular references
          final dio = Dio();
          
          // Copy original request options
          final response = await dio.fetch<dynamic>(
            options..headers.remove(Headers.contentLengthHeader),
          );
          
          // Resolve with the successful response
          return handler.resolve(response);
        } else {
          debugPrint('❌ Token refresh failed');
          await _handleAuthFailure();
        }
      } catch (e) {
        debugPrint('❌ Error during token refresh: $e');
        await _handleAuthFailure();
      }
    }
    
    return super.onError(err, handler);
  }
  
  Future<void> _handleAuthFailure() async {
    // Clear tokens and user data
    await StorageService.clearAll();
    
    // You might want to add navigation to login screen here
    // For example using a global navigator key or a service
    debugPrint('⚠️ Authentication required. Please log in again.');
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await StorageService.getRefreshToken();
      if (refreshToken == null) {
        debugPrint('❌ No refresh token available');
        return false;
      }

      debugPrint('🔄 Refreshing access token...');
      
      final dio = Dio();
      final response = await dio.post<Map<String, dynamic>>(
        'http://192.168.1.69:3000/api/auth/refresh',
        data: {'refreshToken': refreshToken},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!;
        
        if (data['accessToken'] == null || data['refreshToken'] == null) {
          debugPrint('❌ Invalid token response format');
          return false;
        }
        
        await StorageService.saveTokens(
          data['accessToken'],
          data['refreshToken'],
        );
        
        debugPrint('✅ Successfully refreshed tokens');
        return true;
      } else {
        debugPrint('❌ Token refresh failed with status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error refreshing token: $e');
      if (e is DioException) {
        debugPrint('Error details: ${e.response?.data}');
      }
      return false;
    }
  }
}