const express = require('express');
const ExcelJS = require('exceljs');
const db = require('../config/database');
const { requireAdmin } = require('../middleware/auth');
const { validateExportRequest } = require('../middleware/validation');

const router = express.Router();

// Helper function to format date
const formatDate = (date) => {
  return date ? new Date(date).toISOString().split('T')[0] : '';
};

// Helper function to get Y/N display value
const getYNValue = (value) => {
  if (value === 'Y' || value === 'y') return 'Yes';
  if (value === 'N' || value === 'n') return 'No';
  return '';
};

// Generate dynamic filename based on filters
async function generateFileName(req) {
  const { startDate, endDate, userId, province, district } = req.query;
  let filenameParts = ['supervision_forms'];
  const dateStr = new Date().toISOString().split('T')[0];

  if (startDate || endDate) {
    const start = startDate || 'earliest';
    const end = endDate || 'latest';
    filenameParts.push(`${start}_to_${end}`);
  }

  if (userId) {
    try {
      const userQuery = 'SELECT username FROM users WHERE id = $1';
      const userResult = await db.query(userQuery, [userId]);
      const username = userResult.rows[0]?.username || `user${userId}`;
      filenameParts.push(`user_${username}`);
    } catch (error) {
      filenameParts.push(`user_${userId}`);
    }
  }

  if (province) {
    filenameParts.push(`${province.toLowerCase().replace(/\s+/g, '_')}`);
  }

  if (district) {
    filenameParts.push(`${district.toLowerCase().replace(/\s+/g, '_')}`);
  }

  filenameParts.push(dateStr);
  return `${filenameParts.join('_')}.xlsx`;
}

// Helper function to create a safe worksheet name
function createSafeWorksheetName(facilityName, maxLength = 31) {
  // Remove invalid characters and limit length for Excel worksheet names
  let safeName = facilityName
    .replace(/[\\\/\?\*\[\]]/g, '') // Remove invalid characters
    .replace(/:/g, '-') // Replace colon with dash
    .substring(0, maxLength);
  
  return safeName || 'Facility';
}

// Main export handler function - RESTRUCTURED for facility-based worksheets
async function handleExportRequest(req, res, next) {
  try {
    const { startDate, endDate, userId, province, district } = req.query;

    // Build WHERE clause
    let whereConditions = [];
    let queryParams = [];
    let paramIndex = 1;

    if (startDate) {
      whereConditions.push(`sf.created_at >= $${paramIndex}`);
      queryParams.push(startDate);
      paramIndex++;
    }

    if (endDate) {
      whereConditions.push(`sf.created_at <= $${paramIndex}`);
      queryParams.push(endDate);
      paramIndex++;
    }

    if (userId) {
      whereConditions.push(`sf.user_id = $${paramIndex}`);
      queryParams.push(userId);
      paramIndex++;
    }

    if (province) {
      whereConditions.push(`sf.province ILIKE $${paramIndex}`);
      queryParams.push(`%${province}%`);
      paramIndex++;
    }

    if (district) {
      whereConditions.push(`sf.district ILIKE $${paramIndex}`);
      queryParams.push(`%${district}%`);
      paramIndex++;
    }

    const whereClause = whereConditions.length > 0 ? `WHERE ${whereConditions.join(' AND ')}` : '';

    console.log('Export filters applied:', { startDate, endDate, userId, province, district });

    // Get all forms with visits using the CORRECTED visit-based query
    const formsQuery = `
      SELECT 
        sf.id,
        sf.health_facility_name,
        sf.province,
        sf.district,
        sf.created_at,
        sf.updated_at,
        sf.sync_status,
        u.username,
        u.full_name as doctor_name,
        u.email as doctor_email,
        JSON_AGG(
          CASE 
            WHEN sv.id IS NOT NULL THEN
              JSON_BUILD_OBJECT(
                'visit_id', sv.id,
                'visit_number', sv.visit_number,
                'visit_date', sv.visit_date,
                'recommendations', sv.recommendations,
                'actions_agreed', sv.actions_agreed,
                'supervisor_signature', sv.supervisor_signature,
                'facility_representative_signature', sv.facility_representative_signature,
                'sync_status', sv.sync_status
              )
            ELSE NULL
          END
          ORDER BY sv.visit_number
        ) FILTER (WHERE sv.id IS NOT NULL) as visits
      FROM supervision_forms sf
      JOIN users u ON sf.user_id = u.id
      LEFT JOIN supervision_visits sv ON sf.id = sv.form_id
      ${whereClause}
      GROUP BY sf.id, u.username, u.full_name, u.email
      ORDER BY sf.created_at DESC
    `;

    const formsResult = await db.query(formsQuery, queryParams);
    const forms = formsResult.rows;

    console.log(`Query returned ${forms.length} forms`);

    if (forms.length === 0) {
      return res.status(404).json({
        error: 'Not Found',
        message: 'No supervision forms found matching the criteria'
      });
    }

    // Create Excel workbook
    const workbook = new ExcelJS.Workbook();
    workbook.creator = 'Supervision App';
    workbook.created = new Date();

    // Create overview sheet first
    await createOverviewSheet(workbook, forms);

    // Group forms by facility
    const facilitiesByName = {};
    for (const form of forms) {
      const facilityKey = `${form.health_facility_name}_${form.province}_${form.district}`;
      if (!facilitiesByName[facilityKey]) {
        facilitiesByName[facilityKey] = {
          facilityName: form.health_facility_name,
          province: form.province,
          district: form.district,
          forms: []
        };
      }
      facilitiesByName[facilityKey].forms.push(form);
    }

    // Create individual worksheets for each facility
    for (const [facilityKey, facilityData] of Object.entries(facilitiesByName)) {
      await createFacilityWorksheet(workbook, facilityData);
    }

    // Add overall analytics sheet
    await addOverallAnalyticsSheet(workbook, forms, Object.values(facilitiesByName));

    // Generate dynamic filename
    const fileName = await generateFileName(req);
    
    console.log(`Generating facility-based export: ${fileName} for ${forms.length} forms across ${Object.keys(facilitiesByName).length} facilities`);
    
    res.setHeader(
      'Content-Type',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    );
    res.setHeader('Content-Disposition', `attachment; filename="${fileName}"`);

    await workbook.xlsx.write(res);
    res.end();

  } catch (error) {
    console.error('Export error:', error);
    next(error);
  }
}

// Create overview sheet with all facilities summary
async function createOverviewSheet(workbook, forms) {
  const overviewSheet = workbook.addWorksheet('Facilities Overview');
  
  overviewSheet.columns = [
    { header: 'Facility Name', key: 'facility', width: 35 },
    { header: 'Province', key: 'province', width: 20 },
    { header: 'District', key: 'district', width: 20 },
    { header: 'Doctor Name', key: 'doctor', width: 25 },
    { header: 'Form Created', key: 'created', width: 20 },
    { header: 'Total Visits', key: 'visit_count', width: 15 },
    { header: 'Visit Numbers', key: 'visit_numbers', width: 20 },
    { header: 'Completion %', key: 'completion', width: 15 },
    { header: 'Last Visit Date', key: 'last_visit', width: 20 },
    { header: 'Sync Status', key: 'status', width: 15 }
  ];

  // Style headers
  overviewSheet.getRow(1).font = { bold: true };
  overviewSheet.getRow(1).fill = {
    type: 'pattern',
    pattern: 'solid',
    fgColor: { argb: 'FFE6E6FA' }
  };

  // Add forms data to overview
  forms.forEach(form => {
    const visits = form.visits || [];
    const visitNumbers = visits.map(v => v.visit_number).sort().join(', ');
    const completionPercentage = Math.round((visits.length / 4) * 100);
    const lastVisitDate = visits.length > 0 ? 
      Math.max(...visits.map(v => new Date(v.visit_date).getTime())) : null;
    
    overviewSheet.addRow({
      facility: form.health_facility_name,
      province: form.province,
      district: form.district,
      doctor: form.doctor_name,
      created: new Date(form.created_at).toLocaleString(),
      visit_count: visits.length,
      visit_numbers: visitNumbers,
      completion: `${completionPercentage}%`,
      last_visit: lastVisitDate ? new Date(lastVisitDate).toLocaleDateString() : 'No visits',
      status: form.sync_status
    });
  });
}

// Create individual facility worksheet with all visit details
async function createFacilityWorksheet(workbook, facilityData) {
  const { facilityName, province, district, forms } = facilityData;
  const worksheetName = createSafeWorksheetName(facilityName);
  
  const facilitySheet = workbook.addWorksheet(worksheetName);
  
  // Add facility header information
  facilitySheet.addRow(['FACILITY SUPERVISION REPORT']);
  facilitySheet.addRow(['']);
  facilitySheet.addRow(['Facility Name:', facilityName]);
  facilitySheet.addRow(['Province:', province]);
  facilitySheet.addRow(['District:', district]);
  facilitySheet.addRow(['Export Date:', new Date().toLocaleString()]);
  facilitySheet.addRow(['']);

  // Style facility header
  facilitySheet.getCell('A1').font = { bold: true, size: 16 };
  facilitySheet.getCell('A3').font = { bold: true };
  facilitySheet.getCell('A4').font = { bold: true };
  facilitySheet.getCell('A5').font = { bold: true };
  facilitySheet.getCell('A6').font = { bold: true };

  let currentRow = 8;

  // Process each form for this facility
  for (const form of forms) {
    // Add form header
    facilitySheet.addRow(['']);
    facilitySheet.addRow([`FORM ID: ${form.id} | Doctor: ${form.doctor_name} | Created: ${new Date(form.created_at).toLocaleDateString()}`]);
    facilitySheet.addRow(['']);
    
    const formHeaderRow = facilitySheet.getRow(currentRow + 2);
    formHeaderRow.font = { bold: true };
    formHeaderRow.fill = {
      type: 'pattern',
      pattern: 'solid',
      fgColor: { argb: 'FFFFD700' }
    };

    currentRow += 3;

    if (!form.visits || form.visits.length === 0) {
      facilitySheet.addRow(['No visits recorded for this form']);
      currentRow += 2;
      continue;
    }

    // Get enhanced visit data for each visit
    for (const visit of form.visits) {
      const enhancedVisitData = await getEnhancedVisitData(visit.visit_id);
      
      // Add visit header
      facilitySheet.addRow([`VISIT ${visit.visit_number} - Date: ${formatDate(visit.visit_date)}`]);
      const visitHeaderRow = facilitySheet.getRow(currentRow + 1);
      visitHeaderRow.font = { bold: true, color: { argb: 'FF000080' } };
      currentRow += 2;

      // Add visit basic info
      facilitySheet.addRow(['Visit Information:']);
      facilitySheet.addRow(['', 'Recommendations:', visit.recommendations || 'None']);
      facilitySheet.addRow(['', 'Actions Agreed:', visit.actions_agreed || 'None']);
      facilitySheet.addRow(['', 'Supervisor Signature:', visit.supervisor_signature || 'Not signed']);
      facilitySheet.addRow(['', 'Facility Rep Signature:', visit.facility_representative_signature || 'Not signed']);
      facilitySheet.addRow(['', 'Sync Status:', visit.sync_status]);
      facilitySheet.addRow(['']);
      currentRow += 7;

      // Add detailed sections for this visit
      currentRow = await addVisitAdminManagementSection(facilitySheet, currentRow, enhancedVisitData.adminManagement);
      currentRow = await addVisitLogisticsSection(facilitySheet, currentRow, enhancedVisitData.logistics);
      currentRow = await addVisitEquipmentSection(facilitySheet, currentRow, enhancedVisitData.equipment);
      currentRow = await addVisitMhdcManagementSection(facilitySheet, currentRow, enhancedVisitData.mhdcManagement);
      currentRow = await addVisitServiceStandardsSection(facilitySheet, currentRow, enhancedVisitData.serviceStandards);
      currentRow = await addVisitHealthInformationSection(facilitySheet, currentRow, enhancedVisitData.healthInformation);
      currentRow = await addVisitIntegrationSection(facilitySheet, currentRow, enhancedVisitData.integration);
      currentRow = await addVisitMedicineDetailsSection(facilitySheet, currentRow, enhancedVisitData.medicineDetails);
      currentRow = await addVisitPatientVolumesSection(facilitySheet, currentRow, enhancedVisitData.patientVolumes);
      
      // Add separator between visits
      facilitySheet.addRow(['']);
      facilitySheet.addRow(['═══════════════════════════════════════════════════════════════════']);
      facilitySheet.addRow(['']);
      currentRow += 3;
    }

    // Add staff training data (form-level, not visit-level)
    currentRow = await addFormStaffTrainingSection(facilitySheet, currentRow, form.id);
  }

  // Auto-fit columns
  facilitySheet.columns.forEach(column => {
    if (column.width < 15) column.width = 15;
    if (column.width > 50) column.width = 50;
  });
}

// Helper function to get all enhanced visit data
async function getEnhancedVisitData(visitId) {
  const [
    adminMgmt,
    logistics,
    equipment,
    mhdcMgmt,
    serviceStandards,
    healthInfo,
    integration,
    medicineDetails,
    patientVolumes
  ] = await Promise.all([
    getVisitAdminManagementResponses(visitId),
    getVisitLogisticsResponses(visitId),
    getVisitEquipmentResponses(visitId),
    getVisitMhdcManagementResponses(visitId),
    getVisitServiceStandardsResponses(visitId),
    getVisitHealthInformationResponses(visitId),
    getVisitIntegrationResponses(visitId),
    getVisitMedicineDetails(visitId),
    getVisitPatientVolumes(visitId)
  ]);

  return {
    adminManagement: adminMgmt,
    logistics: logistics,
    equipment: equipment,
    mhdcManagement: mhdcMgmt,
    serviceStandards: serviceStandards,
    healthInformation: healthInfo,
    integration: integration,
    medicineDetails: medicineDetails,
    patientVolumes: patientVolumes
  };
}

// Add Admin Management section to facility worksheet
async function addVisitAdminManagementSection(sheet, startRow, adminData) {
  sheet.addRow(['Administrative Management:']);
  let currentRow = startRow + 1;
  
  const adminRow = sheet.getRow(currentRow);
  adminRow.font = { bold: true };
  adminRow.fill = {
    type: 'pattern',
    pattern: 'solid',
    fgColor: { argb: 'FFE6F3FF' }
  };

  if (adminData) {
    const adminFields = [
      { key: 'a1_response', label: 'Governance Committee Active' },
      { key: 'a2_response', label: 'NCD Focal Person Appointed' },
      { key: 'a3_response', label: 'Policy Available' },
      { key: 'a4_response', label: 'SOPs Available' },
      { key: 'a5_response', label: 'Reporting System Functional' },
      { key: 'a6_response', label: 'Budget Allocated' },
      { key: 'a7_response', label: 'Financial Transparency' }
    ];

    adminFields.forEach(field => {
      sheet.addRow(['', field.label + ':', getYNValue(adminData[field.key])]);
      currentRow++;
    });

    if (adminData.actions_agreed) {
      sheet.addRow(['', 'Actions Agreed:', adminData.actions_agreed]);
      currentRow++;
    }
  } else {
    sheet.addRow(['', 'No administrative management data recorded']);
    currentRow++;
  }

  sheet.addRow(['']);
  return currentRow + 1;
}

// Add Logistics section to facility worksheet
async function addVisitLogisticsSection(sheet, startRow, logisticsData) {
  sheet.addRow(['Medicine Logistics & Availability:']);
  let currentRow = startRow + 1;
  
  const logisticsRow = sheet.getRow(currentRow);
  logisticsRow.font = { bold: true };
  logisticsRow.fill = {
    type: 'pattern',
    pattern: 'solid',
    fgColor: { argb: 'FFFFEEE6' }
  };

  if (logisticsData) {
    const medicines = [
      { key: 'amlodipine_5_10mg', name: 'Amlodipine 5/10mg' },
      { key: 'enalapril_2_5_10mg', name: 'Enalapril 2.5/10mg' },
      { key: 'losartan_25_50mg', name: 'Losartan 25/50mg' },
      { key: 'hydrochlorothiazide_12_5_25mg', name: 'Hydrochlorothiazide 12.5/25mg' },
      { key: 'chlorthalidone_6_25_12_5mg', name: 'Chlorthalidone 6.25/12.5mg' },
      { key: 'other_antihypertensives', name: 'Other Antihypertensives' },
      { key: 'atorvastatin_5mg', name: 'Atorvastatin 5mg' },
      { key: 'atorvastatin_10mg', name: 'Atorvastatin 10mg' },
      { key: 'atorvastatin_20mg', name: 'Atorvastatin 20mg' },
      { key: 'other_statins', name: 'Other Statins' },
      { key: 'metformin_500mg', name: 'Metformin 500mg' },
      { key: 'metformin_1000mg', name: 'Metformin 1000mg' },
      { key: 'glimepiride_1_2mg', name: 'Glimepiride 1/2mg' },
      { key: 'gliclazide_40_80mg', name: 'Gliclazide 40/80mg' },
      { key: 'glipizide_2_5_5mg', name: 'Glipizide 2.5/5mg' },
      { key: 'sitagliptin_50mg', name: 'Sitagliptin 50mg' },
      { key: 'pioglitazone_5mg', name: 'Pioglitazone 5mg' },
      { key: 'empagliflozin_10mg', name: 'Empagliflozin 10mg' },
      { key: 'insulin_soluble_inj', name: 'Insulin Soluble Injection' },
      { key: 'insulin_nph_inj', name: 'Insulin NPH Injection' },
      { key: 'other_hypoglycemic_agents', name: 'Other Hypoglycemic Agents' },
      { key: 'dextrose_25_solution', name: 'Dextrose 25% Solution' },
      { key: 'aspirin_75mg', name: 'Aspirin 75mg' },
      { key: 'clopidogrel_75mg', name: 'Clopidogrel 75mg' },
      { key: 'metoprolol_succinate_12_5_25_50mg', name: 'Metoprolol Succinate 12.5/25/50mg' },
      { key: 'isosorbide_dinitrate_5mg', name: 'Isosorbide Dinitrate 5mg' },
      { key: 'other_drugs', name: 'Other Drugs' },
      { key: 'amoxicillin_clavulanic_potassium_625mg', name: 'Amoxicillin Clavulanic Potassium 625mg' },
      { key: 'azithromycin_500mg', name: 'Azithromycin 500mg' },
      { key: 'other_antibiotics', name: 'Other Antibiotics' },
      { key: 'salbutamol_dpi', name: 'Salbutamol DPI' },
      { key: 'salbutamol', name: 'Salbutamol' },
      { key: 'ipratropium', name: 'Ipratropium' },
      { key: 'tiotropium_bromide', name: 'Tiotropium Bromide' },
      { key: 'formoterol', name: 'Formoterol' },
      { key: 'other_bronchodilators', name: 'Other Bronchodilators' },
      { key: 'prednisolone_5_10_20mg', name: 'Prednisolone 5/10/20mg' },
      { key: 'other_steroids_oral', name: 'Other Oral Steroids' }
    ];

    medicines.forEach(medicine => {
      const availability = logisticsData[medicine.key];
      if (availability === 'Y' || availability === 'N') {
        sheet.addRow(['', medicine.name + ':', getYNValue(availability)]);
        currentRow++;
      }
    });

    if (logisticsData.actions_agreed) {
      sheet.addRow(['', 'Actions Agreed:', logisticsData.actions_agreed]);
      currentRow++;
    }
  } else {
    sheet.addRow(['', 'No logistics data recorded']);
    currentRow++;
  }

  sheet.addRow(['']);
  return currentRow + 1;
}

// Add Equipment section to facility worksheet
async function addVisitEquipmentSection(sheet, startRow, equipmentData) {
  sheet.addRow(['Equipment & Infrastructure:']);
  let currentRow = startRow + 1;
  
  const equipmentRow = sheet.getRow(currentRow);
  equipmentRow.font = { bold: true };
  equipmentRow.fill = {
    type: 'pattern',
    pattern: 'solid',
    fgColor: { argb: 'FFFFE6E6' }
  };

  if (equipmentData) {
    const equipment = [
      { key: 'sphygmomanometer', name: 'Sphygmomanometer' },
      { key: 'weighing_scale', name: 'Weighing Scale' },
      { key: 'measuring_tape', name: 'Measuring Tape' },
      { key: 'peak_expiratory_flow_meter', name: 'Peak Expiratory Flow Meter' },
      { key: 'oxygen', name: 'Oxygen' },
      { key: 'oxygen_mask', name: 'Oxygen Mask' },
      { key: 'nebulizer', name: 'Nebulizer' },
      { key: 'pulse_oximetry', name: 'Pulse Oximetry' },
      { key: 'glucometer', name: 'Glucometer' },
      { key: 'glucometer_strips', name: 'Glucometer Strips' },
      { key: 'lancets', name: 'Lancets' },
      { key: 'urine_dipstick', name: 'Urine Dipstick' },
      { key: 'ecg', name: 'ECG Machine' },
      { key: 'stethoscope', name: 'Stethoscope' },
      { key: 'thermometer', name: 'Thermometer' },
      { key: 'examination_table', name: 'Examination Table' },
      { key: 'privacy_screen', name: 'Privacy Screen' },
      { key: 'other_equipment', name: 'Other Equipment' }
    ];

    equipment.forEach(equip => {
      const functionality = equipmentData[equip.key];
      if (functionality === 'Y' || functionality === 'N') {
        sheet.addRow(['', equip.name + ':', getYNValue(functionality)]);
        currentRow++;
      }
    });

    if (equipmentData.actions_agreed) {
      sheet.addRow(['', 'Actions Agreed:', equipmentData.actions_agreed]);
      currentRow++;
    }
  } else {
    sheet.addRow(['', 'No equipment data recorded']);
    currentRow++;
  }

  sheet.addRow(['']);
  return currentRow + 1;
}

// Add MHDC Management section to facility worksheet
async function addVisitMhdcManagementSection(sheet, startRow, mhdcData) {
  sheet.addRow(['MHDC Management:']);
  let currentRow = startRow + 1;
  
  const mhdcRow = sheet.getRow(currentRow);
  mhdcRow.font = { bold: true };
  mhdcRow.fill = {
    type: 'pattern',
    pattern: 'solid',
    fgColor: { argb: 'FFE6FFE6' }
  };

  if (mhdcData) {
    const mhdcFields = [
      { key: 'b1_response', label: 'MHDC Corner Established' },
      { key: 'b2_response', label: 'MHDC Register Maintained' },
      { key: 'b3_response', label: 'MHDC Guidelines Available' },
      { key: 'b4_response', label: 'MHDC Reporting Functional' },
      { key: 'b5_response', label: 'Patient Follow-up System' },
      { key: 'b6_response', label: 'Community Mobilization' },
      { key: 'b7_response', label: 'Referral System Active' }
    ];

    mhdcFields.forEach(field => {
      const value = mhdcData[field.key];
      if (value === 'Y' || value === 'N') {
        sheet.addRow(['', field.label + ':', getYNValue(value)]);
        currentRow++;
      }
    });

    if (mhdcData.actions_agreed) {
      sheet.addRow(['', 'Actions Agreed:', mhdcData.actions_agreed]);
      currentRow++;
    }
  } else {
    sheet.addRow(['', 'No MHDC management data recorded']);
    currentRow++;
  }

  sheet.addRow(['']);
  return currentRow + 1;
}

// Add Service Standards section to facility worksheet
async function addVisitServiceStandardsSection(sheet, startRow, serviceData) {
  sheet.addRow(['Service Standards Compliance:']);
  let currentRow = startRow + 1;
  
  const serviceRow = sheet.getRow(currentRow);
  serviceRow.font = { bold: true };
  serviceRow.fill = {
    type: 'pattern',
    pattern: 'solid',
    fgColor: { argb: 'FFADD8E6' }
  };

  if (serviceData) {
    const serviceStandards = [
      { key: 'c2_blood_pressure', name: 'Blood Pressure Measurement' },
      { key: 'c2_blood_sugar', name: 'Blood Sugar Testing' },
      { key: 'c2_bmi_measurement', name: 'BMI Measurement' },
      { key: 'c2_waist_circumference', name: 'Waist Circumference Measurement' },
      { key: 'c2_cvd_risk_estimation', name: 'CVD Risk Estimation' },
      { key: 'c2_urine_protein_measurement', name: 'Urine Protein Measurement' },
      { key: 'c2_peak_expiratory_flow_rate', name: 'Peak Expiratory Flow Rate' },
      { key: 'c2_egfr_calculation', name: 'eGFR Calculation' },
      { key: 'c2_brief_intervention', name: 'Brief Intervention' },
      { key: 'c2_foot_examination', name: 'Foot Examination' },
      { key: 'c2_oral_examination', name: 'Oral Examination' },
      { key: 'c2_eye_examination', name: 'Eye Examination' },
      { key: 'c2_health_education', name: 'Health Education' },
      { key: 'c3_response', name: 'Examination Room Confidentiality' },
      { key: 'c4_response', name: 'Home-bound NCD Services' },
      { key: 'c5_response', name: 'Community-based NCD Care' },
      { key: 'c6_response', name: 'School-based NCD Prevention' },
      { key: 'c7_response', name: 'Patient Tracking Mechanism' }
    ];

    serviceStandards.forEach(service => {
      const compliance = serviceData[service.key];
      if (compliance === 'Y' || compliance === 'N') {
        sheet.addRow(['', service.name + ':', getYNValue(compliance)]);
        currentRow++;
      }
    });

    if (serviceData.actions_agreed) {
      sheet.addRow(['', 'Actions Agreed:', serviceData.actions_agreed]);
      currentRow++;
    }
  } else {
    sheet.addRow(['', 'No service standards data recorded']);
    currentRow++;
  }

  sheet.addRow(['']);
  return currentRow + 1;
}

// Add Health Information section to facility worksheet
async function addVisitHealthInformationSection(sheet, startRow, healthInfoData) {
  sheet.addRow(['Health Information System:']);
  let currentRow = startRow + 1;
  
  const healthInfoRow = sheet.getRow(currentRow);
  healthInfoRow.font = { bold: true };
  healthInfoRow.fill = {
    type: 'pattern',
    pattern: 'solid',
    fgColor: { argb: 'FFFFE6FF' }
  };

  if (healthInfoData) {
    const healthInfoFields = [
      { key: 'd1_response', label: 'Health Records Management' },
      { key: 'd2_response', label: 'Data Quality Assurance' },
      { key: 'd3_response', label: 'Information Sharing Protocol' },
      { key: 'd4_response', label: 'Digital Health Tools Usage' },
      { key: 'd5_response', label: 'Patient Education Materials' },
      { key: 'd6_response', label: 'Community Health Information' },
      { key: 'd7_response', label: 'Research & Surveillance' }
    ];

    healthInfoFields.forEach(field => {
      const value = healthInfoData[field.key];
      if (value === 'Y' || value === 'N') {
        sheet.addRow(['', field.label + ':', getYNValue(value)]);
        currentRow++;
      }
    });

    if (healthInfoData.actions_agreed) {
      sheet.addRow(['', 'Actions Agreed:', healthInfoData.actions_agreed]);
      currentRow++;
    }
  } else {
    sheet.addRow(['', 'No health information data recorded']);
    currentRow++;
  }

  sheet.addRow(['']);
  return currentRow + 1;
}

// Add Integration section to facility worksheet
async function addVisitIntegrationSection(sheet, startRow, integrationData) {
  sheet.addRow(['Service Integration:']);
  let currentRow = startRow + 1;
  
  const integrationRow = sheet.getRow(currentRow);
  integrationRow.font = { bold: true };
  integrationRow.fill = {
    type: 'pattern',
    pattern: 'solid',
    fgColor: { argb: 'FFFFE6E6' }
  };

  if (integrationData) {
    const integrationFields = [
      { key: 'e1_response', label: 'Primary Healthcare Integration' },
      { key: 'e2_response', label: 'Maternal Health Integration' },
      { key: 'e3_response', label: 'Mental Health Integration' },
      { key: 'e4_response', label: 'Nutrition Services Integration' },
      { key: 'e5_response', label: 'Immunization Integration' },
      { key: 'e6_response', label: 'Emergency Services Integration' },
      { key: 'e7_response', label: 'Community Programs Integration' }
    ];

    integrationFields.forEach(field => {
      const value = integrationData[field.key];
      if (value === 'Y' || value === 'N') {
        sheet.addRow(['', field.label + ':', getYNValue(value)]);
        currentRow++;
      }
    });

    if (integrationData.actions_agreed) {
      sheet.addRow(['', 'Actions Agreed:', integrationData.actions_agreed]);
      currentRow++;
    }
  } else {
    sheet.addRow(['', 'No integration data recorded']);
    currentRow++;
  }

  sheet.addRow(['']);
  return currentRow + 1;
}

// Add Medicine Details section to facility worksheet
async function addVisitMedicineDetailsSection(sheet, startRow, medicineDetails) {
  sheet.addRow(['Medicine Stock Details:']);
  let currentRow = startRow + 1;
  
  const medicineRow = sheet.getRow(currentRow);
  medicineRow.font = { bold: true };
  medicineRow.fill = {
    type: 'pattern',
    pattern: 'solid',
    fgColor: { argb: 'FFF0E68C' }
  };

  if (medicineDetails && medicineDetails.length > 0) {
    // Add medicine details header
    sheet.addRow(['', 'Medicine Name', 'Stock Quantity', 'Expiry Date', 'Notes']);
    const detailHeaderRow = sheet.getRow(currentRow + 1);
    detailHeaderRow.font = { bold: true };
    currentRow += 2;

    medicineDetails.forEach(medicine => {
      sheet.addRow([
        '',
        medicine.medicine_name || '',
        medicine.stock_quantity || '',
        formatDate(medicine.expiry_date) || '',
        medicine.notes || ''
      ]);
      currentRow++;
    });
  } else {
    sheet.addRow(['', 'No medicine stock details recorded']);
    currentRow++;
  }

  sheet.addRow(['']);
  return currentRow + 1;
}

// Add Patient Volumes section to facility worksheet
async function addVisitPatientVolumesSection(sheet, startRow, patientData) {
  sheet.addRow(['Patient Volume Data:']);
  let currentRow = startRow + 1;
  
  const patientRow = sheet.getRow(currentRow);
  patientRow.font = { bold: true };
  patientRow.fill = {
    type: 'pattern',
    pattern: 'solid',
    fgColor: { argb: 'FFDDA0DD' }
  };

  if (patientData) {
    const patientFields = [
      { key: 'hypertension_patients', label: 'Hypertension Patients' },
      { key: 'diabetes_patients', label: 'Diabetes Patients' },
      { key: 'copd_patients', label: 'COPD Patients' },
      { key: 'cvd_patients', label: 'CVD Patients' },
      { key: 'other_ncd_patients', label: 'Other NCD Patients' },
      { key: 'total_monthly_visits', label: 'Total Monthly Visits' },
      { key: 'new_cases_monthly', label: 'New Cases Monthly' },
      { key: 'referrals_made', label: 'Referrals Made' },
      { key: 'referrals_received', label: 'Referrals Received' }
    ];

    patientFields.forEach(field => {
      const value = patientData[field.key];
      if (value !== null && value !== undefined) {
        sheet.addRow(['', field.label + ':', value]);
        currentRow++;
      }
    });
  } else {
    sheet.addRow(['', 'No patient volume data recorded']);
    currentRow++;
  }

  sheet.addRow(['']);
  return currentRow + 1;
}

// Add Staff Training section to facility worksheet (form-level data)
async function addFormStaffTrainingSection(sheet, startRow, formId) {
  sheet.addRow(['Staff Training Matrix:']);
  let currentRow = startRow + 1;
  
  const staffRow = sheet.getRow(currentRow);
  staffRow.font = { bold: true };
  staffRow.fill = {
    type: 'pattern',
    pattern: 'solid',
    fgColor: { argb: 'FF90EE90' }
  };

  try {
    const staffTrainingQuery = `SELECT * FROM form_staff_training WHERE form_id = $1`;
    const staffTrainingResult = await db.query(staffTrainingQuery, [formId]);
    
    if (staffTrainingResult.rows.length > 0) {
      const staffData = staffTrainingResult.rows[0];
      
      // Add staff training header
      sheet.addRow(['', 'Staff Category', 'Total Staff', 'MHDC Trained', 'FEN Trained', 'Other NCD Trained', 'MHDC %', 'FEN %', 'Other NCD %']);
      const trainingHeaderRow = sheet.getRow(currentRow + 1);
      trainingHeaderRow.font = { bold: true };
      currentRow += 2;

      const staffCategories = [
        { key: 'ha', name: 'Health Assistant (HA)' },
        { key: 'sr_ahw', name: 'Senior AHW' },
        { key: 'ahw', name: 'AHW' },
        { key: 'sr_anm', name: 'Senior ANM' },
        { key: 'anm', name: 'ANM' },
        { key: 'others', name: 'Others' }
      ];
      
      staffCategories.forEach(category => {
        const total = staffData[`${category.key}_total_staff`] || 0;
        const mhdc = staffData[`${category.key}_mhdc_trained`] || 0;
        const fen = staffData[`${category.key}_fen_trained`] || 0;
        const other = staffData[`${category.key}_other_ncd_trained`] || 0;
        
        const mhdcPercent = total > 0 ? ((mhdc / total) * 100).toFixed(1) : '0';
        const fenPercent = total > 0 ? ((fen / total) * 100).toFixed(1) : '0';
        const otherPercent = total > 0 ? ((other / total) * 100).toFixed(1) : '0';
        
        if (total > 0) {
          sheet.addRow([
            '',
            category.name,
            total,
            mhdc,
            fen,
            other,
            `${mhdcPercent}%`,
            `${fenPercent}%`,
            `${otherPercent}%`
          ]);
          currentRow++;
        }
      });

      if (staffData.last_mhdc_training_date) {
        sheet.addRow(['', 'Last MHDC Training Date:', formatDate(staffData.last_mhdc_training_date)]);
        currentRow++;
      }
    } else {
      sheet.addRow(['', 'No staff training data recorded']);
      currentRow++;
    }
  } catch (error) {
    console.error('Error fetching staff training data:', error);
    sheet.addRow(['', 'Error loading staff training data']);
    currentRow++;
  }

  sheet.addRow(['']);
  return currentRow + 1;
}

// Add overall analytics sheet
async function addOverallAnalyticsSheet(workbook, forms, facilitiesData) {
  const analyticsSheet = workbook.addWorksheet('Overall Analytics');
  
  const totalForms = forms.length;
  const totalFacilities = facilitiesData.length;
  const totalVisits = forms.reduce((sum, form) => sum + (form.visits ? form.visits.length : 0), 0);
  const facilitiesWithAllVisits = forms.filter(f => 
    f.visits && f.visits.length === 4
  ).length;
  
  const averageVisitsPerFacility = totalForms > 0 ? (totalVisits / totalForms).toFixed(1) : '0';
  
  // Province distribution
  const provinceStats = forms.reduce((acc, form) => {
    acc[form.province] = (acc[form.province] || 0) + 1;
    return acc;
  }, {});
  
  // Completion status distribution
  const completionStats = forms.reduce((acc, form) => {
    const visitCount = form.visits ? form.visits.length : 0;
    if (visitCount === 0) acc.no_visits++;
    else if (visitCount === 4) acc.complete++;
    else acc.in_progress++;
    return acc;
  }, { no_visits: 0, in_progress: 0, complete: 0 });
  
  // Doctor activity
  const doctorStats = forms.reduce((acc, form) => {
    const doctorKey = form.doctor_name;
    if (!acc[doctorKey]) {
      acc[doctorKey] = { forms: 0, visits: 0, facilities: new Set() };
    }
    acc[doctorKey].forms++;
    acc[doctorKey].visits += form.visits ? form.visits.length : 0;
    acc[doctorKey].facilities.add(form.health_facility_name);
    return acc;
  }, {});

  analyticsSheet.addRow(['SUPERVISION FORMS EXPORT ANALYTICS']);
  analyticsSheet.addRow(['']);
  analyticsSheet.addRow(['Export Summary']);
  analyticsSheet.addRow(['Total Forms Exported', totalForms]);
  analyticsSheet.addRow(['Total Facilities', totalFacilities]);
  analyticsSheet.addRow(['Total Visits Recorded', totalVisits]);
  analyticsSheet.addRow(['Facilities with Complete 4 Visits', facilitiesWithAllVisits]);
  analyticsSheet.addRow(['Average Visits per Facility', averageVisitsPerFacility]);
  analyticsSheet.addRow(['Export Generated', new Date().toLocaleString()]);
  analyticsSheet.addRow(['']);
  
  analyticsSheet.addRow(['Forms by Province']);
  Object.entries(provinceStats).forEach(([province, count]) => {
    analyticsSheet.addRow([province, count]);
  });
  analyticsSheet.addRow(['']);
  
  analyticsSheet.addRow(['Completion Status']);
  analyticsSheet.addRow(['No Visits Yet', completionStats.no_visits]);
  analyticsSheet.addRow(['In Progress (1-3 visits)', completionStats.in_progress]);
  analyticsSheet.addRow(['Complete (4 visits)', completionStats.complete]);
  analyticsSheet.addRow(['']);

  analyticsSheet.addRow(['Doctor Activity Summary']);
  analyticsSheet.addRow(['Doctor Name', 'Forms Created', 'Total Visits', 'Facilities Supervised']);
  const doctorHeaderRow = analyticsSheet.getRow(analyticsSheet.rowCount);
  doctorHeaderRow.font = { bold: true };
  
  Object.entries(doctorStats).forEach(([doctor, stats]) => {
    analyticsSheet.addRow([
      doctor,
      stats.forms,
      stats.visits,
      stats.facilities.size
    ]);
  });
  analyticsSheet.addRow(['']);
  
  analyticsSheet.addRow(['Export Structure Notes']);
  analyticsSheet.addRow(['- Each facility has its own worksheet with all visit details']);
  analyticsSheet.addRow(['- Visit data includes all sections: Admin, Logistics, Equipment, etc.']);
  analyticsSheet.addRow(['- Medicine and equipment data shows availability/functionality per visit']);
  analyticsSheet.addRow(['- Staff training data is captured at facility level']);
  analyticsSheet.addRow(['- Actions Agreed shows agreed actions between supervisor and supervisee']);
  
  // Style the analytics sheet
  analyticsSheet.getCell('A1').font = { bold: true, size: 14 };
  analyticsSheet.getCell('A3').font = { bold: true };
  analyticsSheet.getCell('A12').font = { bold: true };
  analyticsSheet.getCell('A17').font = { bold: true };
  analyticsSheet.getCell('A23').font = { bold: true };
  analyticsSheet.getCell('A29').font = { bold: true };
}

// Export all forms to Excel (Admin only) - RESTRUCTURED for facility-based approach
router.get('/excel', requireAdmin, handleExportRequest);

// Export user-specific forms (Users can export their own data)
router.get('/excel/user/:userId', async (req, res, next) => {
  try {
    const userId = parseInt(req.params.userId);
    
    if (req.user.role !== 'admin' && req.user.id !== userId) {
      return res.status(403).json({
        error: 'Forbidden',
        message: 'You can only export your own data'
      });
    }

    // Set userId in query and call the export handler
    req.query.userId = userId;
    return await handleExportRequest(req, res, next);

  } catch (error) {
    next(error);
  }
});

// Export summary statistics
router.get('/summary', requireAdmin, async (req, res, next) => {
  try {
    const statsQuery = `
      SELECT 
        COUNT(DISTINCT sf.id) as total_forms,
        COUNT(DISTINCT sf.user_id) as total_users,
        COUNT(DISTINCT sf.health_facility_name) as total_facilities,
        COUNT(DISTINCT sf.province) as total_provinces,
        COUNT(DISTINCT sf.district) as total_districts,
        COUNT(CASE WHEN sf.sync_status = 'local' THEN 1 END) as local_forms,
        COUNT(CASE WHEN sf.sync_status = 'synced' THEN 1 END) as synced_forms,
        COUNT(CASE WHEN sf.sync_status = 'verified' THEN 1 END) as verified_forms,
        COUNT(sv.id) as total_visits,
        COUNT(CASE WHEN sv.visit_number = 1 THEN 1 END) as visit_1_count,
        COUNT(CASE WHEN sv.visit_number = 2 THEN 1 END) as visit_2_count,
        COUNT(CASE WHEN sv.visit_number = 3 THEN 1 END) as visit_3_count,
        COUNT(CASE WHEN sv.visit_number = 4 THEN 1 END) as visit_4_count
      FROM supervision_forms sf
      LEFT JOIN supervision_visits sv ON sf.id = sv.form_id
    `;

    const statsResult = await db.query(statsQuery);
    const stats = statsResult.rows[0];

    const provinceQuery = `
      SELECT 
        sf.province,
        COUNT(DISTINCT sf.id) as form_count,
        COUNT(DISTINCT sf.health_facility_name) as facility_count,
        COUNT(sv.id) as visit_count
      FROM supervision_forms sf
      LEFT JOIN supervision_visits sv ON sf.id = sv.form_id
      GROUP BY sf.province
      ORDER BY form_count DESC
    `;

    const provinceResult = await db.query(provinceQuery);

    const recentQuery = `
      SELECT 
        sf.health_facility_name,
        sf.province,
        sf.district,
        u.full_name as doctor_name,
        sf.created_at,
        sf.sync_status,
        COUNT(sv.id) as visit_count,
        MAX(sv.visit_date) as last_visit_date
      FROM supervision_forms sf
      JOIN users u ON sf.user_id = u.id
      LEFT JOIN supervision_visits sv ON sf.id = sv.form_id
      GROUP BY sf.id, u.full_name
      ORDER BY sf.created_at DESC
      LIMIT 10
    `;

    const recentResult = await db.query(recentQuery);

    res.json({
      summary: {
        totalForms: parseInt(stats.total_forms),
        totalUsers: parseInt(stats.total_users),
        totalFacilities: parseInt(stats.total_facilities),
        totalProvinces: parseInt(stats.total_provinces),
        totalDistricts: parseInt(stats.total_districts),
        totalVisits: parseInt(stats.total_visits),
        visitBreakdown: {
          visit1: parseInt(stats.visit_1_count),
          visit2: parseInt(stats.visit_2_count),
          visit3: parseInt(stats.visit_3_count),
          visit4: parseInt(stats.visit_4_count)
        },
        syncStatus: {
          local: parseInt(stats.local_forms),
          synced: parseInt(stats.synced_forms),
          verified: parseInt(stats.verified_forms)
        }
      },
      byProvince: provinceResult.rows.map(row => ({
        province: row.province,
        formCount: parseInt(row.form_count),
        facilityCount: parseInt(row.facility_count),
        visitCount: parseInt(row.visit_count)
      })),
      recentActivity: recentResult.rows.map(row => ({
        facilityName: row.health_facility_name,
        province: row.province,
        district: row.district,
        doctorName: row.doctor_name,
        createdAt: row.created_at,
        syncStatus: row.sync_status,
        visitCount: parseInt(row.visit_count),
        lastVisitDate: row.last_visit_date
      }))
    });

  } catch (error) {
    next(error);
  }
});

// Helper functions to get visit section data - SAME AS BEFORE
async function getVisitAdminManagementResponses(visitId) {
  const result = await db.query('SELECT * FROM visit_admin_management_responses WHERE visit_id = $1', [visitId]);
  return result.rows[0] || null;
}

async function getVisitLogisticsResponses(visitId) {
  const result = await db.query('SELECT * FROM visit_logistics_responses WHERE visit_id = $1', [visitId]);
  return result.rows[0] || null;
}

async function getVisitEquipmentResponses(visitId) {
  const result = await db.query('SELECT * FROM visit_equipment_responses WHERE visit_id = $1', [visitId]);
  return result.rows[0] || null;
}

async function getVisitMhdcManagementResponses(visitId) {
  const result = await db.query('SELECT * FROM visit_mhdc_management_responses WHERE visit_id = $1', [visitId]);
  return result.rows[0] || null;
}

async function getVisitServiceStandardsResponses(visitId) {
  const result = await db.query('SELECT * FROM visit_service_standards_responses WHERE visit_id = $1', [visitId]);
  return result.rows[0] || null;
}

async function getVisitHealthInformationResponses(visitId) {
  const result = await db.query('SELECT * FROM visit_health_information_responses WHERE visit_id = $1', [visitId]);
  return result.rows[0] || null;
}

async function getVisitIntegrationResponses(visitId) {
  const result = await db.query('SELECT * FROM visit_integration_responses WHERE visit_id = $1', [visitId]);
  return result.rows[0] || null;
}

async function getVisitMedicineDetails(visitId) {
  const result = await db.query('SELECT * FROM visit_medicine_details WHERE visit_id = $1 ORDER BY medicine_name', [visitId]);
  return result.rows;
}

async function getVisitPatientVolumes(visitId) {
  const result = await db.query('SELECT * FROM visit_patient_volumes WHERE visit_id = $1', [visitId]);
  return result.rows[0] || null;
}

module.exports = router;