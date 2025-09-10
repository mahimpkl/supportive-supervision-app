class QualityAssurance {
  final bool? guidelinesFollowed;
  final bool? protocolsUpdated;
  final bool? clinicalAuditConducted;
  final bool? patientSatisfactionAssessed;
  final bool? recordsComplete;
  final bool? documentationLegible;
  final bool? consentFormsUsed;
  final bool? privacyMaintained;
  final bool? infectionControlPractices;
  final bool? handHygieneFacilities;
  final bool? emergencyProceduresKnown;
  final bool? adverseEventsReported;
  final bool? staffKnowledgeAdequate;
  final bool? continuingEducationProvided;
  final bool? supervisionRegular;
  final int? overallQualityScore;
  final String? areasForImprovement;
  final String? goodPracticesObserved;

  QualityAssurance({
    this.guidelinesFollowed,
    this.protocolsUpdated,
    this.clinicalAuditConducted,
    this.patientSatisfactionAssessed,
    this.recordsComplete,
    this.documentationLegible,
    this.consentFormsUsed,
    this.privacyMaintained,
    this.infectionControlPractices,
    this.handHygieneFacilities,
    this.emergencyProceduresKnown,
    this.adverseEventsReported,
    this.staffKnowledgeAdequate,
    this.continuingEducationProvided,
    this.supervisionRegular,
    this.overallQualityScore,
    this.areasForImprovement,
    this.goodPracticesObserved,
  });

  factory QualityAssurance.fromJson(Map<String, dynamic> json) {
    return QualityAssurance(
      guidelinesFollowed: _parseBool(json['guidelines_followed'] ?? json['guidelinesFollowed']),
      protocolsUpdated: _parseBool(json['protocols_updated'] ?? json['protocolsUpdated']),
      clinicalAuditConducted: _parseBool(json['clinical_audit_conducted'] ?? json['clinicalAuditConducted']),
      patientSatisfactionAssessed: _parseBool(json['patient_satisfaction_assessed'] ?? json['patientSatisfactionAssessed']),
      recordsComplete: _parseBool(json['records_complete'] ?? json['recordsComplete']),
      documentationLegible: _parseBool(json['documentation_legible'] ?? json['documentationLegible']),
      consentFormsUsed: _parseBool(json['consent_forms_used'] ?? json['consentFormsUsed']),
      privacyMaintained: _parseBool(json['privacy_maintained'] ?? json['privacyMaintained']),
      infectionControlPractices: _parseBool(json['infection_control_practices'] ?? json['infectionControlPractices']),
      handHygieneFacilities: _parseBool(json['hand_hygiene_facilities'] ?? json['handHygieneFacilities']),
      emergencyProceduresKnown: _parseBool(json['emergency_procedures_known'] ?? json['emergencyProceduresKnown']),
      adverseEventsReported: _parseBool(json['adverse_events_reported'] ?? json['adverseEventsReported']),
      staffKnowledgeAdequate: _parseBool(json['staff_knowledge_adequate'] ?? json['staffKnowledgeAdequate']),
      continuingEducationProvided: _parseBool(json['continuing_education_provided'] ?? json['continuingEducationProvided']),
      supervisionRegular: _parseBool(json['supervision_regular'] ?? json['supervisionRegular']),
      overallQualityScore: json['overall_quality_score'] ?? json['overallQualityScore'],
      areasForImprovement: json['areas_for_improvement'] ?? json['areasForImprovement'],
      goodPracticesObserved: json['good_practices_observed'] ?? json['goodPracticesObserved'],
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
      if (guidelinesFollowed != null) 'guidelines_followed': guidelinesFollowed,
      if (protocolsUpdated != null) 'protocols_updated': protocolsUpdated,
      if (clinicalAuditConducted != null) 'clinical_audit_conducted': clinicalAuditConducted,
      if (patientSatisfactionAssessed != null) 'patient_satisfaction_assessed': patientSatisfactionAssessed,
      if (recordsComplete != null) 'records_complete': recordsComplete,
      if (documentationLegible != null) 'documentation_legible': documentationLegible,
      if (consentFormsUsed != null) 'consent_forms_used': consentFormsUsed,
      if (privacyMaintained != null) 'privacy_maintained': privacyMaintained,
      if (infectionControlPractices != null) 'infection_control_practices': infectionControlPractices,
      if (handHygieneFacilities != null) 'hand_hygiene_facilities': handHygieneFacilities,
      if (emergencyProceduresKnown != null) 'emergency_procedures_known': emergencyProceduresKnown,
      if (adverseEventsReported != null) 'adverse_events_reported': adverseEventsReported,
      if (staffKnowledgeAdequate != null) 'staff_knowledge_adequate': staffKnowledgeAdequate,
      if (continuingEducationProvided != null) 'continuing_education_provided': continuingEducationProvided,
      if (supervisionRegular != null) 'supervision_regular': supervisionRegular,
      if (overallQualityScore != null) 'overall_quality_score': overallQualityScore,
      if (areasForImprovement != null) 'areas_for_improvement': areasForImprovement,
      if (goodPracticesObserved != null) 'good_practices_observed': goodPracticesObserved,
    };
  }

  Map<String, dynamic> toServerJson() {
    return {
      if (guidelinesFollowed != null) 'guidelines_followed': guidelinesFollowed,
      if (protocolsUpdated != null) 'protocols_updated': protocolsUpdated,
      if (clinicalAuditConducted != null) 'clinical_audit_conducted': clinicalAuditConducted,
      if (patientSatisfactionAssessed != null) 'patient_satisfaction_assessed': patientSatisfactionAssessed,
      if (recordsComplete != null) 'records_complete': recordsComplete,
      if (documentationLegible != null) 'documentation_legible': documentationLegible,
      if (consentFormsUsed != null) 'consent_forms_used': consentFormsUsed,
      if (privacyMaintained != null) 'privacy_maintained': privacyMaintained,
      if (infectionControlPractices != null) 'infection_control_practices': infectionControlPractices,
      if (handHygieneFacilities != null) 'hand_hygiene_facilities': handHygieneFacilities,
      if (emergencyProceduresKnown != null) 'emergency_procedures_known': emergencyProceduresKnown,
      if (adverseEventsReported != null) 'adverse_events_reported': adverseEventsReported,
      if (staffKnowledgeAdequate != null) 'staff_knowledge_adequate': staffKnowledgeAdequate,
      if (continuingEducationProvided != null) 'continuing_education_provided': continuingEducationProvided,
      if (supervisionRegular != null) 'supervision_regular': supervisionRegular,
      if (overallQualityScore != null) 'overall_quality_score': overallQualityScore,
      if (areasForImprovement != null) 'areas_for_improvement': areasForImprovement,
      if (goodPracticesObserved != null) 'good_practices_observed': goodPracticesObserved,
    };
  }

  QualityAssurance copyWith({
    bool? guidelinesFollowed,
    bool? protocolsUpdated,
    bool? clinicalAuditConducted,
    bool? patientSatisfactionAssessed,
    bool? recordsComplete,
    bool? documentationLegible,
    bool? consentFormsUsed,
    bool? privacyMaintained,
    bool? infectionControlPractices,
    bool? handHygieneFacilities,
    bool? emergencyProceduresKnown,
    bool? adverseEventsReported,
    bool? staffKnowledgeAdequate,
    bool? continuingEducationProvided,
    bool? supervisionRegular,
    int? overallQualityScore,
    String? areasForImprovement,
    String? goodPracticesObserved,
  }) {
    return QualityAssurance(
      guidelinesFollowed: guidelinesFollowed ?? this.guidelinesFollowed,
      protocolsUpdated: protocolsUpdated ?? this.protocolsUpdated,
      clinicalAuditConducted: clinicalAuditConducted ?? this.clinicalAuditConducted,
      patientSatisfactionAssessed: patientSatisfactionAssessed ?? this.patientSatisfactionAssessed,
      recordsComplete: recordsComplete ?? this.recordsComplete,
      documentationLegible: documentationLegible ?? this.documentationLegible,
      consentFormsUsed: consentFormsUsed ?? this.consentFormsUsed,
      privacyMaintained: privacyMaintained ?? this.privacyMaintained,
      infectionControlPractices: infectionControlPractices ?? this.infectionControlPractices,
      handHygieneFacilities: handHygieneFacilities ?? this.handHygieneFacilities,
      emergencyProceduresKnown: emergencyProceduresKnown ?? this.emergencyProceduresKnown,
      adverseEventsReported: adverseEventsReported ?? this.adverseEventsReported,
      staffKnowledgeAdequate: staffKnowledgeAdequate ?? this.staffKnowledgeAdequate,
      continuingEducationProvided: continuingEducationProvided ?? this.continuingEducationProvided,
      supervisionRegular: supervisionRegular ?? this.supervisionRegular,
      overallQualityScore: overallQualityScore ?? this.overallQualityScore,
      areasForImprovement: areasForImprovement ?? this.areasForImprovement,
      goodPracticesObserved: goodPracticesObserved ?? this.goodPracticesObserved,
    );
  }
}