import 'package:flutter/material.dart';

class EquipmentSection extends StatefulWidget {
  final Map<String, dynamic> data;
  final Function(String, dynamic) onDataChanged;

  const EquipmentSection({
    super.key,
    required this.data,
    required this.onDataChanged,
  });

  @override
  State<EquipmentSection> createState() => _EquipmentSectionState();
}

class _EquipmentSectionState extends State<EquipmentSection> {
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
                    'Equipment Functionality',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  const Text(
                    'Equipment functionality and calibration status:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  _buildEquipmentFunctionalitySection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentFunctionalitySection() {
    final equipment = [
      {'name': 'Peak expiratory flow meter', 'key': 'peak_expiratory_flow_meter'},
      {'name': 'Weighing scale', 'key': 'weighing_scale'},
      {'name': 'Sphygmomanometer', 'key': 'sphygmomanometer'},
      {'name': 'Glucometer', 'key': 'glucometer'},
    ];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Header row
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: const Row(
              children: [
                Expanded(flex: 3, child: Text('Equipment', style: TextStyle(fontWeight: FontWeight.w600))),
                Expanded(flex: 1, child: Text('Calibrated/Functional', style: TextStyle(fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
              ],
            ),
          ),
          // Equipment rows
          ...equipment.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Container(
              decoration: BoxDecoration(
                border: Border(
                  top: index > 0 ? BorderSide(color: Colors.grey.shade300) : BorderSide.none,
                ),
              ),
              child: _buildEquipmentRow(item['name']!, item['key']!),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEquipmentRow(String equipment, String key) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              equipment,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Radio<String>(
                    value: 'Y',
                    groupValue: widget.data[key],
                    onChanged: (value) {
                      widget.onDataChanged(key, value);
                    },
                  ),
                ),
                const Text('Y', style: TextStyle(fontSize: 11)),
                const SizedBox(width: 4),
                Flexible(
                  child: Radio<String>(
                    value: 'N',
                    groupValue: widget.data[key],
                    onChanged: (value) {
                      widget.onDataChanged(key, value);
                    },
                  ),
                ),
                const Text('N', style: TextStyle(fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
