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
  
  handleValidationErrors
];

// Visit validation (simplified - removed unnecessary sections)
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
  
  body('khdcManagement')
    .optional()
    .isObject()
    .withMessage('KHDC management section must be an object'),
  
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

// Enhanced logistics responses validation (quantities only - no units)
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
  
  // Complete medicine availability validations with quantities only (no units)
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
      .withMessage(`${medicine} quantity must be a non-negative integer`)
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
  
  body('actions_agreed')
    .optional()
    .isLength({ max: 1000 })
    .withMessage('Actions agreed must be 1000 characters or less'),
  
  handleValidationErrors
];

// Enhanced equipment responses validation (quantities only - no units)
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
      .withMessage(`${equipment} quantity must be a non-negative integer`)
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

// Enhanced KHDC management validation (with WHO-ISH tracking)
const validateKhdcManagementResponse = [
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

// Enhanced staff training validation (KHDC naming, simplified)
const validateStaffTraining = [
  ...['ha_total_staff', 'ha_khdc_trained', 'ha_fen_trained', 'ha_other_ncd_trained',
      'sr_ahw_total_staff', 'sr_ahw_khdc_trained', 'sr_ahw_fen_trained', 'sr_ahw_other_ncd_trained',
      'ahw_total_staff', 'ahw_khdc_trained', 'ahw_fen_trained', 'ahw_other_ncd_trained',
      'sr_anm_total_staff', 'sr_anm_khdc_trained', 'sr_anm_fen_trained', 'sr_anm_other_ncd_trained',
      'anm_total_staff', 'anm_khdc_trained', 'anm_fen_trained', 'anm_other_ncd_trained',
      'others_total_staff', 'others_khdc_trained', 'others_fen_trained', 'others_other_ncd_trained'
     ].map(field => 
    body(field)
      .optional()
      .isInt({ min: 0 })
      .withMessage(`${field} must be a non-negative integer`)
  ),
  
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
  validateKhdcManagementResponse,
  validateId,
  validateVisitNumber,
  validateYesNoResponse,
  validateRefreshToken,
  validateExportRequest,
  validateBulkSync
};