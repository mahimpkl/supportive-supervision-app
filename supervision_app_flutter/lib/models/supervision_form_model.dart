import 'package:uuid/uuid.dart';
import 'supervision_visit.dart';
import 'staff_training_data.dart';
import 'infrastructure_data.dart';

class SupervisionForm {
  final int? id;
  final String tempId;
  final int? serverId;
  final String healthFacilityName;
  final String province;
  final String district;
  final int? userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;
  final bool isActive;
  final List<SupervisionVisit>? visits;
  final StaffTrainingData? staffTraining;
  final InfrastructureData? infrastructure;

  SupervisionForm({
    this.id,
    String? tempId,
    this.serverId,
    required this.healthFacilityName,
    required this.province,
    required this.district,
    this.userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.syncStatus = 'local',
    this.isActive = true,
    this.visits,
    this.staffTraining,
    this.infrastructure,
  })  : tempId = tempId ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory SupervisionForm.fromJson(Map<String, dynamic> json) {
    return SupervisionForm(
      id: json['id'],
      tempId: json['temp_id'] ?? json['tempId'],
      serverId: json['server_id'] ?? json['serverId'],
      healthFacilityName: json['health_facility_name'] ?? json['healthFacilityName'],
      province: json['province'],
      district: json['district'],
      userId: json['user_id'] ?? json['userId'],
      createdAt: DateTime.parse(json['created_at'] ?? json['createdAt']),
      updatedAt: DateTime.parse(json['updated_at'] ?? json['updatedAt']),
      syncStatus: json['sync_status'] ?? json['syncStatus'] ?? 'local',
      isActive: (json['is_active'] ?? json['isActive'] ?? 1) == 1,
      visits: json['visits'] != null
          ? (json['visits'] as List).map((v) => SupervisionVisit.fromJson(v)).toList()
          : null,
      staffTraining: json['staffTraining'] != null || json['staff_training'] != null
          ? StaffTrainingData.fromJson(json['staffTraining'] ?? json['staff_training']) 
          : null,
      infrastructure: json['infrastructure'] != null || json['facility_infrastructure'] != null
          ? InfrastructureData.fromJson(json['infrastructure'] ?? json['facility_infrastructure']) 
          : null,
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

    if (id != null) json['id'] = id;
    if (serverId != null) json['server_id'] = serverId;
    if (userId != null) json['user_id'] = userId;
    if (visits != null) json['visits'] = visits!.map((v) => v.toJson()).toList();
    if (staffTraining != null) json['staff_training'] = staffTraining!.toJson();
    if (infrastructure != null) json['facility_infrastructure'] = infrastructure!.toJson();

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
      if (staffTraining != null) 'staffTraining': staffTraining!.toServerJson(),
      if (infrastructure != null) 'infrastructure': infrastructure!.toServerJson(),
    };
  }

  SupervisionForm copyWith({
    int? id,
    String? tempId,
    int? serverId,
    String? healthFacilityName,
    String? province,
    String? district,
    int? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
    bool? isActive,
    List<SupervisionVisit>? visits,
    StaffTrainingData? staffTraining,
    InfrastructureData? infrastructure,
  }) {
    return SupervisionForm(
      id: id ?? this.id,
      tempId: tempId ?? this.tempId,
      serverId: serverId ?? this.serverId,
      healthFacilityName: healthFacilityName ?? this.healthFacilityName,
      province: province ?? this.province,
      district: district ?? this.district,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      isActive: isActive ?? this.isActive,
      visits: visits ?? this.visits,
      staffTraining: staffTraining ?? this.staffTraining,
      infrastructure: infrastructure ?? this.infrastructure,
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