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

// Add comprehensive medicine inventory sheet
function addMedicineInventorySheet(workbook, forms) {
  const medicineSheet = workbook.addWorksheet('Medicine Inventory');
  
  const headers = ['Form ID', 'Facility', 'Province', 'Medicine', 'Visit 1', 'Visit 2', 'Visit 3', 'Visit 4', 'Availability %'];
  medicineSheet.addRow(headers);
  
  const headerRow = medicineSheet.getRow(1);
  headerRow.font = { bold: true };
  headerRow.fill = {
    type: 'pattern',
    pattern: 'solid',
    fgColor: { argb: 'FFE6E6FA' }
  };
  
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
  
  forms.forEach(form => {
    if (form.logistics) {
      medicines.forEach(medicine => {
        const v1 = form.logistics[`${medicine.key}_v1`];
        const v2 = form.logistics[`${medicine.key}_v2`];
        const v3 = form.logistics[`${medicine.key}_v3`];
        const v4 = form.logistics[`${medicine.key}_v4`];
        
        const visits = [v1, v2, v3, v4].filter(v => v === 'Y' || v === 'N');
        const available = visits.filter(v => v === 'Y').length;
        const availabilityPercent = visits.length > 0 ? ((available / visits.length) * 100).toFixed(1) : 'N/A';
        
        if (visits.length > 0) {
          medicineSheet.addRow([
            form.id,
            form.health_facility_name,
            form.province,
            medicine.name,
            getYNValue(v1),
            getYNValue(v2),
            getYNValue(v3),
            getYNValue(v4),
            `${availabilityPercent}%`
          ]);
        }
      });
    }
  });
}

// Add comprehensive equipment tracking sheet
function addEquipmentTrackingSheet(workbook, forms) {
  const equipmentSheet = workbook.addWorksheet('Equipment Tracking');
  
  const headers = ['Form ID', 'Facility', 'Province', 'Equipment', 'Visit 1', 'Visit 2', 'Visit 3', 'Visit 4', 'Functionality %'];
  equipmentSheet.addRow(headers);
  
  const headerRow = equipmentSheet.getRow(1);
  headerRow.font = { bold: true };
  headerRow.fill = {
    type: 'pattern',
    pattern: 'solid',
    fgColor: { argb: 'FFFFD700' }
  };
  
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
    { key: 'other_equipment', name: 'Other Equipment' }
  ];
  
  forms.forEach(form => {
    if (form.equipment) {
      equipment.forEach(equip => {
        const v1 = form.equipment[`${equip.key}_v1`];
        const v2 = form.equipment[`${equip.key}_v2`];
        const v3 = form.equipment[`${equip.key}_v3`];
        const v4 = form.equipment[`${equip.key}_v4`];
        
        const visits = [v1, v2, v3, v4].filter(v => v === 'Y' || v === 'N');
        const functional = visits.filter(v => v === 'Y').length;
        const functionalityPercent = visits.length > 0 ? ((functional / visits.length) * 100).toFixed(1) : 'N/A';
        
        if (visits.length > 0) {
          equipmentSheet.addRow([
            form.id,
            form.health_facility_name,
            form.province,
            equip.name,
            getYNValue(v1),
            getYNValue(v2),
            getYNValue(v3),
            getYNValue(v4),
            `${functionalityPercent}%`
          ]);
        }
      });
    }
  });
}

// Add detailed staff training matrix
function addStaffTrainingSheet(workbook, forms) {
  const staffSheet = workbook.addWorksheet('Staff Training Matrix');
  
  const headers = [
    'Form ID', 'Facility', 'Province',
    'Staff Category', 'Total Staff', 'MHDC Trained', 'FEN Trained', 'Other NCD Trained',
    'MHDC %', 'FEN %', 'Other NCD %'
  ];
  staffSheet.addRow(headers);
  
  const headerRow = staffSheet.getRow(1);
  headerRow.font = { bold: true };
  headerRow.fill = {
    type: 'pattern',
    pattern: 'solid',
    fgColor: { argb: 'FF90EE90' }
  };
  
  const staffCategories = [
    { key: 'ha', name: 'Health Assistant (HA)' },
    { key: 'sr_ahw', name: 'Senior AHW' },
    { key: 'ahw', name: 'AHW' },
    { key: 'sr_anm', name: 'Senior ANM' },
    { key: 'anm', name: 'ANM' },
    { key: 'others', name: 'Others' }
  ];
  
  forms.forEach(form => {
    if (form.serviceDelivery) {
      staffCategories.forEach(category => {
        const total = form.serviceDelivery[`${category.key}_total_staff`] || 0;
        const mhdc = form.serviceDelivery[`${category.key}_mhdc_trained`] || 0;
        const fen = form.serviceDelivery[`${category.key}_fen_trained`] || 0;
        const other = form.serviceDelivery[`${category.key}_other_ncd_trained`] || 0;
        
        const mhdcPercent = total > 0 ? ((mhdc / total) * 100).toFixed(1) : '0';
        const fenPercent = total > 0 ? ((fen / total) * 100).toFixed(1) : '0';
        const otherPercent = total > 0 ? ((other / total) * 100).toFixed(1) : '0';
        
        if (total > 0) {
          staffSheet.addRow([
            form.id,
            form.health_facility_name,
            form.province,
            category.name,
            total,
            mhdc,
            fen,
            other,
            `${mhdcPercent}%`,
            `${fenPercent}%`,
            `${otherPercent}%`
          ]);
        }
      });
    }
  });
}

// Add detailed service standards sheet
function addServiceStandardsDetailSheet(workbook, forms) {
  const serviceSheet = workbook.addWorksheet('Service Standards Detail');
  
  const headers = ['Form ID', 'Facility', 'Province', 'Service Standard', 'Visit 1', 'Visit 2', 'Visit 3', 'Visit 4', 'Compliance %'];
  serviceSheet.addRow(headers);
  
  const headerRow = serviceSheet.getRow(1);
  headerRow.font = { bold: true };
  headerRow.fill = {
    type: 'pattern',
    pattern: 'solid',
    fgColor: { argb: 'FFADD8E6' }
  };
  
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
    { key: 'c2_health_education', name: 'Health Education' }
  ];
  
  forms.forEach(form => {
    if (form.serviceStandards) {
      serviceStandards.forEach(service => {
        const v1 = form.serviceStandards[`${service.key}_v1`];
        const v2 = form.serviceStandards[`${service.key}_v2`];
        const v3 = form.serviceStandards[`${service.key}_v3`];
        const v4 = form.serviceStandards[`${service.key}_v4`];
        
        const visits = [v1, v2, v3, v4].filter(v => v === 'Y' || v === 'N');
        const compliant = visits.filter(v => v === 'Y').length;
        const compliancePercent = visits.length > 0 ? ((compliant / visits.length) * 100).toFixed(1) : 'N/A';
        
        if (visits.length > 0) {
          serviceSheet.addRow([
            form.id,
            form.health_facility_name,
            form.province,
            service.name,
            getYNValue(v1),
            getYNValue(v2),
            getYNValue(v3),
            getYNValue(v4),
            `${compliancePercent}%`
          ]);
        }
      });
    }
  });
}

// Add visit progression analysis
function addVisitProgressionSheet(workbook, forms) {
  const progressSheet = workbook.addWorksheet('Visit Progression');
  
  const headers = [
    'Form ID', 'Facility', 'Province',
    'Visit 1 Date', 'Visit 2 Date', 'Visit 3 Date', 'Visit 4 Date',
    'Total Visits', 'Days V1-V2', 'Days V2-V3', 'Days V3-V4',
    'Visit 1 Recommendations', 'Visit 2 Recommendations', 'Visit 3 Recommendations', 'Visit 4 Recommendations'
  ];
  progressSheet.addRow(headers);
  
  const headerRow = progressSheet.getRow(1);
  headerRow.font = { bold: true };
  headerRow.fill = {
    type: 'pattern',
    pattern: 'solid',
    fgColor: { argb: 'FFFFA500' }
  };
  
  forms.forEach(form => {
    const v1Date = form.visit_1_date ? new Date(form.visit_1_date) : null;
    const v2Date = form.visit_2_date ? new Date(form.visit_2_date) : null;
    const v3Date = form.visit_3_date ? new Date(form.visit_3_date) : null;
    const v4Date = form.visit_4_date ? new Date(form.visit_4_date) : null;
    
    const totalVisits = [v1Date, v2Date, v3Date, v4Date].filter(d => d !== null).length;
    
    const daysBetween = (date1, date2) => {
      if (!date1 || !date2) return 'N/A';
      return Math.floor((date2 - date1) / (1000 * 60 * 60 * 24));
    };
    
    progressSheet.addRow([
      form.id,
      form.health_facility_name,
      form.province,
      formatDate(form.visit_1_date),
      formatDate(form.visit_2_date),
      formatDate(form.visit_3_date),
      formatDate(form.visit_4_date),
      totalVisits,
      daysBetween(v1Date, v2Date),
      daysBetween(v2Date, v3Date),
      daysBetween(v3Date, v4Date),
      form.recommendations_visit_1 || '',
      form.recommendations_visit_2 || '',
      form.recommendations_visit_3 || '',
      form.recommendations_visit_4 || ''
    ]);
  });
}

// Enhanced main export function
async function enhanceExcelWithDetailedSheets(workbook, forms) {
  console.log(`Enhancing Excel with detailed sheets for ${forms.length} forms`);
  
  addMedicineInventorySheet(workbook, forms);
  addEquipmentTrackingSheet(workbook, forms);
  addStaffTrainingSheet(workbook, forms);
  addServiceStandardsDetailSheet(workbook, forms);
  addVisitProgressionSheet(workbook, forms);
  
  // Add analytics sheet
  const analyticsSheet = workbook.addWorksheet('Analytics & Trends');
  
  const totalForms = forms.length;
  const facilitiesWithAllVisits = forms.filter(f => f.visit_1_date && f.visit_2_date && f.visit_3_date && f.visit_4_date).length;
  const averageVisitsPerFacility = forms.reduce((sum, f) => {
    const visits = [f.visit_1_date, f.visit_2_date, f.visit_3_date, f.visit_4_date].filter(d => d).length;
    return sum + visits;
  }, 0) / totalForms;
  
  analyticsSheet.addRow(['Export Analytics']);
  analyticsSheet.addRow(['']);
  analyticsSheet.addRow(['Total Forms Exported', totalForms]);
  analyticsSheet.addRow(['Facilities with Complete 4 Visits', facilitiesWithAllVisits]);
  analyticsSheet.addRow(['Average Visits per Facility', averageVisitsPerFacility.toFixed(1)]);
  analyticsSheet.addRow(['Export Generated', new Date().toLocaleString()]);
  analyticsSheet.addRow(['']);
  
  // Add filter summary
  analyticsSheet.addRow(['Applied Filters:']);
  analyticsSheet.addRow(['(See filename for filter details)']);
}

// Export all forms to Excel (Admin only)
router.get('/excel', requireAdmin, async (req, res, next) => {
  try {
    const { startDate, endDate, userId, province, district } = req.query;

    // Build WHERE clause
    let whereConditions = [];
    let queryParams = [];
    let paramIndex = 1;

    if (startDate) {
      whereConditions.push(`sf.form_created_at >= $${paramIndex}`);
      queryParams.push(startDate);
      paramIndex++;
    }

    if (endDate) {
      whereConditions.push(`sf.form_created_at <= $${paramIndex}`);
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
    console.log('WHERE clause:', whereClause);
    console.log('Query params:', queryParams);

    // Get all forms with user information
    const formsQuery = `
      SELECT 
        sf.*,
        u.username,
        u.full_name as doctor_name,
        u.email as doctor_email
      FROM supervision_forms sf
      JOIN users u ON sf.user_id = u.id
      ${whereClause}
      ORDER BY sf.form_created_at DESC
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

    // Create Table of Contents sheet
    const tocSheet = workbook.addWorksheet('Table of Contents');
    tocSheet.columns = [
      { header: 'Form ID', key: 'id', width: 15 },
      { header: 'Facility Name', key: 'facility', width: 30 },
      { header: 'Province', key: 'province', width: 20 },
      { header: 'Visit Dates', key: 'visits', width: 40 },
      { header: 'Go to Details', key: 'link', width: 20 }
    ];

    // Style TOC headers
    tocSheet.getRow(1).font = { bold: true };
    tocSheet.getRow(1).fill = {
      type: 'pattern',
      pattern: 'solid',
      fgColor: { argb: 'FFE6E6FA' }
    };

    // Add export info to TOC
    const exportInfo = `Export: ${forms.length} forms | Filters: ${JSON.stringify(req.query)} | Generated: ${new Date().toLocaleString()}`;
    tocSheet.addRow(['']);
    tocSheet.addRow(['Export Info:', exportInfo]);
    tocSheet.addRow(['']);

    // Add TOC entries
    forms.forEach(form => {
      const visitDates = [
        form.visit_1_date ? 'V1' : '',
        form.visit_2_date ? 'V2' : '',
        form.visit_3_date ? 'V3' : '',
        form.visit_4_date ? 'V4' : ''
      ].filter(v => v).join(', ');
      
      const tocRow = tocSheet.addRow({
        id: form.id,
        facility: form.health_facility_name,
        province: form.province,
        visits: visitDates,
        link: `=HYPERLINK("#Form ${form.id} Details!A1", "📋 View Details")`
      });
      
      const linkCell = tocRow.getCell(5);
      linkCell.font = {
        color: { argb: 'FF0000FF' },
        underline: true
      };
    });
    
    // Add navigation links in TOC
    const summaryLinkRow = tocSheet.addRow(['']);
    const summaryLinkCell = summaryLinkRow.getCell(1);
    summaryLinkCell.value = {
      text: '📊 Go to Summary Sheet',
      hyperlink: '#Supervision Forms!A1',
      tooltip: 'Click to view the main summary sheet'
    };
    summaryLinkCell.font = {
      color: { argb: 'FF008000' },
      underline: true,
      bold: true
    };

    // Main forms sheet
    const formsSheet = workbook.addWorksheet('Supervision Forms');
    
    formsSheet.columns = [
      { header: 'Form ID', key: 'id', width: 10 },
      { header: 'Health Facility', key: 'facility', width: 30 },
      { header: 'Province', key: 'province', width: 20 },
      { header: 'District', key: 'district', width: 20 },
      { header: 'Doctor Name', key: 'doctor', width: 25 },
      { header: 'Doctor Email', key: 'email', width: 30 },
      { header: 'Visit 1 Date', key: 'visit1', width: 15 },
      { header: 'Visit 2 Date', key: 'visit2', width: 15 },
      { header: 'Visit 3 Date', key: 'visit3', width: 15 },
      { header: 'Visit 4 Date', key: 'visit4', width: 15 },
      { header: 'Form Created', key: 'created', width: 20 },
      { header: 'Sync Status', key: 'status', width: 15 },
      { header: 'Recommendations Visit 1', key: 'rec1', width: 40 },
      { header: 'Recommendations Visit 2', key: 'rec2', width: 40 },
      { header: 'Recommendations Visit 3', key: 'rec3', width: 40 },
      { header: 'Recommendations Visit 4', key: 'rec4', width: 40 }
    ];

    formsSheet.getRow(1).font = { bold: true };
    formsSheet.getRow(1).fill = {
      type: 'pattern',
      pattern: 'solid',
      fgColor: { argb: 'FFE6E6FA' }
    };

    // Collect detailed form data
    const formsWithDetails = [];
    for (const form of forms) {
      const formId = form.id;
      
      const [
        adminMgmt,
        logistics,
        equipment,
        mhdcMgmt,
        serviceDelivery,
        serviceStandards,
        healthInfo,
        integration,
        overallObs
      ] = await Promise.all([
        getAdminManagementResponses(formId),
        getLogisticsResponses(formId),
        getEquipmentResponses(formId),
        getMhdcManagementResponses(formId),
        getServiceDeliveryResponses(formId),
        getServiceStandardsResponses(formId),
        getHealthInformationResponses(formId),
        getIntegrationResponses(formId),
        getOverallObservationsResponses(formId)
      ]);

      const completeForm = {
        ...form,
        adminManagement: adminMgmt,
        logistics: logistics,
        equipment: equipment,
        mhdcManagement: mhdcMgmt,
        serviceDelivery: serviceDelivery,
        serviceStandards: serviceStandards,
        healthInformation: healthInfo,
        integration: integration,
        overallObservations: overallObs
      };
      
      formsWithDetails.push(completeForm);

      // Add to main summary sheet
      const row = formsSheet.addRow({
        id: `Form ${form.id}`,
        facility: form.health_facility_name,
        province: form.province,
        district: form.district,
        doctor: form.doctor_name,
        email: form.doctor_email,
        visit1: formatDate(form.visit_1_date),
        visit2: formatDate(form.visit_2_date),
        visit3: formatDate(form.visit_3_date),
        visit4: formatDate(form.visit_4_date),
        created: new Date(form.form_created_at).toLocaleString(),
        status: form.sync_status,
        rec1: form.recommendations_visit_1 || '',
        rec2: form.recommendations_visit_2 || '',
        rec3: form.recommendations_visit_3 || '',
        rec4: form.recommendations_visit_4 || ''
      });
      
      const formIdCell = row.getCell(1);
      formIdCell.value = {
        text: `Form ${form.id}`,
        hyperlink: `#Form ${form.id} Details!A1`,
        tooltip: `Click to view detailed data for Form ${form.id}`
      };
      
      formIdCell.font = {
        color: { argb: 'FF0000FF' },
        underline: true,
        bold: true
      };

      // Create detailed sheet for this form
      const detailSheet = workbook.addWorksheet(`Form ${formId} Details`);
      
      const navRow = detailSheet.addRow(['']);
      const backLinkCell = navRow.getCell(1);
      backLinkCell.value = {
        text: 'Back to Summary',
        hyperlink: '#Supervision Forms!A1',
        tooltip: 'Click to return to the main summary sheet'
      };
      backLinkCell.font = {
        color: { argb: 'FF0000FF' },
        underline: true,
        bold: true
      };
      
      const tocLinkCell = navRow.getCell(2);
      tocLinkCell.value = {
        text: 'Table of Contents',
        hyperlink: '#Table of Contents!A1',
        tooltip: 'Click to go to Table of Contents'
      };
      tocLinkCell.font = {
        color: { argb: 'FF008000' },
        underline: true,
        bold: true
      };
      
      const headerData = [
        ['Form ID', formId],
        ['Health Facility', form.health_facility_name],
        ['Province', form.province],
        ['District', form.district],
        ['Doctor', form.doctor_name],
        ['Created Date', new Date(form.form_created_at).toLocaleString()],
        ['Sync Status', form.sync_status],
        ['']
      ];

      headerData.forEach(row => {
        const addedRow = detailSheet.addRow(row);
        if (row[0] && row[1]) {
          addedRow.getCell(1).font = { bold: true };
        }
      });

      addSectionToSheet(detailSheet, 'ADMINISTRATION AND MANAGEMENT', adminMgmt, [
        { key: 'a1', label: 'Health Facility Operation Committee' },
        { key: 'a2', label: 'Committee discusses NCD service provisions' },
        { key: 'a3', label: 'Health facility discusses NCD quarterly' }
      ]);

      addSectionToSheet(detailSheet, 'LOGISTICS', logistics, [
        { key: 'b1', label: 'Essential NCD medicines available' },
        { key: 'b2', label: 'Blood glucometer functioning' },
        { key: 'b3', label: 'Urine protein strips used' },
        { key: 'b4', label: 'Urine ketone strips used' },
        { key: 'b5', label: 'Essential equipment available' }
      ]);

      addSectionToSheet(detailSheet, 'MHDC MANAGEMENT', mhdcMgmt, [
        { key: 'b6', label: 'MHDC NCD management leaflets available' },
        { key: 'b7', label: 'NCD awareness materials available' },
        { key: 'b8', label: 'NCD register availability' },
        { key: 'b9', label: 'WHO-ISH CVD Risk Prediction Chart available' },
        { key: 'b10', label: 'WHO-ISH CVD Risk Chart in use' }
      ]);

      addSectionToSheet(detailSheet, 'SERVICE STANDARDS', serviceStandards, [
        { key: 'c3', label: 'Examination room confidentiality' },
        { key: 'c4', label: 'Home-bound NCD services' },
        { key: 'c5', label: 'Community-based NCD care' },
        { key: 'c6', label: 'School-based NCD prevention' },
        { key: 'c7', label: 'Patient tracking mechanism' }
      ]);

      addSectionToSheet(detailSheet, 'HEALTH INFORMATION', healthInfo, [
        { key: 'd1', label: 'NCD OPD register updated' },
        { key: 'd2', label: 'NCD dashboard updated' },
        { key: 'd3', label: 'Monthly reporting' },
        { key: 'd4', label: 'Number of people seeking NCD services' },
        { key: 'd5', label: 'Dedicated healthcare worker for NCD' }
      ]);

      addSectionToSheet(detailSheet, 'INTEGRATION', integration, [
        { key: 'e1', label: 'Health workers aware of PEN programme' },
        { key: 'e2', label: 'Health education provided' },
        { key: 'e3', label: 'Screening for raised blood pressure/sugar' }
      ]);
      
      addSectionToSheet(detailSheet, 'OVERALL OBSERVATIONS', overallObs, [
        { key: 'recommendations', label: 'Summary of Recommendations' }
      ]);
    }

    // Add enhanced detailed sheets
    await enhanceExcelWithDetailedSheets(workbook, formsWithDetails);

    // Generate dynamic filename
    const fileName = await generateFileName(req);
    
    console.log(`Generating export: ${fileName} for ${forms.length} forms`);
    
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
});

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

    // Set userId in query and redirect to main export
    req.query.userId = userId;
    
    // Forward to main export handler
    return router.get('/excel')(req, res, next);

  } catch (error) {
    next(error);
  }
});

// Export summary statistics
router.get('/summary', requireAdmin, async (req, res, next) => {
  try {
    const statsQuery = `
      SELECT 
        COUNT(*) as total_forms,
        COUNT(DISTINCT user_id) as total_users,
        COUNT(DISTINCT health_facility_name) as total_facilities,
        COUNT(DISTINCT province) as total_provinces,
        COUNT(DISTINCT district) as total_districts,
        COUNT(CASE WHEN sync_status = 'local' THEN 1 END) as local_forms,
        COUNT(CASE WHEN sync_status = 'synced' THEN 1 END) as synced_forms,
        COUNT(CASE WHEN sync_status = 'verified' THEN 1 END) as verified_forms
      FROM supervision_forms
    `;

    const statsResult = await db.query(statsQuery);
    const stats = statsResult.rows[0];

    const provinceQuery = `
      SELECT 
        province,
        COUNT(*) as form_count,
        COUNT(DISTINCT health_facility_name) as facility_count
      FROM supervision_forms
      GROUP BY province
      ORDER BY form_count DESC
    `;

    const provinceResult = await db.query(provinceQuery);

    const recentQuery = `
      SELECT 
        sf.health_facility_name,
        sf.province,
        sf.district,
        u.full_name as doctor_name,
        sf.form_created_at,
        sf.sync_status
      FROM supervision_forms sf
      JOIN users u ON sf.user_id = u.id
      ORDER BY sf.form_created_at DESC
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
        localForms: parseInt(stats.local_forms),
        syncedForms: parseInt(stats.synced_forms),
        verifiedForms: parseInt(stats.verified_forms)
      },
      byProvince: provinceResult.rows.map(row => ({
        province: row.province,
        formCount: parseInt(row.form_count),
        facilityCount: parseInt(row.facility_count)
      })),
      recentActivity: recentResult.rows.map(row => ({
        facilityName: row.health_facility_name,
        province: row.province,
        district: row.district,
        doctorName: row.doctor_name,
        createdAt: row.form_created_at,
        syncStatus: row.sync_status
      }))
    });

  } catch (error) {
    next(error);
  }
});

// Helper function to add section data to Excel sheet
function addSectionToSheet(sheet, sectionTitle, sectionData, fields) {
  if (!sectionData) return;

  const headerRow = sheet.addRow([sectionTitle]);
  headerRow.getCell(1).font = { bold: true, size: 14 };
  headerRow.getCell(1).fill = {
    type: 'pattern',
    pattern: 'solid',
    fgColor: { argb: 'FFCCCCCC' }
  };

  if (sectionTitle === 'OVERALL OBSERVATIONS') {
    const recHeaderRow = sheet.addRow(['Visit', 'Recommendations', 'Supervisor Signature', 'Facility Rep Signature']);
    recHeaderRow.font = { bold: true };

    for (let i = 1; i <= 4; i++) {
      if (sectionData[`recommendations_visit_${i}`] || 
          sectionData[`supervisor_signature_v${i}`] || 
          sectionData[`facility_representative_signature_v${i}`]) {
        sheet.addRow([
          `Visit ${i}`,
          sectionData[`recommendations_visit_${i}`] || '',
          sectionData[`supervisor_signature_v${i}`] || '',
          sectionData[`facility_representative_signature_v${i}`] || ''
        ]);
      }
    }
  } else {
    const fieldHeaderRow = sheet.addRow(['Question', 'Visit 1', 'Visit 2', 'Visit 3', 'Visit 4', 'Comments']);
    fieldHeaderRow.font = { bold: true };

    fields.forEach(field => {
      sheet.addRow([
        field.label,
        getYNValue(sectionData[`${field.key}_visit_1`]),
        getYNValue(sectionData[`${field.key}_visit_2`]),
        getYNValue(sectionData[`${field.key}_visit_3`]),
        getYNValue(sectionData[`${field.key}_visit_4`]),
        sectionData[`${field.key}_comment`] || ''
      ]);
    });
  }

  sheet.addRow([]);
}

// Helper functions to get form section data
async function getAdminManagementResponses(formId) {
  const result = await db.query('SELECT * FROM admin_management_responses WHERE form_id = $1', [formId]);
  return result.rows[0] || null;
}

async function getLogisticsResponses(formId) {
  const result = await db.query('SELECT * FROM logistics_responses WHERE form_id = $1', [formId]);
  return result.rows[0] || null;
}

async function getEquipmentResponses(formId) {
  const result = await db.query('SELECT * FROM equipment_responses WHERE form_id = $1', [formId]);
  return result.rows[0] || null;
}

async function getMhdcManagementResponses(formId) {
  const result = await db.query('SELECT * FROM mhdc_management_responses WHERE form_id = $1', [formId]);
  return result.rows[0] || null;
}

async function getServiceDeliveryResponses(formId) {
  const result = await db.query('SELECT * FROM service_delivery_responses WHERE form_id = $1', [formId]);
  return result.rows[0] || null;
}

async function getServiceStandardsResponses(formId) {
  const result = await db.query('SELECT * FROM service_standards_responses WHERE form_id = $1', [formId]);
  return result.rows[0] || null;
}

async function getHealthInformationResponses(formId) {
  const result = await db.query('SELECT * FROM health_information_responses WHERE form_id = $1', [formId]);
  return result.rows[0] || null;
}

async function getIntegrationResponses(formId) {
  const result = await db.query('SELECT * FROM integration_responses WHERE form_id = $1', [formId]);
  return result.rows[0] || null;
}

async function getOverallObservationsResponses(formId) {
  const result = await db.query('SELECT * FROM overall_observations_responses WHERE form_id = $1', [formId]);
  return result.rows[0] || null;
}

module.exports = router;