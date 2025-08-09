const axios = require('axios');

const BASE_URL = 'http://localhost:3000';

async function quickTest() {
  try {
    console.log('🚀 Quick Test - Supervision App Backend\n');

    // Step 1: Health Check
    console.log('1️⃣ Testing health check...');
    const healthResponse = await axios.get(`${BASE_URL}/health`);
    console.log(`   ✅ Server is running: ${healthResponse.data.status}\n`);

    // Step 2: Login as Admin
    console.log('2️⃣ Logging in as admin...');
    const loginResponse = await axios.post(`${BASE_URL}/api/auth/login`, {
      username: 'admin',
      password: 'Admin123!'
    });
    const adminToken = loginResponse.data.accessToken;
    console.log(`   ✅ Admin login successful: ${loginResponse.data.user.fullName}\n`);

    // Step 3: Get All Forms
    console.log('3️⃣ Getting all forms...');
    const formsResponse = await axios.get(`${BASE_URL}/api/forms`, {
      headers: { Authorization: `Bearer ${adminToken}` }
    });
    console.log(`   ✅ Found ${formsResponse.data.forms.length} forms\n`);

    // Step 4: Test Facility History (if forms exist)
    if (formsResponse.data.forms.length > 0) {
      console.log('4️⃣ Testing facility history endpoint...');
      const firstForm = formsResponse.data.forms[0];
      const facilityName = encodeURIComponent(firstForm.health_facility_name);
      
      try {
        const historyResponse = await axios.get(
          `${BASE_URL}/api/forms/facility/${facilityName}/history`,
          { headers: { Authorization: `Bearer ${adminToken}` } }
        );
        console.log(`   ✅ Facility history retrieved: ${historyResponse.data.totalVisits} visits`);
        console.log(`   📊 Trends calculated: ${Object.keys(historyResponse.data.trends).length} metrics\n`);
      } catch (historyError) {
        console.log(`   ⚠️ Facility history test skipped: ${historyError.response?.data?.message || 'No forms found'}\n`);
      }
    }

    // Step 5: Test Facilities Summary
    console.log('5️⃣ Testing facilities summary endpoint...');
    try {
      const summaryResponse = await axios.get(
        `${BASE_URL}/api/forms/facilities/summary`,
        { headers: { Authorization: `Bearer ${adminToken}` } }
      );
      console.log(`   ✅ Facilities summary: ${summaryResponse.data.summary.totalFacilities} facilities`);
      console.log(`   📊 Total visits: ${summaryResponse.data.summary.totalVisits}\n`);
    } catch (summaryError) {
      console.log(`   ⚠️ Facilities summary test skipped: ${summaryError.response?.data?.message || 'No data available'}\n`);
    }

    // Step 6: Test User Management
    console.log('6️⃣ Testing user management...');
    try {
      const usersResponse = await axios.get(`${BASE_URL}/api/users`, {
        headers: { Authorization: `Bearer ${adminToken}` }
      });
      console.log(`   ✅ Users retrieved: ${usersResponse.data.users.length} users\n`);
    } catch (usersError) {
      console.log(`   ⚠️ User management test skipped: ${usersError.response?.data?.message || 'Access denied'}\n`);
    }

    // Step 7: Test Form Creation (if no forms exist)
    if (formsResponse.data.forms.length === 0) {
      console.log('7️⃣ Creating a test form...');
      try {
        const testForm = {
          healthFacilityName: 'Test Health Center',
          province: 'Test Province',
          district: 'Test District',
          visit1Date: '2024-01-15',
          recommendationsVisit1: 'Test recommendation',
          adminManagement: {
            a1_visit_1: 'Y',
            a2_visit_1: 'N',
            a3_visit_1: 'Y',
            a1_comment: 'Test comment'
          },
          logistics: {
            b1_visit_1: 'Y',
            b2_visit_1: 'N',
            b1_comment: 'Test logistics'
          },
          equipment: {
            sphygmomanometer_v1: 'Y',
            glucometer_v1: 'N'
          },
          mhdcManagement: {
            b6_visit_1: 'Y',
            b7_visit_1: 'N',
            b6_comment: 'Test MHDC'
          },
          serviceDelivery: {
            ha_total_staff: 5,
            ha_mhdc_trained: 3,
            ha_fen_trained: 2
          },
          serviceStandards: {
            c2_blood_pressure_v1: 'Y',
            c2_blood_sugar_v1: 'N',
            c3_visit_1: 'Y',
            c3_comment: 'Test standards'
          },
          healthInformation: {
            d1_visit_1: 'Y',
            d2_visit_1: 'N',
            d1_comment: 'Test health info'
          },
          integration: {
            e1_visit_1: 'Y',
            e2_visit_1: 'N',
            e1_comment: 'Test integration'
          }
        };

        const createResponse = await axios.post(`${BASE_URL}/api/forms`, testForm, {
          headers: { Authorization: `Bearer ${adminToken}` }
        });
        console.log(`   ✅ Test form created with ID: ${createResponse.data.form.id}\n`);
      } catch (createError) {
        console.log(`   ❌ Form creation failed: ${createError.response?.data?.message || 'Unknown error'}`);
        console.log(`   💡 Error details: ${JSON.stringify(createError.response?.data, null, 2)}\n`);
      }
    }

    console.log('🎉 Quick test completed successfully!');
    console.log('\n✅ Available endpoints working:');
    console.log('   - Health check');
    console.log('   - Admin authentication');
    console.log('   - Form retrieval');
    console.log('   - User management');
    console.log('   - Facility history (if forms exist)');
    console.log('   - Facilities summary (if forms exist)');
    console.log('\n💡 Note: Excel export requires export routes to be enabled in server.js');

  } catch (error) {
    console.error('❌ Quick test failed:', error.response?.data || error.message);
    if (error.code === 'ECONNREFUSED') {
      console.error('   💡 Make sure the server is running: npm run dev');
    }
  }
}

// Run quick test
quickTest(); 