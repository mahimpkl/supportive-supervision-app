import 'package:flutter/material.dart';

class LogisticsSection extends StatefulWidget {
  final Map<String, dynamic> data;
  final Map<String, TextEditingController> quantityControllers;
  final Map<String, TextEditingController> unitsControllers;
  final Function(String, dynamic) onDataChanged;

  const LogisticsSection({
    super.key,
    required this.data,
    required this.quantityControllers,
    required this.unitsControllers,
    required this.onDataChanged,
  });

  @override
  State<LogisticsSection> createState() => _LogisticsSectionState();
}

class _LogisticsSectionState extends State<LogisticsSection> {
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
                    'B. Logistics',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // B1. Medicine availability section
                  _buildMedicineAvailabilitySection(),
                  
                  const SizedBox(height: 24),
                  
                  // B2. Blood glucometer question
                  _buildResponseQuestion(
  'B2. Is the blood glucometer functioning and in use?',
  'b2_response',
),
_buildCommentField('B2 Comments', 'b2_comment'),
_buildCommentField('B2 Respondents Comment', 'b2_respondents_comment'),
_buildCommentField('B2 Validation Note', 'b2_validation_note'),
CheckboxListTile(
  title: Text('Random records checked'),
  value: widget.data['b2_random_records_checked'] == true,
  onChanged: (value) {
    widget.onDataChanged('b2_random_records_checked', value);
  },
),
_buildCommentField('Explanation if not in use', 'b2_explanation_if_not_in_use'),

// B3 Section  
_buildResponseQuestion(
  'B3. Are urine protein strips used?',
  'b3_response',
),
_buildCommentField('B3 Comments', 'b3_comment'),
_buildCommentField('B3 Respondents Comment', 'b3_respondents_comment'),
_buildCommentField('B3 Validation Note', 'b3_validation_note'),
CheckboxListTile(
  title: Text('Expiry date verified'),
  value: widget.data['b3_expiry_date_verified'] == true,
  onChanged: (value) {
    widget.onDataChanged('b3_expiry_date_verified', value);
  },
),
CheckboxListTile(
  title: Text('Storage conditions verified'),
  value: widget.data['b3_storage_conditions_verified'] == true,
  onChanged: (value) {
    widget.onDataChanged('b3_storage_conditions_verified', value);
  },
),

// B4 Section
_buildResponseQuestion(
  'B4. Are urine ketone strips used?',
  'b4_response',
),
_buildCommentField('B4 Comments', 'b4_comment'),
_buildCommentField('B4 Respondents Comment', 'b4_respondents_comment'),
_buildCommentField('B4 Validation Note', 'b4_validation_note'),
CheckboxListTile(
  title: Text('Expiry date verified'),
  value: widget.data['b4_expiry_date_verified'] == true,
  onChanged: (value) {
    widget.onDataChanged('b4_expiry_date_verified', value);
  },
),
CheckboxListTile(
  title: Text('Storage conditions verified'),
  value: widget.data['b4_storage_conditions_verified'] == true,
  onChanged: (value) {
    widget.onDataChanged('b4_storage_conditions_verified', value);
  },
),


// B5. Equipment availability section
_buildEquipmentAvailabilitySection(),

const SizedBox(height: 24),

// B6-B10 MHDC Management questions
_buildMhdcQuestions(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineAvailabilitySection() {
    // Updated to match the data model field names
    final medicines = [
      {'name': 'Amlodipine 5/10mg', 'key': 'amlodipine_5_10mg'},
      {'name': 'Enalapril 2.5/5/10mg', 'key': 'enalapril_2_5_10mg'},
      {'name': 'Losartan 25/50mg', 'key': 'losartan_25_50mg'},
      {'name': 'Hydrochlorothiazide 12.5/25mg', 'key': 'hydrochlorothiazide_12_5_25mg'},
      {'name': 'Chlorthalidone 6.25/12.5mg', 'key': 'chlorthalidone_6_25_12_5mg'},
      {'name': 'Other Antihypertensives', 'key': 'other_antihypertensives'},
      {'name': 'Atorvastatin 5mg', 'key': 'atorvastatin_5mg'},
      {'name': 'Atorvastatin 10mg', 'key': 'atorvastatin_10mg'},
      {'name': 'Atorvastatin 20mg', 'key': 'atorvastatin_20mg'},
      {'name': 'Other Statins', 'key': 'other_statins'},
      {'name': 'Metformin 500mg', 'key': 'metformin_500mg'},
      {'name': 'Metformin 1000mg', 'key': 'metformin_1000mg'},
      {'name': 'Glimepiride 1-2mg', 'key': 'glimepiride_1_2mg'},
      {'name': 'Gliclazide 40-80mg', 'key': 'gliclazide_40_80mg'},
      {'name': 'Glipizide 2.5-5mg', 'key': 'glipizide_2_5_5mg'},
      {'name': 'Sitagliptin 50mg', 'key': 'sitagliptin_50mg'},
      {'name': 'Pioglitazone 5mg', 'key': 'pioglitazone_5mg'},
      {'name': 'Empagliflozin 10mg', 'key': 'empagliflozin_10mg'},
      {'name': 'Insulin Soluble Injection', 'key': 'insulin_soluble_inj'},
      {'name': 'Insulin NPH Injection', 'key': 'insulin_nph_inj'},
      {'name': 'Other Hypoglycemic Agents', 'key': 'other_hypoglycemic_agents'},
      {'name': 'Dextrose 25% Solution', 'key': 'dextrose_25_solution'},
      {'name': 'Aspirin 75mg', 'key': 'aspirin_75mg'},
      {'name': 'Clopidogrel 75mg', 'key': 'clopidogrel_75mg'},
      {'name': 'Metoprolol Succinate 12.5/25/50mg', 'key': 'metoprolol_succinate_12_5_25_50mg'},
      {'name': 'Isosorbide Dinitrate 5mg', 'key': 'isosorbide_dinitrate_5mg'},
      {'name': 'Other Drugs', 'key': 'other_drugs'},
      {'name': 'Amoxicillin + Clavulanic Potassium 625mg', 'key': 'amoxicillin_clavulanic_potassium_625mg'},
      {'name': 'Azithromycin 500mg', 'key': 'azithromycin_500mg'},
      {'name': 'Other Antibiotics', 'key': 'other_antibiotics'},
      {'name': 'Salbutamol DPI', 'key': 'salbutamol_dpi'},
      {'name': 'Salbutamol', 'key': 'salbutamol'},
      {'name': 'Ipratropium', 'key': 'ipratropium'},
      {'name': 'Tiotropium Bromide', 'key': 'tiotropium_bromide'},
      {'name': 'Formoterol', 'key': 'formoterol'},
      {'name': 'Other Bronchodilators', 'key': 'other_bronchodilators'},
      {'name': 'Prednisolone 5-10-20mg', 'key': 'prednisolone_5_10_20mg'},
      {'name': 'Other Steroids (Oral)', 'key': 'other_steroids_oral'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'B1. Considering the previous trend for patient turnover at health facility, are the following essential NCD medicines available (in health facilities store) and sufficient for 2 months?',
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
                    Expanded(flex: 3, child: Text('Medicine', style: TextStyle(fontWeight: FontWeight.w600))),
                    Expanded(flex: 1, child: Text('Available', style: TextStyle(fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
                    Expanded(flex: 2, child: Text('Quantity', style: TextStyle(fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
                  ],
                ),
              ),
              // Medicine rows
              ...medicines.asMap().entries.map((entry) {
                final index = entry.key;
                final medicine = entry.value;
                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: index > 0 ? BorderSide(color: Colors.grey.shade300) : BorderSide.none,
                    ),
                  ),
                  child: _buildMedicineRow(medicine['name']!, medicine['key']!),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

 Widget _buildMedicineRow(String medicine, String key) {
  // Initialize controllers if they don't exist
  if (!widget.quantityControllers.containsKey(key)) {
    widget.quantityControllers[key] = TextEditingController();
  }
  if (!widget.unitsControllers.containsKey(key)) {
    widget.unitsControllers[key] = TextEditingController();
  }

  final isAvailable = widget.data[key] == 'Y';
  final isOtherMedicine = medicine.toLowerCase().contains('other');
  
  return Padding(
    padding: const EdgeInsets.all(8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: Text(
                medicine,
                style: const TextStyle(fontSize: 12),
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Radio<String>(
                          value: 'Y',
                          groupValue: widget.data[key],
                          onChanged: (value) {
                            widget.onDataChanged(key, value);
                            // Clear fields when marked as not available
                            if (value != 'Y') {
                              widget.quantityControllers[key]?.clear();
                              widget.unitsControllers[key]?.clear();
                              widget.onDataChanged('${key}_quantity', null);
                              widget.onDataChanged('${key}_units', null);
                              if (isOtherMedicine) {
                                widget.onDataChanged('${key}_specify', null);
                              }
                            }
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
                            // Clear fields when marked as not available
                            if (value != 'Y') {
                              widget.quantityControllers[key]?.clear();
                              widget.unitsControllers[key]?.clear();
                              widget.onDataChanged('${key}_quantity', null);
                              widget.onDataChanged('${key}_units', null);
                              if (isOtherMedicine) {
                                widget.onDataChanged('${key}_specify', null);
                              }
                            }
                          },
                        ),
                      ),
                      const Text('N', style: TextStyle(fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: isAvailable ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: TextFormField(
                  controller: widget.quantityControllers[key],
                  decoration: const InputDecoration(
                    hintText: 'Quantity',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 12),
                  onChanged: (value) {
                    widget.onDataChanged('${key}_quantity', value.isNotEmpty ? int.tryParse(value) : null);
                  },
                ),
              ) : const SizedBox(),
            ),
          ],
        ),
        // Add specification field for "Other" medicines when available
        if (isOtherMedicine && isAvailable)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextFormField(
              decoration: InputDecoration(
                hintText: 'Specify $medicine',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                border: const OutlineInputBorder(),
              ),
              style: const TextStyle(fontSize: 12),
              onChanged: (value) {
                widget.onDataChanged('${key}_specify', value.isNotEmpty ? value : null);
              },
            ),
          ),
      ],
    ),
  );
}

  Widget _buildEquipmentAvailabilitySection() {
  final equipment = [
    {'name': 'Sphygmomanometer', 'key': 'b5_sphygmomanometer'},
    {'name': 'Weighing Scale', 'key': 'b5_weighing_scale'},
    {'name': 'Measuring Tape', 'key': 'b5_measuring_tape'},
    {'name': 'Peak Expiratory Flow Meter', 'key': 'b5_peak_expiratory_flow_meter'},
    {'name': 'Oxygen', 'key': 'b5_oxygen'},
    {'name': 'Oxygen mask', 'key': 'b5_oxygen_mask'},
    {'name': 'Nebulizer', 'key': 'b5_nebulizer'},
    {'name': 'Pulse oximetry', 'key': 'b5_pulse_oximetry'},
    {'name': 'Glucometer', 'key': 'b5_glucometer'},
    {'name': 'Glucometer strips', 'key': 'b5_glucometer_strips'},
    {'name': 'Lancets', 'key': 'b5_lancets'},
    {'name': 'Urine dipstick', 'key': 'b5_urine_dipstick'},
    {'name': 'ECG', 'key': 'b5_ecg'},
    {'name': 'Other', 'key': 'b5_other'},
  ];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'B5. Are the following essential equipment available and functional in the health facilities?',
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
                  Expanded(flex: 3, child: Text('Equipment', style: TextStyle(fontWeight: FontWeight.w600))),
                  Expanded(flex: 2, child: Text('Available & Functional', style: TextStyle(fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
                  Expanded(flex: 2, child: Text('Quantity', style: TextStyle(fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
                ],
              ),
            ),
            // Equipment rows
            ...equipment.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: index > 0 ? BorderSide(color: Colors.grey.shade300) : BorderSide.none,
                  ),
                ),
                child: _buildEquipmentRow(item['name']!, item['key']!),
              );
            }),
          ],
        ),
      ),
      const SizedBox(height: 16),
      _buildCommentField('B5 Comments', 'b5_comment'),
      _buildCommentField('B5 Respondents Comment', 'b5_respondents_comment'),
      _buildCommentField('B5 Validation Note', 'b5_validation_note'),
    ],
  );
}

  Widget _buildEquipmentRow(String equipment, String key) {
  final isAvailable = widget.data[key] == 'Y';
  final isOtherEquipment = equipment.toLowerCase() == 'other';
  
  return Padding(
    padding: const EdgeInsets.all(12),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(equipment, style: const TextStyle(fontSize: 13)),
            ),
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Radio<String>(
                    value: 'Y',
                    groupValue: widget.data[key],
                    onChanged: (value) {
                      widget.onDataChanged(key, value);
                    },
                  ),
                  const Text('Y', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 8),
                  Radio<String>(
                    value: 'N',
                    groupValue: widget.data[key],
                    onChanged: (value) {
                      widget.onDataChanged(key, value);
                    },
                  ),
                  const Text('N', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: isAvailable ? TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Quantity',
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 12),
                onChanged: (value) {
                  widget.onDataChanged('${key}_quantity', value.isNotEmpty ? int.tryParse(value) : null);
                },
              ) : const SizedBox(),
            ),
          ],
        ),
        if (isOtherEquipment && isAvailable)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextFormField(
              decoration: const InputDecoration(
                hintText: 'Specify other equipment',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontSize: 12),
              onChanged: (value) {
                widget.onDataChanged('${key}_specify', value.isNotEmpty ? value : null);
              },
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

  Widget _buildMhdcQuestions() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'MHDC Management',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 16),
      
      _buildResponseQuestion(
        'B6. Are the MHDC NCD management leaflets for Healthcare workers available at the Health Center?',
        'b6_response',
      ),
      _buildCommentField('B6 Comments', 'b6_comment'),
      _buildCommentField('B6 Respondents Comment', 'b6_respondents_comment'),
      
      const SizedBox(height: 16),
      
      _buildResponseQuestion(
        'B7. Are MHDC awareness and patient education materials available at the health center?',
        'b7_response',
      ),
      _buildCommentField('B7 Comments', 'b7_comment'),
      _buildCommentField('B7 Respondents Comment', 'b7_respondents_comment'),
      
      const SizedBox(height: 16),
      
      _buildResponseQuestion(
        'B8. Is the NCD register available and filled properly?',
        'b8_response',
      ),
      _buildCommentField('B8 Comments', 'b8_comment'),
      _buildCommentField('B8 Respondents Comment', 'b8_respondents_comment'),
      
      const SizedBox(height: 16),
      
      _buildResponseQuestion(
        'B9. Is WHO-ISH CVD Risk Prediction Chart available for patient care?',
        'b9_response',
      ),
      _buildCommentField('B9 Comments', 'b9_comment'),
      _buildCommentField('B9 Respondents Comment', 'b9_respondents_comment'),
      
      const SizedBox(height: 16),
      
      _buildResponseQuestion(
        'B10. Is WHO-ISH CVD Risk Prediction Chart in use for patient care?',
        'b10_response',
      ),
      _buildCommentField('B10 Comments', 'b10_comment'),
      _buildCommentField('B10 Respondents Comment', 'b10_respondents_comment'),
    ],
  );
}
}

