const axios = require('axios');

const BASE_URL = 'http://localhost:3000/api';
let adminToken = '';

async function simpleTest() {
  try {
    console.log('🔍 Simple test with minimal data...');
    
    // Step 1: Login as admin
    console.log('1️⃣ Logging in as admin...');
    const loginResponse = await axios.post(`${BASE_URL}/auth/login`, {
      username: 'admin',
      password: 'Admin123!'
    });
    
    adminToken = loginResponse.data.accessToken;
    console.log('✅ Admin login successful');

    // Step 2: Create a simple form with minimal data
    console.log('2️⃣ Creating simple form...');
    
    const simpleForm = {
      healthFacilityName: 'Simple Test Facility',
      province: 'Test Province',
      district: 'Test District',
      visit1Date: '2024-01-15',
      visit2Date: '2024-02-15',
      recommendationsVisit1: 'Simple test recommendation',
      recommendationsVisit2: 'Simple test recommendation 2',
      supervisorSignature: 'Dr. Test',
      facilityRepresentativeSignature: 'Dr. Test Rep',
      adminManagement: {
        a1_visit_1: 'Y', a1_visit_2: 'Y',
        a2_visit_1: 'Y', a2_visit_2: 'Y',
        a3_visit_1: 'Y', a3_visit_2: 'Y',
        a1_comment: 'Simple test comment',
        a2_comment: 'Simple test comment',
        a3_comment: 'Simple test comment'
      },
      logistics: {
        b1_visit_1: 'Y', b1_visit_2: 'Y',
        b2_visit_1: 'Y', b2_visit_2: 'Y',
        b3_visit_1: 'Y', b3_visit_2: 'Y',
        b4_visit_1: 'Y', b4_visit_2: 'Y',
        b5_visit_1: 'Y', b5_visit_2: 'Y',
        amlodipine_5_10mg_v1: 'Y', amlodipine_5_10mg_v2: 'Y',
        enalapril_2_5_10mg_v1: 'Y', enalapril_2_5_10mg_v2: 'Y',
        losartan_25_50mg_v1: 'Y', losartan_25_50mg_v2: 'Y',
        hydrochlorothiazide_12_5_25mg_v1: 'Y', hydrochlorothiazide_12_5_25mg_v2: 'Y',
        chlorthalidone_6_25_12_5mg_v1: 'Y', chlorthalidone_6_25_12_5mg_v2: 'Y',
        atorvastatin_5mg_v1: 'Y', atorvastatin_5mg_v2: 'Y',
        atorvastatin_10mg_v1: 'Y', atorvastatin_10mg_v2: 'Y',
        atorvastatin_20mg_v1: 'Y', atorvastatin_20mg_v2: 'Y',
        other_statins_v1: 'Y', other_statins_v2: 'Y',
        metformin_500mg_v1: 'Y', metformin_500mg_v2: 'Y',
        metformin_1000mg_v1: 'Y', metformin_1000mg_v2: 'Y',
        glimepiride_1_2mg_v1: 'Y', glimepiride_1_2mg_v2: 'Y',
        gliclazide_40_80mg_v1: 'Y', gliclazide_40_80mg_v2: 'Y',
        glipizide_2_5_5mg_v1: 'Y', glipizide_2_5_5mg_v2: 'Y',
        sitagliptin_50mg_v1: 'Y', sitagliptin_50mg_v2: 'Y',
        pioglitazone_5mg_v1: 'Y', pioglitazone_5mg_v2: 'Y',
        empagliflozin_10mg_v1: 'Y', empagliflozin_10mg_v2: 'Y',
        insulin_soluble_v1: 'Y', insulin_soluble_v2: 'Y',
        insulin_nph_v1: 'Y', insulin_nph_v2: 'Y',
        other_hypoglycemic_agents_v1: 'Y', other_hypoglycemic_agents_v2: 'Y',
        dextrose_25_solution_v1: 'Y', dextrose_25_solution_v2: 'Y',
        aspirin_75mg_v1: 'Y', aspirin_75mg_v2: 'Y',
        clopidogrel_75mg_v1: 'Y', clopidogrel_75mg_v2: 'Y',
        metoprolol_succinate_12_5_25_50mg_v1: 'Y', metoprolol_succinate_12_5_25_50mg_v2: 'Y',
        isosorbide_dinitrate_5mg_v1: 'Y', isosorbide_dinitrate_5mg_v2: 'Y',
        other_drugs_v1: 'Y', other_drugs_v2: 'Y',
        b1_comment: 'Simple test comment',
        b2_comment: 'Simple test comment',
        b3_comment: 'Simple test comment',
        b4_comment: 'Simple test comment',
        b5_comment: 'Simple test comment'
      },
      equipment: {
        sphygmomanometer_v1: 'Y', sphygmomanometer_v2: 'Y',
        weighing_scale_v1: 'Y', weighing_scale_v2: 'Y',
        measuring_tape_v1: 'Y', measuring_tape_v2: 'Y',
        peak_expiratory_flow_meter_v1: 'Y', peak_expiratory_flow_meter_v2: 'Y',
        oxygen_v1: 'Y', oxygen_v2: 'Y',
        oxygen_mask_v1: 'Y', oxygen_mask_v2: 'Y',
        nebulizer_v1: 'Y', nebulizer_v2: 'Y',
        pulse_oximetry_v1: 'Y', pulse_oximetry_v2: 'Y',
        glucometer_v1: 'Y', glucometer_v2: 'Y',
        glucometer_strips_v1: 'Y', glucometer_strips_v2: 'Y',
        lancets_v1: 'Y', lancets_v2: 'Y',
        urine_dipstick_v1: 'Y', urine_dipstick_v2: 'Y',
        ecg_v1: 'Y', ecg_v2: 'Y',
        other_equipment_v1: 'Y', other_equipment_v2: 'Y',
        b2_comment: 'Simple test comment'
      },
      mhdcManagement: {
        b6_visit_1: 'Y', b6_visit_2: 'Y',
        b7_visit_1: 'Y', b7_visit_2: 'Y',
        b8_visit_1: 'Y', b8_visit_2: 'Y',
        b9_visit_1: 'Y', b9_visit_2: 'Y',
        b10_visit_1: 'Y', b10_visit_2: 'Y',
        b6_comment: 'Simple test comment',
        b7_comment: 'Simple test comment',
        b8_comment: 'Simple test comment',
        b9_comment: 'Simple test comment',
        b10_comment: 'Simple test comment'
      },
      serviceDelivery: {
        ha_total_staff: 5, ha_mhdc_trained: 3, ha_fen_trained: 2, ha_other_ncd_trained: 1,
        sr_ahw_total_staff: 4, sr_ahw_mhdc_trained: 2, sr_ahw_fen_trained: 1, sr_ahw_other_ncd_trained: 1,
        ahw_total_staff: 3, ahw_mhdc_trained: 2, ahw_fen_trained: 1, ahw_other_ncd_trained: 1,
        sr_anm_total_staff: 2, sr_anm_mhdc_trained: 1, sr_anm_fen_trained: 1, sr_anm_other_ncd_trained: 1,
        anm_total_staff: 2, anm_mhdc_trained: 1, anm_fen_trained: 1, anm_other_ncd_trained: 1,
        others_total_staff: 1, others_mhdc_trained: 1, others_fen_trained: 1, others_other_ncd_trained: 1
      },
      serviceStandards: {
        c2_blood_pressure_v1: 'Y', c2_blood_pressure_v2: 'Y',
        c2_blood_sugar_v1: 'Y', c2_blood_sugar_v2: 'Y',
        c2_bmi_measurement_v1: 'Y', c2_bmi_measurement_v2: 'Y',
        c2_waist_circumference_v1: 'Y', c2_waist_circumference_v2: 'Y',
        c2_cvd_risk_estimation_v1: 'Y', c2_cvd_risk_estimation_v2: 'Y',
        c2_urine_protein_measurement_v1: 'Y', c2_urine_protein_measurement_v2: 'Y',
        c2_peak_expiratory_flow_rate_v1: 'Y', c2_peak_expiratory_flow_rate_v2: 'Y',
        c2_egfr_calculation_v1: 'Y', c2_egfr_calculation_v2: 'Y',
        c2_brief_intervention_v1: 'Y', c2_brief_intervention_v2: 'Y',
        c2_foot_examination_v1: 'Y', c2_foot_examination_v2: 'Y',
        c2_oral_examination_v1: 'Y', c2_oral_examination_v2: 'Y',
        c2_eye_examination_v1: 'Y', c2_eye_examination_v2: 'Y',
        c2_health_education_v1: 'Y', c2_health_education_v2: 'Y',
        c3_visit_1: 'Y', c3_visit_2: 'Y',
        c4_visit_1: 'Y', c4_visit_2: 'Y',
        c5_visit_1: 'Y', c5_visit_2: 'Y',
        c6_visit_1: 'Y', c6_visit_2: 'Y',
        c7_visit_1: 'Y', c7_visit_2: 'Y',
        c3_comment: 'Simple test comment',
        c4_comment: 'Simple test comment',
        c5_comment: 'Simple test comment',
        c6_comment: 'Simple test comment',
        c7_comment: 'Simple test comment'
      },
      healthInformation: {
        d1_visit_1: 'Y', d1_visit_2: 'Y',
        d2_visit_1: 'Y', d2_visit_2: 'Y',
        d3_visit_1: 'Y', d3_visit_2: 'Y',
        d4_visit_1: 'Y', d4_visit_2: 'Y',
        d5_visit_1: 'Y', d5_visit_2: 'Y',
        d1_comment: 'Simple test comment',
        d2_comment: 'Simple test comment',
        d3_comment: 'Simple test comment',
        d4_comment: 'Simple test comment',
        d5_comment: 'Simple test comment'
      },
      integration: {
        e1_visit_1: 'Y', e1_visit_2: 'Y',
        e2_visit_1: 'Y', e2_visit_2: 'Y',
        e3_visit_1: 'Y', e3_visit_2: 'Y',
        e1_comment: 'Simple test comment',
        e2_comment: 'Simple test comment',
        e3_comment: 'Simple test comment'
      }
    };

    const formResponse = await axios.post(`${BASE_URL}/forms`, simpleForm, {
      headers: { Authorization: `Bearer ${adminToken}` }
    });

    console.log('✅ Simple form created successfully:', formResponse.data);

  } catch (error) {
    console.error('❌ Error:', {
      message: error.response?.data?.message || error.message,
      status: error.response?.status,
      stack: error.response?.data?.stack || error.stack
    });
  }
}

simpleTest(); 