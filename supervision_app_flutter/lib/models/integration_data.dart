class IntegrationData {
  // E1-E3 responses
  final String? e1Response;
  final String? e1Comment;
  final String? e1RespondentsComment;

  final String? e2Response;
  final String? e2Comment;
  final String? e2RespondentsComment;

  final String? e3Response;
  final String? e3Comment;
  final String? e3RespondentsComment;

  final String? actionsAgreed;

  IntegrationData({
    this.e1Response,
    this.e1Comment,
    this.e1RespondentsComment,
    this.e2Response,
    this.e2Comment,
    this.e2RespondentsComment,
    this.e3Response,
    this.e3Comment,
    this.e3RespondentsComment,
    this.actionsAgreed,
  });

  factory IntegrationData.fromJson(Map<String, dynamic> json) {
    return IntegrationData(
      e1Response: json['e1_response'] ?? json['e1Response'],
      e1Comment: json['e1_comment'] ?? json['e1Comment'],
      e1RespondentsComment: json['e1_respondents_comment'] ?? json['e1RespondentsComment'],
      e2Response: json['e2_response'] ?? json['e2Response'],
      e2Comment: json['e2_comment'] ?? json['e2Comment'],
      e2RespondentsComment: json['e2_respondents_comment'] ?? json['e2RespondentsComment'],
      e3Response: json['e3_response'] ?? json['e3Response'],
      e3Comment: json['e3_comment'] ?? json['e3Comment'],
      e3RespondentsComment: json['e3_respondents_comment'] ?? json['e3RespondentsComment'],
      actionsAgreed: json['actions_agreed'] ?? json['actionsAgreed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (e1Response != null) 'e1_response': e1Response,
      if (e1Comment != null) 'e1_comment': e1Comment,
      if (e1RespondentsComment != null) 'e1_respondents_comment': e1RespondentsComment,
      if (e2Response != null) 'e2_response': e2Response,
      if (e2Comment != null) 'e2_comment': e2Comment,
      if (e2RespondentsComment != null) 'e2_respondents_comment': e2RespondentsComment,
      if (e3Response != null) 'e3_response': e3Response,
      if (e3Comment != null) 'e3_comment': e3Comment,
      if (e3RespondentsComment != null) 'e3_respondents_comment': e3RespondentsComment,
      if (actionsAgreed != null) 'actions_agreed': actionsAgreed,
    };
  }

  Map<String, dynamic> toServerJson() {
    return {
      if (e1Response != null) 'e1_response': e1Response,
      if (e1Comment != null) 'e1_comment': e1Comment,
      if (e1RespondentsComment != null) 'e1_respondents_comment': e1RespondentsComment,
      if (e2Response != null) 'e2_response': e2Response,
      if (e2Comment != null) 'e2_comment': e2Comment,
      if (e2RespondentsComment != null) 'e2_respondents_comment': e2RespondentsComment,
      if (e3Response != null) 'e3_response': e3Response,
      if (e3Comment != null) 'e3_comment': e3Comment,
      if (e3RespondentsComment != null) 'e3_respondents_comment': e3RespondentsComment,
      if (actionsAgreed != null) 'actions_agreed': actionsAgreed,
    };
  }

  IntegrationData copyWith({
    String? e1Response,
    String? e1Comment,
    String? e1RespondentsComment,
    String? e2Response,
    String? e2Comment,
    String? e2RespondentsComment,
    String? e3Response,
    String? e3Comment,
    String? e3RespondentsComment,
    String? actionsAgreed,
  }) {
    return IntegrationData(
      e1Response: e1Response ?? this.e1Response,
      e1Comment: e1Comment ?? this.e1Comment,
      e1RespondentsComment: e1RespondentsComment ?? this.e1RespondentsComment,
      e2Response: e2Response ?? this.e2Response,
      e2Comment: e2Comment ?? this.e2Comment,
      e2RespondentsComment: e2RespondentsComment ?? this.e2RespondentsComment,
      e3Response: e3Response ?? this.e3Response,
      e3Comment: e3Comment ?? this.e3Comment,
      e3RespondentsComment: e3RespondentsComment ?? this.e3RespondentsComment,
      actionsAgreed: actionsAgreed ?? this.actionsAgreed,
    );
  }
}