import 'package:flutter/material.dart';

class MhdcManagementSection extends StatefulWidget {
  final Map<String, dynamic> data;
  final Function(String, dynamic) onDataChanged;

  const MhdcManagementSection({
    super.key,
    required this.data,
    required this.onDataChanged,
  });

  @override
  State<MhdcManagementSection> createState() => _MhdcManagementSectionState();
}

class _MhdcManagementSectionState extends State<MhdcManagementSection> {
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
                    'MHDC Management',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildResponseQuestion(
                    'B6. Are the MHDC NCD management leaflets for Healthcare workers available at the Health Center so that health care workers can easily refer to during patient care?',
                    'b6_response',
                  ),
                  _buildCommentField('B6 Comments', 'b6_comment'),
                  
                  const SizedBox(height: 16),
                  
                  _buildResponseQuestion(
                    'B7. Are MHDC awareness and patient education materials available at the health center?',
                    'b7_response',
                  ),
                  _buildCommentField('B7 Comments', 'b7_comment'),

                  const SizedBox(height: 16),
                  
                  _buildResponseQuestion(
                    'B8. Is the NCD register available and filled properly?',
                    'b8_response',
                  ),
                  _buildCommentField('B8 Comments', 'b8_comment'),

                  const SizedBox(height: 16),
                  
                  _buildResponseQuestion(
                    'B9. Is WHO-ISH CVD Risk Prediction Chart available for patient care in the health facility?',
                    'b9_response',
                  ),
                  _buildCommentField('B9 Comments', 'b9_comment'),

                  const SizedBox(height: 16),
                  
                  _buildResponseQuestion(
                    'B10. Is WHO-ISH CVD Risk Prediction Chart in use for patient care in health facility?',
                    'b10_response',
                  ),
                  _buildCommentField('B10 Comments', 'b10_comment'),
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
