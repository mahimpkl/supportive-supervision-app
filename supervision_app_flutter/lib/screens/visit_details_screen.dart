import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/forms_provider.dart';
import '../models/supervision_visit.dart';

class VisitDetailsScreen extends ConsumerStatefulWidget {
  final int visitId;
  final SupervisionVisit visit;

  const VisitDetailsScreen({
    super.key,
    required this.visitId,
    required this.visit,
  });

  @override
  ConsumerState<VisitDetailsScreen> createState() => _VisitDetailsScreenState();
}

class _VisitDetailsScreenState extends ConsumerState<VisitDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  SupervisionVisit? _visitDetails;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this);
    _loadVisitDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadVisitDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final details = await ref.read(formsProvider.notifier).getVisitDetails(widget.visitId);
      if (mounted) {
        setState(() {
          _visitDetails = details;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading visit details: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Visit ${widget.visit.visitNumber} Details'),
        elevation: 0,
        actions: [
          if (_visitDetails?.syncStatus == 'local')
            IconButton(
              onPressed: _canEditVisit() ? _editVisit : null,
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Visit',
            ),
          if (_visitDetails?.syncStatus == 'local')
            IconButton(
              onPressed: _canDeleteVisit() ? _deleteVisit : null,
              icon: const Icon(Icons.delete),
              tooltip: 'Delete Visit',
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Summary'),
            Tab(text: 'Admin'),
            Tab(text: 'Logistics'),
            Tab(text: 'Equipment'),
            Tab(text: 'MHDC'),
            Tab(text: 'Service'),
            Tab(text: 'Health Info'),
            Tab(text: 'Integration'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _visitDetails == null
              ? const Center(child: Text('Visit details not found'))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildSummaryTab(),
                    _buildAdminManagementTab(),
                    _buildLogisticsTab(),
                    _buildEquipmentTab(),
                    _buildMhdcManagementTab(),
                    _buildServiceStandardsTab(),
                    _buildHealthInformationTab(),
                    _buildIntegrationTab(),
                  ],
                ),
    );
  }

  bool _canEditVisit() {
    return _visitDetails?.syncStatus == 'local';
  }

  bool _canDeleteVisit() {
    return _visitDetails?.syncStatus == 'local';
  }

  Widget _buildSummaryTab() {
    final visit = _visitDetails!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: _getStatusColor(visit.syncStatus),
                        child: Text(
                          visit.visitNumber.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Visit ${visit.visitNumber}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Date: ${_formatDate(visit.visitDate)}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      _buildSyncStatusChip(visit.syncStatus),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (visit.recommendations?.isNotEmpty == true) ...[
                    const Text(
                      'Recommendations',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(visit.recommendations!),
                    const SizedBox(height: 12),
                  ],
                  if (visit.actionsAgreed?.isNotEmpty == true) ...[
                    const Text(
                      'Actions Agreed',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(visit.actionsAgreed!),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Completion Summary
          _buildCompletionSummary(),
          const SizedBox(height: 16),

          // Section Quick Overview
          _buildSectionOverview(),
        ],
      ),
    );
  }

  Widget _buildCompletionSummary() {
    final visit = _visitDetails!;
    int completedSections = 0;
    const totalSections = 7;

    if (visit.adminManagement != null) completedSections++;
    if (visit.logistics != null) completedSections++;
    if (visit.equipment != null) completedSections++;
    if (visit.mhdcManagement != null) completedSections++;
    if (visit.serviceStandards != null) completedSections++;
    if (visit.healthInformation != null) completedSections++;
    if (visit.integration != null) completedSections++;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Completion Status',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Sections Completed'),
                          Text('$completedSections/$totalSections'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: completedSections / totalSections,
                        backgroundColor: Colors.grey[300],
                        color: completedSections == totalSections ? Colors.green : Colors.blue,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionOverview() {
    final visit = _visitDetails!;
    final sections = [
      {
        'name': 'Administrative Management',
        'data': visit.adminManagement,
        'icon': Icons.admin_panel_settings,
      },
      {
        'name': 'Logistics & Medicines',
        'data': visit.logistics,
        'icon': Icons.medical_services,
      },
      {
        'name': 'Equipment',
        'data': visit.equipment,
        'icon': Icons.devices,
      },
      {
        'name': 'MHDC Management',
        'data': visit.mhdcManagement,
        'icon': Icons.health_and_safety,
      },
      {
        'name': 'Service Standards',
        'data': visit.serviceStandards,
        'icon': Icons.verified,
      },
      {
        'name': 'Health Information',
        'data': visit.healthInformation,
        'icon': Icons.info,
      },
      {
        'name': 'Integration',
        'data': visit.integration,
        'icon': Icons.integration_instructions,
      },
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Section Overview',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...sections.map((section) => _buildSectionOverviewItem(
                  section['name'] as String,
                  section['data'] != null,
                  section['icon'] as IconData,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionOverviewItem(String name, bool hasData, IconData icon) {
    final responseCount = hasData ? 1 : 0; // Simplified since we now have typed models

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: hasData ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(name),
          ),
          if (hasData) ...[
            Text(
              '$responseCount responses',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Icon(Icons.check_circle, color: Colors.green, size: 16),
          ] else ...[
            const Text(
              'No data',
              style: TextStyle(color: Colors.grey),
            ),
            const Icon(Icons.radio_button_unchecked, color: Colors.grey, size: 16),
          ],
        ],
      ),
    );
  }

  // Removed _countResponses method as it's no longer needed with typed models

  Widget _buildAdminManagementTab() {
    final data = _visitDetails?.adminManagement;
    if (data == null) {
      return _buildSectionDetailTab('Administrative Management', []);
    }
    
    final dataMap = data.toJson();
    return _buildSectionDetailTab(
      'Administrative Management',
      [
        _buildResponseItem('A1. Health Facility Operation and Management Committee provision', 'a1_response', 'a1_comment', dataMap),
        _buildResponseItem('A2. Committee discusses NCD service provisions in regular meetings', 'a2_response', 'a2_comment', dataMap),
        _buildResponseItem('A3. Health facility discusses quarterly NCD services with MHDC team', 'a3_response', 'a3_comment', dataMap),
      ],
    );
  }

  Widget _buildLogisticsTab() {
    final data = _visitDetails?.logistics;
    if (data == null) {
      return _buildSectionDetailTab('Logistics & Medicines', []);
    }
    
    final dataMap = data.toJson();
    
    // Medicine availability data - complete list matching LogisticsSection
    final medicines = [
      // Antihypertensives
      {'name': 'Amlodipine 5/10mg', 'key': 'amlodipine_5_10mg'},
      {'name': 'Enalapril 2.5/5/10mg', 'key': 'enalapril_2_5_10mg'},
      {'name': 'Losartan 25/50mg', 'key': 'losartan_25_50mg'},
      {'name': 'Hydrochlorothiazide 12.5/25mg', 'key': 'hydrochlorothiazide_12_5_25mg'},
      {'name': 'Chlorthalidone 6.25/12.5mg', 'key': 'chlorthalidone_6_25_12_5mg'},
      {'name': 'Other Antihypertensives', 'key': 'other_antihypertensives'},
      
      // Statins
      {'name': 'Atorvastatin 5mg', 'key': 'atorvastatin_5mg'},
      {'name': 'Atorvastatin 10mg', 'key': 'atorvastatin_10mg'},
      {'name': 'Atorvastatin 20mg', 'key': 'atorvastatin_20mg'},
      {'name': 'Other Statins', 'key': 'other_statins'},
      
      // Diabetes medications
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
      
      // Antiplatelet and Cardiovascular
      {'name': 'Aspirin 75mg', 'key': 'aspirin_75mg'},
      {'name': 'Clopidogrel 75mg', 'key': 'clopidogrel_75mg'},
      {'name': 'Metoprolol Succinate 12.5/25/50mg', 'key': 'metoprolol_succinate_12_5_25_50mg'},
      {'name': 'Isosorbide Dinitrate 5mg', 'key': 'isosorbide_dinitrate_5mg'},
      {'name': 'Other Drugs', 'key': 'other_drugs'},
      
      // Antibiotics
      {'name': 'Amoxicillin + Clavulanic Potassium 625mg', 'key': 'amoxicillin_clavulanic_potassium_625mg'},
      {'name': 'Azithromycin 500mg', 'key': 'azithromycin_500mg'},
      {'name': 'Other Antibiotics', 'key': 'other_antibiotics'},
      
      // Respiratory medications
      {'name': 'Salbutamol DPI', 'key': 'salbutamol_dpi'},
      {'name': 'Salbutamol', 'key': 'salbutamol'},
      {'name': 'Ipratropium', 'key': 'ipratropium'},
      {'name': 'Tiotropium Bromide', 'key': 'tiotropium_bromide'},
      {'name': 'Formoterol', 'key': 'formoterol'},
      {'name': 'Other Bronchodilators', 'key': 'other_bronchodilators'},
      
      // Steroids
      {'name': 'Prednisolone 5-10-20mg', 'key': 'prednisolone_5_10_20mg'},
      {'name': 'Other Steroids (Oral)', 'key': 'other_steroids_oral'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Medicine Availability Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Medicine Availability (B1)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Header row
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Text(
                            'Medicine',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Available',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Quantity',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...medicines.map((medicine) => _buildMedicineAvailabilityItemWithQuantity(
                      medicine['name']!,
                      medicine['key']!,
                      dataMap[medicine['key']] as String?,
                      dataMap,
                    )),
                  if (dataMap['b1_comment']?.isNotEmpty == true) ...[
                    const SizedBox(height: 12),
                    _buildCommentSection('B1 Comments', dataMap['b1_comment'] as String),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),


          // Other Logistics Questions
          _buildSectionDetailTab(
            'Logistics Questions',
            [
              _buildResponseItem('B2. Blood glucometer functioning and in use', 'b2_response', 'b2_comment', dataMap),
              _buildResponseItem('B3. Medicine expiry dates verified', 'b3_response', 'b3_comment', dataMap),
              _buildResponseItem('B4. Medicine storage conditions verified', 'b4_response', 'b4_comment', dataMap),
              _buildResponseItem('B5. Medicine stock management system in place', 'b5_response', 'b5_comment', dataMap),
            ],
          ),

          // Additional Validation Information
          if (dataMap['b2_validation_note'] != null || 
              dataMap['b3_validation_note'] != null || 
              dataMap['b4_validation_note'] != null || 
              dataMap['b5_validation_note'] != null) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Validation Notes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (dataMap['b2_validation_note'] != null)
                      _buildCommentSection('B2 Validation', dataMap['b2_validation_note'] as String),
                    if (dataMap['b3_validation_note'] != null) ...[
                      const SizedBox(height: 8),
                      _buildCommentSection('B3 Validation', dataMap['b3_validation_note'] as String),
                    ],
                    if (dataMap['b4_validation_note'] != null) ...[
                      const SizedBox(height: 8),
                      _buildCommentSection('B4 Validation', dataMap['b4_validation_note'] as String),
                    ],
                    if (dataMap['b5_validation_note'] != null) ...[
                      const SizedBox(height: 8),
                      _buildCommentSection('B5 Validation', dataMap['b5_validation_note'] as String),
                    ],
                  ],
                ),
              ),
            ),
          ],

          // Storage and Expiry Verification
          if (dataMap['expiry_dates_checked'] != null || 
              dataMap['storage_conditions_verified'] != null) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quality Checks',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (dataMap['expiry_dates_checked'] != null)
                      _buildBooleanDetailRow('Expiry Dates Checked', dataMap['expiry_dates_checked'] as bool),
                    if (dataMap['storage_conditions_verified'] != null)
                      _buildBooleanDetailRow('Storage Conditions Verified', dataMap['storage_conditions_verified'] as bool),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEquipmentTab() {
    final data = _visitDetails?.equipment;
    if (data == null) {
      return _buildSectionDetailTab('Equipment', []);
    }
    
    final dataMap = data.toJson();
    
    // Equipment functionality items matching the equipment section widget
    final equipmentFunctionality = [
      {'name': 'Peak expiratory flow meter', 'key': 'peak_expiratory_flow_meter'},
      {'name': 'Weighing scale', 'key': 'weighing_scale'},
      {'name': 'Sphygmomanometer', 'key': 'sphygmomanometer'},
      {'name': 'Glucometer', 'key': 'glucometer'},
    ];

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
                    'Equipment Functionality',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Equipment functionality and calibration status:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Header row for equipment functionality table
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      children: [
                        Expanded(flex: 3, child: Text('Equipment', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                        Expanded(flex: 2, child: Text('Calibrated/Functional', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13), textAlign: TextAlign.center)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...equipmentFunctionality.map((equipment) => _buildEquipmentFunctionalityItem(
                        equipment['name']!,
                        equipment['key']!,
                        dataMap[equipment['key']] as String?,
                      )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionDetailTab(
            'Equipment Related Questions',
            [
              _buildResponseItem('B3. Urine protein strips used', 'b3_response', 'b3_comment', dataMap),
              _buildResponseItem('B4. Urine ketone strips used', 'b4_response', 'b4_comment', dataMap),
              _buildResponseItem('B5. Essential equipment available and functional', 'b5_response', 'b5_comment', dataMap),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMhdcManagementTab() {
    final data = _visitDetails?.mhdcManagement;
    if (data == null) {
      return _buildSectionDetailTab('MHDC Management', []);
    }
    
    final dataMap = data.toJson();
    return _buildSectionDetailTab(
      'MHDC Management',
      [
        _buildResponseItem('B6. MHDC NCD management leaflets available for Healthcare workers', 'b6_response', 'b6_comment', dataMap),
        _buildResponseItem('B7. MHDC awareness and patient education materials available', 'b7_response', 'b7_comment', dataMap),
        _buildResponseItem('B8. NCD register available and filled properly', 'b8_response', 'b8_comment', dataMap),
        _buildResponseItem('B9. WHO-ISH CVD Risk Prediction Chart available for patient care', 'b9_response', 'b9_comment', dataMap),
        _buildResponseItem('B10. WHO-ISH CVD Risk Prediction Chart in use for patient care', 'b10_response', 'b10_comment', dataMap),
      ],
    );
  }

  Widget _buildServiceStandardsTab() {
    final data = _visitDetails?.serviceStandards;
    if (data == null) {
      return _buildSectionDetailTab('Service Standards', []);
    }
    
    final dataMap = data.toJson();
    
    // C1 Service provision items matching the service standards section widget
    final serviceProvision = [
      {'name': 'Hypertension screening and management', 'key': 'c1_hypertension'},
      {'name': 'Diabetes screening and management', 'key': 'c1_diabetes'},
      {'name': 'COPD/Asthma screening and management', 'key': 'c1_copd_asthma'},
      {'name': 'CVD risk assessment and management', 'key': 'c1_cvd_risk'},
      {'name': 'Tobacco cessation counseling', 'key': 'c1_tobacco_cessation'},
      {'name': 'Alcohol cessation counseling', 'key': 'c1_alcohol_cessation'},
      {'name': 'Dietary counseling', 'key': 'c1_dietary_counseling'},
      {'name': 'Physical activity counseling', 'key': 'c1_physical_activity'},
    ];
    
    // C2 PEN Protocol standards
    final penProtocolStandards = [
      {'name': 'Blood pressure measurement of all clients above 40 y/o and people at risk', 'key': 'c2_blood_pressure'},
      {'name': 'Blood sugar measurement of all clients above 40 y/o and patients at risk', 'key': 'c2_blood_sugar'},
      {'name': 'BMI measurement at every visit (weight measurement)', 'key': 'c2_bmi_measurement'},
      {'name': 'Waist circumference measurement at every visit', 'key': 'c2_waist_circumference'},
      {'name': 'CVD risk estimation for all patients above 40 y/o', 'key': 'c2_cvd_risk_estimation'},
      {'name': 'Urine protein measurement of all clients above 40 y/o and at risk', 'key': 'c2_urine_protein_measurement'},
      {'name': 'Peak Expiratory Flow Rate of COPD and asthmatic clients at every visit', 'key': 'c2_peak_expiratory_flow_rate'},
      {'name': 'eGFR calculation for all people at risk', 'key': 'c2_egfr_calculation'},
      {'name': 'Brief intervention using 5A and 5R for tobacco cessation, unhealthy diet, alcohol intake and physical inactivity', 'key': 'c2_brief_intervention'},
      {'name': 'Foot examination once every year for Diabetes', 'key': 'c2_foot_examination'},
      {'name': 'Oral examination at every visit', 'key': 'c2_oral_examination'},
      {'name': 'Counseling for eye examination once every year', 'key': 'c2_eye_examination'},
      {'name': 'Health education for foot care advice at every visit', 'key': 'c2_health_education'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // C1 Service Provision Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'C1. NCD Services Provided at Health Facility',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Header row for service provision table
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      children: [
                        Expanded(flex: 3, child: Text('Service', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                        Expanded(flex: 2, child: Text('Provided', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13), textAlign: TextAlign.center)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...serviceProvision.map((service) => _buildServiceStandardItem(
                        service['name']!,
                        dataMap[service['key']] as String?,
                      )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // C2 PEN Protocol Standards Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'C2. NCD Services as per PEN Protocol and Standards',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Header row for PEN protocol table
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      children: [
                        Expanded(flex: 3, child: Text('Standard/Protocol', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                        Expanded(flex: 2, child: Text('Followed', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13), textAlign: TextAlign.center)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...penProtocolStandards.map((standard) => _buildServiceStandardItem(
                        standard['name']!,
                        dataMap[standard['key']] as String?,
                      )),
                  if (dataMap['c2_main_comment']?.isNotEmpty == true) ...[
                    const SizedBox(height: 12),
                    _buildCommentSection('C2 Main Comments', dataMap['c2_main_comment'] as String),
                  ],
                  if (dataMap['c2_respondents_comment']?.isNotEmpty == true) ...[
                    const SizedBox(height: 8),
                    _buildCommentSection('C2 Respondent Comments', dataMap['c2_respondents_comment'] as String),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // C3-C7 Additional Service Standards
          _buildSectionDetailTab(
            'Additional Service Standards (C3-C7)',
            [
              _buildResponseItem('C3. Examination room allows confidentiality', 'c3_response', 'c3_comment', dataMap),
              _buildResponseItem('C4. NCD services provided to home bound patients', 'c4_response', 'c4_comment', dataMap),
              _buildResponseItem('C5. Community based NCD care provided', 'c5_response', 'c5_comment', dataMap),
              _buildResponseItem('C6. School-based program for NCD prevention conducted', 'c6_response', 'c6_comment', dataMap),
              _buildResponseItem('C7. Patient tracking mechanism for NCD patients', 'c7_response', 'c7_comment', dataMap),
              if (dataMap['actions_agreed']?.isNotEmpty == true)
                _buildResponseItem('Actions Agreed', '', 'actions_agreed', dataMap),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthInformationTab() {
    final data = _visitDetails?.healthInformation;
    if (data == null) {
      return _buildSectionDetailTab('Health Information', []);
    }
    
    final dataMap = data.toJson();
    return _buildSectionDetailTab(
      'Health Information',
      [
        _buildResponseItem('D1. NCD OPD register regularly updated and completed', 'd1_response', 'd1_comment', dataMap),
        _buildResponseItem('D2. NCD dashboard displayed with updated information', 'd2_response', 'd2_comment', dataMap),
        _buildResponseItem('D3. Monthly Reporting Form sent to concerned authority', 'd3_response', 'd3_comment', dataMap),
        _buildResponseItem('D4. Number of people sought NCD services in previous month', 'd4_response', 'd4_comment', dataMap),
        _buildResponseItem('D5. Dedicated healthcare worker assigned for NCD services', 'd5_response', 'd5_comment', dataMap),
      ],
    );
  }

  Widget _buildIntegrationTab() {
    final data = _visitDetails?.integration;
    if (data == null) {
      return _buildSectionDetailTab('Integration of NCD Services', []);
    }
    
    final dataMap = data.toJson();
    return _buildSectionDetailTab(
      'Integration of NCD Services',
      [
        _buildResponseItem('E1. Health Workers aware of PEN programme purpose', 'e1_response', 'e1_comment', dataMap),
        _buildResponseItem('E2. Health education on lifestyle factors provided', 'e2_response', 'e2_comment', dataMap),
        _buildResponseItem('E3. Screening for raised blood pressure and sugar provided', 'e3_response', 'e3_comment', dataMap),
      ],
    );
  }

  Widget _buildSectionDetailTab(String title, List<Widget> items) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (items.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No data available',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This section was not filled during the visit',
                        style: TextStyle(
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            ...items,
        ],
      ),
    );
  }

  Widget _buildResponseItem(String question, String responseKey, String commentKey, Map<String, dynamic> data) {
    final response = data[responseKey] as String?;
    final comment = data[commentKey] as String?;
    
    if (response == null && (comment == null || comment.isEmpty)) {
      return const SizedBox(); // Don't show empty responses
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            if (response != null) ...[
              Row(
                children: [
                  const Text('Response: ', style: TextStyle(fontWeight: FontWeight.w500)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getResponseColor(response),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getResponseText(response),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (comment != null && comment.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildCommentSection('Comments', comment),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineAvailabilityItemWithQuantity(String medicine, String key, String? availability, Map<String, dynamic> dataMap) {
    if (availability == null) return const SizedBox();

    final quantityKey = '${key}_quantity';
    final unitsKey = '${key}_units';
    final quantity = dataMap[quantityKey];
    final units = dataMap[unitsKey];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(medicine),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getResponseColor(availability),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getResponseText(availability),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: quantity != null && availability == 'Y' 
                ? Text(
                    '$quantity ${units ?? 'units'}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.green,
                    ),
                    textAlign: TextAlign.center,
                  )
                : const Text(
                    '-',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentFunctionalityItem(String equipment, String key, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              equipment,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getResponseColor(value ?? 'N/A'),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getResponseText(value ?? 'N/A'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceStandardItem(String standard, String? status) {
    if (status == null) return const SizedBox();

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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _getResponseColor(status),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getResponseText(status),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentSection(String title, String comment) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(comment),
        ],
      ),
    );
  }

  Widget _buildSyncStatusChip(String syncStatus) {
    Color color;
    String label;
    IconData icon;

    switch (syncStatus) {
      case 'local':
        color = Colors.orange;
        label = 'Not Synced';
        icon = Icons.cloud_upload;
        break;
      case 'synced':
        color = Colors.blue;
        label = 'Synced';
        icon = Icons.cloud_done;
        break;
      case 'verified':
        color = Colors.green;
        label = 'Verified';
        icon = Icons.verified;
        break;
      default:
        color = Colors.grey;
        label = 'Unknown';
        icon = Icons.help;
    }

    return Chip(
      avatar: Icon(icon, size: 16, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
    );
  }

  Color _getStatusColor(String syncStatus) {
    switch (syncStatus) {
      case 'local':
        return Colors.orange;
      case 'synced':
        return Colors.blue;
      case 'verified':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getResponseColor(String response) {
    switch (response.toUpperCase()) {
      case 'Y':
        return Colors.green;
      case 'N':
        return Colors.red;
      case 'NA':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  String _getResponseText(String response) {
    switch (response.toUpperCase()) {
      case 'Y':
        return 'YES';
      case 'N':
        return 'NO';
      case 'NA':
        return 'N/A';
      default:
        return response.toUpperCase();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _editVisit() {
    // TODO: Implement visit editing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Visit editing - Coming soon'),
      ),
    );
  }


  Widget _buildBooleanDetailRow(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: value ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value ? 'YES' : 'NO',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteVisit() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Visit'),
        content: Text('Are you sure you want to delete Visit ${widget.visit.visitNumber}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              
              final success = await ref.read(formsProvider.notifier).deleteVisit(widget.visitId);
              
              if (context.mounted) {
                if (success) {
                  Navigator.pop(context, true); // Return to previous screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Visit deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to delete visit'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}