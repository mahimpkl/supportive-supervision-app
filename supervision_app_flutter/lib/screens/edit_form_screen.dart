import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/forms_provider.dart';
import '../models/supervision_form_model.dart';

class EditFormScreen extends ConsumerStatefulWidget {
  final SupervisionForm form;

  const EditFormScreen({
    super.key,
    required this.form,
  });

  @override
  ConsumerState<EditFormScreen> createState() => _EditFormScreenState();
}

class _EditFormScreenState extends ConsumerState<EditFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _facilityNameController;
  late final TextEditingController _provinceController;
  late final TextEditingController _districtController;

  // Staff Training Controllers
  late final TextEditingController _haTotal;
  late final TextEditingController _haMhdc;
  late final TextEditingController _haFen;
  late final TextEditingController _haOtherNcd;
  
  late final TextEditingController _srAhwTotal;
  late final TextEditingController _srAhwMhdc;
  late final TextEditingController _srAhwFen;
  late final TextEditingController _srAhwOtherNcd;
  
  late final TextEditingController _ahwTotal;
  late final TextEditingController _ahwMhdc;
  late final TextEditingController _ahwFen;
  late final TextEditingController _ahwOtherNcd;

  bool _isLoading = false;
  bool _includeStaffTraining = true;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with existing data
    _facilityNameController = TextEditingController(text: widget.form.healthFacilityName);
    _provinceController = TextEditingController(text: widget.form.province);
    _districtController = TextEditingController(text: widget.form.district);

    // Initialize staff training controllers
    final staffTraining = widget.form.staffTraining ?? {};
    _includeStaffTraining = staffTraining.isNotEmpty;
    
    _haTotal = TextEditingController(text: (staffTraining['ha_total_staff'] ?? 0).toString());
    _haMhdc = TextEditingController(text: (staffTraining['ha_mhdc_trained'] ?? 0).toString());
    _haFen = TextEditingController(text: (staffTraining['ha_fen_trained'] ?? 0).toString());
    _haOtherNcd = TextEditingController(text: (staffTraining['ha_other_ncd_trained'] ?? 0).toString());
    
    _srAhwTotal = TextEditingController(text: (staffTraining['sr_ahw_total_staff'] ?? 0).toString());
    _srAhwMhdc = TextEditingController(text: (staffTraining['sr_ahw_mhdc_trained'] ?? 0).toString());
    _srAhwFen = TextEditingController(text: (staffTraining['sr_ahw_fen_trained'] ?? 0).toString());
    _srAhwOtherNcd = TextEditingController(text: (staffTraining['sr_ahw_other_ncd_trained'] ?? 0).toString());
    
    _ahwTotal = TextEditingController(text: (staffTraining['ahw_total_staff'] ?? 0).toString());
    _ahwMhdc = TextEditingController(text: (staffTraining['ahw_mhdc_trained'] ?? 0).toString());
    _ahwFen = TextEditingController(text: (staffTraining['ahw_fen_trained'] ?? 0).toString());
    _ahwOtherNcd = TextEditingController(text: (staffTraining['ahw_other_ncd_trained'] ?? 0).toString());

    // Add listeners to track changes
    _addChangeListeners();
  }

  void _addChangeListeners() {
    final controllers = [
      _facilityNameController,
      _provinceController,
      _districtController,
      _haTotal,
      _haMhdc,
      _haFen,
      _haOtherNcd,
      _srAhwTotal,
      _srAhwMhdc,
      _srAhwFen,
      _srAhwOtherNcd,
      _ahwTotal,
      _ahwMhdc,
      _ahwFen,
      _ahwOtherNcd,
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
    _facilityNameController.dispose();
    _provinceController.dispose();
    _districtController.dispose();
    _haTotal.dispose();
    _haMhdc.dispose();
    _haFen.dispose();
    _haOtherNcd.dispose();
    _srAhwTotal.dispose();
    _srAhwMhdc.dispose();
    _srAhwFen.dispose();
    _srAhwOtherNcd.dispose();
    _ahwTotal.dispose();
    _ahwMhdc.dispose();
    _ahwFen.dispose();
    _ahwOtherNcd.dispose();
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
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
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
                const SizedBox(height: 16),

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
                                  controller: _haMhdc,
                                  decoration: const InputDecoration(
                                    labelText: 'MHDC Trained',
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
                                  controller: _srAhwMhdc,
                                  decoration: const InputDecoration(
                                    labelText: 'MHDC Trained',
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
                                  controller: _ahwMhdc,
                                  decoration: const InputDecoration(
                                    labelText: 'MHDC Trained',
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

  Future<void> _updateForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic>? staffTraining;
      
      if (_includeStaffTraining) {
        staffTraining = {
          'ha_total_staff': int.tryParse(_haTotal.text) ?? 0,
          'ha_mhdc_trained': int.tryParse(_haMhdc.text) ?? 0,
          'ha_fen_trained': int.tryParse(_haFen.text) ?? 0,
          'ha_other_ncd_trained': int.tryParse(_haOtherNcd.text) ?? 0,
          'sr_ahw_total_staff': int.tryParse(_srAhwTotal.text) ?? 0,
          'sr_ahw_mhdc_trained': int.tryParse(_srAhwMhdc.text) ?? 0,
          'sr_ahw_fen_trained': int.tryParse(_srAhwFen.text) ?? 0,
          'sr_ahw_other_ncd_trained': int.tryParse(_srAhwOtherNcd.text) ?? 0,
          'ahw_total_staff': int.tryParse(_ahwTotal.text) ?? 0,
          'ahw_mhdc_trained': int.tryParse(_ahwMhdc.text) ?? 0,
          'ahw_fen_trained': int.tryParse(_ahwFen.text) ?? 0,
          'ahw_other_ncd_trained': int.tryParse(_ahwOtherNcd.text) ?? 0,
        };
      }

      final updatedForm = widget.form.copyWith(
        healthFacilityName: _facilityNameController.text.trim(),
        province: _provinceController.text.trim(),
        district: _districtController.text.trim(),
        staffTraining: staffTraining,
        updatedAt: DateTime.now(),
      );

      final success = await ref.read(formsProvider.notifier).updateFormWithStaffTraining(updatedForm);

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