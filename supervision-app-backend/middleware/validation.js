const { body, validationResult, param } = require('express-validator');

// Handle validation errors
const handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);
  
  if (!errors.isEmpty()) {
    const errorMessages = errors.array().map(error => ({
      field: error.path,
      message: error.msg,
      value: error.value
    }));

    return res.status(400).json({
      error: 'Validation Error',
      message: 'Invalid input data',
      details: errorMessages
    });
  }
  
  next();
};

// User registration validation
const validateUserRegistration = [
  body('username')
    .isLength({ min: 3, max: 50 })
    .withMessage('Username must be between 3 and 50 characters')
    .matches(/^[a-zA-Z0-9_]+$/)
    .withMessage('Username can only contain letters, numbers, and underscores'),
  
  body('email')
    .isEmail()
    .withMessage('Please provide a valid email address')
    .normalizeEmail(),
  
  body('password')
    .isLength({ min: 8 })
    .withMessage('Password must be at least 8 characters long')
    .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
    .withMessage('Password must contain at least one lowercase letter, one uppercase letter, and one number'),
  
  body('fullName')
    .isLength({ min: 2, max: 100 })
    .withMessage('Full name must be between 2 and 100 characters')
    .trim(),
  
  body('role')
    .optional()
    .isIn(['admin', 'user'])
    .withMessage('Role must be either admin or user'),
  
  handleValidationErrors
];

// Supervision form validation (visit-based structure)
const validateSupervisionForm = [
  body('healthFacilityName')
    .isLength({ min: 2, max: 200 })
    .withMessage('Health facility name must be between 2 and 200 characters')
    .trim(),
  
  body('province')
    .isLength({ min: 2, max: 100 })
    .withMessage('Province must be between 2 and 100 characters')
    .trim(),
  
  body('district')
    .isLength({ min: 2, max: 100 })
    .withMessage('District must be between 2 and 100 characters')
    .trim(),
  
  // Staff training data (form-level) - enhanced validation
  body('staffTraining')
    .optional()
    .isObject()
    .withMessage('Staff training section must be an object'),
  
  body('staffTraining.ha_total_staff')
    .optional()
    .isInt({ min: 0 })
    .withMessage('HA total staff must be a non-negative integer'),
  
  body('staffTraining.training_certificates_verified')
    .optional()
    .isBoolean()
    .withMessage('Training certificates verified must be a boolean'),
  
  // Infrastructure data (form-level) - enhanced validation
  body('infrastructure')
    .optional()
    .isObject()
    .withMessage('Infrastructure section must be an object'),
  
  body('infrastructure.total_rooms')
    .optional()
    .isInt({ min: 0 })
    .withMessage('Total rooms must be a non-negative integer'),
  
  body('infrastructure.infrastructure_score')
    .optional()
    .isInt({ min: 0, max: 100 })
    .withMessage('Infrastructure score must be between 0 and 100'),
  
  handleValidationErrors
];

// Visit validation (comprehensive with all new sections)
const validateVisit = [
  body('visitNumber')
    .isInt({ min: 1, max: 4 })
    .withMessage('Visit number must be between 1 and 4'),
  
  body('visitDate')
    .isISO8601()
    .withMessage('Visit date must be a valid date'),
  
  body('recommendations')
    .optional()
    .isLength({ max: 1000 })
    .withMessage('Recommendations must be 1000 characters or less'),
  
  body('actionsAgreed')
    .optional()
    .isLength({ max: 1000 })
    .withMessage('Actions agreed must be 1000 characters or less'),
  
  body('supervisorSignature')
    .optional()
    .isLength({ max: 5000 })
    .withMessage('Supervisor signature data too large'),
  
  body('facilityRepresentativeSignature')
    .optional()
    .isLength({ max: 5000 })
    .withMessage('Facility representative signature data too large'),
  
  // Optional visit section validations
  body('adminManagement')
    .optional()
    .isObject()
    .withMessage('Admin management section must be an object'),
  
  body('logistics')
    .optional()
    .isObject()
    .withMessage('Logistics section must be an object'),
  
  body('equipment')
    .optional()
    .isObject()
    .withMessage('Equipment section must be an object'),
  
  body('mhdcManagement')
    .optional()
    .isObject()
    .withMessage('MHDC management section must be an object'),
  
  body('serviceStandards')
    .optional()
    .isObject()
    .withMessage('Service standards section must be an object'),
  
  body('healthInformation')
    .optional()
    .isObject()
    .withMessage('Health information section must be an object'),
  
  body('integration')
    .optional()
    .isObject()
    .withMessage('Integration section must be an object'),
  
  body('medicineDetails')
    .optional()
    .isArray()
    .withMessage('Medicine details must be an array'),
  
  body('patientVolumes')
    .optional()
    .isObject()
    .withMessage('Patient volumes section must be an object'),
  
  body('equipmentFunctionality')
    .optional()
    .isArray()
    .withMessage('Equipment functionality must be an array'),
  
  body('qualityAssurance')
    .optional()
    .isObject()
    .withMessage('Quality assurance section must be an object'),
  
  handleValidationErrors
];

// Admin management responses validation (with respondent comments)
const validateAdminManagementResponse = [
  body('a1_response')
    .optional()
    .isIn(['Y', 'N'])
    .withMessage('A1 response must be Y or N'),
  
  body('a1_comment')
    .optional()
    .isLength({ max: 500 })
    .withMessage('A1 comment must be 500 characters or less'),
  
  body('a1_respondents_comment')
    .optional()
    .isLength({ max: 500 })
    .withMessage('A1 respondents comment must be 500 characters or less'),
  
  body('a2_response')
    .optional()
    .isIn(['Y', 'N'])
    .withMessage('A2 response must be Y or N'),
  
  body('a2_comment')
    .optional()
    .isLength({ max: 500 })
    .withMessage('A2 comment must be 500 characters or less'),
  
  body('a2_respondents_comment')
    .optional()
    .isLength({ max: 500 })
    .withMessage('A2 respondents comment must be 500 characters or less'),
  
  body('a3_response')
    .optional()
    .isIn(['Y', 'N'])
    .withMessage('A3 response must be Y or N'),
  
  body('a3_comment')
    .optional()
    .isLength({ max: 500 })
    .withMessage('A3 comment must be 500 characters or less'),
  
  body('a3_respondents_comment')
    .optional()
    .isLength({ max: 500 })
    .withMessage('A3 respondents comment must be 500 characters or less'),
  
  body('actions_agreed')
    .optional()
    .isLength({ max: 1000 })
    .withMessage('Actions agreed must be 1000 characters or less'),
  
  handleValidationErrors
];

// Enhanced logistics responses validation (complete medicine list with quantities)
const validateLogisticsResponse = [
  body('b1_response')
    .optional()
    .isIn(['Y', 'N'])
    .withMessage('B1 response must be Y or N'),
  
  body('b1_comment')
    .optional()
    .isLength({ max: 500 })
    .withMessage('B1 comment must be 500 characters or less'),
  
  body('b1_respondents_comment')
    .optional()
    .isLength({ max: 500 })
    .withMessage('B1 respondents comment must be 500 characters or less'),
  
  body('b1_validation_note')
    .optional()
    .isLength({ max: 500 })
    .withMessage('B1 validation note must be 500 characters or less'),
  
  // Complete medicine availability validations with quantities and units
  ...['amlodipine_5_10mg', 'enalapril_2_5_10mg', 'losartan_25_50mg', 
      'hydrochlorothiazide_12_5_25mg', 'chlorthalidone_6_25_12_5mg', 
      'other_antihypertensives', 'atorvastatin_5mg', 'atorvastatin_10mg',
      'atorvastatin_20mg', 'other_statins', 'metformin_500mg', 'metformin_1000mg',
      'glimepiride_1_2mg', 'gliclazide_40_80mg', 'glipizide_2_5_5mg',
      'sitagliptin_50mg', 'pioglitazone_5mg', 'empagliflozin_10mg',
      'insulin_soluble_inj', 'insulin_nph_inj', 'other_hypoglycemic_agents',
      'dextrose_25_solution', 'aspirin_75mg', 'clopidogrel_75mg',
      'metoprolol_succinate_12_5_25_50mg', 'isosorbide_dinitrate_5mg', 'other_drugs',
      'amoxicillin_clavulanic_potassium_625mg', 'azithromycin_500mg', 'other_antibiotics',
      'salbutamol_dpi', 'salbutamol', 'ipratropium', 'tiotropium_bromide',
      'formoterol', 'other_bronchodilators', 'prednisolone_5_10_20mg', 'other_steroids_oral'
     ].flatMap(medicine => [
    body(medicine)
      .optional()
      .isIn(['Y', 'N'])
      .withMessage(`${medicine} must be Y or N`),
    body(`${medicine}_quantity`)
      .optional()
      .isInt({ min: 0 })
      .withMessage(`${medicine} quantity must be a non-negative integer`),
    body(`${medicine}_units`)
      .optional()
      .isLength({ max: 50 })
      .withMessage(`${medicine} units must be 50 characters or less`)
  ]),
  
  // Specify fields for 'other' medicines
  body('other_antihypertensives_specify')
    .optional()
    .isLength({ max: 200 })
    .withMessage('Other antihypertensives specify must be 200 characters or less'),
  
  body('other_statins_specify')
    .optional()
    .isLength({ max: 200 })
    .withMessage('Other statins specify must be 200 characters or less'),
  
  body('other_hypoglycemic_agents_specify')
    .optional()
    .isLength({ max: 200 })
    .withMessage('Other hypoglycemic agents specify must be 200 characters or less'),
  
  body('other_drugs_specify')
    .optional()
    .isLength({ max: 200 })
    .withMessage('Other drugs specify must be 200 characters or less'),
  
  body('other_antibiotics_specify')
    .optional()
    .isLength({ max: 200 })
    .withMessage('Other antibiotics specify must be 200 characters or less'),
  
  body('other_bronchodilators_specify')
    .optional()
    .isLength({ max: 200 })
    .withMessage('Other bronchodilators specify must be 200 characters or less'),
  
  body('other_steroids_oral_specify')
    .optional()
    .isLength({ max: 200 })
    .withMessage('Other steroids oral specify must be 200 characters or less'),
  
  // B2-B5 responses with enhanced validation
  ...['b2_response', 'b3_response', 'b4_response', 'b5_response'].map(field =>
    body(field)
      .optional()
      .isIn(['Y', 'N'])
      .withMessage(`${field} must be Y or N`)
  ),
  
  ...['b2_comment', 'b3_comment', 'b4_comment', 'b5_comment'].map(field =>
    body(field)
      .optional()
      .isLength({ max: 500 })
      .withMessage(`${field} must be 500 characters or less`)
  ),
  
  ...['b2_respondents_comment', 'b3_respondents_comment', 'b4_respondents_comment', 'b5_respondents_comment'].map(field =>
    body(field)
      .optional()
      .isLength({ max: 500 })
      .withMessage(`${field} must be 500 characters or less`)
  ),
  
  ...['b2_validation_note', 'b3_validation_note', 'b4_validation_note', 'b5_validation_note'].map(field =>
    body(field)
      .optional()
      .isLength({ max: 500 })
      .withMessage(`${field} must be 500 characters or less`)
  ),
  
  // Enhanced B2 glucometer fields
  body('b2_random_records_checked')
    .optional()
    .isBoolean()
    .withMessage('B2 random records checked must be a boolean'),
  
  body('b2_explanation_if_not_in_use')
    .optional()
    .isLength({ max: 500 })
    .withMessage('B2 explanation if not in use must be 500 characters or less'),
  
  // Enhanced B3/B4 urine strip fields
  body('b3_expiry_date_verified')
    .optional()
    .isBoolean()
    .withMessage('B3 expiry date verified must be a boolean'),
  
  body('b3_storage_conditions_verified')
    .optional()
    .isBoolean()
    .withMessage('B3 storage conditions verified must be a boolean'),
  
  body('b4_expiry_date_verified')
    .optional()
    .isBoolean()
    .withMessage('B4 expiry date verified must be a boolean'),
  
  body('b4_storage_conditions_verified')
    .optional()
    .isBoolean()
    .withMessage('B4 storage conditions verified must be a boolean'),
  
  // Enhanced tracking fields
  body('medicine_quantities')
    .optional()
    .isObject()
    .withMessage('Medicine quantities must be an object'),
  
  body('expiry_dates_checked')
    .optional()
    .isBoolean()
    .withMessage('Expiry dates checked must be a boolean'),
  
  body('storage_conditions_verified')
    .optional()
    .isBoolean()
    .withMessage('Storage conditions verified must be a boolean'),
  
  // Category-specific comments
  body('antihypertensive_comments')
    .optional()
    .isLength({ max: 500 })
    .withMessage('Antihypertensive comments must be 500 characters or less'),
  
  body('statin_comments')
    .optional()
    .isLength({ max: 500 })
    .withMessage('Statin comments must be 500 characters or less'),
  
  body('diabetes_medication_comments')
    .optional()
    .isLength({ max: 500 })
    .withMessage('Diabetes medication comments must be 500 characters or less'),
  
  body('cardiovascular_medication_comments')
    .optional()
    .isLength({ max: 500 })
    .withMessage('Cardiovascular medication comments must be 500 characters or less'),
  
  body('respiratory_medication_comments')
    .optional()
    .isLength({ max: 500 })
    .withMessage('Respiratory medication comments must be 500 characters or less'),
  
  body('actions_agreed')
    .optional()
    .isLength({ max: 1000 })
    .withMessage('Actions agreed must be 1000 characters or less'),
  
  handleValidationErrors
];

// Enhanced equipment responses validation (with quantities and units)
const validateEquipmentResponse = [
  ...['sphygmomanometer', 'weighing_scale', 'measuring_tape', 'peak_expiratory_flow_meter',
      'oxygen', 'oxygen_mask', 'nebulizer', 'pulse_oximetry', 'glucometer',
      'glucometer_strips', 'lancets', 'urine_dipstick', 'ecg', 'other_equipment',
      'stethoscope', 'thermometer', 'examination_table', 'privacy_screen'
     ].flatMap(equipment => [
    body(equipment)
      .optional()
      .isIn(['Y', 'N'])
      .withMessage(`${equipment} must be Y or N`),
    body(`${equipment}_quantity`)
      .optional()
      .isInt({ min: 0 })
      .withMessage(`${equipment} quantity must be a non-negative integer`),
    body(`${equipment}_units`)
      .optional()
      .isLength({ max: 50 })
      .withMessage(`${equipment} units must be 50 characters or less`)
  ]),
  
  body('other_equipment_specify')
    .optional()
    .isLength({ max: 200 })
    .withMessage('Other equipment specify must be 200 characters or less'),
  
  body('actions_agreed')
    .optional()
    .isLength({ max: 1000 })
    .withMessage('Actions agreed must be 1000 characters or less'),
  
  handleValidationErrors
];

// Enhanced MHDC management validation (with WHO-ISH tracking)
const validateMhdcManagementResponse = [
  ...['b6_response', 'b7_response', 'b8_response', 'b9_response', 'b10_response'].map(field =>
    body(field)
      .optional()
      .isIn(['Y', 'N'])
      .withMessage(`${field} must be Y or N`)
  ),
  
  ...['b6_comment', 'b7_comment', 'b8_comment', 'b9_comment', 'b10_comment'].map(field =>
    body(field)
      .optional()
      .isLength({ max: 500 })
      .withMessage(`${field} must be 500 characters or less`)
  ),
  
  ...['b6_respondents_comment', 'b7_respondents_comment', 'b8_respondents_comment', 'b9_respondents_comment', 'b10_respondents_comment'].map(field =>
    body(field)
      .optional()
      .isLength({ max: 500 })
      .withMessage(`${field} must be 500 characters or less`)
  ),
  
  // Enhanced tracking fields for B6-B10
  body('b6_healthcare_workers_refer_easily')
    .optional()
    .isBoolean()
    .withMessage('B6 healthcare workers refer easily must be a boolean'),
  
  body('b6_kept_in_opd_use')
    .optional()
    .isBoolean()
    .withMessage('B6 kept in OPD use must be a boolean'),
  
  body('b7_available_at_health_center')
    .optional()
    .isBoolean()
    .withMessage('B7 available at health center must be a boolean'),
  
  body('b8_available_and_filled_properly')
    .optional()
    .isBoolean()
    .withMessage('B8 available and filled properly must be a boolean'),
  
  body('b9_available_for_patient_care')
    .optional()
    .isBoolean()
    .withMessage('B9 available for patient care must be a boolean'),
  
  body('b9_chart_version')
    .optional()
    .isLength({ max: 50 })
    .withMessage('B9 chart version must be 50 characters or less'),
  
  body('b9_chart_condition')
    .optional()
    .isLength({ max: 100 })
    .withMessage('B9 chart condition must be 100 characters or less'),
  
  body('b10_in_use_for_patient_care')
    .optional()
    .isBoolean()
    .withMessage('B10 in use for patient care must be a boolean'),
  
  body('b10_staff_trained_on_chart')
    .optional()
    .isBoolean()
    .withMessage('B10 staff trained on chart must be a boolean'),
  
  body('b10_charts_completed_during_visit')
    .optional()
    .isInt({ min: 0 })
    .withMessage('B10 charts completed during visit must be a non-negative integer'),
  
  body('b10_risk_stratification_accurate')
    .optional()
    .isBoolean()
    .withMessage('B10 risk stratification accurate must be a boolean'),
  
  body('actions_agreed')
    .optional()
    .isLength({ max: 1000 })
    .withMessage('Actions agreed must be 1000 characters or less'),
  
  handleValidationErrors
];

// Enhanced service standards validation (complete C2 sub-services)
const validateServiceStandardsResponse = [
  // Main C2 response
  body('c2_main_response')
    .optional()
    .isIn(['Y', 'N'])
    .withMessage('C2 main response must be Y or N'),
  
  body('c2_main_comment')
    .optional()
    .isLength({ max: 500 })
    .withMessage('C2 main comment must be 500 characters or less'),
  
  body('c2_respondents_comment')
    .optional()
    .isLength({ max: 500 })
    .withMessage('C2 respondents comment must be 500 characters or less'),
  
  // C2 sub-services from PDF page 6
  ...['c2_blood_pressure', 'c2_blood_sugar', 'c2_bmi_measurement', 'c2_waist_circumference',
      'c2_cvd_risk_estimation', 'c2_urine_protein_measurement', 'c2_peak_expiratory_flow_rate',
      'c2_egfr_calculation', 'c2_brief_intervention', 'c2_foot_examination',
      'c2_oral_examination', 'c2_eye_examination', 'c2_health_education'
     ].map(service => 
    body(service)
      .optional()
      .isIn(['Y', 'N'])
      .withMessage(`${service} must be Y or N`)
  ),
  
  // C2 sub-service comments
  ...['c2_blood_pressure_comment', 'c2_blood_sugar_comment', 'c2_bmi_measurement_comment',
      'c2_waist_circumference_comment', 'c2_cvd_risk_estimation_comment', 'c2_urine_protein_measurement_comment',
      'c2_peak_expiratory_flow_rate_comment', 'c2_egfr_calculation_comment', 'c2_brief_intervention_comment',
      'c2_foot_examination_comment', 'c2_oral_examination_comment', 'c2_eye_examination_comment',
      'c2_health_education_comment'
     ].map(field =>
    body(field)
      .optional()
      .isLength({ max: 500 })
      .withMessage(`${field} must be 500 characters or less`)
  ),
  
  // Enhanced C2 validation fields
  body('c2_blood_pressure_equipment_calibrated')
    .optional()
    .isBoolean()
    .withMessage('C2 blood pressure equipment calibrated must be a boolean'),
  
  body('c2_blood_pressure_protocol_followed')
    .optional()
    .isBoolean()
    .withMessage('C2 blood pressure protocol followed must be a boolean'),
  
  body('c2_blood_sugar_strips_available')
    .optional()
    .isBoolean()
    .withMessage('C2 blood sugar strips available must be a boolean'),
  
  body('c2_blood_sugar_quality_control')
    .optional()
    .isBoolean()
    .withMessage('C2 blood sugar quality control must be a boolean'),
  
  body('c2_bmi_calculation_accurate')
    .optional()
    .isBoolean()
    .withMessage('C2 BMI calculation accurate must be a boolean'),
  
  body('c2_waist_measurement_technique_correct')
    .optional()
    .isBoolean()
    .withMessage('C2 waist measurement technique correct must be a boolean'),
  
  body('c2_cvd_chart_available_and_used')
    .optional()
    .isBoolean()
    .withMessage('C2 CVD chart available and used must be a boolean'),
  
  body('c2_urine_protein_strips_not_expired')
    .optional()
    .isBoolean()
    .withMessage('C2 urine protein strips not expired must be a boolean'),
  
  body('c2_egfr_formula_used_correctly')
    .optional()
    .isBoolean()
    .withMessage('C2 eGFR formula used correctly must be a boolean'),
  
  // C3-C7 responses
  ...['c3_response', 'c4_response', 'c5_response', 'c6_response', 'c7_response'].map(field =>
    body(field)
      .optional()
      .isIn(['Y', 'N'])
      .withMessage(`${field} must be Y or N`)
  ),
  
  ...['c3_comment', 'c4_comment', 'c5_comment', 'c6_comment', 'c7_comment'].map(field =>
    body(field)
      .optional()
      .isLength({ max: 500 })
      .withMessage(`${field} must be 500 characters or less`)
  ),
  
  ...['c3_respondents_comment', 'c4_respondents_comment', 'c5_respondents_comment', 'c6_respondents_comment', 'c7_respondents_comment'].map(field =>
    body(field)
      .optional()
      .isLength({ max: 500 })
      .withMessage(`${field} must be 500 characters or less`)
  ),
  
  body('actions_agreed')
    .optional()
    .isLength({ max: 1000 })
    .withMessage('Actions agreed must be 1000 characters or less'),
  
  handleValidationErrors
];

// Enhanced health information validation (with respondent comments)
const validateHealthInformationResponse = [
  ...['d1_response', 'd2_response', 'd3_response', 'd4_response', 'd5_response'].map(field =>
    body(field)
      .optional()
      .isIn(['Y', 'N'])
      .withMessage(`${field} must be Y or N`)
  ),
  
  ...['d1_comment', 'd2_comment', 'd3_comment', 'd4_comment', 'd5_comment'].map(field =>
    body(field)
      .optional()
      .isLength({ max: 500 })
      .withMessage(`${field} must be 500 characters or less`)
  ),
  
  ...['d1_respondents_comment', 'd2_respondents_comment', 'd3_respondents_comment', 'd4_respondents_comment', 'd5_respondents_comment'].map(field =>
    body(field)
      .optional()
      .isLength({ max: 500 })
      .withMessage(`${field} must be 500 characters or less`)
  ),
  
  // Enhanced D4 fields
  body('d4_number_of_people')
    .optional()
    .isInt({ min: 0 })
    .withMessage('D4 number of people must be a non-negative integer'),
  
  body('d4_previous_month_data')
    .optional()
    .isBoolean()
    .withMessage('D4 previous month data must be a boolean'),
  
  body('actions_agreed')
    .optional()
    .isLength({ max: 1000 })
    .withMessage('Actions agreed must be 1000 characters or less'),
  
  handleValidationErrors
];

// Enhanced integration validation (with respondent comments)
const validateIntegrationResponse = [
  ...['e1_response', 'e2_response', 'e3_response'].map(field =>
    body(field)
      .optional()
      .isIn(['Y', 'N'])
      .withMessage(`${field} must be Y or N`)
  ),
  
  ...['e1_comment', 'e2_comment', 'e3_comment'].map(field =>
    body(field)
      .optional()
      .isLength({ max: 500 })
      .withMessage(`${field} must be 500 characters or less`)
  ),
  
  ...['e1_respondents_comment', 'e2_respondents_comment', 'e3_respondents_comment'].map(field =>
    body(field)
      .optional()
      .isLength({ max: 500 })
      .withMessage(`${field} must be 500 characters or less`)
  ),
  
  body('actions_agreed')
    .optional()
    .isLength({ max: 1000 })
    .withMessage('Actions agreed must be 1000 characters or less'),
  
  handleValidationErrors
];

// Enhanced staff training validation (with training dates and provider)
const validateStaffTraining = [
  ...['ha_total_staff', 'ha_mhdc_trained', 'ha_fen_trained', 'ha_other_ncd_trained',
      'sr_ahw_total_staff', 'sr_ahw_mhdc_trained', 'sr_ahw_fen_trained', 'sr_ahw_other_ncd_trained',
      'ahw_total_staff', 'ahw_mhdc_trained', 'ahw_fen_trained', 'ahw_other_ncd_trained',
      'sr_anm_total_staff', 'sr_anm_mhdc_trained', 'sr_anm_fen_trained', 'sr_anm_other_ncd_trained',
      'anm_total_staff', 'anm_mhdc_trained', 'anm_fen_trained', 'anm_other_ncd_trained',
      'others_total_staff', 'others_mhdc_trained', 'others_fen_trained', 'others_other_ncd_trained'
     ].map(field => 
    body(field)
      .optional()
      .isInt({ min: 0 })
      .withMessage(`${field} must be a non-negative integer`)
  ),
  
  body('last_mhdc_training_date')
    .optional()
    .isISO8601()
    .withMessage('Last MHDC training date must be a valid date'),
  
  body('last_fen_training_date')
    .optional()
    .isISO8601()
    .withMessage('Last FEN training date must be a valid date'),
  
  body('last_other_training_date')
    .optional()
    .isISO8601()
    .withMessage('Last other training date must be a valid date'),
  
  body('training_provider')
    .optional()
    .isLength({ max: 200 })
    .withMessage('Training provider must be 200 characters or less'),
  
  body('training_certificates_verified')
    .optional()
    .isBoolean()
    .withMessage('Training certificates verified must be a boolean'),
  
  handleValidationErrors
];

// Enhanced medicine details validation (comprehensive tracking)
const validateMedicineDetails = [
  body('*.medicine_name')
    .isLength({ min: 1, max: 200 })
    .withMessage('Medicine name is required and must be 200 characters or less'),
  
  body('*.medicine_category')
    .optional()
    .isLength({ max: 100 })
    .withMessage('Medicine category must be 100 characters or less'),
  
  body('*.availability')
    .optional()
    .isIn(['Y', 'N'])
    .withMessage('Availability must be Y or N'),
  
  body('*.quantity_available')
    .optional()
    .isInt({ min: 0 })
    .withMessage('Quantity available must be a non-negative integer'),
  
  body('*.unit_of_measurement')
    .optional()
    .isLength({ max: 50 })
    .withMessage('Unit of measurement must be 50 characters or less'),
  
  body('*.expiry_date')
    .optional()
    .isISO8601()
    .withMessage('Expiry date must be a valid date'),
  
  body('*.batch_number')
    .optional()
    .isLength({ max: 100 })
    .withMessage('Batch number must be 100 characters or less'),
  
  body('*.storage_temperature_ok')
    .optional()
    .isBoolean()
    .withMessage('Storage temperature OK must be a boolean'),
  
  body('*.storage_humidity_ok')
    .optional()
    .isBoolean()
    .withMessage('Storage humidity OK must be a boolean'),
  
  body('*.storage_location')
    .optional()
    .isLength({ max: 200 })
    .withMessage('Storage location must be 200 characters or less'),
  
  body('*.procurement_source')
    .optional()
    .isLength({ max: 200 })
    .withMessage('Procurement source must be 200 characters or less'),
  
  body('*.cost_per_unit')
    .optional()
    .isDecimal()
    .withMessage('Cost per unit must be a valid decimal'),
  
  body('*.last_restocked_date')
    .optional()
    .isISO8601()
    .withMessage('Last restocked date must be a valid date'),
  
  body('*.minimum_stock_level')
    .optional()
    .isInt({ min: 0 })
    .withMessage('Minimum stock level must be a non-negative integer'),
  
  body('*.stock_out_frequency')
    .optional()
    .isIn(['never', 'rarely', 'sometimes', 'often', 'always'])
    .withMessage('Stock out frequency must be never, rarely, sometimes, often, or always'),
  
  body('*.quality_issues_noted')
    .optional()
    .isLength({ max: 500 })
    .withMessage('Quality issues noted must be 500 characters or less'),
  
  handleValidationErrors
];

// Enhanced patient volumes validation (comprehensive D4 data)
const validatePatientVolumes = [
  body('total_patients_seen')
    .optional()
    .isInt({ min: 0 })
    .withMessage('Total patients seen must be a non-negative integer'),
  
  body('ncd_patients_new')
    .optional()
    .isInt({ min: 0 })
    .withMessage('NCD patients new must be a non-negative integer'),
  
  body('ncd_patients_followup')
    .optional()
    .isInt({ min: 0 })
    .withMessage('NCD patients followup must be a non-negative integer'),
  
  body('diabetes_patients')
    .optional()
    .isInt({ min: 0 })
    .withMessage('Diabetes patients must be a non-negative integer'),
  
  body('hypertension_patients')
    .optional()
    .isInt({ min: 0 })
    .withMessage('Hypertension patients must be a non-negative integer'),
  
  body('copd_patients')
    .optional()
    .isInt({ min: 0 })
    .withMessage('COPD patients must be a non-negative integer'),
  
  body('cardiovascular_patients')
    .optional()
    .isInt({ min: 0 })
    .withMessage('Cardiovascular patients must be a non-negative integer'),
  
  body('other_ncd_patients')
    .optional()
    .isInt({ min: 0 })
    .withMessage('Other NCD patients must be a non-negative integer'),
  
  body('referrals_made')
    .optional()
    .isInt({ min: 0 })
    .withMessage('Referrals made must be a non-negative integer'),
  
  body('referrals_received')
    .optional()
    .isInt({ min: 0 })
    .withMessage('Referrals received must be a non-negative integer'),
  
  body('emergency_cases')
    .optional()
    .isInt({ min: 0 })
    .withMessage('Emergency cases must be a non-negative integer'),
  
  body('month_year')
    .optional()
    .isISO8601()
    .withMessage('Month year must be a valid date'),
  
  body('data_source')
    .optional()
    .isIn(['register', 'dashboard', 'estimation'])
    .withMessage('Data source must be register, dashboard, or estimation'),
  
  body('data_verified')
    .optional()
    .isBoolean()
    .withMessage('Data verified must be a boolean'),
  
  handleValidationErrors
];

// Equipment functionality validation (comprehensive tracking)
const validateEquipmentFunctionality = [
  body('*.equipment_name')
    .isLength({ min: 1, max: 200 })
    .withMessage('Equipment name is required and must be 200 characters or less'),
  
  body('*.equipment_category')
    .optional()
    .isIn(['diagnostic', 'treatment', 'monitoring'])
    .withMessage('Equipment category must be diagnostic, treatment, or monitoring'),
  
  body('*.brand_model')
    .optional()
    .isLength({ max: 200 })
    .withMessage('Brand model must be 200 characters or less'),
  
  body('*.serial_number')
    .optional()
    .isLength({ max: 100 })
    .withMessage('Serial number must be 100 characters or less'),
  
  body('*.availability')
    .optional()
    .isIn(['Y', 'N'])
    .withMessage('Availability must be Y or N'),
  
  body('*.functionality_status')
    .optional()
    .isIn(['working', 'partially_working', 'not_working', 'needs_repair'])
    .withMessage('Functionality status must be working, partially_working, not_working, or needs_repair'),
  
  body('*.last_calibration_date')
    .optional()
    .isISO8601()
    .withMessage('Last calibration date must be a valid date'),
  
  body('*.calibration_due_date')
    .optional()
    .isISO8601()
    .withMessage('Calibration due date must be a valid date'),
  
  body('*.maintenance_schedule')
    .optional()
    .isLength({ max: 100 })
    .withMessage('Maintenance schedule must be 100 characters or less'),
  
  body('*.usage_frequency')
    .optional()
    .isIn(['daily', 'weekly', 'monthly', 'rarely'])
    .withMessage('Usage frequency must be daily, weekly, monthly, or rarely'),
  
  body('*.staff_trained_on_equipment')
    .optional()
    .isBoolean()
    .withMessage('Staff trained on equipment must be a boolean'),
  
  body('*.user_manual_available')
    .optional()
    .isBoolean()
    .withMessage('User manual available must be a boolean'),
  
  body('*.spare_parts_available')
    .optional()
    .isBoolean()
    .withMessage('Spare parts available must be a boolean'),
  
  body('*.warranty_status')
    .optional()
    .isIn(['active', 'expired', 'not_applicable'])
    .withMessage('Warranty status must be active, expired, or not_applicable'),
  
  body('*.issues_noted')
    .optional()
    .isLength({ max: 500 })
    .withMessage('Issues noted must be 500 characters or less'),
  
  body('*.repair_history')
    .optional()
    .isLength({ max: 500 })
    .withMessage('Repair history must be 500 characters or less'),
  
  body('*.procurement_date')
    .optional()
    .isISO8601()
    .withMessage('Procurement date must be a valid date'),
  
  body('*.cost')
    .optional()
    .isDecimal()
    .withMessage('Cost must be a valid decimal'),
  
  body('*.funding_source')
    .optional()
    .isLength({ max: 200 })
    .withMessage('Funding source must be 200 characters or less'),
  
  handleValidationErrors
];

// Quality assurance validation (comprehensive tracking)
const validateQualityAssurance = [
  body('guidelines_followed')
    .optional()
    .isBoolean()
    .withMessage('Guidelines followed must be a boolean'),
  
  body('protocols_updated')
    .optional()
    .isBoolean()
    .withMessage('Protocols updated must be a boolean'),
  
  body('clinical_audit_conducted')
    .optional()
    .isBoolean()
    .withMessage('Clinical audit conducted must be a boolean'),
  
  body('patient_satisfaction_assessed')
    .optional()
    .isBoolean()
    .withMessage('Patient satisfaction assessed must be a boolean'),
  
  body('records_complete')
    .optional()
    .isBoolean()
    .withMessage('Records complete must be a boolean'),
  
  body('documentation_legible')
    .optional()
    .isBoolean()
    .withMessage('Documentation legible must be a boolean'),
  
  body('consent_forms_used')
    .optional()
    .isBoolean()
    .withMessage('Consent forms used must be a boolean'),
  
  body('privacy_maintained')
    .optional()
    .isBoolean()
    .withMessage('Privacy maintained must be a boolean'),
  
  body('infection_control_practices')
    .optional()
    .isBoolean()
    .withMessage('Infection control practices must be a boolean'),
  
  body('hand_hygiene_facilities')
    .optional()
    .isBoolean()
    .withMessage('Hand hygiene facilities must be a boolean'),
  
  body('emergency_procedures_known')
    .optional()
    .isBoolean()
    .withMessage('Emergency procedures known must be a boolean'),
  
  body('adverse_events_reported')
    .optional()
    .isBoolean()
    .withMessage('Adverse events reported must be a boolean'),
  
  body('staff_knowledge_adequate')
    .optional()
    .isBoolean()
    .withMessage('Staff knowledge adequate must be a boolean'),
  
  body('continuing_education_provided')
    .optional()
    .isBoolean()
    .withMessage('Continuing education provided must be a boolean'),
  
  body('supervision_regular')
    .optional()
    .isBoolean()
    .withMessage('Supervision regular must be a boolean'),
  
  body('overall_quality_score')
    .optional()
    .isInt({ min: 0, max: 100 })
    .withMessage('Overall quality score must be between 0 and 100'),
  
  body('areas_for_improvement')
    .optional()
    .isLength({ max: 1000 })
    .withMessage('Areas for improvement must be 1000 characters or less'),
  
  body('good_practices_observed')
    .optional()
    .isLength({ max: 1000 })
    .withMessage('Good practices observed must be 1000 characters or less'),
  
  handleValidationErrors
];

// Enhanced infrastructure validation (comprehensive facility assessment)
const validateInfrastructure = [
  body('total_rooms')
    .optional()
    .isInt({ min: 0 })
    .withMessage('Total rooms must be a non-negative integer'),
  
  body('consultation_rooms')
    .optional()
    .isInt({ min: 0 })
    .withMessage('Consultation rooms must be a non-negative integer'),
  
  body('waiting_area_adequate')
    .optional()
    .isBoolean()
    .withMessage('Waiting area adequate must be a boolean'),
  
  body('waiting_area_capacity')
    .optional()
    .isInt({ min: 0 })
    .withMessage('Waiting area capacity must be a non-negative integer'),
  
  body('pharmacy_storage_adequate')
    .optional()
    .isBoolean()
    .withMessage('Pharmacy storage adequate must be a boolean'),
  
  body('pharmacy_storage_size_sqm')
    .optional()
    .isDecimal()
    .withMessage('Pharmacy storage size sqm must be a valid decimal'),
  
  body('cold_chain_available')
    .optional()
    .isBoolean()
    .withMessage('Cold chain available must be a boolean'),
  
  body('cold_chain_temperature_monitored')
    .optional()
    .isBoolean()
    .withMessage('Cold chain temperature monitored must be a boolean'),
  
  body('medicine_storage_conditions_appropriate')
    .optional()
    .isBoolean()
    .withMessage('Medicine storage conditions appropriate must be a boolean'),
  
  body('generator_backup')
    .optional()
    .isBoolean()
    .withMessage('Generator backup must be a boolean'),
  
  body('generator_capacity_kw')
    .optional()
    .isDecimal()
    .withMessage('Generator capacity kw must be a valid decimal'),
  
  body('water_supply_reliable')
    .optional()
    .isBoolean()
    .withMessage('Water supply reliable must be a boolean'),
  
  body('water_storage_capacity_liters')
    .optional()
    .isInt({ min: 0 })
    .withMessage('Water storage capacity liters must be a non-negative integer'),
  
  body('electricity_stable')
    .optional()
    .isBoolean()
    .withMessage('Electricity stable must be a boolean'),
  
  body('internet_connectivity')
    .optional()
    .isBoolean()
    .withMessage('Internet connectivity must be a boolean'),
  
  body('waste_disposal_system')
    .optional()
    .isBoolean()
    .withMessage('Waste disposal system must be a boolean'),
  
  body('sharps_disposal_appropriate')
    .optional()
    .isBoolean()
    .withMessage('Sharps disposal appropriate must be a boolean'),
  
  body('biomedical_waste_segregation')
    .optional()
    .isBoolean()
    .withMessage('Biomedical waste segregation must be a boolean'),
  
  body('accessibility_features')
    .optional()
    .isBoolean()
    .withMessage('Accessibility features must be a boolean'),
  
  body('wheelchair_accessible')
    .optional()
    .isBoolean()
    .withMessage('Wheelchair accessible must be a boolean'),
  
  body('fire_safety_equipment')
    .optional()
    .isBoolean()
    .withMessage('Fire safety equipment must be a boolean'),
  
  body('emergency_protocols_displayed')
    .optional()
    .isBoolean()
    .withMessage('Emergency protocols displayed must be a boolean'),
  
  body('laboratory_available')
    .optional()
    .isBoolean()
    .withMessage('Laboratory available must be a boolean'),
  
  body('xray_available')
    .optional()
    .isBoolean()
    .withMessage('X-ray available must be a boolean'),
  
  body('ambulance_service')
    .optional()
    .isBoolean()
    .withMessage('Ambulance service must be a boolean'),
  
  body('assessment_date')
    .optional()
    .isISO8601()
    .withMessage('Assessment date must be a valid date'),
  
  body('assessed_by')
    .optional()
    .isLength({ max: 200 })
    .withMessage('Assessed by must be 200 characters or less'),
  
  body('infrastructure_score')
    .optional()
    .isInt({ min: 0, max: 100 })
    .withMessage('Infrastructure score must be between 0 and 100'),
  
  body('priority_improvements')
    .optional()
    .isLength({ max: 1000 })
    .withMessage('Priority improvements must be 1000 characters or less'),
  
  handleValidationErrors
];

// Enhanced bulk sync validation (updated for comprehensive visit-based structure)
const validateBulkSync = [
  body('forms')
    .isArray({ min: 1 })
    .withMessage('Forms array is required and must contain at least one form'),
  
  body('forms.*.tempId')
    .notEmpty()
    .withMessage('Each form must have a tempId'),
  
  body('forms.*.healthFacilityName')
    .isLength({ min: 2, max: 200 })
    .withMessage('Health facility name is required'),
  
  body('forms.*.visits')
    .optional()
    .isArray()
    .withMessage('Visits must be an array'),
  
  body('forms.*.visits.*.visitNumber')
    .optional()
    .isInt({ min: 1, max: 4 })
    .withMessage('Visit number must be between 1 and 4'),
  
  body('forms.*.visits.*.visitDate')
    .optional()
    .isISO8601()
    .withMessage('Visit date must be a valid date'),
  
  body('forms.*.visits.*.actionsAgreed')
    .optional()
    .isLength({ max: 1000 })
    .withMessage('Actions agreed must be 1000 characters or less'),
  
  body('deviceId')
    .notEmpty()
    .withMessage('Device ID is required'),
  
  body('appVersion')
    .optional()
    .isLength({ max: 50 })
    .withMessage('App version must be 50 characters or less'),
  
  handleValidationErrors
];

// User login validation
const validateUserLogin = [
  body('username')
    .notEmpty()
    .withMessage('Username is required')
    .trim(),
  
  body('password')
    .notEmpty()
    .withMessage('Password is required'),
  
  handleValidationErrors
];

// User update validation
const validateUserUpdate = [
  body('username')
    .optional()
    .isLength({ min: 3, max: 50 })
    .withMessage('Username must be between 3 and 50 characters')
    .matches(/^[a-zA-Z0-9_]+$/)
    .withMessage('Username can only contain letters, numbers, and underscores'),
  
  body('email')
    .optional()
    .isEmail()
    .withMessage('Please provide a valid email address')
    .normalizeEmail(),
  
  body('fullName')
    .optional()
    .isLength({ min: 2, max: 100 })
    .withMessage('Full name must be between 2 and 100 characters')
    .trim(),
  
  body('role')
    .optional()
    .isIn(['admin', 'user'])
    .withMessage('Role must be either admin or user'),
  
  body('isActive')
    .optional()
    .isBoolean()
    .withMessage('isActive must be a boolean value'),
  
  handleValidationErrors
];

// Password change validation
const validatePasswordChange = [
  body('currentPassword')
    .notEmpty()
    .withMessage('Current password is required'),
  
  body('newPassword')
    .isLength({ min: 8 })
    .withMessage('New password must be at least 8 characters long')
    .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
    .withMessage('New password must contain at least one lowercase letter, one uppercase letter, and one number'),
  
  body('confirmPassword')
    .custom((value, { req }) => {
      if (value !== req.body.newPassword) {
        throw new Error('Password confirmation does not match new password');
      }
      return true;
    }),
  
  handleValidationErrors
];

// ID parameter validation
const validateId = [
  param('id')
    .isInt({ min: 1 })
    .withMessage('ID must be a positive integer'),
  
  handleValidationErrors
];

// Visit number parameter validation
const validateVisitNumber = [
  param('visitNumber')
    .isInt({ min: 1, max: 4 })
    .withMessage('Visit number must be between 1 and 4'),
  
  handleValidationErrors
];

// Yes/No response validation helper
const validateYesNoResponse = (fieldName) => {
  return body(fieldName)
    .optional()
    .isIn(['Y', 'N', 'y', 'n', ''])
    .withMessage(`${fieldName} must be Y, N, or empty`);
};

// Refresh token validation
const validateRefreshToken = [
  body('refreshToken')
    .notEmpty()
    .withMessage('Refresh token is required'),
  
  handleValidationErrors
];

// Export validation
const validateExportRequest = [
  body('startDate')
    .optional()
    .isISO8601()
    .withMessage('Start date must be a valid date'),
  
  body('endDate')
    .optional()
    .isISO8601()
    .withMessage('End date must be a valid date'),
  
  body('userId')
    .optional()
    .isInt({ min: 1 })
    .withMessage('User ID must be a positive integer'),
  
  body('format')
    .optional()
    .isIn(['json', 'csv', 'excel', 'pdf'])
    .withMessage('Format must be json, csv, excel, or pdf'),
  
  handleValidationErrors
];

module.exports = {
  handleValidationErrors,
  validateUserRegistration,
  validateUserLogin,
  validateUserUpdate,
  validatePasswordChange,
  validateSupervisionForm,
  validateVisit,
  validateAdminManagementResponse,
  validateLogisticsResponse,
  validateEquipmentResponse,
  validateStaffTraining,
  validateServiceStandardsResponse,
  validateHealthInformationResponse,
  validateIntegrationResponse,
  validateMhdcManagementResponse,
  validateMedicineDetails,
  validatePatientVolumes,
  validateEquipmentFunctionality,
  validateQualityAssurance,
  validateInfrastructure,
  validateId,
  validateVisitNumber,
  validateYesNoResponse,
  validateRefreshToken,
  validateExportRequest,
  validateBulkSync
};