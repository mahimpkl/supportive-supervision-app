import 'package:supervision_app/models/khdc_management_data.dart';
import 'package:uuid/uuid.dart';
import 'admin_management_data.dart';
import 'logistics_data.dart';
import 'equipment_data.dart';
import 'khdc_management_data.dart';
import 'service_standards_data.dart';
import 'health_information_data.dart';
import 'integration_data.dart';

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
  final AdminManagementData? adminManagement;
  final LogisticsData? logistics;
  final EquipmentData? equipment;
  final KhdcManagementData? khdcManagement;
  final ServiceStandardsData? serviceStandards;
  final HealthInformationData? healthInformation;
  final IntegrationData? integration;
  

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
    this.khdcManagement,
    this.serviceStandards,
    this.healthInformation,
    this.integration,
    
  })  : tempId = tempId ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory SupervisionVisit.fromJson(Map<String, dynamic> json) {
    return SupervisionVisit(
      id: json['id'],
      tempId: json['temp_id'] ?? json['tempId'],
      serverId: json['server_id'] ?? json['serverId'],
      formId: json['form_id'] ?? json['formId'],
      visitNumber: json['visit_number'] ?? json['visitNumber'],
      visitDate: DateTime.parse(json['visit_date'] ?? json['visitDate']),
      recommendations: json['recommendations'],
      actionsAgreed: json['actions_agreed'] ?? json['actionsAgreed'],
      supervisorSignature: json['supervisor_signature'] ?? json['supervisorSignature'],
      facilityRepresentativeSignature: json['facility_representative_signature'] ?? json['facilityRepresentativeSignature'],
      createdAt: DateTime.parse(json['created_at'] ?? json['createdAt']),
      updatedAt: DateTime.parse(json['updated_at'] ?? json['updatedAt']),
      syncStatus: json['sync_status'] ?? json['syncStatus'] ?? 'local',
      adminManagement: json['adminManagement'] != null || json['admin_management'] != null
          ? AdminManagementData.fromJson(json['adminManagement'] ?? json['admin_management']) : null,
      logistics: json['logistics'] != null 
          ? LogisticsData.fromJson(json['logistics']) : null,
      equipment: json['equipment'] != null 
          ? EquipmentData.fromJson(json['equipment']) : null,
      khdcManagement: json['khdcManagement'] != null || json['khdc_management'] != null
          ? KhdcManagementData.fromJson(json['khdcManagement'] ?? json['khdc_management']) : null,
      serviceStandards: json['serviceStandards'] != null || json['service_standards'] != null
          ? ServiceStandardsData.fromJson(json['serviceStandards'] ?? json['service_standards']) : null,
      healthInformation: json['healthInformation'] != null || json['health_information'] != null
          ? HealthInformationData.fromJson(json['healthInformation'] ?? json['health_information']) : null,
      integration: json['integration'] != null 
          ? IntegrationData.fromJson(json['integration']) : null,
      
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

    if (id != null) json['id'] = id;
    if (serverId != null) json['server_id'] = serverId;
    if (recommendations != null) json['recommendations'] = recommendations;
    if (actionsAgreed != null) json['actions_agreed'] = actionsAgreed;
    if (supervisorSignature != null) json['supervisor_signature'] = supervisorSignature;
    if (facilityRepresentativeSignature != null) json['facility_representative_signature'] = facilityRepresentativeSignature;
    
    if (adminManagement != null) json['admin_management'] = adminManagement!.toJson();
    if (logistics != null) json['logistics'] = logistics!.toJson();
    if (equipment != null) json['equipment'] = equipment!.toJson();
    if (khdcManagement != null) json['khdc_management'] = khdcManagement!.toJson();
    if (serviceStandards != null) json['service_standards'] = serviceStandards!.toJson();
    if (healthInformation != null) json['health_information'] = healthInformation!.toJson();
    if (integration != null) json['integration'] = integration!.toJson();
    

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
      if (adminManagement != null) 'adminManagement': adminManagement!.toServerJson(),
      if (logistics != null) 'logistics': logistics!.toServerJson(),
      if (equipment != null) 'equipment': equipment!.toServerJson(),
      if (khdcManagement != null) 'khdcManagement': khdcManagement!.toServerJson(),
      if (serviceStandards != null) 'serviceStandards': serviceStandards!.toServerJson(),
      if (healthInformation != null) 'healthInformation': healthInformation!.toServerJson(),
      if (integration != null) 'integration': integration!.toServerJson(),
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
    AdminManagementData? adminManagement,
    LogisticsData? logistics,
    EquipmentData? equipment,
    KhdcManagementData? khdcManagement,
    ServiceStandardsData? serviceStandards,
    HealthInformationData? healthInformation,
    IntegrationData? integration,
    
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
      khdcManagement: khdcManagement ?? this.khdcManagement,
      serviceStandards: serviceStandards ?? this.serviceStandards,
      healthInformation: healthInformation ?? this.healthInformation,
      integration: integration ?? this.integration,
    );
  }

  String get visitTitle => 'Visit $visitNumber';
  String get formattedDate => '${visitDate.day}/${visitDate.month}/${visitDate.year}';
}