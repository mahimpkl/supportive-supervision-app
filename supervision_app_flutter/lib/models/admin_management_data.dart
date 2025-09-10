class AdminManagementData {
  final String? a1Response;
  final String? a1Comment;
  final String? a1RespondentsComment;
  final String? a2Response;
  final String? a2Comment;
  final String? a2RespondentsComment;
  final String? a3Response;
  final String? a3Comment;
  final String? a3RespondentsComment;
  final String? actionsAgreed;

  AdminManagementData({
    this.a1Response,
    this.a1Comment,
    this.a1RespondentsComment,
    this.a2Response,
    this.a2Comment,
    this.a2RespondentsComment,
    this.a3Response,
    this.a3Comment,
    this.a3RespondentsComment,
    this.actionsAgreed,
  });

  factory AdminManagementData.fromJson(Map<String, dynamic> json) {
    return AdminManagementData(
      a1Response: json['a1_response'],
      a1Comment: json['a1_comment'],
      a1RespondentsComment: json['a1_respondents_comment'],
      a2Response: json['a2_response'],
      a2Comment: json['a2_comment'],
      a2RespondentsComment: json['a2_respondents_comment'],
      a3Response: json['a3_response'],
      a3Comment: json['a3_comment'],
      a3RespondentsComment: json['a3_respondents_comment'],
      actionsAgreed: json['actions_agreed'],
    );
  }

  Map<String, dynamic> toJson() {
  return {
    if (a1Response != null) 'a1_response': a1Response,
    if (a1Comment != null) 'a1_comment': a1Comment,
    if (a1RespondentsComment != null) 'a1_respondents_comment': a1RespondentsComment,
    if (a2Response != null) 'a2_response': a2Response,
    if (a2Comment != null) 'a2_comment': a2Comment,
    if (a2RespondentsComment != null) 'a2_respondents_comment': a2RespondentsComment,
    if (a3Response != null) 'a3_response': a3Response,
    if (a3Comment != null) 'a3_comment': a3Comment,
    if (a3RespondentsComment != null) 'a3_respondents_comment': a3RespondentsComment,
    if (actionsAgreed != null) 'actions_agreed': actionsAgreed,
  };
}

  Map<String, dynamic> toServerJson() {
    return {
      'a1Response': a1Response,
      'a1Comment': a1Comment,
      'a1RespondentsComment': a1RespondentsComment,
      'a2Response': a2Response,
      'a2Comment': a2Comment,
      'a2RespondentsComment': a2RespondentsComment,
      'a3Response': a3Response,
      'a3Comment': a3Comment,
      'a3RespondentsComment': a3RespondentsComment,
      'actionsAgreed': actionsAgreed,
    };
  }
}