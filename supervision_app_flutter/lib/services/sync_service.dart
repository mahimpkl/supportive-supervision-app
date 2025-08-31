import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import 'database_helper.dart';
import 'storage_service.dart';
import '../models/supervision_form_model.dart';

class SyncService {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final Dio _dio;

  SyncService(this._dio);

  // Upload local forms to server
  Future<SyncResult> uploadForms() async {
    // Declare here so it's accessible in catch
    List<SupervisionForm> unsyncedForms = [];
    try {
      // Get unsynced forms from local database
      unsyncedForms = await _dbHelper.getUnsyncedForms();
      
      if (unsyncedForms.isEmpty) {
        return SyncResult(
          success: true,
          message: 'No forms to sync',
          successCount: 0,
          errorCount: 0,
        );
      }

      // Get device ID
      final deviceId = await _getDeviceId();

      // Prepare forms for upload with complete visit data
      final List<Map<String, dynamic>> formsToSync = [];
      
      for (final form in unsyncedForms) {
        // Get visits for this form
        final visits = await _dbHelper.getVisitsByFormId(form.id!);
        
        // Get staff training data
        final staffTraining = await _dbHelper.getStaffTrainingByFormId(form.id!);
        
        // Get complete visit data with all sections
        final List<Map<String, dynamic>> completeVisits = [];
        
        for (final visit in visits) {
          final visitData = visit.toServerJson();
          
          // Get all visit sections
          visitData['adminManagement'] = await _dbHelper.getVisitSection(
            'visit_admin_management_responses', 
            visit.id!
          );
          visitData['logistics'] = await _dbHelper.getVisitSection(
            'visit_logistics_responses', 
            visit.id!
          );
          visitData['equipment'] = await _dbHelper.getVisitSection(
            'visit_equipment_responses', 
            visit.id!
          );
          visitData['mhdcManagement'] = await _dbHelper.getVisitSection(
            'visit_mhdc_management_responses', 
            visit.id!
          );
          visitData['serviceStandards'] = await _dbHelper.getVisitSection(
            'visit_service_standards_responses', 
            visit.id!
          );
          visitData['healthInformation'] = await _dbHelper.getVisitSection(
            'visit_health_information_responses', 
            visit.id!
          );
          visitData['integration'] = await _dbHelper.getVisitSection(
            'visit_integration_responses', 
            visit.id!
          );
          
          // Remove null values
          visitData.removeWhere((key, value) => value == null);
          completeVisits.add(visitData);
        }

        final formData = form.toServerJson();
        formData['visits'] = completeVisits;
        if (staffTraining != null) {
          formData['staffTraining'] = staffTraining;
        }
        
        formsToSync.add(formData);
      }

      // Prepare sync data
      final syncData = {
        'forms': formsToSync,
        'deviceId': deviceId,
      };

      // Make API call
      final response = await _dio.post('/sync/upload', data: syncData);
      
      if (response.statusCode == 200) {
        final responseData = response.data;
        final uploadResults = responseData['uploadResults'] as List;
        
        // Update local forms with server IDs
        for (final result in uploadResults) {
          if (result['status'] == 'success') {
            final tempId = result['tempId'];
            final serverId = result['serverId'];
            
            // Find local form by tempId
            final localForm = unsyncedForms.firstWhere(
              (form) => form.tempId == tempId
            );
            
            // Mark as synced
            await _dbHelper.markFormAsSynced(localForm.id!, serverId);
            
            // Update visits sync status
            final visits = await _dbHelper.getVisitsByFormId(localForm.id!);
            for (final visit in visits) {
              await _dbHelper.updateVisit(visit.copyWith(syncStatus: 'synced'));
            }
          }
        }

        // Update last sync time
        await StorageService.setLastSyncTime(DateTime.now());

        return SyncResult(
          success: true,
          message: responseData['message'],
          successCount: responseData['successCount'],
          errorCount: responseData['errorCount'],
          errors: responseData['errors'] != null 
              ? (responseData['errors'] as List).map((e) => SyncError.fromJson(e)).toList()
              : null,
        );
      } else {
        throw Exception('Upload failed: ${response.statusMessage}');
      }
      
    } catch (e) {
      return SyncResult(
        success: false,
        message: 'Upload failed: $e',
        successCount: 0,
        errorCount: unsyncedForms.length,
      );
    }
  }

  // Download updated forms from server
  Future<SyncResult> downloadForms() async {
    try {
      final lastSync = await StorageService.getLastSyncTime();
      final deviceId = await _getDeviceId();

      final queryParams = <String, dynamic>{
        'deviceId': deviceId,
      };

      if (lastSync != null) {
        queryParams['lastSync'] = lastSync.toIso8601String();
      }

      final response = await _dio.get('/sync/download', queryParameters: queryParams);
      
      if (response.statusCode == 200) {
        final responseData = response.data;
        final forms = responseData['forms'] as List;
        
        int updatedCount = 0;
        
        // Process downloaded forms
        for (final formJson in forms) {
          await _processDownloadedForm(formJson);
          updatedCount++;
        }

        // Update last sync time
        await StorageService.setLastSyncTime(DateTime.now());

        return SyncResult(
          success: true,
          message: responseData['message'],
          successCount: updatedCount,
          errorCount: 0,
        );
      } else {
        throw Exception('Download failed: ${response.statusMessage}');
      }
      
    } catch (e) {
      return SyncResult(
        success: false,
        message: 'Download failed: $e',
        successCount: 0,
        errorCount: 0,
      );
    }
  }

  // Process a downloaded form and update local database
  Future<void> _processDownloadedForm(Map<String, dynamic> formJson) async {
    final form = SupervisionForm.fromJson(formJson);
    
    // Check if form exists locally by server_id or temp_id
    final existingForms = await _dbHelper.getForms();
    SupervisionForm? existingForm;
    
    for (final localForm in existingForms) {
      if ((form.serverId != null && localForm.serverId == form.serverId) ||
          localForm.tempId == form.tempId) {
        existingForm = localForm;
        break;
      }
    }

    if (existingForm != null) {
      // Update existing form
      final updatedForm = existingForm.copyWith(
        serverId: form.serverId,
        syncStatus: form.syncStatus,
        updatedAt: form.updatedAt,
      );
      await _dbHelper.updateForm(updatedForm);
      
      // Update visits
      if (formJson['visits'] != null) {
        await _processDownloadedVisits(existingForm.id!, formJson['visits']);
      }
    } else {
      // Insert new form
      final newFormId = await _dbHelper.insertForm(form);
      
      // Insert staff training if present
      if (formJson['staffTraining'] != null) {
        await _dbHelper.insertStaffTraining(newFormId, formJson['staffTraining']);
      }
      
      // Insert visits
      if (formJson['visits'] != null) {
        await _processDownloadedVisits(newFormId, formJson['visits']);
      }
    }
  }

  Future<void> _processDownloadedVisits(int formId, List visitJsons) async {
    for (final visitJson in visitJsons) {
      final visit = SupervisionVisit.fromJson(visitJson);
      
      // Check if visit exists locally
      final localVisits = await _dbHelper.getVisitsByFormId(formId);
      SupervisionVisit? existingVisit;
      
      for (final localVisit in localVisits) {
        if ((visit.serverId != null && localVisit.serverId == visit.serverId) ||
            localVisit.visitNumber == visit.visitNumber) {
          existingVisit = localVisit;
          break;
        }
      }

      int visitId;
      if (existingVisit != null) {
        // Update existing visit
        final updatedVisit = existingVisit.copyWith(
          serverId: visit.serverId,
          syncStatus: visit.syncStatus,
          updatedAt: visit.updatedAt,
          recommendations: visit.recommendations,
          actionsAgreed: visit.actionsAgreed,
        );
        await _dbHelper.updateVisit(updatedVisit);
        visitId = existingVisit.id!;
      } else {
        // Insert new visit
        final newVisit = visit.copyWith(formId: formId);
        visitId = await _dbHelper.insertVisit(newVisit);
      }

      // Update visit sections
      await _updateVisitSections(visitId, visitJson);
    }
  }

  Future<void> _updateVisitSections(int visitId, Map<String, dynamic> visitJson) async {
    final sections = [
      'adminManagement',
      'logistics', 
      'equipment',
      'mhdcManagement',
      'serviceStandards',
      'healthInformation',
      'integration',
    ];

    final tableMap = {
      'adminManagement': 'visit_admin_management_responses',
      'logistics': 'visit_logistics_responses',
      'equipment': 'visit_equipment_responses',
      'mhdcManagement': 'visit_mhdc_management_responses',
      'serviceStandards': 'visit_service_standards_responses',
      'healthInformation': 'visit_health_information_responses',
      'integration': 'visit_integration_responses',
    };

    for (final section in sections) {
      if (visitJson[section] != null) {
        final tableName = tableMap[section]!;
        final existingSection = await _dbHelper.getVisitSection(tableName, visitId);
        
        if (existingSection != null) {
          await _dbHelper.updateVisitSection(tableName, visitId, visitJson[section]);
        } else {
          await _dbHelper.insertVisitSection(tableName, visitId, visitJson[section]);
        }
      }
    }
  }

  // Full sync (upload then download)
  Future<SyncResult> fullSync() async {
    try {
      // First upload local changes
      final uploadResult = await uploadForms();
      
      // Then download updates from server
      final downloadResult = await downloadForms();
      
      return SyncResult(
        success: uploadResult.success && downloadResult.success,
        message: 'Upload: ${uploadResult.message}\nDownload: ${downloadResult.message}',
        successCount: uploadResult.successCount + downloadResult.successCount,
        errorCount: uploadResult.errorCount + downloadResult.errorCount,
        errors: [...(uploadResult.errors ?? []), ...(downloadResult.errors ?? [])],
      );
    } catch (e) {
      return SyncResult(
        success: false,
        message: 'Full sync failed: $e',
        successCount: 0,
        errorCount: 0,
      );
    }
  }

  // Get sync status
  Future<Map<String, dynamic>> getSyncStatus() async {
    final unsyncedForms = await _dbHelper.getUnsyncedForms();
    final lastSync = await StorageService.getLastSyncTime();
    
    return {
      'hasUnsyncedData': unsyncedForms.isNotEmpty,
      'unsyncedFormsCount': unsyncedForms.length,
      'lastSyncTime': lastSync?.toIso8601String(),
      'needsSync': unsyncedForms.isNotEmpty,
    };
  }

  Future<String> _getDeviceId() async {
    const uuid = Uuid();
    return uuid.v4(); // In real app, you might want to store this consistently
  }
}