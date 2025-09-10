class HealthInformationData {
  // D1-D5 responses
  final String? d1Response;
  final String? d1Comment;
  final String? d1RespondentsComment;

  final String? d2Response;
  final String? d2Comment;
  final String? d2RespondentsComment;

  final String? d3Response;
  final String? d3Comment;
  final String? d3RespondentsComment;

  final String? d4Response;
  final String? d4Comment;
  final String? d4RespondentsComment;
  final int? d4NumberOfPeople;
  final bool? d4PreviousMonthData;

  final String? d5Response;
  final String? d5Comment;
  final String? d5RespondentsComment;

  final String? actionsAgreed;

  HealthInformationData({
    this.d1Response,
    this.d1Comment,
    this.d1RespondentsComment,
    this.d2Response,
    this.d2Comment,
    this.d2RespondentsComment,
    this.d3Response,
    this.d3Comment,
    this.d3RespondentsComment,
    this.d4Response,
    this.d4Comment,
    this.d4RespondentsComment,
    this.d4NumberOfPeople,
    this.d4PreviousMonthData,
    this.d5Response,
    this.d5Comment,
    this.d5RespondentsComment,
    this.actionsAgreed,
  });

  factory HealthInformationData.fromJson(Map<String, dynamic> json) {
    return HealthInformationData(
      d1Response: json['d1_response'] ?? json['d1Response'],
      d1Comment: json['d1_comment'] ?? json['d1Comment'],
      d1RespondentsComment: json['d1_respondents_comment'] ?? json['d1RespondentsComment'],
      d2Response: json['d2_response'] ?? json['d2Response'],
      d2Comment: json['d2_comment'] ?? json['d2Comment'],
      d2RespondentsComment: json['d2_respondents_comment'] ?? json['d2RespondentsComment'],
      d3Response: json['d3_response'] ?? json['d3Response'],
      d3Comment: json['d3_comment'] ?? json['d3Comment'],
      d3RespondentsComment: json['d3_respondents_comment'] ?? json['d3RespondentsComment'],
      d4Response: json['d4_response'] ?? json['d4Response'],
      d4Comment: json['d4_comment'] ?? json['d4Comment'],
      d4RespondentsComment: json['d4_respondents_comment'] ?? json['d4RespondentsComment'],
      d4NumberOfPeople: json['d4_number_of_people'] ?? json['d4NumberOfPeople'],
      d4PreviousMonthData: _parseBool(json['d4_previous_month_data'] ?? json['d4PreviousMonthData']),
      d5Response: json['d5_response'] ?? json['d5Response'],
      d5Comment: json['d5_comment'] ?? json['d5Comment'],
      d5RespondentsComment: json['d5_respondents_comment'] ?? json['d5RespondentsComment'],
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
      if (d1Response != null) 'd1_response': d1Response,
      if (d1Comment != null) 'd1_comment': d1Comment,
      if (d1RespondentsComment != null) 'd1_respondents_comment': d1RespondentsComment,
      if (d2Response != null) 'd2_response': d2Response,
      if (d2Comment != null) 'd2_comment': d2Comment,
      if (d2RespondentsComment != null) 'd2_respondents_comment': d2RespondentsComment,
      if (d3Response != null) 'd3_response': d3Response,
      if (d3Comment != null) 'd3_comment': d3Comment,
      if (d3RespondentsComment != null) 'd3_respondents_comment': d3RespondentsComment,
      if (d4Response != null) 'd4_response': d4Response,
      if (d4Comment != null) 'd4_comment': d4Comment,
      if (d4RespondentsComment != null) 'd4_respondents_comment': d4RespondentsComment,
      if (d4NumberOfPeople != null) 'd4_number_of_people': d4NumberOfPeople,
      if (d4PreviousMonthData != null) 'd4_previous_month_data': d4PreviousMonthData,
      if (d5Response != null) 'd5_response': d5Response,
      if (d5Comment != null) 'd5_comment': d5Comment,
      if (d5RespondentsComment != null) 'd5_respondents_comment': d5RespondentsComment,
      if (actionsAgreed != null) 'actions_agreed': actionsAgreed,
    };
  }

  Map<String, dynamic> toServerJson() {
    return {
      if (d1Response != null) 'd1_response': d1Response,
      if (d1Comment != null) 'd1_comment': d1Comment,
      if (d1RespondentsComment != null) 'd1_respondents_comment': d1RespondentsComment,
      if (d2Response != null) 'd2_response': d2Response,
      if (d2Comment != null) 'd2_comment': d2Comment,
      if (d2RespondentsComment != null) 'd2_respondents_comment': d2RespondentsComment,
      if (d3Response != null) 'd3_response': d3Response,
      if (d3Comment != null) 'd3_comment': d3Comment,
      if (d3RespondentsComment != null) 'd3_respondents_comment': d3RespondentsComment,
      if (d4Response != null) 'd4_response': d4Response,
      if (d4Comment != null) 'd4_comment': d4Comment,
      if (d4RespondentsComment != null) 'd4_respondents_comment': d4RespondentsComment,
      if (d4NumberOfPeople != null) 'd4_number_of_people': d4NumberOfPeople,
      if (d4PreviousMonthData != null) 'd4_previous_month_data': d4PreviousMonthData,
      if (d5Response != null) 'd5_response': d5Response,
      if (d5Comment != null) 'd5_comment': d5Comment,
      if (d5RespondentsComment != null) 'd5_respondents_comment': d5RespondentsComment,
      if (actionsAgreed != null) 'actions_agreed': actionsAgreed,
    };
  }

  HealthInformationData copyWith({
    String? d1Response,
    String? d1Comment,
    String? d1RespondentsComment,
    String? d2Response,
    String? d2Comment,
    String? d2RespondentsComment,
    String? d3Response,
    String? d3Comment,
    String? d3RespondentsComment,
    String? d4Response,
    String? d4Comment,
    String? d4RespondentsComment,
    int? d4NumberOfPeople,
    bool? d4PreviousMonthData,
    String? d5Response,
    String? d5Comment,
    String? d5RespondentsComment,
    String? actionsAgreed,
  }) {
    return HealthInformationData(
      d1Response: d1Response ?? this.d1Response,
      d1Comment: d1Comment ?? this.d1Comment,
      d1RespondentsComment: d1RespondentsComment ?? this.d1RespondentsComment,
      d2Response: d2Response ?? this.d2Response,
      d2Comment: d2Comment ?? this.d2Comment,
      d2RespondentsComment: d2RespondentsComment ?? this.d2RespondentsComment,
      d3Response: d3Response ?? this.d3Response,
      d3Comment: d3Comment ?? this.d3Comment,
      d3RespondentsComment: d3RespondentsComment ?? this.d3RespondentsComment,
      d4Response: d4Response ?? this.d4Response,
      d4Comment: d4Comment ?? this.d4Comment,
      d4RespondentsComment: d4RespondentsComment ?? this.d4RespondentsComment,
      d4NumberOfPeople: d4NumberOfPeople ?? this.d4NumberOfPeople,
      d4PreviousMonthData: d4PreviousMonthData ?? this.d4PreviousMonthData,
      d5Response: d5Response ?? this.d5Response,
      d5Comment: d5Comment ?? this.d5Comment,
      d5RespondentsComment: d5RespondentsComment ?? this.d5RespondentsComment,
      actionsAgreed: actionsAgreed ?? this.actionsAgreed,
    );
  }
}