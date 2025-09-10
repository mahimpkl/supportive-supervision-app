import 'package:flutter/material.dart';

class AdminManagementSection extends StatefulWidget {
  final Map<String, dynamic> data;
  final Function(String, dynamic) onDataChanged;

  const AdminManagementSection({
    super.key,
    required this.data,
    required this.onDataChanged,
  });

  @override
  State<AdminManagementSection> createState() => _AdminManagementSectionState();
}

class _AdminManagementSectionState extends State<AdminManagementSection> {
  @override
  Widget build(BuildContext context) {
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
                    'A. Administrative Management',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildResponseQuestion(
                    'A1. Is there a provision of Health Facility Operation and Management Committee at the health facility?',
                    'a1_response',
                  ),
                  _buildCommentField('A1 Comments', 'a1_comment'),
                  
                  const SizedBox(height: 16),
                  
                  _buildResponseQuestion(
                    'A2. Does the committee discuss NCD service provisions at their regular meetings?',
                    'a2_response',
                  ),
                  _buildCommentField('A2 Comments', 'a2_comment'),
                  
                  const SizedBox(height: 16),
                  
                  _buildResponseQuestion(
                    'A3. Does the Health facility and its Health care workers discuss quarterly the NCD services related queries and cases with MHDC team over Telemedicine or other means?',
                    'a3_response',
                  ),
                  _buildCommentField('A3 Comments', 'a3_comment'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponseQuestion(String question, String key) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Yes'),
                value: 'Y',
                groupValue: widget.data[key],
                onChanged: (value) {
                  widget.onDataChanged(key, value);
                },
                contentPadding: EdgeInsets.zero,
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: const Text('No'),
                value: 'N',
                groupValue: widget.data[key],
                onChanged: (value) {
                  widget.onDataChanged(key, value);
                },
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCommentField(String label, String key) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          hintText: 'Enter comments',
          alignLabelWithHint: true,
        ),
        maxLines: 2,
        textCapitalization: TextCapitalization.sentences,
        onChanged: (value) {
          widget.onDataChanged(key, value.isNotEmpty ? value : null);
        },
      ),
    );
  }
}
