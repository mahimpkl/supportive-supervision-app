import 'package:dio/dio.dart';
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
    if (err.response?.statusCode == 401) {
      // Token expired, try to refresh
      final refreshSuccess = await _refreshToken();
      
      if (refreshSuccess) {
        // Retry the request with new token
        final accessToken = await StorageService.getAccessToken();
        final options = err.requestOptions;
        options.headers['Authorization'] = 'Bearer $accessToken';
        
        try {
          final dio = Dio();
          final response = await dio.fetch(options);
          handler.resolve(response);
          return;
        } catch (e) {
          // If retry fails, proceed with original error
        }
      } else {
        // Refresh failed, clear storage and redirect to login
        await StorageService.clearAll();
      }
    }
    
    super.onError(err, handler);
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await StorageService.getRefreshToken();
      if (refreshToken == null) return false;

      final dio = Dio();
      final response = await dio.post(
        'http://localhost:3000/api/auth/refresh', // Change to your API URL
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        await StorageService.saveTokens(
          data['accessToken'],
          data['refreshToken'],
        );
        return true;
      }
    } catch (e) {
      print('Token refresh failed: $e');
    }
    
    return false;
  }
}