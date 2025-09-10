import 'package:uuid/uuid.dart';
import 'admin_management_data.dart';
import 'logistics_data.dart';
import 'equipment_data.dart';
import 'mhdc_management_data.dart';
import 'service_standards_data.dart';
import 'health_information_data.dart';
import 'integration_data.dart';
import 'medicine_detail.dart';
import 'patient_volumes.dart';
import 'equipment_functionality.dart';
import 'quality_assurance.dart';

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
  final MhdcManagementData? mhdcManagement;
  final ServiceStandardsData? serviceStandards;
  final HealthInformationData? healthInformation;
  final IntegrationData? integration;
  final List<MedicineDetail>? medicineDetails;
  final PatientVolumes? patientVolumes;
  final List<EquipmentFunctionality>? equipmentFunctionality;
  final QualityAssurance? qualityAssurance;

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
    this.medicineDetails,
    this.patientVolumes,
    this.equipmentFunctionality,
    this.qualityAssurance,
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
      mhdcManagement: json['mhdcManagement'] != null || json['mhdc_management'] != null
          ? MhdcManagementData.fromJson(json['mhdcManagement'] ?? json['mhdc_management']) : null,
      serviceStandards: json['serviceStandards'] != null || json['service_standards'] != null
          ? ServiceStandardsData.fromJson(json['serviceStandards'] ?? json['service_standards']) : null,
      healthInformation: json['healthInformation'] != null || json['health_information'] != null
          ? HealthInformationData.fromJson(json['healthInformation'] ?? json['health_information']) : null,
      integration: json['integration'] != null 
          ? IntegrationData.fromJson(json['integration']) : null,
      medicineDetails: json['medicineDetails'] != null || json['medicine_details'] != null
          ? (json['medicineDetails'] ?? json['medicine_details'] as List).map((m) => MedicineDetail.fromJson(m)).toList() : null,
      patientVolumes: json['patientVolumes'] != null || json['patient_volumes'] != null
          ? PatientVolumes.fromJson(json['patientVolumes'] ?? json['patient_volumes']) : null,
      equipmentFunctionality: json['equipmentFunctionality'] != null || json['equipment_functionality'] != null
          ? (json['equipmentFunctionality'] ?? json['equipment_functionality'] as List).map((e) => EquipmentFunctionality.fromJson(e)).toList() : null,
      qualityAssurance: json['qualityAssurance'] != null || json['quality_assurance'] != null
          ? QualityAssurance.fromJson(json['qualityAssurance'] ?? json['quality_assurance']) : null,
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
    if (mhdcManagement != null) json['mhdc_management'] = mhdcManagement!.toJson();
    if (serviceStandards != null) json['service_standards'] = serviceStandards!.toJson();
    if (healthInformation != null) json['health_information'] = healthInformation!.toJson();
    if (integration != null) json['integration'] = integration!.toJson();
    if (medicineDetails != null) json['medicine_details'] = medicineDetails!.map((m) => m.toJson()).toList();
    if (patientVolumes != null) json['patient_volumes'] = patientVolumes!.toJson();
    if (equipmentFunctionality != null) json['equipment_functionality'] = equipmentFunctionality!.map((e) => e.toJson()).toList();
    if (qualityAssurance != null) json['quality_assurance'] = qualityAssurance!.toJson();

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
      if (mhdcManagement != null) 'mhdcManagement': mhdcManagement!.toServerJson(),
      if (serviceStandards != null) 'serviceStandards': serviceStandards!.toServerJson(),
      if (healthInformation != null) 'healthInformation': healthInformation!.toServerJson(),
      if (integration != null) 'integration': integration!.toServerJson(),
      if (medicineDetails != null) 'medicineDetails': medicineDetails!.map((m) => m.toServerJson()).toList(),
      if (patientVolumes != null) 'patientVolumes': patientVolumes!.toServerJson(),
      if (equipmentFunctionality != null) 'equipmentFunctionality': equipmentFunctionality!.map((e) => e.toServerJson()).toList(),
      if (qualityAssurance != null) 'qualityAssurance': qualityAssurance!.toServerJson(),
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
    MhdcManagementData? mhdcManagement,
    ServiceStandardsData? serviceStandards,
    HealthInformationData? healthInformation,
    IntegrationData? integration,
    List<MedicineDetail>? medicineDetails,
    PatientVolumes? patientVolumes,
    List<EquipmentFunctionality>? equipmentFunctionality,
    QualityAssurance? qualityAssurance,
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
      medicineDetails: medicineDetails ?? this.medicineDetails,
      patientVolumes: patientVolumes ?? this.patientVolumes,
      equipmentFunctionality: equipmentFunctionality ?? this.equipmentFunctionality,
      qualityAssurance: qualityAssurance ?? this.qualityAssurance,
    );
  }

  String get visitTitle => 'Visit $visitNumber';
  String get formattedDate => '${visitDate.day}/${visitDate.month}/${visitDate.year}';
}