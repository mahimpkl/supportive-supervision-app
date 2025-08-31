import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';
import '../models/supervision_form_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'supervision_forms.db');
    
    return await openDatabase(
      path,
      version: 3, // Increment version to handle schema changes
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      // Drop all existing tables to recreate with consistent schema
      await db.execute('DROP TABLE IF EXISTS supervision_forms');
      await db.execute('DROP TABLE IF EXISTS supervision_visits');
      await db.execute('DROP TABLE IF EXISTS form_staff_training');
      await db.execute('DROP TABLE IF EXISTS visit_admin_management_responses');
      await db.execute('DROP TABLE IF EXISTS visit_logistics_responses');
      await db.execute('DROP TABLE IF EXISTS visit_equipment_responses');
      await db.execute('DROP TABLE IF EXISTS visit_mhdc_management_responses');
      await db.execute('DROP TABLE IF EXISTS visit_service_standards_responses');
      await db.execute('DROP TABLE IF EXISTS visit_health_information_responses');
      await db.execute('DROP TABLE IF EXISTS visit_integration_responses');
      
      // Recreate all tables with correct schema
      await _onCreate(db, newVersion);
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create supervision_forms table - camelCase for consistency with Flutter
    await db.execute('''
      CREATE TABLE supervision_forms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tempId TEXT UNIQUE NOT NULL,
        serverId INTEGER,
        healthFacilityName TEXT NOT NULL,
        province TEXT NOT NULL,
        district TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        syncStatus TEXT DEFAULT 'local',
        isActive INTEGER DEFAULT 1
      )
    ''');

    // Create supervision_visits table - camelCase for consistency
    await db.execute('''
      CREATE TABLE supervision_visits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tempId TEXT UNIQUE NOT NULL,
        serverId INTEGER,
        formId INTEGER NOT NULL,
        visitNumber INTEGER NOT NULL,
        visitDate TEXT NOT NULL,
        recommendations TEXT,
        actionsAgreed TEXT,
        supervisorSignature TEXT,
        facilityRepresentativeSignature TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        syncStatus TEXT DEFAULT 'local',
        FOREIGN KEY (formId) REFERENCES supervision_forms (id),
        UNIQUE(formId, visitNumber)
      )
    ''');

    // Create form_staff_training table (snake_case for backend compatibility)
    await db.execute('''
      CREATE TABLE form_staff_training (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        form_id INTEGER NOT NULL,
        ha_total_staff INTEGER DEFAULT 0,
        ha_mhdc_trained INTEGER DEFAULT 0,
        ha_fen_trained INTEGER DEFAULT 0,
        ha_other_ncd_trained INTEGER DEFAULT 0,
        sr_ahw_total_staff INTEGER DEFAULT 0,
        sr_ahw_mhdc_trained INTEGER DEFAULT 0,
        sr_ahw_fen_trained INTEGER DEFAULT 0,
        sr_ahw_other_ncd_trained INTEGER DEFAULT 0,
        ahw_total_staff INTEGER DEFAULT 0,
        ahw_mhdc_trained INTEGER DEFAULT 0,
        ahw_fen_trained INTEGER DEFAULT 0,
        ahw_other_ncd_trained INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (form_id) REFERENCES supervision_forms (id)
      )
    ''');

    // Create visit section tables (snake_case for backend compatibility)
    await _createVisitSectionTables(db);
  }

  Future<void> _createVisitSectionTables(Database db) async {
    // Admin Management - matching backend exactly
    await db.execute('''
      CREATE TABLE visit_admin_management_responses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        visit_id INTEGER NOT NULL,
        a1_response TEXT,
        a1_comment TEXT,
        a2_response TEXT,
        a2_comment TEXT,
        a3_response TEXT,
        a3_comment TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (visit_id) REFERENCES supervision_visits (id)
      )
    ''');

    // Logistics - comprehensive medicine list matching PDF
    await db.execute('''
      CREATE TABLE visit_logistics_responses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        visit_id INTEGER NOT NULL,
        b1_response TEXT,
        b1_comment TEXT,
        amlodipine_5_10mg TEXT,
        enalapril_2_5_10mg TEXT,
        losartan_25_50mg TEXT,
        hydrochlorothiazide_12_5_25mg TEXT,
        chlorthalidone_6_25_12_5mg TEXT,
        atorvastatin_5mg TEXT,
        atorvastatin_10mg TEXT,
        atorvastatin_20mg TEXT,
        metformin_500mg TEXT,
        metformin_1000mg TEXT,
        glimepiride_1_2mg TEXT,
        gliclazide_40_80mg TEXT,
        glipizide_2_5_5mg TEXT,
        sitagliptin_50mg TEXT,
        pioglitazone_5mg TEXT,
        empagliflozin_10mg TEXT,
        insulin_soluble_inj TEXT,
        insulin_nph_inj TEXT,
        dextrose_25_solution TEXT,
        aspirin_75mg TEXT,
        clopidogrel_75mg TEXT,
        metoprolol_succinate_12_5_25_50mg TEXT,
        isosorbide_dinitrate_5mg TEXT,
        amoxicillin_clavulanic_potassium_625mg TEXT,
        azithromycin_500mg TEXT,
        salbutamol_dpi TEXT,
        salbutamol TEXT,
        ipratropium TEXT,
        tiotropium_bromide TEXT,
        formoterol TEXT,
        prednisolone_5_10_20mg TEXT,
        b2_response TEXT,
        b2_comment TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (visit_id) REFERENCES supervision_visits (id)
      )
    ''');

    // Equipment - matching PDF equipment list
    await db.execute('''
      CREATE TABLE visit_equipment_responses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        visit_id INTEGER NOT NULL,
        sphygmomanometer TEXT,
        weighing_scale TEXT,
        measuring_tape TEXT,
        peak_expiratory_flow_meter TEXT,
        oxygen TEXT,
        oxygen_mask TEXT,
        nebulizer TEXT,
        pulse_oximetry TEXT,
        glucometer TEXT,
        glucometer_strips TEXT,
        lancets TEXT,
        urine_dipstick TEXT,
        ecg TEXT,
        other_equipment TEXT,
        b3_response TEXT,
        b3_comment TEXT,
        b4_response TEXT,
        b4_comment TEXT,
        b5_response TEXT,
        b5_comment TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (visit_id) REFERENCES supervision_visits (id)
      )
    ''');

    // MHDC Management
    await db.execute('''
      CREATE TABLE visit_mhdc_management_responses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        visit_id INTEGER NOT NULL,
        b6_response TEXT,
        b6_comment TEXT,
        b7_response TEXT,
        b7_comment TEXT,
        b8_response TEXT,
        b8_comment TEXT,
        b9_response TEXT,
        b9_comment TEXT,
        b10_response TEXT,
        b10_comment TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (visit_id) REFERENCES supervision_visits (id)
      )
    ''');

    // Service Standards
    await db.execute('''
      CREATE TABLE visit_service_standards_responses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        visit_id INTEGER NOT NULL,
        c2_main_response TEXT,
        c2_main_comment TEXT,
        c2_blood_pressure TEXT,
        c2_blood_sugar TEXT,
        c2_bmi_measurement TEXT,
        c2_waist_circumference TEXT,
        c2_cvd_risk_estimation TEXT,
        c2_urine_protein_measurement TEXT,
        c2_peak_expiratory_flow_rate TEXT,
        c2_egfr_calculation TEXT,
        c2_brief_intervention TEXT,
        c2_foot_examination TEXT,
        c2_oral_examination TEXT,
        c2_eye_examination TEXT,
        c2_health_education TEXT,
        c3_response TEXT,
        c3_comment TEXT,
        c4_response TEXT,
        c4_comment TEXT,
        c5_response TEXT,
        c5_comment TEXT,
        c6_response TEXT,
        c6_comment TEXT,
        c7_response TEXT,
        c7_comment TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (visit_id) REFERENCES supervision_visits (id)
      )
    ''');

    // Health Information
    await db.execute('''
      CREATE TABLE visit_health_information_responses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        visit_id INTEGER NOT NULL,
        d1_response TEXT,
        d1_comment TEXT,
        d2_response TEXT,
        d2_comment TEXT,
        d3_response TEXT,
        d3_comment TEXT,
        d4_response TEXT,
        d4_comment TEXT,
        d5_response TEXT,
        d5_comment TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (visit_id) REFERENCES supervision_visits (id)
      )
    ''');

    // Integration
    await db.execute('''
      CREATE TABLE visit_integration_responses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        visit_id INTEGER NOT NULL,
        e1_response TEXT,
        e1_comment TEXT,
        e2_response TEXT,
        e2_comment TEXT,
        e3_response TEXT,
        e3_comment TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (visit_id) REFERENCES supervision_visits (id)
      )
    ''');
  }

  // Form CRUD operations
  Future<int> insertForm(SupervisionForm form) async {
    final db = await database;
    
    final formData = {
      'tempId': form.tempId,
      'healthFacilityName': form.healthFacilityName,
      'province': form.province,
      'district': form.district,
      'createdAt': form.createdAt.toIso8601String(),
      'updatedAt': form.updatedAt.toIso8601String(),
      'syncStatus': form.syncStatus,
      'isActive': form.isActive ? 1 : 0,
    };
    
    if (form.serverId != null) {
      formData['serverId'] = form.serverId!;
    }
    
    return await db.insert('supervision_forms', formData);
  }

  Future<List<SupervisionForm>> getForms() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'supervision_forms',
      where: 'isActive = ?',
      whereArgs: [1],
      orderBy: 'updatedAt DESC',
    );

    return List.generate(maps.length, (i) {
      return SupervisionForm.fromJson(maps[i]);
    });
  }

  Future<SupervisionForm?> getFormById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'supervision_forms',
      where: 'id = ? AND isActive = ?',
      whereArgs: [id, 1],
    );

    if (maps.isNotEmpty) {
      return SupervisionForm.fromJson(maps.first);
    }
    return null;
  }

  Future<void> updateForm(SupervisionForm form) async {
    final db = await database;
    final formData = <String, dynamic>{
      'tempId': form.tempId,
      'serverId': form.serverId,
      'healthFacilityName': form.healthFacilityName,
      'province': form.province,
      'district': form.district,
      'createdAt': form.createdAt.toIso8601String(),
      'updatedAt': form.updatedAt.toIso8601String(),
      'syncStatus': form.syncStatus,
      'isActive': form.isActive ? 1 : 0,
    };
    await db.update(
      'supervision_forms',
      formData,
      where: 'id = ?',
      whereArgs: [form.id],
    );
  }

  Future<void> deleteForm(int id) async {
    final db = await database;
    await db.update(
      'supervision_forms',
      {'isActive': 0, 'updatedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Visit operations
  Future<int> insertVisit(SupervisionVisit visit) async {
    final db = await database;
    
    final visitData = {
      'tempId': visit.tempId,
      'formId': visit.formId,
      'visitNumber': visit.visitNumber,
      'visitDate': visit.visitDate.toIso8601String(),
      'createdAt': visit.createdAt.toIso8601String(),
      'updatedAt': visit.updatedAt.toIso8601String(),
      'syncStatus': visit.syncStatus,
    };
    
    if (visit.serverId != null) visitData['serverId'] = visit.serverId!;
    if (visit.recommendations != null) visitData['recommendations'] = visit.recommendations!;
    if (visit.actionsAgreed != null) visitData['actionsAgreed'] = visit.actionsAgreed!;
    if (visit.supervisorSignature != null) visitData['supervisorSignature'] = visit.supervisorSignature!;
    if (visit.facilityRepresentativeSignature != null) visitData['facilityRepresentativeSignature'] = visit.facilityRepresentativeSignature!;
    
    return await db.insert('supervision_visits', visitData);
  }

  Future<List<SupervisionVisit>> getVisitsByFormId(int formId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'supervision_visits',
      where: 'formId = ?',
      whereArgs: [formId],
      orderBy: 'visitNumber ASC',
    );

    return List.generate(maps.length, (i) {
      return SupervisionVisit.fromJson(maps[i]);
    });
  }

  Future<void> updateVisit(SupervisionVisit visit) async {
    final db = await database;
    final visitData = <String, dynamic>{
      'tempId': visit.tempId,
      'formId': visit.formId,
      'visitNumber': visit.visitNumber,
      'visitDate': visit.visitDate.toIso8601String(),
      'createdAt': visit.createdAt.toIso8601String(),
      'updatedAt': visit.updatedAt.toIso8601String(),
      'syncStatus': visit.syncStatus,
    };
    if (visit.serverId != null) visitData['serverId'] = visit.serverId;
    if (visit.recommendations != null) visitData['recommendations'] = visit.recommendations;
    if (visit.actionsAgreed != null) visitData['actionsAgreed'] = visit.actionsAgreed;
    if (visit.supervisorSignature != null) visitData['supervisorSignature'] = visit.supervisorSignature;
    if (visit.facilityRepresentativeSignature != null) visitData['facilityRepresentativeSignature'] = visit.facilityRepresentativeSignature;

    await db.update(
      'supervision_visits',
      visitData,
      where: 'id = ?',
      whereArgs: [visit.id],
    );
  }

  // Staff training operations
  Future<void> insertStaffTraining(int formId, Map<String, dynamic> staffTraining) async {
    final db = await database;
    
    final cleanedData = Map<String, dynamic>.from(staffTraining);
    cleanedData['form_id'] = formId;
    cleanedData['created_at'] = DateTime.now().toIso8601String();
    cleanedData['updated_at'] = DateTime.now().toIso8601String();
    
    // Ensure integer fields are properly handled
    const intFields = {
      'ha_total_staff', 'ha_mhdc_trained', 'ha_fen_trained', 'ha_other_ncd_trained',
      'sr_ahw_total_staff', 'sr_ahw_mhdc_trained', 'sr_ahw_fen_trained', 'sr_ahw_other_ncd_trained',
      'ahw_total_staff', 'ahw_mhdc_trained', 'ahw_fen_trained', 'ahw_other_ncd_trained'
    };

    intFields.forEach((field) {
      if (cleanedData.containsKey(field)) {
        final value = cleanedData[field];
        if (value is String) {
          cleanedData[field] = int.tryParse(value) ?? 0;
        } else if (value is! int) {
          cleanedData[field] = 0;
        }
      }
    });

    await db.insert('form_staff_training', cleanedData);
  }

  Future<void> updateStaffTraining(int formId, Map<String, dynamic> staffTraining) async {
    final db = await database;
    
    final cleanedData = Map<String, dynamic>.from(staffTraining);
    cleanedData['updated_at'] = DateTime.now().toIso8601String();
    
    // Ensure integer fields are properly handled
    const intFields = {
      'ha_total_staff', 'ha_mhdc_trained', 'ha_fen_trained', 'ha_other_ncd_trained',
      'sr_ahw_total_staff', 'sr_ahw_mhdc_trained', 'sr_ahw_fen_trained', 'sr_ahw_other_ncd_trained',
      'ahw_total_staff', 'ahw_mhdc_trained', 'ahw_fen_trained', 'ahw_other_ncd_trained'
    };

    intFields.forEach((field) {
      if (cleanedData.containsKey(field)) {
        final value = cleanedData[field];
        if (value is String) {
          cleanedData[field] = int.tryParse(value) ?? 0;
        } else if (value is! int) {
          cleanedData[field] = 0;
        }
      }
    });

    await db.update(
      'form_staff_training',
      cleanedData,
      where: 'form_id = ?',
      whereArgs: [formId],
    );
  }

  Future<Map<String, dynamic>?> getStaffTrainingByFormId(int formId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'form_staff_training',
      where: 'form_id = ?',
      whereArgs: [formId],
    );

    return maps.isNotEmpty ? maps.first : null;
  }

  Future<void> deleteVisit(int visitId) async {
    final db = await database;
    
    // Delete visit sections first (foreign key constraints)
    await db.delete('visit_admin_management_responses', where: 'visit_id = ?', whereArgs: [visitId]);
    await db.delete('visit_logistics_responses', where: 'visit_id = ?', whereArgs: [visitId]);
    await db.delete('visit_equipment_responses', where: 'visit_id = ?', whereArgs: [visitId]);
    await db.delete('visit_mhdc_management_responses', where: 'visit_id = ?', whereArgs: [visitId]);
    await db.delete('visit_service_standards_responses', where: 'visit_id = ?', whereArgs: [visitId]);
    await db.delete('visit_health_information_responses', where: 'visit_id = ?', whereArgs: [visitId]);
    await db.delete('visit_integration_responses', where: 'visit_id = ?', whereArgs: [visitId]);
    
    // Delete the visit itself
    await db.delete('supervision_visits', where: 'id = ?', whereArgs: [visitId]);
  }

  // Get unsynced visits - needed by sync service
  Future<List<SupervisionVisit>> getUnsyncedVisits() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'supervision_visits',
      where: 'syncStatus = ?',
      whereArgs: ['local'],
      orderBy: 'createdAt ASC',
    );

    return List.generate(maps.length, (i) {
      return SupervisionVisit.fromJson(maps[i]);
    });
  }

  // Update form sync status after successful sync
  Future<void> updateFormSyncStatus(int formId, String syncStatus, {int? serverId}) async {
    final db = await database;
    final updateData = <String, dynamic>{
      'syncStatus': syncStatus,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    
    if (serverId != null) {
      updateData['serverId'] = serverId;
    }

    await db.update(
      'supervision_forms',
      updateData,
      where: 'id = ?',
      whereArgs: [formId],
    );
  }

  // Update visit sync status after successful sync
  Future<void> updateVisitSyncStatus(int visitId, String syncStatus, {int? serverId}) async {
    final db = await database;
    final updateData = <String, dynamic>{
      'syncStatus': syncStatus,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    
    if (serverId != null) {
      updateData['serverId'] = serverId;
    }

    await db.update(
      'supervision_visits',
      updateData,
      where: 'id = ?',
      whereArgs: [visitId],
    );
  }

  // Get form with complete visit data for sync
  Future<SupervisionForm?> getFormWithCompleteVisits(int formId) async {
    final form = await getFormById(formId);
    if (form == null) return null;

    // Get all visits with their section data
    final visits = await getVisitsByFormId(formId);
    final completeVisits = <SupervisionVisit>[];

    for (final visit in visits) {
      // Load all sections for this visit
      final adminManagement = await getVisitSection('visit_admin_management_responses', visit.id!);
      final logistics = await getVisitSection('visit_logistics_responses', visit.id!);
      final equipment = await getVisitSection('visit_equipment_responses', visit.id!);
      final mhdcManagement = await getVisitSection('visit_mhdc_management_responses', visit.id!);
      final serviceStandards = await getVisitSection('visit_service_standards_responses', visit.id!);
      final healthInformation = await getVisitSection('visit_health_information_responses', visit.id!);
      final integration = await getVisitSection('visit_integration_responses', visit.id!);

      final completeVisit = visit.copyWith(
        adminManagement: adminManagement,
        logistics: logistics,
        equipment: equipment,
        mhdcManagement: mhdcManagement,
        serviceStandards: serviceStandards,
        healthInformation: healthInformation,
        integration: integration,
      );

      completeVisits.add(completeVisit);
    }

    // Get staff training
    final staffTraining = await getStaffTrainingByFormId(formId);

    return form.copyWith(
      visits: completeVisits,
      staffTraining: staffTraining,
    );
  }

  // Update form from server data after download sync
  Future<void> updateFormFromServer(Map<String, dynamic> serverData) async {
    final db = await database;
    
    final formId = serverData['id'] as int;
    final updateData = <String, dynamic>{
      'serverId': formId,
      'syncStatus': serverData['sync_status'] ?? 'synced',
      'updatedAt': serverData['updated_at'] ?? DateTime.now().toIso8601String(),
    };

    // Find local form by tempId or serverId
    final tempId = serverData['tempId'] ?? serverData['temp_id'];
    String whereClause;
    List<dynamic> whereArgs;

    if (tempId != null) {
      whereClause = 'tempId = ? OR serverId = ?';
      whereArgs = [tempId, formId];
    } else {
      whereClause = 'serverId = ?';
      whereArgs = [formId];
    }

    await db.update(
      'supervision_forms',
      updateData,
      where: whereClause,
      whereArgs: whereArgs,
    );
  }

  // Insert form from server data during download sync
  Future<int> insertFormFromServer(Map<String, dynamic> serverData) async {
    final db = await database;
    
    final formData = {
      'tempId': serverData['tempId'] ?? serverData['temp_id'] ?? const Uuid().v4(),
      'serverId': serverData['id'],
      'healthFacilityName': serverData['healthFacilityName'] ?? serverData['health_facility_name'],
      'province': serverData['province'],
      'district': serverData['district'],
      'createdAt': serverData['createdAt'] ?? serverData['created_at'] ?? DateTime.now().toIso8601String(),
      'updatedAt': serverData['updatedAt'] ?? serverData['updated_at'] ?? DateTime.now().toIso8601String(),
      'syncStatus': serverData['syncStatus'] ?? serverData['sync_status'] ?? 'synced',
      'isActive': 1,
    };
    
    return await db.insert('supervision_forms', formData);
  }

  // Insert visit from server data during download sync
  Future<int> insertVisitFromServer(int localFormId, Map<String, dynamic> serverData) async {
    final db = await database;
    
    final visitData = {
      'tempId': serverData['tempId'] ?? serverData['temp_id'] ?? const Uuid().v4(),
      'serverId': serverData['id'],
      'formId': localFormId,
      'visitNumber': serverData['visitNumber'] ?? serverData['visit_number'],
      'visitDate': serverData['visitDate'] ?? serverData['visit_date'],
      'recommendations': serverData['recommendations'],
      'actionsAgreed': serverData['actionsAgreed'] ?? serverData['actions_agreed'],
      'supervisorSignature': serverData['supervisorSignature'] ?? serverData['supervisor_signature'],
      'facilityRepresentativeSignature': serverData['facilityRepresentativeSignature'] ?? serverData['facility_representative_signature'],
      'createdAt': serverData['createdAt'] ?? serverData['created_at'] ?? DateTime.now().toIso8601String(),
      'updatedAt': serverData['updatedAt'] ?? serverData['updated_at'] ?? DateTime.now().toIso8601String(),
      'syncStatus': serverData['syncStatus'] ?? serverData['sync_status'] ?? 'synced',
    };
    
    return await db.insert('supervision_visits', visitData);
  }

  // Check if visit exists by server ID or visit number
  Future<SupervisionVisit?> findVisitByServerIdOrNumber(int formId, int? serverId, int visitNumber) async {
    final db = await database;
    
    String whereClause;
    List<dynamic> whereArgs;
    
    if (serverId != null) {
      whereClause = 'formId = ? AND (serverId = ? OR visitNumber = ?)';
      whereArgs = [formId, serverId, visitNumber];
    } else {
      whereClause = 'formId = ? AND visitNumber = ?';
      whereArgs = [formId, visitNumber];
    }
    
    final List<Map<String, dynamic>> maps = await db.query(
      'supervision_visits',
      where: whereClause,
      whereArgs: whereArgs,
    );

    if (maps.isNotEmpty) {
      return SupervisionVisit.fromJson(maps.first);
    }
    return null;
  }

  // Find form by server ID or temp ID
  Future<SupervisionForm?> findFormByServerIdOrTempId(int? serverId, String? tempId) async {
    final db = await database;
    
    if (serverId == null && tempId == null) return null;
    
    String whereClause;
    List<dynamic> whereArgs;
    
    if (serverId != null && tempId != null) {
      whereClause = 'serverId = ? OR tempId = ?';
      whereArgs = [serverId, tempId];
    } else if (serverId != null) {
      whereClause = 'serverId = ?';
      whereArgs = [serverId];
    } else {
      whereClause = 'tempId = ?';
      whereArgs = [tempId!];
    }
    
    final List<Map<String, dynamic>> maps = await db.query(
      'supervision_forms',
      where: whereClause,
      whereArgs: whereArgs,
    );

    if (maps.isNotEmpty) {
      return SupervisionForm.fromJson(maps.first);
    }
    return null;
  }

  // Get visit by ID - needed for visit details
  Future<SupervisionVisit?> getVisitById(int visitId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'supervision_visits',
      where: 'id = ?',
      whereArgs: [visitId],
    );

    if (maps.isNotEmpty) {
      return SupervisionVisit.fromJson(maps.first);
    }
    return null;
  }

  // Visit section operations
  Future<void> insertVisitSection(String tableName, int visitId, Map<String, dynamic> data) async {
    final db = await database;
    final sectionData = Map<String, dynamic>.from(data);
    
    // Add metadata
    sectionData['visit_id'] = visitId;
    sectionData['created_at'] = DateTime.now().toIso8601String();
    sectionData['updated_at'] = DateTime.now().toIso8601String();

    // Remove any null values to prevent SQL issues
    sectionData.removeWhere((key, value) => value == null || (value is String && value.isEmpty));

    try {
      await db.insert(tableName, sectionData);
    } catch (e) {
      print('Error inserting into $tableName: $e');
      print('Data: $sectionData');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getVisitSection(String tableName, int visitId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'visit_id = ?',
      whereArgs: [visitId],
    );

    return maps.isNotEmpty ? maps.first : null;
  }

  Future<void> updateVisitSection(String tableName, int visitId, Map<String, dynamic> data) async {
    final db = await database;
    final sectionData = Map<String, dynamic>.from(data);
    
    sectionData['updated_at'] = DateTime.now().toIso8601String();
    sectionData.removeWhere((key, value) => value == null || (value is String && value.isEmpty));

    await db.update(
      tableName,
      sectionData,
      where: 'visit_id = ?',
      whereArgs: [visitId],
    );
  }

  // Sync-related operations
  Future<List<SupervisionForm>> getUnsyncedForms() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'supervision_forms',
      where: 'syncStatus = ? AND isActive = ?',
      whereArgs: ['local', 1],
    );

    return List.generate(maps.length, (i) {
      return SupervisionForm.fromJson(maps[i]);
    });
  }

  Future<void> markFormAsSynced(int formId, int serverId) async {
    final db = await database;
    await db.update(
      'supervision_forms',
      {
        'serverId': serverId,
        'syncStatus': 'synced',
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [formId],
    );
  }

  Future<void> markVisitAsSynced(int visitId, int serverId) async {
    final db = await database;
    await db.update(
      'supervision_visits',
      {
        'serverId': serverId,
        'syncStatus': 'synced',
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [visitId],
    );
  }

  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('supervision_forms');
    await db.delete('supervision_visits');
    await db.delete('form_staff_training');
    await db.delete('visit_admin_management_responses');
    await db.delete('visit_logistics_responses');
    await db.delete('visit_equipment_responses');
    await db.delete('visit_mhdc_management_responses');
    await db.delete('visit_service_standards_responses');
    await db.delete('visit_health_information_responses');
    await db.delete('visit_integration_responses');
  }

  // Debug helpers
  Future<void> debugPrintTableSchema(String tableName) async {
    final db = await database;
    final result = await db.rawQuery("PRAGMA table_info($tableName)");
    print('Schema for $tableName:');
    for (var row in result) {
      print('  ${row['name']}: ${row['type']}');
    }
  }

  Future<List<String>> getAllTableNames() async {
    final db = await database;
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name"
    );
    return result.map((row) => row['name'] as String).toList();
  }
}