class StaffTrainingData {
  // HA (Health Assistant) staff
  final int? haTotalStaff;
  final int? haMhdcTrained;
  final int? haFenTrained;
  final int? haOtherNcdTrained;

  // Sr. AHW (Senior Auxiliary Health Worker) staff
  final int? srAhwTotalStaff;
  final int? srAhwMhdcTrained;
  final int? srAhwFenTrained;
  final int? srAhwOtherNcdTrained;

  // AHW (Auxiliary Health Worker) staff
  final int? ahwTotalStaff;
  final int? ahwMhdcTrained;
  final int? ahwFenTrained;
  final int? ahwOtherNcdTrained;

  // Sr. ANM (Senior Auxiliary Nurse Midwife) staff
  final int? srAnmTotalStaff;
  final int? srAnmMhdcTrained;
  final int? srAnmFenTrained;
  final int? srAnmOtherNcdTrained;

  // ANM (Auxiliary Nurse Midwife) staff
  final int? anmTotalStaff;
  final int? anmMhdcTrained;
  final int? anmFenTrained;
  final int? anmOtherNcdTrained;

  // Others staff
  final int? othersTotalStaff;
  final int? othersMhdcTrained;
  final int? othersFenTrained;
  final int? othersOtherNcdTrained;

  // Training dates and verification
  final DateTime? lastMhdcTrainingDate;
  final DateTime? lastFenTrainingDate;
  final DateTime? lastOtherTrainingDate;
  final String? trainingProvider;
  final bool? trainingCertificatesVerified;

  StaffTrainingData({
    this.haTotalStaff,
    this.haMhdcTrained,
    this.haFenTrained,
    this.haOtherNcdTrained,
    this.srAhwTotalStaff,
    this.srAhwMhdcTrained,
    this.srAhwFenTrained,
    this.srAhwOtherNcdTrained,
    this.ahwTotalStaff,
    this.ahwMhdcTrained,
    this.ahwFenTrained,
    this.ahwOtherNcdTrained,
    this.srAnmTotalStaff,
    this.srAnmMhdcTrained,
    this.srAnmFenTrained,
    this.srAnmOtherNcdTrained,
    this.anmTotalStaff,
    this.anmMhdcTrained,
    this.anmFenTrained,
    this.anmOtherNcdTrained,
    this.othersTotalStaff,
    this.othersMhdcTrained,
    this.othersFenTrained,
    this.othersOtherNcdTrained,
    this.lastMhdcTrainingDate,
    this.lastFenTrainingDate,
    this.lastOtherTrainingDate,
    this.trainingProvider,
    this.trainingCertificatesVerified,
  });

  factory StaffTrainingData.fromJson(Map<String, dynamic> json) {
    return StaffTrainingData(
      haTotalStaff: json['ha_total_staff'] ?? json['haTotalStaff'],
      haMhdcTrained: json['ha_mhdc_trained'] ?? json['haMhdcTrained'],
      haFenTrained: json['ha_fen_trained'] ?? json['haFenTrained'],
      haOtherNcdTrained: json['ha_other_ncd_trained'] ?? json['haOtherNcdTrained'],
      srAhwTotalStaff: json['sr_ahw_total_staff'] ?? json['srAhwTotalStaff'],
      srAhwMhdcTrained: json['sr_ahw_mhdc_trained'] ?? json['srAhwMhdcTrained'],
      srAhwFenTrained: json['sr_ahw_fen_trained'] ?? json['srAhwFenTrained'],
      srAhwOtherNcdTrained: json['sr_ahw_other_ncd_trained'] ?? json['srAhwOtherNcdTrained'],
      ahwTotalStaff: json['ahw_total_staff'] ?? json['ahwTotalStaff'],
      ahwMhdcTrained: json['ahw_mhdc_trained'] ?? json['ahwMhdcTrained'],
      ahwFenTrained: json['ahw_fen_trained'] ?? json['ahwFenTrained'],
      ahwOtherNcdTrained: json['ahw_other_ncd_trained'] ?? json['ahwOtherNcdTrained'],
      srAnmTotalStaff: json['sr_anm_total_staff'] ?? json['srAnmTotalStaff'],
      srAnmMhdcTrained: json['sr_anm_mhdc_trained'] ?? json['srAnmMhdcTrained'],
      srAnmFenTrained: json['sr_anm_fen_trained'] ?? json['srAnmFenTrained'],
      srAnmOtherNcdTrained: json['sr_anm_other_ncd_trained'] ?? json['srAnmOtherNcdTrained'],
      anmTotalStaff: json['anm_total_staff'] ?? json['anmTotalStaff'],
      anmMhdcTrained: json['anm_mhdc_trained'] ?? json['anmMhdcTrained'],
      anmFenTrained: json['anm_fen_trained'] ?? json['anmFenTrained'],
      anmOtherNcdTrained: json['anm_other_ncd_trained'] ?? json['anmOtherNcdTrained'],
      othersTotalStaff: json['others_total_staff'] ?? json['othersTotalStaff'],
      othersMhdcTrained: json['others_mhdc_trained'] ?? json['othersMhdcTrained'],
      othersFenTrained: json['others_fen_trained'] ?? json['othersFenTrained'],
      othersOtherNcdTrained: json['others_other_ncd_trained'] ?? json['othersOtherNcdTrained'],
      lastMhdcTrainingDate: json['last_mhdc_training_date'] != null || json['lastMhdcTrainingDate'] != null
          ? DateTime.parse(json['last_mhdc_training_date'] ?? json['lastMhdcTrainingDate'])
          : null,
      lastFenTrainingDate: json['last_fen_training_date'] != null || json['lastFenTrainingDate'] != null
          ? DateTime.parse(json['last_fen_training_date'] ?? json['lastFenTrainingDate'])
          : null,
      lastOtherTrainingDate: json['last_other_training_date'] != null || json['lastOtherTrainingDate'] != null
          ? DateTime.parse(json['last_other_training_date'] ?? json['lastOtherTrainingDate'])
          : null,
      trainingProvider: json['training_provider'] ?? json['trainingProvider'],
      trainingCertificatesVerified: _parseBool(json['training_certificates_verified'] ?? json['trainingCertificatesVerified']),
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
      if (haTotalStaff != null) 'ha_total_staff': haTotalStaff,
      if (haMhdcTrained != null) 'ha_mhdc_trained': haMhdcTrained,
      if (haFenTrained != null) 'ha_fen_trained': haFenTrained,
      if (haOtherNcdTrained != null) 'ha_other_ncd_trained': haOtherNcdTrained,
      if (srAhwTotalStaff != null) 'sr_ahw_total_staff': srAhwTotalStaff,
      if (srAhwMhdcTrained != null) 'sr_ahw_mhdc_trained': srAhwMhdcTrained,
      if (srAhwFenTrained != null) 'sr_ahw_fen_trained': srAhwFenTrained,
      if (srAhwOtherNcdTrained != null) 'sr_ahw_other_ncd_trained': srAhwOtherNcdTrained,
      if (ahwTotalStaff != null) 'ahw_total_staff': ahwTotalStaff,
      if (ahwMhdcTrained != null) 'ahw_mhdc_trained': ahwMhdcTrained,
      if (ahwFenTrained != null) 'ahw_fen_trained': ahwFenTrained,
      if (ahwOtherNcdTrained != null) 'ahw_other_ncd_trained': ahwOtherNcdTrained,
      if (srAnmTotalStaff != null) 'sr_anm_total_staff': srAnmTotalStaff,
      if (srAnmMhdcTrained != null) 'sr_anm_mhdc_trained': srAnmMhdcTrained,
      if (srAnmFenTrained != null) 'sr_anm_fen_trained': srAnmFenTrained,
      if (srAnmOtherNcdTrained != null) 'sr_anm_other_ncd_trained': srAnmOtherNcdTrained,
      if (anmTotalStaff != null) 'anm_total_staff': anmTotalStaff,
      if (anmMhdcTrained != null) 'anm_mhdc_trained': anmMhdcTrained,
      if (anmFenTrained != null) 'anm_fen_trained': anmFenTrained,
      if (anmOtherNcdTrained != null) 'anm_other_ncd_trained': anmOtherNcdTrained,
      if (othersTotalStaff != null) 'others_total_staff': othersTotalStaff,
      if (othersMhdcTrained != null) 'others_mhdc_trained': othersMhdcTrained,
      if (othersFenTrained != null) 'others_fen_trained': othersFenTrained,
      if (othersOtherNcdTrained != null) 'others_other_ncd_trained': othersOtherNcdTrained,
      if (lastMhdcTrainingDate != null) 'last_mhdc_training_date': lastMhdcTrainingDate!.toIso8601String(),
      if (lastFenTrainingDate != null) 'last_fen_training_date': lastFenTrainingDate!.toIso8601String(),
      if (lastOtherTrainingDate != null) 'last_other_training_date': lastOtherTrainingDate!.toIso8601String(),
      if (trainingProvider != null) 'training_provider': trainingProvider,
      if (trainingCertificatesVerified != null) 'training_certificates_verified': trainingCertificatesVerified,
    };
  }

  Map<String, dynamic> toServerJson() {
    return {
      if (haTotalStaff != null) 'ha_total_staff': haTotalStaff,
      if (haMhdcTrained != null) 'ha_mhdc_trained': haMhdcTrained,
      if (haFenTrained != null) 'ha_fen_trained': haFenTrained,
      if (haOtherNcdTrained != null) 'ha_other_ncd_trained': haOtherNcdTrained,
      if (srAhwTotalStaff != null) 'sr_ahw_total_staff': srAhwTotalStaff,
      if (srAhwMhdcTrained != null) 'sr_ahw_mhdc_trained': srAhwMhdcTrained,
      if (srAhwFenTrained != null) 'sr_ahw_fen_trained': srAhwFenTrained,
      if (srAhwOtherNcdTrained != null) 'sr_ahw_other_ncd_trained': srAhwOtherNcdTrained,
      if (ahwTotalStaff != null) 'ahw_total_staff': ahwTotalStaff,
      if (ahwMhdcTrained != null) 'ahw_mhdc_trained': ahwMhdcTrained,
      if (ahwFenTrained != null) 'ahw_fen_trained': ahwFenTrained,
      if (ahwOtherNcdTrained != null) 'ahw_other_ncd_trained': ahwOtherNcdTrained,
      if (srAnmTotalStaff != null) 'sr_anm_total_staff': srAnmTotalStaff,
      if (srAnmMhdcTrained != null) 'sr_anm_mhdc_trained': srAnmMhdcTrained,
      if (srAnmFenTrained != null) 'sr_anm_fen_trained': srAnmFenTrained,
      if (srAnmOtherNcdTrained != null) 'sr_anm_other_ncd_trained': srAnmOtherNcdTrained,
      if (anmTotalStaff != null) 'anm_total_staff': anmTotalStaff,
      if (anmMhdcTrained != null) 'anm_mhdc_trained': anmMhdcTrained,
      if (anmFenTrained != null) 'anm_fen_trained': anmFenTrained,
      if (anmOtherNcdTrained != null) 'anm_other_ncd_trained': anmOtherNcdTrained,
      if (othersTotalStaff != null) 'others_total_staff': othersTotalStaff,
      if (othersMhdcTrained != null) 'others_mhdc_trained': othersMhdcTrained,
      if (othersFenTrained != null) 'others_fen_trained': othersFenTrained,
      if (othersOtherNcdTrained != null) 'others_other_ncd_trained': othersOtherNcdTrained,
      if (lastMhdcTrainingDate != null) 'last_mhdc_training_date': lastMhdcTrainingDate!.toIso8601String(),
      if (lastFenTrainingDate != null) 'last_fen_training_date': lastFenTrainingDate!.toIso8601String(),
      if (lastOtherTrainingDate != null) 'last_other_training_date': lastOtherTrainingDate!.toIso8601String(),
      if (trainingProvider != null) 'training_provider': trainingProvider,
      if (trainingCertificatesVerified != null) 'training_certificates_verified': trainingCertificatesVerified,
    };
  }

  StaffTrainingData copyWith({
    int? haTotalStaff,
    int? haMhdcTrained,
    int? haFenTrained,
    int? haOtherNcdTrained,
    int? srAhwTotalStaff,
    int? srAhwMhdcTrained,
    int? srAhwFenTrained,
    int? srAhwOtherNcdTrained,
    int? ahwTotalStaff,
    int? ahwMhdcTrained,
    int? ahwFenTrained,
    int? ahwOtherNcdTrained,
    int? srAnmTotalStaff,
    int? srAnmMhdcTrained,
    int? srAnmFenTrained,
    int? srAnmOtherNcdTrained,
    int? anmTotalStaff,
    int? anmMhdcTrained,
    int? anmFenTrained,
    int? anmOtherNcdTrained,
    int? othersTotalStaff,
    int? othersMhdcTrained,
    int? othersFenTrained,
    int? othersOtherNcdTrained,
    DateTime? lastMhdcTrainingDate,
    DateTime? lastFenTrainingDate,
    DateTime? lastOtherTrainingDate,
    String? trainingProvider,
    bool? trainingCertificatesVerified,
  }) {
    return StaffTrainingData(
      haTotalStaff: haTotalStaff ?? this.haTotalStaff,
      haMhdcTrained: haMhdcTrained ?? this.haMhdcTrained,
      haFenTrained: haFenTrained ?? this.haFenTrained,
      haOtherNcdTrained: haOtherNcdTrained ?? this.haOtherNcdTrained,
      srAhwTotalStaff: srAhwTotalStaff ?? this.srAhwTotalStaff,
      srAhwMhdcTrained: srAhwMhdcTrained ?? this.srAhwMhdcTrained,
      srAhwFenTrained: srAhwFenTrained ?? this.srAhwFenTrained,
      srAhwOtherNcdTrained: srAhwOtherNcdTrained ?? this.srAhwOtherNcdTrained,
      ahwTotalStaff: ahwTotalStaff ?? this.ahwTotalStaff,
      ahwMhdcTrained: ahwMhdcTrained ?? this.ahwMhdcTrained,
      ahwFenTrained: ahwFenTrained ?? this.ahwFenTrained,
      ahwOtherNcdTrained: ahwOtherNcdTrained ?? this.ahwOtherNcdTrained,
      srAnmTotalStaff: srAnmTotalStaff ?? this.srAnmTotalStaff,
      srAnmMhdcTrained: srAnmMhdcTrained ?? this.srAnmMhdcTrained,
      srAnmFenTrained: srAnmFenTrained ?? this.srAnmFenTrained,
      srAnmOtherNcdTrained: srAnmOtherNcdTrained ?? this.srAnmOtherNcdTrained,
      anmTotalStaff: anmTotalStaff ?? this.anmTotalStaff,
      anmMhdcTrained: anmMhdcTrained ?? this.anmMhdcTrained,
      anmFenTrained: anmFenTrained ?? this.anmFenTrained,
      anmOtherNcdTrained: anmOtherNcdTrained ?? this.anmOtherNcdTrained,
      othersTotalStaff: othersTotalStaff ?? this.othersTotalStaff,
      othersMhdcTrained: othersMhdcTrained ?? this.othersMhdcTrained,
      othersFenTrained: othersFenTrained ?? this.othersFenTrained,
      othersOtherNcdTrained: othersOtherNcdTrained ?? this.othersOtherNcdTrained,
      lastMhdcTrainingDate: lastMhdcTrainingDate ?? this.lastMhdcTrainingDate,
      lastFenTrainingDate: lastFenTrainingDate ?? this.lastFenTrainingDate,
      lastOtherTrainingDate: lastOtherTrainingDate ?? this.lastOtherTrainingDate,
      trainingProvider: trainingProvider ?? this.trainingProvider,
      trainingCertificatesVerified: trainingCertificatesVerified ?? this.trainingCertificatesVerified,
    );
  }
}