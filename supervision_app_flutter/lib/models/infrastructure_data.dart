class InfrastructureData {
  // Room and space infrastructure
  final int? totalRooms;
  final int? consultationRooms;
  final bool? waitingAreaAdequate;
  final int? waitingAreaCapacity;

  // Pharmacy and storage
  final bool? pharmacyStorageAdequate;
  final double? pharmacyStorageSizeSqm;
  final bool? coldChainAvailable;
  final bool? coldChainTemperatureMonitored;
  final bool? medicineStorageConditionsAppropriate;

  // Power and utilities
  final bool? generatorBackup;
  final double? generatorCapacityKw;
  final bool? waterSupplyReliable;
  final int? waterStorageCapacityLiters;
  final bool? electricityStable;
  final bool? internetConnectivity;

  // Waste management
  final bool? wasteDisposalSystem;
  final bool? sharpsDisposalAppropriate;
  final bool? biomedicalWasteSegregation;

  // Accessibility and safety
  final bool? accessibilityFeatures;
  final bool? wheelchairAccessible;
  final bool? fireSafetyEquipment;
  final bool? emergencyProtocolsDisplayed;

  // Medical services
  final bool? laboratoryAvailable;
  final bool? xrayAvailable;
  final bool? ambulanceService;

  // Assessment details
  final DateTime? assessmentDate;
  final String? assessedBy;
  final int? infrastructureScore;
  final String? priorityImprovements;

  InfrastructureData({
    this.totalRooms,
    this.consultationRooms,
    this.waitingAreaAdequate,
    this.waitingAreaCapacity,
    this.pharmacyStorageAdequate,
    this.pharmacyStorageSizeSqm,
    this.coldChainAvailable,
    this.coldChainTemperatureMonitored,
    this.medicineStorageConditionsAppropriate,
    this.generatorBackup,
    this.generatorCapacityKw,
    this.waterSupplyReliable,
    this.waterStorageCapacityLiters,
    this.electricityStable,
    this.internetConnectivity,
    this.wasteDisposalSystem,
    this.sharpsDisposalAppropriate,
    this.biomedicalWasteSegregation,
    this.accessibilityFeatures,
    this.wheelchairAccessible,
    this.fireSafetyEquipment,
    this.emergencyProtocolsDisplayed,
    this.laboratoryAvailable,
    this.xrayAvailable,
    this.ambulanceService,
    this.assessmentDate,
    this.assessedBy,
    this.infrastructureScore,
    this.priorityImprovements,
  });

  factory InfrastructureData.fromJson(Map<String, dynamic> json) {
    return InfrastructureData(
      totalRooms: json['total_rooms'] ?? json['totalRooms'],
      consultationRooms: json['consultation_rooms'] ?? json['consultationRooms'],
      waitingAreaAdequate: _parseBool(json['waiting_area_adequate'] ?? json['waitingAreaAdequate']),
      waitingAreaCapacity: json['waiting_area_capacity'] ?? json['waitingAreaCapacity'],
      pharmacyStorageAdequate: _parseBool(json['pharmacy_storage_adequate'] ?? json['pharmacyStorageAdequate']),
      pharmacyStorageSizeSqm: json['pharmacy_storage_size_sqm'] != null 
          ? (json['pharmacy_storage_size_sqm'] as num).toDouble() 
          : json['pharmacyStorageSizeSqm'] != null 
              ? (json['pharmacyStorageSizeSqm'] as num).toDouble() 
              : null,
      coldChainAvailable: _parseBool(json['cold_chain_available'] ?? json['coldChainAvailable']),
      coldChainTemperatureMonitored: _parseBool(json['cold_chain_temperature_monitored'] ?? json['coldChainTemperatureMonitored']),
      medicineStorageConditionsAppropriate: _parseBool(json['medicine_storage_conditions_appropriate'] ?? json['medicineStorageConditionsAppropriate']),
      generatorBackup: _parseBool(json['generator_backup'] ?? json['generatorBackup']),
      generatorCapacityKw: json['generator_capacity_kw'] != null 
          ? (json['generator_capacity_kw'] as num).toDouble() 
          : json['generatorCapacityKw'] != null 
              ? (json['generatorCapacityKw'] as num).toDouble() 
              : null,
      waterSupplyReliable: _parseBool(json['water_supply_reliable'] ?? json['waterSupplyReliable']),
      waterStorageCapacityLiters: json['water_storage_capacity_liters'] ?? json['waterStorageCapacityLiters'],
      electricityStable: _parseBool(json['electricity_stable'] ?? json['electricityStable']),
      internetConnectivity: _parseBool(json['internet_connectivity'] ?? json['internetConnectivity']),
      wasteDisposalSystem: _parseBool(json['waste_disposal_system'] ?? json['wasteDisposalSystem']),
      sharpsDisposalAppropriate: _parseBool(json['sharps_disposal_appropriate'] ?? json['sharpsDisposalAppropriate']),
      biomedicalWasteSegregation: _parseBool(json['biomedical_waste_segregation'] ?? json['biomedicalWasteSegregation']),
      accessibilityFeatures: _parseBool(json['accessibility_features'] ?? json['accessibilityFeatures']),
      wheelchairAccessible: _parseBool(json['wheelchair_accessible'] ?? json['wheelchairAccessible']),
      fireSafetyEquipment: _parseBool(json['fire_safety_equipment'] ?? json['fireSafetyEquipment']),
      emergencyProtocolsDisplayed: _parseBool(json['emergency_protocols_displayed'] ?? json['emergencyProtocolsDisplayed']),
      laboratoryAvailable: _parseBool(json['laboratory_available'] ?? json['laboratoryAvailable']),
      xrayAvailable: _parseBool(json['xray_available'] ?? json['xrayAvailable']),
      ambulanceService: _parseBool(json['ambulance_service'] ?? json['ambulanceService']),
      assessmentDate: json['assessment_date'] != null || json['assessmentDate'] != null
          ? DateTime.parse(json['assessment_date'] ?? json['assessmentDate'])
          : null,
      assessedBy: json['assessed_by'] ?? json['assessedBy'],
      infrastructureScore: json['infrastructure_score'] ?? json['infrastructureScore'],
      priorityImprovements: json['priority_improvements'] ?? json['priorityImprovements'],
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
      if (totalRooms != null) 'total_rooms': totalRooms,
      if (consultationRooms != null) 'consultation_rooms': consultationRooms,
      if (waitingAreaAdequate != null) 'waiting_area_adequate': waitingAreaAdequate,
      if (waitingAreaCapacity != null) 'waiting_area_capacity': waitingAreaCapacity,
      if (pharmacyStorageAdequate != null) 'pharmacy_storage_adequate': pharmacyStorageAdequate,
      if (pharmacyStorageSizeSqm != null) 'pharmacy_storage_size_sqm': pharmacyStorageSizeSqm,
      if (coldChainAvailable != null) 'cold_chain_available': coldChainAvailable,
      if (coldChainTemperatureMonitored != null) 'cold_chain_temperature_monitored': coldChainTemperatureMonitored,
      if (medicineStorageConditionsAppropriate != null) 'medicine_storage_conditions_appropriate': medicineStorageConditionsAppropriate,
      if (generatorBackup != null) 'generator_backup': generatorBackup,
      if (generatorCapacityKw != null) 'generator_capacity_kw': generatorCapacityKw,
      if (waterSupplyReliable != null) 'water_supply_reliable': waterSupplyReliable,
      if (waterStorageCapacityLiters != null) 'water_storage_capacity_liters': waterStorageCapacityLiters,
      if (electricityStable != null) 'electricity_stable': electricityStable,
      if (internetConnectivity != null) 'internet_connectivity': internetConnectivity,
      if (wasteDisposalSystem != null) 'waste_disposal_system': wasteDisposalSystem,
      if (sharpsDisposalAppropriate != null) 'sharps_disposal_appropriate': sharpsDisposalAppropriate,
      if (biomedicalWasteSegregation != null) 'biomedical_waste_segregation': biomedicalWasteSegregation,
      if (accessibilityFeatures != null) 'accessibility_features': accessibilityFeatures,
      if (wheelchairAccessible != null) 'wheelchair_accessible': wheelchairAccessible,
      if (fireSafetyEquipment != null) 'fire_safety_equipment': fireSafetyEquipment,
      if (emergencyProtocolsDisplayed != null) 'emergency_protocols_displayed': emergencyProtocolsDisplayed,
      if (laboratoryAvailable != null) 'laboratory_available': laboratoryAvailable,
      if (xrayAvailable != null) 'xray_available': xrayAvailable,
      if (ambulanceService != null) 'ambulance_service': ambulanceService,
      if (assessmentDate != null) 'assessment_date': assessmentDate!.toIso8601String(),
      if (assessedBy != null) 'assessed_by': assessedBy,
      if (infrastructureScore != null) 'infrastructure_score': infrastructureScore,
      if (priorityImprovements != null) 'priority_improvements': priorityImprovements,
    };
  }


  Map<String, dynamic> toServerJson() {
  return {
    if (totalRooms != null) 'total_rooms': totalRooms,
    if (consultationRooms != null) 'consultation_rooms': consultationRooms,
    if (waitingAreaAdequate != null) 'waiting_area_adequate': waitingAreaAdequate,
    if (waitingAreaCapacity != null) 'waiting_area_capacity': waitingAreaCapacity,
    if (pharmacyStorageAdequate != null) 'pharmacy_storage_adequate': pharmacyStorageAdequate,
    if (pharmacyStorageSizeSqm != null) 'pharmacy_storage_size_sqm': pharmacyStorageSizeSqm,
    if (coldChainAvailable != null) 'cold_chain_available': coldChainAvailable,
    if (coldChainTemperatureMonitored != null) 'cold_chain_temperature_monitored': coldChainTemperatureMonitored,
    if (medicineStorageConditionsAppropriate != null) 'medicine_storage_conditions_appropriate': medicineStorageConditionsAppropriate,
    if (generatorBackup != null) 'generator_backup': generatorBackup,
    if (generatorCapacityKw != null) 'generator_capacity_kw': generatorCapacityKw,
    if (waterSupplyReliable != null) 'water_supply_reliable': waterSupplyReliable,
    if (waterStorageCapacityLiters != null) 'water_storage_capacity_liters': waterStorageCapacityLiters,
    if (electricityStable != null) 'electricity_stable': electricityStable,
    if (internetConnectivity != null) 'internet_connectivity': internetConnectivity,
    if (wasteDisposalSystem != null) 'waste_disposal_system': wasteDisposalSystem,
    if (sharpsDisposalAppropriate != null) 'sharps_disposal_appropriate': sharpsDisposalAppropriate,
    if (biomedicalWasteSegregation != null) 'biomedical_waste_segregation': biomedicalWasteSegregation,
    if (accessibilityFeatures != null) 'accessibility_features': accessibilityFeatures,
    if (wheelchairAccessible != null) 'wheelchair_accessible': wheelchairAccessible,
    if (fireSafetyEquipment != null) 'fire_safety_equipment': fireSafetyEquipment,
    if (emergencyProtocolsDisplayed != null) 'emergency_protocols_displayed': emergencyProtocolsDisplayed,
    if (laboratoryAvailable != null) 'laboratory_available': laboratoryAvailable,
    if (xrayAvailable != null) 'xray_available': xrayAvailable,
    if (ambulanceService != null) 'ambulance_service': ambulanceService,
    if (assessmentDate != null) 'assessment_date': assessmentDate!.toIso8601String(),
    if (assessedBy != null) 'assessed_by': assessedBy,
    if (infrastructureScore != null) 'infrastructure_score': infrastructureScore,
    if (priorityImprovements != null) 'priority_improvements': priorityImprovements,
  };
}

  InfrastructureData copyWith({
    int? totalRooms,
    int? consultationRooms,
    bool? waitingAreaAdequate,
    int? waitingAreaCapacity,
    bool? pharmacyStorageAdequate,
    double? pharmacyStorageSizeSqm,
    bool? coldChainAvailable,
    bool? coldChainTemperatureMonitored,
    bool? medicineStorageConditionsAppropriate,
    bool? generatorBackup,
    double? generatorCapacityKw,
    bool? waterSupplyReliable,
    int? waterStorageCapacityLiters,
    bool? electricityStable,
    bool? internetConnectivity,
    bool? wasteDisposalSystem,
    bool? sharpsDisposalAppropriate,
    bool? biomedicalWasteSegregation,
    bool? accessibilityFeatures,
    bool? wheelchairAccessible,
    bool? fireSafetyEquipment,
    bool? emergencyProtocolsDisplayed,
    bool? laboratoryAvailable,
    bool? xrayAvailable,
    bool? ambulanceService,
    DateTime? assessmentDate,
    String? assessedBy,
    int? infrastructureScore,
    String? priorityImprovements,
  }) {
    return InfrastructureData(
      totalRooms: totalRooms ?? this.totalRooms,
      consultationRooms: consultationRooms ?? this.consultationRooms,
      waitingAreaAdequate: waitingAreaAdequate ?? this.waitingAreaAdequate,
      waitingAreaCapacity: waitingAreaCapacity ?? this.waitingAreaCapacity,
      pharmacyStorageAdequate: pharmacyStorageAdequate ?? this.pharmacyStorageAdequate,
      pharmacyStorageSizeSqm: pharmacyStorageSizeSqm ?? this.pharmacyStorageSizeSqm,
      coldChainAvailable: coldChainAvailable ?? this.coldChainAvailable,
      coldChainTemperatureMonitored: coldChainTemperatureMonitored ?? this.coldChainTemperatureMonitored,
      medicineStorageConditionsAppropriate: medicineStorageConditionsAppropriate ?? this.medicineStorageConditionsAppropriate,
      generatorBackup: generatorBackup ?? this.generatorBackup,
      generatorCapacityKw: generatorCapacityKw ?? this.generatorCapacityKw,
      waterSupplyReliable: waterSupplyReliable ?? this.waterSupplyReliable,
      waterStorageCapacityLiters: waterStorageCapacityLiters ?? this.waterStorageCapacityLiters,
      electricityStable: electricityStable ?? this.electricityStable,
      internetConnectivity: internetConnectivity ?? this.internetConnectivity,
      wasteDisposalSystem: wasteDisposalSystem ?? this.wasteDisposalSystem,
      sharpsDisposalAppropriate: sharpsDisposalAppropriate ?? this.sharpsDisposalAppropriate,
      biomedicalWasteSegregation: biomedicalWasteSegregation ?? this.biomedicalWasteSegregation,
      accessibilityFeatures: accessibilityFeatures ?? this.accessibilityFeatures,
      wheelchairAccessible: wheelchairAccessible ?? this.wheelchairAccessible,
      fireSafetyEquipment: fireSafetyEquipment ?? this.fireSafetyEquipment,
      emergencyProtocolsDisplayed: emergencyProtocolsDisplayed ?? this.emergencyProtocolsDisplayed,
      laboratoryAvailable: laboratoryAvailable ?? this.laboratoryAvailable,
      xrayAvailable: xrayAvailable ?? this.xrayAvailable,
      ambulanceService: ambulanceService ?? this.ambulanceService,
      assessmentDate: assessmentDate ?? this.assessmentDate,
      assessedBy: assessedBy ?? this.assessedBy,
      infrastructureScore: infrastructureScore ?? this.infrastructureScore,
      priorityImprovements: priorityImprovements ?? this.priorityImprovements,
    );
  }
}