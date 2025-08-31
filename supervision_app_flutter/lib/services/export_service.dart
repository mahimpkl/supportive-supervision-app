import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'dart:typed_data';
import 'api_client.dart';
import 'storage_service.dart';

class ExportService {
  final ApiClient _apiClient;

  ExportService(Dio dio) : _apiClient = ApiClient(dio);

  // Export all forms to Excel (Admin only)
  Future<ExportResult> exportFormsToExcel({
    DateTime? startDate,
    DateTime? endDate,
    int? userId,
    String? province,
    String? district,
  }) async {
    try {
      // Skip permission check - use app-specific directory instead
      print('Starting export without permission check...');

      // Build query parameters
      final queryParams = <String, dynamic>{};
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String().split('T')[0];
      }
      if (userId != null) {
        queryParams['userId'] = userId;
      }
      if (province != null && province.isNotEmpty) {
        queryParams['province'] = province;
      }
      if (district != null && district.isNotEmpty) {
        queryParams['district'] = district;
      }

      print('Exporting with filters: $queryParams');

      // Make API request through ApiClient
      final responseData = await _apiClient.exportFormsToExcel(queryParams);

      if (responseData.isNotEmpty) {
        // Generate filename since we don't have access to headers
        final timestamp = DateTime.now().toIso8601String().split('T')[0];
        String fileName = 'supervision_forms_export_$timestamp.xlsx';
        
        // Add filter info to filename
        if (province != null && province.isNotEmpty) {
          fileName = 'supervision_forms_${province.toLowerCase()}_$timestamp.xlsx';
        }
        if (userId != null) {
          fileName = 'supervision_forms_user${userId}_$timestamp.xlsx';
        }

        // Use app-specific directory that doesn't require permissions
        Directory? directory;
        String filePath;
        
        try {
          // Try external storage directory first (app-specific, no permission needed)
          directory = await getExternalStorageDirectory();
          if (directory != null) {
            filePath = '${directory.path}/$fileName';
          } else {
            // Fallback to application documents directory
            directory = await getApplicationDocumentsDirectory();
            filePath = '${directory.path}/$fileName';
          }
        } catch (e) {
          print('Error getting directory: $e');
          // Final fallback to application documents directory
          directory = await getApplicationDocumentsDirectory();
          filePath = '${directory.path}/$fileName';
        }
        
        final file = File(filePath);
        
        // Convert List<int> to Uint8List and write
        final bytes = Uint8List.fromList(responseData);
        await file.writeAsBytes(bytes);

        print('Export saved to: $filePath');

        return ExportResult(
          success: true,
          message: 'Export completed successfully. File saved to app folder.',
          filePath: filePath,
          fileName: fileName,
        );
      } else {
        return ExportResult(
          success: false,
          message: 'Export failed: No data received from server',
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Export failed';
      
      if (e.response?.statusCode == 403) {
        errorMessage = 'Access denied. Admin privileges required.';
      } else if (e.response?.statusCode == 404) {
        errorMessage = 'No data found matching the criteria';
      } else if (e.response?.statusCode == 401) {
        errorMessage = 'Authentication failed. Please log in again.';
      } else if (e.response?.data != null) {
        try {
          final errorData = e.response!.data;
          if (errorData is Map<String, dynamic>) {
            errorMessage = errorData['message'] ?? errorMessage;
          } else if (errorData is String) {
            errorMessage = errorData;
          }
        } catch (_) {
          errorMessage = e.message ?? errorMessage;
        }
      } else {
        errorMessage = e.message ?? errorMessage;
      }

      print('Export error: $errorMessage');

      return ExportResult(
        success: false,
        message: errorMessage,
      );
    } catch (e) {
      print('Unexpected export error: $e');
      return ExportResult(
        success: false,
        message: 'Export failed: $e',
      );
    }
  }

  // Export user-specific forms
  Future<ExportResult> exportUserForms(int userId) async {
    try {
      // Skip permission check - use app-specific directory instead
      print('Starting user export without permission check...');

      print('Exporting forms for user: $userId');

      // Make API request through ApiClient
      final responseData = await _apiClient.exportUserForms(userId);

      if (responseData.isNotEmpty) {
        // Generate filename since we don't have access to headers
        final timestamp = DateTime.now().toIso8601String().split('T')[0];
        String fileName = 'user_${userId}_forms_$timestamp.xlsx';

        // Use app-specific directory that doesn't require permissions
        Directory? directory;
        String filePath;
        
        try {
          // Try external storage directory first (app-specific, no permission needed)
          directory = await getExternalStorageDirectory();
          if (directory != null) {
            filePath = '${directory.path}/$fileName';
          } else {
            // Fallback to application documents directory
            directory = await getApplicationDocumentsDirectory();
            filePath = '${directory.path}/$fileName';
          }
        } catch (e) {
          print('Error getting directory: $e');
          // Final fallback to application documents directory
          directory = await getApplicationDocumentsDirectory();
          filePath = '${directory.path}/$fileName';
        }
        
        final file = File(filePath);
        
        // Convert List<int> to Uint8List and write
        final bytes = Uint8List.fromList(responseData);
        await file.writeAsBytes(bytes);

        print('User export saved to: $filePath');

        return ExportResult(
          success: true,
          message: 'Your forms exported successfully. File saved to app folder.',
          filePath: filePath,
          fileName: fileName,
        );
      } else {
        return ExportResult(
          success: false,
          message: 'Export failed: No data received from server',
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Export failed';
      
      if (e.response?.statusCode == 403) {
        errorMessage = 'Access denied. You can only export your own data.';
      } else if (e.response?.statusCode == 404) {
        errorMessage = 'No forms found for this user';
      } else if (e.response?.statusCode == 401) {
        errorMessage = 'Authentication failed. Please log in again.';
      } else if (e.response?.data != null) {
        try {
          final errorData = e.response!.data;
          if (errorData is Map<String, dynamic>) {
            errorMessage = errorData['message'] ?? errorMessage;
          } else if (errorData is String) {
            errorMessage = errorData;
          }
        } catch (_) {
          errorMessage = e.message ?? errorMessage;
        }
      } else {
        errorMessage = e.message ?? errorMessage;
      }

      return ExportResult(
        success: false,
        message: errorMessage,
      );
    } catch (e) {
      return ExportResult(
        success: false,
        message: 'Export failed: $e',
      );
    }
  }

  // Get export summary statistics
  Future<ExportSummary?> getExportSummary() async {
    try {
      print('Fetching export summary...');

      final response = await _apiClient.getExportSummary();

      if (response != null && response is Map<String, dynamic>) {
        return ExportSummary.fromJson(response);
      }

      return null;
    } on DioException catch (e) {
      print('Error fetching export summary: ${e.message}');
      
      if (e.response?.statusCode == 403) {
        print('Access denied for export summary - user may not have admin privileges');
        return null;
      } else if (e.response?.statusCode == 401) {
        print('Authentication failed for export summary');
        throw Exception('Authentication failed. Please log in again.');
      }
      
      return null;
    } catch (e) {
      print('Unexpected error fetching export summary: $e');
      return null;
    }
  }

  // Get available export filters (provinces, districts)
  Future<ExportFilters?> getExportFilters() async {
    try {
      print('Fetching export filters...');

      final response = await _apiClient.getExportFilters();

      if (response != null && response is Map<String, dynamic>) {
        return ExportFilters.fromJson(response);
      }

      return null;
    } on DioException catch (e) {
      print('Error fetching export filters: ${e.message}');
      
      if (e.response?.statusCode == 404) {
        print('Export filters endpoint not available');
        return null;
      }
      
      return null;
    } catch (e) {
      print('Unexpected error fetching export filters: $e');
      return null;
    }
  }

  // Open exported file
  Future<bool> openExportedFile(String filePath) async {
    try {
      final file = File(filePath);
      
      if (!await file.exists()) {
        print('File not found: $filePath');
        return false;
      }

      print('Opening file: $filePath');
      final result = await OpenFile.open(filePath);
      
      if (result.type == ResultType.done) {
        print('File opened successfully');
        return true;
      } else {
        print('Failed to open file: ${result.message}');
        return false;
      }
    } catch (e) {
      print('Error opening file: $e');
      return false;
    }
  }

  // Share exported file (placeholder for future implementation)
  Future<void> shareExportedFile(String filePath) async {
    try {
      print('Sharing file: $filePath');
    } catch (e) {
      print('Error sharing file: $e');
    }
  }

  // Check if file exists at given path
  Future<bool> fileExists(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  // Delete exported file
  Future<bool> deleteExportedFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        print('Deleted file: $filePath');
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting file: $e');
      return false;
    }
  }

  // Get file size in bytes
  Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  // Format file size for display
  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

class ExportResult {
  final bool success;
  final String message;
  final String? filePath;
  final String? fileName;

  ExportResult({
    required this.success,
    required this.message,
    this.filePath,
    this.fileName,
  });

  @override
  String toString() {
    return 'ExportResult(success: $success, message: $message, filePath: $filePath, fileName: $fileName)';
  }
}

class ExportSummary {
  final SummaryStats summary;
  final List<ProvinceStats> byProvince;
  final List<RecentActivity> recentActivity;

  ExportSummary({
    required this.summary,
    required this.byProvince,
    required this.recentActivity,
  });

  factory ExportSummary.fromJson(Map<String, dynamic> json) {
    return ExportSummary(
      summary: SummaryStats.fromJson(json['summary'] ?? {}),
      byProvince: (json['byProvince'] as List? ?? [])
          .map((item) => ProvinceStats.fromJson(item))
          .toList(),
      recentActivity: (json['recentActivity'] as List? ?? [])
          .map((item) => RecentActivity.fromJson(item))
          .toList(),
    );
  }
}

class SummaryStats {
  final int totalForms;
  final int totalUsers;
  final int totalFacilities;
  final int totalProvinces;
  final int totalDistricts;
  final int totalVisits;
  final VisitBreakdown visitBreakdown;
  final SyncStatus syncStatus;

  SummaryStats({
    required this.totalForms,
    required this.totalUsers,
    required this.totalFacilities,
    required this.totalProvinces,
    required this.totalDistricts,
    required this.totalVisits,
    required this.visitBreakdown,
    required this.syncStatus,
  });

  factory SummaryStats.fromJson(Map<String, dynamic> json) {
    return SummaryStats(
      totalForms: json['totalForms'] ?? 0,
      totalUsers: json['totalUsers'] ?? 0,
      totalFacilities: json['totalFacilities'] ?? 0,
      totalProvinces: json['totalProvinces'] ?? 0,
      totalDistricts: json['totalDistricts'] ?? 0,
      totalVisits: json['totalVisits'] ?? 0,
      visitBreakdown: VisitBreakdown.fromJson(json['visitBreakdown'] ?? {}),
      syncStatus: SyncStatus.fromJson(json['syncStatus'] ?? {}),
    );
  }
}

class VisitBreakdown {
  final int visit1;
  final int visit2;
  final int visit3;
  final int visit4;

  VisitBreakdown({
    required this.visit1,
    required this.visit2,
    required this.visit3,
    required this.visit4,
  });

  factory VisitBreakdown.fromJson(Map<String, dynamic> json) {
    return VisitBreakdown(
      visit1: json['visit1'] ?? 0,
      visit2: json['visit2'] ?? 0,
      visit3: json['visit3'] ?? 0,
      visit4: json['visit4'] ?? 0,
    );
  }
}

class SyncStatus {
  final int local;
  final int synced;
  final int verified;

  SyncStatus({
    required this.local,
    required this.synced,
    required this.verified,
  });

  factory SyncStatus.fromJson(Map<String, dynamic> json) {
    return SyncStatus(
      local: json['local'] ?? 0,
      synced: json['synced'] ?? 0,
      verified: json['verified'] ?? 0,
    );
  }
}

class ProvinceStats {
  final String province;
  final int formCount;
  final int facilityCount;
  final int visitCount;

  ProvinceStats({
    required this.province,
    required this.formCount,
    required this.facilityCount,
    required this.visitCount,
  });

  factory ProvinceStats.fromJson(Map<String, dynamic> json) {
    return ProvinceStats(
      province: json['province'] ?? '',
      formCount: json['formCount'] ?? 0,
      facilityCount: json['facilityCount'] ?? 0,
      visitCount: json['visitCount'] ?? 0,
    );
  }
}

class RecentActivity {
  final String facilityName;
  final String province;
  final String district;
  final String doctorName;
  final DateTime createdAt;
  final String syncStatus;
  final int visitCount;
  final DateTime? lastVisitDate;

  RecentActivity({
    required this.facilityName,
    required this.province,
    required this.district,
    required this.doctorName,
    required this.createdAt,
    required this.syncStatus,
    required this.visitCount,
    this.lastVisitDate,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      facilityName: json['facilityName'] ?? '',
      province: json['province'] ?? '',
      district: json['district'] ?? '',
      doctorName: json['doctorName'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      syncStatus: json['syncStatus'] ?? '',
      visitCount: json['visitCount'] ?? 0,
      lastVisitDate: json['lastVisitDate'] != null 
          ? DateTime.parse(json['lastVisitDate'])
          : null,
    );
  }
}

class ExportFilters {
  final List<String> provinces;
  final List<String> districts;

  ExportFilters({
    required this.provinces,
    required this.districts,
  });

  factory ExportFilters.fromJson(Map<String, dynamic> json) {
    return ExportFilters(
      provinces: List<String>.from(json['provinces'] ?? []),
      districts: List<String>.from(json['districts'] ?? []),
    );
  }
}