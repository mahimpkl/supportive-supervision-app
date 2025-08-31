import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/forms_provider.dart';

class CreateVisitScreen extends ConsumerStatefulWidget {
  final int formId;
  final int visitNumber;

  const CreateVisitScreen({
    super.key,
    required this.formId,
    required this.visitNumber,
  });

  @override
  ConsumerState<CreateVisitScreen> createState() => _CreateVisitScreenState();
}

class _CreateVisitScreenState extends ConsumerState<CreateVisitScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;
  
  // Basic visit info
  DateTime? _visitDate;
  final _recommendationsController = TextEditingController();
  final _actionsAgreedController = TextEditingController();
  
  bool _isLoading = false;
  
  // Section data maps - using snake_case keys to match backend
  final Map<String, dynamic> _adminManagement = {};
  final Map<String, dynamic> _logistics = {};
  final Map<String, dynamic> _equipment = {};
  final Map<String, dynamic> _mhdcManagement = {};
  final Map<String, dynamic> _serviceStandards = {};
  final Map<String, dynamic> _healthInformation = {};
  final Map<String, dynamic> _integration = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this);
    _visitDate = DateTime.now();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _recommendationsController.dispose();
    _actionsAgreedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final hasInput = _recommendationsController.text.trim().isNotEmpty ||
            _actionsAgreedController.text.trim().isNotEmpty ||
            _adminManagement.isNotEmpty ||
            _logistics.isNotEmpty ||
            _equipment.isNotEmpty ||
            _mhdcManagement.isNotEmpty ||
            _serviceStandards.isNotEmpty ||
            _healthInformation.isNotEmpty ||
            _integration.isNotEmpty;
        if (!hasInput) return true;
        return await _confirmDiscard();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Visit ${widget.visitNumber}'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              final canLeave = await _checkCanLeave();
              if (canLeave && mounted) Navigator.of(context).pop();
            },
          ),
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: const [
              Tab(text: 'Basic'),
              Tab(text: 'Admin'),
              Tab(text: 'Logistics'),
              Tab(text: 'Equipment'),
              Tab(text: 'MHDC'),
              Tab(text: 'Standards'),
              Tab(text: 'Health Info'),
              Tab(text: 'Integration'),
            ],
          ),
        ),
        body: Form(
          key: _formKey,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildBasicInfoTab(),
              _buildAdminManagementTab(),
              _buildLogisticsTab(),
              _buildEquipmentTab(),
              _buildMhdcManagementTab(),
              _buildServiceStandardsTab(),
              _buildHealthInformationTab(),
              _buildIntegrationTab(),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final canLeave = await _confirmDiscard();
                    if (canLeave && mounted) Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              if (_tabController.index > 0) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _tabController.animateTo(_tabController.index - 1);
                    },
                    child: const Text('Previous'),
                  ),
                ),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleNextOrSave,
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        )
                      : Text(_tabController.index == 7 ? 'Save Visit' : 'Next'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoTab() {
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
                  Text(
                    'Visit ${widget.visitNumber} Information',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Visit Date
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Visit Date'),
                    subtitle: Text(_visitDate != null 
                        ? '${_visitDate!.day}/${_visitDate!.month}/${_visitDate!.year}'
                        : 'Select date'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _selectDate,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Recommendations
                  TextFormField(
                    controller: _recommendationsController,
                    decoration: const InputDecoration(
                      labelText: 'Recommendations',
                      hintText: 'Enter recommendations from this visit',
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Actions Agreed
                  TextFormField(
                    controller: _actionsAgreedController,
                    decoration: const InputDecoration(
                      labelText: 'Actions Agreed',
                      hintText: 'Enter actions agreed upon',
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminManagementTab() {
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
                    'Administrative Management',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildResponseQuestion(
                    'A1. Is there a provision of Health Facility Operation and Management Committee at the health facility?',
                    'a1_response',
                    _adminManagement,
                  ),
                  
                  _buildCommentField(
                    'A1 Comments',
                    'a1_comment',
                    _adminManagement,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildResponseQuestion(
                    'A2. Does the committee discuss NCD service provisions at their regular meetings?',
                    'a2_response',
                    _adminManagement,
                  ),
                  
                  _buildCommentField(
                    'A2 Comments',
                    'a2_comment',
                    _adminManagement,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildResponseQuestion(
                    'A3. Does the Health facility and its Health care workers discuss quarterly the NCD services related queries and cases with MHDC team over Telemedicine or other means?',
                    'a3_response',
                    _adminManagement,
                  ),
                  
                  _buildCommentField(
                    'A3 Comments',
                    'a3_comment',
                    _adminManagement,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogisticsTab() {
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
                    'Logistics and Medicines',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Medicine availability questions
                  _buildMedicineAvailabilitySection(),
                  
                  const SizedBox(height: 16),
                  
                  _buildResponseQuestion(
                    'B2. Is the blood glucometer functioning and in use?',
                    'b2_response',
                    _logistics,
                  ),
                  
                  _buildCommentField(
                    'B2 Comments',
                    'b2_comment',
                    _logistics,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentTab() {
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
                    'Equipment Availability',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildEquipmentAvailabilitySection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMhdcManagementTab() {
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
                    'MHDC Management',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildResponseQuestion(
                    'B6. Are the MHDC NCD management leaflets for Healthcare workers available at the Health Center so that health care workers can easily refer to during patient care?',
                    'b6_response',
                    _mhdcManagement,
                  ),
                  
                  _buildCommentField(
                    'B6 Comments',
                    'b6_comment',
                    _mhdcManagement,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildResponseQuestion(
                    'B7. Are MHDC awareness and patient education materials available at the health center?',
                    'b7_response',
                    _mhdcManagement,
                  ),
                  
                  _buildCommentField(
                    'B7 Comments',
                    'b7_comment',
                    _mhdcManagement,
                  ),

                  const SizedBox(height: 16),
                  
                  _buildResponseQuestion(
                    'B8. Is the NCD register available and filled properly?',
                    'b8_response',
                    _mhdcManagement,
                  ),
                  
                  _buildCommentField(
                    'B8 Comments',
                    'b8_comment',
                    _mhdcManagement,
                  ),

                  const SizedBox(height: 16),
                  
                  _buildResponseQuestion(
                    'B9. Is WHO-ISH CVD Risk Prediction Chart available for patient care in the health facility?',
                    'b9_response',
                    _mhdcManagement,
                  ),
                  
                  _buildCommentField(
                    'B9 Comments',
                    'b9_comment',
                    _mhdcManagement,
                  ),

                  const SizedBox(height: 16),
                  
                  _buildResponseQuestion(
                    'B10. Is WHO-ISH CVD Risk Prediction Chart in use for patient care in health facility?',
                    'b10_response',
                    _mhdcManagement,
                  ),
                  
                  _buildCommentField(
                    'B10 Comments',
                    'b10_comment',
                    _mhdcManagement,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceStandardsTab() {
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
                    'Service Standards',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  const Text(
                    'C2. Are the following NCD services provided to the clients as per the PEN protocol and standards?',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  _buildServiceStandardsSection(),

                  const SizedBox(height: 16),
                  
                  _buildResponseQuestion(
                    'C3. Is there an examination room that allows confidentiality?',
                    'c3_response',
                    _serviceStandards,
                  ),
                  
                  _buildCommentField(
                    'C3 Comments',
                    'c3_comment',
                    _serviceStandards,
                  ),

                  const SizedBox(height: 16),
                  
                  _buildResponseQuestion(
                    'C4. Is there any NCD services provided to home bound patients by the Health Facility?',
                    'c4_response',
                    _serviceStandards,
                  ),
                  
                  _buildCommentField(
                    'C4 Comments',
                    'c4_comment',
                    _serviceStandards,
                  ),

                  const SizedBox(height: 16),
                  
                  _buildResponseQuestion(
                    'C5. Is there any community based NCD care provided by the Health Facilities?',
                    'c5_response',
                    _serviceStandards,
                  ),
                  
                  _buildCommentField(
                    'C5 Comments',
                    'c5_comment',
                    _serviceStandards,
                  ),

                  const SizedBox(height: 16),
                  
                  _buildResponseQuestion(
                    'C6. Is there any school-based program for NCD prevention and health promotion conducted by Health Facility?',
                    'c6_response',
                    _serviceStandards,
                  ),
                  
                  _buildCommentField(
                    'C6 Comments',
                    'c6_comment',
                    _serviceStandards,
                  ),

                  const SizedBox(height: 16),
                  
                  _buildResponseQuestion(
                    'C7. Is there any patient tracking mechanism such as recall and reminder for proactively following up on NCD patients?',
                    'c7_response',
                    _serviceStandards,
                  ),
                  
                  _buildCommentField(
                    'C7 Comments',
                    'c7_comment',
                    _serviceStandards,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthInformationTab() {
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
                    'Health Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildResponseQuestion(
                    'D1. Is NCD OPD register regularly updated and thoroughly completed?',
                    'd1_response',
                    _healthInformation,
                  ),
                  
                  _buildCommentField(
                    'D1 Comments',
                    'd1_comment',
                    _healthInformation,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildResponseQuestion(
                    'D2. Is the NCD dashboard displayed with updated information?',
                    'd2_response',
                    _healthInformation,
                  ),
                  
                  _buildCommentField(
                    'D2 Comments',
                    'd2_comment',
                    _healthInformation,
                  ),

                  const SizedBox(height: 16),
                  
                  _buildResponseQuestion(
                    'D3. Is the Monthly Reporting Form sent to the concerned authority?',
                    'd3_response',
                    _healthInformation,
                  ),
                  
                  _buildCommentField(
                    'D3 Comments',
                    'd3_comment',
                    _healthInformation,
                  ),

                  const SizedBox(height: 16),
                  
                  _buildResponseQuestion(
                    'D4. What number of people sought NCD services in the previous month?',
                    'd4_response',
                    _healthInformation,
                  ),
                  
                  _buildCommentField(
                    'D4 Comments',
                    'd4_comment',
                    _healthInformation,
                  ),

                  const SizedBox(height: 16),
                  
                  _buildResponseQuestion(
                    'D5. Is there any dedicated healthcare worker assigned for NCD service provisions?',
                    'd5_response',
                    _healthInformation,
                  ),
                  
                  _buildCommentField(
                    'D5 Comments',
                    'd5_comment',
                    _healthInformation,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntegrationTab() {
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
                    'Integration of NCD services',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildResponseQuestion(
                    'E1. Are Health Workers in the health facility aware of the purpose of the PEN programme?',
                    'e1_response',
                    _integration,
                  ),
                  
                  _buildCommentField(
                    'E1 Comments',
                    'e1_comment',
                    _integration,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildResponseQuestion(
                    'E2. Is health education on tobacco, alcohol, unhealthy diet and physical activity provided to all patients at risk of NCDs?',
                    'e2_response',
                    _integration,
                  ),
                  
                  _buildCommentField(
                    'E2 Comments',
                    'e2_comment',
                    _integration,
                  ),

                  const SizedBox(height: 16),
                  
                  _buildResponseQuestion(
                    'E3. Is screening for raised blood pressure and raised blood sugar provided to all patients at high risk for NCDs?',
                    'e3_response',
                    _integration,
                  ),
                  
                  _buildCommentField(
                    'E3 Comments',
                    'e3_comment',
                    _integration,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponseQuestion(String question, String key, Map<String, dynamic> sectionData) {
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
                groupValue: sectionData[key],
                onChanged: (value) {
                  setState(() {
                    sectionData[key] = value;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: const Text('No'),
                value: 'N',
                groupValue: sectionData[key],
                onChanged: (value) {
                  setState(() {
                    sectionData[key] = value;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCommentField(String label, String key, Map<String, dynamic> sectionData) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Enter comments',
        alignLabelWithHint: true,
      ),
      maxLines: 2,
      textCapitalization: TextCapitalization.sentences,
      onChanged: (value) {
        sectionData[key] = value.isNotEmpty ? value : null;
      },
    );
  }

  Widget _buildMedicineAvailabilitySection() {
    final medicines = [
      {'name': 'Amlodipine 5-10mg', 'key': 'amlodipine_5_10mg'},
      {'name': 'Enalapril 2.5-10mg', 'key': 'enalapril_2_5_10mg'},
      {'name': 'Losartan 25mg/50mg', 'key': 'losartan_25_50mg'},
      {'name': 'Hydrochlorothiazide 12.5-25mg', 'key': 'hydrochlorothiazide_12_5_25mg'},
      {'name': 'Chlorthalidone 6.25-12.5mg', 'key': 'chlorthalidone_6_25_12_5mg'},
      {'name': 'Atorvastatin 5mg', 'key': 'atorvastatin_5mg'},
      {'name': 'Atorvastatin 10mg', 'key': 'atorvastatin_10mg'},
      {'name': 'Atorvastatin 20mg', 'key': 'atorvastatin_20mg'},
      {'name': 'Metformin 500mg', 'key': 'metformin_500mg'},
      {'name': 'Metformin 1000mg', 'key': 'metformin_1000mg'},
      {'name': 'Aspirin 75mg', 'key': 'aspirin_75mg'},
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
        const SizedBox(height: 8),
        ...medicines.map((medicine) => _buildMedicineRow(medicine['name']!, medicine['key']!)),
      ],
    );
  }

  Widget _buildMedicineRow(String medicine, String key) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(medicine),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Radio<String>(
                  value: 'Y',
                  groupValue: _logistics[key],
                  onChanged: (value) {
                    setState(() {
                      _logistics[key] = value;
                    });
                  },
                ),
                const Text('Y'),
                Radio<String>(
                  value: 'N',
                  groupValue: _logistics[key],
                  onChanged: (value) {
                    setState(() {
                      _logistics[key] = value;
                    });
                  },
                ),
                const Text('N'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentAvailabilitySection() {
    final equipment = [
      {'name': 'Sphygmomanometer', 'key': 'sphygmomanometer'},
      {'name': 'Weighing Scale', 'key': 'weighing_scale'},
      {'name': 'Measuring Tape', 'key': 'measuring_tape'},
      {'name': 'Peak Expiratory Flow Meter', 'key': 'peak_expiratory_flow_meter'},
      {'name': 'Oxygen', 'key': 'oxygen'},
      {'name': 'Oxygen mask', 'key': 'oxygen_mask'},
      {'name': 'Nebulizer', 'key': 'nebulizer'},
      {'name': 'Pulse oximetry', 'key': 'pulse_oximetry'},
      {'name': 'Glucometer', 'key': 'glucometer'},
      {'name': 'Glucometer strips', 'key': 'glucometer_strips'},
      {'name': 'Lancets', 'key': 'lancets'},
      {'name': 'Urine dipstick', 'key': 'urine_dipstick'},
      {'name': 'ECG', 'key': 'ecg'},
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
        const SizedBox(height: 8),
        ...equipment.map((item) => _buildEquipmentRow(item['name']!, item['key']!)),
      ],
    );
  }

  Widget _buildEquipmentRow(String equipment, String key) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(equipment),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Radio<String>(
                  value: 'Y',
                  groupValue: _equipment[key],
                  onChanged: (value) {
                    setState(() {
                      _equipment[key] = value;
                    });
                  },
                ),
                const Text('Y'),
                Radio<String>(
                  value: 'N',
                  groupValue: _equipment[key],
                  onChanged: (value) {
                    setState(() {
                      _equipment[key] = value;
                    });
                  },
                ),
                const Text('N'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceStandardsSection() {
    final standards = [
      {'name': 'Blood pressure measurement of all clients above 40 y/o and people at risk (as per leaflet), at every visit', 'key': 'c2_blood_pressure'},
      {'name': 'Blood sugar measurement of all clients above 40 y/o and patients at risk (as per leaflet) at first visit, then each visit when diabetic patients comes', 'key': 'c2_blood_sugar'},
      {'name': 'BMI measurement at every visit (weight measurement)', 'key': 'c2_bmi_measurement'},
      {'name': 'Waist circumference measurement at every visit', 'key': 'c2_waist_circumference'},
      {'name': 'CVD risk estimation for all patients above 40 y/o', 'key': 'c2_cvd_risk_estimation'},
      {'name': 'Urine protein measurement of all clients above 40 y/o and at risk (leaflet). Then every 6 months for people with CKD, diabetes, hypertension', 'key': 'c2_urine_protein_measurement'},
      {'name': 'Peak Expiratory Flow Rate of COPD and asthmatic clients at every visit', 'key': 'c2_peak_expiratory_flow_rate'},
      {'name': 'eGFR calculation for all people at risk (according to leaflet)', 'key': 'c2_egfr_calculation'},
      {'name': 'Brief intervention using 5A and 5R for tobacco cessation, unhealthy diet, alcohol intake and physical inactivity at every visit', 'key': 'c2_brief_intervention'},
      {'name': 'Foot examination once every year for Diabetes', 'key': 'c2_foot_examination'},
      {'name': 'Oral examination at every visit', 'key': 'c2_oral_examination'},
      {'name': 'Counseling for eye examination once every year', 'key': 'c2_eye_examination'},
      {'name': 'Health education for foot care advice at every visit', 'key': 'c2_health_education'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...standards.map((standard) => _buildStandardRow(standard['name']!, standard['key']!)),
      ],
    );
  }

  Widget _buildStandardRow(String standard, String key) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              standard,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Radio<String>(
                  value: 'Y',
                  groupValue: _serviceStandards[key],
                  onChanged: (value) {
                    setState(() {
                      _serviceStandards[key] = value;
                    });
                  },
                ),
                const Text('Y'),
                Radio<String>(
                  value: 'N',
                  groupValue: _serviceStandards[key],
                  onChanged: (value) {
                    setState(() {
                      _serviceStandards[key] = value;
                    });
                  },
                ),
                const Text('N'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _visitDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    
    if (date != null) {
      setState(() {
        _visitDate = date;
      });
    }
  }

  Future<bool> _confirmDiscard() async {
    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('If you go back now, your entered data will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep editing'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return shouldDiscard ?? false;
  }

  Future<bool> _checkCanLeave() async {
    final hasInput = _recommendationsController.text.trim().isNotEmpty ||
        _actionsAgreedController.text.trim().isNotEmpty ||
        _adminManagement.isNotEmpty ||
        _logistics.isNotEmpty ||
        _equipment.isNotEmpty ||
        _mhdcManagement.isNotEmpty ||
        _serviceStandards.isNotEmpty ||
        _healthInformation.isNotEmpty ||
        _integration.isNotEmpty;
    if (!hasInput) return true;
    return await _confirmDiscard();
  }

  void _handleNextOrSave() {
    if (_tabController.index < 7) {
      _tabController.animateTo(_tabController.index + 1);
    } else {
      _createVisit();
    }
  }

  Future<void> _createVisit() async {
    if (_visitDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a visit date'),
          backgroundColor: Colors.red,
        ),
      );
      _tabController.animateTo(0);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Clean up data - remove null values and empty strings
      final cleanedData = <String, Map<String, dynamic>>{
        'adminManagement': _cleanSectionData(_adminManagement),
        'logistics': _cleanSectionData(_logistics),
        'equipment': _cleanSectionData(_equipment),
        'mhdcManagement': _cleanSectionData(_mhdcManagement),
        'serviceStandards': _cleanSectionData(_serviceStandards),
        'healthInformation': _cleanSectionData(_healthInformation),
        'integration': _cleanSectionData(_integration),
      };

      final success = await ref.read(formsProvider.notifier).createVisit(
        formId: widget.formId,
        visitNumber: widget.visitNumber,
        visitDate: _visitDate!,
        recommendations: _recommendationsController.text.trim().isNotEmpty
            ? _recommendationsController.text.trim()
            : null,
        actionsAgreed: _actionsAgreedController.text.trim().isNotEmpty
            ? _actionsAgreedController.text.trim()
            : null,
        adminManagement: cleanedData['adminManagement']!.isNotEmpty 
            ? cleanedData['adminManagement'] : null,
        logistics: cleanedData['logistics']!.isNotEmpty 
            ? cleanedData['logistics'] : null,
        equipment: cleanedData['equipment']!.isNotEmpty 
            ? cleanedData['equipment'] : null,
        mhdcManagement: cleanedData['mhdcManagement']!.isNotEmpty 
            ? cleanedData['mhdcManagement'] : null,
        serviceStandards: cleanedData['serviceStandards']!.isNotEmpty 
            ? cleanedData['serviceStandards'] : null,
        healthInformation: cleanedData['healthInformation']!.isNotEmpty 
            ? cleanedData['healthInformation'] : null,
        integration: cleanedData['integration']!.isNotEmpty 
            ? cleanedData['integration'] : null,
      );

      if (success && mounted) {
        Navigator.pop(context, true); // Return true to indicate successful creation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Visit ${widget.visitNumber} created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating visit: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Map<String, dynamic> _cleanSectionData(Map<String, dynamic> data) {
    final cleaned = <String, dynamic>{};
    data.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) {
        cleaned[key] = value;
      }
    });
    return cleaned;
  }
}