import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/forms_provider.dart';
import '../models/supervision_form_model.dart';
import '../models/supervision_visit.dart';
import '../models/admin_management_data.dart';
import '../models/logistics_data.dart';
import '../models/equipment_data.dart';
import '../models/khdc_management_data.dart';
import '../models/service_standards_data.dart';
import '../models/health_information_data.dart';
import '../models/integration_data.dart';
import '../models/staff_training_data.dart';
import '../widgets/visit_sections/admin_management_section.dart';
import '../widgets/visit_sections/logistics_section.dart';
import '../widgets/visit_sections/equipment_section.dart';
// import '../widgets/visit_sections/khdc_management_section.dart';
import '../widgets/visit_sections/service_standards_section.dart';
import '../widgets/visit_sections/health_information_section.dart';
import '../widgets/visit_sections/integration_section.dart';

class EditFormScreen extends ConsumerStatefulWidget {
  final SupervisionForm form;

  const EditFormScreen({
    super.key,
    required this.form,
  });

  @override
  ConsumerState<EditFormScreen> createState() => _EditFormScreenState();
}

class _EditFormScreenState extends ConsumerState<EditFormScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;
  
  // Basic form controllers
  late final TextEditingController _facilityNameController;
  late final TextEditingController _provinceController;
  late final TextEditingController _districtController;

  // Staff Training Controllers
  late final TextEditingController _haTotal;
  late final TextEditingController _haKhdc;
  late final TextEditingController _haFen;
  late final TextEditingController _haOtherNcd;
  
  late final TextEditingController _srAhwTotal;
  late final TextEditingController _srAhwKhdc;
  late final TextEditingController _srAhwFen;
  late final TextEditingController _srAhwOtherNcd;
  
  late final TextEditingController _ahwTotal;
  late final TextEditingController _ahwKhdc;
  late final TextEditingController _ahwFen;
  late final TextEditingController _ahwOtherNcd;

  // Visit data controllers
  final _recommendationsController = TextEditingController();
  final _actionsAgreedController = TextEditingController();
  DateTime? _visitDate;

  // Section data using Maps for form fields
  final Map<String, dynamic> _adminData = {};
  final Map<String, dynamic> _logisticsData = {};
  final Map<String, dynamic> _equipmentData = {};
  final Map<String, dynamic> _khdcData = {};
  final Map<String, dynamic> _serviceData = {};
  final Map<String, dynamic> _healthInfoData = {};
  final Map<String, dynamic> _integrationData = {};
  
  // Medicine quantity controllers
  final Map<String, TextEditingController> _quantityControllers = {};
  final Map<String, TextEditingController> _unitsControllers = {};

  bool _isLoading = false;
  bool _includeStaffTraining = true;
  bool _hasChanges = false;
  bool _showVisitForm = false;
  SupervisionVisit? _currentVisit;

  @override
  void initState() {
    super.initState();
    
    // Initialize tab controller with 3 tabs: Basic Info, Staff Training, Visit Data
    _tabController = TabController(length: 3, vsync: this);
    
    // Initialize controllers with existing data
    _facilityNameController = TextEditingController(text: widget.form.healthFacilityName);
    _provinceController = TextEditingController(text: widget.form.province);
    _districtController = TextEditingController(text: widget.form.district);

    // Initialize staff training controllers
    final staffTraining = widget.form.staffTraining;
    _includeStaffTraining = staffTraining != null;
    
    _haTotal = TextEditingController(text: (staffTraining?.haTotalStaff ?? 0).toString());
    _haKhdc = TextEditingController(text: (staffTraining?.haKhdcTrained ?? 0).toString());
    _haFen = TextEditingController(text: (staffTraining?.haFenTrained ?? 0).toString());
    _haOtherNcd = TextEditingController(text: (staffTraining?.haOtherNcdTrained ?? 0).toString());
    
    _srAhwTotal = TextEditingController(text: (staffTraining?.srAhwTotalStaff ?? 0).toString());
    _srAhwKhdc = TextEditingController(text: (staffTraining?.srAhwKhdcTrained ?? 0).toString());
    _srAhwFen = TextEditingController(text: (staffTraining?.srAhwFenTrained ?? 0).toString());
    _srAhwOtherNcd = TextEditingController(text: (staffTraining?.srAhwOtherNcdTrained ?? 0).toString());
    
    _ahwTotal = TextEditingController(text: (staffTraining?.ahwTotalStaff ?? 0).toString());
    _ahwKhdc = TextEditingController(text: (staffTraining?.ahwKhdcTrained ?? 0).toString());
    _ahwFen = TextEditingController(text: (staffTraining?.ahwFenTrained ?? 0).toString());
    _ahwOtherNcd = TextEditingController(text: (staffTraining?.ahwOtherNcdTrained ?? 0).toString());

    // Load existing visit data if available
    _loadVisitData();

    // Add listeners to track changes
    _addChangeListeners();
  }

  Future<void> _loadVisitData() async {
    try {
      // Check if form has visits
      if (widget.form.visits != null && widget.form.visits!.isNotEmpty) {
        final visit = widget.form.visits!.first; // Get the first visit for editing
        final completeVisit = await ref.read(formsProvider.notifier).getVisitDetails(visit.id!);
        
        if (completeVisit != null) {
          setState(() {
            _currentVisit = completeVisit;
            _showVisitForm = true;
            _visitDate = completeVisit.visitDate;
            _recommendationsController.text = completeVisit.recommendations ?? '';
            _actionsAgreedController.text = completeVisit.actionsAgreed ?? '';
          });
          
          // Load section data from visit
          _loadSectionDataFromVisit(completeVisit);
        }
      }
    } catch (e) {
      print('Error loading visit data: $e');
    }
  }

  void _loadSectionDataFromVisit(SupervisionVisit visit) {
    setState(() {
      // Load section data from the complete visit object
      if (visit.adminManagement != null) {
        _adminData.addAll(visit.adminManagement!.toJson());
      }
      if (visit.logistics != null) {
        _logisticsData.addAll(visit.logistics!.toJson());
      }
      if (visit.equipment != null) {
        _equipmentData.addAll(visit.equipment!.toJson());
      }
      if (visit.khdcManagement != null) {
        _khdcData.addAll(visit.khdcManagement!.toJson());
      }
      if (visit.serviceStandards != null) {
        _serviceData.addAll(visit.serviceStandards!.toJson());
      }
      if (visit.healthInformation != null) {
        _healthInfoData.addAll(visit.healthInformation!.toJson());
      }
      if (visit.integration != null) {
        _integrationData.addAll(visit.integration!.toJson());
      }
    });
    
    // Initialize quantity controllers for medicines
    _initializeQuantityControllers();
  }

  void _initializeQuantityControllers() {
    final medicines = [
      'metformin_500mg', 'metformin_850mg', 'gliclazide_40_80mg',
      'glibenclamide_5mg', 'enalapril_5mg', 'enalapril_10mg',
      'amlodipine_5mg', 'amlodipine_10mg', 'atenolol_50mg',
      'atenolol_100mg', 'hydrochlorothiazide_25mg', 'simvastatin_20mg',
      'aspirin_75mg', 'prednisolone_5_10_20mg', 'salbutamol_inhaler',
      'beclomethasone_inhaler'
    ];
    
    for (final medicine in medicines) {
      final quantityKey = '${medicine}_quantity';
      final unitsKey = '${medicine}_units';
      
      _quantityControllers[medicine] = TextEditingController(
        text: (_logisticsData[quantityKey] ?? '').toString()
      );
      _unitsControllers[medicine] = TextEditingController(
        text: (_logisticsData[unitsKey] ?? '').toString()
      );
    }
  }

  void _addChangeListeners() {
    final controllers = [
      _facilityNameController,
      _provinceController,
      _districtController,
      _haTotal,
      _haKhdc,
      _haFen,
      _haOtherNcd,
      _srAhwTotal,
      _srAhwKhdc,
      _srAhwFen,
      _srAhwOtherNcd,
      _ahwTotal,
      _ahwKhdc,
      _ahwFen,
      _ahwOtherNcd,
      _recommendationsController,
      _actionsAgreedController,
    ];

    for (final controller in controllers) {
      controller.addListener(() {
        if (!_hasChanges) {
          setState(() {
            _hasChanges = true;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _facilityNameController.dispose();
    _provinceController.dispose();
    _districtController.dispose();
    _haTotal.dispose();
    _haKhdc.dispose();
    _haFen.dispose();
    _haOtherNcd.dispose();
    _srAhwTotal.dispose();
    _srAhwKhdc.dispose();
    _srAhwFen.dispose();
    _srAhwOtherNcd.dispose();
    _ahwTotal.dispose();
    _ahwKhdc.dispose();
    _ahwFen.dispose();
    _ahwOtherNcd.dispose();
    _recommendationsController.dispose();
    _actionsAgreedController.dispose();
    
    // Dispose quantity controllers
    for (final controller in _quantityControllers.values) {
      controller.dispose();
    }
    for (final controller in _unitsControllers.values) {
      controller.dispose();
    }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if form is synced
    if (widget.form.syncStatus != 'local') {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Form'),
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Form Cannot Be Edited',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This form has been synced and cannot be modified.',
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        if (!_hasChanges) return true;
        return await _confirmDiscard();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Form'),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (!_hasChanges) {
                Navigator.pop(context);
                return;
              }
              final canLeave = await _confirmDiscard();
              if (canLeave && mounted) Navigator.pop(context);
            },
          ),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Basic Info'),
              Tab(text: 'Staff Training'),
              Tab(text: 'Visit Data'),
            ],
          ),
        ),
        body: Form(
          key: _formKey,
          child: TabBarView(
            controller: _tabController,
            children: [
              // Basic Information Tab
              _buildBasicInfoTab(),
              // Staff Training Tab
              _buildStaffTrainingTab(),
              // Visit Data Tab
              _buildVisitDataTab(),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmDiscard() async {
    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('You have unsaved changes. Are you sure you want to discard them?'),
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

  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Warning card
          Card(
            color: Colors.amber.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.amber.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Edit Local Form',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.amber.shade900,
                          ),
                        ),
                        Text(
                          'This form is not synced. You can edit it, but changes will be lost if you delete the app.',
                          style: TextStyle(
                            color: Colors.amber.shade800,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Basic Information
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Facility Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _facilityNameController,
                    decoration: const InputDecoration(
                      labelText: 'Health Facility Name',
                      hintText: 'Enter facility name',
                      prefixIcon: Icon(Icons.local_hospital),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter facility name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _provinceController,
                    decoration: const InputDecoration(
                      labelText: 'Province',
                      hintText: 'Enter province',
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter province';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _districtController,
                    decoration: const InputDecoration(
                      labelText: 'District',
                      hintText: 'Enter district',
                      prefixIcon: Icon(Icons.location_city),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter district';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Update Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _updateForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    )
                  : const Text(
                      'Update Form',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffTrainingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Staff Training Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Staff Training Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Switch(
                        value: _includeStaffTraining,
                        onChanged: (value) {
                          setState(() {
                            _includeStaffTraining = value;
                            _hasChanges = true;
                          });
                        },
                      ),
                    ],
                  ),
                  if (_includeStaffTraining) ...[
                    const SizedBox(height: 16),
                    // HA Section
                    const Text(
                      'Health Assistant (HA)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _haTotal,
                            decoration: const InputDecoration(
                              labelText: 'Total Staff',
                              hintText: '0',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _haKhdc,
                            decoration: const InputDecoration(
                              labelText: 'KHDC Trained',
                              hintText: '0',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _haFen,
                            decoration: const InputDecoration(
                              labelText: 'FEN Trained',
                              hintText: '0',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _haOtherNcd,
                            decoration: const InputDecoration(
                              labelText: 'Other NCD Trained',
                              hintText: '0',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Sr. AHW Section
                    const Text(
                      'Senior AHW',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _srAhwTotal,
                            decoration: const InputDecoration(
                              labelText: 'Total Staff',
                              hintText: '0',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _srAhwKhdc,
                            decoration: const InputDecoration(
                              labelText: 'KHDC Trained',
                              hintText: '0',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _srAhwFen,
                            decoration: const InputDecoration(
                              labelText: 'FEN Trained',
                              hintText: '0',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _srAhwOtherNcd,
                            decoration: const InputDecoration(
                              labelText: 'Other NCD Trained',
                              hintText: '0',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // AHW Section
                    const Text(
                      'AHW',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _ahwTotal,
                            decoration: const InputDecoration(
                              labelText: 'Total Staff',
                              hintText: '0',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _ahwKhdc,
                            decoration: const InputDecoration(
                              labelText: 'KHDC Trained',
                              hintText: '0',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _ahwFen,
                            decoration: const InputDecoration(
                              labelText: 'FEN Trained',
                              hintText: '0',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _ahwOtherNcd,
                            decoration: const InputDecoration(
                              labelText: 'Other NCD Trained',
                              hintText: '0',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitDataTab() {
    if (!_showVisitForm || _currentVisit == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No Visit Data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'This form does not have any visit data to edit.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return DefaultTabController(
      length: 8,
      child: Column(
        children: [
          // Visit basic info
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Visit ${_currentVisit!.visitNumber}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      _visitDate != null
                          ? '${_visitDate!.day}/${_visitDate!.month}/${_visitDate!.year}'
                          : 'No date',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _recommendationsController,
                  decoration: const InputDecoration(
                    labelText: 'Recommendations',
                    hintText: 'Enter recommendations',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _actionsAgreedController,
                  decoration: const InputDecoration(
                    labelText: 'Actions Agreed',
                    hintText: 'Enter actions agreed',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          
          // Visit sections tabs
          const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Admin'),
              Tab(text: 'Logistics'),
              Tab(text: 'Equipment'),
              Tab(text: 'KHDC'),
              Tab(text: 'Service Standards'),
              Tab(text: 'Health Info'),
              Tab(text: 'Integration'),
              Tab(text: 'Update'),
            ],
          ),
          
          // Visit sections content
          Expanded(
            child: TabBarView(
              children: [
                AdminManagementSection(
                  data: _adminData,
                  onDataChanged: (key, value) {
                    setState(() {
                      _adminData[key] = value;
                      _hasChanges = true;
                    });
                  },
                ),
                LogisticsSection(
                  data: _logisticsData,
                  quantityControllers: _quantityControllers,
                  unitsControllers: _unitsControllers,
                  onDataChanged: (key, value) {
                    setState(() {
                      _logisticsData[key] = value;
                      _hasChanges = true;
                    });
                  },
                ),
                EquipmentSection(
                  data: _equipmentData,
                  onDataChanged: (key, value) {
                    setState(() {
                      _equipmentData[key] = value;
                      _hasChanges = true;
                    });
                  },
                ),
               
                ServiceStandardsSection(
                  data: _serviceData,
                  onDataChanged: (key, value) {
                    setState(() {
                      _serviceData[key] = value;
                      _hasChanges = true;
                    });
                  },
                ),
                HealthInformationSection(
                  data: _healthInfoData,
                  onDataChanged: (key, value) {
                    setState(() {
                      _healthInfoData[key] = value;
                      _hasChanges = true;
                    });
                  },
                ),
                IntegrationSection(
                  data: _integrationData,
                  onDataChanged: (key, value) {
                    setState(() {
                      _integrationData[key] = value;
                      _hasChanges = true;
                    });
                  },
                ),
                // Update visit tab
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Update Visit',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _updateVisit,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Update Visit',
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateVisit() async {
    if (_currentVisit == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Create typed model instances from the form data
      final adminManagement = _adminData.isNotEmpty 
          ? AdminManagementData.fromJson(_adminData) 
          : null;
      
      final logistics = _logisticsData.isNotEmpty 
          ? LogisticsData.fromJson(_logisticsData) 
          : null;
      
      final equipment = _equipmentData.isNotEmpty 
          ? EquipmentData.fromJson(_equipmentData) 
          : null;
      
      final khdcManagement = _khdcData.isNotEmpty 
          ? KhdcManagementData.fromJson(_khdcData) 
          : null;
      
      final serviceStandards = _serviceData.isNotEmpty 
          ? ServiceStandardsData.fromJson(_serviceData) 
          : null;
      
      final healthInformation = _healthInfoData.isNotEmpty 
          ? HealthInformationData.fromJson(_healthInfoData) 
          : null;
      
      final integration = _integrationData.isNotEmpty 
          ? IntegrationData.fromJson(_integrationData) 
          : null;

      // Update the visit with new data
      final updatedVisit = _currentVisit!.copyWith(
        recommendations: _recommendationsController.text.trim().isEmpty 
            ? null 
            : _recommendationsController.text.trim(),
        actionsAgreed: _actionsAgreedController.text.trim().isEmpty 
            ? null 
            : _actionsAgreedController.text.trim(),
        updatedAt: DateTime.now(),
        adminManagement: adminManagement,
        logistics: logistics,
        equipment: equipment,
        khdcManagement: khdcManagement,
        serviceStandards: serviceStandards,
        healthInformation: healthInformation,
        integration: integration,
      );

      final success = await ref.read(formsProvider.notifier).updateVisit(
        visit: updatedVisit,
        adminManagement: adminManagement,
        logistics: logistics,
        equipment: equipment,
        khdcManagement: khdcManagement,
        serviceStandards: serviceStandards,
        healthInformation: healthInformation,
        integration: integration,
      );

      if (success && mounted) {
        setState(() {
          _hasChanges = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Visit updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating visit: $e'),
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

  Future<void> _updateForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      StaffTrainingData? staffTraining;
      
      if (_includeStaffTraining) {
        final staffTrainingMap = {
          'ha_total_staff': int.tryParse(_haTotal.text) ?? 0,
          'ha_khdc_trained': int.tryParse(_haKhdc.text) ?? 0,
          'ha_fen_trained': int.tryParse(_haFen.text) ?? 0,
          'ha_other_ncd_trained': int.tryParse(_haOtherNcd.text) ?? 0,
          'sr_ahw_total_staff': int.tryParse(_srAhwTotal.text) ?? 0,
          'sr_ahw_khdc_trained': int.tryParse(_srAhwKhdc.text) ?? 0,
          'sr_ahw_fen_trained': int.tryParse(_srAhwFen.text) ?? 0,
          'sr_ahw_other_ncd_trained': int.tryParse(_srAhwOtherNcd.text) ?? 0,
          'ahw_total_staff': int.tryParse(_ahwTotal.text) ?? 0,
          'ahw_khdc_trained': int.tryParse(_ahwKhdc.text) ?? 0,
          'ahw_fen_trained': int.tryParse(_ahwFen.text) ?? 0,
          'ahw_other_ncd_trained': int.tryParse(_ahwOtherNcd.text) ?? 0,
        };
        staffTraining = StaffTrainingData.fromJson(staffTrainingMap);
      }

      final updatedForm = widget.form.copyWith(
        healthFacilityName: _facilityNameController.text.trim(),
        province: _provinceController.text.trim(),
        district: _districtController.text.trim(),
        staffTraining: staffTraining,
        updatedAt: DateTime.now(),
      );

      final success = await ref.read(formsProvider.notifier).updateForm(updatedForm);

      if (success && mounted) {
        Navigator.pop(context, true); // Return true to indicate successful update
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Form updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating form: $e'),
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
}