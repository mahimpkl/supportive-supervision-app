class PatientVolumes {
  final int? totalPatientsSeen;
  final int? ncdPatientsNew;
  final int? ncdPatientsFollowup;
  final int? diabetesPatients;
  final int? hypertensionPatients;
  final int? copdPatients;
  final int? cardiovascularPatients;
  final int? otherNcdPatients;
  final int? referralsMade;
  final int? referralsReceived;
  final int? emergencyCases;
  final DateTime? monthYear;
  final String? dataSource;
  final bool? dataVerified;

  PatientVolumes({
    this.totalPatientsSeen,
    this.ncdPatientsNew,
    this.ncdPatientsFollowup,
    this.diabetesPatients,
    this.hypertensionPatients,
    this.copdPatients,
    this.cardiovascularPatients,
    this.otherNcdPatients,
    this.referralsMade,
    this.referralsReceived,
    this.emergencyCases,
    this.monthYear,
    this.dataSource,
    this.dataVerified,
  });

  factory PatientVolumes.fromJson(Map<String, dynamic> json) {
    return PatientVolumes(
      totalPatientsSeen: json['total_patients_seen'] ?? json['totalPatientsSeen'],
      ncdPatientsNew: json['ncd_patients_new'] ?? json['ncdPatientsNew'],
      ncdPatientsFollowup: json['ncd_patients_followup'] ?? json['ncdPatientsFollowup'],
      diabetesPatients: json['diabetes_patients'] ?? json['diabetesPatients'],
      hypertensionPatients: json['hypertension_patients'] ?? json['hypertensionPatients'],
      copdPatients: json['copd_patients'] ?? json['copdPatients'],
      cardiovascularPatients: json['cardiovascular_patients'] ?? json['cardiovascularPatients'],
      otherNcdPatients: json['other_ncd_patients'] ?? json['otherNcdPatients'],
      referralsMade: json['referrals_made'] ?? json['referralsMade'],
      referralsReceived: json['referrals_received'] ?? json['referralsReceived'],
      emergencyCases: json['emergency_cases'] ?? json['emergencyCases'],
      monthYear: json['month_year'] != null || json['monthYear'] != null
          ? DateTime.parse(json['month_year'] ?? json['monthYear'])
          : null,
      dataSource: json['data_source'] ?? json['dataSource'],
      dataVerified: json['data_verified'] ?? json['dataVerified'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (totalPatientsSeen != null) 'total_patients_seen': totalPatientsSeen,
      if (ncdPatientsNew != null) 'ncd_patients_new': ncdPatientsNew,
      if (ncdPatientsFollowup != null) 'ncd_patients_followup': ncdPatientsFollowup,
      if (diabetesPatients != null) 'diabetes_patients': diabetesPatients,
      if (hypertensionPatients != null) 'hypertension_patients': hypertensionPatients,
      if (copdPatients != null) 'copd_patients': copdPatients,
      if (cardiovascularPatients != null) 'cardiovascular_patients': cardiovascularPatients,
      if (otherNcdPatients != null) 'other_ncd_patients': otherNcdPatients,
      if (referralsMade != null) 'referrals_made': referralsMade,
      if (referralsReceived != null) 'referrals_received': referralsReceived,
      if (emergencyCases != null) 'emergency_cases': emergencyCases,
      if (monthYear != null) 'month_year': monthYear!.toIso8601String(),
      if (dataSource != null) 'data_source': dataSource,
      if (dataVerified != null) 'data_verified': dataVerified,
    };
  }

  Map<String, dynamic> toServerJson() {
    return {
      if (totalPatientsSeen != null) 'total_patients_seen': totalPatientsSeen,
      if (ncdPatientsNew != null) 'ncd_patients_new': ncdPatientsNew,
      if (ncdPatientsFollowup != null) 'ncd_patients_followup': ncdPatientsFollowup,
      if (diabetesPatients != null) 'diabetes_patients': diabetesPatients,
      if (hypertensionPatients != null) 'hypertension_patients': hypertensionPatients,
      if (copdPatients != null) 'copd_patients': copdPatients,
      if (cardiovascularPatients != null) 'cardiovascular_patients': cardiovascularPatients,
      if (otherNcdPatients != null) 'other_ncd_patients': otherNcdPatients,
      if (referralsMade != null) 'referrals_made': referralsMade,
      if (referralsReceived != null) 'referrals_received': referralsReceived,
      if (emergencyCases != null) 'emergency_cases': emergencyCases,
      if (monthYear != null) 'month_year': monthYear!.toIso8601String(),
      if (dataSource != null) 'data_source': dataSource,
      if (dataVerified != null) 'data_verified': dataVerified,
    };
  }

  PatientVolumes copyWith({
    int? totalPatientsSeen,
    int? ncdPatientsNew,
    int? ncdPatientsFollowup,
    int? diabetesPatients,
    int? hypertensionPatients,
    int? copdPatients,
    int? cardiovascularPatients,
    int? otherNcdPatients,
    int? referralsMade,
    int? referralsReceived,
    int? emergencyCases,
    DateTime? monthYear,
    String? dataSource,
    bool? dataVerified,
  }) {
    return PatientVolumes(
      totalPatientsSeen: totalPatientsSeen ?? this.totalPatientsSeen,
      ncdPatientsNew: ncdPatientsNew ?? this.ncdPatientsNew,
      ncdPatientsFollowup: ncdPatientsFollowup ?? this.ncdPatientsFollowup,
      diabetesPatients: diabetesPatients ?? this.diabetesPatients,
      hypertensionPatients: hypertensionPatients ?? this.hypertensionPatients,
      copdPatients: copdPatients ?? this.copdPatients,
      cardiovascularPatients: cardiovascularPatients ?? this.cardiovascularPatients,
      otherNcdPatients: otherNcdPatients ?? this.otherNcdPatients,
      referralsMade: referralsMade ?? this.referralsMade,
      referralsReceived: referralsReceived ?? this.referralsReceived,
      emergencyCases: emergencyCases ?? this.emergencyCases,
      monthYear: monthYear ?? this.monthYear,
      dataSource: dataSource ?? this.dataSource,
      dataVerified: dataVerified ?? this.dataVerified,
    );
  }
}