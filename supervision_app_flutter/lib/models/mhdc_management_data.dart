class MhdcManagementData {
  // B6-B10 responses
  final String? b6Response;
  final String? b6Comment;
  final String? b6RespondentsComment;
  final bool? b6HealthcareWorkersReferEasily;
  final bool? b6KeptInOpdUse;

  final String? b7Response;
  final String? b7Comment;
  final String? b7RespondentsComment;
  final bool? b7AvailableAtHealthCenter;

  final String? b8Response;
  final String? b8Comment;
  final String? b8RespondentsComment;
  final bool? b8AvailableAndFilledProperly;

  final String? b9Response;
  final String? b9Comment;
  final String? b9RespondentsComment;
  final bool? b9AvailableForPatientCare;
  final String? b9ChartVersion;
  final String? b9ChartCondition;

  final String? b10Response;
  final String? b10Comment;
  final String? b10RespondentsComment;
  final bool? b10InUseForPatientCare;
  final bool? b10StaffTrainedOnChart;
  final int? b10ChartsCompletedDuringVisit;
  final bool? b10RiskStratificationAccurate;

  final String? actionsAgreed;

  MhdcManagementData({
    this.b6Response,
    this.b6Comment,
    this.b6RespondentsComment,
    this.b6HealthcareWorkersReferEasily,
    this.b6KeptInOpdUse,
    this.b7Response,
    this.b7Comment,
    this.b7RespondentsComment,
    this.b7AvailableAtHealthCenter,
    this.b8Response,
    this.b8Comment,
    this.b8RespondentsComment,
    this.b8AvailableAndFilledProperly,
    this.b9Response,
    this.b9Comment,
    this.b9RespondentsComment,
    this.b9AvailableForPatientCare,
    this.b9ChartVersion,
    this.b9ChartCondition,
    this.b10Response,
    this.b10Comment,
    this.b10RespondentsComment,
    this.b10InUseForPatientCare,
    this.b10StaffTrainedOnChart,
    this.b10ChartsCompletedDuringVisit,
    this.b10RiskStratificationAccurate,
    this.actionsAgreed,
  });

  factory MhdcManagementData.fromJson(Map<String, dynamic> json) {
    return MhdcManagementData(
      b6Response: json['b6_response'] ?? json['b6Response'],
      b6Comment: json['b6_comment'] ?? json['b6Comment'],
      b6RespondentsComment: json['b6_respondents_comment'] ?? json['b6RespondentsComment'],
      b6HealthcareWorkersReferEasily: _parseBool(json['b6_healthcare_workers_refer_easily'] ?? json['b6HealthcareWorkersReferEasily']),
      b6KeptInOpdUse: _parseBool(json['b6_kept_in_opd_use'] ?? json['b6KeptInOpdUse']),
      b7Response: json['b7_response'] ?? json['b7Response'],
      b7Comment: json['b7_comment'] ?? json['b7Comment'],
      b7RespondentsComment: json['b7_respondents_comment'] ?? json['b7RespondentsComment'],
      b7AvailableAtHealthCenter: _parseBool(json['b7_available_at_health_center'] ?? json['b7AvailableAtHealthCenter']),
      b8Response: json['b8_response'] ?? json['b8Response'],
      b8Comment: json['b8_comment'] ?? json['b8Comment'],
      b8RespondentsComment: json['b8_respondents_comment'] ?? json['b8RespondentsComment'],
      b8AvailableAndFilledProperly: _parseBool(json['b8_available_and_filled_properly'] ?? json['b8AvailableAndFilledProperly']),
      b9Response: json['b9_response'] ?? json['b9Response'],
      b9Comment: json['b9_comment'] ?? json['b9Comment'],
      b9RespondentsComment: json['b9_respondents_comment'] ?? json['b9RespondentsComment'],
      b9AvailableForPatientCare: _parseBool(json['b9_available_for_patient_care'] ?? json['b9AvailableForPatientCare']),
      b9ChartVersion: json['b9_chart_version'] ?? json['b9ChartVersion'],
      b9ChartCondition: json['b9_chart_condition'] ?? json['b9ChartCondition'],
      b10Response: json['b10_response'] ?? json['b10Response'],
      b10Comment: json['b10_comment'] ?? json['b10Comment'],
      b10RespondentsComment: json['b10_respondents_comment'] ?? json['b10RespondentsComment'],
      b10InUseForPatientCare: _parseBool(json['b10_in_use_for_patient_care'] ?? json['b10InUseForPatientCare']),
      b10StaffTrainedOnChart: _parseBool(json['b10_staff_trained_on_chart'] ?? json['b10StaffTrainedOnChart']),
      b10ChartsCompletedDuringVisit: json['b10_charts_completed_during_visit'] ?? json['b10ChartsCompletedDuringVisit'],
      b10RiskStratificationAccurate: _parseBool(json['b10_risk_stratification_accurate'] ?? json['b10RiskStratificationAccurate']),
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
      if (b6Response != null) 'b6_response': b6Response,
      if (b6Comment != null) 'b6_comment': b6Comment,
      if (b6RespondentsComment != null) 'b6_respondents_comment': b6RespondentsComment,
      if (b6HealthcareWorkersReferEasily != null) 'b6_healthcare_workers_refer_easily': b6HealthcareWorkersReferEasily,
      if (b6KeptInOpdUse != null) 'b6_kept_in_opd_use': b6KeptInOpdUse,
      if (b7Response != null) 'b7_response': b7Response,
      if (b7Comment != null) 'b7_comment': b7Comment,
      if (b7RespondentsComment != null) 'b7_respondents_comment': b7RespondentsComment,
      if (b7AvailableAtHealthCenter != null) 'b7_available_at_health_center': b7AvailableAtHealthCenter,
      if (b8Response != null) 'b8_response': b8Response,
      if (b8Comment != null) 'b8_comment': b8Comment,
      if (b8RespondentsComment != null) 'b8_respondents_comment': b8RespondentsComment,
      if (b8AvailableAndFilledProperly != null) 'b8_available_and_filled_properly': b8AvailableAndFilledProperly,
      if (b9Response != null) 'b9_response': b9Response,
      if (b9Comment != null) 'b9_comment': b9Comment,
      if (b9RespondentsComment != null) 'b9_respondents_comment': b9RespondentsComment,
      if (b9AvailableForPatientCare != null) 'b9_available_for_patient_care': b9AvailableForPatientCare,
      if (b9ChartVersion != null) 'b9_chart_version': b9ChartVersion,
      if (b9ChartCondition != null) 'b9_chart_condition': b9ChartCondition,
      if (b10Response != null) 'b10_response': b10Response,
      if (b10Comment != null) 'b10_comment': b10Comment,
      if (b10RespondentsComment != null) 'b10_respondents_comment': b10RespondentsComment,
      if (b10InUseForPatientCare != null) 'b10_in_use_for_patient_care': b10InUseForPatientCare,
      if (b10StaffTrainedOnChart != null) 'b10_staff_trained_on_chart': b10StaffTrainedOnChart,
      if (b10ChartsCompletedDuringVisit != null) 'b10_charts_completed_during_visit': b10ChartsCompletedDuringVisit,
      if (b10RiskStratificationAccurate != null) 'b10_risk_stratification_accurate': b10RiskStratificationAccurate,
      if (actionsAgreed != null) 'actions_agreed': actionsAgreed,
    };
  }

  Map<String, dynamic> toServerJson() {
    return {
      if (b6Response != null) 'b6_response': b6Response,
      if (b6Comment != null) 'b6_comment': b6Comment,
      if (b6RespondentsComment != null) 'b6_respondents_comment': b6RespondentsComment,
      if (b6HealthcareWorkersReferEasily != null) 'b6_healthcare_workers_refer_easily': b6HealthcareWorkersReferEasily,
      if (b6KeptInOpdUse != null) 'b6_kept_in_opd_use': b6KeptInOpdUse,
      if (b7Response != null) 'b7_response': b7Response,
      if (b7Comment != null) 'b7_comment': b7Comment,
      if (b7RespondentsComment != null) 'b7_respondents_comment': b7RespondentsComment,
      if (b7AvailableAtHealthCenter != null) 'b7_available_at_health_center': b7AvailableAtHealthCenter,
      if (b8Response != null) 'b8_response': b8Response,
      if (b8Comment != null) 'b8_comment': b8Comment,
      if (b8RespondentsComment != null) 'b8_respondents_comment': b8RespondentsComment,
      if (b8AvailableAndFilledProperly != null) 'b8_available_and_filled_properly': b8AvailableAndFilledProperly,
      if (b9Response != null) 'b9_response': b9Response,
      if (b9Comment != null) 'b9_comment': b9Comment,
      if (b9RespondentsComment != null) 'b9_respondents_comment': b9RespondentsComment,
      if (b9AvailableForPatientCare != null) 'b9_available_for_patient_care': b9AvailableForPatientCare,
      if (b9ChartVersion != null) 'b9_chart_version': b9ChartVersion,
      if (b9ChartCondition != null) 'b9_chart_condition': b9ChartCondition,
      if (b10Response != null) 'b10_response': b10Response,
      if (b10Comment != null) 'b10_comment': b10Comment,
      if (b10RespondentsComment != null) 'b10_respondents_comment': b10RespondentsComment,
      if (b10InUseForPatientCare != null) 'b10_in_use_for_patient_care': b10InUseForPatientCare,
      if (b10StaffTrainedOnChart != null) 'b10_staff_trained_on_chart': b10StaffTrainedOnChart,
      if (b10ChartsCompletedDuringVisit != null) 'b10_charts_completed_during_visit': b10ChartsCompletedDuringVisit,
      if (b10RiskStratificationAccurate != null) 'b10_risk_stratification_accurate': b10RiskStratificationAccurate,
      if (actionsAgreed != null) 'actions_agreed': actionsAgreed,
    };
  }

  MhdcManagementData copyWith({
    String? b6Response,
    String? b6Comment,
    String? b6RespondentsComment,
    bool? b6HealthcareWorkersReferEasily,
    bool? b6KeptInOpdUse,
    String? b7Response,
    String? b7Comment,
    String? b7RespondentsComment,
    bool? b7AvailableAtHealthCenter,
    String? b8Response,
    String? b8Comment,
    String? b8RespondentsComment,
    bool? b8AvailableAndFilledProperly,
    String? b9Response,
    String? b9Comment,
    String? b9RespondentsComment,
    bool? b9AvailableForPatientCare,
    String? b9ChartVersion,
    String? b9ChartCondition,
    String? b10Response,
    String? b10Comment,
    String? b10RespondentsComment,
    bool? b10InUseForPatientCare,
    bool? b10StaffTrainedOnChart,
    int? b10ChartsCompletedDuringVisit,
    bool? b10RiskStratificationAccurate,
    String? actionsAgreed,
  }) {
    return MhdcManagementData(
      b6Response: b6Response ?? this.b6Response,
      b6Comment: b6Comment ?? this.b6Comment,
      b6RespondentsComment: b6RespondentsComment ?? this.b6RespondentsComment,
      b6HealthcareWorkersReferEasily: b6HealthcareWorkersReferEasily ?? this.b6HealthcareWorkersReferEasily,
      b6KeptInOpdUse: b6KeptInOpdUse ?? this.b6KeptInOpdUse,
      b7Response: b7Response ?? this.b7Response,
      b7Comment: b7Comment ?? this.b7Comment,
      b7RespondentsComment: b7RespondentsComment ?? this.b7RespondentsComment,
      b7AvailableAtHealthCenter: b7AvailableAtHealthCenter ?? this.b7AvailableAtHealthCenter,
      b8Response: b8Response ?? this.b8Response,
      b8Comment: b8Comment ?? this.b8Comment,
      b8RespondentsComment: b8RespondentsComment ?? this.b8RespondentsComment,
      b8AvailableAndFilledProperly: b8AvailableAndFilledProperly ?? this.b8AvailableAndFilledProperly,
      b9Response: b9Response ?? this.b9Response,
      b9Comment: b9Comment ?? this.b9Comment,
      b9RespondentsComment: b9RespondentsComment ?? this.b9RespondentsComment,
      b9AvailableForPatientCare: b9AvailableForPatientCare ?? this.b9AvailableForPatientCare,
      b9ChartVersion: b9ChartVersion ?? this.b9ChartVersion,
      b9ChartCondition: b9ChartCondition ?? this.b9ChartCondition,
      b10Response: b10Response ?? this.b10Response,
      b10Comment: b10Comment ?? this.b10Comment,
      b10RespondentsComment: b10RespondentsComment ?? this.b10RespondentsComment,
      b10InUseForPatientCare: b10InUseForPatientCare ?? this.b10InUseForPatientCare,
      b10StaffTrainedOnChart: b10StaffTrainedOnChart ?? this.b10StaffTrainedOnChart,
      b10ChartsCompletedDuringVisit: b10ChartsCompletedDuringVisit ?? this.b10ChartsCompletedDuringVisit,
      b10RiskStratificationAccurate: b10RiskStratificationAccurate ?? this.b10RiskStratificationAccurate,
      actionsAgreed: actionsAgreed ?? this.actionsAgreed,
    );
  }
}