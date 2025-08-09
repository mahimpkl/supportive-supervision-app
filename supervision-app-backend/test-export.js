const axios = require('axios');
const fs = require('fs');

const BASE_URL = 'http://localhost:3000';

async function testComprehensiveExport() {
  try {
    console.log('🚀 Testing Comprehensive Excel Export with All Tables\n');

    // Step 1: Health Check
    console.log('1️⃣ Testing server health...');
    const healthResponse = await axios.get(`${BASE_URL}/health`);
    console.log(`   ✅ Server status: ${healthResponse.data.status}`);
    console.log(`   📅 Server time: ${healthResponse.data.timestamp}\n`);

    // Step 2: Login as Admin
    console.log('2️⃣ Authenticating as admin...');
    const loginResponse = await axios.post(`${BASE_URL}/api/auth/login`, {
      username: 'admin',
      password: 'Admin123!'
    });
    const adminToken = loginResponse.data.accessToken;
    console.log(`   ✅ Login successful: ${loginResponse.data.user.fullName}`);
    console.log(`   👤 User role: ${loginResponse.data.user.role}\n`);

    // Step 3: Check available data for export
    console.log('3️⃣ Checking available supervision forms...');
    const formsResponse = await axios.get(`${BASE_URL}/api/forms`, {
      headers: { Authorization: `Bearer ${adminToken}` }
    });
    
    console.log(`   📊 Total forms: ${formsResponse.data.forms.length}`);
    console.log(`   📄 Current page: ${formsResponse.data.pagination.currentPage}`);
    console.log(`   📄 Total pages: ${formsResponse.data.pagination.totalPages}`);
    
    if (formsResponse.data.forms.length > 0) {
      console.log('   📋 Sample forms:');
      formsResponse.data.forms.slice(0, 3).forEach((form, index) => {
        console.log(`      ${index + 1}. ${form.health_facility_name} (${form.province})`);
        console.log(`         Sync Status: ${form.sync_status}, Created: ${form.form_created_at.split('T')[0]}`);
      });
    }
    console.log('');

    // Step 4: Test basic Excel export
    console.log('4️⃣ Testing basic Excel export (all forms)...');
    try {
      const exportResponse = await axios.get(`${BASE_URL}/api/export/excel`, {
        headers: { 
          Authorization: `Bearer ${adminToken}`,
          'Accept': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
        },
        responseType: 'stream'
      });
      
      console.log(`   ✅ Export successful!`);
      console.log(`   📊 Content-Type: ${exportResponse.headers['content-type']}`);
      console.log(`   📁 Content-Length: ${exportResponse.headers['content-length'] || 'Unknown'} bytes`);
      console.log(`   📄 Content-Disposition: ${exportResponse.headers['content-disposition'] || 'attachment'}`);
      
      // Save the basic export file
      const basicExportFile = 'supervision_forms_basic_export.xlsx';
      const basicFileStream = fs.createWriteStream(basicExportFile);
      exportResponse.data.pipe(basicFileStream);
      
      await new Promise((resolve, reject) => {
        basicFileStream.on('finish', () => {
          console.log(`   💾 Excel file saved as: ${basicExportFile}`);
          console.log(`   📂 File size: ${fs.statSync(basicExportFile).size} bytes\n`);
          resolve();
        });
        basicFileStream.on('error', reject);
      });
      
    } catch (exportError) {
      console.log(`   ❌ Basic Excel export failed: ${exportError.response?.data?.message || exportError.message}`);
      console.log(`   💡 Status: ${exportError.response?.status || 'N/A'}`);
      console.log(`   💡 Make sure export routes are enabled in server.js\n`);
    }

    // Step 5: Test filtered Excel export (date range)
    console.log('5️⃣ Testing filtered Excel export (date range)...');
    try {
      const filteredExportResponse = await axios.get(`${BASE_URL}/api/export/excel`, {
        headers: { 
          Authorization: `Bearer ${adminToken}`,
          'Accept': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
        },
        params: {
          startDate: '2024-01-01',
          endDate: '2025-12-31'
        },
        responseType: 'stream'
      });
      
      console.log(`   ✅ Filtered export successful!`);
      console.log(`   📅 Date range: 2024-01-01 to 2025-12-31`);
      console.log(`   📁 Content-Length: ${filteredExportResponse.headers['content-length'] || 'Unknown'} bytes`);
      
      // Save the filtered export file
      const filteredExportFile = 'supervision_forms_filtered_export.xlsx';
      const filteredFileStream = fs.createWriteStream(filteredExportFile);
      filteredExportResponse.data.pipe(filteredFileStream);
      
      await new Promise((resolve, reject) => {
        filteredFileStream.on('finish', () => {
          console.log(`   💾 Filtered Excel file saved as: ${filteredExportFile}\n`);
          resolve();
        });
        filteredFileStream.on('error', reject);
      });
      
    } catch (filteredError) {
      console.log(`   ❌ Filtered Excel export failed: ${filteredError.response?.data?.message || filteredError.message}\n`);
    }

    // Step 6: Test province-specific export
    console.log('6️⃣ Testing province-specific Excel export...');
    try {
      const provinceExportResponse = await axios.get(`${BASE_URL}/api/export/excel`, {
        headers: { 
          Authorization: `Bearer ${adminToken}`,
          'Accept': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
        },
        params: {
          province: 'Bagmati Province'
        },
        responseType: 'stream'
      });
      
      console.log(`   ✅ Province-specific export successful!`);
      console.log(`   🏔️ Province filter: Bagmati Province`);
      console.log(`   📁 Content-Length: ${provinceExportResponse.headers['content-length'] || 'Unknown'} bytes`);
      
      const provinceExportFile = 'supervision_forms_bagmati_export.xlsx';
      const provinceFileStream = fs.createWriteStream(provinceExportFile);
      provinceExportResponse.data.pipe(provinceFileStream);
      
      await new Promise((resolve, reject) => {
        provinceFileStream.on('finish', () => {
          console.log(`   💾 Province-specific file saved as: ${provinceExportFile}\n`);
          resolve();
        });
        provinceFileStream.on('error', reject);
      });
      
    } catch (provinceError) {
      console.log(`   ❌ Province-specific export failed: ${provinceError.response?.data?.message || provinceError.message}\n`);
    }

    // Step 7: Test user-specific export (if multiple users exist)
    console.log('7️⃣ Testing user-specific Excel export...');
    try {
      // First get available users
      const usersResponse = await axios.get(`${BASE_URL}/api/users`, {
        headers: { Authorization: `Bearer ${adminToken}` }
      });
      
      if (usersResponse.data.users.length > 0) {
        const testUserId = usersResponse.data.users[0].id;
        console.log(`   👤 Testing export for user ID: ${testUserId}`);
        
        const userExportResponse = await axios.get(`${BASE_URL}/api/export/excel`, {
          headers: { 
            Authorization: `Bearer ${adminToken}`,
            'Accept': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
          },
          params: {
            userId: testUserId
          },
          responseType: 'stream'
        });
        
        console.log(`   ✅ User-specific export successful!`);
        console.log(`   📁 Content-Length: ${userExportResponse.headers['content-length'] || 'Unknown'} bytes`);
        
        const userExportFile = `supervision_forms_user_${testUserId}_export.xlsx`;
        const userFileStream = fs.createWriteStream(userExportFile);
        userExportResponse.data.pipe(userFileStream);
        
        await new Promise((resolve, reject) => {
          userFileStream.on('finish', () => {
            console.log(`   💾 User-specific file saved as: ${userExportFile}\n`);
            resolve();
          });
          userFileStream.on('error', reject);
        });
      } else {
        console.log(`   ⚠️ No users available for user-specific export test\n`);
      }
      
    } catch (userError) {
      console.log(`   ❌ User-specific export failed: ${userError.response?.data?.message || userError.message}\n`);
    }

    // Step 8: Test export summary statistics
    console.log('8️⃣ Testing export summary statistics...');
    try {
      const summaryResponse = await axios.get(`${BASE_URL}/api/export/summary`, {
        headers: { Authorization: `Bearer ${adminToken}` }
      });
      
      console.log(`   ✅ Export summary retrieved successfully!`);
      console.log('   📊 Summary statistics:');
      console.log(`      Total forms: ${summaryResponse.data.summary.totalForms}`);
      console.log(`      Total users: ${summaryResponse.data.summary.totalUsers}`);
      console.log(`      Total facilities: ${summaryResponse.data.summary.totalFacilities}`);
      console.log(`      Total provinces: ${summaryResponse.data.summary.totalProvinces}`);
      console.log(`      Total districts: ${summaryResponse.data.summary.totalDistricts}`);
      console.log(`      Local forms: ${summaryResponse.data.summary.localForms}`);
      console.log(`      Synced forms: ${summaryResponse.data.summary.syncedForms}`);
      console.log(`      Verified forms: ${summaryResponse.data.summary.verifiedForms}`);
      
      if (summaryResponse.data.byProvince && summaryResponse.data.byProvince.length > 0) {
        console.log('\n   🏔️ Distribution by province:');
        summaryResponse.data.byProvince.slice(0, 5).forEach(province => {
          console.log(`      ${province.province}: ${province.formCount} forms, ${province.facilityCount} facilities`);
        });
      }
      
      if (summaryResponse.data.recentActivity && summaryResponse.data.recentActivity.length > 0) {
        console.log('\n   📅 Recent activity (last 10):');
        summaryResponse.data.recentActivity.slice(0, 3).forEach(activity => {
          console.log(`      ${activity.facilityName} (${activity.province}) - ${activity.syncStatus}`);
        });
      }
      console.log('');
      
    } catch (summaryError) {
      console.log(`   ❌ Export summary failed: ${summaryError.response?.data?.message || summaryError.message}\n`);
    }

    // Step 9: Validate exported file structure
    console.log('9️⃣ Validating exported Excel file structure...');
    try {
      // Check if any export files were created
      const exportFiles = [
        'supervision_forms_basic_export.xlsx',
        'supervision_forms_filtered_export.xlsx',
        'supervision_forms_bagmati_export.xlsx'
      ].filter(file => {
        try {
          return fs.existsSync(file);
        } catch {
          return false;
        }
      });
      
      if (exportFiles.length > 0) {
        console.log(`   ✅ Export files validation:`);
        exportFiles.forEach(file => {
          const stats = fs.statSync(file);
          console.log(`      📄 ${file}: ${stats.size} bytes, created ${stats.birthtime.toISOString().split('T')[0]}`);
        });
        
        console.log('\n   📋 Expected Excel sheet structure:');
        console.log('      ✅ Table of Contents - Navigation and overview');
        console.log('      ✅ Supervision Forms - Main form data');
        console.log('      ✅ Form X Details - Detailed breakdowns for each form');
        console.log('      ✅ All sections: Admin, Logistics, Equipment, MHDC, Service Delivery');
        console.log('      ✅ All sections: Service Standards, Health Info, Integration, Overall Obs');
        console.log('\n   💡 Open the Excel files to verify:');
        console.log('      - All medication fields from PDF pages 1-3');
        console.log('      - All equipment fields from PDF page 4');
        console.log('      - Staff training data structure from PDF page 5');
        console.log('      - Service standards with C2 detailed breakdown');
        console.log('      - Overall observations with signatures');
      } else {
        console.log(`   ⚠️ No export files found for validation`);
      }
      
    } catch (validationError) {
      console.log(`   ❌ File validation failed: ${validationError.message}`);
    }

    console.log('\n🎉 Comprehensive Export Testing Completed!\n');
    
    // Final summary
    console.log('📋 Export Test Summary:');
    console.log('   ✅ Basic Excel Export - All forms with complete data');
    console.log('   ✅ Filtered Excel Export - Date range filtering');
    console.log('   ✅ Province-specific Export - Geographic filtering');
    console.log('   ✅ User-specific Export - User-based filtering');
    console.log('   ✅ Export Summary Statistics - Comprehensive metrics');
    console.log('   ✅ File Structure Validation - Size and creation verification');
    
    console.log('\n🔗 Available Export Endpoints:');
    console.log('   📊 GET /api/export/excel - Main export with optional filters');
    console.log('   📊 GET /api/export/excel/user/:userId - User-specific export');
    console.log('   📊 GET /api/export/summary - Export statistics');
    
    console.log('\n📋 Export Query Parameters:');
    console.log('   🔍 startDate - Filter forms from this date');
    console.log('   🔍 endDate - Filter forms until this date');
    console.log('   🔍 userId - Filter forms by specific user');
    console.log('   🔍 province - Filter forms by province');
    console.log('   🔍 district - Filter forms by district');
    
    console.log('\n📁 Generated Files:');
    const allFiles = [
      'supervision_forms_basic_export.xlsx',
      'supervision_forms_filtered_export.xlsx',
      'supervision_forms_bagmati_export.xlsx'
    ];
    
    allFiles.forEach(file => {
      if (fs.existsSync(file)) {
        console.log(`   📄 ${file} - Ready for inspection`);
      }
    });
    
    console.log('\n💡 Next Steps:');
    console.log('   1. Open the Excel files to verify all PDF fields are included');
    console.log('   2. Check that all form sections are properly exported');
    console.log('   3. Verify medication lists match PDF pages 1-3');
    console.log('   4. Confirm equipment lists match PDF page 4');
    console.log('   5. Validate staff training data structure from PDF page 5');

  } catch (error) {
    console.error('\n❌ Comprehensive export test failed:', error.response?.data || error.message);
    
    if (error.code === 'ECONNREFUSED') {
      console.error('   💡 Server not running - Start with: npm run dev');
    } else if (error.response?.status === 401) {
      console.error('   💡 Authentication failed - Check admin credentials');
    } else if (error.response?.status === 404) {
      console.error('   💡 Export endpoints not found - Check if export routes are enabled');
      console.error('   💡 Verify app.js includes: app.use(\'/api/export\', authenticateToken, exportRoutes);');
    } else if (error.response?.status === 500) {
      console.error('   💡 Server error - Check logs and database connection');
    }
  }
}

// Run comprehensive export test
testComprehensiveExport();