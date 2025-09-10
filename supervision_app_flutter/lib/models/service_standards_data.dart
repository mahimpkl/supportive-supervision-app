class ServiceStandardsData {
  // C2 main response and sub-services
  final String? c2MainResponse;
  final String? c2MainComment;
  final String? c2RespondentsComment;

  // C2 sub-services from PDF page 6
  final String? c2BloodPressure;
  final String? c2BloodPressureComment;
  final bool? c2BloodPressureEquipmentCalibrated;
  final bool? c2BloodPressureProtocolFollowed;

  final String? c2BloodSugar;
  final String? c2BloodSugarComment;
  final bool? c2BloodSugarStripsAvailable;
  final bool? c2BloodSugarQualityControl;

  final String? c2BmiMeasurement;
  final String? c2BmiMeasurementComment;
  final bool? c2BmiCalculationAccurate;

  final String? c2WaistCircumference;
  final String? c2WaistCircumferenceComment;
  final bool? c2WaistMeasurementTechniqueCorrect;

  final String? c2CvdRiskEstimation;
  final String? c2CvdRiskEstimationComment;
  final bool? c2CvdChartAvailableAndUsed;

  final String? c2UrineProteinMeasurement;
  final String? c2UrineProteinMeasurementComment;
  final bool? c2UrineProteinStripsNotExpired;

  final String? c2PeakExpiratoryFlowRate;
  final String? c2PeakExpiratoryFlowRateComment;
  final bool? c2PeakFlowMeterCalibrated;

  final String? c2EgfrCalculation;
  final String? c2EgfrCalculationComment;
  final bool? c2EgfrFormulaUsedCorrectly;

  final String? c2BriefIntervention;
  final String? c2BriefInterventionComment;

  final String? c2FootExamination;
  final String? c2FootExaminationComment;

  final String? c2OralExamination;
  final String? c2OralExaminationComment;

  final String? c2EyeExamination;
  final String? c2EyeExaminationComment;

  final String? c2HealthEducation;
  final String? c2HealthEducationComment;

  // C3-C7 responses
  final String? c3Response;
  final String? c3Comment;
  final String? c3RespondentsComment;

  final String? c4Response;
  final String? c4Comment;
  final String? c4RespondentsComment;

  final String? c5Response;
  final String? c5Comment;
  final String? c5RespondentsComment;

  final String? c6Response;
  final String? c6Comment;
  final String? c6RespondentsComment;

  final String? c7Response;
  final String? c7Comment;
  final String? c7RespondentsComment;

  final String? actionsAgreed;

  ServiceStandardsData({
    this.c2MainResponse,
    this.c2MainComment,
    this.c2RespondentsComment,
    this.c2BloodPressure,
    this.c2BloodPressureComment,
    this.c2BloodPressureEquipmentCalibrated,
    this.c2BloodPressureProtocolFollowed,
    this.c2BloodSugar,
    this.c2BloodSugarComment,
    this.c2BloodSugarStripsAvailable,
    this.c2BloodSugarQualityControl,
    this.c2BmiMeasurement,
    this.c2BmiMeasurementComment,
    this.c2BmiCalculationAccurate,
    this.c2WaistCircumference,
    this.c2WaistCircumferenceComment,
    this.c2WaistMeasurementTechniqueCorrect,
    this.c2CvdRiskEstimation,
    this.c2CvdRiskEstimationComment,
    this.c2CvdChartAvailableAndUsed,
    this.c2UrineProteinMeasurement,
    this.c2UrineProteinMeasurementComment,
    this.c2UrineProteinStripsNotExpired,
    this.c2PeakExpiratoryFlowRate,
    this.c2PeakExpiratoryFlowRateComment,
    this.c2PeakFlowMeterCalibrated,
    this.c2EgfrCalculation,
    this.c2EgfrCalculationComment,
    this.c2EgfrFormulaUsedCorrectly,
    this.c2BriefIntervention,
    this.c2BriefInterventionComment,
    this.c2FootExamination,
    this.c2FootExaminationComment,
    this.c2OralExamination,
    this.c2OralExaminationComment,
    this.c2EyeExamination,
    this.c2EyeExaminationComment,
    this.c2HealthEducation,
    this.c2HealthEducationComment,
    this.c3Response,
    this.c3Comment,
    this.c3RespondentsComment,
    this.c4Response,
    this.c4Comment,
    this.c4RespondentsComment,
    this.c5Response,
    this.c5Comment,
    this.c5RespondentsComment,
    this.c6Response,
    this.c6Comment,
    this.c6RespondentsComment,
    this.c7Response,
    this.c7Comment,
    this.c7RespondentsComment,
    this.actionsAgreed,
  });

  factory ServiceStandardsData.fromJson(Map<String, dynamic> json) {
    return ServiceStandardsData(
      c2MainResponse: json['c2_main_response'] ?? json['c2MainResponse'],
      c2MainComment: json['c2_main_comment'] ?? json['c2MainComment'],
      c2RespondentsComment: json['c2_respondents_comment'] ?? json['c2RespondentsComment'],
      c2BloodPressure: json['c2_blood_pressure'] ?? json['c2BloodPressure'],
      c2BloodPressureComment: json['c2_blood_pressure_comment'] ?? json['c2BloodPressureComment'],
      c2BloodPressureEquipmentCalibrated: _parseBool(json['c2_blood_pressure_equipment_calibrated'] ?? json['c2BloodPressureEquipmentCalibrated']),
      c2BloodPressureProtocolFollowed: _parseBool(json['c2_blood_pressure_protocol_followed'] ?? json['c2BloodPressureProtocolFollowed']),
      c2BloodSugar: json['c2_blood_sugar'] ?? json['c2BloodSugar'],
      c2BloodSugarComment: json['c2_blood_sugar_comment'] ?? json['c2BloodSugarComment'],
      c2BloodSugarStripsAvailable: _parseBool(json['c2_blood_sugar_strips_available'] ?? json['c2BloodSugarStripsAvailable']),
      c2BloodSugarQualityControl: _parseBool(json['c2_blood_sugar_quality_control'] ?? json['c2BloodSugarQualityControl']),
      c2BmiMeasurement: json['c2_bmi_measurement'] ?? json['c2BmiMeasurement'],
      c2BmiMeasurementComment: json['c2_bmi_measurement_comment'] ?? json['c2BmiMeasurementComment'],
      c2BmiCalculationAccurate: _parseBool(json['c2_bmi_calculation_accurate'] ?? json['c2BmiCalculationAccurate']),
      c2WaistCircumference: json['c2_waist_circumference'] ?? json['c2WaistCircumference'],
      c2WaistCircumferenceComment: json['c2_waist_circumference_comment'] ?? json['c2WaistCircumferenceComment'],
      c2WaistMeasurementTechniqueCorrect: _parseBool(json['c2_waist_measurement_technique_correct'] ?? json['c2WaistMeasurementTechniqueCorrect']),
      c2CvdRiskEstimation: json['c2_cvd_risk_estimation'] ?? json['c2CvdRiskEstimation'],
      c2CvdRiskEstimationComment: json['c2_cvd_risk_estimation_comment'] ?? json['c2CvdRiskEstimationComment'],
      c2CvdChartAvailableAndUsed: _parseBool(json['c2_cvd_chart_available_and_used'] ?? json['c2CvdChartAvailableAndUsed']),
      c2UrineProteinMeasurement: json['c2_urine_protein_measurement'] ?? json['c2UrineProteinMeasurement'],
      c2UrineProteinMeasurementComment: json['c2_urine_protein_measurement_comment'] ?? json['c2UrineProteinMeasurementComment'],
      c2UrineProteinStripsNotExpired: _parseBool(json['c2_urine_protein_strips_not_expired'] ?? json['c2UrineProteinStripsNotExpired']),
      c2PeakExpiratoryFlowRate: json['c2_peak_expiratory_flow_rate'] ?? json['c2PeakExpiratoryFlowRate'],
      c2PeakExpiratoryFlowRateComment: json['c2_peak_expiratory_flow_rate_comment'] ?? json['c2PeakExpiratoryFlowRateComment'],
      c2PeakFlowMeterCalibrated: _parseBool(json['c2_peak_flow_meter_calibrated'] ?? json['c2PeakFlowMeterCalibrated']),
      c2EgfrCalculation: json['c2_egfr_calculation'] ?? json['c2EgfrCalculation'],
      c2EgfrCalculationComment: json['c2_egfr_calculation_comment'] ?? json['c2EgfrCalculationComment'],
      c2EgfrFormulaUsedCorrectly: _parseBool(json['c2_egfr_formula_used_correctly'] ?? json['c2EgfrFormulaUsedCorrectly']),
      c2BriefIntervention: json['c2_brief_intervention'] ?? json['c2BriefIntervention'],
      c2BriefInterventionComment: json['c2_brief_intervention_comment'] ?? json['c2BriefInterventionComment'],
      c2FootExamination: json['c2_foot_examination'] ?? json['c2FootExamination'],
      c2FootExaminationComment: json['c2_foot_examination_comment'] ?? json['c2FootExaminationComment'],
      c2OralExamination: json['c2_oral_examination'] ?? json['c2OralExamination'],
      c2OralExaminationComment: json['c2_oral_examination_comment'] ?? json['c2OralExaminationComment'],
      c2EyeExamination: json['c2_eye_examination'] ?? json['c2EyeExamination'],
      c2EyeExaminationComment: json['c2_eye_examination_comment'] ?? json['c2EyeExaminationComment'],
      c2HealthEducation: json['c2_health_education'] ?? json['c2HealthEducation'],
      c2HealthEducationComment: json['c2_health_education_comment'] ?? json['c2HealthEducationComment'],
      c3Response: json['c3_response'] ?? json['c3Response'],
      c3Comment: json['c3_comment'] ?? json['c3Comment'],
      c3RespondentsComment: json['c3_respondents_comment'] ?? json['c3RespondentsComment'],
      c4Response: json['c4_response'] ?? json['c4Response'],
      c4Comment: json['c4_comment'] ?? json['c4Comment'],
      c4RespondentsComment: json['c4_respondents_comment'] ?? json['c4RespondentsComment'],
      c5Response: json['c5_response'] ?? json['c5Response'],
      c5Comment: json['c5_comment'] ?? json['c5Comment'],
      c5RespondentsComment: json['c5_respondents_comment'] ?? json['c5RespondentsComment'],
      c6Response: json['c6_response'] ?? json['c6Response'],
      c6Comment: json['c6_comment'] ?? json['c6Comment'],
      c6RespondentsComment: json['c6_respondents_comment'] ?? json['c6RespondentsComment'],
      c7Response: json['c7_response'] ?? json['c7Response'],
      c7Comment: json['c7_comment'] ?? json['c7Comment'],
      c7RespondentsComment: json['c7_respondents_comment'] ?? json['c7RespondentsComment'],
      actionsAgreed: json['actions_agreed'] ?? json['actionsAgreed'],
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
      if (c2MainResponse != null) 'c2_main_response': c2MainResponse,
      if (c2MainComment != null) 'c2_main_comment': c2MainComment,
      if (c2RespondentsComment != null) 'c2_respondents_comment': c2RespondentsComment,
      if (c2BloodPressure != null) 'c2_blood_pressure': c2BloodPressure,
      if (c2BloodPressureComment != null) 'c2_blood_pressure_comment': c2BloodPressureComment,
      if (c2BloodPressureEquipmentCalibrated != null) 'c2_blood_pressure_equipment_calibrated': c2BloodPressureEquipmentCalibrated,
      if (c2BloodPressureProtocolFollowed != null) 'c2_blood_pressure_protocol_followed': c2BloodPressureProtocolFollowed,
      if (c2BloodSugar != null) 'c2_blood_sugar': c2BloodSugar,
      if (c2BloodSugarComment != null) 'c2_blood_sugar_comment': c2BloodSugarComment,
      if (c2BloodSugarStripsAvailable != null) 'c2_blood_sugar_strips_available': c2BloodSugarStripsAvailable,
      if (c2BloodSugarQualityControl != null) 'c2_blood_sugar_quality_control': c2BloodSugarQualityControl,
      if (c2BmiMeasurement != null) 'c2_bmi_measurement': c2BmiMeasurement,
      if (c2BmiMeasurementComment != null) 'c2_bmi_measurement_comment': c2BmiMeasurementComment,
      if (c2BmiCalculationAccurate != null) 'c2_bmi_calculation_accurate': c2BmiCalculationAccurate,
      if (c2WaistCircumference != null) 'c2_waist_circumference': c2WaistCircumference,
      if (c2WaistCircumferenceComment != null) 'c2_waist_circumference_comment': c2WaistCircumferenceComment,
      if (c2WaistMeasurementTechniqueCorrect != null) 'c2_waist_measurement_technique_correct': c2WaistMeasurementTechniqueCorrect,
      if (c2CvdRiskEstimation != null) 'c2_cvd_risk_estimation': c2CvdRiskEstimation,
      if (c2CvdRiskEstimationComment != null) 'c2_cvd_risk_estimation_comment': c2CvdRiskEstimationComment,
      if (c2CvdChartAvailableAndUsed != null) 'c2_cvd_chart_available_and_used': c2CvdChartAvailableAndUsed,
      if (c2UrineProteinMeasurement != null) 'c2_urine_protein_measurement': c2UrineProteinMeasurement,
      if (c2UrineProteinMeasurementComment != null) 'c2_urine_protein_measurement_comment': c2UrineProteinMeasurementComment,
      if (c2UrineProteinStripsNotExpired != null) 'c2_urine_protein_strips_not_expired': c2UrineProteinStripsNotExpired,
      if (c2PeakExpiratoryFlowRate != null) 'c2_peak_expiratory_flow_rate': c2PeakExpiratoryFlowRate,
      if (c2PeakExpiratoryFlowRateComment != null) 'c2_peak_expiratory_flow_rate_comment': c2PeakExpiratoryFlowRateComment,
      if (c2PeakFlowMeterCalibrated != null) 'c2_peak_flow_meter_calibrated': c2PeakFlowMeterCalibrated,
      if (c2EgfrCalculation != null) 'c2_egfr_calculation': c2EgfrCalculation,
      if (c2EgfrCalculationComment != null) 'c2_egfr_calculation_comment': c2EgfrCalculationComment,
      if (c2EgfrFormulaUsedCorrectly != null) 'c2_egfr_formula_used_correctly': c2EgfrFormulaUsedCorrectly,
      if (c2BriefIntervention != null) 'c2_brief_intervention': c2BriefIntervention,
      if (c2BriefInterventionComment != null) 'c2_brief_intervention_comment': c2BriefInterventionComment,
      if (c2FootExamination != null) 'c2_foot_examination': c2FootExamination,
      if (c2FootExaminationComment != null) 'c2_foot_examination_comment': c2FootExaminationComment,
      if (c2OralExamination != null) 'c2_oral_examination': c2OralExamination,
      if (c2OralExaminationComment != null) 'c2_oral_examination_comment': c2OralExaminationComment,
      if (c2EyeExamination != null) 'c2_eye_examination': c2EyeExamination,
      if (c2EyeExaminationComment != null) 'c2_eye_examination_comment': c2EyeExaminationComment,
      if (c2HealthEducation != null) 'c2_health_education': c2HealthEducation,
      if (c2HealthEducationComment != null) 'c2_health_education_comment': c2HealthEducationComment,
      if (c3Response != null) 'c3_response': c3Response,
      if (c3Comment != null) 'c3_comment': c3Comment,
      if (c3RespondentsComment != null) 'c3_respondents_comment': c3RespondentsComment,
      if (c4Response != null) 'c4_response': c4Response,
      if (c4Comment != null) 'c4_comment': c4Comment,
      if (c4RespondentsComment != null) 'c4_respondents_comment': c4RespondentsComment,
      if (c5Response != null) 'c5_response': c5Response,
      if (c5Comment != null) 'c5_comment': c5Comment,
      if (c5RespondentsComment != null) 'c5_respondents_comment': c5RespondentsComment,
      if (c6Response != null) 'c6_response': c6Response,
      if (c6Comment != null) 'c6_comment': c6Comment,
      if (c6RespondentsComment != null) 'c6_respondents_comment': c6RespondentsComment,
      if (c7Response != null) 'c7_response': c7Response,
      if (c7Comment != null) 'c7_comment': c7Comment,
      if (c7RespondentsComment != null) 'c7_respondents_comment': c7RespondentsComment,
      if (actionsAgreed != null) 'actions_agreed': actionsAgreed,
    };
  }

  Map<String, dynamic> toServerJson() {
    return {
      if (c2MainResponse != null) 'c2_main_response': c2MainResponse,
      if (c2MainComment != null) 'c2_main_comment': c2MainComment,
      if (c2RespondentsComment != null) 'c2_respondents_comment': c2RespondentsComment,
      if (c2BloodPressure != null) 'c2_blood_pressure': c2BloodPressure,
      if (c2BloodPressureComment != null) 'c2_blood_pressure_comment': c2BloodPressureComment,
      if (c2BloodPressureEquipmentCalibrated != null) 'c2_blood_pressure_equipment_calibrated': c2BloodPressureEquipmentCalibrated,
      if (c2BloodPressureProtocolFollowed != null) 'c2_blood_pressure_protocol_followed': c2BloodPressureProtocolFollowed,
      if (c2BloodSugar != null) 'c2_blood_sugar': c2BloodSugar,
      if (c2BloodSugarComment != null) 'c2_blood_sugar_comment': c2BloodSugarComment,
      if (c2BloodSugarStripsAvailable != null) 'c2_blood_sugar_strips_available': c2BloodSugarStripsAvailable,
      if (c2BloodSugarQualityControl != null) 'c2_blood_sugar_quality_control': c2BloodSugarQualityControl,
      if (c2BmiMeasurement != null) 'c2_bmi_measurement': c2BmiMeasurement,
      if (c2BmiMeasurementComment != null) 'c2_bmi_measurement_comment': c2BmiMeasurementComment,
      if (c2BmiCalculationAccurate != null) 'c2_bmi_calculation_accurate': c2BmiCalculationAccurate,
      if (c2WaistCircumference != null) 'c2_waist_circumference': c2WaistCircumference,
      if (c2WaistCircumferenceComment != null) 'c2_waist_circumference_comment': c2WaistCircumferenceComment,
      if (c2WaistMeasurementTechniqueCorrect != null) 'c2_waist_measurement_technique_correct': c2WaistMeasurementTechniqueCorrect,
      if (c2CvdRiskEstimation != null) 'c2_cvd_risk_estimation': c2CvdRiskEstimation,
      if (c2CvdRiskEstimationComment != null) 'c2_cvd_risk_estimation_comment': c2CvdRiskEstimationComment,
      if (c2CvdChartAvailableAndUsed != null) 'c2_cvd_chart_available_and_used': c2CvdChartAvailableAndUsed,
      if (c2UrineProteinMeasurement != null) 'c2_urine_protein_measurement': c2UrineProteinMeasurement,
      if (c2UrineProteinMeasurementComment != null) 'c2_urine_protein_measurement_comment': c2UrineProteinMeasurementComment,
      if (c2UrineProteinStripsNotExpired != null) 'c2_urine_protein_strips_not_expired': c2UrineProteinStripsNotExpired,
      if (c2PeakExpiratoryFlowRate != null) 'c2_peak_expiratory_flow_rate': c2PeakExpiratoryFlowRate,
      if (c2PeakExpiratoryFlowRateComment != null) 'c2_peak_expiratory_flow_rate_comment': c2PeakExpiratoryFlowRateComment,
      if (c2PeakFlowMeterCalibrated != null) 'c2_peak_flow_meter_calibrated': c2PeakFlowMeterCalibrated,
      if (c2EgfrCalculation != null) 'c2_egfr_calculation': c2EgfrCalculation,
      if (c2EgfrCalculationComment != null) 'c2_egfr_calculation_comment': c2EgfrCalculationComment,
      if (c2EgfrFormulaUsedCorrectly != null) 'c2_egfr_formula_used_correctly': c2EgfrFormulaUsedCorrectly,
      if (c2BriefIntervention != null) 'c2_brief_intervention': c2BriefIntervention,
      if (c2BriefInterventionComment != null) 'c2_brief_intervention_comment': c2BriefInterventionComment,
      if (c2FootExamination != null) 'c2_foot_examination': c2FootExamination,
      if (c2FootExaminationComment != null) 'c2_foot_examination_comment': c2FootExaminationComment,
      if (c2OralExamination != null) 'c2_oral_examination': c2OralExamination,
      if (c2OralExaminationComment != null) 'c2_oral_examination_comment': c2OralExaminationComment,
      if (c2EyeExamination != null) 'c2_eye_examination': c2EyeExamination,
      if (c2EyeExaminationComment != null) 'c2_eye_examination_comment': c2EyeExaminationComment,
      if (c2HealthEducation != null) 'c2_health_education': c2HealthEducation,
      if (c2HealthEducationComment != null) 'c2_health_education_comment': c2HealthEducationComment,
      if (c3Response != null) 'c3_response': c3Response,
      if (c3Comment != null) 'c3_comment': c3Comment,
      if (c3RespondentsComment != null) 'c3_respondents_comment': c3RespondentsComment,
      if (c4Response != null) 'c4_response': c4Response,
      if (c4Comment != null) 'c4_comment': c4Comment,
      if (c4RespondentsComment != null) 'c4_respondents_comment': c4RespondentsComment,
      if (c5Response != null) 'c5_response': c5Response,
      if (c5Comment != null) 'c5_comment': c5Comment,
      if (c5RespondentsComment != null) 'c5_respondents_comment': c5RespondentsComment,
      if (c6Response != null) 'c6_response': c6Response,
      if (c6Comment != null) 'c6_comment': c6Comment,
      if (c6RespondentsComment != null) 'c6_respondents_comment': c6RespondentsComment,
      if (c7Response != null) 'c7_response': c7Response,
      if (c7Comment != null) 'c7_comment': c7Comment,
      if (c7RespondentsComment != null) 'c7_respondents_comment': c7RespondentsComment,
      if (actionsAgreed != null) 'actions_agreed': actionsAgreed,
    };
  }

  ServiceStandardsData copyWith({
    String? c2MainResponse,
    String? c2MainComment,
    String? c2RespondentsComment,
    String? c2BloodPressure,
    String? c2BloodPressureComment,
    bool? c2BloodPressureEquipmentCalibrated,
    bool? c2BloodPressureProtocolFollowed,
    String? c2BloodSugar,
    String? c2BloodSugarComment,
    bool? c2BloodSugarStripsAvailable,
    bool? c2BloodSugarQualityControl,
    String? c2BmiMeasurement,
    String? c2BmiMeasurementComment,
    bool? c2BmiCalculationAccurate,
    String? c2WaistCircumference,
    String? c2WaistCircumferenceComment,
    bool? c2WaistMeasurementTechniqueCorrect,
    String? c2CvdRiskEstimation,
    String? c2CvdRiskEstimationComment,
    bool? c2CvdChartAvailableAndUsed,
    String? c2UrineProteinMeasurement,
    String? c2UrineProteinMeasurementComment,
    bool? c2UrineProteinStripsNotExpired,
    String? c2PeakExpiratoryFlowRate,
    String? c2PeakExpiratoryFlowRateComment,
    bool? c2PeakFlowMeterCalibrated,
    String? c2EgfrCalculation,
    String? c2EgfrCalculationComment,
    bool? c2EgfrFormulaUsedCorrectly,
    String? c2BriefIntervention,
    String? c2BriefInterventionComment,
    String? c2FootExamination,
    String? c2FootExaminationComment,
    String? c2OralExamination,
    String? c2OralExaminationComment,
    String? c2EyeExamination,
    String? c2EyeExaminationComment,
    String? c2HealthEducation,
    String? c2HealthEducationComment,
    String? c3Response,
    String? c3Comment,
    String? c3RespondentsComment,
    String? c4Response,
    String? c4Comment,
    String? c4RespondentsComment,
    String? c5Response,
    String? c5Comment,
    String? c5RespondentsComment,
    String? c6Response,
    String? c6Comment,
    String? c6RespondentsComment,
    String? c7Response,
    String? c7Comment,
    String? c7RespondentsComment,
    String? actionsAgreed,
  }) {
    return ServiceStandardsData(
      c2MainResponse: c2MainResponse ?? this.c2MainResponse,
      c2MainComment: c2MainComment ?? this.c2MainComment,
      c2RespondentsComment: c2RespondentsComment ?? this.c2RespondentsComment,
      c2BloodPressure: c2BloodPressure ?? this.c2BloodPressure,
      c2BloodPressureComment: c2BloodPressureComment ?? this.c2BloodPressureComment,
      c2BloodPressureEquipmentCalibrated: c2BloodPressureEquipmentCalibrated ?? this.c2BloodPressureEquipmentCalibrated,
      c2BloodPressureProtocolFollowed: c2BloodPressureProtocolFollowed ?? this.c2BloodPressureProtocolFollowed,
      c2BloodSugar: c2BloodSugar ?? this.c2BloodSugar,
      c2BloodSugarComment: c2BloodSugarComment ?? this.c2BloodSugarComment,
      c2BloodSugarStripsAvailable: c2BloodSugarStripsAvailable ?? this.c2BloodSugarStripsAvailable,
      c2BloodSugarQualityControl: c2BloodSugarQualityControl ?? this.c2BloodSugarQualityControl,
      c2BmiMeasurement: c2BmiMeasurement ?? this.c2BmiMeasurement,
      c2BmiMeasurementComment: c2BmiMeasurementComment ?? this.c2BmiMeasurementComment,
      c2BmiCalculationAccurate: c2BmiCalculationAccurate ?? this.c2BmiCalculationAccurate,
      c2WaistCircumference: c2WaistCircumference ?? this.c2WaistCircumference,
      c2WaistCircumferenceComment: c2WaistCircumferenceComment ?? this.c2WaistCircumferenceComment,
      c2WaistMeasurementTechniqueCorrect: c2WaistMeasurementTechniqueCorrect ?? this.c2WaistMeasurementTechniqueCorrect,
      c2CvdRiskEstimation: c2CvdRiskEstimation ?? this.c2CvdRiskEstimation,
      c2CvdRiskEstimationComment: c2CvdRiskEstimationComment ?? this.c2CvdRiskEstimationComment,
      c2CvdChartAvailableAndUsed: c2CvdChartAvailableAndUsed ?? this.c2CvdChartAvailableAndUsed,
      c2UrineProteinMeasurement: c2UrineProteinMeasurement ?? this.c2UrineProteinMeasurement,
      c2UrineProteinMeasurementComment: c2UrineProteinMeasurementComment ?? this.c2UrineProteinMeasurementComment,
      c2UrineProteinStripsNotExpired: c2UrineProteinStripsNotExpired ?? this.c2UrineProteinStripsNotExpired,
      c2PeakExpiratoryFlowRate: c2PeakExpiratoryFlowRate ?? this.c2PeakExpiratoryFlowRate,
      c2PeakExpiratoryFlowRateComment: c2PeakExpiratoryFlowRateComment ?? this.c2PeakExpiratoryFlowRateComment,
      c2PeakFlowMeterCalibrated: c2PeakFlowMeterCalibrated ?? this.c2PeakFlowMeterCalibrated,
      c2EgfrCalculation: c2EgfrCalculation ?? this.c2EgfrCalculation,
      c2EgfrCalculationComment: c2EgfrCalculationComment ?? this.c2EgfrCalculationComment,
      c2EgfrFormulaUsedCorrectly: c2EgfrFormulaUsedCorrectly ?? this.c2EgfrFormulaUsedCorrectly,
      c2BriefIntervention: c2BriefIntervention ?? this.c2BriefIntervention,
      c2BriefInterventionComment: c2BriefInterventionComment ?? this.c2BriefInterventionComment,
      c2FootExamination: c2FootExamination ?? this.c2FootExamination,
      c2FootExaminationComment: c2FootExaminationComment ?? this.c2FootExaminationComment,
      c2OralExamination: c2OralExamination ?? this.c2OralExamination,
      c2OralExaminationComment: c2OralExaminationComment ?? this.c2OralExaminationComment,
      c2EyeExamination: c2EyeExamination ?? this.c2EyeExamination,
      c2EyeExaminationComment: c2EyeExaminationComment ?? this.c2EyeExaminationComment,
      c2HealthEducation: c2HealthEducation ?? this.c2HealthEducation,
      c2HealthEducationComment: c2HealthEducationComment ?? this.c2HealthEducationComment,
      c3Response: c3Response ?? this.c3Response,
      c3Comment: c3Comment ?? this.c3Comment,
      c3RespondentsComment: c3RespondentsComment ?? this.c3RespondentsComment,
      c4Response: c4Response ?? this.c4Response,
      c4Comment: c4Comment ?? this.c4Comment,
      c4RespondentsComment: c4RespondentsComment ?? this.c4RespondentsComment,
      c5Response: c5Response ?? this.c5Response,
      c5Comment: c5Comment ?? this.c5Comment,
      c5RespondentsComment: c5RespondentsComment ?? this.c5RespondentsComment,
      c6Response: c6Response ?? this.c6Response,
      c6Comment: c6Comment ?? this.c6Comment,
      c6RespondentsComment: c6RespondentsComment ?? this.c6RespondentsComment,
      c7Response: c7Response ?? this.c7Response,
      c7Comment: c7Comment ?? this.c7Comment,
      c7RespondentsComment: c7RespondentsComment ?? this.c7RespondentsComment,
      actionsAgreed: actionsAgreed ?? this.actionsAgreed,
    );
  }
}