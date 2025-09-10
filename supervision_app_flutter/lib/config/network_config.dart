import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class NetworkConfig {
  static const String _realDeviceIP = "192.168.1.69";
  static const String _emulatorIP = "10.0.2.2";
  static const String _localhostIP = "127.0.0.1";
  static const int _port = 3000;
  
  // Get the appropriate IP based on platform and device type
  static Future<String> getBaseUrl() async {
    final ip = await _getServerIP();
    return "http://$ip:$_port/api";
  }
  
  static Future<String> _getServerIP() async {
    if (Platform.isAndroid) {
      final isEmulator = await _isAndroidEmulator();
      return isEmulator ? _emulatorIP : _realDeviceIP;
    } else if (Platform.isIOS) {
      final isSimulator = await _isIOSSimulator();
      return isSimulator ? _localhostIP : _realDeviceIP;
    } else {
      // Desktop/Web
      return _localhostIP;
    }
  }
  
  static Future<bool> _isAndroidEmulator() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      
      // Check multiple indicators for emulator
      return androidInfo.isPhysicalDevice == false ||
             androidInfo.model.toLowerCase().contains('emulator') ||
             androidInfo.product.toLowerCase().contains('emulator') ||
             androidInfo.fingerprint.toLowerCase().contains('generic') ||
             androidInfo.hardware.toLowerCase().contains('goldfish') ||
             androidInfo.hardware.toLowerCase().contains('ranchu');
    } catch (e) {
      // Fallback to environment variable check
      return Platform.environment['ANDROID_EMULATOR'] == 'true';
    }
  }
  
  static Future<bool> _isIOSSimulator() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.isPhysicalDevice == false;
    } catch (e) {
      // Fallback to environment variable check
      return Platform.environment['SIMULATOR_DEVICE_NAME'] != null;
    }
  }
  
  // Manual IP configuration for development
  static String? _manualIP;
  
  static void setManualIP(String? ip) {
    _manualIP = ip;
  }
  
  static Future<String> getEffectiveBaseUrl() async {
    if (_manualIP != null) {
      return "http://$_manualIP:$_port/api";
    }
    return await getBaseUrl();
  }
  
  // Quick access methods for different environments
  static String getRealDeviceUrl() => "http://$_realDeviceIP:$_port/api";
  static String getEmulatorUrl() => "http://$_emulatorIP:$_port/api";
  static String getLocalhostUrl() => "http://$_localhostIP:$_port/api";
}
