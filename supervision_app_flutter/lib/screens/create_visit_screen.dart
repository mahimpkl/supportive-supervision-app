import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/forms_provider.dart';
import '../models/admin_management_data.dart';
import '../models/logistics_data.dart';
import '../models/service_standards_data.dart';
import '../models/health_information_data.dart';
import '../models/integration_data.dart';
import '../widgets/visit_sections/admin_management_section.dart';
import '../widgets/visit_sections/logistics_section.dart';
import '../widgets/visit_sections/service_standards_section.dart';
import '../widgets/visit_sections/health_information_section.dart';
import '../widgets/visit_sections/integration_section.dart';

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
  
  // Section data using Maps for form fields
  final Map<String, dynamic> _adminData = {};
  final Map<String, dynamic> _logisticsData = {};
  final Map<String, dynamic> _serviceData = {};
  final Map<String, dynamic> _healthInfoData = {};
  final Map<String, dynamic> _integrationData = {};
  
  // Medicine quantity controllers
  final Map<String, TextEditingController> _quantityControllers = {};
  final Map<String, TextEditingController> _unitsControllers = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _visitDate = DateTime.now();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _recommendationsController.dispose();
    _actionsAgreedController.dispose();
    
    // Clear section data maps
    _adminData.clear();
    _logisticsData.clear();
    _serviceData.clear();
    _healthInfoData.clear();
    _integrationData.clear();
    
    // Dispose quantity controllers
    for (var controller in _quantityControllers.values) {
      controller.dispose();
    }
    for (var controller in _unitsControllers.values) {
      controller.dispose();
    }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final hasInput = _recommendationsController.text.trim().isNotEmpty ||
            _actionsAgreedController.text.trim().isNotEmpty ||
            _adminData.isNotEmpty ||
            _logisticsData.isNotEmpty ||
            _serviceData.isNotEmpty ||
            _healthInfoData.isNotEmpty ||
            _integrationData.isNotEmpty;
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
              if (canLeave && mounted) {
                Navigator.pop(context);
              }
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
              Tab(text: 'Service'),
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
              AdminManagementSection(
                data: _adminData,
                onDataChanged: (key, value) {
                  setState(() {
                    _adminData[key] = value;
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
                  });
                },
              ),
              ServiceStandardsSection(
                data: _serviceData,
                onDataChanged: (key, value) {
                  setState(() {
                    _serviceData[key] = value;
                  });
                },
              ),
              HealthInformationSection(
                data: _healthInfoData,
                onDataChanged: (key, value) {
                  setState(() {
                    _healthInfoData[key] = value;
                  });
                },
              ),
              IntegrationSection(
                data: _integrationData,
                onDataChanged: (key, value) {
                  setState(() {
                    _integrationData[key] = value;
                  });
                },
              ),
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
                    final canLeave = await _checkCanLeave();
                    if (canLeave && mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleNextOrSave,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_tabController.index < 5 ? 'Next' : 'Save Visit'),
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
                  const Text(
                    'Visit Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Visit Date
                  ListTile(
                    title: const Text('Visit Date'),
                    subtitle: Text(
                      _visitDate != null 
                          ? '${_visitDate!.day}/${_visitDate!.month}/${_visitDate!.year}'
                          : 'Select date',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: _selectDate,
                    contentPadding: EdgeInsets.zero,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Recommendations
                  TextFormField(
                    controller: _recommendationsController,
                    decoration: const InputDecoration(
                      labelText: 'Recommendations',
                      hintText: 'Enter recommendations',
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
        _adminData.isNotEmpty ||
        _logisticsData.isNotEmpty ||
        _serviceData.isNotEmpty ||
        _healthInfoData.isNotEmpty ||
        _integrationData.isNotEmpty;
    if (!hasInput) return true;
    return await _confirmDiscard();
  }

  void _handleNextOrSave() {
    if (_tabController.index < 5) {
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
      // Create typed model instances from Map data
      AdminManagementData? adminManagement;
      if (_adminData.isNotEmpty) {
        adminManagement = AdminManagementData.fromJson(_cleanSectionData(_adminData));
      }

      LogisticsData? logistics;
      if (_logisticsData.isNotEmpty) {
        logistics = LogisticsData.fromJson(_cleanSectionData(_logisticsData));
      }

      ServiceStandardsData? serviceStandards;
      if (_serviceData.isNotEmpty) {
        serviceStandards = ServiceStandardsData.fromJson(_cleanSectionData(_serviceData));
      }

      HealthInformationData? healthInformation;
      if (_healthInfoData.isNotEmpty) {
        healthInformation = HealthInformationData.fromJson(_cleanSectionData(_healthInfoData));
      }

      IntegrationData? integration;
      if (_integrationData.isNotEmpty) {
        integration = IntegrationData.fromJson(_cleanSectionData(_integrationData));
      }

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
        adminManagement: adminManagement,
        logistics: logistics,
        serviceStandards: serviceStandards,
        healthInformation: healthInformation,
        integration: integration,
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