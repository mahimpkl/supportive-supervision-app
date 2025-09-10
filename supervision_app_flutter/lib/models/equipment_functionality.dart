class EquipmentFunctionality {
  final String? equipmentName;
  final String? equipmentCategory;
  final String? brandModel;
  final String? serialNumber;
  final String? availability;
  final String? functionalityStatus;
  final DateTime? lastCalibrationDate;
  final DateTime? calibrationDueDate;
  final String? maintenanceSchedule;
  final String? usageFrequency;
  final bool? staffTrainedOnEquipment;
  final bool? userManualAvailable;
  final bool? sparePartsAvailable;
  final String? warrantyStatus;
  final String? issuesNoted;
  final String? repairHistory;
  final DateTime? procurementDate;
  final double? cost;
  final String? fundingSource;

  EquipmentFunctionality({
    this.equipmentName,
    this.equipmentCategory,
    this.brandModel,
    this.serialNumber,
    this.availability,
    this.functionalityStatus,
    this.lastCalibrationDate,
    this.calibrationDueDate,
    this.maintenanceSchedule,
    this.usageFrequency,
    this.staffTrainedOnEquipment,
    this.userManualAvailable,
    this.sparePartsAvailable,
    this.warrantyStatus,
    this.issuesNoted,
    this.repairHistory,
    this.procurementDate,
    this.cost,
    this.fundingSource,
  });

  factory EquipmentFunctionality.fromJson(Map<String, dynamic> json) {
    return EquipmentFunctionality(
      equipmentName: json['equipment_name'] ?? json['equipmentName'],
      equipmentCategory: json['equipment_category'] ?? json['equipmentCategory'],
      brandModel: json['brand_model'] ?? json['brandModel'],
      serialNumber: json['serial_number'] ?? json['serialNumber'],
      availability: json['availability'],
      functionalityStatus: json['functionality_status'] ?? json['functionalityStatus'],
      lastCalibrationDate: json['last_calibration_date'] != null || json['lastCalibrationDate'] != null
          ? DateTime.parse(json['last_calibration_date'] ?? json['lastCalibrationDate'])
          : null,
      calibrationDueDate: json['calibration_due_date'] != null || json['calibrationDueDate'] != null
          ? DateTime.parse(json['calibration_due_date'] ?? json['calibrationDueDate'])
          : null,
      maintenanceSchedule: json['maintenance_schedule'] ?? json['maintenanceSchedule'],
      usageFrequency: json['usage_frequency'] ?? json['usageFrequency'],
      staffTrainedOnEquipment: _parseBool(json['staff_trained_on_equipment'] ?? json['staffTrainedOnEquipment']),
      userManualAvailable: _parseBool(json['user_manual_available'] ?? json['userManualAvailable']),
      sparePartsAvailable: _parseBool(json['spare_parts_available'] ?? json['sparePartsAvailable']),
      warrantyStatus: json['warranty_status'] ?? json['warrantyStatus'],
      issuesNoted: json['issues_noted'] ?? json['issuesNoted'],
      repairHistory: json['repair_history'] ?? json['repairHistory'],
      procurementDate: json['procurement_date'] != null || json['procurementDate'] != null
          ? DateTime.parse(json['procurement_date'] ?? json['procurementDate'])
          : null,
      cost: json['cost'] != null ? (json['cost'] as num).toDouble() : null,
      fundingSource: json['funding_source'] ?? json['fundingSource'],
    );
  }

  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      if (value.toLowerCase() == 'true' || value == '1') return true;
      if (value.toLowerCase() == 'false' || value == '0') return false;
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      if (equipmentName != null) 'equipment_name': equipmentName,
      if (equipmentCategory != null) 'equipment_category': equipmentCategory,
      if (brandModel != null) 'brand_model': brandModel,
      if (serialNumber != null) 'serial_number': serialNumber,
      if (availability != null) 'availability': availability,
      if (functionalityStatus != null) 'functionality_status': functionalityStatus,
      if (lastCalibrationDate != null) 'last_calibration_date': lastCalibrationDate!.toIso8601String(),
      if (calibrationDueDate != null) 'calibration_due_date': calibrationDueDate!.toIso8601String(),
      if (maintenanceSchedule != null) 'maintenance_schedule': maintenanceSchedule,
      if (usageFrequency != null) 'usage_frequency': usageFrequency,
      if (staffTrainedOnEquipment != null) 'staff_trained_on_equipment': staffTrainedOnEquipment,
      if (userManualAvailable != null) 'user_manual_available': userManualAvailable,
      if (sparePartsAvailable != null) 'spare_parts_available': sparePartsAvailable,
      if (warrantyStatus != null) 'warranty_status': warrantyStatus,
      if (issuesNoted != null) 'issues_noted': issuesNoted,
      if (repairHistory != null) 'repair_history': repairHistory,
      if (procurementDate != null) 'procurement_date': procurementDate!.toIso8601String(),
      if (cost != null) 'cost': cost,
      if (fundingSource != null) 'funding_source': fundingSource,
    };
  }

  Map<String, dynamic> toServerJson() {
    return {
      if (equipmentName != null) 'equipment_name': equipmentName,
      if (equipmentCategory != null) 'equipment_category': equipmentCategory,
      if (brandModel != null) 'brand_model': brandModel,
      if (serialNumber != null) 'serial_number': serialNumber,
      if (availability != null) 'availability': availability,
      if (functionalityStatus != null) 'functionality_status': functionalityStatus,
      if (lastCalibrationDate != null) 'last_calibration_date': lastCalibrationDate!.toIso8601String(),
      if (calibrationDueDate != null) 'calibration_due_date': calibrationDueDate!.toIso8601String(),
      if (maintenanceSchedule != null) 'maintenance_schedule': maintenanceSchedule,
      if (usageFrequency != null) 'usage_frequency': usageFrequency,
      if (staffTrainedOnEquipment != null) 'staff_trained_on_equipment': staffTrainedOnEquipment,
      if (userManualAvailable != null) 'user_manual_available': userManualAvailable,
      if (sparePartsAvailable != null) 'spare_parts_available': sparePartsAvailable,
      if (warrantyStatus != null) 'warranty_status': warrantyStatus,
      if (issuesNoted != null) 'issues_noted': issuesNoted,
      if (repairHistory != null) 'repair_history': repairHistory,
      if (procurementDate != null) 'procurement_date': procurementDate!.toIso8601String(),
      if (cost != null) 'cost': cost,
      if (fundingSource != null) 'funding_source': fundingSource,
    };
  }

  EquipmentFunctionality copyWith({
    String? equipmentName,
    String? equipmentCategory,
    String? brandModel,
    String? serialNumber,
    String? availability,
    String? functionalityStatus,
    DateTime? lastCalibrationDate,
    DateTime? calibrationDueDate,
    String? maintenanceSchedule,
    String? usageFrequency,
    bool? staffTrainedOnEquipment,
    bool? userManualAvailable,
    bool? sparePartsAvailable,
    String? warrantyStatus,
    String? issuesNoted,
    String? repairHistory,
    DateTime? procurementDate,
    double? cost,
    String? fundingSource,
  }) {
    return EquipmentFunctionality(
      equipmentName: equipmentName ?? this.equipmentName,
      equipmentCategory: equipmentCategory ?? this.equipmentCategory,
      brandModel: brandModel ?? this.brandModel,
      serialNumber: serialNumber ?? this.serialNumber,
      availability: availability ?? this.availability,
      functionalityStatus: functionalityStatus ?? this.functionalityStatus,
      lastCalibrationDate: lastCalibrationDate ?? this.lastCalibrationDate,
      calibrationDueDate: calibrationDueDate ?? this.calibrationDueDate,
      maintenanceSchedule: maintenanceSchedule ?? this.maintenanceSchedule,
      usageFrequency: usageFrequency ?? this.usageFrequency,
      staffTrainedOnEquipment: staffTrainedOnEquipment ?? this.staffTrainedOnEquipment,
      userManualAvailable: userManualAvailable ?? this.userManualAvailable,
      sparePartsAvailable: sparePartsAvailable ?? this.sparePartsAvailable,
      warrantyStatus: warrantyStatus ?? this.warrantyStatus,
      issuesNoted: issuesNoted ?? this.issuesNoted,
      repairHistory: repairHistory ?? this.repairHistory,
      procurementDate: procurementDate ?? this.procurementDate,
      cost: cost ?? this.cost,
      fundingSource: fundingSource ?? this.fundingSource,
    );
  }
}