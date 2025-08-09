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

// Supervision form validation
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
  
  body('visit1Date')
    .optional()
    .isISO8601()
    .withMessage('Visit 1 date must be a valid date'),
  
  body('visit2Date')
    .optional()
    .isISO8601()
    .withMessage('Visit 2 date must be a valid date'),
  
  body('visit3Date')
    .optional()
    .isISO8601()
    .withMessage('Visit 3 date must be a valid date'),
  
  body('visit4Date')
    .optional()
    .isISO8601()
    .withMessage('Visit 4 date must be a valid date'),

  // Optional section validations
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
  
  body('serviceDelivery')
    .optional()
    .isObject()
    .withMessage('Service delivery section must be an object'),
  
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

// Form section validation helpers
const validateYesNoFields = (sectionName, fields) => {
  return fields.map(field => 
    body(`${sectionName}.${field}`)
      .optional()
      .isIn(['Y', 'N', 'y', 'n', ''])
      .withMessage(`${field} must be Y, N, or empty`)
  );
};

// Bulk sync validation
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
  
  body('deviceId')
    .notEmpty()
    .withMessage('Device ID is required'),
  
  handleValidationErrors
];

// ID parameter validation
const validateId = [
  param('id')
    .isInt({ min: 1 })
    .withMessage('ID must be a positive integer'),
  
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
  
  handleValidationErrors
];

module.exports = {
  handleValidationErrors,
  validateUserRegistration,
  validateUserLogin,
  validateUserUpdate,
  validatePasswordChange,
  validateSupervisionForm,
  validateId,
  validateYesNoResponse,
  validateRefreshToken,
  validateExportRequest,
  validateYesNoFields,
  validateBulkSync
};