class EquipmentData {
  // Equipment with quantities and units
  final String? sphygmomanometer;
  final int? sphygmomanometerQuantity;
  final String? sphygmomanometerUnits;
  
  final String? weighingScale;
  final int? weighingScaleQuantity;
  final String? weighingScaleUnits;
  
  final String? measuringTape;
  final int? measuringTapeQuantity;
  final String? measuringTapeUnits;
  
  final String? peakExpiratoryFlowMeter;
  final int? peakExpiratoryFlowMeterQuantity;
  final String? peakExpiratoryFlowMeterUnits;
  
  final String? oxygen;
  final int? oxygenQuantity;
  final String? oxygenUnits;
  
  final String? oxygenMask;
  final int? oxygenMaskQuantity;
  final String? oxygenMaskUnits;
  
  final String? nebulizer;
  final int? nebulizerQuantity;
  final String? nebulizerUnits;
  
  final String? pulseOximetry;
  final int? pulseOximetryQuantity;
  final String? pulseOximetryUnits;
  
  final String? glucometer;
  final int? glucometerQuantity;
  final String? glucometerUnits;
  
  final String? glucometerStrips;
  final int? glucometerStripsQuantity;
  final String? glucometerStripsUnits;
  
  final String? lancets;
  final int? lancetsQuantity;
  final String? lancetsUnits;
  
  final String? urineDipstick;
  final int? urineDipstickQuantity;
  final String? urineDipstickUnits;
  
  final String? ecg;
  final int? ecgQuantity;
  final String? ecgUnits;
  
  final String? otherEquipment;
  final int? otherEquipmentQuantity;
  final String? otherEquipmentUnits;
  final String? otherEquipmentSpecify;
  
  final String? stethoscope;
  final int? stethoscopeQuantity;
  
  final String? thermometer;
  final int? thermometerQuantity;
  
  final String? examinationTable;
  final int? examinationTableQuantity;
  
  final String? privacyScreen;
  final int? privacyScreenQuantity;
  
  final String? actionsAgreed;

  EquipmentData({
    this.sphygmomanometer,
    this.sphygmomanometerQuantity,
    this.sphygmomanometerUnits,
    this.weighingScale,
    this.weighingScaleQuantity,
    this.weighingScaleUnits,
    this.measuringTape,
    this.measuringTapeQuantity,
    this.measuringTapeUnits,
    this.peakExpiratoryFlowMeter,
    this.peakExpiratoryFlowMeterQuantity,
    this.peakExpiratoryFlowMeterUnits,
    this.oxygen,
    this.oxygenQuantity,
    this.oxygenUnits,
    this.oxygenMask,
    this.oxygenMaskQuantity,
    this.oxygenMaskUnits,
    this.nebulizer,
    this.nebulizerQuantity,
    this.nebulizerUnits,
    this.pulseOximetry,
    this.pulseOximetryQuantity,
    this.pulseOximetryUnits,
    this.glucometer,
    this.glucometerQuantity,
    this.glucometerUnits,
    this.glucometerStrips,
    this.glucometerStripsQuantity,
    this.glucometerStripsUnits,
    this.lancets,
    this.lancetsQuantity,
    this.lancetsUnits,
    this.urineDipstick,
    this.urineDipstickQuantity,
    this.urineDipstickUnits,
    this.ecg,
    this.ecgQuantity,
    this.ecgUnits,
    this.otherEquipment,
    this.otherEquipmentQuantity,
    this.otherEquipmentUnits,
    this.otherEquipmentSpecify,
    this.stethoscope,
    this.stethoscopeQuantity,
    this.thermometer,
    this.thermometerQuantity,
    this.examinationTable,
    this.examinationTableQuantity,
    this.privacyScreen,
    this.privacyScreenQuantity,
    this.actionsAgreed,
  });

  factory EquipmentData.fromJson(Map<String, dynamic> json) {
    return EquipmentData(
      sphygmomanometer: json['sphygmomanometer'],
      sphygmomanometerQuantity: json['sphygmomanometer_quantity'] ?? json['sphygmomanometerQuantity'],
      sphygmomanometerUnits: json['sphygmomanometer_units'] ?? json['sphygmomanometerUnits'],
      weighingScale: json['weighing_scale'] ?? json['weighingScale'],
      weighingScaleQuantity: json['weighing_scale_quantity'] ?? json['weighingScaleQuantity'],
      weighingScaleUnits: json['weighing_scale_units'] ?? json['weighingScaleUnits'],
      measuringTape: json['measuring_tape'] ?? json['measuringTape'],
      measuringTapeQuantity: json['measuring_tape_quantity'] ?? json['measuringTapeQuantity'],
      measuringTapeUnits: json['measuring_tape_units'] ?? json['measuringTapeUnits'],
      peakExpiratoryFlowMeter: json['peak_expiratory_flow_meter'] ?? json['peakExpiratoryFlowMeter'],
      peakExpiratoryFlowMeterQuantity: json['peak_expiratory_flow_meter_quantity'] ?? json['peakExpiratoryFlowMeterQuantity'],
      peakExpiratoryFlowMeterUnits: json['peak_expiratory_flow_meter_units'] ?? json['peakExpiratoryFlowMeterUnits'],
      oxygen: json['oxygen'],
      oxygenQuantity: json['oxygen_quantity'] ?? json['oxygenQuantity'],
      oxygenUnits: json['oxygen_units'] ?? json['oxygenUnits'],
      oxygenMask: json['oxygen_mask'] ?? json['oxygenMask'],
      oxygenMaskQuantity: json['oxygen_mask_quantity'] ?? json['oxygenMaskQuantity'],
      oxygenMaskUnits: json['oxygen_mask_units'] ?? json['oxygenMaskUnits'],
      nebulizer: json['nebulizer'],
      nebulizerQuantity: json['nebulizer_quantity'] ?? json['nebulizerQuantity'],
      nebulizerUnits: json['nebulizer_units'] ?? json['nebulizerUnits'],
      pulseOximetry: json['pulse_oximetry'] ?? json['pulseOximetry'],
      pulseOximetryQuantity: json['pulse_oximetry_quantity'] ?? json['pulseOximetryQuantity'],
      pulseOximetryUnits: json['pulse_oximetry_units'] ?? json['pulseOximetryUnits'],
      glucometer: json['glucometer'],
      glucometerQuantity: json['glucometer_quantity'] ?? json['glucometerQuantity'],
      glucometerUnits: json['glucometer_units'] ?? json['glucometerUnits'],
      glucometerStrips: json['glucometer_strips'] ?? json['glucometerStrips'],
      glucometerStripsQuantity: json['glucometer_strips_quantity'] ?? json['glucometerStripsQuantity'],
      glucometerStripsUnits: json['glucometer_strips_units'] ?? json['glucometerStripsUnits'],
      lancets: json['lancets'],
      lancetsQuantity: json['lancets_quantity'] ?? json['lancetsQuantity'],
      lancetsUnits: json['lancets_units'] ?? json['lancetsUnits'],
      urineDipstick: json['urine_dipstick'] ?? json['urineDipstick'],
      urineDipstickQuantity: json['urine_dipstick_quantity'] ?? json['urineDipstickQuantity'],
      urineDipstickUnits: json['urine_dipstick_units'] ?? json['urineDipstickUnits'],
      ecg: json['ecg'],
      ecgQuantity: json['ecg_quantity'] ?? json['ecgQuantity'],
      ecgUnits: json['ecg_units'] ?? json['ecgUnits'],
      otherEquipment: json['other_equipment'] ?? json['otherEquipment'],
      otherEquipmentQuantity: json['other_equipment_quantity'] ?? json['otherEquipmentQuantity'],
      otherEquipmentUnits: json['other_equipment_units'] ?? json['otherEquipmentUnits'],
      otherEquipmentSpecify: json['other_equipment_specify'] ?? json['otherEquipmentSpecify'],
      stethoscope: json['stethoscope'],
      stethoscopeQuantity: json['stethoscope_quantity'] ?? json['stethoscopeQuantity'],
      thermometer: json['thermometer'],
      thermometerQuantity: json['thermometer_quantity'] ?? json['thermometerQuantity'],
      examinationTable: json['examination_table'] ?? json['examinationTable'],
      examinationTableQuantity: json['examination_table_quantity'] ?? json['examinationTableQuantity'],
      privacyScreen: json['privacy_screen'] ?? json['privacyScreen'],
      privacyScreenQuantity: json['privacy_screen_quantity'] ?? json['privacyScreenQuantity'],
      actionsAgreed: json['actions_agreed'] ?? json['actionsAgreed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (sphygmomanometer != null) 'sphygmomanometer': sphygmomanometer,
      if (sphygmomanometerQuantity != null) 'sphygmomanometer_quantity': sphygmomanometerQuantity,
      if (sphygmomanometerUnits != null) 'sphygmomanometer_units': sphygmomanometerUnits,
      if (weighingScale != null) 'weighing_scale': weighingScale,
      if (weighingScaleQuantity != null) 'weighing_scale_quantity': weighingScaleQuantity,
      if (weighingScaleUnits != null) 'weighing_scale_units': weighingScaleUnits,
      if (measuringTape != null) 'measuring_tape': measuringTape,
      if (measuringTapeQuantity != null) 'measuring_tape_quantity': measuringTapeQuantity,
      if (measuringTapeUnits != null) 'measuring_tape_units': measuringTapeUnits,
      if (peakExpiratoryFlowMeter != null) 'peak_expiratory_flow_meter': peakExpiratoryFlowMeter,
      if (peakExpiratoryFlowMeterQuantity != null) 'peak_expiratory_flow_meter_quantity': peakExpiratoryFlowMeterQuantity,
      if (peakExpiratoryFlowMeterUnits != null) 'peak_expiratory_flow_meter_units': peakExpiratoryFlowMeterUnits,
      if (oxygen != null) 'oxygen': oxygen,
      if (oxygenQuantity != null) 'oxygen_quantity': oxygenQuantity,
      if (oxygenUnits != null) 'oxygen_units': oxygenUnits,
      if (oxygenMask != null) 'oxygen_mask': oxygenMask,
      if (oxygenMaskQuantity != null) 'oxygen_mask_quantity': oxygenMaskQuantity,
      if (oxygenMaskUnits != null) 'oxygen_mask_units': oxygenMaskUnits,
      if (nebulizer != null) 'nebulizer': nebulizer,
      if (nebulizerQuantity != null) 'nebulizer_quantity': nebulizerQuantity,
      if (nebulizerUnits != null) 'nebulizer_units': nebulizerUnits,
      if (pulseOximetry != null) 'pulse_oximetry': pulseOximetry,
      if (pulseOximetryQuantity != null) 'pulse_oximetry_quantity': pulseOximetryQuantity,
      if (pulseOximetryUnits != null) 'pulse_oximetry_units': pulseOximetryUnits,
      if (glucometer != null) 'glucometer': glucometer,
      if (glucometerQuantity != null) 'glucometer_quantity': glucometerQuantity,
      if (glucometerUnits != null) 'glucometer_units': glucometerUnits,
      if (glucometerStrips != null) 'glucometer_strips': glucometerStrips,
      if (glucometerStripsQuantity != null) 'glucometer_strips_quantity': glucometerStripsQuantity,
      if (glucometerStripsUnits != null) 'glucometer_strips_units': glucometerStripsUnits,
      if (lancets != null) 'lancets': lancets,
      if (lancetsQuantity != null) 'lancets_quantity': lancetsQuantity,
      if (lancetsUnits != null) 'lancets_units': lancetsUnits,
      if (urineDipstick != null) 'urine_dipstick': urineDipstick,
      if (urineDipstickQuantity != null) 'urine_dipstick_quantity': urineDipstickQuantity,
      if (urineDipstickUnits != null) 'urine_dipstick_units': urineDipstickUnits,
      if (ecg != null) 'ecg': ecg,
      if (ecgQuantity != null) 'ecg_quantity': ecgQuantity,
      if (ecgUnits != null) 'ecg_units': ecgUnits,
      if (otherEquipment != null) 'other_equipment': otherEquipment,
      if (otherEquipmentQuantity != null) 'other_equipment_quantity': otherEquipmentQuantity,
      if (otherEquipmentUnits != null) 'other_equipment_units': otherEquipmentUnits,
      if (otherEquipmentSpecify != null) 'other_equipment_specify': otherEquipmentSpecify,
      if (stethoscope != null) 'stethoscope': stethoscope,
      if (stethoscopeQuantity != null) 'stethoscope_quantity': stethoscopeQuantity,
      if (thermometer != null) 'thermometer': thermometer,
      if (thermometerQuantity != null) 'thermometer_quantity': thermometerQuantity,
      if (examinationTable != null) 'examination_table': examinationTable,
      if (examinationTableQuantity != null) 'examination_table_quantity': examinationTableQuantity,
      if (privacyScreen != null) 'privacy_screen': privacyScreen,
      if (privacyScreenQuantity != null) 'privacy_screen_quantity': privacyScreenQuantity,
      if (actionsAgreed != null) 'actions_agreed': actionsAgreed,
    };
  }

  Map<String, dynamic> toServerJson() {
    return {
      if (sphygmomanometer != null) 'sphygmomanometer': sphygmomanometer,
      if (sphygmomanometerQuantity != null) 'sphygmomanometer_quantity': sphygmomanometerQuantity,
      if (sphygmomanometerUnits != null) 'sphygmomanometer_units': sphygmomanometerUnits,
      if (weighingScale != null) 'weighing_scale': weighingScale,
      if (weighingScaleQuantity != null) 'weighing_scale_quantity': weighingScaleQuantity,
      if (weighingScaleUnits != null) 'weighing_scale_units': weighingScaleUnits,
      if (measuringTape != null) 'measuring_tape': measuringTape,
      if (measuringTapeQuantity != null) 'measuring_tape_quantity': measuringTapeQuantity,
      if (measuringTapeUnits != null) 'measuring_tape_units': measuringTapeUnits,
      if (peakExpiratoryFlowMeter != null) 'peak_expiratory_flow_meter': peakExpiratoryFlowMeter,
      if (peakExpiratoryFlowMeterQuantity != null) 'peak_expiratory_flow_meter_quantity': peakExpiratoryFlowMeterQuantity,
      if (peakExpiratoryFlowMeterUnits != null) 'peak_expiratory_flow_meter_units': peakExpiratoryFlowMeterUnits,
      if (oxygen != null) 'oxygen': oxygen,
      if (oxygenQuantity != null) 'oxygen_quantity': oxygenQuantity,
      if (oxygenUnits != null) 'oxygen_units': oxygenUnits,
      if (oxygenMask != null) 'oxygen_mask': oxygenMask,
      if (oxygenMaskQuantity != null) 'oxygen_mask_quantity': oxygenMaskQuantity,
      if (oxygenMaskUnits != null) 'oxygen_mask_units': oxygenMaskUnits,
      if (nebulizer != null) 'nebulizer': nebulizer,
      if (nebulizerQuantity != null) 'nebulizer_quantity': nebulizerQuantity,
      if (nebulizerUnits != null) 'nebulizer_units': nebulizerUnits,
      if (pulseOximetry != null) 'pulse_oximetry': pulseOximetry,
      if (pulseOximetryQuantity != null) 'pulse_oximetry_quantity': pulseOximetryQuantity,
      if (pulseOximetryUnits != null) 'pulse_oximetry_units': pulseOximetryUnits,
      if (glucometer != null) 'glucometer': glucometer,
      if (glucometerQuantity != null) 'glucometer_quantity': glucometerQuantity,
      if (glucometerUnits != null) 'glucometer_units': glucometerUnits,
      if (glucometerStrips != null) 'glucometer_strips': glucometerStrips,
      if (glucometerStripsQuantity != null) 'glucometer_strips_quantity': glucometerStripsQuantity,
      if (glucometerStripsUnits != null) 'glucometer_strips_units': glucometerStripsUnits,
      if (lancets != null) 'lancets': lancets,
      if (lancetsQuantity != null) 'lancets_quantity': lancetsQuantity,
      if (lancetsUnits != null) 'lancets_units': lancetsUnits,
      if (urineDipstick != null) 'urine_dipstick': urineDipstick,
      if (urineDipstickQuantity != null) 'urine_dipstick_quantity': urineDipstickQuantity,
      if (urineDipstickUnits != null) 'urine_dipstick_units': urineDipstickUnits,
      if (ecg != null) 'ecg': ecg,
      if (ecgQuantity != null) 'ecg_quantity': ecgQuantity,
      if (ecgUnits != null) 'ecg_units': ecgUnits,
      if (otherEquipment != null) 'other_equipment': otherEquipment,
      if (otherEquipmentQuantity != null) 'other_equipment_quantity': otherEquipmentQuantity,
      if (otherEquipmentUnits != null) 'other_equipment_units': otherEquipmentUnits,
      if (otherEquipmentSpecify != null) 'other_equipment_specify': otherEquipmentSpecify,
      if (stethoscope != null) 'stethoscope': stethoscope,
      if (stethoscopeQuantity != null) 'stethoscope_quantity': stethoscopeQuantity,
      if (thermometer != null) 'thermometer': thermometer,
      if (thermometerQuantity != null) 'thermometer_quantity': thermometerQuantity,
      if (examinationTable != null) 'examination_table': examinationTable,
      if (examinationTableQuantity != null) 'examination_table_quantity': examinationTableQuantity,
      if (privacyScreen != null) 'privacy_screen': privacyScreen,
      if (privacyScreenQuantity != null) 'privacy_screen_quantity': privacyScreenQuantity,
      if (actionsAgreed != null) 'actions_agreed': actionsAgreed,
    };
  }

  EquipmentData copyWith({
    String? sphygmomanometer,
    int? sphygmomanometerQuantity,
    String? sphygmomanometerUnits,
    String? weighingScale,
    int? weighingScaleQuantity,
    String? weighingScaleUnits,
    String? measuringTape,
    int? measuringTapeQuantity,
    String? measuringTapeUnits,
    String? peakExpiratoryFlowMeter,
    int? peakExpiratoryFlowMeterQuantity,
    String? peakExpiratoryFlowMeterUnits,
    String? oxygen,
    int? oxygenQuantity,
    String? oxygenUnits,
    String? oxygenMask,
    int? oxygenMaskQuantity,
    String? oxygenMaskUnits,
    String? nebulizer,
    int? nebulizerQuantity,
    String? nebulizerUnits,
    String? pulseOximetry,
    int? pulseOximetryQuantity,
    String? pulseOximetryUnits,
    String? glucometer,
    int? glucometerQuantity,
    String? glucometerUnits,
    String? glucometerStrips,
    int? glucometerStripsQuantity,
    String? glucometerStripsUnits,
    String? lancets,
    int? lancetsQuantity,
    String? lancetsUnits,
    String? urineDipstick,
    int? urineDipstickQuantity,
    String? urineDipstickUnits,
    String? ecg,
    int? ecgQuantity,
    String? ecgUnits,
    String? otherEquipment,
    int? otherEquipmentQuantity,
    String? otherEquipmentUnits,
    String? otherEquipmentSpecify,
    String? stethoscope,
    int? stethoscopeQuantity,
    String? thermometer,
    int? thermometerQuantity,
    String? examinationTable,
    int? examinationTableQuantity,
    String? privacyScreen,
    int? privacyScreenQuantity,
    String? actionsAgreed,
  }) {
    return EquipmentData(
      sphygmomanometer: sphygmomanometer ?? this.sphygmomanometer,
      sphygmomanometerQuantity: sphygmomanometerQuantity ?? this.sphygmomanometerQuantity,
      sphygmomanometerUnits: sphygmomanometerUnits ?? this.sphygmomanometerUnits,
      weighingScale: weighingScale ?? this.weighingScale,
      weighingScaleQuantity: weighingScaleQuantity ?? this.weighingScaleQuantity,
      weighingScaleUnits: weighingScaleUnits ?? this.weighingScaleUnits,
      measuringTape: measuringTape ?? this.measuringTape,
      measuringTapeQuantity: measuringTapeQuantity ?? this.measuringTapeQuantity,
      measuringTapeUnits: measuringTapeUnits ?? this.measuringTapeUnits,
      peakExpiratoryFlowMeter: peakExpiratoryFlowMeter ?? this.peakExpiratoryFlowMeter,
      peakExpiratoryFlowMeterQuantity: peakExpiratoryFlowMeterQuantity ?? this.peakExpiratoryFlowMeterQuantity,
      peakExpiratoryFlowMeterUnits: peakExpiratoryFlowMeterUnits ?? this.peakExpiratoryFlowMeterUnits,
      oxygen: oxygen ?? this.oxygen,
      oxygenQuantity: oxygenQuantity ?? this.oxygenQuantity,
      oxygenUnits: oxygenUnits ?? this.oxygenUnits,
      oxygenMask: oxygenMask ?? this.oxygenMask,
      oxygenMaskQuantity: oxygenMaskQuantity ?? this.oxygenMaskQuantity,
      oxygenMaskUnits: oxygenMaskUnits ?? this.oxygenMaskUnits,
      nebulizer: nebulizer ?? this.nebulizer,
      nebulizerQuantity: nebulizerQuantity ?? this.nebulizerQuantity,
      nebulizerUnits: nebulizerUnits ?? this.nebulizerUnits,
      pulseOximetry: pulseOximetry ?? this.pulseOximetry,
      pulseOximetryQuantity: pulseOximetryQuantity ?? this.pulseOximetryQuantity,
      pulseOximetryUnits: pulseOximetryUnits ?? this.pulseOximetryUnits,
      glucometer: glucometer ?? this.glucometer,
      glucometerQuantity: glucometerQuantity ?? this.glucometerQuantity,
      glucometerUnits: glucometerUnits ?? this.glucometerUnits,
      glucometerStrips: glucometerStrips ?? this.glucometerStrips,
      glucometerStripsQuantity: glucometerStripsQuantity ?? this.glucometerStripsQuantity,
      glucometerStripsUnits: glucometerStripsUnits ?? this.glucometerStripsUnits,
      lancets: lancets ?? this.lancets,
      lancetsQuantity: lancetsQuantity ?? this.lancetsQuantity,
      lancetsUnits: lancetsUnits ?? this.lancetsUnits,
      urineDipstick: urineDipstick ?? this.urineDipstick,
      urineDipstickQuantity: urineDipstickQuantity ?? this.urineDipstickQuantity,
      urineDipstickUnits: urineDipstickUnits ?? this.urineDipstickUnits,
      ecg: ecg ?? this.ecg,
      ecgQuantity: ecgQuantity ?? this.ecgQuantity,
      ecgUnits: ecgUnits ?? this.ecgUnits,
      otherEquipment: otherEquipment ?? this.otherEquipment,
      otherEquipmentQuantity: otherEquipmentQuantity ?? this.otherEquipmentQuantity,
      otherEquipmentUnits: otherEquipmentUnits ?? this.otherEquipmentUnits,
      otherEquipmentSpecify: otherEquipmentSpecify ?? this.otherEquipmentSpecify,
      stethoscope: stethoscope ?? this.stethoscope,
      stethoscopeQuantity: stethoscopeQuantity ?? this.stethoscopeQuantity,
      thermometer: thermometer ?? this.thermometer,
      thermometerQuantity: thermometerQuantity ?? this.thermometerQuantity,
      examinationTable: examinationTable ?? this.examinationTable,
      examinationTableQuantity: examinationTableQuantity ?? this.examinationTableQuantity,
      privacyScreen: privacyScreen ?? this.privacyScreen,
      privacyScreenQuantity: privacyScreenQuantity ?? this.privacyScreenQuantity,
      actionsAgreed: actionsAgreed ?? this.actionsAgreed,
    );
  }
}