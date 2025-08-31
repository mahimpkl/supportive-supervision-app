import 'package:uuid/uuid.dart';

class SupervisionForm {
  final int? id;
  final String tempId;
  final int? serverId;
  final String healthFacilityName;
  final String province;
  final String district;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;
  final bool isActive;
  final List<SupervisionVisit>? visits;
  final Map<String, dynamic>? staffTraining;

  SupervisionForm({
    this.id,
    String? tempId,
    this.serverId,
    required this.healthFacilityName,
    required this.province,
    required this.district,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.syncStatus = 'local',
    this.isActive = true,
    this.visits,
    this.staffTraining,
  })  : tempId = tempId ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory SupervisionForm.fromJson(Map<String, dynamic> json) {
    return SupervisionForm(
      id: json['id'],
      // Handle both camelCase (local DB) and snake_case (server) formats
      tempId: json['tempId'] ?? json['temp_id'],
      serverId: json['serverId'] ?? json['server_id'],
      healthFacilityName: json['healthFacilityName'] ?? json['health_facility_name'],
      province: json['province'],
      district: json['district'],
      createdAt: DateTime.parse(json['createdAt'] ?? json['created_at']),
      updatedAt: DateTime.parse(json['updatedAt'] ?? json['updated_at']),
      syncStatus: json['syncStatus'] ?? json['sync_status'] ?? 'local',
      isActive: (json['isActive'] ?? json['is_active'] ?? 1) == 1,
      visits: json['visits'] != null
          ? (json['visits'] as List).map((v) => SupervisionVisit.fromJson(v)).toList()
          : null,
      staffTraining: json['staffTraining'] ?? json['staff_training'],
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'temp_id': tempId,
      'health_facility_name': healthFacilityName,
      'province': province,
      'district': district,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'sync_status': syncStatus,
      'is_active': isActive ? 1 : 0,
    };

    // Only include id and server_id if they're not null (for updates)
    if (id != null) json['id'] = id;
    if (serverId != null) json['server_id'] = serverId;
    
    // Include optional fields
    if (visits != null) json['visits'] = visits!.map((v) => v.toJson()).toList();
    if (staffTraining != null) json['staff_training'] = staffTraining;

    return json;
  }

  Map<String, dynamic> toServerJson() {
    return {
      'tempId': tempId,
      'healthFacilityName': healthFacilityName,
      'province': province,
      'district': district,
      'formCreatedAt': createdAt.toIso8601String(),
      if (visits != null) 'visits': visits!.map((v) => v.toServerJson()).toList(),
      if (staffTraining != null) 'staffTraining': staffTraining,
    };
  }

  SupervisionForm copyWith({
    int? id,
    String? tempId,
    int? serverId,
    String? healthFacilityName,
    String? province,
    String? district,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
    bool? isActive,
    List<SupervisionVisit>? visits,
    Map<String, dynamic>? staffTraining,
  }) {
    return SupervisionForm(
      id: id ?? this.id,
      tempId: tempId ?? this.tempId,
      serverId: serverId ?? this.serverId,
      healthFacilityName: healthFacilityName ?? this.healthFacilityName,
      province: province ?? this.province,
      district: district ?? this.district,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      isActive: isActive ?? this.isActive,
      visits: visits ?? this.visits,
      staffTraining: staffTraining ?? this.staffTraining,
    );
  }

  // Helper methods
  int get completedVisits => visits?.length ?? 0;
  bool get isCompleted => completedVisits >= 4;
  int? get nextVisitNumber => isCompleted ? null : completedVisits + 1;
  
  String get syncStatusDisplay {
    switch (syncStatus) {
      case 'local':
        return 'Not Synced';
      case 'synced':
        return 'Synced';
      case 'verified':
        return 'Verified';
      default:
        return 'Unknown';
    }
  }

  double get completionPercentage => (completedVisits / 4) * 100;
}

class SupervisionVisit {
  final int? id;
  final String tempId;
  final int? serverId;
  final int formId;
  final int visitNumber;
  final DateTime visitDate;
  final String? recommendations;
  final String? actionsAgreed;
  final String? supervisorSignature;
  final String? facilityRepresentativeSignature;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;
  
  // Section data
  final Map<String, dynamic>? adminManagement;
  final Map<String, dynamic>? logistics;
  final Map<String, dynamic>? equipment;
  final Map<String, dynamic>? mhdcManagement;
  final Map<String, dynamic>? serviceStandards;
  final Map<String, dynamic>? healthInformation;
  final Map<String, dynamic>? integration;

  SupervisionVisit({
    this.id,
    String? tempId,
    this.serverId,
    required this.formId,
    required this.visitNumber,
    required this.visitDate,
    this.recommendations,
    this.actionsAgreed,
    this.supervisorSignature,
    this.facilityRepresentativeSignature,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.syncStatus = 'local',
    this.adminManagement,
    this.logistics,
    this.equipment,
    this.mhdcManagement,
    this.serviceStandards,
    this.healthInformation,
    this.integration,
  })  : tempId = tempId ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory SupervisionVisit.fromJson(Map<String, dynamic> json) {
    return SupervisionVisit(
      id: json['id'],
      // Handle both camelCase (local DB) and snake_case (server) formats
      tempId: json['tempId'] ?? json['temp_id'],
      serverId: json['serverId'] ?? json['server_id'],
      formId: json['formId'] ?? json['form_id'],
      visitNumber: json['visitNumber'] ?? json['visit_number'],
      visitDate: DateTime.parse(json['visitDate'] ?? json['visit_date']),
      recommendations: json['recommendations'],
      actionsAgreed: json['actionsAgreed'] ?? json['actions_agreed'],
      supervisorSignature: json['supervisorSignature'] ?? json['supervisor_signature'],
      facilityRepresentativeSignature: json['facilityRepresentativeSignature'] ?? json['facility_representative_signature'],
      createdAt: DateTime.parse(json['createdAt'] ?? json['created_at']),
      updatedAt: DateTime.parse(json['updatedAt'] ?? json['updated_at']),
      syncStatus: json['syncStatus'] ?? json['sync_status'] ?? 'local',
      adminManagement: json['adminManagement'] ?? json['admin_management'],
      logistics: json['logistics'],
      equipment: json['equipment'],
      mhdcManagement: json['mhdcManagement'] ?? json['mhdc_management'],
      serviceStandards: json['serviceStandards'] ?? json['service_standards'],
      healthInformation: json['healthInformation'] ?? json['health_information'],
      integration: json['integration'],
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'temp_id': tempId,
      'form_id': formId,
      'visit_number': visitNumber,
      'visit_date': visitDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'sync_status': syncStatus,
    };

    // Only include id and server_id if they're not null (for updates)
    if (id != null) json['id'] = id;
    if (serverId != null) json['server_id'] = serverId;
    
    // Include optional fields
    if (recommendations != null) json['recommendations'] = recommendations;
    if (actionsAgreed != null) json['actions_agreed'] = actionsAgreed;
    if (supervisorSignature != null) json['supervisor_signature'] = supervisorSignature;
    if (facilityRepresentativeSignature != null) json['facility_representative_signature'] = facilityRepresentativeSignature;
    
    if (adminManagement != null) json['admin_management'] = adminManagement;
    if (logistics != null) json['logistics'] = logistics;
    if (equipment != null) json['equipment'] = equipment;
    if (mhdcManagement != null) json['mhdc_management'] = mhdcManagement;
    if (serviceStandards != null) json['service_standards'] = serviceStandards;
    if (healthInformation != null) json['health_information'] = healthInformation;
    if (integration != null) json['integration'] = integration;

    return json;
  }

  Map<String, dynamic> toServerJson() {
    return {
      'visitNumber': visitNumber,
      'visitDate': visitDate.toIso8601String(),
      'recommendations': recommendations,
      'actionsAgreed': actionsAgreed,
      'supervisorSignature': supervisorSignature,
      'facilityRepresentativeSignature': facilityRepresentativeSignature,
      'createdAt': createdAt.toIso8601String(),
      if (adminManagement != null) 'adminManagement': adminManagement,
      if (logistics != null) 'logistics': logistics,
      if (equipment != null) 'equipment': equipment,
      if (mhdcManagement != null) 'mhdcManagement': mhdcManagement,
      if (serviceStandards != null) 'serviceStandards': serviceStandards,
      if (healthInformation != null) 'healthInformation': healthInformation,
      if (integration != null) 'integration': integration,
    };
  }

  SupervisionVisit copyWith({
    int? id,
    String? tempId,
    int? serverId,
    int? formId,
    int? visitNumber,
    DateTime? visitDate,
    String? recommendations,
    String? actionsAgreed,
    String? supervisorSignature,
    String? facilityRepresentativeSignature,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
    Map<String, dynamic>? adminManagement,
    Map<String, dynamic>? logistics,
    Map<String, dynamic>? equipment,
    Map<String, dynamic>? mhdcManagement,
    Map<String, dynamic>? serviceStandards,
    Map<String, dynamic>? healthInformation,
    Map<String, dynamic>? integration,
  }) {
    return SupervisionVisit(
      id: id ?? this.id,
      tempId: tempId ?? this.tempId,
      serverId: serverId ?? this.serverId,
      formId: formId ?? this.formId,
      visitNumber: visitNumber ?? this.visitNumber,
      visitDate: visitDate ?? this.visitDate,
      recommendations: recommendations ?? this.recommendations,
      actionsAgreed: actionsAgreed ?? this.actionsAgreed,
      supervisorSignature: supervisorSignature ?? this.supervisorSignature,
      facilityRepresentativeSignature: facilityRepresentativeSignature ?? this.facilityRepresentativeSignature,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      adminManagement: adminManagement ?? this.adminManagement,
      logistics: logistics ?? this.logistics,
      equipment: equipment ?? this.equipment,
      mhdcManagement: mhdcManagement ?? this.mhdcManagement,
      serviceStandards: serviceStandards ?? this.serviceStandards,
      healthInformation: healthInformation ?? this.healthInformation,
      integration: integration ?? this.integration,
    );
  }

  String get visitTitle => 'Visit $visitNumber';
  String get formattedDate => '${visitDate.day}/${visitDate.month}/${visitDate.year}';
}

// Sync related models
class SyncResult {
  final bool success;
  final String message;
  final int successCount;
  final int errorCount;
  final List<SyncError>? errors;

  SyncResult({
    required this.success,
    required this.message,
    required this.successCount,
    required this.errorCount,
    this.errors,
  });

  factory SyncResult.fromJson(Map<String, dynamic> json) {
    return SyncResult(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      successCount: json['successCount'] ?? 0,
      errorCount: json['errorCount'] ?? 0,
      errors: json['errors'] != null
          ? (json['errors'] as List).map((e) => SyncError.fromJson(e)).toList()
          : null,
    );
  }
}

class SyncError {
  final String tempId;
  final String error;

  SyncError({
    required this.tempId,
    required this.error,
  });

  factory SyncError.fromJson(Map<String, dynamic> json) {
    return SyncError(
      tempId: json['tempId'],
      error: json['error'],
    );
  }
}