import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/forms_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/export_provider.dart';
import '../models/supervision_form_model.dart';
import '../widgets/form_card_widget.dart';
import '../widgets/sync_status_card_widget.dart';
import 'create_form_screen.dart';
import 'form_details_screen.dart';
import 'export_screen.dart';

class OfflineHomeScreen extends ConsumerStatefulWidget {
  const OfflineHomeScreen({super.key});

  @override
  ConsumerState<OfflineHomeScreen> createState() => _OfflineHomeScreenState();
}

class _OfflineHomeScreenState extends ConsumerState<OfflineHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formsState = ref.watch(formsProvider);
    final syncState = ref.watch(syncProvider);
    final authState = ref.watch(authProvider);
    final canExport = ref.watch(canExportProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              title: const Text(
                'Health Supervision',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () => _showProfileMenu(context),
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF2196F3),
                        Color(0xFF1976D2),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 80, 16, 16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            child: Text(
                              authState.user?.fullName?.substring(0, 1).toUpperCase() ?? 'U',
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
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Welcome back,',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  authState.user?.fullName ?? 'User',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  color: const Color(0xFF2196F3),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    indicatorColor: Colors.white,
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                    ),
                    tabs: [
                      const Tab(text: 'Dashboard'),
                      const Tab(text: 'Forms'),
                      const Tab(text: 'Sync'),
                      if (canExport) const Tab(text: 'Export'),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildDashboardTab(formsState, syncState),
            _buildFormsTab(formsState),
            _buildSyncTab(syncState),
            if (canExport) const ExportScreen(),
          ],
        ),
      ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton.extended(
              onPressed: () => _navigateToCreateForm(context),
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('New Form'),
            )
          : null,
    );
  }

  Widget _buildDashboardTab(FormsState formsState, SyncState syncState) {
    final totalForms = formsState.forms.length;
    final completedForms = formsState.forms.where((f) => f.isCompleted).length;
    final inProgressForms = totalForms - completedForms;
    final unsyncedForms = syncState.unsyncedFormsCount;

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(formsProvider.notifier).loadForms();
        ref.read(syncProvider.notifier).loadSyncStatus();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Stats
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Forms',
                    totalForms.toString(),
                    Icons.assignment,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Completed',
                    completedForms.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'In Progress',
                    inProgressForms.toString(),
                    Icons.pending,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Unsynced',
                    unsyncedForms.toString(),
                    Icons.cloud_upload,
                    Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Sync Status
            SyncStatusCard(syncState: syncState),
            const SizedBox(height: 24),

            // Recent Forms
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Forms',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () => _tabController.animateTo(1),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (formsState.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (formsState.forms.isEmpty)
              _buildEmptyState()
            else
              ...formsState.forms.take(3).map((form) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: FormCard(
                      form: form,
                      onTap: () => _navigateToFormDetails(context, form),
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildFormsTab(FormsState formsState) {
    final filteredForms = _filterForms(formsState.forms);

    return Column(
      children: [
        // Search and Filter
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search forms...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Filter: '),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('All', 'all'),
                          _buildFilterChip('Completed', 'completed'),
                          _buildFilterChip('In Progress', 'progress'),
                          _buildFilterChip('Not Synced', 'unsynced'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Forms List
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.read(formsProvider.notifier).loadForms();
            },
            child: formsState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredForms.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredForms.length,
                        itemBuilder: (context, index) {
                          final form = filteredForms[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: FormCard(
                              form: form,
                              onTap: () => _navigateToFormDetails(context, form),
                            ),
                          );
                        },
                      ),
          ),
        ),
      ],
    );
  }

  Widget _buildSyncTab(SyncState syncState) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.read(syncProvider.notifier).loadSyncStatus();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SyncStatusCard(syncState: syncState),
            const SizedBox(height: 24),

            // Sync Actions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sync Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Full Sync Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: syncState.isLoading
                            ? null
                            : () => _performFullSync(context),
                        icon: syncState.isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.sync),
                        label: Text(syncState.isLoading ? 'Syncing...' : 'Full Sync'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196F3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Upload Only
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: syncState.isLoading
                            ? null
                            : () => _performUploadSync(context),
                        icon: const Icon(Icons.cloud_upload),
                        label: const Text('Upload Changes'),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Download Only
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: syncState.isLoading
                            ? null
                            : () => _performDownloadSync(context),
                        icon: const Icon(Icons.cloud_download),
                        label: const Text('Download Updates'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (syncState.error != null) ...[
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
                            'Sync Error',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(syncState.error!),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _statusFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _statusFilter = value;
          });
        },
        selectedColor: const Color(0xFF2196F3).withOpacity(0.2),
        checkmarkColor: const Color(0xFF2196F3),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No forms yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first supervision form to get started',
              style: TextStyle(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _navigateToCreateForm(context),
              icon: const Icon(Icons.add),
              label: const Text('Create Form'),
            ),
          ],
        ),
      ),
    );
  }

  List<SupervisionForm> _filterForms(List<SupervisionForm> forms) {
    List<SupervisionForm> filtered = forms;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((form) =>
          form.healthFacilityName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          form.province.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          form.district.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    // Apply status filter
    switch (_statusFilter) {
      case 'completed':
        filtered = filtered.where((form) => form.isCompleted).toList();
        break;
      case 'progress':
        filtered = filtered.where((form) => !form.isCompleted && form.completedVisits > 0).toList();
        break;
      case 'unsynced':
        filtered = filtered.where((form) => form.syncStatus == 'local').toList();
        break;
    }

    return filtered;
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                _showLogoutDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCreateForm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateFormScreen()),
    ).then((_) {
      // Refresh forms after returning
      ref.read(formsProvider.notifier).loadForms();
    });
  }

  void _navigateToFormDetails(BuildContext context, SupervisionForm form) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormDetailsScreen(formId: form.id!),
      ),
    );
  }

  Future<void> _performFullSync(BuildContext context) async {
    final result = await ref.read(syncProvider.notifier).fullSync();
    
    if (context.mounted) {
      _showSyncResultDialog(context, result, 'Full Sync');
    }
    
    // Refresh forms after sync
    ref.read(formsProvider.notifier).loadForms();
  }

  Future<void> _performUploadSync(BuildContext context) async {
    final result = await ref.read(syncProvider.notifier).uploadForms();
    
    if (context.mounted) {
      _showSyncResultDialog(context, result, 'Upload');
    }
    
    // Refresh forms after sync
    ref.read(formsProvider.notifier).loadForms();
  }

  Future<void> _performDownloadSync(BuildContext context) async {
    final result = await ref.read(syncProvider.notifier).downloadForms();
    
    if (context.mounted) {
      _showSyncResultDialog(context, result, 'Download');
    }
    
    // Refresh forms after sync
    ref.read(formsProvider.notifier).loadForms();
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // Close dialog
                
                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const AlertDialog(
                    content: Row(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 20),
                        Text('Logging out...'),
                      ],
                    ),
                  ),
                );
                
                // Perform logout
                try {
                  await ref.read(authProvider.notifier).logout();
                  
                  if (context.mounted) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context); // Close loading dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Logout failed: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void _showSyncResultDialog(BuildContext context, SyncResult result, String syncType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              result.success ? Icons.check_circle : Icons.error,
              color: result.success ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$syncType ${result.success ? 'Successful' : 'Failed'}',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(result.message),
            if (result.successCount > 0) ...[
              const SizedBox(height: 8),
              Text('✓ ${result.successCount} items processed successfully'),
            ],
            if (result.errorCount > 0) ...[
              const SizedBox(height: 8),
              Text('✗ ${result.errorCount} items failed'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}