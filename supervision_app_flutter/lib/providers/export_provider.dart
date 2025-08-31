import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supervision_app/providers/forms_provider.dart';
import '../services/export_service.dart';
import '../services/api_client.dart'; // Import for dioProvider

// Export state class
class ExportState {
  final bool isLoading;
  final String? error;
  final ExportSummary? summary;
  final List<ExportRecord> recentExports;

  const ExportState({
    this.isLoading = false,
    this.error,
    this.summary,
    this.recentExports = const [],
  });

  ExportState copyWith({
    bool? isLoading,
    String? error,
    ExportSummary? summary,
    List<ExportRecord>? recentExports,
    bool clearError = false,
  }) {
    return ExportState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      summary: summary ?? this.summary,
      recentExports: recentExports ?? this.recentExports,
    );
  }
}

// Export record for tracking export history
class ExportRecord {
  final String? fileName;
  final String? filePath;
  final DateTime exportedAt;
  final Map<String, dynamic>? filters;

  ExportRecord({
    this.fileName,
    this.filePath,
    required this.exportedAt,
    this.filters,
  });
}

// Export provider notifier
class ExportNotifier extends StateNotifier<ExportState> {
  final ExportService _exportService;

  ExportNotifier(this._exportService) : super(const ExportState());

  // Load export summary
  Future<void> loadExportSummary() async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final summary = await _exportService.getExportSummary();
      state = state.copyWith(
        summary: summary,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load export summary: $e',
      );
    }
  }

  // Export all forms with filters
  Future<ExportResult> exportForms({
    DateTime? startDate,
    DateTime? endDate,
    int? userId,
    String? province,
    String? district,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final result = await _exportService.exportFormsToExcel(
        startDate: startDate,
        endDate: endDate,
        userId: userId,
        province: province,
        district: district,
      );

      if (result.success) {
        // Add to recent exports
        final exportRecord = ExportRecord(
          fileName: result.fileName,
          filePath: result.filePath,
          exportedAt: DateTime.now(),
          filters: {
            if (startDate != null) 'startDate': startDate.toIso8601String(),
            if (endDate != null) 'endDate': endDate.toIso8601String(),
            if (userId != null) 'userId': userId,
            if (province != null) 'province': province,
            if (district != null) 'district': district,
          },
        );

        final updatedExports = [exportRecord, ...state.recentExports];
        state = state.copyWith(
          recentExports: updatedExports.take(10).toList(), // Keep only last 10
        );
      }

      state = state.copyWith(
        isLoading: false,
        error: result.success ? null : result.message,
      );

      return result;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Export failed: $e',
      );
      return ExportResult(
        success: false,
        message: 'Export failed: $e',
      );
    }
  }

  // Export user-specific forms
  Future<ExportResult> exportUserForms(int userId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final result = await _exportService.exportUserForms(userId);
      
      if (result.success) {
        // Add to recent exports
        final exportRecord = ExportRecord(
          fileName: result.fileName,
          filePath: result.filePath,
          exportedAt: DateTime.now(),
          filters: {'userSpecific': true},
        );

        final updatedExports = [exportRecord, ...state.recentExports];
        state = state.copyWith(
          recentExports: updatedExports.take(10).toList(),
        );
      }

      state = state.copyWith(
        isLoading: false,
        error: result.success ? null : result.message,
      );

      return result;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Export failed: $e',
      );
      return ExportResult(
        success: false,
        message: 'Export failed: $e',
      );
    }
  }

  // Open exported file
  Future<bool> openExportedFile(String filePath) async {
    try {
      return await _exportService.openExportedFile(filePath);
    } catch (e) {
      state = state.copyWith(error: 'Failed to open file: $e');
      return false;
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  // Clear recent exports
  void clearRecentExports() {
    state = state.copyWith(recentExports: []);
  }
}

// Provider definitions
final exportServiceProvider = Provider<ExportService>((ref) {
  final dio = ref.watch(dioProvider); // Assumes you have dioProvider from forms_provider
  return ExportService(dio);
});

final exportProvider = StateNotifierProvider<ExportNotifier, ExportState>((ref) {
  final exportService = ref.watch(exportServiceProvider);
  return ExportNotifier(exportService);
});

// Additional helper providers
final canExportProvider = Provider<bool>((ref) {
  // This would check if the user has export permissions
  // For now, return true - you can add proper permission checking
  return true;
});

final exportFiltersProvider = FutureProvider<ExportFilters?>((ref) async {
  final exportService = ref.watch(exportServiceProvider);
  return await exportService.getExportFilters();
});