import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/supervision_form_model.dart';
import '../services/database_helper.dart';
import '../services/sync_service.dart';
import '../services/api_client.dart';

// State classes
class FormsState {
  final List<SupervisionForm> forms;
  final bool isLoading;
  final String? error;
  final SupervisionForm? selectedForm;

  const FormsState({
    this.forms = const [],
    this.isLoading = false,
    this.error,
    this.selectedForm,
  });

  FormsState copyWith({
    List<SupervisionForm>? forms,
    bool? isLoading,
    String? error,
    SupervisionForm? selectedForm,
    bool clearError = false,
    bool clearSelectedForm = false,
  }) {
    return FormsState(
      forms: forms ?? this.forms,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      selectedForm: clearSelectedForm ? null : (selectedForm ?? this.selectedForm),
    );
  }
}

class SyncState {
  final bool isLoading;
  final String? error;
  final DateTime? lastSyncTime;
  final bool hasUnsyncedData;
  final int unsyncedFormsCount;

  const SyncState({
    this.isLoading = false,
    this.error,
    this.lastSyncTime,
    this.hasUnsyncedData = false,
    this.unsyncedFormsCount = 0,
  });

  SyncState copyWith({
    bool? isLoading,
    String? error,
    DateTime? lastSyncTime,
    bool? hasUnsyncedData,
    int? unsyncedFormsCount,
    bool clearError = false,
  }) {
    return SyncState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      hasUnsyncedData: hasUnsyncedData ?? this.hasUnsyncedData,
      unsyncedFormsCount: unsyncedFormsCount ?? this.unsyncedFormsCount,
    );
  }
}

// Forms provider
class FormsNotifier extends StateNotifier<FormsState> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final SyncService _syncService;

  FormsNotifier(this._syncService) : super(const FormsState()) {
    loadForms();
  }

  // Load forms from local database with visit counts
  Future<void> loadForms() async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final forms = await _dbHelper.getForms();
      
      // Load visits for each form to get accurate counts
      final formsWithVisits = <SupervisionForm>[];
      for (final form in forms) {
        final visits = await _dbHelper.getVisitsByFormId(form.id!);
        final formWithVisits = form.copyWith(visits: visits);
        formsWithVisits.add(formWithVisits);
      }
      
      state = state.copyWith(forms: formsWithVisits, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load forms: $e',
      );
    }
  }

  // Create new form
  Future<bool> createForm({
    required String healthFacilityName,
    required String province,
    required String district,
    Map<String, dynamic>? staffTraining,
  }) async {
    try {
      final form = SupervisionForm(
        healthFacilityName: healthFacilityName,
        province: province,
        district: district,
        staffTraining: staffTraining,
      );

      final formId = await _dbHelper.insertForm(form);
      
      // Insert staff training if provided
      if (staffTraining != null) {
        await _dbHelper.insertStaffTraining(formId, staffTraining);
      }

      await loadForms(); // Refresh forms list
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to create form: $e');
      return false;
    }
  }

  // Get form by ID with visits and check if next visit is allowed
  Future<void> getFormDetails(int formId) async {
    state = state.copyWith(isLoading: true);
    
    try {
      final form = await _dbHelper.getFormById(formId);
      if (form != null) {
        // Load visits
        final visits = await _dbHelper.getVisitsByFormId(formId);
        
        // Load staff training
        final staffTraining = await _dbHelper.getStaffTrainingByFormId(formId);
        
        final completeForm = form.copyWith(
          visits: visits,
          staffTraining: staffTraining,
        );
        
        state = state.copyWith(
          selectedForm: completeForm,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Form not found',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load form details: $e',
      );
    }
  }

  // Check if user can create the next visit
  bool canCreateVisit(SupervisionForm form, int visitNumber) {
    // Check if this visit already exists
    final existingVisit = form.visits?.any((v) => v.visitNumber == visitNumber) ?? false;
    if (existingVisit) return false;

    // For visit 1, always allow
    if (visitNumber == 1) return true;

    // For subsequent visits, check if previous visit exists and is synced
    final previousVisit = form.visits?.where((v) => v.visitNumber == visitNumber - 1).firstOrNull;
    if (previousVisit == null) return false;

    // Allow if previous visit is synced (or if offline mode allows unsynced visits)
    return previousVisit.syncStatus == 'synced' || previousVisit.syncStatus == 'verified';
  }

  // Get next available visit number
  int? getNextVisitNumber(SupervisionForm form) {
    final visits = form.visits ?? [];
    if (visits.isEmpty) return 1;
    
    // Find the highest visit number
    final maxVisitNumber = visits.map((v) => v.visitNumber).reduce((a, b) => a > b ? a : b);
    
    // Check if all previous visits are synced
    final allPreviousSynced = visits.where((v) => v.visitNumber < maxVisitNumber + 1)
        .every((v) => v.syncStatus == 'synced' || v.syncStatus == 'verified');
    
    if (!allPreviousSynced) return null; // Cannot create next visit until previous ones are synced
    
    return maxVisitNumber < 4 ? maxVisitNumber + 1 : null;
  }

  // Update form with staff training - enhanced for editing
  Future<bool> updateFormWithStaffTraining(SupervisionForm form) async {
    try {
      // Check if form can be edited (not synced)
      if (form.syncStatus != 'local') {
        state = state.copyWith(error: 'Cannot edit synced form');
        return false;
      }

      await _dbHelper.updateForm(form);
      
      // Update or insert staff training data
      if (form.staffTraining != null) {
        final existingTraining = await _dbHelper.getStaffTrainingByFormId(form.id!);
        if (existingTraining != null) {
          // Update existing staff training
          await _dbHelper.updateStaffTraining(form.id!, form.staffTraining!);
        } else {
          // Insert new staff training
          await _dbHelper.insertStaffTraining(form.id!, form.staffTraining!);
        }
      }

      await loadForms();
      
      // Refresh selected form if it's the one being updated
      if (state.selectedForm?.id == form.id) {
        await getFormDetails(form.id!);
      }
      
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to update form: $e');
      return false;
    }
  }

  // Check if form can be edited
  bool canEditForm(SupervisionForm form) {
    return form.syncStatus == 'local';
  }

  // Check if form can be deleted
  bool canDeleteForm(SupervisionForm form) {
    return form.syncStatus == 'local';
  }

  // Delete form - enhanced validation
  Future<bool> deleteForm(int formId) async {
    try {
      final form = await _dbHelper.getFormById(formId);
      if (form == null) {
        state = state.copyWith(error: 'Form not found');
        return false;
      }

      // Check if form can be deleted (not synced)
      if (form.syncStatus != 'local') {
        state = state.copyWith(error: 'Cannot delete synced form');
        return false;
      }

      await _dbHelper.deleteForm(formId);
      await loadForms();
      
      // Clear selected form if it was the deleted one
      if (state.selectedForm?.id == formId) {
        state = state.copyWith(clearSelectedForm: true);
      }
      
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete form: $e');
      return false;
    }
  }

  // Delete visit - new functionality
  Future<bool> deleteVisit(int visitId) async {
    try {
      // Find the visit
      SupervisionVisit? targetVisit;
      SupervisionForm? parentForm;
      
      for (final form in state.forms) {
        if (form.visits != null) {
          try {
            final visit = form.visits!.firstWhere((v) => v.id == visitId);
            targetVisit = visit;
            parentForm = form;
            break;
          } catch (e) {
            // Visit not found in this form, continue searching
            continue;
          }
        }
      }

      if (targetVisit == null || parentForm == null) {
        state = state.copyWith(error: 'Visit not found');
        return false;
      }

      // Check if visit can be deleted (not synced)
      if (targetVisit.syncStatus != 'local') {
        state = state.copyWith(error: 'Cannot delete synced visit');
        return false;
      }

      await _dbHelper.deleteVisit(visitId);
      
      // Mark parent form as updated
      final updatedForm = parentForm.copyWith(
        updatedAt: DateTime.now(),
      );
      await _dbHelper.updateForm(updatedForm);

      await loadForms();
      
      // Refresh form details if it's currently selected
      if (state.selectedForm?.id == parentForm.id) {
        await getFormDetails(parentForm.id!);
      }
      
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete visit: $e');
      return false;
    }
  }

  // Create visit - enhanced validation
  Future<bool> createVisit({
    required int formId,
    required int visitNumber,
    required DateTime visitDate,
    String? recommendations,
    String? actionsAgreed,
    Map<String, dynamic>? adminManagement,
    Map<String, dynamic>? logistics,
    Map<String, dynamic>? equipment,
    Map<String, dynamic>? mhdcManagement,
    Map<String, dynamic>? serviceStandards,
    Map<String, dynamic>? healthInformation,
    Map<String, dynamic>? integration,
  }) async {
    try {
      // Get current form to validate visit creation
      final currentForm = await _dbHelper.getFormById(formId);
      if (currentForm == null) {
        state = state.copyWith(error: 'Form not found');
        return false;
      }

      final visits = await _dbHelper.getVisitsByFormId(formId);
      final formWithVisits = currentForm.copyWith(visits: visits);

      // Validate if this visit can be created
      if (!canCreateVisit(formWithVisits, visitNumber)) {
        state = state.copyWith(
          error: 'Cannot create visit $visitNumber. Ensure previous visits are synced.'
        );
        return false;
      }

      // Check if visit already exists
      final existingVisit = visits.any((v) => v.visitNumber == visitNumber);
      if (existingVisit) {
        state = state.copyWith(error: 'Visit $visitNumber already exists');
        return false;
      }

      final visit = SupervisionVisit(
        formId: formId,
        visitNumber: visitNumber,
        visitDate: visitDate,
        recommendations: recommendations,
        actionsAgreed: actionsAgreed,
      );

      final visitId = await _dbHelper.insertVisit(visit);

      // Insert section data with proper snake_case keys
      if (adminManagement != null && adminManagement.isNotEmpty) {
        await _dbHelper.insertVisitSection(
          'visit_admin_management_responses',
          visitId,
          adminManagement,
        );
      }
      
      if (logistics != null && logistics.isNotEmpty) {
        await _dbHelper.insertVisitSection(
          'visit_logistics_responses',
          visitId,
          logistics,
        );
      }
      
      if (equipment != null && equipment.isNotEmpty) {
        await _dbHelper.insertVisitSection(
          'visit_equipment_responses',
          visitId,
          equipment,
        );
      }
      
      if (mhdcManagement != null && mhdcManagement.isNotEmpty) {
        await _dbHelper.insertVisitSection(
          'visit_mhdc_management_responses',
          visitId,
          mhdcManagement,
        );
      }
      
      if (serviceStandards != null && serviceStandards.isNotEmpty) {
        await _dbHelper.insertVisitSection(
          'visit_service_standards_responses',
          visitId,
          serviceStandards,
        );
      }
      
      if (healthInformation != null && healthInformation.isNotEmpty) {
        await _dbHelper.insertVisitSection(
          'visit_health_information_responses',
          visitId,
          healthInformation,
        );
      }
      
      if (integration != null && integration.isNotEmpty) {
        await _dbHelper.insertVisitSection(
          'visit_integration_responses',
          visitId,
          integration,
        );
      }

      // Mark form as updated
      final updatedForm = currentForm.copyWith(
        updatedAt: DateTime.now(),
        syncStatus: 'local' // Mark as needing sync since we added a visit
      );
      await _dbHelper.updateForm(updatedForm);

      await loadForms();
      
      // Refresh the selected form if it's the one we updated
      if (state.selectedForm?.id == formId) {
        await getFormDetails(formId);
      }
      
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to create visit: $e');
      return false;
    }
  }

  // Get visit details with all sections
  Future<SupervisionVisit?> getVisitDetails(int visitId) async {
    try {
      // Find the form that contains this visit
      SupervisionForm? parentForm;
      for (final form in state.forms) {
        if (form.visits?.any((v) => v.id == visitId) ?? false) {
          parentForm = form;
          break;
        }
      }

      if (parentForm == null) return null;

      final visits = await _dbHelper.getVisitsByFormId(parentForm.id!);
      final visit = visits.firstWhere((v) => v.id == visitId);
      
      // Load all sections
      final adminManagement = await _dbHelper.getVisitSection(
        'visit_admin_management_responses',
        visitId,
      );
      final logistics = await _dbHelper.getVisitSection(
        'visit_logistics_responses',
        visitId,
      );
      final equipment = await _dbHelper.getVisitSection(
        'visit_equipment_responses',
        visitId,
      );
      final mhdcManagement = await _dbHelper.getVisitSection(
        'visit_mhdc_management_responses',
        visitId,
      );
      final serviceStandards = await _dbHelper.getVisitSection(
        'visit_service_standards_responses',
        visitId,
      );
      final healthInformation = await _dbHelper.getVisitSection(
        'visit_health_information_responses',
        visitId,
      );
      final integration = await _dbHelper.getVisitSection(
        'visit_integration_responses',
        visitId,
      );

      return visit.copyWith(
        adminManagement: adminManagement,
        logistics: logistics,
        equipment: equipment,
        mhdcManagement: mhdcManagement,
        serviceStandards: serviceStandards,
        healthInformation: healthInformation,
        integration: integration,
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to load visit details: $e');
      return null;
    }
  }

  void clearSelectedForm() {
    state = state.copyWith(clearSelectedForm: true);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// Sync provider - enhanced with proper visit handling
class SyncNotifier extends StateNotifier<SyncState> {
  final SyncService _syncService;

  SyncNotifier(this._syncService) : super(const SyncState()) {
    loadSyncStatus();
  }

  Future<void> loadSyncStatus() async {
    try {
      final status = await _syncService.getSyncStatus();
      state = state.copyWith(
        lastSyncTime: status['lastSyncTime'] != null 
            ? DateTime.parse(status['lastSyncTime'])
            : null,
        hasUnsyncedData: status['hasUnsyncedData'] ?? false,
        unsyncedFormsCount: status['unsyncedFormsCount'] ?? 0,
      );
    } catch (e) {
      // Handle error silently for status check
    }
  }

  Future<SyncResult> uploadForms() async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final result = await _syncService.uploadForms();
      
      state = state.copyWith(
        isLoading: false,
        error: result.success ? null : result.message,
      );
      
      if (result.success) {
        await loadSyncStatus();
      }
      
      return result;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Upload failed: $e',
      );
      return SyncResult(
        success: false,
        message: 'Upload failed: $e',
        successCount: 0,
        errorCount: 0,
      );
    }
  }

  Future<SyncResult> downloadForms() async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final result = await _syncService.downloadForms();
      
      state = state.copyWith(
        isLoading: false,
        error: result.success ? null : result.message,
      );
      
      if (result.success) {
        await loadSyncStatus();
      }
      
      return result;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Download failed: $e',
      );
      return SyncResult(
        success: false,
        message: 'Download failed: $e',
        successCount: 0,
        errorCount: 0,
      );
    }
  }

  Future<SyncResult> fullSync() async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final result = await _syncService.fullSync();
      
      state = state.copyWith(
        isLoading: false,
        error: result.success ? null : result.message,
      );
      
      if (result.success) {
        await loadSyncStatus();
      }
      
      return result;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Sync failed: $e',
      );
      return SyncResult(
        success: false,
        message: 'Sync failed: $e',
        successCount: 0,
        errorCount: 0,
      );
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// Providers
final dioProvider = Provider<Dio>((ref) {
  return DioProvider.createDio();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiClient(dio);
});

final syncServiceProvider = Provider<SyncService>((ref) {
  final dio = ref.watch(dioProvider);
  return SyncService(dio);
});

final formsProvider = StateNotifierProvider<FormsNotifier, FormsState>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return FormsNotifier(syncService);
});

final syncProvider = StateNotifierProvider<SyncNotifier, SyncState>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return SyncNotifier(syncService);
});