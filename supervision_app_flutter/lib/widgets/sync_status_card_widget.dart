import 'package:flutter/material.dart';
import '../providers/forms_provider.dart';

class SyncStatusCard extends StatelessWidget {
  final SyncState syncState;

  const SyncStatusCard({
    super.key,
    required this.syncState,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getSyncIcon(),
                  color: _getSyncColor(),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sync Status',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _getSyncStatusText(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (syncState.isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            
            if (syncState.hasUnsyncedData || syncState.lastSyncTime != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    if (syncState.hasUnsyncedData) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.cloud_upload,
                            size: 16,
                            color: Colors.orange[700],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${syncState.unsyncedFormsCount} forms need to be synced',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      if (syncState.lastSyncTime != null) 
                        const SizedBox(height: 8),
                    ],
                    
                    if (syncState.lastSyncTime != null)
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Last sync: ${_formatLastSyncTime()}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getSyncIcon() {
    if (syncState.isLoading) {
      return Icons.sync;
    } else if (syncState.hasUnsyncedData) {
      return Icons.cloud_upload;
    } else {
      return Icons.cloud_done;
    }
  }

  Color _getSyncColor() {
    if (syncState.isLoading) {
      return Colors.blue;
    } else if (syncState.hasUnsyncedData) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  String _getSyncStatusText() {
    if (syncState.isLoading) {
      return 'Syncing data...';
    } else if (syncState.hasUnsyncedData) {
      return 'Changes pending sync';
    } else if (syncState.lastSyncTime != null) {
      return 'All data synced';
    } else {
      return 'Not synced yet';
    }
  }

  String _formatLastSyncTime() {
    if (syncState.lastSyncTime == null) return 'Never';
    
    final now = DateTime.now();
    final difference = now.difference(syncState.lastSyncTime!);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}