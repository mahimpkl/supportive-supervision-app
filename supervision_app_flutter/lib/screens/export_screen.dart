import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/export_provider.dart';
import '../providers/auth_provider.dart';
import '../services/export_service.dart';

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedProvince;
  String? _selectedDistrict;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Only load export summary for admin users
      final authState = ref.read(authProvider);
      if (authState.user?.role == 'admin') {
        ref.read(exportProvider.notifier).loadExportSummary();
      }
    });
  }

  Widget _buildUserWelcomeCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.file_download,
                  color: Colors.blue.shade700,
                  size: 32,
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Export Your Forms',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Download and share your supervision forms',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'What you can export:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• All your supervision forms\n'
                    '• Complete visit records\n'
                    '• Form responses and signatures\n'
                    '• Excel format for easy sharing',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final exportState = ref.watch(exportProvider);
    final authState = ref.watch(authProvider);
    final isAdmin = authState.user?.role == 'admin';

    return RefreshIndicator(
      onRefresh: () async {
        // Only refresh export summary for admin users
        if (isAdmin) {
          ref.read(exportProvider.notifier).loadExportSummary();
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Export Summary Card (Admin Only)
            if (isAdmin && exportState.summary != null) ...[
              _buildSummaryCard(exportState.summary!),
              const SizedBox(height: 24),
            ],

            // User Welcome Card (Non-Admin)
            if (!isAdmin) ...[
              _buildUserWelcomeCard(),
              const SizedBox(height: 24),
            ],

            // Export Actions
            _buildExportActionsCard(isAdmin),
            const SizedBox(height: 24),

            // Recent Exports
            _buildRecentExportsCard(exportState.recentExports),

            if (exportState.error != null) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.error, color: Colors.red.shade700),
                          const SizedBox(width: 8),
                          const Text(
                            'Export Error',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(exportState.error!),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          ref.read(exportProvider.notifier).clearError();
                        },
                        child: const Text('Dismiss'),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            if (exportState.isLoading)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 16),
                      Text('Exporting data...'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(ExportSummary summary) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Export Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // Stats Grid
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total Forms',
                    summary.summary.totalForms.toString(),
                    Icons.assignment,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    'Facilities',
                    summary.summary.totalFacilities.toString(),
                    Icons.local_hospital,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total Visits',
                    summary.summary.totalVisits.toString(),
                    Icons.event,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    'Users',
                    summary.summary.totalUsers.toString(),
                    Icons.people,
                    Colors.purple,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Visit Breakdown
            const Text(
              'Visit Distribution',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildVisitStat('Visit 1', summary.summary.visitBreakdown.visit1),
                ),
                Expanded(
                  child: _buildVisitStat('Visit 2', summary.summary.visitBreakdown.visit2),
                ),
                Expanded(
                  child: _buildVisitStat('Visit 3', summary.summary.visitBreakdown.visit3),
                ),
                Expanded(
                  child: _buildVisitStat('Visit 4', summary.summary.visitBreakdown.visit4),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Sync Status
            const Text(
              'Sync Status',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSyncStat('Local', summary.summary.syncStatus.local, Colors.orange),
                ),
                Expanded(
                  child: _buildSyncStat('Synced', summary.summary.syncStatus.synced, Colors.blue),
                ),
                Expanded(
                  child: _buildSyncStat('Verified', summary.summary.syncStatus.verified, Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVisitStat(String visit, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          visit,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSyncStat(String status, int count, Color color) {
    return Column(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          status,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildExportActionsCard(bool isAdmin) {
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
                  'Export Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showFilters = !_showFilters;
                    });
                  },
                  icon: Icon(
                    _showFilters ? Icons.filter_list_off : Icons.filter_list,
                  ),
                  tooltip: _showFilters ? 'Hide Filters' : 'Show Filters',
                ),
              ],
            ),

            // Filters Section (collapsible)
            if (_showFilters) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              _buildFiltersSection(),
              const SizedBox(height: 16),
              const Divider(),
            ],

            const SizedBox(height: 16),

            if (isAdmin) ...[
              // Admin Export (Full Access)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: ref.watch(exportProvider).isLoading
                      ? null
                      : () => _performAdminExport(),
                  icon: const Icon(Icons.admin_panel_settings),
                  label: const Text('Export All Forms (Admin)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // User Export
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: ref.watch(exportProvider).isLoading
                    ? null
                    : () => _performUserExport(),
                icon: const Icon(Icons.person),
                label: const Text('Export My Forms'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Export Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue.shade700, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Export Information',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Exports are saved to your Downloads folder\n'
                    '• Files are in Excel format (.xlsx)\n'
                    '• Includes all form data, visits, and responses\n'
                    '• Large exports may take some time',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Filters (Admin Export Only)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),

        // Date Range
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _selectDate(context, true),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _startDate != null
                              ? 'From: ${_formatDate(_startDate!)}'
                              : 'Start Date',
                          style: TextStyle(
                            color: _startDate != null ? Colors.black : Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: () => _selectDate(context, false),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _endDate != null
                              ? 'To: ${_formatDate(_endDate!)}'
                              : 'End Date',
                          style: TextStyle(
                            color: _endDate != null ? Colors.black : Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Province and District (placeholder - you can implement dropdowns)
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Province (Optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  _selectedProvince = value.isNotEmpty ? value : null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'District (Optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  _selectedDistrict = value.isNotEmpty ? value : null;
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Clear Filters
        TextButton.icon(
          onPressed: () {
            setState(() {
              _startDate = null;
              _endDate = null;
              _selectedProvince = null;
              _selectedDistrict = null;
            });
          },
          icon: const Icon(Icons.clear),
          label: const Text('Clear Filters'),
        ),
      ],
    );
  }

  Widget _buildRecentExportsCard(List<ExportRecord> recentExports) {
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
                  'Recent Exports',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (recentExports.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      ref.read(exportProvider.notifier).clearRecentExports();
                    },
                    child: const Text('Clear'),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            if (recentExports.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.file_download_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No recent exports',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...recentExports.map((export) => _buildExportItem(export)),
          ],
        ),
      ),
    );
  }

  Widget _buildExportItem(ExportRecord export) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.file_present, color: Colors.green),
        title: Text(
          export.fileName ?? 'Export',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Exported: ${_formatDateTime(export.exportedAt)}'),
            if (export.filters != null && export.filters!.isNotEmpty)
              Text(
                'Filters: ${_formatFilters(export.filters!)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: export.filePath != null
                  ? () => _openExportedFile(export.filePath!)
                  : null,
              icon: const Icon(Icons.open_in_new),
              tooltip: 'Open File',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatFilters(Map<String, dynamic> filters) {
    final List<String> filterStrings = [];
    
    if (filters['startDate'] != null) {
      filterStrings.add('From ${filters['startDate']}');
    }
    if (filters['endDate'] != null) {
      filterStrings.add('To ${filters['endDate']}');
    }
    if (filters['province'] != null) {
      filterStrings.add('Province: ${filters['province']}');
    }
    if (filters['district'] != null) {
      filterStrings.add('District: ${filters['district']}');
    }
    if (filters['userSpecific'] == true) {
      filterStrings.add('User Export');
    }
    
    return filterStrings.join(', ');
  }

  Future<void> _performAdminExport() async {
    final result = await ref.read(exportProvider.notifier).exportForms(
      startDate: _startDate,
      endDate: _endDate,
      province: _selectedProvince,
      district: _selectedDistrict,
    );

    if (mounted) {
      _showExportResult(result);
    }
  }

  Future<void> _performUserExport() async {
    final user = ref.read(authProvider).user;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You need to be logged in to export your forms'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    
    final result = await ref.read(exportProvider.notifier).exportUserForms(user.id);

    if (mounted) {
      _showExportResult(result);
    }
  }

  Future<void> _openExportedFile(String filePath) async {
    final success = await ref.read(exportProvider.notifier).openExportedFile(filePath);
    
    if (mounted && !success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open file. It may have been moved or deleted.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _showExportResult(ExportResult result) {
    if (result.success) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Export Successful'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(result.message),
              if (result.fileName != null) ...[
                const SizedBox(height: 8),
                Text(
                  'File: ${result.fileName}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
            if (result.filePath != null)
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _openExportedFile(result.filePath!);
                },
                child: const Text('Open File'),
              ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
  }
}