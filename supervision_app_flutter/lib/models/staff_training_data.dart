class StaffTrainingData {
  // HA (Health Assistant) staff
  final int? haTotalStaff;
  final int? haKhdcTrained;
  final int? haFenTrained;
  final int? haOtherNcdTrained;

  // Sr. AHW (Senior Auxiliary Health Worker) staff
  final int? srAhwTotalStaff;
  final int? srAhwKhdcTrained;
  final int? srAhwFenTrained;
  final int? srAhwOtherNcdTrained;

  // AHW (Auxiliary Health Worker) staff
  final int? ahwTotalStaff;
  final int? ahwKhdcTrained;
  final int? ahwFenTrained;
  final int? ahwOtherNcdTrained;

  // Sr. ANM (Senior Auxiliary Nurse Midwife) staff
  final int? srAnmTotalStaff;
  final int? srAnmKhdcTrained;
  final int? srAnmFenTrained;
  final int? srAnmOtherNcdTrained;

  // ANM (Auxiliary Nurse Midwife) staff
  final int? anmTotalStaff;
  final int? anmKhdcTrained;
  final int? anmFenTrained;
  final int? anmOtherNcdTrained;

  // Others staff
  final int? othersTotalStaff;
  final int? othersKhdcTrained;
  final int? othersFenTrained;
  final int? othersOtherNcdTrained;


  StaffTrainingData({
    this.haTotalStaff,
    this.haKhdcTrained,
    this.haFenTrained,
    this.haOtherNcdTrained,
    this.srAhwTotalStaff,
    this.srAhwKhdcTrained,
    this.srAhwFenTrained,
    this.srAhwOtherNcdTrained,
    this.ahwTotalStaff,
    this.ahwKhdcTrained,
    this.ahwFenTrained,
    this.ahwOtherNcdTrained,
    this.srAnmTotalStaff,
    this.srAnmKhdcTrained,
    this.srAnmFenTrained,
    this.srAnmOtherNcdTrained,
    this.anmTotalStaff,
    this.anmKhdcTrained,
    this.anmFenTrained,
    this.anmOtherNcdTrained,
    this.othersTotalStaff,
    this.othersKhdcTrained,
    this.othersFenTrained,
    this.othersOtherNcdTrained,
  });

  factory StaffTrainingData.fromJson(Map<String, dynamic> json) {
    return StaffTrainingData(
      haTotalStaff: json['ha_total_staff'] ?? json['haTotalStaff'],
      haKhdcTrained: json['ha_Khdc_trained'] ?? json['haKhdcTrained'],
      haFenTrained: json['ha_fen_trained'] ?? json['haFenTrained'],
      haOtherNcdTrained: json['ha_other_ncd_trained'] ?? json['haOtherNcdTrained'],
      srAhwTotalStaff: json['sr_ahw_total_staff'] ?? json['srAhwTotalStaff'],
      srAhwKhdcTrained: json['sr_ahw_Khdc_trained'] ?? json['srAhwKhdcTrained'],
      srAhwFenTrained: json['sr_ahw_fen_trained'] ?? json['srAhwFenTrained'],
      srAhwOtherNcdTrained: json['sr_ahw_other_ncd_trained'] ?? json['srAhwOtherNcdTrained'],
      ahwTotalStaff: json['ahw_total_staff'] ?? json['ahwTotalStaff'],
      ahwKhdcTrained: json['ahw_Khdc_trained'] ?? json['ahwKhdcTrained'],
      ahwFenTrained: json['ahw_fen_trained'] ?? json['ahwFenTrained'],
      ahwOtherNcdTrained: json['ahw_other_ncd_trained'] ?? json['ahwOtherNcdTrained'],
      srAnmTotalStaff: json['sr_anm_total_staff'] ?? json['srAnmTotalStaff'],
      srAnmKhdcTrained: json['sr_anm_Khdc_trained'] ?? json['srAnmKhdcTrained'],
      srAnmFenTrained: json['sr_anm_fen_trained'] ?? json['srAnmFenTrained'],
      srAnmOtherNcdTrained: json['sr_anm_other_ncd_trained'] ?? json['srAnmOtherNcdTrained'],
      anmTotalStaff: json['anm_total_staff'] ?? json['anmTotalStaff'],
      anmKhdcTrained: json['anm_Khdc_trained'] ?? json['anmKhdcTrained'],
      anmFenTrained: json['anm_fen_trained'] ?? json['anmFenTrained'],
      anmOtherNcdTrained: json['anm_other_ncd_trained'] ?? json['anmOtherNcdTrained'],
      othersTotalStaff: json['others_total_staff'] ?? json['othersTotalStaff'],
      othersKhdcTrained: json['others_Khdc_trained'] ?? json['othersKhdcTrained'],
      othersFenTrained: json['others_fen_trained'] ?? json['othersFenTrained'],
      othersOtherNcdTrained: json['others_other_ncd_trained'] ?? json['othersOtherNcdTrained'],
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
      if (haKhdcTrained != null) 'ha_Khdc_trained': haKhdcTrained,
      if (haFenTrained != null) 'ha_fen_trained': haFenTrained,
      if (haOtherNcdTrained != null) 'ha_other_ncd_trained': haOtherNcdTrained,
      if (srAhwTotalStaff != null) 'sr_ahw_total_staff': srAhwTotalStaff,
      if (srAhwKhdcTrained != null) 'sr_ahw_Khdc_trained': srAhwKhdcTrained,
      if (srAhwFenTrained != null) 'sr_ahw_fen_trained': srAhwFenTrained,
      if (srAhwOtherNcdTrained != null) 'sr_ahw_other_ncd_trained': srAhwOtherNcdTrained,
      if (ahwTotalStaff != null) 'ahw_total_staff': ahwTotalStaff,
      if (ahwKhdcTrained != null) 'ahw_Khdc_trained': ahwKhdcTrained,
      if (ahwFenTrained != null) 'ahw_fen_trained': ahwFenTrained,
      if (ahwOtherNcdTrained != null) 'ahw_other_ncd_trained': ahwOtherNcdTrained,
      if (srAnmTotalStaff != null) 'sr_anm_total_staff': srAnmTotalStaff,
      if (srAnmKhdcTrained != null) 'sr_anm_Khdc_trained': srAnmKhdcTrained,
      if (srAnmFenTrained != null) 'sr_anm_fen_trained': srAnmFenTrained,
      if (srAnmOtherNcdTrained != null) 'sr_anm_other_ncd_trained': srAnmOtherNcdTrained,
      if (anmTotalStaff != null) 'anm_total_staff': anmTotalStaff,
      if (anmKhdcTrained != null) 'anm_Khdc_trained': anmKhdcTrained,
      if (anmFenTrained != null) 'anm_fen_trained': anmFenTrained,
      if (anmOtherNcdTrained != null) 'anm_other_ncd_trained': anmOtherNcdTrained,
      if (othersTotalStaff != null) 'others_total_staff': othersTotalStaff,
      if (othersKhdcTrained != null) 'others_Khdc_trained': othersKhdcTrained,
      if (othersFenTrained != null) 'others_fen_trained': othersFenTrained,
      if (othersOtherNcdTrained != null) 'others_other_ncd_trained': othersOtherNcdTrained,
    };
  }

  Map<String, dynamic> toServerJson() {
    return {
      if (haTotalStaff != null) 'ha_total_staff': haTotalStaff,
      if (haKhdcTrained != null) 'ha_Khdc_trained': haKhdcTrained,
      if (haFenTrained != null) 'ha_fen_trained': haFenTrained,
      if (haOtherNcdTrained != null) 'ha_other_ncd_trained': haOtherNcdTrained,
      if (srAhwTotalStaff != null) 'sr_ahw_total_staff': srAhwTotalStaff,
      if (srAhwKhdcTrained != null) 'sr_ahw_Khdc_trained': srAhwKhdcTrained,
      if (srAhwFenTrained != null) 'sr_ahw_fen_trained': srAhwFenTrained,
      if (srAhwOtherNcdTrained != null) 'sr_ahw_other_ncd_trained': srAhwOtherNcdTrained,
      if (ahwTotalStaff != null) 'ahw_total_staff': ahwTotalStaff,
      if (ahwKhdcTrained != null) 'ahw_Khdc_trained': ahwKhdcTrained,
      if (ahwFenTrained != null) 'ahw_fen_trained': ahwFenTrained,
      if (ahwOtherNcdTrained != null) 'ahw_other_ncd_trained': ahwOtherNcdTrained,
      if (srAnmTotalStaff != null) 'sr_anm_total_staff': srAnmTotalStaff,
      if (srAnmKhdcTrained != null) 'sr_anm_Khdc_trained': srAnmKhdcTrained,
      if (srAnmFenTrained != null) 'sr_anm_fen_trained': srAnmFenTrained,
      if (srAnmOtherNcdTrained != null) 'sr_anm_other_ncd_trained': srAnmOtherNcdTrained,
      if (anmTotalStaff != null) 'anm_total_staff': anmTotalStaff,
      if (anmKhdcTrained != null) 'anm_Khdc_trained': anmKhdcTrained,
      if (anmFenTrained != null) 'anm_fen_trained': anmFenTrained,
      if (anmOtherNcdTrained != null) 'anm_other_ncd_trained': anmOtherNcdTrained,
      if (othersTotalStaff != null) 'others_total_staff': othersTotalStaff,
      if (othersKhdcTrained != null) 'others_Khdc_trained': othersKhdcTrained,
      if (othersFenTrained != null) 'others_fen_trained': othersFenTrained,
      if (othersOtherNcdTrained != null) 'others_other_ncd_trained': othersOtherNcdTrained,
    };
  }

  StaffTrainingData copyWith({
    int? haTotalStaff,
    int? haKhdcTrained,
    int? haFenTrained,
    int? haOtherNcdTrained,
    int? srAhwTotalStaff,
    int? srAhwKhdcTrained,
    int? srAhwFenTrained,
    int? srAhwOtherNcdTrained,
    int? ahwTotalStaff,
    int? ahwKhdcTrained,
    int? ahwFenTrained,
    int? ahwOtherNcdTrained,
    int? srAnmTotalStaff,
    int? srAnmKhdcTrained,
    int? srAnmFenTrained,
    int? srAnmOtherNcdTrained,
    int? anmTotalStaff,
    int? anmKhdcTrained,
    int? anmFenTrained,
    int? anmOtherNcdTrained,
    int? othersTotalStaff,
    int? othersKhdcTrained,
    int? othersFenTrained,
    int? othersOtherNcdTrained,
    DateTime? lastKhdcTrainingDate,
    DateTime? lastFenTrainingDate,
    DateTime? lastOtherTrainingDate,
    String? trainingProvider,
    bool? trainingCertificatesVerified,
  }) {
    return StaffTrainingData(
      haTotalStaff: haTotalStaff ?? this.haTotalStaff,
      haKhdcTrained: haKhdcTrained ?? this.haKhdcTrained,
      haFenTrained: haFenTrained ?? this.haFenTrained,
      haOtherNcdTrained: haOtherNcdTrained ?? this.haOtherNcdTrained,
      srAhwTotalStaff: srAhwTotalStaff ?? this.srAhwTotalStaff,
      srAhwKhdcTrained: srAhwKhdcTrained ?? this.srAhwKhdcTrained,
      srAhwFenTrained: srAhwFenTrained ?? this.srAhwFenTrained,
      srAhwOtherNcdTrained: srAhwOtherNcdTrained ?? this.srAhwOtherNcdTrained,
      ahwTotalStaff: ahwTotalStaff ?? this.ahwTotalStaff,
      ahwKhdcTrained: ahwKhdcTrained ?? this.ahwKhdcTrained,
      ahwFenTrained: ahwFenTrained ?? this.ahwFenTrained,
      ahwOtherNcdTrained: ahwOtherNcdTrained ?? this.ahwOtherNcdTrained,
      srAnmTotalStaff: srAnmTotalStaff ?? this.srAnmTotalStaff,
      srAnmKhdcTrained: srAnmKhdcTrained ?? this.srAnmKhdcTrained,
      srAnmFenTrained: srAnmFenTrained ?? this.srAnmFenTrained,
      srAnmOtherNcdTrained: srAnmOtherNcdTrained ?? this.srAnmOtherNcdTrained,
      anmTotalStaff: anmTotalStaff ?? this.anmTotalStaff,
      anmKhdcTrained: anmKhdcTrained ?? this.anmKhdcTrained,
      anmFenTrained: anmFenTrained ?? this.anmFenTrained,
      anmOtherNcdTrained: anmOtherNcdTrained ?? this.anmOtherNcdTrained,
      othersTotalStaff: othersTotalStaff ?? this.othersTotalStaff,
      othersKhdcTrained: othersKhdcTrained ?? this.othersKhdcTrained,
      othersFenTrained: othersFenTrained ?? this.othersFenTrained,
      othersOtherNcdTrained: othersOtherNcdTrained ?? this.othersOtherNcdTrained,
    );
  }
}