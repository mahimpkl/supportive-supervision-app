class MedicineDetail {
  final String medicineName;
  final String? medicineCategory;
  final String? availability;
  final int? quantityAvailable;
  final String? unitOfMeasurement;
  final DateTime? expiryDate;
  final String? batchNumber;
  final bool? storageTemperatureOk;
  final bool? storageHumidityOk;
  final String? storageLocation;
  final String? procurementSource;
  final double? costPerUnit;
  final DateTime? lastRestockedDate;
  final int? minimumStockLevel;
  final String? stockOutFrequency;
  final String? qualityIssuesNoted;

  MedicineDetail({
    required this.medicineName,
    this.medicineCategory,
    this.availability,
    this.quantityAvailable,
    this.unitOfMeasurement,
    this.expiryDate,
    this.batchNumber,
    this.storageTemperatureOk,
    this.storageHumidityOk,
    this.storageLocation,
    this.procurementSource,
    this.costPerUnit,
    this.lastRestockedDate,
    this.minimumStockLevel,
    this.stockOutFrequency,
    this.qualityIssuesNoted,
  });

  factory MedicineDetail.fromJson(Map<String, dynamic> json) {
    return MedicineDetail(
      medicineName: json['medicine_name'] ?? json['medicineName'] ?? '',
      medicineCategory: json['medicine_category'] ?? json['medicineCategory'],
      availability: json['availability'],
      quantityAvailable: json['quantity_available'] ?? json['quantityAvailable'],
      unitOfMeasurement: json['unit_of_measurement'] ?? json['unitOfMeasurement'],
      expiryDate: json['expiry_date'] != null || json['expiryDate'] != null
          ? DateTime.parse(json['expiry_date'] ?? json['expiryDate'])
          : null,
      batchNumber: json['batch_number'] ?? json['batchNumber'],
      storageTemperatureOk: _parseBool(json['storage_temperature_ok'] ?? json['storageTemperatureOk']),
      storageHumidityOk: _parseBool(json['storage_humidity_ok'] ?? json['storageHumidityOk']),
      storageLocation: json['storage_location'] ?? json['storageLocation'],
      procurementSource: json['procurement_source'] ?? json['procurementSource'],
      costPerUnit: json['cost_per_unit'] != null ? (json['cost_per_unit'] as num).toDouble() : 
                   json['costPerUnit'] != null ? (json['costPerUnit'] as num).toDouble() : null,
      lastRestockedDate: json['last_restocked_date'] != null || json['lastRestockedDate'] != null
          ? DateTime.parse(json['last_restocked_date'] ?? json['lastRestockedDate'])
          : null,
      minimumStockLevel: json['minimum_stock_level'] ?? json['minimumStockLevel'],
      stockOutFrequency: json['stock_out_frequency'] ?? json['stockOutFrequency'],
      qualityIssuesNoted: json['quality_issues_noted'] ?? json['qualityIssuesNoted'],
    );
  }

  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      if (value.toLowerCase() == 'true' || value == '1') return true;
      if (value.toLowerCase() == 'false' || value == '0') return false;
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'medicine_name': medicineName,
      if (medicineCategory != null) 'medicine_category': medicineCategory,
      if (availability != null) 'availability': availability,
      if (quantityAvailable != null) 'quantity_available': quantityAvailable,
      if (unitOfMeasurement != null) 'unit_of_measurement': unitOfMeasurement,
      if (expiryDate != null) 'expiry_date': expiryDate!.toIso8601String(),
      if (batchNumber != null) 'batch_number': batchNumber,
      if (storageTemperatureOk != null) 'storage_temperature_ok': storageTemperatureOk,
      if (storageHumidityOk != null) 'storage_humidity_ok': storageHumidityOk,
      if (storageLocation != null) 'storage_location': storageLocation,
      if (procurementSource != null) 'procurement_source': procurementSource,
      if (costPerUnit != null) 'cost_per_unit': costPerUnit,
      if (lastRestockedDate != null) 'last_restocked_date': lastRestockedDate!.toIso8601String(),
      if (minimumStockLevel != null) 'minimum_stock_level': minimumStockLevel,
      if (stockOutFrequency != null) 'stock_out_frequency': stockOutFrequency,
      if (qualityIssuesNoted != null) 'quality_issues_noted': qualityIssuesNoted,
    };
  }

  Map<String, dynamic> toServerJson() {
    return {
      'medicine_name': medicineName,
      if (medicineCategory != null) 'medicine_category': medicineCategory,
      if (availability != null) 'availability': availability,
      if (quantityAvailable != null) 'quantity_available': quantityAvailable,
      if (unitOfMeasurement != null) 'unit_of_measurement': unitOfMeasurement,
      if (expiryDate != null) 'expiry_date': expiryDate!.toIso8601String(),
      if (batchNumber != null) 'batch_number': batchNumber,
      if (storageTemperatureOk != null) 'storage_temperature_ok': storageTemperatureOk,
      if (storageHumidityOk != null) 'storage_humidity_ok': storageHumidityOk,
      if (storageLocation != null) 'storage_location': storageLocation,
      if (procurementSource != null) 'procurement_source': procurementSource,
      if (costPerUnit != null) 'cost_per_unit': costPerUnit,
      if (lastRestockedDate != null) 'last_restocked_date': lastRestockedDate!.toIso8601String(),
      if (minimumStockLevel != null) 'minimum_stock_level': minimumStockLevel,
      if (stockOutFrequency != null) 'stock_out_frequency': stockOutFrequency,
      if (qualityIssuesNoted != null) 'quality_issues_noted': qualityIssuesNoted,
    };
  }

  MedicineDetail copyWith({
    String? medicineName,
    String? medicineCategory,
    String? availability,
    int? quantityAvailable,
    String? unitOfMeasurement,
    DateTime? expiryDate,
    String? batchNumber,
    bool? storageTemperatureOk,
    bool? storageHumidityOk,
    String? storageLocation,
    String? procurementSource,
    double? costPerUnit,
    DateTime? lastRestockedDate,
    int? minimumStockLevel,
    String? stockOutFrequency,
    String? qualityIssuesNoted,
  }) {
    return MedicineDetail(
      medicineName: medicineName ?? this.medicineName,
      medicineCategory: medicineCategory ?? this.medicineCategory,
      availability: availability ?? this.availability,
      quantityAvailable: quantityAvailable ?? this.quantityAvailable,
      unitOfMeasurement: unitOfMeasurement ?? this.unitOfMeasurement,
      expiryDate: expiryDate ?? this.expiryDate,
      batchNumber: batchNumber ?? this.batchNumber,
      storageTemperatureOk: storageTemperatureOk ?? this.storageTemperatureOk,
      storageHumidityOk: storageHumidityOk ?? this.storageHumidityOk,
      storageLocation: storageLocation ?? this.storageLocation,
      procurementSource: procurementSource ?? this.procurementSource,
      costPerUnit: costPerUnit ?? this.costPerUnit,
      lastRestockedDate: lastRestockedDate ?? this.lastRestockedDate,
      minimumStockLevel: minimumStockLevel ?? this.minimumStockLevel,
      stockOutFrequency: stockOutFrequency ?? this.stockOutFrequency,
      qualityIssuesNoted: qualityIssuesNoted ?? this.qualityIssuesNoted,
    );
  }
}