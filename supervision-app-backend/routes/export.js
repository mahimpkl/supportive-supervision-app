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
      
      // Style the link cell
      const linkCell = tocRow.getCell(5);
      linkCell.font = {
        color: { argb: 'FF0000FF' },
        underline: true
      };
    });
    
    // Add link to summary sheet in TOC
    const summaryLinkRow = tocSheet.addRow(['']);
    const summaryLinkCell = summaryLinkRow.getCell(1);
    summaryLinkCell.value = {
      text: '📊 Go to Summary Sheet',
      hyperlink: '#Supervision Forms!A1',
      tooltip: 'Click to view the main summary sheet'
    };
    summaryLinkCell.font = {
      color: { argb: 'FF008000' }, // Green color
      underline: true,
      bold: true
    };

    // Main forms sheet
    const formsSheet = workbook.addWorksheet('Supervision Forms');
    
    // Define headers for main forms sheet
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

    // Style headers
    formsSheet.getRow(1).font = { bold: true };
    formsSheet.getRow(1).fill = {
      type: 'pattern',
      pattern: 'solid',
      fgColor: { argb: 'FFE6E6FA' }
    };

    // Add form data with clickable links
    forms.forEach((form, index) => {
      const row = formsSheet.addRow({
        id: `Form ${form.id}`,  // Make it clickable
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
      
      // Add hyperlink to Form ID cell
      const formIdCell = row.getCell(1); // First column (Form ID)
      formIdCell.value = {
        text: `Form ${form.id}`,
        hyperlink: `#Form ${form.id} Details!A1`,
        tooltip: `Click to view detailed data for Form ${form.id}`
      };
      
      // Style the hyperlink
      formIdCell.font = {
        color: { argb: 'FF0000FF' }, // Blue color
        underline: true,
        bold: true
      };
    });

    // Get detailed form data for each form
    for (const form of forms) {
      const formId = form.id;
      
      // Get all form sections
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
      

      // Create detailed sheet for this form
      const detailSheet = workbook.addWorksheet(`Form ${formId} Details`);
      
      // Add navigation links
      const navRow = detailSheet.addRow(['']);
      const backLinkCell = navRow.getCell(1);
      backLinkCell.value = {
        text: '🔙 Back to Summary',
        hyperlink: '#Supervision Forms!A1',
        tooltip: 'Click to return to the main summary sheet'
      };
      backLinkCell.font = {
        color: { argb: 'FF0000FF' },
        underline: true,
        bold: true
      };
      
      // Add link to Table of Contents
      const tocLinkCell = navRow.getCell(2);
      tocLinkCell.value = {
        text: '📋 Table of Contents',
        hyperlink: '#Table of Contents!A1',
        tooltip: 'Click to go to Table of Contents'
      };
      tocLinkCell.font = {
        color: { argb: 'FF008000' }, // Green color
        underline: true,
        bold: true
      };
      
      // Add form header information
      const headerData = [
        ['Form ID', formId],
        ['Health Facility', form.health_facility_name],
        ['Province', form.province],
        ['District', form.district],
        ['Doctor', form.doctor_name],
        ['Created Date', new Date(form.form_created_at).toLocaleString()],
        ['Sync Status', form.sync_status],
        [''], // Empty row
      ];

      headerData.forEach(row => {
        const addedRow = detailSheet.addRow(row);
        if (row[0] && row[1]) {
          addedRow.getCell(1).font = { bold: true };
        }
      });

      // Add section data
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
        

    // Generate Excel file
    const fileName = `supervision_forms_export_${new Date().toISOString().split('T')[0]}.xlsx`;
    
    res.setHeader(
      'Content-Type',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    );
    res.setHeader('Content-Disposition', `attachment; filename="${fileName}"`);

    await workbook.xlsx.write(res);
    res.end();

  } catch (error) {
    next(error);
  }
});

// Export user-specific forms (Users can export their own data)
router.get('/excel/user/:userId', async (req, res, next) => {
  try {
    const userId = parseInt(req.params.userId);
    
    // Check if user can access this data
    if (req.user.role !== 'admin' && req.user.id !== userId) {
      return res.status(403).json({
        error: 'Forbidden',
        message: 'You can only export your own data'
      });
    }

    // Redirect to main export with user filter
    req.query.userId = userId;
    return router.handle(req, res, next);

  } catch (error) {
    next(error);
  }
});

// Export summary statistics
router.get('/summary', requireAdmin, async (req, res, next) => {
  try {
    // Get overall statistics
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

    // Get forms by province
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

    // Get recent activity
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
  
    // Add section header
    const headerRow = sheet.addRow([sectionTitle]);
    headerRow.getCell(1).font = { bold: true, size: 14 };
    headerRow.getCell(1).fill = {
      type: 'pattern',
      pattern: 'solid',
      fgColor: { argb: 'FFCCCCCC' }
    };
  
    // Special handling for Overall Observations
    if (sectionTitle === 'OVERALL OBSERVATIONS') {
      // Add recommendations headers
      const recHeaderRow = sheet.addRow(['Visit', 'Recommendations', 'Supervisor Signature', 'Facility Rep Signature']);
      recHeaderRow.font = { bold: true };
  
      // Add recommendations data
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
      // Regular field handling (existing code)
      const fieldHeaderRow = sheet.addRow(['Question', 'Visit 1', 'Visit 2', 'Visit 3', 'Visit 4', 'Comments']);
      fieldHeaderRow.font = { bold: true };
  
      fields.forEach(field => {
        const row = sheet.addRow([
          field.label,
          getYNValue(sectionData[`${field.key}_visit_1`]),
          getYNValue(sectionData[`${field.key}_visit_2`]),
          getYNValue(sectionData[`${field.key}_visit_3`]),
          getYNValue(sectionData[`${field.key}_visit_4`]),
          sectionData[`${field.key}_comment`] || ''
        ]);
      });
    }
  
    // Add empty row
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