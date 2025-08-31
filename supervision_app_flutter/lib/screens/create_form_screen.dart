import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/forms_provider.dart';

class CreateFormScreen extends ConsumerStatefulWidget {
  const CreateFormScreen({super.key});

  @override
  ConsumerState<CreateFormScreen> createState() => _CreateFormScreenState();
}

class _CreateFormScreenState extends ConsumerState<CreateFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _facilityNameController = TextEditingController();
  final _provinceController = TextEditingController();
  final _districtController = TextEditingController();

  // Staff Training Controllers
  final _haTotal = TextEditingController();
  final _haMhdc = TextEditingController();
  final _haFen = TextEditingController();
  final _haOtherNcd = TextEditingController();
  
  final _srAhwTotal = TextEditingController();
  final _srAhwMhdc = TextEditingController();
  final _srAhwFen = TextEditingController();
  final _srAhwOtherNcd = TextEditingController();
  
  final _ahwTotal = TextEditingController();
  final _ahwMhdc = TextEditingController();
  final _ahwFen = TextEditingController();
  final _ahwOtherNcd = TextEditingController();

  bool _isLoading = false;
  bool _includeStaffTraining = true;

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Form'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                              });
                            },
                          ),
                        ],
                      ),
                      if (_includeStaffTraining) ...[
                        const SizedBox(height: 16),
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

              // Create Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        )
                      : const Text(
                          'Create Form',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createForm() async {
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

      final success = await ref.read(formsProvider.notifier).createForm(
        healthFacilityName: _facilityNameController.text.trim(),
        province: _provinceController.text.trim(),
        district: _districtController.text.trim(),
        staffTraining: staffTraining,
      );

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Form created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating form: $e'),
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