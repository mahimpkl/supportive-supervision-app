import 'dart:io';

class AppConfig {
  // Base URLs for different environments
  static const String _realDeviceBaseUrl = "http://192.168.1.69:3000/api";
  static const String _emulatorBaseUrl = "http://10.0.2.2:3000/api";
  static const String _localhostBaseUrl = "http://localhost:3000/api";
  
  // Get the appropriate base URL based on the platform and environment
  static String get baseUrl {
    if (Platform.isAndroid) {
      // Check if running on emulator by trying to detect emulator characteristics
      return _isEmulator() ? _emulatorBaseUrl : _realDeviceBaseUrl;
    } else if (Platform.isIOS) {
      // iOS simulator uses localhost, real device uses the network IP
      return _isSimulator() ? _localhostBaseUrl : _realDeviceBaseUrl;
    } else {
      // Desktop/Web development
      return _localhostBaseUrl;
    }
  }
  
  // Alternative method to manually set environment
  static String getBaseUrlForEnvironment(AppEnvironment environment) {
    switch (environment) {
      case AppEnvironment.realDevice:
        return _realDeviceBaseUrl;
      case AppEnvironment.androidEmulator:
        return _emulatorBaseUrl;
      case AppEnvironment.localhost:
        return _localhostBaseUrl;
    }
  }
  
  // Detect if running on Android emulator
  static bool _isEmulator() {
    // This is a heuristic approach - you can also use device_info_plus package for more accurate detection
    return Platform.environment['ANDROID_EMULATOR'] == 'true' ||
           Platform.environment['FLUTTER_TEST'] == 'true';
  }
  
  // Detect if running on iOS simulator
  static bool _isSimulator() {
    // iOS simulator detection
    return Platform.environment['SIMULATOR_DEVICE_NAME'] != null;
  }
  
  // Network configuration
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
  
  // API endpoints
  static const String syncUploadEndpoint = "/sync/upload";
  static const String syncDownloadEndpoint = "/sync/download";
  static const String formsEndpoint = "/forms";
  static const String authLoginEndpoint = "/auth/login";
  static const String authRegisterEndpoint = "/auth/register";
  static const String authRefreshEndpoint = "/auth/refresh";
  static const String exportExcelEndpoint = "/export/excel";
  
  // Debug settings
  static const bool enableNetworkLogs = true;
  static const bool enableRequestBody = true;
  static const bool enableResponseBody = false; // Disabled for binary data like Excel files
}

enum AppEnvironment {
  realDevice,
  androidEmulator,
  localhost,
}

// Extension for easy environment switching during development
extension AppConfigExtension on AppConfig {
  // Method to override base URL for testing
  static String? _overrideBaseUrl;
  
  static void setBaseUrlOverride(String? url) {
    _overrideBaseUrl = url;
  }
  
  static String get effectiveBaseUrl {
    return _overrideBaseUrl ?? AppConfig.baseUrl;
  }
}
