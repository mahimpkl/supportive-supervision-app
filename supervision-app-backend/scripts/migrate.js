require('dotenv').config();
const db = require('../config/database');
const bcrypt = require('bcryptjs');

async function createTables() {
  console.log('🔄 Creating complete visit-based database tables with full PDF compliance...');

  try {
    // Users table (unchanged)
    await db.query(`
      CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        username VARCHAR(50) UNIQUE NOT NULL,
        email VARCHAR(100) UNIQUE NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        role VARCHAR(20) NOT NULL DEFAULT 'user',
        full_name VARCHAR(100) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        is_active BOOLEAN DEFAULT true
      )
    `);
    console.log('✅ Users table created');

    // Main supervision forms table (facility-level information)
    await db.query(`
      CREATE TABLE IF NOT EXISTS supervision_forms (
        id SERIAL PRIMARY KEY,
        user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
        health_facility_name VARCHAR(200) NOT NULL,
        province VARCHAR(100) NOT NULL,
        district VARCHAR(100) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        sync_status VARCHAR(20) DEFAULT 'local' CHECK (sync_status IN ('local', 'synced', 'verified')),
        is_active BOOLEAN DEFAULT true
      )
    `);
    console.log('✅ Supervision forms table created');

    // Individual visits table (one record per visit) - COMPLETE WITH ALL PDF FIELDS
    await db.query(`
      CREATE TABLE IF NOT EXISTS supervision_visits (
        id SERIAL PRIMARY KEY,
        form_id INTEGER REFERENCES supervision_forms(id) ON DELETE CASCADE,
        visit_number INTEGER NOT NULL CHECK (visit_number BETWEEN 1 AND 4),
        visit_date DATE NOT NULL,
        supervisor_signature TEXT,
        facility_representative_signature TEXT,
        recommendations TEXT,
        actions_agreed TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        sync_status VARCHAR(20) DEFAULT 'local' CHECK (sync_status IN ('local', 'synced', 'verified')),
        UNIQUE(form_id, visit_number)
      )
    `);
    console.log('✅ Supervision visits table created');

    // A. Administration and Management responses (per visit) - COMPLETE WITH ALL COMMENTS
    await db.query(`
      CREATE TABLE IF NOT EXISTS visit_admin_management_responses (
        id SERIAL PRIMARY KEY,
        visit_id INTEGER REFERENCES supervision_visits(id) ON DELETE CASCADE,
        
        -- A1: Health Facility Operation and Management Committee
        a1_response VARCHAR(1) CHECK (a1_response IN ('Y', 'N')),
        a1_comment TEXT,
        a1_respondents_comment TEXT,
        
        -- A2: Committee discusses NCD service provisions
        a2_response VARCHAR(1) CHECK (a2_response IN ('Y', 'N')),
        a2_comment TEXT,
        a2_respondents_comment TEXT,
        
        -- A3: Health facility discusses NCD quarterly
        a3_response VARCHAR(1) CHECK (a3_response IN ('Y', 'N')),
        a3_comment TEXT,
        a3_respondents_comment TEXT,
        
        -- Section-level actions agreed
        actions_agreed TEXT,
        
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ Visit admin management responses table created with full comments');

    // B. Logistics responses (medicines, supplies & equipment) per visit - COMPLETE MEDICINE LIST
    await db.query(`
      CREATE TABLE IF NOT EXISTS visit_logistics_responses (
        id SERIAL PRIMARY KEY,
        visit_id INTEGER REFERENCES supervision_visits(id) ON DELETE CASCADE,
        
        -- B1: Essential NCD medicines available
        b1_response VARCHAR(1) CHECK (b1_response IN ('Y', 'N')),
        b1_comment TEXT,
        b1_respondents_comment TEXT,
        b1_validation_note TEXT,
        
        -- COMPLETE MEDICINE AVAILABILITY (from PDF pages 1-3) with quantities
        amlodipine_5_10mg VARCHAR(1) CHECK (amlodipine_5_10mg IN ('Y', 'N')),
        amlodipine_5_10mg_quantity INTEGER,
        amlodipine_5_10mg_units VARCHAR(50),
        
        enalapril_2_5_10mg VARCHAR(1) CHECK (enalapril_2_5_10mg IN ('Y', 'N')),
        enalapril_2_5_10mg_quantity INTEGER,
        enalapril_2_5_10mg_units VARCHAR(50),
        
        losartan_25_50mg VARCHAR(1) CHECK (losartan_25_50mg IN ('Y', 'N')),
        losartan_25_50mg_quantity INTEGER,
        losartan_25_50mg_units VARCHAR(50),
        
        hydrochlorothiazide_12_5_25mg VARCHAR(1) CHECK (hydrochlorothiazide_12_5_25mg IN ('Y', 'N')),
        hydrochlorothiazide_12_5_25mg_quantity INTEGER,
        hydrochlorothiazide_12_5_25mg_units VARCHAR(50),
        
        chlorthalidone_6_25_12_5mg VARCHAR(1) CHECK (chlorthalidone_6_25_12_5mg IN ('Y', 'N')),
        chlorthalidone_6_25_12_5mg_quantity INTEGER,
        chlorthalidone_6_25_12_5mg_units VARCHAR(50),
        
        other_antihypertensives VARCHAR(1) CHECK (other_antihypertensives IN ('Y', 'N')),
        other_antihypertensives_quantity INTEGER,
        other_antihypertensives_units VARCHAR(50),
        other_antihypertensives_specify TEXT,
        
        atorvastatin_5mg VARCHAR(1) CHECK (atorvastatin_5mg IN ('Y', 'N')),
        atorvastatin_5mg_quantity INTEGER,
        atorvastatin_5mg_units VARCHAR(50),
        
        atorvastatin_10mg VARCHAR(1) CHECK (atorvastatin_10mg IN ('Y', 'N')),
        atorvastatin_10mg_quantity INTEGER,
        atorvastatin_10mg_units VARCHAR(50),
        
        atorvastatin_20mg VARCHAR(1) CHECK (atorvastatin_20mg IN ('Y', 'N')),
        atorvastatin_20mg_quantity INTEGER,
        atorvastatin_20mg_units VARCHAR(50),
        
        other_statins VARCHAR(1) CHECK (other_statins IN ('Y', 'N')),
        other_statins_quantity INTEGER,
        other_statins_units VARCHAR(50),
        other_statins_specify TEXT,
        
        metformin_500mg VARCHAR(1) CHECK (metformin_500mg IN ('Y', 'N')),
        metformin_500mg_quantity INTEGER,
        metformin_500mg_units VARCHAR(50),
        
        metformin_1000mg VARCHAR(1) CHECK (metformin_1000mg IN ('Y', 'N')),
        metformin_1000mg_quantity INTEGER,
        metformin_1000mg_units VARCHAR(50),
        
        glimepiride_1_2mg VARCHAR(1) CHECK (glimepiride_1_2mg IN ('Y', 'N')),
        glimepiride_1_2mg_quantity INTEGER,
        glimepiride_1_2mg_units VARCHAR(50),
        
        gliclazide_40_80mg VARCHAR(1) CHECK (gliclazide_40_80mg IN ('Y', 'N')),
        gliclazide_40_80mg_quantity INTEGER,
        gliclazide_40_80mg_units VARCHAR(50),
        
        glipizide_2_5_5mg VARCHAR(1) CHECK (glipizide_2_5_5mg IN ('Y', 'N')),
        glipizide_2_5_5mg_quantity INTEGER,
        glipizide_2_5_5mg_units VARCHAR(50),
        
        sitagliptin_50mg VARCHAR(1) CHECK (sitagliptin_50mg IN ('Y', 'N')),
        sitagliptin_50mg_quantity INTEGER,
        sitagliptin_50mg_units VARCHAR(50),
        
        pioglitazone_5mg VARCHAR(1) CHECK (pioglitazone_5mg IN ('Y', 'N')),
        pioglitazone_5mg_quantity INTEGER,
        pioglitazone_5mg_units VARCHAR(50),
        
        empagliflozin_10mg VARCHAR(1) CHECK (empagliflozin_10mg IN ('Y', 'N')),
        empagliflozin_10mg_quantity INTEGER,
        empagliflozin_10mg_units VARCHAR(50),
        
        insulin_soluble_inj VARCHAR(1) CHECK (insulin_soluble_inj IN ('Y', 'N')),
        insulin_soluble_inj_quantity INTEGER,
        insulin_soluble_inj_units VARCHAR(50),
        
        insulin_nph_inj VARCHAR(1) CHECK (insulin_nph_inj IN ('Y', 'N')),
        insulin_nph_inj_quantity INTEGER,
        insulin_nph_inj_units VARCHAR(50),
        
        other_hypoglycemic_agents VARCHAR(1) CHECK (other_hypoglycemic_agents IN ('Y', 'N')),
        other_hypoglycemic_agents_quantity INTEGER,
        other_hypoglycemic_agents_units VARCHAR(50),
        other_hypoglycemic_agents_specify TEXT,
        
        dextrose_25_solution VARCHAR(1) CHECK (dextrose_25_solution IN ('Y', 'N')),
        dextrose_25_solution_quantity INTEGER,
        dextrose_25_solution_units VARCHAR(50),
        
        aspirin_75mg VARCHAR(1) CHECK (aspirin_75mg IN ('Y', 'N')),
        aspirin_75mg_quantity INTEGER,
        aspirin_75mg_units VARCHAR(50),
        
        clopidogrel_75mg VARCHAR(1) CHECK (clopidogrel_75mg IN ('Y', 'N')),
        clopidogrel_75mg_quantity INTEGER,
        clopidogrel_75mg_units VARCHAR(50),
        
        metoprolol_succinate_12_5_25_50mg VARCHAR(1) CHECK (metoprolol_succinate_12_5_25_50mg IN ('Y', 'N')),
        metoprolol_succinate_12_5_25_50mg_quantity INTEGER,
        metoprolol_succinate_12_5_25_50mg_units VARCHAR(50),
        
        isosorbide_dinitrate_5mg VARCHAR(1) CHECK (isosorbide_dinitrate_5mg IN ('Y', 'N')),
        isosorbide_dinitrate_5mg_quantity INTEGER,
        isosorbide_dinitrate_5mg_units VARCHAR(50),
        
        other_drugs VARCHAR(1) CHECK (other_drugs IN ('Y', 'N')),
        other_drugs_quantity INTEGER,
        other_drugs_units VARCHAR(50),
        other_drugs_specify TEXT,
        
        amoxicillin_clavulanic_potassium_625mg VARCHAR(1) CHECK (amoxicillin_clavulanic_potassium_625mg IN ('Y', 'N')),
        amoxicillin_clavulanic_potassium_625mg_quantity INTEGER,
        amoxicillin_clavulanic_potassium_625mg_units VARCHAR(50),
        
        azithromycin_500mg VARCHAR(1) CHECK (azithromycin_500mg IN ('Y', 'N')),
        azithromycin_500mg_quantity INTEGER,
        azithromycin_500mg_units VARCHAR(50),
        
        other_antibiotics VARCHAR(1) CHECK (other_antibiotics IN ('Y', 'N')),
        other_antibiotics_quantity INTEGER,
        other_antibiotics_units VARCHAR(50),
        other_antibiotics_specify TEXT,
        
        salbutamol_dpi VARCHAR(1) CHECK (salbutamol_dpi IN ('Y', 'N')),
        salbutamol_dpi_quantity INTEGER,
        salbutamol_dpi_units VARCHAR(50),
        
        salbutamol VARCHAR(1) CHECK (salbutamol IN ('Y', 'N')),
        salbutamol_quantity INTEGER,
        salbutamol_units VARCHAR(50),
        
        ipratropium VARCHAR(1) CHECK (ipratropium IN ('Y', 'N')),
        ipratropium_quantity INTEGER,
        ipratropium_units VARCHAR(50),
        
        tiotropium_bromide VARCHAR(1) CHECK (tiotropium_bromide IN ('Y', 'N')),
        tiotropium_bromide_quantity INTEGER,
        tiotropium_bromide_units VARCHAR(50),
        
        formoterol VARCHAR(1) CHECK (formoterol IN ('Y', 'N')),
        formoterol_quantity INTEGER,
        formoterol_units VARCHAR(50),
        
        other_bronchodilators VARCHAR(1) CHECK (other_bronchodilators IN ('Y', 'N')),
        other_bronchodilators_quantity INTEGER,
        other_bronchodilators_units VARCHAR(50),
        other_bronchodilators_specify TEXT,
        
        prednisolone_5_10_20mg VARCHAR(1) CHECK (prednisolone_5_10_20mg IN ('Y', 'N')),
        prednisolone_5_10_20mg_quantity INTEGER,
        prednisolone_5_10_20mg_units VARCHAR(50),
        
        other_steroids_oral VARCHAR(1) CHECK (other_steroids_oral IN ('Y', 'N')),
        other_steroids_oral_quantity INTEGER,
        other_steroids_oral_units VARCHAR(50),
        other_steroids_oral_specify TEXT,
        
        -- B2: Blood glucometer functioning
        b2_response VARCHAR(1) CHECK (b2_response IN ('Y', 'N')),
        b2_comment TEXT,
        b2_respondents_comment TEXT,
        b2_validation_note TEXT,
        b2_random_records_checked BOOLEAN DEFAULT FALSE,
        b2_explanation_if_not_in_use TEXT,
        
        -- B3: Urine protein strips used
        b3_response VARCHAR(1) CHECK (b3_response IN ('Y', 'N')),
        b3_comment TEXT,
        b3_respondents_comment TEXT,
        b3_validation_note TEXT,
        b3_expiry_date_verified BOOLEAN DEFAULT FALSE,
        b3_storage_conditions_verified BOOLEAN DEFAULT FALSE,
        
        -- B4: Urine ketone strips used
        b4_response VARCHAR(1) CHECK (b4_response IN ('Y', 'N')),
        b4_comment TEXT,
        b4_respondents_comment TEXT,
        b4_validation_note TEXT,
        b4_expiry_date_verified BOOLEAN DEFAULT FALSE,
        b4_storage_conditions_verified BOOLEAN DEFAULT FALSE,
        
        -- B5: Essential equipment available and functional
        b5_response VARCHAR(1) CHECK (b5_response IN ('Y', 'N')),
        b5_comment TEXT,
        b5_respondents_comment TEXT,
        b5_validation_note TEXT,
        
        -- ENHANCED FIELDS FOR COMPLETE PDF COMPLIANCE
        medicine_quantities JSONB,
        expiry_dates_checked BOOLEAN DEFAULT FALSE,
        storage_conditions_verified BOOLEAN DEFAULT FALSE,
        antihypertensive_comments TEXT,
        statin_comments TEXT,
        diabetes_medication_comments TEXT,
        cardiovascular_medication_comments TEXT,
        respiratory_medication_comments TEXT,
        actions_agreed TEXT,
        
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ Visit logistics responses table created with complete medicine tracking');

    // Equipment availability per visit - COMPLETE WITH QUANTITIES
    await db.query(`
      CREATE TABLE IF NOT EXISTS visit_equipment_responses (
        id SERIAL PRIMARY KEY,
        visit_id INTEGER REFERENCES supervision_visits(id) ON DELETE CASCADE,
        
        -- Equipment from PDF page 4 with quantities
        sphygmomanometer VARCHAR(1) CHECK (sphygmomanometer IN ('Y', 'N')),
        sphygmomanometer_quantity INTEGER,
        sphygmomanometer_units VARCHAR(50),
        
        weighing_scale VARCHAR(1) CHECK (weighing_scale IN ('Y', 'N')),
        weighing_scale_quantity INTEGER,
        weighing_scale_units VARCHAR(50),
        
        measuring_tape VARCHAR(1) CHECK (measuring_tape IN ('Y', 'N')),
        measuring_tape_quantity INTEGER,
        measuring_tape_units VARCHAR(50),
        
        peak_expiratory_flow_meter VARCHAR(1) CHECK (peak_expiratory_flow_meter IN ('Y', 'N')),
        peak_expiratory_flow_meter_quantity INTEGER,
        peak_expiratory_flow_meter_units VARCHAR(50),
        
        oxygen VARCHAR(1) CHECK (oxygen IN ('Y', 'N')),
        oxygen_quantity INTEGER,
        oxygen_units VARCHAR(50),
        
        oxygen_mask VARCHAR(1) CHECK (oxygen_mask IN ('Y', 'N')),
        oxygen_mask_quantity INTEGER,
        oxygen_mask_units VARCHAR(50),
        
        nebulizer VARCHAR(1) CHECK (nebulizer IN ('Y', 'N')),
        nebulizer_quantity INTEGER,
        nebulizer_units VARCHAR(50),
        
        pulse_oximetry VARCHAR(1) CHECK (pulse_oximetry IN ('Y', 'N')),
        pulse_oximetry_quantity INTEGER,
        pulse_oximetry_units VARCHAR(50),
        
        glucometer VARCHAR(1) CHECK (glucometer IN ('Y', 'N')),
        glucometer_quantity INTEGER,
        glucometer_units VARCHAR(50),
        
        glucometer_strips VARCHAR(1) CHECK (glucometer_strips IN ('Y', 'N')),
        glucometer_strips_quantity INTEGER,
        glucometer_strips_units VARCHAR(50),
        
        lancets VARCHAR(1) CHECK (lancets IN ('Y', 'N')),
        lancets_quantity INTEGER,
        lancets_units VARCHAR(50),
        
        urine_dipstick VARCHAR(1) CHECK (urine_dipstick IN ('Y', 'N')),
        urine_dipstick_quantity INTEGER,
        urine_dipstick_units VARCHAR(50),
        
        ecg VARCHAR(1) CHECK (ecg IN ('Y', 'N')),
        ecg_quantity INTEGER,
        ecg_units VARCHAR(50),
        
        other_equipment VARCHAR(1) CHECK (other_equipment IN ('Y', 'N')),
        other_equipment_quantity INTEGER,
        other_equipment_units VARCHAR(50),
        other_equipment_specify TEXT,
        
        -- ADDITIONAL EQUIPMENT
        stethoscope VARCHAR(1) CHECK (stethoscope IN ('Y', 'N')),
        stethoscope_quantity INTEGER,
        
        thermometer VARCHAR(1) CHECK (thermometer IN ('Y', 'N')),
        thermometer_quantity INTEGER,
        
        examination_table VARCHAR(1) CHECK (examination_table IN ('Y', 'N')),
        examination_table_quantity INTEGER,
        
        privacy_screen VARCHAR(1) CHECK (privacy_screen IN ('Y', 'N')),
        privacy_screen_quantity INTEGER,
        
        actions_agreed TEXT,
        
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ Visit equipment responses table created with complete tracking');

    // MHDC NCD Management responses per visit - ENHANCED WITH PDF DETAILS
    await db.query(`
      CREATE TABLE IF NOT EXISTS visit_mhdc_management_responses (
        id SERIAL PRIMARY KEY,
        visit_id INTEGER REFERENCES supervision_visits(id) ON DELETE CASCADE,
        
        -- B6: MHDC NCD management leaflets available
        b6_response VARCHAR(1) CHECK (b6_response IN ('Y', 'N')),
        b6_comment TEXT,
        b6_respondents_comment TEXT,
        b6_healthcare_workers_refer_easily BOOLEAN DEFAULT FALSE,
        b6_kept_in_opd_use BOOLEAN DEFAULT FALSE,
        
        -- B7: NCD awareness and patient education materials available
        b7_response VARCHAR(1) CHECK (b7_response IN ('Y', 'N')),
        b7_comment TEXT,
        b7_respondents_comment TEXT,
        b7_available_at_health_center BOOLEAN DEFAULT FALSE,
        
        -- B8: NCD register availability and proper filling
        b8_response VARCHAR(1) CHECK (b8_response IN ('Y', 'N')),
        b8_comment TEXT,
        b8_respondents_comment TEXT,
        b8_available_and_filled_properly BOOLEAN DEFAULT FALSE,
        
        -- B9: WHO-ISH CVD Risk Prediction Chart available
        b9_response VARCHAR(1) CHECK (b9_response IN ('Y', 'N')),
        b9_comment TEXT,
        b9_respondents_comment TEXT,
        b9_available_for_patient_care BOOLEAN DEFAULT FALSE,
        
        -- B10: WHO-ISH CVD Risk Chart in use
        b10_response VARCHAR(1) CHECK (b10_response IN ('Y', 'N')),
        b10_comment TEXT,
        b10_respondents_comment TEXT,
        b10_in_use_for_patient_care BOOLEAN DEFAULT FALSE,
        
        -- ENHANCED WHO-ISH RISK CHART TRACKING
        b9_chart_version VARCHAR(50),
        b9_chart_condition VARCHAR(100),
        b10_staff_trained_on_chart BOOLEAN,
        b10_charts_completed_during_visit INTEGER,
        b10_risk_stratification_accurate BOOLEAN,
        actions_agreed TEXT,
        
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ Visit MHDC management responses table created with enhanced tracking');

    // C1: Staff Training Matrix (one record per form, not per visit) - COMPLETE
    await db.query(`
      CREATE TABLE IF NOT EXISTS form_staff_training (
        id SERIAL PRIMARY KEY,
        form_id INTEGER REFERENCES supervision_forms(id) ON DELETE CASCADE,
        
        -- Health Assistant (HA)
        ha_total_staff INTEGER DEFAULT 0,
        ha_mhdc_trained INTEGER DEFAULT 0,
        ha_fen_trained INTEGER DEFAULT 0,
        ha_other_ncd_trained INTEGER DEFAULT 0,
        
        -- Senior AHW
        sr_ahw_total_staff INTEGER DEFAULT 0,
        sr_ahw_mhdc_trained INTEGER DEFAULT 0,
        sr_ahw_fen_trained INTEGER DEFAULT 0,
        sr_ahw_other_ncd_trained INTEGER DEFAULT 0,
        
        -- AHW
        ahw_total_staff INTEGER DEFAULT 0,
        ahw_mhdc_trained INTEGER DEFAULT 0,
        ahw_fen_trained INTEGER DEFAULT 0,
        ahw_other_ncd_trained INTEGER DEFAULT 0,
        
        -- Senior ANM
        sr_anm_total_staff INTEGER DEFAULT 0,
        sr_anm_mhdc_trained INTEGER DEFAULT 0,
        sr_anm_fen_trained INTEGER DEFAULT 0,
        sr_anm_other_ncd_trained INTEGER DEFAULT 0,
        
        -- ANM
        anm_total_staff INTEGER DEFAULT 0,
        anm_mhdc_trained INTEGER DEFAULT 0,
        anm_fen_trained INTEGER DEFAULT 0,
        anm_other_ncd_trained INTEGER DEFAULT 0,
        
        -- Others
        others_total_staff INTEGER DEFAULT 0,
        others_mhdc_trained INTEGER DEFAULT 0,
        others_fen_trained INTEGER DEFAULT 0,
        others_other_ncd_trained INTEGER DEFAULT 0,
        
        -- ENHANCED TRAINING TRACKING
        last_mhdc_training_date DATE,
        last_fen_training_date DATE,
        last_other_training_date DATE,
        training_provider VARCHAR(200),
        training_certificates_verified BOOLEAN DEFAULT FALSE,
        
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ Form staff training table created');

    // C2-C7: Service Standards per visit - COMPLETE WITH ALL C2 SUB-SERVICES
    await db.query(`
      CREATE TABLE IF NOT EXISTS visit_service_standards_responses (
        id SERIAL PRIMARY KEY,
        visit_id INTEGER REFERENCES supervision_visits(id) ON DELETE CASCADE,
        
        -- C2: NCD services provided as per PEN protocol and standards
        c2_main_response VARCHAR(1) CHECK (c2_main_response IN ('Y', 'N')),
        c2_main_comment TEXT,
        c2_respondents_comment TEXT,
        
        -- C2 Sub-services (from PDF page 6)
        c2_blood_pressure VARCHAR(1) CHECK (c2_blood_pressure IN ('Y', 'N')),
        c2_blood_pressure_comment TEXT,
        c2_blood_pressure_equipment_calibrated BOOLEAN,
        c2_blood_pressure_protocol_followed BOOLEAN,
        
        c2_blood_sugar VARCHAR(1) CHECK (c2_blood_sugar IN ('Y', 'N')),
        c2_blood_sugar_comment TEXT,
        c2_blood_sugar_strips_available BOOLEAN,
        c2_blood_sugar_quality_control BOOLEAN,
        
        c2_bmi_measurement VARCHAR(1) CHECK (c2_bmi_measurement IN ('Y', 'N')),
        c2_bmi_measurement_comment TEXT,
        c2_bmi_calculation_accurate BOOLEAN,
        
        c2_waist_circumference VARCHAR(1) CHECK (c2_waist_circumference IN ('Y', 'N')),
        c2_waist_circumference_comment TEXT,
        c2_waist_measurement_technique_correct BOOLEAN,
        
        c2_cvd_risk_estimation VARCHAR(1) CHECK (c2_cvd_risk_estimation IN ('Y', 'N')),
        c2_cvd_risk_estimation_comment TEXT,
        c2_cvd_chart_available_and_used BOOLEAN,
        
        c2_urine_protein_measurement VARCHAR(1) CHECK (c2_urine_protein_measurement IN ('Y', 'N')),
        c2_urine_protein_measurement_comment TEXT,
        c2_urine_protein_strips_not_expired BOOLEAN,
        
        c2_peak_expiratory_flow_rate VARCHAR(1) CHECK (c2_peak_expiratory_flow_rate IN ('Y', 'N')),
        c2_peak_expiratory_flow_rate_comment TEXT,
        c2_peak_flow_meter_calibrated BOOLEAN,
        
        c2_egfr_calculation VARCHAR(1) CHECK (c2_egfr_calculation IN ('Y', 'N')),
        c2_egfr_calculation_comment TEXT,
        c2_egfr_formula_used_correctly BOOLEAN,
        
        c2_brief_intervention VARCHAR(1) CHECK (c2_brief_intervention IN ('Y', 'N')),
        c2_brief_intervention_comment TEXT,
        
        c2_foot_examination VARCHAR(1) CHECK (c2_foot_examination IN ('Y', 'N')),
        c2_foot_examination_comment TEXT,
        
        c2_oral_examination VARCHAR(1) CHECK (c2_oral_examination IN ('Y', 'N')),
        c2_oral_examination_comment TEXT,
        
        c2_eye_examination VARCHAR(1) CHECK (c2_eye_examination IN ('Y', 'N')),
        c2_eye_examination_comment TEXT,
        
        c2_health_education VARCHAR(1) CHECK (c2_health_education IN ('Y', 'N')),
        c2_health_education_comment TEXT,
        
        -- C3: Examination room confidentiality
        c3_response VARCHAR(1) CHECK (c3_response IN ('Y', 'N')),
        c3_comment TEXT,
        c3_respondents_comment TEXT,
        
        -- C4: Home-bound NCD services
        c4_response VARCHAR(1) CHECK (c4_response IN ('Y', 'N')),
        c4_comment TEXT,
        c4_respondents_comment TEXT,
        
        -- C5: Community-based NCD care
        c5_response VARCHAR(1) CHECK (c5_response IN ('Y', 'N')),
        c5_comment TEXT,
        c5_respondents_comment TEXT,
        
        -- C6: School-based NCD prevention program
        c6_response VARCHAR(1) CHECK (c6_response IN ('Y', 'N')),
        c6_comment TEXT,
        c6_respondents_comment TEXT,
        
        -- C7: Patient tracking mechanism
        c7_response VARCHAR(1) CHECK (c7_response IN ('Y', 'N')),
        c7_comment TEXT,
        c7_respondents_comment TEXT,
        
        actions_agreed TEXT,
        
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ Visit service standards responses table created with complete C2 sub-services');

    // D1-D5: Health Information per visit - COMPLETE WITH RESPONDENT COMMENTS
    await db.query(`
      CREATE TABLE IF NOT EXISTS visit_health_information_responses (
        id SERIAL PRIMARY KEY,
        visit_id INTEGER REFERENCES supervision_visits(id) ON DELETE CASCADE,
        
        -- D1: NCD OPD register regularly updated
        d1_response VARCHAR(1) CHECK (d1_response IN ('Y', 'N')),
        d1_comment TEXT,
        d1_respondents_comment TEXT,
        
        -- D2: NCD dashboard displayed with updated information
        d2_response VARCHAR(1) CHECK (d2_response IN ('Y', 'N')),
        d2_comment TEXT,
        d2_respondents_comment TEXT,
        
        -- D3: Monthly Reporting Form sent to concerned authority
        d3_response VARCHAR(1) CHECK (d3_response IN ('Y', 'N')),
        d3_comment TEXT,
        d3_respondents_comment TEXT,
        
        -- D4: Number of people seeking NCD services
        d4_response VARCHAR(1) CHECK (d4_response IN ('Y', 'N')),
        d4_comment TEXT,
        d4_respondents_comment TEXT,
        d4_number_of_people INTEGER,
        d4_previous_month_data BOOLEAN DEFAULT FALSE,
        
        -- D5: Dedicated healthcare worker for NCD service provisions
        d5_response VARCHAR(1) CHECK (d5_response IN ('Y', 'N')),
        d5_comment TEXT,
        d5_respondents_comment TEXT,
        
        actions_agreed TEXT,
        
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ Visit health information responses table created');

    // E1-E3: Integration of NCD services per visit - COMPLETE
    await db.query(`
      CREATE TABLE IF NOT EXISTS visit_integration_responses (
        id SERIAL PRIMARY KEY,
        visit_id INTEGER REFERENCES supervision_visits(id) ON DELETE CASCADE,
        
        -- E1: Health Workers aware of PEN programme purpose
        e1_response VARCHAR(1) CHECK (e1_response IN ('Y', 'N')),
        e1_comment TEXT,
        e1_respondents_comment TEXT,
        
        -- E2: Health education on tobacco, alcohol, unhealthy diet and physical activity
        e2_response VARCHAR(1) CHECK (e2_response IN ('Y', 'N')),
        e2_comment TEXT,
        e2_respondents_comment TEXT,
        
        -- E3: Screening for raised blood pressure and raised blood sugar
        e3_response VARCHAR(1) CHECK (e3_response IN ('Y', 'N')),
        e3_comment TEXT,
        e3_respondents_comment TEXT,
        
        actions_agreed TEXT,
        
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ Visit integration responses table created');

    // Detailed medicine tracking per visit (enhanced from existing)
    await db.query(`
      CREATE TABLE IF NOT EXISTS visit_medicine_details (
        id SERIAL PRIMARY KEY,
        visit_id INTEGER REFERENCES supervision_visits(id) ON DELETE CASCADE,
        medicine_name VARCHAR(200) NOT NULL,
        medicine_category VARCHAR(100), -- antihypertensive, statin, diabetes, etc.
        availability VARCHAR(1) CHECK (availability IN ('Y', 'N')),
        quantity_available INTEGER,
        unit_of_measurement VARCHAR(50),
        expiry_date DATE,
        batch_number VARCHAR(100),
        storage_temperature_ok BOOLEAN DEFAULT FALSE,
        storage_humidity_ok BOOLEAN DEFAULT FALSE,
        storage_location VARCHAR(200),
        procurement_source VARCHAR(200),
        cost_per_unit DECIMAL(10,2),
        last_restocked_date DATE,
        minimum_stock_level INTEGER,
        stock_out_frequency VARCHAR(50), -- never, rarely, sometimes, often, always
        quality_issues_noted TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ Visit medicine details table created with comprehensive tracking');

    // Patient volume tracking (D4 details)
    await db.query(`
      CREATE TABLE IF NOT EXISTS visit_patient_volumes (
        id SERIAL PRIMARY KEY,
        visit_id INTEGER REFERENCES supervision_visits(id) ON DELETE CASCADE,
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
        month_year DATE,
        data_source VARCHAR(100), -- register, dashboard, estimation
        data_verified BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ Visit patient volumes table created');

    // Facility infrastructure assessment (comprehensive)
    await db.query(`
      CREATE TABLE IF NOT EXISTS form_facility_infrastructure (
        id SERIAL PRIMARY KEY,
        form_id INTEGER REFERENCES supervision_forms(id) ON DELETE CASCADE,
        
        -- Basic infrastructure
        total_rooms INTEGER,
        consultation_rooms INTEGER,
        waiting_area_adequate BOOLEAN DEFAULT FALSE,
        waiting_area_capacity INTEGER,
        
        -- Storage and pharmacy
        pharmacy_storage_adequate BOOLEAN DEFAULT FALSE,
        pharmacy_storage_size_sqm DECIMAL(8,2),
        cold_chain_available BOOLEAN DEFAULT FALSE,
        cold_chain_temperature_monitored BOOLEAN DEFAULT FALSE,
        medicine_storage_conditions_appropriate BOOLEAN DEFAULT FALSE,
        
        -- Utilities
        generator_backup BOOLEAN DEFAULT FALSE,
        generator_capacity_kw DECIMAL(8,2),
        water_supply_reliable BOOLEAN DEFAULT FALSE,
        water_storage_capacity_liters INTEGER,
        electricity_stable BOOLEAN DEFAULT FALSE,
        internet_connectivity BOOLEAN DEFAULT FALSE,
        
        -- Waste management
        waste_disposal_system BOOLEAN DEFAULT FALSE,
        sharps_disposal_appropriate BOOLEAN DEFAULT FALSE,
        biomedical_waste_segregation BOOLEAN DEFAULT FALSE,
        
        -- Accessibility and safety
        accessibility_features BOOLEAN DEFAULT FALSE,
        wheelchair_accessible BOOLEAN DEFAULT FALSE,
        fire_safety_equipment BOOLEAN DEFAULT FALSE,
        emergency_protocols_displayed BOOLEAN DEFAULT FALSE,
        
        -- Additional facilities
        laboratory_available BOOLEAN DEFAULT FALSE,
        xray_available BOOLEAN DEFAULT FALSE,
        ambulance_service BOOLEAN DEFAULT FALSE,
        
        assessment_date DATE,
        assessed_by VARCHAR(200),
        infrastructure_score INTEGER, -- out of 100
        priority_improvements TEXT,
        
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ Form facility infrastructure table created');

    // Equipment functionality tracking (enhanced)
    await db.query(`
      CREATE TABLE IF NOT EXISTS visit_equipment_functionality (
        id SERIAL PRIMARY KEY,
        visit_id INTEGER REFERENCES supervision_visits(id) ON DELETE CASCADE,
        equipment_name VARCHAR(200) NOT NULL,
        equipment_category VARCHAR(100), -- diagnostic, treatment, monitoring
        brand_model VARCHAR(200),
        serial_number VARCHAR(100),
        availability VARCHAR(1) CHECK (availability IN ('Y', 'N')),
        functionality_status VARCHAR(50), -- working, partially_working, not_working, needs_repair
        last_calibration_date DATE,
        calibration_due_date DATE,
        maintenance_schedule VARCHAR(100),
        usage_frequency VARCHAR(50), -- daily, weekly, monthly, rarely
        staff_trained_on_equipment BOOLEAN DEFAULT FALSE,
        user_manual_available BOOLEAN DEFAULT FALSE,
        spare_parts_available BOOLEAN DEFAULT FALSE,
        warranty_status VARCHAR(50), -- active, expired, not_applicable
        issues_noted TEXT,
        repair_history TEXT,
        procurement_date DATE,
        cost DECIMAL(12,2),
        funding_source VARCHAR(200),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ Visit equipment functionality table created');

    // Quality assurance tracking
    await db.query(`
      CREATE TABLE IF NOT EXISTS visit_quality_assurance (
        id SERIAL PRIMARY KEY,
        visit_id INTEGER REFERENCES supervision_visits(id) ON DELETE CASCADE,
        
        -- Clinical quality indicators
        guidelines_followed BOOLEAN DEFAULT FALSE,
        protocols_updated BOOLEAN DEFAULT FALSE,
        clinical_audit_conducted BOOLEAN DEFAULT FALSE,
        patient_satisfaction_assessed BOOLEAN DEFAULT FALSE,
        
        -- Documentation quality
        records_complete BOOLEAN DEFAULT FALSE,
        documentation_legible BOOLEAN DEFAULT FALSE,
        consent_forms_used BOOLEAN DEFAULT FALSE,
        privacy_maintained BOOLEAN DEFAULT FALSE,
        
        -- Safety measures
        infection_control_practices BOOLEAN DEFAULT FALSE,
        hand_hygiene_facilities BOOLEAN DEFAULT FALSE,
        emergency_procedures_known BOOLEAN DEFAULT FALSE,
        adverse_events_reported BOOLEAN DEFAULT FALSE,
        
        -- Staff competency
        staff_knowledge_adequate BOOLEAN DEFAULT FALSE,
        continuing_education_provided BOOLEAN DEFAULT FALSE,
        supervision_regular BOOLEAN DEFAULT FALSE,
        
        overall_quality_score INTEGER, -- out of 100
        areas_for_improvement TEXT,
        good_practices_observed TEXT,
        
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ Visit quality assurance table created');

    // Sync logs table (updated for comprehensive visit-based tracking)
    await db.query(`
      CREATE TABLE IF NOT EXISTS sync_logs (
        id SERIAL PRIMARY KEY,
        user_id INTEGER REFERENCES users(id),
        form_id INTEGER REFERENCES supervision_forms(id),
        visit_id INTEGER REFERENCES supervision_visits(id),
        sync_type VARCHAR(20), -- form, visit, section
        section_name VARCHAR(100), -- admin, logistics, equipment, etc.
        sync_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        device_id VARCHAR(100),
        sync_status VARCHAR(20) DEFAULT 'completed',
        error_message TEXT,
        data_size_kb INTEGER,
        network_type VARCHAR(50),
        sync_duration_seconds INTEGER,
        ip_address INET,
        user_agent TEXT,
        app_version VARCHAR(50),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ Sync logs table created');

    // Create comprehensive indexes for performance
    await db.query(`
      -- Main table indexes
      CREATE INDEX IF NOT EXISTS idx_supervision_forms_user_id ON supervision_forms(user_id);
      CREATE INDEX IF NOT EXISTS idx_supervision_forms_sync_status ON supervision_forms(sync_status);
      CREATE INDEX IF NOT EXISTS idx_supervision_forms_facility ON supervision_forms(health_facility_name);
      CREATE INDEX IF NOT EXISTS idx_supervision_forms_location ON supervision_forms(province, district);
      CREATE INDEX IF NOT EXISTS idx_supervision_forms_created_at ON supervision_forms(created_at);
      
      -- Visit indexes
      CREATE INDEX IF NOT EXISTS idx_supervision_visits_form_id ON supervision_visits(form_id);
      CREATE INDEX IF NOT EXISTS idx_supervision_visits_visit_number ON supervision_visits(visit_number);
      CREATE INDEX IF NOT EXISTS idx_supervision_visits_date ON supervision_visits(visit_date);
      CREATE INDEX IF NOT EXISTS idx_supervision_visits_sync_status ON supervision_visits(sync_status);
      CREATE INDEX IF NOT EXISTS idx_supervision_visits_form_visit ON supervision_visits(form_id, visit_number);
      
      -- Response table indexes
      CREATE INDEX IF NOT EXISTS idx_visit_admin_management_visit_id ON visit_admin_management_responses(visit_id);
      CREATE INDEX IF NOT EXISTS idx_visit_logistics_visit_id ON visit_logistics_responses(visit_id);
      CREATE INDEX IF NOT EXISTS idx_visit_equipment_visit_id ON visit_equipment_responses(visit_id);
      CREATE INDEX IF NOT EXISTS idx_visit_mhdc_visit_id ON visit_mhdc_management_responses(visit_id);
      CREATE INDEX IF NOT EXISTS idx_visit_service_standards_visit_id ON visit_service_standards_responses(visit_id);
      CREATE INDEX IF NOT EXISTS idx_visit_health_info_visit_id ON visit_health_information_responses(visit_id);
      CREATE INDEX IF NOT EXISTS idx_visit_integration_visit_id ON visit_integration_responses(visit_id);
      
      -- Detail table indexes
      CREATE INDEX IF NOT EXISTS idx_visit_medicine_details_visit_id ON visit_medicine_details(visit_id);
      CREATE INDEX IF NOT EXISTS idx_visit_medicine_details_medicine ON visit_medicine_details(medicine_name);
      CREATE INDEX IF NOT EXISTS idx_visit_medicine_details_category ON visit_medicine_details(medicine_category);
      CREATE INDEX IF NOT EXISTS idx_visit_medicine_details_expiry ON visit_medicine_details(expiry_date);
      CREATE INDEX IF NOT EXISTS idx_visit_medicine_details_availability ON visit_medicine_details(availability);
      
      CREATE INDEX IF NOT EXISTS idx_visit_patient_volumes_visit_id ON visit_patient_volumes(visit_id);
      CREATE INDEX IF NOT EXISTS idx_visit_patient_volumes_month ON visit_patient_volumes(month_year);
      
      CREATE INDEX IF NOT EXISTS idx_visit_equipment_functionality_visit_id ON visit_equipment_functionality(visit_id);
      CREATE INDEX IF NOT EXISTS idx_visit_equipment_functionality_name ON visit_equipment_functionality(equipment_name);
      CREATE INDEX IF NOT EXISTS idx_visit_equipment_functionality_status ON visit_equipment_functionality(functionality_status);
      
      CREATE INDEX IF NOT EXISTS idx_visit_quality_assurance_visit_id ON visit_quality_assurance(visit_id);
      
      -- Form-level indexes
      CREATE INDEX IF NOT EXISTS idx_form_staff_training_form_id ON form_staff_training(form_id);
      CREATE INDEX IF NOT EXISTS idx_form_facility_infrastructure_form_id ON form_facility_infrastructure(form_id);
      
      -- Sync logs indexes
      CREATE INDEX IF NOT EXISTS idx_sync_logs_user_id ON sync_logs(user_id);
      CREATE INDEX IF NOT EXISTS idx_sync_logs_form_id ON sync_logs(form_id);
      CREATE INDEX IF NOT EXISTS idx_sync_logs_visit_id ON sync_logs(visit_id);
      CREATE INDEX IF NOT EXISTS idx_sync_logs_timestamp ON sync_logs(sync_timestamp);
      CREATE INDEX IF NOT EXISTS idx_sync_logs_sync_type ON sync_logs(sync_type);
      CREATE INDEX IF NOT EXISTS idx_sync_logs_status ON sync_logs(sync_status);
    `);
    console.log('✅ Comprehensive database indexes created');

    // Add detailed table comments for documentation
    await db.query(`
      COMMENT ON TABLE supervision_forms IS 'Main facility-level supervision forms with basic facility information';
      COMMENT ON TABLE supervision_visits IS 'Individual visits (1-4) per form with visit-specific data and overall actions agreed';
      
      COMMENT ON TABLE visit_admin_management_responses IS 'Administration and Management section responses per visit (A1-A3)';
      COMMENT ON TABLE visit_logistics_responses IS 'Complete medicine and logistics tracking per visit (B1-B5) with quantities';
      COMMENT ON TABLE visit_equipment_responses IS 'Equipment availability and functionality per visit with quantities';
      COMMENT ON TABLE visit_mhdc_management_responses IS 'MHDC NCD management materials and tools tracking (B6-B10)';
      COMMENT ON TABLE visit_service_standards_responses IS 'Comprehensive service standards including all C2 sub-services (C2-C7)';
      COMMENT ON TABLE visit_health_information_responses IS 'Health information systems and reporting (D1-D5)';
      COMMENT ON TABLE visit_integration_responses IS 'Integration of NCD services (E1-E3)';
      
      COMMENT ON TABLE form_staff_training IS 'Staff training matrix - one record per form covering all staff categories';
      COMMENT ON TABLE form_facility_infrastructure IS 'Comprehensive facility infrastructure assessment';
      
      COMMENT ON TABLE visit_medicine_details IS 'Detailed medicine inventory tracking with storage, costs, and quality';
      COMMENT ON TABLE visit_patient_volumes IS 'Patient volume statistics per visit for D4 reporting';
      COMMENT ON TABLE visit_equipment_functionality IS 'Detailed equipment tracking with maintenance and calibration data';
      COMMENT ON TABLE visit_quality_assurance IS 'Quality assurance indicators and safety measures per visit';
      
      COMMENT ON COLUMN supervision_visits.actions_agreed IS 'Overall visit-level actions agreed between supervisor and supervisee';
      COMMENT ON COLUMN supervision_visits.recommendations IS 'General recommendations from supervisor for this visit';
      
      -- Section-specific actions agreed comments
      COMMENT ON COLUMN visit_admin_management_responses.actions_agreed IS 'Section A specific actions agreed';
      COMMENT ON COLUMN visit_logistics_responses.actions_agreed IS 'Section B specific actions agreed';
      COMMENT ON COLUMN visit_equipment_responses.actions_agreed IS 'Equipment section specific actions agreed';
      COMMENT ON COLUMN visit_mhdc_management_responses.actions_agreed IS 'MHDC section specific actions agreed';
      COMMENT ON COLUMN visit_service_standards_responses.actions_agreed IS 'Service standards section specific actions agreed';
      COMMENT ON COLUMN visit_health_information_responses.actions_agreed IS 'Health information section specific actions agreed';
      COMMENT ON COLUMN visit_integration_responses.actions_agreed IS 'Integration section specific actions agreed';
      
      -- Enhanced field comments
      COMMENT ON COLUMN visit_logistics_responses.medicine_quantities IS 'JSON field for detailed medicine quantities and units (legacy field)';
      COMMENT ON COLUMN visit_logistics_responses.expiry_dates_checked IS 'Whether medicine expiry dates were verified during visit';
      COMMENT ON COLUMN form_staff_training.training_certificates_verified IS 'Whether training certificates were verified during assessment';
    `);
    console.log('✅ Comprehensive table documentation added');

    // Create the ultimate complete view for all visit data
    await db.query(`
      CREATE OR REPLACE VIEW complete_supervision_data AS
      SELECT 
        sf.id as form_id,
        sf.health_facility_name,
        sf.province,
        sf.district,
        sf.created_at as form_created_at,
        sf.sync_status as form_sync_status,
        
        sv.id as visit_id,
        sv.visit_number,
        sv.visit_date,
        sv.recommendations,
        sv.actions_agreed as visit_actions_agreed,
        sv.supervisor_signature,
        sv.facility_representative_signature,
        sv.sync_status as visit_sync_status,
        
        u.full_name as doctor_name,
        u.username,
        u.email as doctor_email,
        
        -- JSON aggregated section data
        row_to_json(vam.*) as admin_management,
        row_to_json(vl.*) as logistics,
        row_to_json(ve.*) as equipment,
        row_to_json(vmhdc.*) as mhdc_management,
        row_to_json(vss.*) as service_standards,
        row_to_json(vhi.*) as health_information,
        row_to_json(vi.*) as integration,
        
        -- Aggregated detail tables
        (SELECT json_agg(row_to_json(vmd)) FROM visit_medicine_details vmd WHERE vmd.visit_id = sv.id) as medicine_details,
        (SELECT row_to_json(vpv) FROM visit_patient_volumes vpv WHERE vpv.visit_id = sv.id) as patient_volumes,
        (SELECT json_agg(row_to_json(vef)) FROM visit_equipment_functionality vef WHERE vef.visit_id = sv.id) as equipment_functionality,
        (SELECT row_to_json(vqa) FROM visit_quality_assurance vqa WHERE vqa.visit_id = sv.id) as quality_assurance,
        
        -- Form-level data
        (SELECT row_to_json(fst) FROM form_staff_training fst WHERE fst.form_id = sf.id) as staff_training,
        (SELECT row_to_json(ffi) FROM form_facility_infrastructure ffi WHERE ffi.form_id = sf.id) as facility_infrastructure,
        
        sv.created_at as visit_created_at,
        sv.updated_at as visit_updated_at
        
      FROM supervision_forms sf
      JOIN users u ON sf.user_id = u.id
      LEFT JOIN supervision_visits sv ON sf.id = sv.form_id
      LEFT JOIN visit_admin_management_responses vam ON sv.id = vam.visit_id
      LEFT JOIN visit_logistics_responses vl ON sv.id = vl.visit_id
      LEFT JOIN visit_equipment_responses ve ON sv.id = ve.visit_id
      LEFT JOIN visit_mhdc_management_responses vmhdc ON sv.id = vmhdc.visit_id
      LEFT JOIN visit_service_standards_responses vss ON sv.id = vss.visit_id
      LEFT JOIN visit_health_information_responses vhi ON sv.id = vhi.visit_id
      LEFT JOIN visit_integration_responses vi ON sv.id = vi.visit_id
      ORDER BY sf.id, sv.visit_number
    `);
    console.log('✅ Complete supervision data view created');

    console.log('🎉 All comprehensive visit-based tables created successfully with complete PDF compliance!');

  } catch (error) {
    console.error('❌ Error creating tables:', error);
    throw error;
  }
}

async function createDefaultAdmin() {
  console.log('🔄 Creating default admin user...');

  try {
    const existingAdminQuery = `SELECT id FROM users WHERE role = 'admin' LIMIT 1`;
    const existingAdmin = await db.query(existingAdminQuery);

    if (existingAdmin.rows.length > 0) {
      console.log('ℹ️  Admin user already exists, skipping creation');
      return;
    }

    const defaultPassword = 'Admin123!';
    const saltRounds = 12;
    const hashedPassword = await bcrypt.hash(defaultPassword, saltRounds);

    const createAdminQuery = `
      INSERT INTO users (username, email, password_hash, full_name, role, created_at, updated_at)
      VALUES ($1, $2, $3, $4, $5, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
      RETURNING id, username, email
    `;

    const result = await db.query(createAdminQuery, [
      'admin',
      'admin@supervision-app.com',
      hashedPassword,
      'System Administrator',
      'admin'
    ]);

    console.log('✅ Default admin user created:');
    console.log(`   Username: admin`);
    console.log(`   Email: admin@supervision-app.com`);
    console.log(`   Password: ${defaultPassword}`);
    console.log(`   ⚠️  Please change the default password after first login!`);

  } catch (error) {
    console.error('❌ Error creating default admin:', error);
    throw error;
  }
}

async function dropTables() {
  console.log('🔄 Dropping all tables...');

  try {
    const tables = [
      'sync_logs',
      'visit_quality_assurance',
      'visit_equipment_functionality',
      'form_facility_infrastructure',
      'visit_patient_volumes',
      'visit_medicine_details',
      'visit_integration_responses',
      'visit_health_information_responses',
      'visit_service_standards_responses',
      'form_staff_training',
      'visit_mhdc_management_responses',
      'visit_equipment_responses',
      'visit_logistics_responses',
      'visit_admin_management_responses',
      'supervision_visits',
      'supervision_forms',
      'users'
    ];

    // Drop view first
    await db.query(`DROP VIEW IF EXISTS complete_supervision_data CASCADE`);
    console.log('✅ Dropped view: complete_supervision_data');

    for (const table of tables) {
      await db.query(`DROP TABLE IF EXISTS ${table} CASCADE`);
      console.log(`✅ Dropped table: ${table}`);
    }

    console.log('🎉 All tables dropped successfully!');

  } catch (error) {
    console.error('❌ Error dropping tables:', error);
    throw error;
  }
}

async function resetDatabase() {
  console.log('🔄 Resetting database...');
  await dropTables();
  await createTables();
  await createDefaultAdmin();
  console.log('🎉 Database reset completed with complete PDF compliance!');
}

async function createSampleData() {
  console.log('🔄 Creating comprehensive sample data...');

  try {
    const adminResult = await db.query("SELECT id FROM users WHERE username = 'admin'");
    if (adminResult.rows.length === 0) {
      throw new Error('Admin user not found. Run migration first.');
    }
    const adminId = adminResult.rows[0].id;

    // Create sample form
    const formQuery = `
      INSERT INTO supervision_forms (
        user_id, health_facility_name, province, district, sync_status
      ) VALUES ($1, $2, $3, $4, $5)
      RETURNING id
    `;

    const formResult = await db.query(formQuery, [
      adminId,
      'Central Health Post',
      'Bagmati Province',
      'Kathmandu',
      'local'
    ]);

    const formId = formResult.rows[0].id;

    // Create comprehensive sample visit
    const visit1Query = `
      INSERT INTO supervision_visits (
        form_id, visit_number, visit_date, recommendations, actions_agreed, sync_status
      ) VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING id
    `;

    const visit1Result = await db.query(visit1Query, [
      formId, 1, '2025-01-01', 
      'Improve medicine availability, enhance staff training on WHO-ISH charts, and maintain regular register updates',
      'Facility to order missing medicines by Jan 15. Staff training on CVD risk charts by Jan 30. Monthly register review meetings established.',
      'local'
    ]);

    const visit1Id = visit1Result.rows[0].id;

    // Add comprehensive sample data for all sections
    
    // Admin management with all comments
    await db.query(`
      INSERT INTO visit_admin_management_responses (
        visit_id, a1_response, a1_comment, a1_respondents_comment,
        a2_response, a2_comment, a2_respondents_comment,
        a3_response, a3_comment, a3_respondents_comment, actions_agreed
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
    `, [
      visit1Id, 'Y', 'Committee functioning well with regular meetings', 'Monthly meetings held consistently',
      'N', 'NCD discussions need to be more frequent', 'Currently discussed quarterly only',
      'Y', 'Regular quarterly discussions happening', 'Good coordination observed',
      'Committee to include monthly NCD agenda item starting February. Committee chair to attend NCD training.'
    ]);

    // Comprehensive logistics with quantities
    await db.query(`
      INSERT INTO visit_logistics_responses (
        visit_id, b1_response, b1_comment, b1_respondents_comment,
        amlodipine_5_10mg, amlodipine_5_10mg_quantity, amlodipine_5_10mg_units,
        metformin_500mg, metformin_500mg_quantity, metformin_500mg_units,
        aspirin_75mg, aspirin_75mg_quantity, aspirin_75mg_units,
        b2_response, b2_comment, b2_random_records_checked,
        b3_response, b3_comment, b3_expiry_date_verified,
        actions_agreed
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20)
    `, [
      visit1Id, 'Y', 'Most essential medicines available', 'Good stock maintained for most items',
      'Y', 150, 'tablets', 'N', 0, 'tablets', 'Y', 200, 'tablets',
      'Y', 'Glucometer functioning well', true,
      'Y', 'Strips available and being used', true,
      'Order metformin 500mg immediately. Ensure minimum stock levels maintained for all diabetes medications.'
    ]);

    // Equipment with quantities
    await db.query(`
      INSERT INTO visit_equipment_responses (
        visit_id, sphygmomanometer, sphygmomanometer_quantity,
        weighing_scale, weighing_scale_quantity,
        glucometer, glucometer_quantity,
        pulse_oximetry, pulse_oximetry_quantity,
        actions_agreed
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
    `, [
      visit1Id, 'Y', 2, 'Y', 1, 'Y', 1, 'N', 0,
      'Purchase pulse oximetry for improved respiratory assessment capabilities.'
    ]);

    // MHDC management with detailed tracking
    await db.query(`
      INSERT INTO visit_mhdc_management_responses (
        visit_id, b6_response, b6_comment, b6_healthcare_workers_refer_easily,
        b7_response, b7_comment, b7_available_at_health_center,
        b8_response, b8_comment, b8_available_and_filled_properly,
        b9_response, b9_comment, b9_available_for_patient_care,
        b10_response, b10_comment, b10_in_use_for_patient_care,
        b10_staff_trained_on_chart, b10_charts_completed_during_visit,
        actions_agreed
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19)
    `, [
      visit1Id, 'Y', 'Leaflets available and accessible', true,
      'Y', 'Good variety of educational materials', true,
      'Y', 'Register maintained properly', true,
      'Y', 'WHO-ISH charts available', true,
      'N', 'Charts not being used consistently', false,
      false, 0,
      'Train all clinical staff on WHO-ISH chart usage by month-end. Conduct practice sessions weekly.'
    ]);

    // Comprehensive service standards with all C2 sub-services
    await db.query(`
      INSERT INTO visit_service_standards_responses (
        visit_id, c2_main_response, c2_main_comment,
        c2_blood_pressure, c2_blood_pressure_equipment_calibrated,
        c2_blood_sugar, c2_blood_sugar_strips_available,
        c2_bmi_measurement, c2_bmi_calculation_accurate,
        c2_cvd_risk_estimation, c2_cvd_chart_available_and_used,
        c3_response, c3_comment,
        c4_response, c4_comment,
        c5_response, c5_comment,
        actions_agreed
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18)
    `, [
      visit1Id, 'Y', 'Most services provided according to protocol',
      'Y', true, 'Y', true, 'Y', true, 'N', false,
      'Y', 'Privacy maintained well',
      'N', 'Home visits not yet started',
      'Y', 'Community outreach active',
      'Implement CVD risk estimation using WHO-ISH charts. Develop home visit protocol for bed-bound patients.'
    ]);

    // Health information
    await db.query(`
      INSERT INTO visit_health_information_responses (
        visit_id, d1_response, d1_comment, d2_response, d2_comment,
        d3_response, d3_comment, d4_response, d4_comment, d4_number_of_people,
        d5_response, d5_comment, actions_agreed
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
    `, [
      visit1Id, 'Y', 'Register updated regularly', 'Y', 'Dashboard current',
      'Y', 'Reports submitted on time', 'Y', 'Good patient volume data', 45,
      'Y', 'Dedicated staff assigned', 'Maintain current good practices in data management.'
    ]);

    // Integration
    await db.query(`
      INSERT INTO visit_integration_responses (
        visit_id, e1_response, e1_comment, e2_response, e2_comment,
        e3_response, e3_comment, actions_agreed
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
    `, [
      visit1Id, 'Y', 'Staff aware of PEN programme', 'Y', 'Health education provided regularly',
      'Y', 'Screening conducted systematically', 'Continue current integration practices with enhanced documentation.'
    ]);

    // Staff training data
    await db.query(`
      INSERT INTO form_staff_training (
        form_id, ha_total_staff, ha_mhdc_trained, ha_fen_trained,
        sr_ahw_total_staff, sr_ahw_mhdc_trained, sr_ahw_fen_trained,
        ahw_total_staff, ahw_mhdc_trained, ahw_fen_trained,
        anm_total_staff, anm_mhdc_trained, anm_fen_trained,
        last_mhdc_training_date, training_provider, training_certificates_verified
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16)
    `, [formId, 3, 2, 2, 2, 1, 1, 4, 3, 2, 3, 2, 2, '2024-12-15', 'MHDC Training Institute', true]);

    // Medicine details
    await db.query(`
      INSERT INTO visit_medicine_details (
        visit_id, medicine_name, medicine_category, availability, quantity_available,
        unit_of_measurement, expiry_date, storage_temperature_ok, storage_humidity_ok
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
    `, [visit1Id, 'Amlodipine 5mg', 'antihypertensive', 'Y', 150, 'tablets', '2025-08-15', true, true]);

    await db.query(`
      INSERT INTO visit_medicine_details (
        visit_id, medicine_name, medicine_category, availability, quantity_available,
        unit_of_measurement, storage_temperature_ok, storage_humidity_ok
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
    `, [visit1Id, 'Metformin 500mg', 'diabetes', 'N', 0, 'tablets', true, true]);

    // Patient volume data
    await db.query(`
      INSERT INTO visit_patient_volumes (
        visit_id, total_patients_seen, ncd_patients_new, ncd_patients_followup,
        diabetes_patients, hypertension_patients, referrals_made, month_year, data_verified
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
    `, [visit1Id, 45, 8, 37, 20, 25, 3, '2025-01-01', true]);

    // Facility infrastructure data
    await db.query(`
      INSERT INTO form_facility_infrastructure (
        form_id, total_rooms, consultation_rooms, waiting_area_adequate,
        pharmacy_storage_adequate, cold_chain_available, generator_backup,
        water_supply_reliable, assessment_date, infrastructure_score
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
    `, [formId, 8, 3, true, true, false, true, true, '2025-01-01', 85]);

    // Equipment functionality details
    await db.query(`
      INSERT INTO visit_equipment_functionality (
        visit_id, equipment_name, equipment_category, availability, functionality_status,
        last_calibration_date, staff_trained_on_equipment, user_manual_available
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
    `, [visit1Id, 'Digital Sphygmomanometer', 'diagnostic', 'Y', 'working', '2024-12-01', true, true]);

    // Quality assurance data
    await db.query(`
      INSERT INTO visit_quality_assurance (
        visit_id, guidelines_followed, protocols_updated, records_complete,
        infection_control_practices, staff_knowledge_adequate, overall_quality_score
      ) VALUES ($1, $2, $3, $4, $5, $6, $7)
    `, [visit1Id, true, true, true, true, true, 88]);

    console.log('✅ Comprehensive sample data created with all PDF-compliant fields');

  } catch (error) {
    console.error('❌ Error creating sample data:', error);
    throw error;
  }
}

async function main() {
  const command = process.argv[2];

  try {
    await db.testConnection();
    console.log('✅ Database connection successful');

    switch (command) {
      case 'create':
        await createTables();
        await createDefaultAdmin();
        break;
      case 'drop':
        await dropTables();
        break;
      case 'reset':
        await resetDatabase();
        break;
      case 'admin':
        await createDefaultAdmin();
        break;
      case 'sample':
        await createSampleData();
        break;
      default:
        console.log('📋 Available commands:');
        console.log('  npm run migrate create  - Create all tables and default admin');
        console.log('  npm run migrate drop    - Drop all tables');
        console.log('  npm run migrate reset   - Drop and recreate all tables');
        console.log('  npm run migrate admin   - Create default admin user');
        console.log('  npm run migrate sample  - Create comprehensive sample data');
        process.exit(0);
    }

  } catch (error) {
    console.error('❌ Migration failed:', error.message);
    process.exit(1);
  } finally {
    await db.closeConnection();
    console.log('✅ Database connection closed');
  }
}

if (require.main === module) {
  main();
}

module.exports = {
  createTables,
  createDefaultAdmin,
  dropTables,
  resetDatabase,
  createSampleData
};