import 'package:flutter/material.dart';

class IntegrationSection extends StatefulWidget {
  final Map<String, dynamic> data;
  final Function(String, dynamic) onDataChanged;

  const IntegrationSection({
    super.key,
    required this.data,
    required this.onDataChanged,
  });

  @override
  State<IntegrationSection> createState() => _IntegrationSectionState();
}

class _IntegrationSectionState extends State<IntegrationSection> {
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
                    'E. Integration of NCD Services',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildResponseQuestion(
                    'E1. Are Health Workers in the health facility aware of the purpose of the PEN programme?',
                    'e1_response',
                  ),
                  _buildCommentField('E1 Comments', 'e1_comment'),
                  
                  const SizedBox(height: 16),
                  
                  _buildResponseQuestion(
                    'E2. Is health education on tobacco, alcohol, unhealthy diet and physical activity provided to all patients at risk of NCDs?',
                    'e2_response',
                  ),
                  _buildCommentField('E2 Comments', 'e2_comment'),

                  const SizedBox(height: 16),
                  
                  _buildResponseQuestion(
                    'E3. Is screening for raised blood pressure and raised blood sugar provided to all patients at high risk for NCDs?',
                    'e3_response',
                  ),
                  _buildCommentField('E3 Comments', 'e3_comment'),
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
