import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';
import '../models/supervision_form_model.dart';
import '../models/supervision_visit.dart';
import '../models/staff_training_data.dart';
import '../models/infrastructure_data.dart';
import '../models/admin_management_data.dart';
import '../models/logistics_data.dart';
import '../models/equipment_data.dart';
import '../models/mhdc_management_data.dart';
import '../models/service_standards_data.dart';
import '../models/health_information_data.dart';
import '../models/integration_data.dart';
import '../models/medicine_detail.dart';
import '../models/patient_volumes.dart';
import '../models/equipment_functionality.dart';
import '../models/quality_assurance.dart';

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
      version: 4, // Increment version for comprehensive schema update
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      // Drop all existing tables to recreate with comprehensive schema
      await _dropAllTables(db);
      await _onCreate(db, newVersion);
    }
  }

  Future<void> _dropAllTables(Database db) async {
    final tables = [
      'supervision_forms', 'supervision_visits', 'form_staff_training', 'form_infrastructure',
      'visit_admin_management_responses', 'visit_logistics_responses', 'visit_equipment_responses',
      'visit_mhdc_management_responses', 'visit_service_standards_responses', 
      'visit_health_information_responses', 'visit_integration_responses',
      'visit_medicine_details', 'visit_patient_volumes', 'visit_equipment_functionality',
      'visit_quality_assurance'
    ];
    
    for (final table in tables) {
      await db.execute('DROP TABLE IF EXISTS $table');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create supervision_forms table
    await db.execute('''
      CREATE TABLE supervision_forms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        temp_id TEXT UNIQUE NOT NULL,
        server_id INTEGER,
        health_facility_name TEXT NOT NULL,
        province TEXT NOT NULL,
        district TEXT NOT NULL,
        user_id INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        sync_status TEXT DEFAULT 'local',
        is_active INTEGER DEFAULT 1
      )
    ''');

    // Create supervision_visits table
    await db.execute('''
      CREATE TABLE supervision_visits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        temp_id TEXT UNIQUE NOT NULL,
        server_id INTEGER,
        form_id INTEGER NOT NULL,
        visit_number INTEGER NOT NULL,
        visit_date TEXT NOT NULL,
        recommendations TEXT,
        actions_agreed TEXT,
        supervisor_signature TEXT,
        facility_representative_signature TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        sync_status TEXT DEFAULT 'local',
        FOREIGN KEY (form_id) REFERENCES supervision_forms (id),
        UNIQUE(form_id, visit_number)
      )
    ''');

    // Create form-level data tables
    await _createFormDataTables(db);
    
    // Create visit section tables
    await _createVisitSectionTables(db);
  }

  Future<void> _createFormDataTables(Database db) async {
    // Staff Training table
    await db.execute('''
      CREATE TABLE form_staff_training (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        form_id INTEGER NOT NULL,
        ha_total_staff INTEGER,
        ha_mhdc_trained INTEGER,
        ha_fen_trained INTEGER,
        ha_other_ncd_trained INTEGER,
        sr_ahw_total_staff INTEGER,
        sr_ahw_mhdc_trained INTEGER,
        sr_ahw_fen_trained INTEGER,
        sr_ahw_other_ncd_trained INTEGER,
        ahw_total_staff INTEGER,
        ahw_mhdc_trained INTEGER,
        ahw_fen_trained INTEGER,
        ahw_other_ncd_trained INTEGER,
        sr_anm_total_staff INTEGER,
        sr_anm_mhdc_trained INTEGER,
        sr_anm_fen_trained INTEGER,
        sr_anm_other_ncd_trained INTEGER,
        anm_total_staff INTEGER,
        anm_mhdc_trained INTEGER,
        anm_fen_trained INTEGER,
        anm_other_ncd_trained INTEGER,
        others_total_staff INTEGER,
        others_mhdc_trained INTEGER,
        others_fen_trained INTEGER,
        others_other_ncd_trained INTEGER,
        last_mhdc_training_date TEXT,
        last_fen_training_date TEXT,
        last_other_training_date TEXT,
        training_provider TEXT,
        training_certificates_verified INTEGER,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (form_id) REFERENCES supervision_forms (id)
      )
    ''');

    // Infrastructure table
    await db.execute('''
      CREATE TABLE form_infrastructure (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        form_id INTEGER NOT NULL,
        total_rooms INTEGER,
        consultation_rooms INTEGER,
        waiting_area_adequate INTEGER,
        waiting_area_capacity INTEGER,
        pharmacy_storage_adequate INTEGER,
        pharmacy_storage_size_sqm REAL,
        cold_chain_available INTEGER,
        cold_chain_temperature_monitored INTEGER,
        medicine_storage_conditions_appropriate INTEGER,
        generator_backup INTEGER,
        generator_capacity_kw REAL,
        water_supply_reliable INTEGER,
        water_storage_capacity_liters INTEGER,
        electricity_stable INTEGER,
        internet_connectivity INTEGER,
        waste_disposal_system INTEGER,
        sharps_disposal_appropriate INTEGER,
        biomedical_waste_segregation INTEGER,
        accessibility_features INTEGER,
        wheelchair_accessible INTEGER,
        fire_safety_equipment INTEGER,
        emergency_protocols_displayed INTEGER,
        laboratory_available INTEGER,
        xray_available INTEGER,
        ambulance_service INTEGER,
        assessment_date TEXT,
        assessed_by TEXT,
        infrastructure_score INTEGER,
        priority_improvements TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (form_id) REFERENCES supervision_forms (id)
      )
    ''');
  }

  Future<void> _createVisitSectionTables(Database db) async {
    // Admin Management table
    await db.execute('''
      CREATE TABLE visit_admin_management_responses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        visit_id INTEGER NOT NULL,
        a1_response TEXT,
        a1_comment TEXT,
        a1_respondents_comment TEXT,
        a2_response TEXT,
        a2_comment TEXT,
        a2_respondents_comment TEXT,
        a3_response TEXT,
        a3_comment TEXT,
        a3_respondents_comment TEXT,
        actions_agreed TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (visit_id) REFERENCES supervision_visits (id)
      )
    ''');

    // Logistics table - comprehensive medicine tracking
    await db.execute('''
      CREATE TABLE visit_logistics_responses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        visit_id INTEGER NOT NULL,
        -- Antihypertensives
        amlodipine_5_10mg TEXT,
        amlodipine_5_10mg_quantity INTEGER,
        amlodipine_5_10mg_units TEXT,
        enalapril_2_5_10mg TEXT,
        enalapril_2_5_10mg_quantity INTEGER,
        enalapril_2_5_10mg_units TEXT,
        losartan_25_50mg TEXT,
        losartan_25_50mg_quantity INTEGER,
        losartan_25_50mg_units TEXT,
        hydrochlorothiazide_12_5_25mg TEXT,
        hydrochlorothiazide_12_5_25mg_quantity INTEGER,
        hydrochlorothiazide_12_5_25mg_units TEXT,
        chlorthalidone_6_25_12_5mg TEXT,
        chlorthalidone_6_25_12_5mg_quantity INTEGER,
        chlorthalidone_6_25_12_5mg_units TEXT,
        other_antihypertensives TEXT,
        other_antihypertensives_quantity INTEGER,
        other_antihypertensives_units TEXT,
        other_antihypertensives_specify TEXT,
        -- Statins
        atorvastatin_5mg TEXT,
        atorvastatin_5mg_quantity INTEGER,
        atorvastatin_5mg_units TEXT,
        atorvastatin_10mg TEXT,
        atorvastatin_10mg_quantity INTEGER,
        atorvastatin_10mg_units TEXT,
        atorvastatin_20mg TEXT,
        atorvastatin_20mg_quantity INTEGER,
        atorvastatin_20mg_units TEXT,
        other_statins TEXT,
        other_statins_quantity INTEGER,
        other_statins_units TEXT,
        other_statins_specify TEXT,
        -- Diabetes medications
        metformin_500mg TEXT,
        metformin_500mg_quantity INTEGER,
        metformin_500mg_units TEXT,
        metformin_1000mg TEXT,
        metformin_1000mg_quantity INTEGER,
        metformin_1000mg_units TEXT,
        glimepiride_1_2mg TEXT,
        glimepiride_1_2mg_quantity INTEGER,
        glimepiride_1_2mg_units TEXT,
        gliclazide_40_80mg TEXT,
        gliclazide_40_80mg_quantity INTEGER,
        gliclazide_40_80mg_units TEXT,
        glipizide_2_5_5mg TEXT,
        glipizide_2_5_5mg_quantity INTEGER,
        glipizide_2_5_5mg_units TEXT,
        sitagliptin_50mg TEXT,
        sitagliptin_50mg_quantity INTEGER,
        sitagliptin_50mg_units TEXT,
        pioglitazone_5mg TEXT,
        pioglitazone_5mg_quantity INTEGER,
        pioglitazone_5mg_units TEXT,
        empagliflozin_10mg TEXT,
        empagliflozin_10mg_quantity INTEGER,
        empagliflozin_10mg_units TEXT,
        insulin_soluble_inj TEXT,
        insulin_soluble_inj_quantity INTEGER,
        insulin_soluble_inj_units TEXT,
        insulin_nph_inj TEXT,
        insulin_nph_inj_quantity INTEGER,
        insulin_nph_inj_units TEXT,
        other_hypoglycemic_agents TEXT,
        other_hypoglycemic_agents_quantity INTEGER,
        other_hypoglycemic_agents_units TEXT,
        other_hypoglycemic_agents_specify TEXT,
        -- Emergency and cardiovascular
        dextrose_25_solution TEXT,
        dextrose_25_solution_quantity INTEGER,
        dextrose_25_solution_units TEXT,
        aspirin_75mg TEXT,
        aspirin_75mg_quantity INTEGER,
        aspirin_75mg_units TEXT,
        clopidogrel_75mg TEXT,
        clopidogrel_75mg_quantity INTEGER,
        clopidogrel_75mg_units TEXT,
        metoprolol_succinate_12_5_25_50mg TEXT,
        metoprolol_succinate_12_5_25_50mg_quantity INTEGER,
        metoprolol_succinate_12_5_25_50mg_units TEXT,
        isosorbide_dinitrate_5mg TEXT,
        isosorbide_dinitrate_5mg_quantity INTEGER,
        isosorbide_dinitrate_5mg_units TEXT,
        other_drugs TEXT,
        other_drugs_quantity INTEGER,
        other_drugs_units TEXT,
        other_drugs_specify TEXT,
        -- Antibiotics
        amoxicillin_clavulanic_potassium_625mg TEXT,
        amoxicillin_clavulanic_potassium_625mg_quantity INTEGER,
        amoxicillin_clavulanic_potassium_625mg_units TEXT,
        azithromycin_500mg TEXT,
        azithromycin_500mg_quantity INTEGER,
        azithromycin_500mg_units TEXT,
        other_antibiotics TEXT,
        other_antibiotics_quantity INTEGER,
        other_antibiotics_units TEXT,
        other_antibiotics_specify TEXT,
        -- Respiratory
        salbutamol_dpi TEXT,
        salbutamol_dpi_quantity INTEGER,
        salbutamol_dpi_units TEXT,
        salbutamol TEXT,
        salbutamol_quantity INTEGER,
        salbutamol_units TEXT,
        ipratropium TEXT,
        ipratropium_quantity INTEGER,
        ipratropium_units TEXT,
        tiotropium_bromide TEXT,
        tiotropium_bromide_quantity INTEGER,
        tiotropium_bromide_units TEXT,
        formoterol TEXT,
        formoterol_quantity INTEGER,
        formoterol_units TEXT,
        other_bronchodilators TEXT,
        other_bronchodilators_quantity INTEGER,
        other_bronchodilators_units TEXT,
        other_bronchodilators_specify TEXT,
        prednisolone_5_10_20mg TEXT,
        prednisolone_5_10_20mg_quantity INTEGER,
        prednisolone_5_10_20mg_units TEXT,
        other_steroids_oral TEXT,
        other_steroids_oral_quantity INTEGER,
        other_steroids_oral_units TEXT,
        other_steroids_oral_specify TEXT,
        -- B1-B5 responses
        b1_response TEXT,
        b1_comment TEXT,
        b1_respondents_comment TEXT,
        b1_validation_note TEXT,
        b2_response TEXT,
        b2_comment TEXT,
        b2_respondents_comment TEXT,
        b2_validation_note TEXT,
        b2_random_records_checked INTEGER,
        b2_explanation_if_not_in_use TEXT,
        b3_response TEXT,
        b3_comment TEXT,
        b3_respondents_comment TEXT,
        b3_validation_note TEXT,
        b3_expiry_date_verified INTEGER,
        b3_storage_conditions_verified INTEGER,
        b4_response TEXT,
        b4_comment TEXT,
        b4_respondents_comment TEXT,
        b4_validation_note TEXT,
        b4_expiry_date_verified INTEGER,
        b4_storage_conditions_verified INTEGER,
        b5_response TEXT,
        b5_comment TEXT,
        b5_respondents_comment TEXT,
        b5_validation_note TEXT,
        -- Category-specific comments
        antihypertensive_comments TEXT,
        statin_comments TEXT,
        diabetes_medication_comments TEXT,
        cardiovascular_medication_comments TEXT,
        respiratory_medication_comments TEXT,
        -- Additional tracking
        expiry_dates_checked INTEGER,
        storage_conditions_verified INTEGER,
        actions_agreed TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (visit_id) REFERENCES supervision_visits (id)
      )
    ''');

    // Equipment table - comprehensive equipment tracking
    await db.execute('''
      CREATE TABLE visit_equipment_responses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        visit_id INTEGER NOT NULL,
        -- Equipment with quantities and units
        sphygmomanometer TEXT,
        sphygmomanometer_quantity INTEGER,
        sphygmomanometer_units TEXT,
        weighing_scale TEXT,
        weighing_scale_quantity INTEGER,
        weighing_scale_units TEXT,
        measuring_tape TEXT,
        measuring_tape_quantity INTEGER,
        measuring_tape_units TEXT,
        peak_expiratory_flow_meter TEXT,
        peak_expiratory_flow_meter_quantity INTEGER,
        peak_expiratory_flow_meter_units TEXT,
        oxygen TEXT,
        oxygen_quantity INTEGER,
        oxygen_units TEXT,
        oxygen_mask TEXT,
        oxygen_mask_quantity INTEGER,
        oxygen_mask_units TEXT,
        nebulizer TEXT,
        nebulizer_quantity INTEGER,
        nebulizer_units TEXT,
        pulse_oximetry TEXT,
        pulse_oximetry_quantity INTEGER,
        pulse_oximetry_units TEXT,
        glucometer TEXT,
        glucometer_quantity INTEGER,
        glucometer_units TEXT,
        glucometer_strips TEXT,
        glucometer_strips_quantity INTEGER,
        glucometer_strips_units TEXT,
        lancets TEXT,
        lancets_quantity INTEGER,
        lancets_units TEXT,
        urine_dipstick TEXT,
        urine_dipstick_quantity INTEGER,
        urine_dipstick_units TEXT,
        ecg TEXT,
        ecg_quantity INTEGER,
        ecg_units TEXT,
        other_equipment TEXT,
        other_equipment_quantity INTEGER,
        other_equipment_units TEXT,
        other_equipment_specify TEXT,
        stethoscope TEXT,
        stethoscope_quantity INTEGER,
        thermometer TEXT,
        thermometer_quantity INTEGER,
        examination_table TEXT,
        examination_table_quantity INTEGER,
        privacy_screen TEXT,
        privacy_screen_quantity INTEGER,
        actions_agreed TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (visit_id) REFERENCES supervision_visits (id)
      )
    ''');

    // MHDC Management table
    await db.execute('''
      CREATE TABLE visit_mhdc_management_responses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        visit_id INTEGER NOT NULL,
        b6_response TEXT,
        b6_comment TEXT,
        b6_respondents_comment TEXT,
        b6_healthcare_workers_refer_easily INTEGER,
        b6_kept_in_opd_use INTEGER,
        b7_response TEXT,
        b7_comment TEXT,
        b7_respondents_comment TEXT,
        b7_available_at_health_center INTEGER,
        b8_response TEXT,
        b8_comment TEXT,
        b8_respondents_comment TEXT,
        b8_available_and_filled_properly INTEGER,
        b9_response TEXT,
        b9_comment TEXT,
        b9_respondents_comment TEXT,
        b9_available_for_patient_care INTEGER,
        b9_chart_version TEXT,
        b9_chart_condition TEXT,
        b10_response TEXT,
        b10_comment TEXT,
        b10_respondents_comment TEXT,
        b10_in_use_for_patient_care INTEGER,
        b10_staff_trained_on_chart INTEGER,
        b10_charts_completed_during_visit INTEGER,
        b10_risk_stratification_accurate INTEGER,
        actions_agreed TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (visit_id) REFERENCES supervision_visits (id)
      )
    ''');

    // Service Standards table - comprehensive C2 sub-services
    await db.execute('''
      CREATE TABLE visit_service_standards_responses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        visit_id INTEGER NOT NULL,
        -- C2 main response
        c2_main_response TEXT,
        c2_main_comment TEXT,
        c2_respondents_comment TEXT,
        -- C2 sub-services
        c2_blood_pressure TEXT,
        c2_blood_pressure_comment TEXT,
        c2_blood_pressure_equipment_calibrated INTEGER,
        c2_blood_pressure_protocol_followed INTEGER,
        c2_blood_sugar TEXT,
        c2_blood_sugar_comment TEXT,
        c2_blood_sugar_strips_available INTEGER,
        c2_blood_sugar_quality_control INTEGER,
        c2_bmi_measurement TEXT,
        c2_bmi_measurement_comment TEXT,
        c2_bmi_calculation_accurate INTEGER,
        c2_waist_circumference TEXT,
        c2_waist_circumference_comment TEXT,
        c2_waist_measurement_technique_correct INTEGER,
        c2_cvd_risk_estimation TEXT,
        c2_cvd_risk_estimation_comment TEXT,
        c2_cvd_chart_available_and_used INTEGER,
        c2_urine_protein_measurement TEXT,
        c2_urine_protein_measurement_comment TEXT,
        c2_urine_protein_strips_not_expired INTEGER,
        c2_peak_expiratory_flow_rate TEXT,
        c2_peak_expiratory_flow_rate_comment TEXT,
        c2_peak_flow_meter_calibrated INTEGER,
        c2_egfr_calculation TEXT,
        c2_egfr_calculation_comment TEXT,
        c2_egfr_formula_used_correctly INTEGER,
        c2_brief_intervention TEXT,
        c2_brief_intervention_comment TEXT,
        c2_foot_examination TEXT,
        c2_foot_examination_comment TEXT,
        c2_oral_examination TEXT,
        c2_oral_examination_comment TEXT,
        c2_eye_examination TEXT,
        c2_eye_examination_comment TEXT,
        c2_health_education TEXT,
        c2_health_education_comment TEXT,
        -- C3-C7 responses
        c3_response TEXT,
        c3_comment TEXT,
        c3_respondents_comment TEXT,
        c4_response TEXT,
        c4_comment TEXT,
        c4_respondents_comment TEXT,
        c5_response TEXT,
        c5_comment TEXT,
        c5_respondents_comment TEXT,
        c6_response TEXT,
        c6_comment TEXT,
        c6_respondents_comment TEXT,
        c7_response TEXT,
        c7_comment TEXT,
        c7_respondents_comment TEXT,
        actions_agreed TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (visit_id) REFERENCES supervision_visits (id)
      )
    ''');

    // Health Information table
    await db.execute('''
      CREATE TABLE visit_health_information_responses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        visit_id INTEGER NOT NULL,
        d1_response TEXT,
        d1_comment TEXT,
        d1_respondents_comment TEXT,
        d2_response TEXT,
        d2_comment TEXT,
        d2_respondents_comment TEXT,
        d3_response TEXT,
        d3_comment TEXT,
        d3_respondents_comment TEXT,
        d4_response TEXT,
        d4_comment TEXT,
        d4_respondents_comment TEXT,
        d4_number_of_people INTEGER,
        d4_previous_month_data INTEGER,
        d5_response TEXT,
        d5_comment TEXT,
        d5_respondents_comment TEXT,
        actions_agreed TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (visit_id) REFERENCES supervision_visits (id)
      )
    ''');

    // Integration table
    await db.execute('''
      CREATE TABLE visit_integration_responses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        visit_id INTEGER NOT NULL,
        e1_response TEXT,
        e1_comment TEXT,
        e1_respondents_comment TEXT,
        e2_response TEXT,
        e2_comment TEXT,
        e2_respondents_comment TEXT,
        e3_response TEXT,
        e3_comment TEXT,
        e3_respondents_comment TEXT,
        actions_agreed TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (visit_id) REFERENCES supervision_visits (id)
      )
    ''');

    // Medicine Details table - for detailed medicine tracking
    await db.execute('''
      CREATE TABLE visit_medicine_details (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        visit_id INTEGER NOT NULL,
        medicine_name TEXT NOT NULL,
        medicine_category TEXT,
        availability TEXT,
        quantity_available INTEGER,
        unit_of_measurement TEXT,
        expiry_date TEXT,
        batch_number TEXT,
        storage_temperature_ok INTEGER,
        storage_humidity_ok INTEGER,
        storage_location TEXT,
        procurement_source TEXT,
        cost_per_unit REAL,
        last_restocked_date TEXT,
        minimum_stock_level INTEGER,
        stock_out_frequency TEXT,
        quality_issues_noted TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (visit_id) REFERENCES supervision_visits (id)
      )
    ''');

    // Patient Volumes table
    await db.execute('''
      CREATE TABLE visit_patient_volumes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        visit_id INTEGER NOT NULL,
        total_patients_seen INTEGER,
        ncd_patients_new INTEGER,
        ncd_patients_followup INTEGER,
        diabetes_patients INTEGER,
        hypertension_patients INTEGER,
        copd_patients INTEGER,
        cardiovascular_patients INTEGER,
        other_ncd_patients INTEGER,
        referrals_made INTEGER,
        referrals_received INTEGER,
        emergency_cases INTEGER,
        month_year TEXT,
        data_source TEXT,
        data_verified INTEGER,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (visit_id) REFERENCES supervision_visits (id)
      )
    ''');

    // Equipment Functionality table - for detailed equipment assessment
    await db.execute('''
      CREATE TABLE visit_equipment_functionality (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        visit_id INTEGER NOT NULL,
        equipment_name TEXT NOT NULL,
        equipment_category TEXT,
        brand_model TEXT,
        serial_number TEXT,
        availability TEXT,
        functionality_status TEXT,
        last_calibration_date TEXT,
        calibration_due_date TEXT,
        maintenance_schedule TEXT,
        usage_frequency TEXT,
        staff_trained_on_equipment INTEGER,
        user_manual_available INTEGER,
        spare_parts_available INTEGER,
        warranty_status TEXT,
        issues_noted TEXT,
        repair_history TEXT,
        procurement_date TEXT,
        cost REAL,
        funding_source TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (visit_id) REFERENCES supervision_visits (id)
      )
    ''');

    // Quality Assurance table
    await db.execute('''
      CREATE TABLE visit_quality_assurance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        visit_id INTEGER NOT NULL,
        guidelines_followed INTEGER,
        protocols_updated INTEGER,
        clinical_audit_conducted INTEGER,
        patient_satisfaction_assessed INTEGER,
        records_complete INTEGER,
        documentation_legible INTEGER,
        consent_forms_used INTEGER,
        privacy_maintained INTEGER,
        infection_control_practices INTEGER,
        hand_hygiene_facilities INTEGER,
        emergency_procedures_known INTEGER,
        adverse_events_reported INTEGER,
        staff_knowledge_adequate INTEGER,
        continuing_education_provided INTEGER,
        supervision_regular INTEGER,
        overall_quality_score INTEGER,
        areas_for_improvement TEXT,
        good_practices_observed TEXT,
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
      'temp_id': form.tempId,
      'health_facility_name': form.healthFacilityName,
      'province': form.province,
      'district': form.district,
      'created_at': form.createdAt.toIso8601String(),
      'updated_at': form.updatedAt.toIso8601String(),
      'sync_status': form.syncStatus,
      'is_active': form.isActive ? 1 : 0,
    };
    
    if (form.serverId != null) formData['server_id'] = form.serverId!;
    if (form.userId != null) formData['user_id'] = form.userId!;
    
    return await db.insert('supervision_forms', formData);
  }

  Future<List<SupervisionForm>> getForms() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'supervision_forms',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'updated_at DESC',
    );

    return List.generate(maps.length, (i) {
      return SupervisionForm.fromJson(maps[i]);
    });
  }

  Future<SupervisionForm?> getFormById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'supervision_forms',
      where: 'id = ? AND is_active = ?',
      whereArgs: [id, 1],
    );

    if (maps.isNotEmpty) {
      return SupervisionForm.fromJson(maps.first);
    }
    return null;
  }

  Future<void> updateForm(SupervisionForm form) async {
    final db = await database;
    final formData = {
      'temp_id': form.tempId,
      'health_facility_name': form.healthFacilityName,
      'province': form.province,
      'district': form.district,
      'created_at': form.createdAt.toIso8601String(),
      'updated_at': form.updatedAt.toIso8601String(),
      'sync_status': form.syncStatus,
      'is_active': form.isActive ? 1 : 0,
    };
    
    if (form.serverId != null) formData['server_id'] = form.serverId!;
    if (form.userId != null) formData['user_id'] = form.userId!;

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
      {'is_active': 0, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Visit operations
  Future<int> insertVisit(SupervisionVisit visit) async {
    final db = await database;
    
    final visitData = <String, Object?>{
      'temp_id': visit.tempId,
      'form_id': visit.formId,
      'visit_number': visit.visitNumber,
      'visit_date': visit.visitDate.toIso8601String(),
      'created_at': visit.createdAt.toIso8601String(),
      'updated_at': visit.updatedAt.toIso8601String(),
      'sync_status': visit.syncStatus,
    };
    
    if (visit.serverId != null) visitData['server_id'] = visit.serverId;
    if (visit.recommendations != null) visitData['recommendations'] = visit.recommendations;
    if (visit.actionsAgreed != null) visitData['actions_agreed'] = visit.actionsAgreed;
    if (visit.supervisorSignature != null) visitData['supervisor_signature'] = visit.supervisorSignature;
    if (visit.facilityRepresentativeSignature != null) visitData['facility_representative_signature'] = visit.facilityRepresentativeSignature;
    
    return await db.insert('supervision_visits', visitData);
  }

  Future<List<SupervisionVisit>> getVisitsByFormId(int formId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'supervision_visits',
      where: 'form_id = ?',
      whereArgs: [formId],
      orderBy: 'visit_number ASC',
    );

    return List.generate(maps.length, (i) {
      return SupervisionVisit.fromJson(maps[i]);
    });
  }

  Future<void> updateVisit(SupervisionVisit visit) async {
    final db = await database;
    final visitData = <String, Object?>{
      'temp_id': visit.tempId,
      'form_id': visit.formId,
      'visit_number': visit.visitNumber,
      'visit_date': visit.visitDate.toIso8601String(),
      'created_at': visit.createdAt.toIso8601String(),
      'updated_at': visit.updatedAt.toIso8601String(),
      'sync_status': visit.syncStatus,
    };
    
    if (visit.serverId != null) visitData['server_id'] = visit.serverId;
    if (visit.recommendations != null) visitData['recommendations'] = visit.recommendations;
    if (visit.actionsAgreed != null) visitData['actions_agreed'] = visit.actionsAgreed;
    if (visit.supervisorSignature != null) visitData['supervisor_signature'] = visit.supervisorSignature;
    if (visit.facilityRepresentativeSignature != null) visitData['facility_representative_signature'] = visit.facilityRepresentativeSignature;

    await db.update(
      'supervision_visits',
      visitData,
      where: 'id = ?',
      whereArgs: [visit.id],
    );
  }

  Future<void> deleteVisit(int visitId) async {
    final db = await database;
    
    // Delete visit sections first (foreign key constraints)
    final tables = [
      'visit_admin_management_responses',
      'visit_logistics_responses', 
      'visit_equipment_responses',
      'visit_mhdc_management_responses',
      'visit_service_standards_responses',
      'visit_health_information_responses',
      'visit_integration_responses',
      'visit_medicine_details',
      'visit_patient_volumes',
      'visit_equipment_functionality',
      'visit_quality_assurance'
    ];
    
    for (final table in tables) {
      await db.delete(table, where: 'visit_id = ?', whereArgs: [visitId]);
    }
    
    // Delete the visit itself
    await db.delete('supervision_visits', where: 'id = ?', whereArgs: [visitId]);
  }

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

  // Staff training operations
  Future<void> insertStaffTraining(int formId, StaffTrainingData staffTraining) async {
    final db = await database;
    
    final data = staffTraining.toJson();
    data['form_id'] = formId;
    data['created_at'] = DateTime.now().toIso8601String();
    data['updated_at'] = DateTime.now().toIso8601String();
    
    await db.insert('form_staff_training', data);
  }

  Future<void> updateStaffTraining(int formId, StaffTrainingData staffTraining) async {
    final db = await database;
    
    final data = staffTraining.toJson();
    data['updated_at'] = DateTime.now().toIso8601String();

    await db.update(
      'form_staff_training',
      data,
      where: 'form_id = ?',
      whereArgs: [formId],
    );
  }

  Future<StaffTrainingData?> getStaffTrainingByFormId(int formId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'form_staff_training',
      where: 'form_id = ?',
      whereArgs: [formId],
    );

    return maps.isNotEmpty ? StaffTrainingData.fromJson(maps.first) : null;
  }

  // Infrastructure operations
  Future<void> insertInfrastructure(int formId, InfrastructureData infrastructure) async {
    final db = await database;
    
    final data = infrastructure.toJson();
    data['form_id'] = formId;
    data['created_at'] = DateTime.now().toIso8601String();
    data['updated_at'] = DateTime.now().toIso8601String();
    
    await db.insert('form_infrastructure', data);
  }

  Future<void> updateInfrastructure(int formId, InfrastructureData infrastructure) async {
    final db = await database;
    
    final data = infrastructure.toJson();
    data['updated_at'] = DateTime.now().toIso8601String();

    await db.update(
      'form_infrastructure',
      data,
      where: 'form_id = ?',
      whereArgs: [formId],
    );
  }

  Future<InfrastructureData?> getInfrastructureByFormId(int formId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'form_infrastructure',
      where: 'form_id = ?',
      whereArgs: [formId],
    );

    return maps.isNotEmpty ? InfrastructureData.fromJson(maps.first) : null;
  }

  // Visit section operations
  Future<void> insertAdminManagement(int visitId, AdminManagementData data) async {
    final db = await database;
    final sectionData = data.toJson();
    sectionData['visit_id'] = visitId;
    sectionData['created_at'] = DateTime.now().toIso8601String();
    sectionData['updated_at'] = DateTime.now().toIso8601String();
    await db.insert('visit_admin_management_responses', sectionData);
  }

  Future<AdminManagementData?> getAdminManagement(int visitId) async {
    final db = await database;
    final maps = await db.query(
      'visit_admin_management_responses',
      where: 'visit_id = ?',
      whereArgs: [visitId],
    );
    return maps.isNotEmpty ? AdminManagementData.fromJson(maps.first) : null;
  }

  Future<void> insertLogistics(int visitId, LogisticsData data) async {
    final db = await database;
    final sectionData = data.toJson();
    sectionData['visit_id'] = visitId;
    sectionData['created_at'] = DateTime.now().toIso8601String();
    sectionData['updated_at'] = DateTime.now().toIso8601String();
    await db.insert('visit_logistics_responses', sectionData);
  }

  Future<LogisticsData?> getLogistics(int visitId) async {
    final db = await database;
    final maps = await db.query(
      'visit_logistics_responses',
      where: 'visit_id = ?',
      whereArgs: [visitId],
    );
    return maps.isNotEmpty ? LogisticsData.fromJson(maps.first) : null;
  }

  Future<void> insertEquipment(int visitId, EquipmentData data) async {
    final db = await database;
    final sectionData = data.toJson();
    sectionData['visit_id'] = visitId;
    sectionData['created_at'] = DateTime.now().toIso8601String();
    sectionData['updated_at'] = DateTime.now().toIso8601String();
    await db.insert('visit_equipment_responses', sectionData);
  }

  Future<EquipmentData?> getEquipment(int visitId) async {
    final db = await database;
    final maps = await db.query(
      'visit_equipment_responses',
      where: 'visit_id = ?',
      whereArgs: [visitId],
    );
    return maps.isNotEmpty ? EquipmentData.fromJson(maps.first) : null;
  }

  Future<void> insertMhdcManagement(int visitId, MhdcManagementData data) async {
    final db = await database;
    final sectionData = data.toJson();
    sectionData['visit_id'] = visitId;
    sectionData['created_at'] = DateTime.now().toIso8601String();
    sectionData['updated_at'] = DateTime.now().toIso8601String();
    await db.insert('visit_mhdc_management_responses', sectionData);
  }

  Future<MhdcManagementData?> getMhdcManagement(int visitId) async {
    final db = await database;
    final maps = await db.query(
      'visit_mhdc_management_responses',
      where: 'visit_id = ?',
      whereArgs: [visitId],
    );
    return maps.isNotEmpty ? MhdcManagementData.fromJson(maps.first) : null;
  }

  Future<void> insertServiceStandards(int visitId, ServiceStandardsData data) async {
    final db = await database;
    final sectionData = data.toJson();
    sectionData['visit_id'] = visitId;
    sectionData['created_at'] = DateTime.now().toIso8601String();
    sectionData['updated_at'] = DateTime.now().toIso8601String();
    await db.insert('visit_service_standards_responses', sectionData);
  }

  Future<ServiceStandardsData?> getServiceStandards(int visitId) async {
    final db = await database;
    final maps = await db.query(
      'visit_service_standards_responses',
      where: 'visit_id = ?',
      whereArgs: [visitId],
    );
    return maps.isNotEmpty ? ServiceStandardsData.fromJson(maps.first) : null;
  }

  Future<void> insertHealthInformation(int visitId, HealthInformationData data) async {
    final db = await database;
    final sectionData = data.toJson();
    sectionData['visit_id'] = visitId;
    sectionData['created_at'] = DateTime.now().toIso8601String();
    sectionData['updated_at'] = DateTime.now().toIso8601String();
    await db.insert('visit_health_information_responses', sectionData);
  }

  Future<HealthInformationData?> getHealthInformation(int visitId) async {
    final db = await database;
    final maps = await db.query(
      'visit_health_information_responses',
      where: 'visit_id = ?',
      whereArgs: [visitId],
    );
    return maps.isNotEmpty ? HealthInformationData.fromJson(maps.first) : null;
  }

  Future<void> insertIntegration(int visitId, IntegrationData data) async {
    final db = await database;
    final sectionData = data.toJson();
    sectionData['visit_id'] = visitId;
    sectionData['created_at'] = DateTime.now().toIso8601String();
    sectionData['updated_at'] = DateTime.now().toIso8601String();
    await db.insert('visit_integration_responses', sectionData);
  }

  Future<IntegrationData?> getIntegration(int visitId) async {
    final db = await database;
    final maps = await db.query(
      'visit_integration_responses',
      where: 'visit_id = ?',
      whereArgs: [visitId],
    );
    return maps.isNotEmpty ? IntegrationData.fromJson(maps.first) : null;
  }

  // Medicine details operations
  Future<void> insertMedicineDetails(int visitId, List<MedicineDetail> medicines) async {
    final db = await database;
    for (final medicine in medicines) {
      final data = medicine.toJson();
      data['visit_id'] = visitId;
      data['created_at'] = DateTime.now().toIso8601String();
      data['updated_at'] = DateTime.now().toIso8601String();
      await db.insert('visit_medicine_details', data);
    }
  }

  Future<List<MedicineDetail>> getMedicineDetails(int visitId) async {
    final db = await database;
    final maps = await db.query(
      'visit_medicine_details',
      where: 'visit_id = ?',
      whereArgs: [visitId],
    );
    return maps.map((map) => MedicineDetail.fromJson(map)).toList();
  }

  // Patient volumes operations
  Future<void> insertPatientVolumes(int visitId, PatientVolumes data) async {
    final db = await database;
    final sectionData = data.toJson();
    sectionData['visit_id'] = visitId;
    sectionData['created_at'] = DateTime.now().toIso8601String();
    sectionData['updated_at'] = DateTime.now().toIso8601String();
    await db.insert('visit_patient_volumes', sectionData);
  }

  Future<PatientVolumes?> getPatientVolumes(int visitId) async {
    final db = await database;
    final maps = await db.query(
      'visit_patient_volumes',
      where: 'visit_id = ?',
      whereArgs: [visitId],
    );
    return maps.isNotEmpty ? PatientVolumes.fromJson(maps.first) : null;
  }

  // Equipment functionality operations
  Future<void> insertEquipmentFunctionality(int visitId, List<EquipmentFunctionality> equipment) async {
    final db = await database;
    for (final item in equipment) {
      final data = item.toJson();
      data['visit_id'] = visitId;
      data['created_at'] = DateTime.now().toIso8601String();
      data['updated_at'] = DateTime.now().toIso8601String();
      await db.insert('visit_equipment_functionality', data);
    }
  }

  Future<List<EquipmentFunctionality>> getEquipmentFunctionality(int visitId) async {
    final db = await database;
    final maps = await db.query(
      'visit_equipment_functionality',
      where: 'visit_id = ?',
      whereArgs: [visitId],
    );
    return maps.map((map) => EquipmentFunctionality.fromJson(map)).toList();
  }

  // Quality assurance operations
  Future<void> insertQualityAssurance(int visitId, QualityAssurance data) async {
    final db = await database;
    final sectionData = data.toJson();
    sectionData['visit_id'] = visitId;
    sectionData['created_at'] = DateTime.now().toIso8601String();
    sectionData['updated_at'] = DateTime.now().toIso8601String();
    await db.insert('visit_quality_assurance', sectionData);
  }

  Future<QualityAssurance?> getQualityAssurance(int visitId) async {
    final db = await database;
    final maps = await db.query(
      'visit_quality_assurance',
      where: 'visit_id = ?',
      whereArgs: [visitId],
    );
    return maps.isNotEmpty ? QualityAssurance.fromJson(maps.first) : null;
  }

  // Enhanced visit loading with all sections
  Future<SupervisionVisit?> getCompleteVisit(int visitId) async {
    final visit = await getVisitById(visitId);
    if (visit == null) return null;

    // Load all sections
    final adminManagement = await getAdminManagement(visitId);
    final logistics = await getLogistics(visitId);
    final equipment = await getEquipment(visitId);
    final mhdcManagement = await getMhdcManagement(visitId);
    final serviceStandards = await getServiceStandards(visitId);
    final healthInformation = await getHealthInformation(visitId);
    final integration = await getIntegration(visitId);
    final medicineDetails = await getMedicineDetails(visitId);
    final patientVolumes = await getPatientVolumes(visitId);
    final equipmentFunctionality = await getEquipmentFunctionality(visitId);
    final qualityAssurance = await getQualityAssurance(visitId);

    return visit.copyWith(
      adminManagement: adminManagement,
      logistics: logistics,
      equipment: equipment,
      mhdcManagement: mhdcManagement,
      serviceStandards: serviceStandards,
      healthInformation: healthInformation,
      integration: integration,
      medicineDetails: medicineDetails.isNotEmpty ? medicineDetails : null,
      patientVolumes: patientVolumes,
      equipmentFunctionality: equipmentFunctionality.isNotEmpty ? equipmentFunctionality : null,
      qualityAssurance: qualityAssurance,
    );
  }

  // Enhanced form loading with all data
  Future<SupervisionForm?> getCompleteForm(int formId) async {
    final form = await getFormById(formId);
    if (form == null) return null;

    // Load visits with all their sections
    final visits = await getVisitsByFormId(formId);
    final completeVisits = <SupervisionVisit>[];

    for (final visit in visits) {
      final completeVisit = await getCompleteVisit(visit.id!);
      if (completeVisit != null) {
        completeVisits.add(completeVisit);
      }
    }

    // Load form-level data
    final staffTraining = await getStaffTrainingByFormId(formId);
    final infrastructure = await getInfrastructureByFormId(formId);

    return form.copyWith(
      visits: completeVisits,
      staffTraining: staffTraining,
      infrastructure: infrastructure,
    );
  }

  // Sync-related operations
  Future<List<SupervisionForm>> getUnsyncedForms() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'supervision_forms',
      where: 'sync_status = ? AND is_active = ?',
      whereArgs: ['local', 1],
    );

    return List.generate(maps.length, (i) {
      return SupervisionForm.fromJson(maps[i]);
    });
  }

  Future<List<SupervisionVisit>> getUnsyncedVisits() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'supervision_visits',
      where: 'sync_status = ?',
      whereArgs: ['local'],
      orderBy: 'created_at ASC',
    );

    return List.generate(maps.length, (i) {
      return SupervisionVisit.fromJson(maps[i]);
    });
  }

  Future<void> updateFormSyncStatus(int formId, String syncStatus, {int? serverId}) async {
    final db = await database;
    final updateData = <String, dynamic>{
      'sync_status': syncStatus,
      'updated_at': DateTime.now().toIso8601String(),
    };
    
    if (serverId != null) {
      updateData['server_id'] = serverId;
    }

    await db.update(
      'supervision_forms',
      updateData,
      where: 'id = ?',
      whereArgs: [formId],
    );
  }

  Future<void> updateVisitSyncStatus(int visitId, String syncStatus, {int? serverId}) async {
    final db = await database;
    final updateData = <String, dynamic>{
      'sync_status': syncStatus,
      'updated_at': DateTime.now().toIso8601String(),
    };
    
    if (serverId != null) {
      updateData['server_id'] = serverId;
    }

    await db.update(
      'supervision_visits',
      updateData,
      where: 'id = ?',
      whereArgs: [visitId],
    );
  }

  Future<void> markFormAsSynced(int formId, int serverId) async {
    final db = await database;
    await db.update(
      'supervision_forms',
      {
        'sync_status': 'synced',
        'server_id': serverId,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [formId],
    );
  }

  // Legacy method support for backwards compatibility
  Future<void> insertVisitSection(String tableName, int visitId, Map<String, dynamic> data) async {
    final db = await database;
    final sectionData = Map<String, dynamic>.from(data);
    
    sectionData['visit_id'] = visitId;
    sectionData['created_at'] = DateTime.now().toIso8601String();
    sectionData['updated_at'] = DateTime.now().toIso8601String();
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

    try {
      await db.update(
        tableName,
        sectionData,
        where: 'visit_id = ?',
        whereArgs: [visitId],
      );
    } catch (e) {
      print('Error updating $tableName: $e');
      print('Data: $sectionData');
      rethrow;
    }
  }

  // Server sync operations
  Future<SupervisionForm?> findFormByServerIdOrTempId(int? serverId, String? tempId) async {
    final db = await database;
    
    if (serverId == null && tempId == null) return null;
    
    String whereClause;
    List<dynamic> whereArgs;
    
    if (serverId != null && tempId != null) {
      whereClause = 'server_id = ? OR temp_id = ?';
      whereArgs = [serverId, tempId];
    } else if (serverId != null) {
      whereClause = 'server_id = ?';
      whereArgs = [serverId];
    } else {
      whereClause = 'temp_id = ?';
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

  Future<int> insertFormFromServer(Map<String, dynamic> serverData) async {
    final db = await database;
    
    final formData = {
      'temp_id': serverData['tempId'] ?? serverData['temp_id'] ?? const Uuid().v4(),
      'server_id': serverData['id'],
      'health_facility_name': serverData['healthFacilityName'] ?? serverData['health_facility_name'],
      'province': serverData['province'],
      'district': serverData['district'],
      'user_id': serverData['userId'] ?? serverData['user_id'],
      'created_at': serverData['createdAt'] ?? serverData['created_at'] ?? DateTime.now().toIso8601String(),
      'updated_at': serverData['updatedAt'] ?? serverData['updated_at'] ?? DateTime.now().toIso8601String(),
      'sync_status': serverData['syncStatus'] ?? serverData['sync_status'] ?? 'synced',
      'is_active': 1,
    };
    
    return await db.insert('supervision_forms', formData);
  }

  // Utility operations
  Future<void> clearDatabase() async {
    final db = await database;
    final tables = [
      'supervision_forms', 'supervision_visits', 'form_staff_training', 'form_infrastructure',
      'visit_admin_management_responses', 'visit_logistics_responses', 'visit_equipment_responses',
      'visit_mhdc_management_responses', 'visit_service_standards_responses', 
      'visit_health_information_responses', 'visit_integration_responses',
      'visit_medicine_details', 'visit_patient_volumes', 'visit_equipment_functionality',
      'visit_quality_assurance'
    ];
    
    for (final table in tables) {
      await db.delete(table);
    }
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