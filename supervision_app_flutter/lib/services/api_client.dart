import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/user.dart';

part 'api_client.g.dart';

@RestApi(baseUrl: "http://192.168.1.69:3000/api")
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

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
    
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    dio.options.sendTimeout = const Duration(seconds: 30);
    
    // Set default content type for JSON requests
    dio.options.headers['Content-Type'] = 'application/json';
    dio.options.headers['Accept'] = 'application/json';
    
    // Add content-type interceptor to handle JSON serialization
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Ensure JSON content type for POST/PUT requests with body data
        if ((options.method == 'POST' || options.method == 'PUT') && 
            options.data != null && 
            options.headers['Content-Type'] == null) {
          options.headers['Content-Type'] = 'application/json';
        }
        handler.next(options);
      },
    ));
    
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: false,
    ));
    
    return dio;
  }
}