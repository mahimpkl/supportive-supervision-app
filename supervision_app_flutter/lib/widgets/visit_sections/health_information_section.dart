import 'package:flutter/material.dart';

class HealthInformationSection extends StatefulWidget {
  final Map<String, dynamic> data;
  final Function(String, dynamic) onDataChanged;

  const HealthInformationSection({
    super.key,
    required this.data,
    required this.onDataChanged,
  });

  @override
  State<HealthInformationSection> createState() => _HealthInformationSectionState();
}

class _HealthInformationSectionState extends State<HealthInformationSection> {
  final TextEditingController _d4NumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the number field controller
    if (widget.data['d4_number_of_people'] != null) {
      _d4NumberController.text = widget.data['d4_number_of_people'].toString();
    }
  }

  @override
  void dispose() {
    _d4NumberController.dispose();
    super.dispose();
  }

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
                    'D. Health Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // D1. NCD OPD register
                  _buildResponseQuestion(
                    'D1. Is NCD OPD register regularly updated and thoroughly completed?',
                    'd1_response',
                  ),
                  _buildCommentField('D1 Comments', 'd1_comment'),
                  _buildRespondentsCommentField('D1 Respondent Comments', 'd1_respondents_comment'),
                  
                  const SizedBox(height: 16),
                  
                  // D2. NCD dashboard
                  _buildResponseQuestion(
                    'D2. Is the NCD dashboard displayed with updated information?',
                    'd2_response',
                  ),
                  _buildCommentField('D2 Comments', 'd2_comment'),
                  _buildRespondentsCommentField('D2 Respondent Comments', 'd2_respondents_comment'),

                  const SizedBox(height: 16),
                  
                  // D3. Monthly reporting
                  _buildResponseQuestion(
                    'D3. Is the Monthly Reporting Form sent to the concerned authority?',
                    'd3_response',
                  ),
                  _buildCommentField('D3 Comments', 'd3_comment'),
                  _buildRespondentsCommentField('D3 Respondent Comments', 'd3_respondents_comment'),

                  const SizedBox(height: 16),
                  
                  // D4. Number of people seeking NCD services
                  _buildD4Section(),

                  const SizedBox(height: 16),
                  
                  // D5. Dedicated healthcare worker
                  _buildResponseQuestion(
                    'D5. Is there any dedicated healthcare worker assigned for NCD service provisions?',
                    'd5_response',
                  ),
                  _buildCommentField('D5 Comments', 'd5_comment'),
                  _buildRespondentsCommentField('D5 Respondent Comments', 'd5_respondents_comment'),
                  
                  const SizedBox(height: 24),
                  
                  // Actions Agreed field
                  _buildCommentField('Actions Agreed', 'actions_agreed'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildD4Section() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildResponseQuestion(
          'D4. Are records available for the number of people who sought NCD services in the previous month?',
          'd4_response',
        ),
        
        // Number of people field - only show if D4 response is Yes
        if (widget.data['d4_response'] == 'Y') ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: _d4NumberController,
            decoration: const InputDecoration(
              labelText: 'Number of people who sought NCD services',
              hintText: 'Enter number of people',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.people),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              widget.onDataChanged('d4_number_of_people', value.isNotEmpty ? int.tryParse(value) : null);
            },
          ),
          
          const SizedBox(height: 12),
          
          // Previous month data checkbox
          Row(
            children: [
              Checkbox(
                value: widget.data['d4_previous_month_data'] == true,
                onChanged: (value) {
                  widget.onDataChanged('d4_previous_month_data', value);
                },
              ),
              const Expanded(
                child: Text(
                  'Previous month data is available and verified',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ],
        
        _buildCommentField('D4 Comments', 'd4_comment'),
        _buildRespondentsCommentField('D4 Respondent Comments', 'd4_respondents_comment'),
      ],
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
                  // Clear D4 specific fields if D4 is set to No
                  if (key == 'd4_response' && value != 'Y') {
                    _d4NumberController.clear();
                    widget.onDataChanged('d4_number_of_people', null);
                    widget.onDataChanged('d4_previous_month_data', null);
                  }
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
                  // Clear D4 specific fields if D4 is set to No
                  if (key == 'd4_response' && value != 'Y') {
                    _d4NumberController.clear();
                    widget.onDataChanged('d4_number_of_people', null);
                    widget.onDataChanged('d4_previous_month_data', null);
                  }
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

  Widget _buildRespondentsCommentField(String label, String key) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          hintText: 'Enter respondent comments',
          alignLabelWithHint: true,
          fillColor: Colors.blue.shade50,
          filled: true,
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