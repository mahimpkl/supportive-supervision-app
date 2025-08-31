import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/user.dart';
import 'storage_service.dart';
import 'auth_interceptor.dart';

part 'api_client.g.dart';

@RestApi(baseUrl: "http://192.168.1.69:3000/api")
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  // Add these sync endpoints
  @POST("/sync/upload")
  Future<dynamic> uploadForms(@Body() Map<String, dynamic> syncData);

  @GET("/sync/download")
  Future<dynamic> downloadForms(@Queries() Map<String, dynamic> params);

  // Forms endpoints
  @GET("/forms")
  Future<dynamic> getForms(@Queries() Map<String, dynamic> params);

  @POST("/forms")
  Future<dynamic> createForm(@Body() Map<String, dynamic> formData);

  @GET("/forms/{id}")
  Future<dynamic> getFormById(@Path("id") int id);

  @POST("/forms/{id}/visits")
  Future<dynamic> createVisit(@Path("id") int formId, @Body() Map<String, dynamic> visitData);

  // Export endpoints - NEW
  @GET("/export/excel")
  @DioResponseType(ResponseType.bytes)
  Future<List<int>> exportFormsToExcel(@Queries() Map<String, dynamic> params);

  @GET("/export/excel/user/{userId}")
  @DioResponseType(ResponseType.bytes)  
  Future<List<int>> exportUserForms(@Path("userId") int userId);

  @GET("/export/summary")
  Future<dynamic> getExportSummary();

  @GET("/export/filters")
  Future<dynamic> getExportFilters();

  // Keep your existing auth endpoints
  @POST("/auth/login")
  Future<AuthResponse> login(@Body() LoginRequest request);

  @POST("/auth/register")
  Future<AuthResponse> register(@Body() RegisterRequest request);

  @POST("/auth/refresh")
  Future<AuthResponse> refreshToken(@Body() RefreshTokenRequest request);

  @POST("/auth/logout")
  Future<dynamic> logout();

  @GET("/auth/profile")
  Future<dynamic> getProfile();

  @PUT("/auth/change-password")
  Future<dynamic> changePassword(@Body() Map<String, dynamic> request);

  @POST("/auth/verify")
  Future<dynamic> verifyToken();
}

class DioProvider {
  static Dio createDio() {
    final dio = Dio();
    
    // Ensure base URL is set so relative paths work in SyncService
    dio.options.baseUrl = "http://192.168.1.69:3000/api";
    
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    dio.options.sendTimeout = const Duration(seconds: 30);
    
    // Set default content type for JSON requests
    dio.options.headers['Content-Type'] = 'application/json';
    dio.options.headers['Accept'] = 'application/json';
    
    // Add auth interceptor for token management
    dio.interceptors.add(AuthInterceptor());
    
    // Add content-type interceptor
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Special handling for export endpoints - they need different accept headers
        if (options.path.contains('/export/excel')) {
          options.headers['Accept'] = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
          options.responseType = ResponseType.bytes;
        } else {
          // Ensure JSON content type for POST/PUT requests with body data
          if ((options.method == 'POST' || options.method == 'PUT') &&
              options.data != null &&
              options.headers['Content-Type'] == null) {
            options.headers['Content-Type'] = 'application/json';
          }
        }

        // Attach Authorization header if token exists and not already set
        final token = await StorageService.getAccessToken();
        if (token != null && options.headers['Authorization'] == null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        handler.next(options);
      },
      onError: (error, handler) async {
        // Attempt refresh on 401 once
        final response = error.response;
        final requestOptions = error.requestOptions;
        if (response?.statusCode == 401 && requestOptions.extra['retried'] != true) {
          try {
            final refreshToken = await StorageService.getRefreshToken();
            if (refreshToken == null) return handler.next(error);

            // Use a separate Dio without interceptors to refresh
            final refreshDio = Dio()
              ..options.baseUrl = dio.options.baseUrl
              ..options.headers['Content-Type'] = 'application/json'
              ..options.connectTimeout = dio.options.connectTimeout
              ..options.receiveTimeout = dio.options.receiveTimeout
              ..options.sendTimeout = dio.options.sendTimeout;

            final refreshResp = await refreshDio.post('/auth/refresh', data: {
              'refreshToken': refreshToken,
            });

            if (refreshResp.statusCode == 200) {
              final data = refreshResp.data as Map<String, dynamic>;
              final newAccess = data['accessToken'] as String?;
              final newRefresh = data['refreshToken'] as String?;

              if (newAccess != null && newRefresh != null) {
                await StorageService.saveTokens(newAccess, newRefresh);

                // Set retried flag and update Authorization
                requestOptions.headers['Authorization'] = 'Bearer $newAccess';
                requestOptions.extra['retried'] = true;

                // Retry original request using the same dio
                final result = await dio.fetch(requestOptions);
                return handler.resolve(result);
              }
            }
          } catch (_) {
            // Fall through to next handler to surface the original error
          }
        }

        handler.next(error);
      },
    ));
    
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: false, // Don't log binary response bodies (Excel files)
      requestHeader: true,
      responseHeader: false,
    ));
    
    return dio;
  }
}