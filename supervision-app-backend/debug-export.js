console.log('Debugging export routes...');

try {
  console.log('1. Creating Express router...');
  const express = require('express');
  const router = express.Router();
  console.log('✅ Router created successfully');
  console.log('Router type:', typeof router);
  console.log('Router has use method:', typeof router.use === 'function');

  console.log('2. Adding a test route...');
  router.get('/test', (req, res) => {
    res.json({ message: 'Test route working' });
  });
  console.log('✅ Test route added');

  console.log('3. Testing router export...');
  console.log('Router before export:', router);
  console.log('Router keys:', Object.keys(router));
  
  // Simulate the export
  const testExport = router;
  console.log('✅ Export simulation successful');
  console.log('Exported type:', typeof testExport);
  console.log('Exported has use method:', typeof testExport.use === 'function');

} catch (error) {
  console.error('❌ Error:', error.message);
  console.error('Stack:', error.stack);
}

console.log('Debug completed!'); 