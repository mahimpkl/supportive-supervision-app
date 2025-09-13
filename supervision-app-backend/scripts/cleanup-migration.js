require('dotenv').config();
const db = require('../config/database');

async function cleanupUnnecessaryTables() {
  console.log('🔄 Comprehensive cleanup: Removing unnecessary tables, units columns, and updating MHDC to KHDC...');

  try {
    // Drop the view first to avoid dependency issues
    await db.query(`DROP VIEW IF EXISTS complete_supervision_data CASCADE`);
    console.log('✅ Dropped view: complete_supervision_data');

    // Drop unnecessary tables that don't exist in PDF requirements
    const tablesToDrop = [
      'visit_medicine_details',
      'visit_patient_volumes', 
      'form_facility_infrastructure',
      'visit_equipment_functionality',
      'visit_quality_assurance'
    ];

    for (const table of tablesToDrop) {
      await db.query(`DROP TABLE IF EXISTS ${table} CASCADE`);
      console.log(`✅ Dropped unnecessary table: ${table}`);
    }

    // Remove unnecessary fields from visit_logistics_responses
    await db.query(`
      ALTER TABLE visit_logistics_responses 
      DROP COLUMN IF EXISTS medicine_quantities
    `);
    console.log('✅ Removed medicine_quantities JSONB field from logistics');

    // Remove all _units columns from logistics responses table
    const unitsColumns = [
      'amlodipine_5_10mg_units', 'enalapril_2_5_10mg_units', 'losartan_25_50mg_units',
      'hydrochlorothiazide_12_5_25mg_units', 'chlorthalidone_6_25_12_5mg_units', 
      'other_antihypertensives_units', 'atorvastatin_5mg_units', 'atorvastatin_10mg_units',
      'atorvastatin_20mg_units', 'other_statins_units', 'metformin_500mg_units',
      'metformin_1000mg_units', 'glimepiride_1_2mg_units', 'gliclazide_40_80mg_units',
      'glipizide_2_5_5mg_units', 'sitagliptin_50mg_units', 'pioglitazone_5mg_units',
      'empagliflozin_10mg_units', 'insulin_soluble_inj_units', 'insulin_nph_inj_units',
      'other_hypoglycemic_agents_units', 'dextrose_25_solution_units', 'aspirin_75mg_units',
      'clopidogrel_75mg_units', 'metoprolol_succinate_12_5_25_50mg_units', 
      'isosorbide_dinitrate_5mg_units', 'other_drugs_units', 'amoxicillin_clavulanic_potassium_625mg_units',
      'azithromycin_500mg_units', 'other_antibiotics_units', 'salbutamol_dpi_units',
      'salbutamol_units', 'ipratropium_units', 'tiotropium_bromide_units', 'formoterol_units',
      'other_bronchodilators_units', 'prednisolone_5_10_20mg_units', 'other_steroids_oral_units'
    ];

    for (const column of unitsColumns) {
      await db.query(`
        ALTER TABLE visit_logistics_responses 
        DROP COLUMN IF EXISTS ${column}
      `);
      console.log(`✅ Removed ${column} from logistics table`);
    }

    // Remove _units columns from equipment responses table
    const equipmentUnitsColumns = [
      'sphygmomanometer_units', 'weighing_scale_units', 'measuring_tape_units',
      'peak_expiratory_flow_meter_units', 'oxygen_units', 'oxygen_mask_units',
      'nebulizer_units', 'pulse_oximetry_units', 'glucometer_units', 'glucometer_strips_units',
      'lancets_units', 'urine_dipstick_units', 'ecg_units', 'other_equipment_units'
    ];

    for (const column of equipmentUnitsColumns) {
      await db.query(`
        ALTER TABLE visit_equipment_responses 
        DROP COLUMN IF EXISTS ${column}
      `);
      console.log(`✅ Removed ${column} from equipment table`);
    }

    // Remove unnecessary fields from form_staff_training
    const fieldsToRemove = [
      'last_mhdc_training_date',
      'last_fen_training_date', 
      'last_other_training_date',
      'training_provider',
      'training_certificates_verified'
    ];

    for (const field of fieldsToRemove) {
      await db.query(`
        ALTER TABLE form_staff_training 
        DROP COLUMN IF EXISTS ${field}
      `);
      console.log(`✅ Removed ${field} from staff training table`);
    }

    // RENAME MHDC TO KHDC - Table and column updates
    console.log('🔄 Converting all MHDC references to KHDC...');

    // Rename the MHDC table to KHDC
    await db.query(`
      ALTER TABLE visit_mhdc_management_responses 
      RENAME TO visit_khdc_management_responses
    `);
    console.log('✅ Renamed visit_mhdc_management_responses to visit_khdc_management_responses');

    // Update staff training column names from MHDC to KHDC
    const mhdcToKhdcColumns = [
      'ha_mhdc_trained',
      'sr_ahw_mhdc_trained', 
      'ahw_mhdc_trained',
      'sr_anm_mhdc_trained',
      'anm_mhdc_trained',
      'others_mhdc_trained'
    ];

    for (const column of mhdcToKhdcColumns) {
      const newColumn = column.replace('mhdc', 'khdc');
      await db.query(`
        ALTER TABLE form_staff_training 
        RENAME COLUMN ${column} TO ${newColumn}
      `);
      console.log(`✅ Renamed ${column} to ${newColumn}`);
    }

    // Recreate the simplified view without unnecessary tables and with KHDC updates
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
        
        -- JSON aggregated section data (only PDF-compliant sections)
        row_to_json(vam.*) as admin_management,
        row_to_json(vl.*) as logistics,
        row_to_json(ve.*) as equipment,
        row_to_json(vkhdc.*) as khdc_management,
        row_to_json(vss.*) as service_standards,
        row_to_json(vhi.*) as health_information,
        row_to_json(vi.*) as integration,
        
        -- Form-level data (simplified)
        (SELECT row_to_json(fst) FROM form_staff_training fst WHERE fst.form_id = sf.id) as staff_training,
        
        sv.created_at as visit_created_at,
        sv.updated_at as visit_updated_at
        
      FROM supervision_forms sf
      JOIN users u ON sf.user_id = u.id
      LEFT JOIN supervision_visits sv ON sf.id = sv.form_id
      LEFT JOIN visit_admin_management_responses vam ON sv.id = vam.visit_id
      LEFT JOIN visit_logistics_responses vl ON sv.id = vl.visit_id
      LEFT JOIN visit_equipment_responses ve ON sv.id = ve.visit_id
      LEFT JOIN visit_khdc_management_responses vkhdc ON sv.id = vkhdc.visit_id
      LEFT JOIN visit_service_standards_responses vss ON sv.id = vss.visit_id
      LEFT JOIN visit_health_information_responses vhi ON sv.id = vhi.visit_id
      LEFT JOIN visit_integration_responses vi ON sv.id = vi.visit_id
      ORDER BY sf.id, sv.visit_number
    `);
    console.log('✅ Recreated simplified complete_supervision_data view with KHDC references');

    // Remove indexes for dropped tables
    const indexesToDrop = [
      'idx_visit_medicine_details_visit_id',
      'idx_visit_medicine_details_medicine',
      'idx_visit_medicine_details_category',
      'idx_visit_medicine_details_expiry',
      'idx_visit_medicine_details_availability',
      'idx_visit_patient_volumes_visit_id',
      'idx_visit_patient_volumes_month',
      'idx_visit_equipment_functionality_visit_id',
      'idx_visit_equipment_functionality_name',
      'idx_visit_equipment_functionality_status',
      'idx_visit_quality_assurance_visit_id',
      'idx_form_facility_infrastructure_form_id',
      'idx_visit_mhdc_visit_id'
    ];

    for (const index of indexesToDrop) {
      await db.query(`DROP INDEX IF EXISTS ${index}`);
      console.log(`✅ Dropped index: ${index}`);
    }

    // Create new index for KHDC table
    await db.query(`
      CREATE INDEX IF NOT EXISTS idx_visit_khdc_visit_id ON visit_khdc_management_responses(visit_id)
    `);
    console.log('✅ Created index for KHDC management responses');

    // Update table comments to reflect simplified structure and KHDC naming
    await db.query(`
      COMMENT ON TABLE supervision_forms IS 'Main facility-level supervision forms with basic facility information';
      COMMENT ON TABLE supervision_visits IS 'Individual visits (1-4) per form with visit-specific data and overall actions agreed';
      
      COMMENT ON TABLE visit_admin_management_responses IS 'Administration and Management section responses per visit (A1-A3)';
      COMMENT ON TABLE visit_logistics_responses IS 'Complete medicine and logistics tracking per visit (B1-B5) - simplified for PDF compliance, no units tracking';
      COMMENT ON TABLE visit_equipment_responses IS 'Equipment availability and functionality per visit with quantities only (B5 from PDF)';
      COMMENT ON TABLE visit_khdc_management_responses IS 'KHDC NCD management materials and tools tracking (B6-B10)';
      COMMENT ON TABLE visit_service_standards_responses IS 'Service standards including all C2 sub-services (C2-C7)';
      COMMENT ON TABLE visit_health_information_responses IS 'Health information systems and reporting (D1-D5)';
      COMMENT ON TABLE visit_integration_responses IS 'Integration of NCD services (E1-E3)';
      
      COMMENT ON TABLE form_staff_training IS 'Staff training matrix (C1) - one record per form covering all staff categories - simplified, KHDC naming';
      
      COMMENT ON COLUMN supervision_visits.actions_agreed IS 'Overall visit-level actions agreed between supervisor and supervisee';
      COMMENT ON COLUMN supervision_visits.recommendations IS 'General recommendations from supervisor for this visit';
    `);
    console.log('✅ Updated table documentation for simplified structure with KHDC naming');

    console.log('🎉 Comprehensive database cleanup completed successfully!');
    console.log('📋 Changes made:');
    console.log('   ✅ Removed 5 unnecessary tables (medicine_details, patient_volumes, etc.)');
    console.log('   ✅ Removed all _units columns from logistics and equipment tables');
    console.log('   ✅ Removed training date/provider fields from staff training');
    console.log('   ✅ Renamed MHDC table and columns to KHDC throughout database');
    console.log('   ✅ Updated view to reference KHDC instead of MHDC');
    console.log('   ✅ Recreated indexes for optimized structure');
    console.log('');
    console.log('✅ Database now fully aligned with PDF requirements and uses KHDC naming');

  } catch (error) {
    console.error('❌ Error during cleanup:', error);
    throw error;
  }
}

async function verifyCleanup() {
  console.log('🔄 Verifying comprehensive cleanup...');

  try {
    // Check which tables still exist
    const tablesQuery = `
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public' 
      AND table_type = 'BASE TABLE'
      ORDER BY table_name
    `;

    const result = await db.query(tablesQuery);
    
    console.log('📋 Remaining tables:');
    result.rows.forEach(row => {
      console.log(`   - ${row.table_name}`);
    });

    // Check if KHDC table exists and MHDC is gone
    const khdcCheck = result.rows.find(row => row.table_name === 'visit_khdc_management_responses');
    const mhdcCheck = result.rows.find(row => row.table_name === 'visit_mhdc_management_responses');
    
    if (khdcCheck && !mhdcCheck) {
      console.log('✅ MHDC successfully renamed to KHDC');
    } else {
      console.log('❌ MHDC to KHDC rename may have failed');
    }

    // Check staff training column names
    const staffColumnsQuery = `
      SELECT column_name 
      FROM information_schema.columns 
      WHERE table_name = 'form_staff_training' 
      AND column_name LIKE '%khdc%'
    `;
    
    const staffResult = await db.query(staffColumnsQuery);
    console.log('📋 KHDC training columns found:');
    staffResult.rows.forEach(row => {
      console.log(`   - ${row.column_name}`);
    });

    // Check if view was recreated
    const viewQuery = `
      SELECT table_name 
      FROM information_schema.views 
      WHERE table_schema = 'public'
    `;

    const viewResult = await db.query(viewQuery);
    console.log('📋 Available views:');
    viewResult.rows.forEach(row => {
      console.log(`   - ${row.table_name}`);
    });

    console.log('✅ Verification completed');

  } catch (error) {
    console.error('❌ Error during verification:', error);
    throw error;
  }
}

async function createSampleDataForCleanedDB() {
  console.log('🔄 Creating sample data for cleaned database with KHDC naming...');

  try {
    const adminResult = await db.query("SELECT id FROM users WHERE username = 'admin'");
    if (adminResult.rows.length === 0) {
      throw new Error('Admin user not found. Run main migration first.');
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
      'Sample Health Post',
      'Bagmati Province',
      'Kathmandu',
      'local'
    ]);

    const formId = formResult.rows[0].id;

    // Create sample visit
    const visitQuery = `
      INSERT INTO supervision_visits (
        form_id, visit_number, visit_date, recommendations, actions_agreed, sync_status
      ) VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING id
    `;

    const visitResult = await db.query(visitQuery, [
      formId, 1, '2025-01-15', 
      'Improve medicine stock levels and enhance staff training',
      'Order missing medicines by month-end. Conduct staff refresher training.',
      'local'
    ]);

    const visitId = visitResult.rows[0].id;

    // Add sample data for all remaining sections
    
    // Admin management
    await db.query(`
      INSERT INTO visit_admin_management_responses (
        visit_id, a1_response, a1_comment, a2_response, a2_comment,
        a3_response, a3_comment, actions_agreed
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
    `, [
      visitId, 'Y', 'Committee functioning well', 'N', 'Need more frequent NCD discussions',
      'Y', 'Regular quarterly meetings', 'Include monthly NCD agenda items'
    ]);

    // Logistics with medicine availability (no units)
    await db.query(`
      INSERT INTO visit_logistics_responses (
        visit_id, b1_response, b1_comment,
        amlodipine_5_10mg, amlodipine_5_10mg_quantity,
        metformin_500mg, metformin_500mg_quantity,
        b2_response, b2_comment, b3_response, b3_comment,
        actions_agreed
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
    `, [
      visitId, 'Y', 'Good medicine availability overall',
      'Y', 100, 'N', 0,
      'Y', 'Glucometer working well', 'Y', 'Urine strips available',
      'Restock metformin 500mg urgently'
    ]);

    // Equipment (no units)
    await db.query(`
      INSERT INTO visit_equipment_responses (
        visit_id, sphygmomanometer, sphygmomanometer_quantity,
        weighing_scale, weighing_scale_quantity,
        glucometer, glucometer_quantity,
        actions_agreed
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
    `, [
      visitId, 'Y', 2, 'Y', 1, 'Y', 1,
      'All essential equipment available and functional'
    ]);

    // KHDC management (updated from MHDC)
    await db.query(`
      INSERT INTO visit_khdc_management_responses (
        visit_id, b6_response, b6_comment, b7_response, b7_comment,
        b8_response, b8_comment, b9_response, b9_comment,
        b10_response, b10_comment, actions_agreed
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
    `, [
      visitId, 'Y', 'Leaflets available', 'Y', 'Educational materials present',
      'Y', 'Register properly maintained', 'Y', 'WHO-ISH charts available',
      'N', 'Charts not used consistently', 'Train staff on WHO-ISH chart usage'
    ]);

    // Service standards
    await db.query(`
      INSERT INTO visit_service_standards_responses (
        visit_id, c2_main_response, c2_main_comment,
        c2_blood_pressure, c2_blood_sugar, c2_bmi_measurement,
        c3_response, c3_comment, c4_response, c4_comment,
        actions_agreed
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
    `, [
      visitId, 'Y', 'Most protocols followed',
      'Y', 'Y', 'Y',
      'Y', 'Privacy maintained', 'N', 'Home visits not started',
      'Implement home visit protocols'
    ]);

    // Health information
    await db.query(`
      INSERT INTO visit_health_information_responses (
        visit_id, d1_response, d1_comment, d2_response, d2_comment,
        d3_response, d3_comment, d4_response, d4_comment, d4_number_of_people,
        actions_agreed
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
    `, [
      visitId, 'Y', 'Register updated regularly', 'Y', 'Dashboard current',
      'Y', 'Reports submitted timely', 'Y', 'Good patient tracking', 42,
      'Continue current data management practices'
    ]);

    // Integration
    await db.query(`
      INSERT INTO visit_integration_responses (
        visit_id, e1_response, e1_comment, e2_response, e2_comment,
        e3_response, e3_comment, actions_agreed
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
    `, [
      visitId, 'Y', 'Staff aware of PEN programme', 'Y', 'Health education provided',
      'Y', 'Screening conducted regularly', 'Maintain current integration practices'
    ]);

    // Simplified staff training with KHDC naming
    await db.query(`
      INSERT INTO form_staff_training (
        form_id, ha_total_staff, ha_khdc_trained, ha_fen_trained,
        sr_ahw_total_staff, sr_ahw_khdc_trained, sr_ahw_fen_trained,
        ahw_total_staff, ahw_khdc_trained, ahw_fen_trained,
        anm_total_staff, anm_khdc_trained, anm_fen_trained
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
    `, [formId, 3, 2, 2, 2, 1, 1, 4, 3, 2, 3, 2, 2]);

    console.log('✅ Sample data created for cleaned database with KHDC naming');

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
      case 'cleanup':
        await cleanupUnnecessaryTables();
        break;
      case 'verify':
        await verifyCleanup();
        break;
      case 'sample':
        await createSampleDataForCleanedDB();
        break;
      case 'full':
        await cleanupUnnecessaryTables();
        await verifyCleanup();
        await createSampleDataForCleanedDB();
        break;
      default:
        console.log('📋 Comprehensive database cleanup commands:');
        console.log('  node cleanup-migration.js cleanup  - Remove unnecessary tables/fields and convert MHDC to KHDC');
        console.log('  node cleanup-migration.js verify   - Verify cleanup and KHDC conversion was successful');
        console.log('  node cleanup-migration.js sample   - Create sample data for cleaned DB with KHDC');
        console.log('  node cleanup-migration.js full     - Run cleanup, verify, and create sample data');
        console.log('');
        console.log('📋 Changes included:');
        console.log('  - Remove unnecessary tables (medicine_details, patient_volumes, etc.)');
        console.log('  - Remove all _units columns from logistics and equipment');
        console.log('  - Convert all MHDC references to KHDC in database');
        console.log('  - Update view and indexes accordingly');
        process.exit(0);
    }

  } catch (error) {
    console.error('❌ Cleanup failed:', error.message);
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
  cleanupUnnecessaryTables,
  verifyCleanup,
  createSampleDataForCleanedDB
};