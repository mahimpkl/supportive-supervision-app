require('dotenv').config();
const db = require('../config/database');
const bcrypt = require('bcryptjs');

async function createTables() {
  console.log('🔄 Creating database tables...');

  try {
    // Users table
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

    // Supervision forms table - main form header
    await db.query(`
      CREATE TABLE IF NOT EXISTS supervision_forms (
        id SERIAL PRIMARY KEY,
        user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
        health_facility_name VARCHAR(200) NOT NULL,
        province VARCHAR(100) NOT NULL,
        district VARCHAR(100) NOT NULL,
        visit_1_date DATE,
        visit_2_date DATE,
        visit_3_date DATE,
        visit_4_date DATE,
        form_created_at TIMESTAMP NOT NULL,
        synced_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        last_modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        sync_status VARCHAR(20) DEFAULT 'local',
        supervisor_signature TEXT,
        facility_representative_signature TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ Supervision forms table created');

    // A. Administration and Management responses
    await db.query(`
      CREATE TABLE IF NOT EXISTS admin_management_responses (
        id SERIAL PRIMARY KEY,
        form_id INTEGER REFERENCES supervision_forms(id) ON DELETE CASCADE,
        -- A1: Health Facility Operation and Management Committee
        a1_visit_1 VARCHAR(1) CHECK (a1_visit_1 IN ('Y', 'N')),
        a1_visit_2 VARCHAR(1) CHECK (a1_visit_2 IN ('Y', 'N')),
        a1_visit_3 VARCHAR(1) CHECK (a1_visit_3 IN ('Y', 'N')),
        a1_visit_4 VARCHAR(1) CHECK (a1_visit_4 IN ('Y', 'N')),
        a1_comment TEXT,
        -- A2: Committee discusses NCD service provisions
        a2_visit_1 VARCHAR(1) CHECK (a2_visit_1 IN ('Y', 'N')),
        a2_visit_2 VARCHAR(1) CHECK (a2_visit_2 IN ('Y', 'N')),
        a2_visit_3 VARCHAR(1) CHECK (a2_visit_3 IN ('Y', 'N')),
        a2_visit_4 VARCHAR(1) CHECK (a2_visit_4 IN ('Y', 'N')),
        a2_comment TEXT,
        -- A3: Health facility and health care workers discuss quarterly
        a3_visit_1 VARCHAR(1) CHECK (a3_visit_1 IN ('Y', 'N')),
        a3_visit_2 VARCHAR(1) CHECK (a3_visit_2 IN ('Y', 'N')),
        a3_visit_3 VARCHAR(1) CHECK (a3_visit_3 IN ('Y', 'N')),
        a3_visit_4 VARCHAR(1) CHECK (a3_visit_4 IN ('Y', 'N')),
        a3_comment TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ Admin management responses table created');

    // B. Logistics responses (medicines, supplies & equipment) - EXACT match to PDF
    await db.query(`
      CREATE TABLE IF NOT EXISTS logistics_responses (
        id SERIAL PRIMARY KEY,
        form_id INTEGER REFERENCES supervision_forms(id) ON DELETE CASCADE,
        -- B1: Essential NCD medicines available and sufficient for 2 months
        b1_visit_1 VARCHAR(1) CHECK (b1_visit_1 IN ('Y', 'N')),
        b1_visit_2 VARCHAR(1) CHECK (b1_visit_2 IN ('Y', 'N')),
        b1_visit_3 VARCHAR(1) CHECK (b1_visit_3 IN ('Y', 'N')),
        b1_visit_4 VARCHAR(1) CHECK (b1_visit_4 IN ('Y', 'N')),
        b1_comment TEXT,
        
        -- Blood pressure medications (as per PDF)
        amlodipine_5_10mg_v1 VARCHAR(1) CHECK (amlodipine_5_10mg_v1 IN ('Y', 'N')),
        amlodipine_5_10mg_v2 VARCHAR(1) CHECK (amlodipine_5_10mg_v2 IN ('Y', 'N')),
        amlodipine_5_10mg_v3 VARCHAR(1) CHECK (amlodipine_5_10mg_v3 IN ('Y', 'N')),
        amlodipine_5_10mg_v4 VARCHAR(1) CHECK (amlodipine_5_10mg_v4 IN ('Y', 'N')),
        
        enalapril_2_5_10mg_v1 VARCHAR(1) CHECK (enalapril_2_5_10mg_v1 IN ('Y', 'N')),
        enalapril_2_5_10mg_v2 VARCHAR(1) CHECK (enalapril_2_5_10mg_v2 IN ('Y', 'N')),
        enalapril_2_5_10mg_v3 VARCHAR(1) CHECK (enalapril_2_5_10mg_v3 IN ('Y', 'N')),
        enalapril_2_5_10mg_v4 VARCHAR(1) CHECK (enalapril_2_5_10mg_v4 IN ('Y', 'N')),
        
        losartan_25_50mg_v1 VARCHAR(1) CHECK (losartan_25_50mg_v1 IN ('Y', 'N')),
        losartan_25_50mg_v2 VARCHAR(1) CHECK (losartan_25_50mg_v2 IN ('Y', 'N')),
        losartan_25_50mg_v3 VARCHAR(1) CHECK (losartan_25_50mg_v3 IN ('Y', 'N')),
        losartan_25_50mg_v4 VARCHAR(1) CHECK (losartan_25_50mg_v4 IN ('Y', 'N')),
        
        hydrochlorothiazide_12_5_25mg_v1 VARCHAR(1) CHECK (hydrochlorothiazide_12_5_25mg_v1 IN ('Y', 'N')),
        hydrochlorothiazide_12_5_25mg_v2 VARCHAR(1) CHECK (hydrochlorothiazide_12_5_25mg_v2 IN ('Y', 'N')),
        hydrochlorothiazide_12_5_25mg_v3 VARCHAR(1) CHECK (hydrochlorothiazide_12_5_25mg_v3 IN ('Y', 'N')),
        hydrochlorothiazide_12_5_25mg_v4 VARCHAR(1) CHECK (hydrochlorothiazide_12_5_25mg_v4 IN ('Y', 'N')),
        
        chlorthalidone_6_25_12_5mg_v1 VARCHAR(1) CHECK (chlorthalidone_6_25_12_5mg_v1 IN ('Y', 'N')),
        chlorthalidone_6_25_12_5mg_v2 VARCHAR(1) CHECK (chlorthalidone_6_25_12_5mg_v2 IN ('Y', 'N')),
        chlorthalidone_6_25_12_5mg_v3 VARCHAR(1) CHECK (chlorthalidone_6_25_12_5mg_v3 IN ('Y', 'N')),
        chlorthalidone_6_25_12_5mg_v4 VARCHAR(1) CHECK (chlorthalidone_6_25_12_5mg_v4 IN ('Y', 'N')),
        
        -- Other antihypertensives (from PDF page 2)
        other_antihypertensives_v1 VARCHAR(1) CHECK (other_antihypertensives_v1 IN ('Y', 'N')),
        other_antihypertensives_v2 VARCHAR(1) CHECK (other_antihypertensives_v2 IN ('Y', 'N')),
        other_antihypertensives_v3 VARCHAR(1) CHECK (other_antihypertensives_v3 IN ('Y', 'N')),
        other_antihypertensives_v4 VARCHAR(1) CHECK (other_antihypertensives_v4 IN ('Y', 'N')),
        
        -- Statins
        atorvastatin_5mg_v1 VARCHAR(1) CHECK (atorvastatin_5mg_v1 IN ('Y', 'N')),
        atorvastatin_5mg_v2 VARCHAR(1) CHECK (atorvastatin_5mg_v2 IN ('Y', 'N')),
        atorvastatin_5mg_v3 VARCHAR(1) CHECK (atorvastatin_5mg_v3 IN ('Y', 'N')),
        atorvastatin_5mg_v4 VARCHAR(1) CHECK (atorvastatin_5mg_v4 IN ('Y', 'N')),
        
        atorvastatin_10mg_v1 VARCHAR(1) CHECK (atorvastatin_10mg_v1 IN ('Y', 'N')),
        atorvastatin_10mg_v2 VARCHAR(1) CHECK (atorvastatin_10mg_v2 IN ('Y', 'N')),
        atorvastatin_10mg_v3 VARCHAR(1) CHECK (atorvastatin_10mg_v3 IN ('Y', 'N')),
        atorvastatin_10mg_v4 VARCHAR(1) CHECK (atorvastatin_10mg_v4 IN ('Y', 'N')),
        
        atorvastatin_20mg_v1 VARCHAR(1) CHECK (atorvastatin_20mg_v1 IN ('Y', 'N')),
        atorvastatin_20mg_v2 VARCHAR(1) CHECK (atorvastatin_20mg_v2 IN ('Y', 'N')),
        atorvastatin_20mg_v3 VARCHAR(1) CHECK (atorvastatin_20mg_v3 IN ('Y', 'N')),
        atorvastatin_20mg_v4 VARCHAR(1) CHECK (atorvastatin_20mg_v4 IN ('Y', 'N')),
        
        other_statins_v1 VARCHAR(1) CHECK (other_statins_v1 IN ('Y', 'N')),
        other_statins_v2 VARCHAR(1) CHECK (other_statins_v2 IN ('Y', 'N')),
        other_statins_v3 VARCHAR(1) CHECK (other_statins_v3 IN ('Y', 'N')),
        other_statins_v4 VARCHAR(1) CHECK (other_statins_v4 IN ('Y', 'N')),
        
        -- Diabetes medications
        metformin_500mg_v1 VARCHAR(1) CHECK (metformin_500mg_v1 IN ('Y', 'N')),
        metformin_500mg_v2 VARCHAR(1) CHECK (metformin_500mg_v2 IN ('Y', 'N')),
        metformin_500mg_v3 VARCHAR(1) CHECK (metformin_500mg_v3 IN ('Y', 'N')),
        metformin_500mg_v4 VARCHAR(1) CHECK (metformin_500mg_v4 IN ('Y', 'N')),
        
        metformin_1000mg_v1 VARCHAR(1) CHECK (metformin_1000mg_v1 IN ('Y', 'N')),
        metformin_1000mg_v2 VARCHAR(1) CHECK (metformin_1000mg_v2 IN ('Y', 'N')),
        metformin_1000mg_v3 VARCHAR(1) CHECK (metformin_1000mg_v3 IN ('Y', 'N')),
        metformin_1000mg_v4 VARCHAR(1) CHECK (metformin_1000mg_v4 IN ('Y', 'N')),
        
        glimepiride_1_2mg_v1 VARCHAR(1) CHECK (glimepiride_1_2mg_v1 IN ('Y', 'N')),
        glimepiride_1_2mg_v2 VARCHAR(1) CHECK (glimepiride_1_2mg_v2 IN ('Y', 'N')),
        glimepiride_1_2mg_v3 VARCHAR(1) CHECK (glimepiride_1_2mg_v3 IN ('Y', 'N')),
        glimepiride_1_2mg_v4 VARCHAR(1) CHECK (glimepiride_1_2mg_v4 IN ('Y', 'N')),
        
        gliclazide_40_80mg_v1 VARCHAR(1) CHECK (gliclazide_40_80mg_v1 IN ('Y', 'N')),
        gliclazide_40_80mg_v2 VARCHAR(1) CHECK (gliclazide_40_80mg_v2 IN ('Y', 'N')),
        gliclazide_40_80mg_v3 VARCHAR(1) CHECK (gliclazide_40_80mg_v3 IN ('Y', 'N')),
        gliclazide_40_80mg_v4 VARCHAR(1) CHECK (gliclazide_40_80mg_v4 IN ('Y', 'N')),
        
        glipizide_2_5_5mg_v1 VARCHAR(1) CHECK (glipizide_2_5_5mg_v1 IN ('Y', 'N')),
        glipizide_2_5_5mg_v2 VARCHAR(1) CHECK (glipizide_2_5_5mg_v2 IN ('Y', 'N')),
        glipizide_2_5_5mg_v3 VARCHAR(1) CHECK (glipizide_2_5_5mg_v3 IN ('Y', 'N')),
        glipizide_2_5_5mg_v4 VARCHAR(1) CHECK (glipizide_2_5_5mg_v4 IN ('Y', 'N')),
        
        sitagliptin_50mg_v1 VARCHAR(1) CHECK (sitagliptin_50mg_v1 IN ('Y', 'N')),
        sitagliptin_50mg_v2 VARCHAR(1) CHECK (sitagliptin_50mg_v2 IN ('Y', 'N')),
        sitagliptin_50mg_v3 VARCHAR(1) CHECK (sitagliptin_50mg_v3 IN ('Y', 'N')),
        sitagliptin_50mg_v4 VARCHAR(1) CHECK (sitagliptin_50mg_v4 IN ('Y', 'N')),
        
        pioglitazone_5mg_v1 VARCHAR(1) CHECK (pioglitazone_5mg_v1 IN ('Y', 'N')),
        pioglitazone_5mg_v2 VARCHAR(1) CHECK (pioglitazone_5mg_v2 IN ('Y', 'N')),
        pioglitazone_5mg_v3 VARCHAR(1) CHECK (pioglitazone_5mg_v3 IN ('Y', 'N')),
        pioglitazone_5mg_v4 VARCHAR(1) CHECK (pioglitazone_5mg_v4 IN ('Y', 'N')),
        
        empagliflozin_10mg_v1 VARCHAR(1) CHECK (empagliflozin_10mg_v1 IN ('Y', 'N')),
        empagliflozin_10mg_v2 VARCHAR(1) CHECK (empagliflozin_10mg_v2 IN ('Y', 'N')),
        empagliflozin_10mg_v3 VARCHAR(1) CHECK (empagliflozin_10mg_v3 IN ('Y', 'N')),
        empagliflozin_10mg_v4 VARCHAR(1) CHECK (empagliflozin_10mg_v4 IN ('Y', 'N')),
        
        insulin_soluble_inj_v1 VARCHAR(1) CHECK (insulin_soluble_inj_v1 IN ('Y', 'N')),
        insulin_soluble_inj_v2 VARCHAR(1) CHECK (insulin_soluble_inj_v2 IN ('Y', 'N')),
        insulin_soluble_inj_v3 VARCHAR(1) CHECK (insulin_soluble_inj_v3 IN ('Y', 'N')),
        insulin_soluble_inj_v4 VARCHAR(1) CHECK (insulin_soluble_inj_v4 IN ('Y', 'N')),
        
        insulin_nph_inj_v1 VARCHAR(1) CHECK (insulin_nph_inj_v1 IN ('Y', 'N')),
        insulin_nph_inj_v2 VARCHAR(1) CHECK (insulin_nph_inj_v2 IN ('Y', 'N')),
        insulin_nph_inj_v3 VARCHAR(1) CHECK (insulin_nph_inj_v3 IN ('Y', 'N')),
        insulin_nph_inj_v4 VARCHAR(1) CHECK (insulin_nph_inj_v4 IN ('Y', 'N')),
        
        other_hypoglycemic_agents_v1 VARCHAR(1) CHECK (other_hypoglycemic_agents_v1 IN ('Y', 'N')),
        other_hypoglycemic_agents_v2 VARCHAR(1) CHECK (other_hypoglycemic_agents_v2 IN ('Y', 'N')),
        other_hypoglycemic_agents_v3 VARCHAR(1) CHECK (other_hypoglycemic_agents_v3 IN ('Y', 'N')),
        other_hypoglycemic_agents_v4 VARCHAR(1) CHECK (other_hypoglycemic_agents_v4 IN ('Y', 'N')),
        
        dextrose_25_solution_v1 VARCHAR(1) CHECK (dextrose_25_solution_v1 IN ('Y', 'N')),
        dextrose_25_solution_v2 VARCHAR(1) CHECK (dextrose_25_solution_v2 IN ('Y', 'N')),
        dextrose_25_solution_v3 VARCHAR(1) CHECK (dextrose_25_solution_v3 IN ('Y', 'N')),
        dextrose_25_solution_v4 VARCHAR(1) CHECK (dextrose_25_solution_v4 IN ('Y', 'N')),
        
        aspirin_75mg_v1 VARCHAR(1) CHECK (aspirin_75mg_v1 IN ('Y', 'N')),
        aspirin_75mg_v2 VARCHAR(1) CHECK (aspirin_75mg_v2 IN ('Y', 'N')),
        aspirin_75mg_v3 VARCHAR(1) CHECK (aspirin_75mg_v3 IN ('Y', 'N')),
        aspirin_75mg_v4 VARCHAR(1) CHECK (aspirin_75mg_v4 IN ('Y', 'N')),
        
        clopidogrel_75mg_v1 VARCHAR(1) CHECK (clopidogrel_75mg_v1 IN ('Y', 'N')),
        clopidogrel_75mg_v2 VARCHAR(1) CHECK (clopidogrel_75mg_v2 IN ('Y', 'N')),
        clopidogrel_75mg_v3 VARCHAR(1) CHECK (clopidogrel_75mg_v3 IN ('Y', 'N')),
        clopidogrel_75mg_v4 VARCHAR(1) CHECK (clopidogrel_75mg_v4 IN ('Y', 'N')),
        
        metoprolol_succinate_12_5_25_50mg_v1 VARCHAR(1) CHECK (metoprolol_succinate_12_5_25_50mg_v1 IN ('Y', 'N')),
        metoprolol_succinate_12_5_25_50mg_v2 VARCHAR(1) CHECK (metoprolol_succinate_12_5_25_50mg_v2 IN ('Y', 'N')),
        metoprolol_succinate_12_5_25_50mg_v3 VARCHAR(1) CHECK (metoprolol_succinate_12_5_25_50mg_v3 IN ('Y', 'N')),
        metoprolol_succinate_12_5_25_50mg_v4 VARCHAR(1) CHECK (metoprolol_succinate_12_5_25_50mg_v4 IN ('Y', 'N')),
        
        -- Additional medications from PDF page 3
        isosorbide_dinitrate_5mg_v1 VARCHAR(1) CHECK (isosorbide_dinitrate_5mg_v1 IN ('Y', 'N')),
        isosorbide_dinitrate_5mg_v2 VARCHAR(1) CHECK (isosorbide_dinitrate_5mg_v2 IN ('Y', 'N')),
        isosorbide_dinitrate_5mg_v3 VARCHAR(1) CHECK (isosorbide_dinitrate_5mg_v3 IN ('Y', 'N')),
        isosorbide_dinitrate_5mg_v4 VARCHAR(1) CHECK (isosorbide_dinitrate_5mg_v4 IN ('Y', 'N')),
        
        other_drugs_v1 VARCHAR(1) CHECK (other_drugs_v1 IN ('Y', 'N')),
        other_drugs_v2 VARCHAR(1) CHECK (other_drugs_v2 IN ('Y', 'N')),
        other_drugs_v3 VARCHAR(1) CHECK (other_drugs_v3 IN ('Y', 'N')),
        other_drugs_v4 VARCHAR(1) CHECK (other_drugs_v4 IN ('Y', 'N')),
        
        -- Respiratory medications (from PDF page 3)
        amoxicillin_clavulanic_potassium_625mg_v1 VARCHAR(1) CHECK (amoxicillin_clavulanic_potassium_625mg_v1 IN ('Y', 'N')),
        amoxicillin_clavulanic_potassium_625mg_v2 VARCHAR(1) CHECK (amoxicillin_clavulanic_potassium_625mg_v2 IN ('Y', 'N')),
        amoxicillin_clavulanic_potassium_625mg_v3 VARCHAR(1) CHECK (amoxicillin_clavulanic_potassium_625mg_v3 IN ('Y', 'N')),
        amoxicillin_clavulanic_potassium_625mg_v4 VARCHAR(1) CHECK (amoxicillin_clavulanic_potassium_625mg_v4 IN ('Y', 'N')),
        
        azithromycin_500mg_v1 VARCHAR(1) CHECK (azithromycin_500mg_v1 IN ('Y', 'N')),
        azithromycin_500mg_v2 VARCHAR(1) CHECK (azithromycin_500mg_v2 IN ('Y', 'N')),
        azithromycin_500mg_v3 VARCHAR(1) CHECK (azithromycin_500mg_v3 IN ('Y', 'N')),
        azithromycin_500mg_v4 VARCHAR(1) CHECK (azithromycin_500mg_v4 IN ('Y', 'N')),
        
        other_antibiotics_v1 VARCHAR(1) CHECK (other_antibiotics_v1 IN ('Y', 'N')),
        other_antibiotics_v2 VARCHAR(1) CHECK (other_antibiotics_v2 IN ('Y', 'N')),
        other_antibiotics_v3 VARCHAR(1) CHECK (other_antibiotics_v3 IN ('Y', 'N')),
        other_antibiotics_v4 VARCHAR(1) CHECK (other_antibiotics_v4 IN ('Y', 'N')),
        
        salbutamol_dpi_v1 VARCHAR(1) CHECK (salbutamol_dpi_v1 IN ('Y', 'N')),
        salbutamol_dpi_v2 VARCHAR(1) CHECK (salbutamol_dpi_v2 IN ('Y', 'N')),
        salbutamol_dpi_v3 VARCHAR(1) CHECK (salbutamol_dpi_v3 IN ('Y', 'N')),
        salbutamol_dpi_v4 VARCHAR(1) CHECK (salbutamol_dpi_v4 IN ('Y', 'N')),
        
        salbutamol_v1 VARCHAR(1) CHECK (salbutamol_v1 IN ('Y', 'N')),
        salbutamol_v2 VARCHAR(1) CHECK (salbutamol_v2 IN ('Y', 'N')),
        salbutamol_v3 VARCHAR(1) CHECK (salbutamol_v3 IN ('Y', 'N')),
        salbutamol_v4 VARCHAR(1) CHECK (salbutamol_v4 IN ('Y', 'N')),
        
        ipratropium_v1 VARCHAR(1) CHECK (ipratropium_v1 IN ('Y', 'N')),
        ipratropium_v2 VARCHAR(1) CHECK (ipratropium_v2 IN ('Y', 'N')),
        ipratropium_v3 VARCHAR(1) CHECK (ipratropium_v3 IN ('Y', 'N')),
        ipratropium_v4 VARCHAR(1) CHECK (ipratropium_v4 IN ('Y', 'N')),
        
        tiotropium_bromide_v1 VARCHAR(1) CHECK (tiotropium_bromide_v1 IN ('Y', 'N')),
        tiotropium_bromide_v2 VARCHAR(1) CHECK (tiotropium_bromide_v2 IN ('Y', 'N')),
        tiotropium_bromide_v3 VARCHAR(1) CHECK (tiotropium_bromide_v3 IN ('Y', 'N')),
        tiotropium_bromide_v4 VARCHAR(1) CHECK (tiotropium_bromide_v4 IN ('Y', 'N')),
        
        formoterol_v1 VARCHAR(1) CHECK (formoterol_v1 IN ('Y', 'N')),
        formoterol_v2 VARCHAR(1) CHECK (formoterol_v2 IN ('Y', 'N')),
        formoterol_v3 VARCHAR(1) CHECK (formoterol_v3 IN ('Y', 'N')),
        formoterol_v4 VARCHAR(1) CHECK (formoterol_v4 IN ('Y', 'N')),
        
        other_bronchodilators_v1 VARCHAR(1) CHECK (other_bronchodilators_v1 IN ('Y', 'N')),
        other_bronchodilators_v2 VARCHAR(1) CHECK (other_bronchodilators_v2 IN ('Y', 'N')),
        other_bronchodilators_v3 VARCHAR(1) CHECK (other_bronchodilators_v3 IN ('Y', 'N')),
        other_bronchodilators_v4 VARCHAR(1) CHECK (other_bronchodilators_v4 IN ('Y', 'N')),
        
        prednisolone_5_10_20mg_v1 VARCHAR(1) CHECK (prednisolone_5_10_20mg_v1 IN ('Y', 'N')),
        prednisolone_5_10_20mg_v2 VARCHAR(1) CHECK (prednisolone_5_10_20mg_v2 IN ('Y', 'N')),
        prednisolone_5_10_20mg_v3 VARCHAR(1) CHECK (prednisolone_5_10_20mg_v3 IN ('Y', 'N')),
        prednisolone_5_10_20mg_v4 VARCHAR(1) CHECK (prednisolone_5_10_20mg_v4 IN ('Y', 'N')),
        
        other_steroids_oral_v1 VARCHAR(1) CHECK (other_steroids_oral_v1 IN ('Y', 'N')),
        other_steroids_oral_v2 VARCHAR(1) CHECK (other_steroids_oral_v2 IN ('Y', 'N')),
        other_steroids_oral_v3 VARCHAR(1) CHECK (other_steroids_oral_v3 IN ('Y', 'N')),
        other_steroids_oral_v4 VARCHAR(1) CHECK (other_steroids_oral_v4 IN ('Y', 'N')),
        
        -- B2: Blood glucometer functioning and in use
        b2_visit_1 VARCHAR(1) CHECK (b2_visit_1 IN ('Y', 'N')),
        b2_visit_2 VARCHAR(1) CHECK (b2_visit_2 IN ('Y', 'N')),
        b2_visit_3 VARCHAR(1) CHECK (b2_visit_3 IN ('Y', 'N')),
        b2_visit_4 VARCHAR(1) CHECK (b2_visit_4 IN ('Y', 'N')),
        b2_comment TEXT,
        
        -- B3: Urine protein strips used
        b3_visit_1 VARCHAR(1) CHECK (b3_visit_1 IN ('Y', 'N')),
        b3_visit_2 VARCHAR(1) CHECK (b3_visit_2 IN ('Y', 'N')),
        b3_visit_3 VARCHAR(1) CHECK (b3_visit_3 IN ('Y', 'N')),
        b3_visit_4 VARCHAR(1) CHECK (b3_visit_4 IN ('Y', 'N')),
        b3_comment TEXT,
        
        -- B4: Urine ketone strips used
        b4_visit_1 VARCHAR(1) CHECK (b4_visit_1 IN ('Y', 'N')),
        b4_visit_2 VARCHAR(1) CHECK (b4_visit_2 IN ('Y', 'N')),
        b4_visit_3 VARCHAR(1) CHECK (b4_visit_3 IN ('Y', 'N')),
        b4_visit_4 VARCHAR(1) CHECK (b4_visit_4 IN ('Y', 'N')),
        b4_comment TEXT,
        
        -- B5: Essential equipment available and functional
        b5_visit_1 VARCHAR(1) CHECK (b5_visit_1 IN ('Y', 'N')),
        b5_visit_2 VARCHAR(1) CHECK (b5_visit_2 IN ('Y', 'N')),
        b5_visit_3 VARCHAR(1) CHECK (b5_visit_3 IN ('Y', 'N')),
        b5_visit_4 VARCHAR(1) CHECK (b5_visit_4 IN ('Y', 'N')),
        b5_comment TEXT,
        
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ Logistics responses table created');

    // -- Equipment responses (B5 details from PDF page 4)
    await db.query(`
      CREATE TABLE IF NOT EXISTS equipment_responses (
        id SERIAL PRIMARY KEY,
        form_id INTEGER REFERENCES supervision_forms(id) ON DELETE CASCADE,
        
        -- Equipment checklist from PDF page 4
        sphygmomanometer_v1 VARCHAR(1) CHECK (sphygmomanometer_v1 IN ('Y', 'N')),
        sphygmomanometer_v2 VARCHAR(1) CHECK (sphygmomanometer_v2 IN ('Y', 'N')),
        sphygmomanometer_v3 VARCHAR(1) CHECK (sphygmomanometer_v3 IN ('Y', 'N')),
        sphygmomanometer_v4 VARCHAR(1) CHECK (sphygmomanometer_v4 IN ('Y', 'N')),
        
        weighing_scale_v1 VARCHAR(1) CHECK (weighing_scale_v1 IN ('Y', 'N')),
        weighing_scale_v2 VARCHAR(1) CHECK (weighing_scale_v2 IN ('Y', 'N')),
        weighing_scale_v3 VARCHAR(1) CHECK (weighing_scale_v3 IN ('Y', 'N')),
        weighing_scale_v4 VARCHAR(1) CHECK (weighing_scale_v4 IN ('Y', 'N')),
        
        measuring_tape_v1 VARCHAR(1) CHECK (measuring_tape_v1 IN ('Y', 'N')),
        measuring_tape_v2 VARCHAR(1) CHECK (measuring_tape_v2 IN ('Y', 'N')),
        measuring_tape_v3 VARCHAR(1) CHECK (measuring_tape_v3 IN ('Y', 'N')),
        measuring_tape_v4 VARCHAR(1) CHECK (measuring_tape_v4 IN ('Y', 'N')),
        
        peak_expiratory_flow_meter_v1 VARCHAR(1) CHECK (peak_expiratory_flow_meter_v1 IN ('Y', 'N')),
        peak_expiratory_flow_meter_v2 VARCHAR(1) CHECK (peak_expiratory_flow_meter_v2 IN ('Y', 'N')),
        peak_expiratory_flow_meter_v3 VARCHAR(1) CHECK (peak_expiratory_flow_meter_v3 IN ('Y', 'N')),
        peak_expiratory_flow_meter_v4 VARCHAR(1) CHECK (peak_expiratory_flow_meter_v4 IN ('Y', 'N')),
        
        oxygen_v1 VARCHAR(1) CHECK (oxygen_v1 IN ('Y', 'N')),
        oxygen_v2 VARCHAR(1) CHECK (oxygen_v2 IN ('Y', 'N')),
        oxygen_v3 VARCHAR(1) CHECK (oxygen_v3 IN ('Y', 'N')),
        oxygen_v4 VARCHAR(1) CHECK (oxygen_v4 IN ('Y', 'N')),
        
        oxygen_mask_v1 VARCHAR(1) CHECK (oxygen_mask_v1 IN ('Y', 'N')),
        oxygen_mask_v2 VARCHAR(1) CHECK (oxygen_mask_v2 IN ('Y', 'N')),
        oxygen_mask_v3 VARCHAR(1) CHECK (oxygen_mask_v3 IN ('Y', 'N')),
        oxygen_mask_v4 VARCHAR(1) CHECK (oxygen_mask_v4 IN ('Y', 'N')),
        
        nebulizer_v1 VARCHAR(1) CHECK (nebulizer_v1 IN ('Y', 'N')),
        nebulizer_v2 VARCHAR(1) CHECK (nebulizer_v2 IN ('Y', 'N')),
        nebulizer_v3 VARCHAR(1) CHECK (nebulizer_v3 IN ('Y', 'N')),
        nebulizer_v4 VARCHAR(1) CHECK (nebulizer_v4 IN ('Y', 'N')),
        
        pulse_oximetry_v1 VARCHAR(1) CHECK (pulse_oximetry_v1 IN ('Y', 'N')),
        pulse_oximetry_v2 VARCHAR(1) CHECK (pulse_oximetry_v2 IN ('Y', 'N')),
        pulse_oximetry_v3 VARCHAR(1) CHECK (pulse_oximetry_v3 IN ('Y', 'N')),
        pulse_oximetry_v4 VARCHAR(1) CHECK (pulse_oximetry_v4 IN ('Y', 'N')),
        
        glucometer_v1 VARCHAR(1) CHECK (glucometer_v1 IN ('Y', 'N')),
        glucometer_v2 VARCHAR(1) CHECK (glucometer_v2 IN ('Y', 'N')),
        glucometer_v3 VARCHAR(1) CHECK (glucometer_v3 IN ('Y', 'N')),
        glucometer_v4 VARCHAR(1) CHECK (glucometer_v4 IN ('Y', 'N')),
        
        glucometer_strips_v1 VARCHAR(1) CHECK (glucometer_strips_v1 IN ('Y', 'N')),
        glucometer_strips_v2 VARCHAR(1) CHECK (glucometer_strips_v2 IN ('Y', 'N')),
        glucometer_strips_v3 VARCHAR(1) CHECK (glucometer_strips_v3 IN ('Y', 'N')),
        glucometer_strips_v4 VARCHAR(1) CHECK (glucometer_strips_v4 IN ('Y', 'N')),
        
        lancets_v1 VARCHAR(1) CHECK (lancets_v1 IN ('Y', 'N')),
        lancets_v2 VARCHAR(1) CHECK (lancets_v2 IN ('Y', 'N')),
        lancets_v3 VARCHAR(1) CHECK (lancets_v3 IN ('Y', 'N')),
        lancets_v4 VARCHAR(1) CHECK (lancets_v4 IN ('Y', 'N')),
        
        urine_dipstick_v1 VARCHAR(1) CHECK (urine_dipstick_v1 IN ('Y', 'N')),
        urine_dipstick_v2 VARCHAR(1) CHECK (urine_dipstick_v2 IN ('Y', 'N')),
        urine_dipstick_v3 VARCHAR(1) CHECK (urine_dipstick_v3 IN ('Y', 'N')),
        urine_dipstick_v4 VARCHAR(1) CHECK (urine_dipstick_v4 IN ('Y', 'N')),
        
        ecg_v1 VARCHAR(1) CHECK (ecg_v1 IN ('Y', 'N')),
        ecg_v2 VARCHAR(1) CHECK (ecg_v2 IN ('Y', 'N')),
        ecg_v3 VARCHAR(1) CHECK (ecg_v3 IN ('Y', 'N')),
        ecg_v4 VARCHAR(1) CHECK (ecg_v4 IN ('Y', 'N')),
        
        other_equipment_v1 VARCHAR(1) CHECK (other_equipment_v1 IN ('Y', 'N')),
        other_equipment_v2 VARCHAR(1) CHECK (other_equipment_v2 IN ('Y', 'N')),
        other_equipment_v3 VARCHAR(1) CHECK (other_equipment_v3 IN ('Y', 'N')),
        other_equipment_v4 VARCHAR(1) CHECK (other_equipment_v4 IN ('Y', 'N')),
        
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ Equipment responses table created');

    // -- MHDC NCD Management responses (B6-B10 from PDF page 5)
    await db.query(`
      CREATE TABLE IF NOT EXISTS mhdc_management_responses (
        id SERIAL PRIMARY KEY,
        form_id INTEGER REFERENCES supervision_forms(id) ON DELETE CASCADE,
        
        -- B6: MHDC NCD management leaflets for healthcare workers
        b6_visit_1 VARCHAR(1) CHECK (b6_visit_1 IN ('Y', 'N')),
        b6_visit_2 VARCHAR(1) CHECK (b6_visit_2 IN ('Y', 'N')),
        b6_visit_3 VARCHAR(1) CHECK (b6_visit_3 IN ('Y', 'N')),
        b6_visit_4 VARCHAR(1) CHECK (b6_visit_4 IN ('Y', 'N')),
        b6_comment TEXT,
        
        -- B7: MHDC awareness and patient education materials
        b7_visit_1 VARCHAR(1) CHECK (b7_visit_1 IN ('Y', 'N')),
        b7_visit_2 VARCHAR(1) CHECK (b7_visit_2 IN ('Y', 'N')),
        b7_visit_3 VARCHAR(1) CHECK (b7_visit_3 IN ('Y', 'N')),
        b7_visit_4 VARCHAR(1) CHECK (b7_visit_4 IN ('Y', 'N')),
        b7_comment TEXT,
        
        -- B8: NCD register available and filled properly
        b8_visit_1 VARCHAR(1) CHECK (b8_visit_1 IN ('Y', 'N')),
        b8_visit_2 VARCHAR(1) CHECK (b8_visit_2 IN ('Y', 'N')),
        b8_visit_3 VARCHAR(1) CHECK (b8_visit_3 IN ('Y', 'N')),
        b8_visit_4 VARCHAR(1) CHECK (b8_visit_4 IN ('Y', 'N')),
        b8_comment TEXT,
        
        -- B9: WHO-ISH CVD Risk Prediction Chart available
        b9_visit_1 VARCHAR(1) CHECK (b9_visit_1 IN ('Y', 'N')),
        b9_visit_2 VARCHAR(1) CHECK (b9_visit_2 IN ('Y', 'N')),
        b9_visit_3 VARCHAR(1) CHECK (b9_visit_3 IN ('Y', 'N')),
        b9_visit_4 VARCHAR(1) CHECK (b9_visit_4 IN ('Y', 'N')),
        b9_comment TEXT,
        
        -- B10: WHO-ISH CVD Risk Prediction Chart in use
        b10_visit_1 VARCHAR(1) CHECK (b10_visit_1 IN ('Y', 'N')),
        b10_visit_2 VARCHAR(1) CHECK (b10_visit_2 IN ('Y', 'N')),
        b10_visit_3 VARCHAR(1) CHECK (b10_visit_3 IN ('Y', 'N')),
        b10_visit_4 VARCHAR(1) CHECK (b10_visit_4 IN ('Y', 'N')),
        b10_comment TEXT,
        
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ MHDC management responses table created');

    // -- C. NCD Service Delivery - Staff Training (C1 from PDF page 5)
    await db.query(`
      CREATE TABLE IF NOT EXISTS service_delivery_responses (
        id SERIAL PRIMARY KEY,
        form_id INTEGER REFERENCES supervision_forms(id) ON DELETE CASCADE,
        
        -- C1: Total Number of Health Workers trained on NCDs
        -- Staff categories as per PDF table
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
        
        sr_anm_total_staff INTEGER DEFAULT 0,
        sr_anm_mhdc_trained INTEGER DEFAULT 0,
        sr_anm_fen_trained INTEGER DEFAULT 0,
        sr_anm_other_ncd_trained INTEGER DEFAULT 0,
        
        anm_total_staff INTEGER DEFAULT 0,
        anm_mhdc_trained INTEGER DEFAULT 0,
        anm_fen_trained INTEGER DEFAULT 0,
        anm_other_ncd_trained INTEGER DEFAULT 0,
        
        others_total_staff INTEGER DEFAULT 0,
        others_mhdc_trained INTEGER DEFAULT 0,
        others_fen_trained INTEGER DEFAULT 0,
        others_other_ncd_trained INTEGER DEFAULT 0,
        
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ Service delivery responses table created');

    // -- Service standards responses (C2-C7 from PDF page 6-7)
    await db.query(`
      CREATE TABLE IF NOT EXISTS service_standards_responses (
        id SERIAL PRIMARY KEY,
        form_id INTEGER REFERENCES supervision_forms(id) ON DELETE CASCADE,
        
        -- C2: NCD services provided as per PEN protocol and standards
        c2_blood_pressure_v1 VARCHAR(1) CHECK (c2_blood_pressure_v1 IN ('Y', 'N')),
        c2_blood_pressure_v2 VARCHAR(1) CHECK (c2_blood_pressure_v2 IN ('Y', 'N')),
        c2_blood_pressure_v3 VARCHAR(1) CHECK (c2_blood_pressure_v3 IN ('Y', 'N')),
        c2_blood_pressure_v4 VARCHAR(1) CHECK (c2_blood_pressure_v4 IN ('Y', 'N')),
        
        c2_blood_sugar_v1 VARCHAR(1) CHECK (c2_blood_sugar_v1 IN ('Y', 'N')),
        c2_blood_sugar_v2 VARCHAR(1) CHECK (c2_blood_sugar_v2 IN ('Y', 'N')),
        c2_blood_sugar_v3 VARCHAR(1) CHECK (c2_blood_sugar_v3 IN ('Y', 'N')),
        c2_blood_sugar_v4 VARCHAR(1) CHECK (c2_blood_sugar_v4 IN ('Y', 'N')),
        
        c2_bmi_measurement_v1 VARCHAR(1) CHECK (c2_bmi_measurement_v1 IN ('Y', 'N')),
        c2_bmi_measurement_v2 VARCHAR(1) CHECK (c2_bmi_measurement_v2 IN ('Y', 'N')),
        c2_bmi_measurement_v3 VARCHAR(1) CHECK (c2_bmi_measurement_v3 IN ('Y', 'N')),
        c2_bmi_measurement_v4 VARCHAR(1) CHECK (c2_bmi_measurement_v4 IN ('Y', 'N')),
        
        c2_waist_circumference_v1 VARCHAR(1) CHECK (c2_waist_circumference_v1 IN ('Y', 'N')),
        c2_waist_circumference_v2 VARCHAR(1) CHECK (c2_waist_circumference_v2 IN ('Y', 'N')),
        c2_waist_circumference_v3 VARCHAR(1) CHECK (c2_waist_circumference_v3 IN ('Y', 'N')),
        c2_waist_circumference_v4 VARCHAR(1) CHECK (c2_waist_circumference_v4 IN ('Y', 'N')),
        
        c2_cvd_risk_estimation_v1 VARCHAR(1) CHECK (c2_cvd_risk_estimation_v1 IN ('Y', 'N')),
        c2_cvd_risk_estimation_v2 VARCHAR(1) CHECK (c2_cvd_risk_estimation_v2 IN ('Y', 'N')),
        c2_cvd_risk_estimation_v3 VARCHAR(1) CHECK (c2_cvd_risk_estimation_v3 IN ('Y', 'N')),
        c2_cvd_risk_estimation_v4 VARCHAR(1) CHECK (c2_cvd_risk_estimation_v4 IN ('Y', 'N')),
        
        c2_urine_protein_measurement_v1 VARCHAR(1) CHECK (c2_urine_protein_measurement_v1 IN ('Y', 'N')),
        c2_urine_protein_measurement_v2 VARCHAR(1) CHECK (c2_urine_protein_measurement_v2 IN ('Y', 'N')),
        c2_urine_protein_measurement_v3 VARCHAR(1) CHECK (c2_urine_protein_measurement_v3 IN ('Y', 'N')),
        c2_urine_protein_measurement_v4 VARCHAR(1) CHECK (c2_urine_protein_measurement_v4 IN ('Y', 'N')),
        
        c2_peak_expiratory_flow_rate_v1 VARCHAR(1) CHECK (c2_peak_expiratory_flow_rate_v1 IN ('Y', 'N')),
        c2_peak_expiratory_flow_rate_v2 VARCHAR(1) CHECK (c2_peak_expiratory_flow_rate_v2 IN ('Y', 'N')),
        c2_peak_expiratory_flow_rate_v3 VARCHAR(1) CHECK (c2_peak_expiratory_flow_rate_v3 IN ('Y', 'N')),
        c2_peak_expiratory_flow_rate_v4 VARCHAR(1) CHECK (c2_peak_expiratory_flow_rate_v4 IN ('Y', 'N')),
        
        c2_egfr_calculation_v1 VARCHAR(1) CHECK (c2_egfr_calculation_v1 IN ('Y', 'N')),
        c2_egfr_calculation_v2 VARCHAR(1) CHECK (c2_egfr_calculation_v2 IN ('Y', 'N')),
        c2_egfr_calculation_v3 VARCHAR(1) CHECK (c2_egfr_calculation_v3 IN ('Y', 'N')),
        c2_egfr_calculation_v4 VARCHAR(1) CHECK (c2_egfr_calculation_v4 IN ('Y', 'N')),
        
        c2_brief_intervention_v1 VARCHAR(1) CHECK (c2_brief_intervention_v1 IN ('Y', 'N')),
        c2_brief_intervention_v2 VARCHAR(1) CHECK (c2_brief_intervention_v2 IN ('Y', 'N')),
        c2_brief_intervention_v3 VARCHAR(1) CHECK (c2_brief_intervention_v3 IN ('Y', 'N')),
        c2_brief_intervention_v4 VARCHAR(1) CHECK (c2_brief_intervention_v4 IN ('Y', 'N')),
        
        c2_foot_examination_v1 VARCHAR(1) CHECK (c2_foot_examination_v1 IN ('Y', 'N')),
        c2_foot_examination_v2 VARCHAR(1) CHECK (c2_foot_examination_v2 IN ('Y', 'N')),
        c2_foot_examination_v3 VARCHAR(1) CHECK (c2_foot_examination_v3 IN ('Y', 'N')),
        c2_foot_examination_v4 VARCHAR(1) CHECK (c2_foot_examination_v4 IN ('Y', 'N')),
        
        c2_oral_examination_v1 VARCHAR(1) CHECK (c2_oral_examination_v1 IN ('Y', 'N')),
        c2_oral_examination_v2 VARCHAR(1) CHECK (c2_oral_examination_v2 IN ('Y', 'N')),
        c2_oral_examination_v3 VARCHAR(1) CHECK (c2_oral_examination_v3 IN ('Y', 'N')),
        c2_oral_examination_v4 VARCHAR(1) CHECK (c2_oral_examination_v4 IN ('Y', 'N')),
        
        c2_eye_examination_v1 VARCHAR(1) CHECK (c2_eye_examination_v1 IN ('Y', 'N')),
        c2_eye_examination_v2 VARCHAR(1) CHECK (c2_eye_examination_v2 IN ('Y', 'N')),
        c2_eye_examination_v3 VARCHAR(1) CHECK (c2_eye_examination_v3 IN ('Y', 'N')),
        c2_eye_examination_v4 VARCHAR(1) CHECK (c2_eye_examination_v4 IN ('Y', 'N')),
        
        c2_health_education_v1 VARCHAR(1) CHECK (c2_health_education_v1 IN ('Y', 'N')),
        c2_health_education_v2 VARCHAR(1) CHECK (c2_health_education_v2 IN ('Y', 'N')),
        c2_health_education_v3 VARCHAR(1) CHECK (c2_health_education_v3 IN ('Y', 'N')),
        c2_health_education_v4 VARCHAR(1) CHECK (c2_health_education_v4 IN ('Y', 'N')),
        
        -- C3: Examination room confidentiality
        c3_visit_1 VARCHAR(1) CHECK (c3_visit_1 IN ('Y', 'N')),
        c3_visit_2 VARCHAR(1) CHECK (c3_visit_2 IN ('Y', 'N')),
        c3_visit_3 VARCHAR(1) CHECK (c3_visit_3 IN ('Y', 'N')),
        c3_visit_4 VARCHAR(1) CHECK (c3_visit_4 IN ('Y', 'N')),
        c3_comment TEXT,
        
        -- C4: NCD services for home-bound patients
        c4_visit_1 VARCHAR(1) CHECK (c4_visit_1 IN ('Y', 'N')),
        c4_visit_2 VARCHAR(1) CHECK (c4_visit_2 IN ('Y', 'N')),
        c4_visit_3 VARCHAR(1) CHECK (c4_visit_3 IN ('Y', 'N')),
        c4_visit_4 VARCHAR(1) CHECK (c4_visit_4 IN ('Y', 'N')),
        c4_comment TEXT,
        
        -- C5: Community-based NCD care
        c5_visit_1 VARCHAR(1) CHECK (c5_visit_1 IN ('Y', 'N')),
        c5_visit_2 VARCHAR(1) CHECK (c5_visit_2 IN ('Y', 'N')),
        c5_visit_3 VARCHAR(1) CHECK (c5_visit_3 IN ('Y', 'N')),
        c5_visit_4 VARCHAR(1) CHECK (c5_visit_4 IN ('Y', 'N')),
        c5_comment TEXT,
        
        -- C6: School-based program for NCD prevention
        c6_visit_1 VARCHAR(1) CHECK (c6_visit_1 IN ('Y', 'N')),
        c6_visit_2 VARCHAR(1) CHECK (c6_visit_2 IN ('Y', 'N')),
        c6_visit_3 VARCHAR(1) CHECK (c6_visit_3 IN ('Y', 'N')),
        c6_visit_4 VARCHAR(1) CHECK (c6_visit_4 IN ('Y', 'N')),
        c6_comment TEXT,
        
        -- C7: Patient tracking mechanism
        c7_visit_1 VARCHAR(1) CHECK (c7_visit_1 IN ('Y', 'N')),
        c7_visit_2 VARCHAR(1) CHECK (c7_visit_2 IN ('Y', 'N')),
        c7_visit_3 VARCHAR(1) CHECK (c7_visit_3 IN ('Y', 'N')),
        c7_visit_4 VARCHAR(1) CHECK (c7_visit_4 IN ('Y', 'N')),
        c7_comment TEXT,
        
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ Service standards responses table created');

    // -- D. Health Information responses (D1-D5 from PDF page 7)
    await db.query(`
      CREATE TABLE IF NOT EXISTS health_information_responses (
        id SERIAL PRIMARY KEY,
        form_id INTEGER REFERENCES supervision_forms(id) ON DELETE CASCADE,
        
        -- D1: NCD OPD register regularly updated
        d1_visit_1 VARCHAR(1) CHECK (d1_visit_1 IN ('Y', 'N')),
        d1_visit_2 VARCHAR(1) CHECK (d1_visit_2 IN ('Y', 'N')),
        d1_visit_3 VARCHAR(1) CHECK (d1_visit_3 IN ('Y', 'N')),
        d1_visit_4 VARCHAR(1) CHECK (d1_visit_4 IN ('Y', 'N')),
        d1_comment TEXT,
        
        -- D2: NCD dashboard displayed with updated information
        d2_visit_1 VARCHAR(1) CHECK (d2_visit_1 IN ('Y', 'N')),
        d2_visit_2 VARCHAR(1) CHECK (d2_visit_2 IN ('Y', 'N')),
        d2_visit_3 VARCHAR(1) CHECK (d2_visit_3 IN ('Y', 'N')),
        d2_visit_4 VARCHAR(1) CHECK (d2_visit_4 IN ('Y', 'N')),
        d2_comment TEXT,
        
        -- D3: Monthly Reporting Form sent to concerned authority
        d3_visit_1 VARCHAR(1) CHECK (d3_visit_1 IN ('Y', 'N')),
        d3_visit_2 VARCHAR(1) CHECK (d3_visit_2 IN ('Y', 'N')),
        d3_visit_3 VARCHAR(1) CHECK (d3_visit_3 IN ('Y', 'N')),
        d3_visit_4 VARCHAR(1) CHECK (d3_visit_4 IN ('Y', 'N')),
        d3_comment TEXT,
        
        -- D4: Number of people seeking NCD services in previous month
        d4_visit_1 VARCHAR(1) CHECK (d4_visit_1 IN ('Y', 'N')),
        d4_visit_2 VARCHAR(1) CHECK (d4_visit_2 IN ('Y', 'N')),
        d4_visit_3 VARCHAR(1) CHECK (d4_visit_3 IN ('Y', 'N')),
        d4_visit_4 VARCHAR(1) CHECK (d4_visit_4 IN ('Y', 'N')),
        d4_comment TEXT,
        
        -- D5: Dedicated healthcare worker assigned for NCD service
        d5_visit_1 VARCHAR(1) CHECK (d5_visit_1 IN ('Y', 'N')),
        d5_visit_2 VARCHAR(1) CHECK (d5_visit_2 IN ('Y', 'N')),
        d5_visit_3 VARCHAR(1) CHECK (d5_visit_3 IN ('Y', 'N')),
        d5_visit_4 VARCHAR(1) CHECK (d5_visit_4 IN ('Y', 'N')),
        d5_comment TEXT,
        
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ Health information responses table created');

    // -- E. Integration of NCD services (E1-E3 from PDF page 7)
    await db.query(`
      CREATE TABLE IF NOT EXISTS integration_responses (
        id SERIAL PRIMARY KEY,
        form_id INTEGER REFERENCES supervision_forms(id) ON DELETE CASCADE,
        
        -- E1: Health Workers aware of PEN programme
        e1_visit_1 VARCHAR(1) CHECK (e1_visit_1 IN ('Y', 'N')),
        e1_visit_2 VARCHAR(1) CHECK (e1_visit_2 IN ('Y', 'N')),
        e1_visit_3 VARCHAR(1) CHECK (e1_visit_3 IN ('Y', 'N')),
        e1_visit_4 VARCHAR(1) CHECK (e1_visit_4 IN ('Y', 'N')),
        e1_comment TEXT,
        
        -- E2: Health education on tobacco, alcohol, unhealthy diet, physical activity
        e2_visit_1 VARCHAR(1) CHECK (e2_visit_1 IN ('Y', 'N')),
        e2_visit_2 VARCHAR(1) CHECK (e2_visit_2 IN ('Y', 'N')),
        e2_visit_3 VARCHAR(1) CHECK (e2_visit_3 IN ('Y', 'N')),
        e2_visit_4 VARCHAR(1) CHECK (e2_visit_4 IN ('Y', 'N')),
        e2_comment TEXT,
        
        -- E3: Screening for raised blood pressure and blood sugar
        e3_visit_1 VARCHAR(1) CHECK (e3_visit_1 IN ('Y', 'N')),
        e3_visit_2 VARCHAR(1) CHECK (e3_visit_2 IN ('Y', 'N')),
        e3_visit_3 VARCHAR(1) CHECK (e3_visit_3 IN ('Y', 'N')),
        e3_visit_4 VARCHAR(1) CHECK (e3_visit_4 IN ('Y', 'N')),
        e3_comment TEXT,
        
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ Integration responses table created');

    // -- F. Overall observations and summary (from PDF page 8)
    await db.query(`
      CREATE TABLE IF NOT EXISTS overall_observations_responses (
        id SERIAL PRIMARY KEY,
        form_id INTEGER REFERENCES supervision_forms(id) ON DELETE CASCADE,
        
        -- F1: Summary of recommendations between supervisor and supervisee
        recommendations_visit_1 TEXT,
        recommendations_visit_2 TEXT,
        recommendations_visit_3 TEXT,
        recommendations_visit_4 TEXT,
        
        -- Signatures (as per PDF page 8)
        supervisor_signature_v1 TEXT,
        supervisor_signature_v2 TEXT,
        supervisor_signature_v3 TEXT,
        supervisor_signature_v4 TEXT,
        
        facility_representative_signature_v1 TEXT,
        facility_representative_signature_v2 TEXT,
        facility_representative_signature_v3 TEXT,
        facility_representative_signature_v4 TEXT,
        
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ Overall observations responses table created');

    // -- Sync logs table
    await db.query(`
      CREATE TABLE IF NOT EXISTS sync_logs (
        id SERIAL PRIMARY KEY,
        user_id INTEGER REFERENCES users(id),
        form_id INTEGER REFERENCES supervision_forms(id),
        sync_type VARCHAR(20),
        sync_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        device_id VARCHAR(100),
        sync_status VARCHAR(20) DEFAULT 'completed',
        error_message TEXT,
        ip_address INET,
        user_agent TEXT
      )
    `);
    console.log('✅ Sync logs table created');

    // -- Create indexes for better performance
    await db.query(`
      CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
      CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
      CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
      CREATE INDEX IF NOT EXISTS idx_users_is_active ON users(is_active);
      
      CREATE INDEX IF NOT EXISTS idx_supervision_forms_user_id ON supervision_forms(user_id);
      CREATE INDEX IF NOT EXISTS idx_supervision_forms_sync_status ON supervision_forms(sync_status);
      CREATE INDEX IF NOT EXISTS idx_supervision_forms_created_at ON supervision_forms(form_created_at);
      CREATE INDEX IF NOT EXISTS idx_supervision_forms_facility ON supervision_forms(health_facility_name);
      CREATE INDEX IF NOT EXISTS idx_supervision_forms_province ON supervision_forms(province);
      CREATE INDEX IF NOT EXISTS idx_supervision_forms_district ON supervision_forms(district);
      
      CREATE INDEX IF NOT EXISTS idx_admin_management_form_id ON admin_management_responses(form_id);
      CREATE INDEX IF NOT EXISTS idx_logistics_form_id ON logistics_responses(form_id);
      CREATE INDEX IF NOT EXISTS idx_equipment_form_id ON equipment_responses(form_id);
      CREATE INDEX IF NOT EXISTS idx_mhdc_management_form_id ON mhdc_management_responses(form_id);
      CREATE INDEX IF NOT EXISTS idx_service_delivery_form_id ON service_delivery_responses(form_id);
      CREATE INDEX IF NOT EXISTS idx_service_standards_form_id ON service_standards_responses(form_id);
      CREATE INDEX IF NOT EXISTS idx_health_information_form_id ON health_information_responses(form_id);
      CREATE INDEX IF NOT EXISTS idx_integration_form_id ON integration_responses(form_id);
      CREATE INDEX IF NOT EXISTS idx_overall_observations_form_id ON overall_observations_responses(form_id);
      
      CREATE INDEX IF NOT EXISTS idx_sync_logs_user_id ON sync_logs(user_id);
      CREATE INDEX IF NOT EXISTS idx_sync_logs_form_id ON sync_logs(form_id);
      CREATE INDEX IF NOT EXISTS idx_sync_logs_timestamp ON sync_logs(sync_timestamp);
      CREATE INDEX IF NOT EXISTS idx_sync_logs_sync_status ON sync_logs(sync_status);
    `);
    console.log('✅ Database indexes created');

    console.log('🎉 All tables created successfully!');

  } catch (error) {
    console.error('❌ Error creating tables:', error);
    throw error;
  }
}

async function createDefaultAdmin() {
  console.log('🔄 Creating default admin user...');

  try {
    // Check if admin user already exists
    const existingAdminQuery = `
      SELECT id FROM users WHERE role = 'admin' LIMIT 1
    `;
    const existingAdmin = await db.query(existingAdminQuery);

    if (existingAdmin.rows.length > 0) {
      console.log('ℹ️  Admin user already exists, skipping creation');
      return;
    }

    // Create default admin
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

    const newAdmin = result.rows[0];

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
    // Drop tables in reverse order due to foreign key constraints
    const tables = [
      'sync_logs',
      'overall_observations_responses',
      'integration_responses',
      'health_information_responses',
      'service_standards_responses',
      'service_delivery_responses',
      'mhdc_management_responses',
      'equipment_responses',
      'logistics_responses',
      'admin_management_responses',
      'supervision_forms',
      'users'
    ];

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
  console.log('🎉 Database reset completed!');
}

async function createSampleData() {
  console.log('🔄 Creating sample supervision form data...');

  try {
    // Get admin user ID
    const adminResult = await db.query("SELECT id FROM users WHERE username = 'admin'");
    if (adminResult.rows.length === 0) {
      throw new Error('Admin user not found. Run migration first.');
    }
    const adminId = adminResult.rows[0].id;

    // Create sample form
    const formQuery = `
      INSERT INTO supervision_forms (
        user_id, health_facility_name, province, district,
        visit_1_date, visit_2_date, form_created_at, sync_status
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
      RETURNING id
    `;

    const formResult = await db.query(formQuery, [
      adminId,
      'Central Health Post',
      'Bagmati Province',
      'Kathmandu',
      '2025-01-01',
      '2025-01-15',
      new Date(),
      'local'
    ]);

    const formId = formResult.rows[0].id;

    // Add sample admin management responses
    await db.query(`
      INSERT INTO admin_management_responses (
        form_id, a1_visit_1, a1_visit_2, a1_comment,
        a2_visit_1, a2_visit_2, a2_comment,
        a3_visit_1, a3_visit_2, a3_comment
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
    `, [
      formId, 'Y', 'Y', 'Committee functioning well',
      'Y', 'N', 'Need to improve NCD discussion frequency',
      'Y', 'Y', 'Regular quarterly discussions happening'
    ]);

    // Add sample overall observations
    await db.query(`
      INSERT INTO overall_observations_responses (
        form_id, recommendations_visit_1, recommendations_visit_2
      ) VALUES ($1, $2, $3)
    `, [
      formId, 
      'Improve medicine availability and staff training',
      'Update equipment inventory and maintain regular register updates'
    ]);

    console.log('✅ Sample supervision form data created');

  } catch (error) {
    console.error('❌ Error creating sample data:', error);
    throw error;
  }
}

async function main() {
  const command = process.argv[2];

  try {
    // Test database connection
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
        console.log('  npm run migrate sample  - Create sample supervision form data');
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

// Run migration if this file is executed directly
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