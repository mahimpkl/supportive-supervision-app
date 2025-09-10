import 'package:flutter/material.dart';

class ServiceStandardsSection extends StatefulWidget {
  final Map<String, dynamic> data;
  final Function(String, dynamic) onDataChanged;

  const ServiceStandardsSection({
    super.key,
    required this.data,
    required this.onDataChanged,
  });

  @override
  State<ServiceStandardsSection> createState() => _ServiceStandardsSectionState();
}

class _ServiceStandardsSectionState extends State<ServiceStandardsSection> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'C. Service Standards',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  
                  // C2. NCD services as per PEN protocol
                  _buildPenProtocolSection(),
                  
                  const SizedBox(height: 24),
                  
                  // C3. Examination room confidentiality
                  _buildResponseQuestion(
                    'C3. Is there an examination room that allows confidentiality?',
                    'c3_response',
                  ),
                  _buildCommentField('C3 Comments', 'c3_comment'),
                  _buildRespondentsCommentField('C3 Respondent Comments', 'c3_respondents_comment'),
                  
                  const SizedBox(height: 16),
                  
                  // C4. Home bound patients
                  _buildResponseQuestion(
                    'C4. Is there any NCD services provided to home bound patients by the Health Facility?',
                    'c4_response',
                  ),
                  _buildCommentField('C4 Comments', 'c4_comment'),
                  _buildRespondentsCommentField('C4 Respondent Comments', 'c4_respondents_comment'),
                  
                  const SizedBox(height: 16),
                  
                  // C5. Community based NCD care
                  _buildResponseQuestion(
                    'C5. Is there any community based NCD care provided by the Health Facilities?',
                    'c5_response',
                  ),
                  _buildCommentField('C5 Comments', 'c5_comment'),
                  _buildRespondentsCommentField('C5 Respondent Comments', 'c5_respondents_comment'),
                  
                  const SizedBox(height: 16),
                  
                  // C6. School-based program
                  _buildResponseQuestion(
                    'C6. Is there any school-based program for NCD prevention and health promotion conducted by Health Facility?',
                    'c6_response',
                  ),
                  _buildCommentField('C6 Comments', 'c6_comment'),
                  _buildRespondentsCommentField('C6 Respondent Comments', 'c6_respondents_comment'),
                  
                  const SizedBox(height: 16),
                  
                  // C7. Patient tracking mechanism
                  _buildResponseQuestion(
                    'C7. Is there any patient tracking mechanism such as recall and reminder for proactively following up on NCD patients?',
                    'c7_response',
                  ),
                  _buildCommentField('C7 Comments', 'c7_comment'),
                  _buildRespondentsCommentField('C7 Respondent Comments', 'c7_respondents_comment'),
                  
                  const SizedBox(height: 24),
                  
                  // Actions Agreed field
                  _buildCommentField('Actions Agreed', 'actions_agreed'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

 

  Widget _buildPenProtocolSection() {
    // Updated to match the exact field names from the data model
    final standards = [
      {
        'name': 'Blood pressure measurement of all clients above 40 y/o and people at risk (as per leaflet), at every visit', 
        'key': 'c2_blood_pressure',
        'hasExtraFields': true,
        'extraFields': ['c2_blood_pressure_equipment_calibrated', 'c2_blood_pressure_protocol_followed']
      },
      {
        'name': 'Blood sugar measurement of all clients above 40 y/o and patients at risk (as per leaflet) at first visit, then each visit when diabetic patients comes', 
        'key': 'c2_blood_sugar',
        'hasExtraFields': true,
        'extraFields': ['c2_blood_sugar_strips_available', 'c2_blood_sugar_quality_control']
      },
      {
        'name': 'BMI measurement at every visit (weight measurement)', 
        'key': 'c2_bmi_measurement',
        'hasExtraFields': true,
        'extraFields': ['c2_bmi_calculation_accurate']
      },
      {
        'name': 'Waist circumference measurement at every visit', 
        'key': 'c2_waist_circumference',
        'hasExtraFields': true,
        'extraFields': ['c2_waist_measurement_technique_correct']
      },
      {
        'name': 'CVD risk estimation for all patients above 40 y/o', 
        'key': 'c2_cvd_risk_estimation',
        'hasExtraFields': true,
        'extraFields': ['c2_cvd_chart_available_and_used']
      },
      {
        'name': 'Urine protein measurement of all clients above 40 y/o and at risk (leaflet). Then every 6 months for people with CKD, diabetes, hypertension', 
        'key': 'c2_urine_protein_measurement',
        'hasExtraFields': true,
        'extraFields': ['c2_urine_protein_strips_not_expired']
      },
      {
        'name': 'Peak Expiratory Flow Rate of COPD and asthmatic clients at every visit', 
        'key': 'c2_peak_expiratory_flow_rate',
        'hasExtraFields': true,
        'extraFields': ['c2_peak_flow_meter_calibrated']
      },
      {
        'name': 'eGFR calculation for all people at risk (according to leaflet)', 
        'key': 'c2_egfr_calculation',
        'hasExtraFields': true,
        'extraFields': ['c2_egfr_formula_used_correctly']
      },
      {
        'name': 'Brief intervention using 5A and 5R for tobacco cessation, unhealthy diet, alcohol intake and physical inactivity at every visit', 
        'key': 'c2_brief_intervention'
      },
      {
        'name': 'Foot examination once every year for Diabetes', 
        'key': 'c2_foot_examination'
      },
      {
        'name': 'Oral examination at every visit', 
        'key': 'c2_oral_examination'
      },
      {
        'name': 'Counseling for eye examination once every year', 
        'key': 'c2_eye_examination'
      },
      {
        'name': 'Health education for foot care advice at every visit', 
        'key': 'c2_health_education'
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'C2. Are the following NCD services provided to the clients as per the PEN protocol and standards?',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // Header row
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: const Row(
                  children: [
                    Expanded(flex: 3, child: Text('Standard/Protocol', style: TextStyle(fontWeight: FontWeight.w600))),
                    Expanded(flex: 1, child: Text('Followed', style: TextStyle(fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
                  ],
                ),
              ),
              // Standard rows
              ...standards.asMap().entries.map((entry) {
                final index = entry.key;
                final standard = entry.value;
                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: index > 0 ? BorderSide(color: Colors.grey.shade300) : BorderSide.none,
                    ),
                  ),
                  child: _buildStandardRowWithDetails(standard),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildCommentField('C2 Main Comments', 'c2_main_comment'),
        _buildRespondentsCommentField('C2 Respondent Comments', 'c2_respondents_comment'),
      ],
    );
  }

  Widget _buildStandardRowWithDetails(Map<String, dynamic> standard) {
    final key = standard['key'] as String;
    final name = standard['name'] as String;
    final hasExtraFields = standard['hasExtraFields'] == true;
    final extraFields = standard['extraFields'] as List<String>? ?? [];

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  name,
                  style: const TextStyle(fontSize: 11),
                ),
              ),
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Radio<String>(
                        value: 'Y',
                        groupValue: widget.data[key],
                        onChanged: (value) {
                          widget.onDataChanged(key, value);
                        },
                      ),
                    ),
                    const Text('Y', style: TextStyle(fontSize: 11)),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Radio<String>(
                        value: 'N',
                        groupValue: widget.data[key],
                        onChanged: (value) {
                          widget.onDataChanged(key, value);
                        },
                      ),
                    ),
                    const Text('N', style: TextStyle(fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          // Comment field for this standard
          if (widget.data[key] != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Comments',
                  hintText: 'Enter comments for ${name.split(' ').take(3).join(' ')}...',
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  border: const OutlineInputBorder(),
                ),
                maxLines: 2,
                style: const TextStyle(fontSize: 12),
                textCapitalization: TextCapitalization.sentences,
                onChanged: (value) {
                  widget.onDataChanged('${key}_comment', value.isNotEmpty ? value : null);
                },
              ),
            ),
          // Extra boolean fields for some standards
          if (hasExtraFields && widget.data[key] == 'Y')
            ...extraFields.map((extraKey) => 
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Checkbox(
                      value: widget.data[extraKey] == true,
                      onChanged: (value) {
                        widget.onDataChanged(extraKey, value);
                      },
                    ),
                    Expanded(
                      child: Text(
                        _getExtraFieldLabel(extraKey),
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getExtraFieldLabel(String key) {
    switch (key) {
      case 'c2_blood_pressure_equipment_calibrated':
        return 'Equipment calibrated';
      case 'c2_blood_pressure_protocol_followed':
        return 'Protocol followed';
      case 'c2_blood_sugar_strips_available':
        return 'Strips available';
      case 'c2_blood_sugar_quality_control':
        return 'Quality control performed';
      case 'c2_bmi_calculation_accurate':
        return 'Calculation accurate';
      case 'c2_waist_measurement_technique_correct':
        return 'Measurement technique correct';
      case 'c2_cvd_chart_available_and_used':
        return 'CVD chart available and used';
      case 'c2_urine_protein_strips_not_expired':
        return 'Strips not expired';
      case 'c2_peak_flow_meter_calibrated':
        return 'Peak flow meter calibrated';
      case 'c2_egfr_formula_used_correctly':
        return 'eGFR formula used correctly';
      default:
        return key.replaceAll('_', ' ').replaceAll('c2 ', '');
    }
  }

  Widget _buildServiceRow(String service, String key) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              service,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Radio<String>(
                    value: 'Y',
                    groupValue: widget.data[key],
                    onChanged: (value) {
                      widget.onDataChanged(key, value);
                    },
                  ),
                ),
                const Text('Y', style: TextStyle(fontSize: 11)),
                const SizedBox(width: 4),
                Flexible(
                  child: Radio<String>(
                    value: 'N',
                    groupValue: widget.data[key],
                    onChanged: (value) {
                      widget.onDataChanged(key, value);
                    },
                  ),
                ),
                const Text('N', style: TextStyle(fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponseQuestion(String question, String key) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Yes'),
                value: 'Y',
                groupValue: widget.data[key],
                onChanged: (value) {
                  widget.onDataChanged(key, value);
                },
                contentPadding: EdgeInsets.zero,
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: const Text('No'),
                value: 'N',
                groupValue: widget.data[key],
                onChanged: (value) {
                  widget.onDataChanged(key, value);
                },
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCommentField(String label, String key) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          hintText: 'Enter comments',
          alignLabelWithHint: true,
        ),
        maxLines: 2,
        textCapitalization: TextCapitalization.sentences,
        onChanged: (value) {
          widget.onDataChanged(key, value.isNotEmpty ? value : null);
        },
      ),
    );
  }

  Widget _buildRespondentsCommentField(String label, String key) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          hintText: 'Enter respondent comments',
          alignLabelWithHint: true,
          fillColor: Colors.blue.shade50,
          filled: true,
        ),
        maxLines: 2,
        textCapitalization: TextCapitalization.sentences,
        onChanged: (value) {
          widget.onDataChanged(key, value.isNotEmpty ? value : null);
        },
      ),
    );
  }
}