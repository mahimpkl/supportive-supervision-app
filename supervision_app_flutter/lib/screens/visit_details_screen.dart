import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/forms_provider.dart';
import '../models/supervision_form_model.dart';

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
            Tab(text: 'Standards'),
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

    if (visit.adminManagement?.isNotEmpty == true) completedSections++;
    if (visit.logistics?.isNotEmpty == true) completedSections++;
    if (visit.equipment?.isNotEmpty == true) completedSections++;
    if (visit.mhdcManagement?.isNotEmpty == true) completedSections++;
    if (visit.serviceStandards?.isNotEmpty == true) completedSections++;
    if (visit.healthInformation?.isNotEmpty == true) completedSections++;
    if (visit.integration?.isNotEmpty == true) completedSections++;

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
                  section['data'] as Map<String, dynamic>?,
                  section['icon'] as IconData,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionOverviewItem(String name, Map<String, dynamic>? data, IconData icon) {
    final hasData = data?.isNotEmpty == true;
    final responseCount = hasData ? _countResponses(data!) : 0;

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

  int _countResponses(Map<String, dynamic> data) {
    return data.values.where((value) => 
        value != null && 
        value.toString().isNotEmpty && 
        !['created_at', 'updated_at', 'visit_id', 'id'].contains(value)
    ).length;
  }

  Widget _buildAdminManagementTab() {
    final data = _visitDetails?.adminManagement ?? {};
    return _buildSectionDetailTab(
      'Administrative Management',
      [
        _buildResponseItem('A1. Health Facility Operation and Management Committee provision', 'a1_response', 'a1_comment', data),
        _buildResponseItem('A2. Committee discusses NCD service provisions in regular meetings', 'a2_response', 'a2_comment', data),
        _buildResponseItem('A3. Health facility discusses quarterly NCD services with MHDC team', 'a3_response', 'a3_comment', data),
      ],
    );
  }

  Widget _buildLogisticsTab() {
    final data = _visitDetails?.logistics ?? {};
    
    // Medicine availability data
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
                  ...medicines.map((medicine) => _buildMedicineAvailabilityItem(
                        medicine['name']!,
                        data[medicine['key']] as String?,
                      )),
                  if (data['b1_comment']?.isNotEmpty == true) ...[
                    const SizedBox(height: 12),
                    _buildCommentSection('B1 Comments', data['b1_comment'] as String),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Other Logistics Questions
          _buildSectionDetailTab(
            'Other Logistics',
            [
              _buildResponseItem('B2. Blood glucometer functioning and in use', 'b2_response', 'b2_comment', data),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentTab() {
    final data = _visitDetails?.equipment ?? {};
    
    final equipment = [
      {'name': 'Sphygmomanometer', 'key': 'sphygmomanometer'},
      {'name': 'Weighing Scale', 'key': 'weighing_scale'},
      {'name': 'Measuring Tape', 'key': 'measuring_tape'},
      {'name': 'Peak Expiratory Flow Meter', 'key': 'peak_expiratory_flow_meter'},
      {'name': 'Oxygen', 'key': 'oxygen'},
      {'name': 'Oxygen Mask', 'key': 'oxygen_mask'},
      {'name': 'Nebulizer', 'key': 'nebulizer'},
      {'name': 'Pulse Oximetry', 'key': 'pulse_oximetry'},
      {'name': 'Glucometer', 'key': 'glucometer'},
      {'name': 'Glucometer Strips', 'key': 'glucometer_strips'},
      {'name': 'Lancets', 'key': 'lancets'},
      {'name': 'Urine Dipstick', 'key': 'urine_dipstick'},
      {'name': 'ECG', 'key': 'ecg'},
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
                    'Equipment Availability (B5)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...equipment.map((item) => _buildEquipmentAvailabilityItem(
                        item['name']!,
                        data[item['key']] as String?,
                      )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionDetailTab(
            'Equipment Related Questions',
            [
              _buildResponseItem('B3. Urine protein strips used', 'b3_response', 'b3_comment', data),
              _buildResponseItem('B4. Urine ketone strips used', 'b4_response', 'b4_comment', data),
              _buildResponseItem('B5. Essential equipment available and functional', 'b5_response', 'b5_comment', data),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMhdcManagementTab() {
    final data = _visitDetails?.mhdcManagement ?? {};
    return _buildSectionDetailTab(
      'MHDC Management',
      [
        _buildResponseItem('B6. MHDC NCD management leaflets available for Healthcare workers', 'b6_response', 'b6_comment', data),
        _buildResponseItem('B7. MHDC awareness and patient education materials available', 'b7_response', 'b7_comment', data),
        _buildResponseItem('B8. NCD register available and filled properly', 'b8_response', 'b8_comment', data),
        _buildResponseItem('B9. WHO-ISH CVD Risk Prediction Chart available for patient care', 'b9_response', 'b9_comment', data),
        _buildResponseItem('B10. WHO-ISH CVD Risk Prediction Chart in use for patient care', 'b10_response', 'b10_comment', data),
      ],
    );
  }

  Widget _buildServiceStandardsTab() {
    final data = _visitDetails?.serviceStandards ?? {};
    
    final standards = [
      {'name': 'Blood pressure measurement', 'key': 'c2_blood_pressure'},
      {'name': 'Blood sugar measurement', 'key': 'c2_blood_sugar'},
      {'name': 'BMI measurement', 'key': 'c2_bmi_measurement'},
      {'name': 'Waist circumference measurement', 'key': 'c2_waist_circumference'},
      {'name': 'CVD risk estimation', 'key': 'c2_cvd_risk_estimation'},
      {'name': 'Urine protein measurement', 'key': 'c2_urine_protein_measurement'},
      {'name': 'Peak Expiratory Flow Rate', 'key': 'c2_peak_expiratory_flow_rate'},
      {'name': 'eGFR calculation', 'key': 'c2_egfr_calculation'},
      {'name': 'Brief intervention', 'key': 'c2_brief_intervention'},
      {'name': 'Foot examination', 'key': 'c2_foot_examination'},
      {'name': 'Oral examination', 'key': 'c2_oral_examination'},
      {'name': 'Eye examination counseling', 'key': 'c2_eye_examination'},
      {'name': 'Health education', 'key': 'c2_health_education'},
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
                    'NCD Service Standards (C2)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...standards.map((standard) => _buildServiceStandardItem(
                        standard['name']!,
                        data[standard['key']] as String?,
                      )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionDetailTab(
            'Other Service Standards',
            [
              _buildResponseItem('C3. Examination room allows confidentiality', 'c3_response', 'c3_comment', data),
              _buildResponseItem('C4. NCD services provided to home bound patients', 'c4_response', 'c4_comment', data),
              _buildResponseItem('C5. Community based NCD care provided', 'c5_response', 'c5_comment', data),
              _buildResponseItem('C6. School-based program for NCD prevention conducted', 'c6_response', 'c6_comment', data),
              _buildResponseItem('C7. Patient tracking mechanism for NCD patients', 'c7_response', 'c7_comment', data),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthInformationTab() {
    final data = _visitDetails?.healthInformation ?? {};
    return _buildSectionDetailTab(
      'Health Information',
      [
        _buildResponseItem('D1. NCD OPD register regularly updated and completed', 'd1_response', 'd1_comment', data),
        _buildResponseItem('D2. NCD dashboard displayed with updated information', 'd2_response', 'd2_comment', data),
        _buildResponseItem('D3. Monthly Reporting Form sent to concerned authority', 'd3_response', 'd3_comment', data),
        _buildResponseItem('D4. Number of people sought NCD services in previous month', 'd4_response', 'd4_comment', data),
        _buildResponseItem('D5. Dedicated healthcare worker assigned for NCD services', 'd5_response', 'd5_comment', data),
      ],
    );
  }

  Widget _buildIntegrationTab() {
    final data = _visitDetails?.integration ?? {};
    return _buildSectionDetailTab(
      'Integration of NCD Services',
      [
        _buildResponseItem('E1. Health Workers aware of PEN programme purpose', 'e1_response', 'e1_comment', data),
        _buildResponseItem('E2. Health education on lifestyle factors provided', 'e2_response', 'e2_comment', data),
        _buildResponseItem('E3. Screening for raised blood pressure and sugar provided', 'e3_response', 'e3_comment', data),
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

  Widget _buildMedicineAvailabilityItem(String medicine, String? availability) {
    if (availability == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(medicine),
          ),
          Container(
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentAvailabilityItem(String equipment, String? availability) {
    if (availability == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(equipment),
          ),
          Container(
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
              // TODO: Implement visit deletion
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Visit deletion - Coming soon'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}