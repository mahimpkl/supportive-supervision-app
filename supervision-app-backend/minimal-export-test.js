console.log('Testing minimal export routes...');

try {
  // Test basic imports
  console.log('1. Testing basic imports...');
  const express = require('express');
  const ExcelJS = require('exceljs');
  console.log('✅ Basic imports successful');

  // Test validation middleware
  console.log('2. Testing validation middleware...');
  const { validateExportRequest } = require('./middleware/validation');
  console.log('✅ Validation middleware imported');

  // Test database connection
  console.log('3. Testing database connection...');
  const db = require('./config/database');
  console.log('✅ Database connection imported');

  // Test auth middleware
  console.log('4. Testing auth middleware...');
  const { requireAdmin } = require('./middleware/auth');
  console.log('✅ Auth middleware imported');

  // Test export routes
  console.log('5. Testing export routes...');
  const exportRoutes = require('./routes/export');
  console.log('✅ Export routes imported successfully');
  console.log('Type:', typeof exportRoutes);
  console.log('Is router:', exportRoutes && typeof exportRoutes.use === 'function');
  console.log('Export routes keys:', Object.keys(exportRoutes));
  console.log('Export routes prototype:', Object.getPrototypeOf(exportRoutes));

} catch (error) {
  console.error('❌ Error:', error.message);
  console.error('Stack:', error.stack);
}

console.log('Test completed!'); 