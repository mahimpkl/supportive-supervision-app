const axios = require('axios');

const BASE_URL = 'http://localhost:3000';

async function createSampleData() {
  try {
    console.log('🚀 Creating Sample Data for Excel Export Test\n');

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

    // Step 3: Check existing forms
    console.log('3️⃣ Checking existing forms...');
    const formsResponse = await axios.get(`${BASE_URL}/api/forms`, {
      headers: { Authorization: `Bearer ${adminToken}` }
    });
    console.log(`   ✅ Found ${formsResponse.data.forms.length} existing forms\n`);

    // Step 4: Create sample forms if none exist
    if (formsResponse.data.forms.length === 0) {
      console.log('4️⃣ Creating sample supervision forms...');
      
      const sampleForms = [
        {
          healthFacilityName: 'Central Health Post',
          province: 'Bagmati Province',
          district: 'Kathmandu',
          visit1Date: '2024-01-15',
          visit2Date: '2024-02-15',
          recommendationsVisit1: 'Improve medicine availability and staff training',
          recommendationsVisit2: 'Equipment maintenance and protocol updates needed',
          supervisorSignature: 'Dr. John Doe',
          facilityRepresentativeSignature: 'Dr. Jane Smith',
          adminManagement: {
            a1_visit_1: 'Y', a1_visit_2: 'Y',
            a2_visit_1: 'Y', a2_visit_2: 'N',
            a3_visit_1: 'Y', a3_visit_2: 'Y',
            a1_comment: 'Committee functioning well with regular meetings',
            a2_comment: 'Need to improve NCD discussion frequency',
            a3_comment: 'Regular quarterly discussions happening'
          },
          logistics: {
            b1_visit_1: 'Y', b2_visit_1: 'Y',
            b1_comment: 'All medicines available in sufficient quantities',
            b2_comment: 'Equipment properly maintained and functional'
          },
          equipment: {
            sphygmomanometer_v1: 'Y',
            glucometer_v1: 'Y',
            weighing_scale_v1: 'Y'
          },
          mhdcManagement: {
            b6_visit_1: 'Y', b7_visit_1: 'Y',
            b6_comment: 'MHDC materials and charts properly maintained',
            b7_comment: 'Charts updated regularly'
          },
          serviceDelivery: {
            ha_total_staff: 10, ha_mhdc_trained: 8,
            sr_ahw_total_staff: 8, sr_ahw_mhdc_trained: 6
          },
          serviceStandards: {
            c2_blood_pressure_v1: 'Y',
            c2_blood_sugar_v1: 'Y',
            c3_visit_1: 'Y',
            c3_comment: 'All service standards properly implemented'
          },
          healthInformation: {
            d1_visit_1: 'Y', d2_visit_1: 'Y',
            d1_comment: 'Health information systems properly maintained'
          },
          integration: {
            e1_visit_1: 'Y', e2_visit_1: 'Y',
            e1_comment: 'Integration of NCD services well established'
          }
        },
        {
          healthFacilityName: 'District Hospital',
          province: 'Gandaki Province',
          district: 'Pokhara',
          visit1Date: '2024-03-10',
          visit2Date: '2024-04-10',
          recommendationsVisit1: 'Expand NCD services and improve monitoring',
          recommendationsVisit2: 'Continue monitoring and expand services',
          supervisorSignature: 'Dr. Sarah Wilson',
          facilityRepresentativeSignature: 'Dr. Michael Brown',
          adminManagement: {
            a1_visit_1: 'Y', a1_visit_2: 'Y',
            a2_visit_1: 'Y', a2_visit_2: 'Y',
            a3_visit_1: 'Y', a3_visit_2: 'Y',
            a1_comment: 'Excellent committee structure and meetings',
            a2_comment: 'NCD discussions well integrated',
            a3_comment: 'Quarterly reviews happening as scheduled'
          },
          logistics: {
            b1_visit_1: 'Y', b2_visit_1: 'Y',
            b1_comment: 'Medicine availability excellent',
            b2_comment: 'All equipment functional and well maintained'
          },
          equipment: {
            sphygmomanometer_v1: 'Y',
            glucometer_v1: 'Y',
            weighing_scale_v1: 'Y',
            pulse_oximetry_v1: 'Y'
          },
          mhdcManagement: {
            b6_visit_1: 'Y', b7_visit_1: 'Y',
            b6_comment: 'MHDC materials comprehensive and up-to-date',
            b7_comment: 'Charts regularly updated and accessible'
          },
          serviceDelivery: {
            ha_total_staff: 15, ha_mhdc_trained: 12,
            sr_ahw_total_staff: 10, sr_ahw_mhdc_trained: 8
          },
          serviceStandards: {
            c2_blood_pressure_v1: 'Y',
            c2_blood_sugar_v1: 'Y',
            c3_visit_1: 'Y',
            c3_comment: 'All protocols followed correctly'
          },
          healthInformation: {
            d1_visit_1: 'Y', d2_visit_1: 'Y',
            d1_comment: 'Health information systems excellent'
          },
          integration: {
            e1_visit_1: 'Y', e2_visit_1: 'Y',
            e1_comment: 'Excellent integration of NCD services'
          }
        }
      ];

      for (let i = 0; i < sampleForms.length; i++) {
        const form = sampleForms[i];
        console.log(`   Creating form ${i + 1}: ${form.healthFacilityName}`);
        
        try {
          const createResponse = await axios.post(`${BASE_URL}/api/forms`, form, {
            headers: { Authorization: `Bearer ${adminToken}` }
          });
          console.log(`   ✅ Form created with ID: ${createResponse.data.form.id}`);
        } catch (createError) {
          console.log(`   ❌ Form creation failed: ${createError.response?.data?.message || 'Unknown error'}`);
        }
      }
      
      console.log('✅ Sample forms created successfully\n');
    } else {
      console.log('4️⃣ Sample forms already exist, skipping creation\n');
    }

    console.log('🎉 Sample data setup completed!');
    console.log('\n📋 Next steps:');
    console.log('   - Run: node test-export.js');
    console.log('   - This will test the Excel export functionality');
    console.log('   - The export will include all forms with detailed sections');

  } catch (error) {
    console.error('❌ Sample data creation failed:', error.response?.data || error.message);
    if (error.code === 'ECONNREFUSED') {
      console.error('   💡 Make sure the server is running: npm run dev');
    }
  }
}

// Run sample data creation
createSampleData(); 