import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/forms_provider.dart';
import '../models/supervision_form_model.dart';
import 'create_visit_screen.dart';
import 'visit_details_screen.dart';
import 'edit_form_screen.dart';

class FormDetailsScreen extends ConsumerStatefulWidget {
  final int formId;

  const FormDetailsScreen({
    super.key,
    required this.formId,
  });

  @override
  ConsumerState<FormDetailsScreen> createState() => _FormDetailsScreenState();
}

class _FormDetailsScreenState extends ConsumerState<FormDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Load form details when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(formsProvider.notifier).getFormDetails(widget.formId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final formsState = ref.watch(formsProvider);
    final syncState = ref.watch(syncProvider);
    final selectedForm = formsState.selectedForm;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Details'),
        elevation: 0,
        actions: [
          if (selectedForm != null && selectedForm.syncStatus == 'local')
            IconButton(
              onPressed: syncState.isLoading ? null : () => _syncForm(context),
              icon: syncState.isLoading 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sync),
              tooltip: 'Sync Form',
            ),
          IconButton(
            onPressed: () => _showOptionsMenu(context),
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: formsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : formsState.error != null
              ? _buildErrorState(formsState.error!)
              : selectedForm == null
                  ? const Center(child: Text('Form not found'))
                  : _buildFormDetails(selectedForm),
      floatingActionButton: selectedForm != null 
          ? _buildFloatingActionButton(selectedForm)
          : null,
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading form',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ref.read(formsProvider.notifier).getFormDetails(widget.formId);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildFormDetails(SupervisionForm form) {
    final visits = form.visits ?? [];
    visits.sort((a, b) => a.visitNumber.compareTo(b.visitNumber));

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(formsProvider.notifier).getFormDetails(widget.formId);
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Form Information Card
            _buildFormInfoCard(form),
            const SizedBox(height: 16),

            // Staff Training Card (if available)
            if (form.staffTraining != null) ...[
              _buildStaffTrainingCard(form.staffTraining!),
              const SizedBox(height: 16),
            ],

            // Visits Section
            _buildVisitsSection(form, visits),
            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildFormInfoCard(SupervisionForm form) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_hospital, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    form.healthFacilityName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _buildSyncStatusChip(form.syncStatus),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${form.district}, ${form.province}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Created: ${_formatDate(form.createdAt)}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            if (form.updatedAt != form.createdAt) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.update, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Updated: ${_formatDate(form.updatedAt)}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            // Progress indicator
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Progress'),
                          Text('${form.completedVisits}/4 visits'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: form.completedVisits / 4,
                        backgroundColor: Colors.grey[300],
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

  Widget _buildStaffTrainingCard(Map<String, dynamic> staffTraining) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Staff Training Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _buildStaffTrainingRow('HA', staffTraining),
            _buildStaffTrainingRow('Sr. AHW', staffTraining, prefix: 'sr_ahw'),
            _buildStaffTrainingRow('AHW', staffTraining),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffTrainingRow(String role, Map<String, dynamic> data, {String? prefix}) {
    final rolePrefix = prefix ?? role.toLowerCase().replaceAll(' ', '_').replaceAll('.', '');
    final total = data['${rolePrefix}_total_staff'] ?? 0;
    final mhdc = data['${rolePrefix}_mhdc_trained'] ?? 0;
    final fen = data['${rolePrefix}_fen_trained'] ?? 0;
    final other = data['${rolePrefix}_other_ncd_trained'] ?? 0;

    if (total == 0) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(role, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text('Total: $total | MHDC: $mhdc | FEN: $fen | Other NCD: $other'),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitsSection(SupervisionForm form, List<SupervisionVisit> visits) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Supervision Visits',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (visits.isNotEmpty)
                  Text(
                    '${visits.length}/4 completed',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (visits.isEmpty)
              _buildEmptyVisitsState()
            else
              ...visits.map((visit) => _buildVisitCard(visit)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyVisitsState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No visits yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create the first supervision visit to get started',
            style: TextStyle(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVisitCard(SupervisionVisit visit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 1,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: _getVisitStatusColor(visit.syncStatus),
            child: Text(
              visit.visitNumber.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text('Visit ${visit.visitNumber}'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Date: ${_formatDate(visit.visitDate)}'),
              const SizedBox(height: 2),
              Row(
                children: [
                  _buildSyncStatusChip(visit.syncStatus),
                  const SizedBox(width: 8),
                  Text(
                    'Created: ${_formatDate(visit.createdAt)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _viewVisitDetails(visit),
        ),
      ),
    );
  }

  Widget? _buildFloatingActionButton(SupervisionForm form) {
    final formsNotifier = ref.read(formsProvider.notifier);
    final nextVisitNumber = formsNotifier.getNextVisitNumber(form);
    final canCreate = nextVisitNumber != null && formsNotifier.canCreateVisit(form, nextVisitNumber);

    if (!canCreate) return null;

    return FloatingActionButton.extended(
      onPressed: () => _createNextVisit(form, nextVisitNumber!),
      icon: const Icon(Icons.add),
      label: Text('Create Visit $nextVisitNumber'),
    );
  }

  Color _getVisitStatusColor(String syncStatus) {
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _createNextVisit(SupervisionForm form, int visitNumber) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => CreateVisitScreen(
          formId: form.id!,
          visitNumber: visitNumber,
        ),
      ),
    );

    if (result == true) {
      // Refresh form details after successful visit creation
      ref.read(formsProvider.notifier).getFormDetails(widget.formId);
    }
  }

  void _viewVisitDetails(SupervisionVisit visit) async {
    if (visit.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Visit ID not found')),
      );
      return;
    }

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => VisitDetailsScreen(
          visitId: visit.id!,
          visit: visit,
        ),
      ),
    );

    if (result == true) {
      // Refresh form details if something changed in visit details
      ref.read(formsProvider.notifier).getFormDetails(widget.formId);
    }
  }

  void _syncForm(BuildContext context) async {
    final result = await ref.read(syncProvider.notifier).uploadForms();
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.success 
              ? 'Form synced successfully' 
              : 'Sync failed: ${result.message}'),
          backgroundColor: result.success ? Colors.green : Colors.red,
        ),
      );

      if (result.success) {
        // Refresh form details after successful sync
        ref.read(formsProvider.notifier).getFormDetails(widget.formId);
        ref.read(formsProvider.notifier).loadForms();
      }
    }
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.sync),
              title: const Text('Sync Form'),
              onTap: () {
                Navigator.pop(context);
                _syncForm(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Form'),
              onTap: () {
                Navigator.pop(context);
                final selectedForm = ref.read(formsProvider).selectedForm;
                if (selectedForm == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Form not loaded yet')),
                  );
                  return;
                }
                Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditFormScreen(form: selectedForm),
                  ),
                ).then((updated) {
                  if (updated == true) {
                    // Refresh after editing
                    ref.read(formsProvider.notifier).getFormDetails(widget.formId);
                    ref.read(formsProvider.notifier).loadForms();
                  }
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Form', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteForm(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Form'),
        content: const Text('Are you sure you want to delete this form? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ref.read(formsProvider.notifier).deleteForm(widget.formId);
              
              if (context.mounted) {
                if (success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Form deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to delete form'),
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