const express = require('express');
const db = require('../config/database');
const { requireAdmin, canModifyResource } = require('../middleware/auth');
const { 
  validateSupervisionForm,
  validateId,
  handleValidationErrors 
} = require('../middleware/validation');

const router = express.Router();

// Get all supervision forms (Admin: all forms, User: only their own)
router.get('/', async (req, res, next) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const offset = (page - 1) * limit;
    const search = req.query.search || '';
    const syncStatus = req.query.syncStatus || '';
    const startDate = req.query.startDate;
    const endDate = req.query.endDate;

    // Build WHERE clause based on user role
    let whereConditions = [];
    let queryParams = [];
    let paramIndex = 1;

    // Role-based filtering
    if (req.user.role !== 'admin') {
      whereConditions.push(`sf.user_id = $${paramIndex}`);
      queryParams.push(req.user.id);
      paramIndex++;
    }

    // Search filter
    if (search) {
      whereConditions.push(`(sf.health_facility_name ILIKE $${paramIndex} OR sf.province ILIKE $${paramIndex} OR sf.district ILIKE $${paramIndex})`);
      queryParams.push(`%${search}%`);
      paramIndex++;
    }

    // Sync status filter
    if (syncStatus) {
      whereConditions.push(`sf.sync_status = $${paramIndex}`);
      queryParams.push(syncStatus);
      paramIndex++;
    }

    // Date range filter
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

    const whereClause = whereConditions.length > 0 ? `WHERE ${whereConditions.join(' AND ')}` : '';

    // Get total count
    const countQuery = `
      SELECT COUNT(*) as total 
      FROM supervision_forms sf
      JOIN users u ON sf.user_id = u.id
      ${whereClause}
    `;
    const countResult = await db.query(countQuery, queryParams);
    const totalForms = parseInt(countResult.rows[0].total);

    // Get forms with user information
    const formsQuery = `
      SELECT 
        sf.id,
        sf.health_facility_name,
        sf.province,
        sf.district,
        sf.visit_1_date,
        sf.visit_2_date,
        sf.visit_3_date,
        sf.visit_4_date,
        sf.form_created_at,
        sf.synced_at,
        sf.last_modified_at,
        sf.sync_status,
        u.username,
        u.full_name as doctor_name
      FROM supervision_forms sf
      JOIN users u ON sf.user_id = u.id
      ${whereClause}
      ORDER BY sf.form_created_at DESC
      LIMIT $${paramIndex} OFFSET $${paramIndex + 1}
    `;
    
    queryParams.push(limit, offset);
    const formsResult = await db.query(formsQuery, queryParams);

    const totalPages = Math.ceil(totalForms / limit);

    res.json({
      forms: formsResult.rows,
      pagination: {
        currentPage: page,
        totalPages,
        totalForms,
        hasNextPage: page < totalPages,
        hasPrevPage: page > 1
      }
    });

  } catch (error) {
    next(error);
  }
});

// Get supervision form by ID
router.get('/:id', validateId, async (req, res, next) => {
  try {
    const formId = parseInt(req.params.id);

    // Build query based on user role
    let userFilter = '';
    let queryParams = [formId];
    
    if (req.user.role !== 'admin') {
      userFilter = 'AND sf.user_id = $2';
      queryParams.push(req.user.id);
    }

    const formQuery = `
      SELECT 
        sf.*,
        u.username,
        u.full_name as doctor_name,
        u.email as doctor_email
      FROM supervision_forms sf
      JOIN users u ON sf.user_id = u.id
      WHERE sf.id = $1 ${userFilter}
    `;

    const formResult = await db.query(formQuery, queryParams);

    if (formResult.rows.length === 0) {
      return res.status(404).json({
        error: 'Not Found',
        message: 'Supervision form not found'
      });
    }

    const form = formResult.rows[0];

    // Get all related form sections
    const sections = await Promise.all([
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
      adminManagement: sections[0],
      logistics: sections[1],
      equipment: sections[2],
      mhdcManagement: sections[3],
      serviceDelivery: sections[4],
      serviceStandards: sections[5],
      healthInformation: sections[6],
      integration: sections[7],
      overallObservations: sections[8]
    };

    res.json({ form: completeForm });

  } catch (error) {
    next(error);
  }
});

// Create new supervision form
router.post('/', validateSupervisionForm, async (req, res, next) => {
  try {
    const {
      healthFacilityName,
      province,
      district,
      visit1Date,
      visit2Date,
      visit3Date,
      visit4Date,
      supervisorSignature,
      facilityRepresentativeSignature,
      recommendationsVisit1,
      recommendationsVisit2,
      recommendationsVisit3,
      recommendationsVisit4,
      // Form sections
      adminManagement,
      logistics,
      equipment,
      mhdcManagement,
      serviceDelivery,
      serviceStandards,
      healthInformation,
      integration,
      overallObservations
      
    } = req.body;

    // Create form within transaction
    const result = await db.transaction(async (client) => {
      // Insert main form
      const formQuery = `
        INSERT INTO supervision_forms (
          user_id, health_facility_name, province, district,
          visit_1_date, visit_2_date, visit_3_date, visit_4_date,
          form_created_at, sync_status,
          supervisor_signature, facility_representative_signature,
          recommendations_visit_1, recommendations_visit_2,
          recommendations_visit_3, recommendations_visit_4
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16)
        RETURNING id, form_created_at
      `;

      const formResult = await client.query(formQuery, [
        req.user.id,
        healthFacilityName,
        province,
        district,
        visit1Date,
        visit2Date,
        visit3Date,
        visit4Date,
        new Date(),
        'local', // New forms start as local
        supervisorSignature,
        facilityRepresentativeSignature,
        recommendationsVisit1,
        recommendationsVisit2,
        recommendationsVisit3,
        recommendationsVisit4
      ]);

      const formId = formResult.rows[0].id;

      // Insert all form sections
      await insertAdminManagementResponses(client, formId, adminManagement);
      await insertLogisticsResponses(client, formId, logistics);
      await insertEquipmentResponses(client, formId, equipment);
      await insertMhdcManagementResponses(client, formId, mhdcManagement);
      await insertServiceDeliveryResponses(client, formId, serviceDelivery);
      await insertServiceStandardsResponses(client, formId, serviceStandards);
      await insertHealthInformationResponses(client, formId, healthInformation);
      await insertIntegrationResponses(client, formId, integration);
      await insertOverallObservationsResponses(client, formId, overallObservations);
      return formResult.rows[0];
    });

    res.status(201).json({
      message: 'Supervision form created successfully',
      form: {
        id: result.id,
        createdAt: result.form_created_at,
        syncStatus: 'local'
      }
    });

  } catch (error) {
    next(error);
  }
});

// Update supervision form (only if not synced for regular users)
router.put('/:id', validateId, async (req, res, next) => {
  try {
    const formId = parseInt(req.params.id);

    // Check if form exists and user has permission
    let userFilter = '';
    let queryParams = [formId];
    
    if (req.user.role !== 'admin') {
      userFilter = 'AND user_id = $2';
      queryParams.push(req.user.id);
    }

    const checkQuery = `
      SELECT id, sync_status, user_id 
      FROM supervision_forms 
      WHERE id = $1 ${userFilter}
    `;

    const checkResult = await db.query(checkQuery, queryParams);

    if (checkResult.rows.length === 0) {
      return res.status(404).json({
        error: 'Not Found',
        message: 'Supervision form not found'
      });
    }

    const existingForm = checkResult.rows[0];

    // Check if user can modify (not synced for regular users)
    if (req.user.role !== 'admin' && existingForm.sync_status !== 'local') {
      return res.status(403).json({
        error: 'Forbidden',
        message: 'Cannot modify synced forms. Only local forms can be edited.'
      });
    }

    const {
      healthFacilityName,
      province,
      district,
      visit1Date,
      visit2Date,
      visit3Date,
      visit4Date,
      supervisorSignature,
      facilityRepresentativeSignature,
      recommendationsVisit1,
      recommendationsVisit2,
      recommendationsVisit3,
      recommendationsVisit4,
      // Form sections
      adminManagement,
      logistics,
      equipment,
      mhdcManagement,
      serviceDelivery,
      serviceStandards,
      healthInformation,
      integration
    } = req.body;

    // Update form within transaction
    await db.transaction(async (client) => {
      // Update main form
      const updateQuery = `
        UPDATE supervision_forms SET
          health_facility_name = $1,
          province = $2,
          district = $3,
          visit_1_date = $4,
          visit_2_date = $5,
          visit_3_date = $6,
          visit_4_date = $7,
          supervisor_signature = $8,
          facility_representative_signature = $9,
          recommendations_visit_1 = $10,
          recommendations_visit_2 = $11,
          recommendations_visit_3 = $12,
          recommendations_visit_4 = $13,
          last_modified_at = CURRENT_TIMESTAMP
        WHERE id = $14
      `;

      await client.query(updateQuery, [
        healthFacilityName,
        province,
        district,
        visit1Date,
        visit2Date,
        visit3Date,
        visit4Date,
        supervisorSignature,
        facilityRepresentativeSignature,
        recommendationsVisit1,
        recommendationsVisit2,
        recommendationsVisit3,
        recommendationsVisit4,
        formId
      ]);

      // Delete existing section responses
      await client.query('DELETE FROM admin_management_responses WHERE form_id = $1', [formId]);
      await client.query('DELETE FROM logistics_responses WHERE form_id = $1', [formId]);
      await client.query('DELETE FROM equipment_responses WHERE form_id = $1', [formId]);
      await client.query('DELETE FROM mhdc_management_responses WHERE form_id = $1', [formId]);
      await client.query('DELETE FROM service_delivery_responses WHERE form_id = $1', [formId]);
      await client.query('DELETE FROM service_standards_responses WHERE form_id = $1', [formId]);
      await client.query('DELETE FROM health_information_responses WHERE form_id = $1', [formId]);
      await client.query('DELETE FROM integration_responses WHERE form_id = $1', [formId]);
      await client.query('DELETE FROM overall_observations_responses WHERE form_id = $1', [formId]);
      // Insert updated sections
      if (adminManagement) await insertAdminManagementResponses(client, formId, adminManagement);
      if (logistics) await insertLogisticsResponses(client, formId, logistics);
      if (equipment) await insertEquipmentResponses(client, formId, equipment);
      if (mhdcManagement) await insertMhdcManagementResponses(client, formId, mhdcManagement);
      if (serviceDelivery) await insertServiceDeliveryResponses(client, formId, serviceDelivery);
      if (serviceStandards) await insertServiceStandardsResponses(client, formId, serviceStandards);
      if (healthInformation) await insertHealthInformationResponses(client, formId, healthInformation);
      if (integration) await insertIntegrationResponses(client, formId, integration);
      if (overallObservations) await insertOverallObservationsResponses(client, formId, overallObservations);
    });

    res.json({
      message: 'Supervision form updated successfully',
      formId: formId
    });

  } catch (error) {
    next(error);
  }
});

// Delete supervision form (only if not synced for regular users)
router.delete('/:id', validateId, async (req, res, next) => {
  try {
    const formId = parseInt(req.params.id);

    // Check if form exists and user has permission
    let userFilter = '';
    let queryParams = [formId];
    
    if (req.user.role !== 'admin') {
      userFilter = 'AND user_id = $2';
      queryParams.push(req.user.id);
    }

    const checkQuery = `
      SELECT id, sync_status, health_facility_name 
      FROM supervision_forms 
      WHERE id = $1 ${userFilter}
    `;

    const checkResult = await db.query(checkQuery, queryParams);

    if (checkResult.rows.length === 0) {
      return res.status(404).json({
        error: 'Not Found',
        message: 'Supervision form not found'
      });
    }

    const existingForm = checkResult.rows[0];

    // Check if user can delete (not synced for regular users)
    if (req.user.role !== 'admin' && existingForm.sync_status !== 'local') {
      return res.status(403).json({
        error: 'Forbidden',
        message: 'Cannot delete synced forms. Only local forms can be deleted.'
      });
    }

    // Delete form (CASCADE will delete related sections)
    await db.query('DELETE FROM supervision_forms WHERE id = $1', [formId]);

    res.json({
      message: 'Supervision form deleted successfully',
      deletedForm: {
        id: formId,
        facilityName: existingForm.health_facility_name
      }
    });

  } catch (error) {
    next(error);
  }
});

// Get facility history for supervisor (all visits to specific facility)
router.get('/facility/:facilityName/history', async (req, res, next) => {
  try {
    const facilityName = decodeURIComponent(req.params.facilityName);
    const userId = req.user.id;

    // Get all visits to this specific facility by this supervisor
    const historyQuery = `
      SELECT 
        sf.id,
        sf.health_facility_name,
        sf.province,
        sf.district,
        sf.visit_1_date,
        sf.visit_2_date,
        sf.visit_3_date,
        sf.visit_4_date,
        sf.form_created_at,
        sf.synced_at,
        sf.sync_status,
        sf.recommendations_visit_1,
        sf.recommendations_visit_2,
        sf.recommendations_visit_3,
        sf.recommendations_visit_4,
        u.full_name as doctor_name
      FROM supervision_forms sf
      JOIN users u ON sf.user_id = u.id
      WHERE sf.user_id = $1 
        AND sf.health_facility_name ILIKE $2
      ORDER BY sf.form_created_at DESC
    `;

    const historyResult = await db.query(historyQuery, [userId, `%${facilityName}%`]);

    if (historyResult.rows.length === 0) {
      return res.status(404).json({
        error: 'Not Found',
        message: `No previous visits found for facility: ${facilityName}`
      });
    }

    // Get detailed data for each visit
    const detailedHistory = [];
    for (const visit of historyResult.rows) {
      const visitDetails = {
        ...visit,
        adminManagement: await getAdminManagementResponses(visit.id),
        logistics: await getLogisticsResponses(visit.id),
        equipment: await getEquipmentResponses(visit.id),
        mhdcManagement: await getMhdcManagementResponses(visit.id),
        serviceDelivery: await getServiceDeliveryResponses(visit.id),
        serviceStandards: await getServiceStandardsResponses(visit.id),
        healthInformation: await getHealthInformationResponses(visit.id),
        integration: await getIntegrationResponses(visit.id),
        overallObservations: await getOverallObservationsResponses(visit.id)
      };
      detailedHistory.push(visitDetails);
    }

    // Calculate improvement trends
    const trends = calculateFacilityTrends(detailedHistory);

    res.json({
      facilityName,
      totalVisits: detailedHistory.length,
      visitHistory: detailedHistory,
      trends: trends,
      lastVisit: detailedHistory[0]?.form_created_at,
      firstVisit: detailedHistory[detailedHistory.length - 1]?.form_created_at
    });

  } catch (error) {
    next(error);
  }
});

// Get supervisor's facility summary (all facilities they've visited)
router.get('/facilities/summary', async (req, res, next) => {
  try {
    const userId = req.user.id;

    // Get summary of all facilities visited by this supervisor
    const summaryQuery = `
      SELECT 
        sf.health_facility_name,
        sf.province,
        sf.district,
        COUNT(*) as visit_count,
        MAX(sf.form_created_at) as last_visit_date,
        MIN(sf.form_created_at) as first_visit_date,
        MAX(sf.sync_status) as latest_sync_status
      FROM supervision_forms sf
      WHERE sf.user_id = $1
      GROUP BY sf.health_facility_name, sf.province, sf.district
      ORDER BY last_visit_date DESC
    `;

    const summaryResult = await db.query(summaryQuery, [userId]);

    // Calculate overall statistics
    const totalFacilities = summaryResult.rows.length;
    const totalVisits = summaryResult.rows.reduce((sum, facility) => sum + parseInt(facility.visit_count), 0);
    const averageVisitsPerFacility = totalFacilities > 0 ? (totalVisits / totalFacilities).toFixed(1) : 0;

    res.json({
      supervisorId: userId,
      summary: {
        totalFacilities,
        totalVisits,
        averageVisitsPerFacility,
        facilitiesVisited: summaryResult.rows.map(facility => ({
          facilityName: facility.health_facility_name,
          province: facility.province,
          district: facility.district,
          visitCount: parseInt(facility.visit_count),
          lastVisitDate: facility.last_visit_date,
          firstVisitDate: facility.first_visit_date,
          latestSyncStatus: facility.latest_sync_status,
          daysSinceLastVisit: Math.floor((new Date() - new Date(facility.last_visit_date)) / (1000 * 60 * 60 * 24))
        }))
      }
    });

  } catch (error) {
    next(error);
  }
});

// Helper functions for section operations
async function getAdminManagementResponses(formId) {
  const result = await db.query('SELECT * FROM admin_management_responses WHERE form_id = $1', [formId]);
  return result.rows[0] || null;
}

async function insertAdminManagementResponses(client, formId, data) {
  if (!data) return;
  
  const query = `
    INSERT INTO admin_management_responses (
      form_id, a1_visit_1, a1_visit_2, a1_visit_3, a1_visit_4, a1_comment,
      a2_visit_1, a2_visit_2, a2_visit_3, a2_visit_4, a2_comment,
      a3_visit_1, a3_visit_2, a3_visit_3, a3_visit_4, a3_comment
    ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16)
  `;
  
  return client.query(query, [
    formId,
    data.a1_visit_1, data.a1_visit_2, data.a1_visit_3, data.a1_visit_4, data.a1_comment,
    data.a2_visit_1, data.a2_visit_2, data.a2_visit_3, data.a2_visit_4, data.a2_comment,
    data.a3_visit_1, data.a3_visit_2, data.a3_visit_3, data.a3_visit_4, data.a3_comment
  ]);
}

// Similar helper functions for other sections (logistics, equipment, etc.)
// [Additional helper functions would follow the same pattern]
// Helper functions for getting form sections (already partially in forms.js)
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
  
  // Helper functions for inserting form sections
  async function insertLogisticsResponses(client, formId, data) {
    if (!data) return;
    
    const query = `
      INSERT INTO logistics_responses (
        form_id, b1_visit_1, b1_visit_2, b1_visit_3, b1_visit_4, b1_comment,
        amlodipine_5_10mg_v1, amlodipine_5_10mg_v2, amlodipine_5_10mg_v3, amlodipine_5_10mg_v4,
        enalapril_2_5_10mg_v1, enalapril_2_5_10mg_v2, enalapril_2_5_10mg_v3, enalapril_2_5_10mg_v4,
        losartan_25_50mg_v1, losartan_25_50mg_v2, losartan_25_50mg_v3, losartan_25_50mg_v4,
        hydrochlorothiazide_12_5_25mg_v1, hydrochlorothiazide_12_5_25mg_v2, hydrochlorothiazide_12_5_25mg_v3, hydrochlorothiazide_12_5_25mg_v4,
        chlorthalidone_6_25_12_5mg_v1, chlorthalidone_6_25_12_5mg_v2, chlorthalidone_6_25_12_5mg_v3, chlorthalidone_6_25_12_5mg_v4,
        atorvastatin_5mg_v1, atorvastatin_5mg_v2, atorvastatin_5mg_v3, atorvastatin_5mg_v4,
        atorvastatin_10mg_v1, atorvastatin_10mg_v2, atorvastatin_10mg_v3, atorvastatin_10mg_v4,
        atorvastatin_20mg_v1, atorvastatin_20mg_v2, atorvastatin_20mg_v3, atorvastatin_20mg_v4,
        other_statins_v1, other_statins_v2, other_statins_v3, other_statins_v4,
        metformin_500mg_v1, metformin_500mg_v2, metformin_500mg_v3, metformin_500mg_v4,
        metformin_1000mg_v1, metformin_1000mg_v2, metformin_1000mg_v3, metformin_1000mg_v4,
        glimepiride_1_2mg_v1, glimepiride_1_2mg_v2, glimepiride_1_2mg_v3, glimepiride_1_2mg_v4,
        gliclazide_40_80mg_v1, gliclazide_40_80mg_v2, gliclazide_40_80mg_v3, gliclazide_40_80mg_v4,
        glipizide_2_5_5mg_v1, glipizide_2_5_5mg_v2, glipizide_2_5_5mg_v3, glipizide_2_5_5mg_v4,
        sitagliptin_50mg_v1, sitagliptin_50mg_v2, sitagliptin_50mg_v3, sitagliptin_50mg_v4,
        pioglitazone_5mg_v1, pioglitazone_5mg_v2, pioglitazone_5mg_v3, pioglitazone_5mg_v4,
        empagliflozin_10mg_v1, empagliflozin_10mg_v2, empagliflozin_10mg_v3, empagliflozin_10mg_v4,
        insulin_soluble_v1, insulin_soluble_v2, insulin_soluble_v3, insulin_soluble_v4,
        insulin_nph_v1, insulin_nph_v2, insulin_nph_v3, insulin_nph_v4,
        other_hypoglycemic_agents_v1, other_hypoglycemic_agents_v2, other_hypoglycemic_agents_v3, other_hypoglycemic_agents_v4,
        dextrose_25_solution_v1, dextrose_25_solution_v2, dextrose_25_solution_v3, dextrose_25_solution_v4,
        aspirin_75mg_v1, aspirin_75mg_v2, aspirin_75mg_v3, aspirin_75mg_v4,
        clopidogrel_75mg_v1, clopidogrel_75mg_v2, clopidogrel_75mg_v3, clopidogrel_75mg_v4,
        metoprolol_succinate_12_5_25_50mg_v1, metoprolol_succinate_12_5_25_50mg_v2, metoprolol_succinate_12_5_25_50mg_v3, metoprolol_succinate_12_5_25_50mg_v4,
        isosorbide_dinitrate_5mg_v1, isosorbide_dinitrate_5mg_v2, isosorbide_dinitrate_5mg_v3, isosorbide_dinitrate_5mg_v4,
        other_drugs_v1, other_drugs_v2, other_drugs_v3, other_drugs_v4,
        b2_visit_1, b2_visit_2, b2_visit_3, b2_visit_4, b2_comment,
        b3_visit_1, b3_visit_2, b3_visit_3, b3_visit_4, b3_comment,
        b4_visit_1, b4_visit_2, b4_visit_3, b4_visit_4, b4_comment,
        b5_visit_1, b5_visit_2, b5_visit_3, b5_visit_4, b5_comment
      ) VALUES (
        $1, $2, $3, $4, $5, $6,
        $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18,
        $19, $20, $21, $22, $23, $24, $25, $26, $27, $28, $29, $30,
        $31, $32, $33, $34, $35, $36, $37, $38, $39, $40, $41, $42,
        $43, $44, $45, $46, $47, $48, $49, $50, $51, $52, $53, $54,
        $55, $56, $57, $58, $59, $60, $61, $62, $63, $64, $65, $66,
        $67, $68, $69, $70, $71, $72, $73, $74, $75, $76, $77, $78,
        $79, $80, $81, $82, $83, $84, $85, $86, $87, $88, $89, $90,
        $91, $92, $93, $94, $95, $96, $97, $98, $99, $100, $101, $102,
        $103, $104, $105, $106, $107, $108, $109, $110, $111, $112, $113, $114,
        $115, $116, $117, $118, $119, $120, $121, $122, $123, $124, $125, $126,
        $127, $128, $129, $130
      )
    `;
    
    return client.query(query, [
      formId,
      data.b1_visit_1 || null, data.b1_visit_2 || null, data.b1_visit_3 || null, data.b1_visit_4 || null, data.b1_comment || null,
      data.amlodipine_5_10mg_v1 || null, data.amlodipine_5_10mg_v2 || null, data.amlodipine_5_10mg_v3 || null, data.amlodipine_5_10mg_v4 || null,
      data.enalapril_2_5_10mg_v1 || null, data.enalapril_2_5_10mg_v2 || null, data.enalapril_2_5_10mg_v3 || null, data.enalapril_2_5_10mg_v4 || null,
      data.losartan_25_50mg_v1 || null, data.losartan_25_50mg_v2 || null, data.losartan_25_50mg_v3 || null, data.losartan_25_50mg_v4 || null,
      data.hydrochlorothiazide_12_5_25mg_v1 || null, data.hydrochlorothiazide_12_5_25mg_v2 || null, data.hydrochlorothiazide_12_5_25mg_v3 || null, data.hydrochlorothiazide_12_5_25mg_v4 || null,
      data.chlorthalidone_6_25_12_5mg_v1 || null, data.chlorthalidone_6_25_12_5mg_v2 || null, data.chlorthalidone_6_25_12_5mg_v3 || null, data.chlorthalidone_6_25_12_5mg_v4 || null,
      data.atorvastatin_5mg_v1 || null, data.atorvastatin_5mg_v2 || null, data.atorvastatin_5mg_v3 || null, data.atorvastatin_5mg_v4 || null,
      data.atorvastatin_10mg_v1 || null, data.atorvastatin_10mg_v2 || null, data.atorvastatin_10mg_v3 || null, data.atorvastatin_10mg_v4 || null,
      data.atorvastatin_20mg_v1 || null, data.atorvastatin_20mg_v2 || null, data.atorvastatin_20mg_v3 || null, data.atorvastatin_20mg_v4 || null,
      data.other_statins_v1 || null, data.other_statins_v2 || null, data.other_statins_v3 || null, data.other_statins_v4 || null,
      data.metformin_500mg_v1 || null, data.metformin_500mg_v2 || null, data.metformin_500mg_v3 || null, data.metformin_500mg_v4 || null,
      data.metformin_1000mg_v1 || null, data.metformin_1000mg_v2 || null, data.metformin_1000mg_v3 || null, data.metformin_1000mg_v4 || null,
      data.glimepiride_1_2mg_v1 || null, data.glimepiride_1_2mg_v2 || null, data.glimepiride_1_2mg_v3 || null, data.glimepiride_1_2mg_v4 || null,
      data.gliclazide_40_80mg_v1 || null, data.gliclazide_40_80mg_v2 || null, data.gliclazide_40_80mg_v3 || null, data.gliclazide_40_80mg_v4 || null,
      data.glipizide_2_5_5mg_v1 || null, data.glipizide_2_5_5mg_v2 || null, data.glipizide_2_5_5mg_v3 || null, data.glipizide_2_5_5mg_v4 || null,
      data.sitagliptin_50mg_v1 || null, data.sitagliptin_50mg_v2 || null, data.sitagliptin_50mg_v3 || null, data.sitagliptin_50mg_v4 || null,
      data.pioglitazone_5mg_v1 || null, data.pioglitazone_5mg_v2 || null, data.pioglitazone_5mg_v3 || null, data.pioglitazone_5mg_v4 || null,
      data.empagliflozin_10mg_v1 || null, data.empagliflozin_10mg_v2 || null, data.empagliflozin_10mg_v3 || null, data.empagliflozin_10mg_v4 || null,
      data.insulin_soluble_v1 || null, data.insulin_soluble_v2 || null, data.insulin_soluble_v3 || null, data.insulin_soluble_v4 || null,
      data.insulin_nph_v1 || null, data.insulin_nph_v2 || null, data.insulin_nph_v3 || null, data.insulin_nph_v4 || null,
      data.other_hypoglycemic_agents_v1 || null, data.other_hypoglycemic_agents_v2 || null, data.other_hypoglycemic_agents_v3 || null, data.other_hypoglycemic_agents_v4 || null,
      data.dextrose_25_solution_v1 || null, data.dextrose_25_solution_v2 || null, data.dextrose_25_solution_v3 || null, data.dextrose_25_solution_v4 || null,
      data.aspirin_75mg_v1 || null, data.aspirin_75mg_v2 || null, data.aspirin_75mg_v3 || null, data.aspirin_75mg_v4 || null,
      data.clopidogrel_75mg_v1 || null, data.clopidogrel_75mg_v2 || null, data.clopidogrel_75mg_v3 || null, data.clopidogrel_75mg_v4 || null,
      data.metoprolol_succinate_12_5_25_50mg_v1 || null, data.metoprolol_succinate_12_5_25_50mg_v2 || null, data.metoprolol_succinate_12_5_25_50mg_v3 || null, data.metoprolol_succinate_12_5_25_50mg_v4 || null,
      data.isosorbide_dinitrate_5mg_v1 || null, data.isosorbide_dinitrate_5mg_v2 || null, data.isosorbide_dinitrate_5mg_v3 || null, data.isosorbide_dinitrate_5mg_v4 || null,
      data.other_drugs_v1 || null, data.other_drugs_v2 || null, data.other_drugs_v3 || null, data.other_drugs_v4 || null,
      data.b2_visit_1 || null, data.b2_visit_2 || null, data.b2_visit_3 || null, data.b2_visit_4 || null, data.b2_comment || null,
      data.b3_visit_1 || null, data.b3_visit_2 || null, data.b3_visit_3 || null, data.b3_visit_4 || null, data.b3_comment || null,
      data.b4_visit_1 || null, data.b4_visit_2 || null, data.b4_visit_3 || null, data.b4_visit_4 || null, data.b4_comment || null,
      data.b5_visit_1 || null, data.b5_visit_2 || null, data.b5_visit_3 || null, data.b5_visit_4 || null, data.b5_comment || null
    ]);
  }
  
  async function insertEquipmentResponses(client, formId, data) {
    if (!data) return;
    
    const query = `
      INSERT INTO equipment_responses (
        form_id, 
        sphygmomanometer_v1, sphygmomanometer_v2, sphygmomanometer_v3, sphygmomanometer_v4,
        weighing_scale_v1, weighing_scale_v2, weighing_scale_v3, weighing_scale_v4,
        measuring_tape_v1, measuring_tape_v2, measuring_tape_v3, measuring_tape_v4,
        peak_expiratory_flow_meter_v1, peak_expiratory_flow_meter_v2, peak_expiratory_flow_meter_v3, peak_expiratory_flow_meter_v4,
        oxygen_v1, oxygen_v2, oxygen_v3, oxygen_v4,
        oxygen_mask_v1, oxygen_mask_v2, oxygen_mask_v3, oxygen_mask_v4,
        nebulizer_v1, nebulizer_v2, nebulizer_v3, nebulizer_v4,
        pulse_oximetry_v1, pulse_oximetry_v2, pulse_oximetry_v3, pulse_oximetry_v4,
        glucometer_v1, glucometer_v2, glucometer_v3, glucometer_v4,
        glucometer_strips_v1, glucometer_strips_v2, glucometer_strips_v3, glucometer_strips_v4,
        lancets_v1, lancets_v2, lancets_v3, lancets_v4,
        urine_dipstick_v1, urine_dipstick_v2, urine_dipstick_v3, urine_dipstick_v4,
        ecg_v1, ecg_v2, ecg_v3, ecg_v4,
        other_equipment_v1, other_equipment_v2, other_equipment_v3, other_equipment_v4
      ) VALUES (
        $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13,
        $14, $15, $16, $17, $18, $19, $20, $21, $22, $23, $24, $25,
        $26, $27, $28, $29, $30, $31, $32, $33, $34, $35, $36, $37,
        $38, $39, $40, $41, $42, $43, $44, $45, $46, $47, $48, $49,
        $50, $51, $52, $53
      )
    `;
    
    return client.query(query, [
      formId,
      data.sphygmomanometer_v1 || null, data.sphygmomanometer_v2 || null, data.sphygmomanometer_v3 || null, data.sphygmomanometer_v4 || null,
      data.weighing_scale_v1 || null, data.weighing_scale_v2 || null, data.weighing_scale_v3 || null, data.weighing_scale_v4 || null,
      data.measuring_tape_v1 || null, data.measuring_tape_v2 || null, data.measuring_tape_v3 || null, data.measuring_tape_v4 || null,
      data.peak_expiratory_flow_meter_v1 || null, data.peak_expiratory_flow_meter_v2 || null, data.peak_expiratory_flow_meter_v3 || null, data.peak_expiratory_flow_meter_v4 || null,
      data.oxygen_v1 || null, data.oxygen_v2 || null, data.oxygen_v3 || null, data.oxygen_v4 || null,
      data.oxygen_mask_v1 || null, data.oxygen_mask_v2 || null, data.oxygen_mask_v3 || null, data.oxygen_mask_v4 || null,
      data.nebulizer_v1 || null, data.nebulizer_v2 || null, data.nebulizer_v3 || null, data.nebulizer_v4 || null,
      data.pulse_oximetry_v1 || null, data.pulse_oximetry_v2 || null, data.pulse_oximetry_v3 || null, data.pulse_oximetry_v4 || null,
      data.glucometer_v1 || null, data.glucometer_v2 || null, data.glucometer_v3 || null, data.glucometer_v4 || null,
      data.glucometer_strips_v1 || null, data.glucometer_strips_v2 || null, data.glucometer_strips_v3 || null, data.glucometer_strips_v4 || null,
      data.lancets_v1 || null, data.lancets_v2 || null, data.lancets_v3 || null, data.lancets_v4 || null,
      data.urine_dipstick_v1 || null, data.urine_dipstick_v2 || null, data.urine_dipstick_v3 || null, data.urine_dipstick_v4 || null,
      data.ecg_v1 || null, data.ecg_v2 || null, data.ecg_v3 || null, data.ecg_v4 || null,
      data.other_equipment_v1 || null, data.other_equipment_v2 || null, data.other_equipment_v3 || null, data.other_equipment_v4 || null
    ]);
  }
  
  async function insertMhdcManagementResponses(client, formId, data) {
    if (!data) return;
    
    const query = `
      INSERT INTO mhdc_management_responses (
        form_id, 
        b6_visit_1, b6_visit_2, b6_visit_3, b6_visit_4, b6_comment,
        b7_visit_1, b7_visit_2, b7_visit_3, b7_visit_4, b7_comment,
        b8_visit_1, b8_visit_2, b8_visit_3, b8_visit_4, b8_comment,
        b9_visit_1, b9_visit_2, b9_visit_3, b9_visit_4, b9_comment,
        b10_visit_1, b10_visit_2, b10_visit_3, b10_visit_4, b10_comment
      ) VALUES (
        $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11,
        $12, $13, $14, $15, $16, $17, $18, $19, $20, $21,
        $22, $23, $24, $25, $26
      )
    `;
    
    return client.query(query, [
      formId,
      data.b6_visit_1 || null, data.b6_visit_2 || null, data.b6_visit_3 || null, data.b6_visit_4 || null, data.b6_comment || null,
      data.b7_visit_1 || null, data.b7_visit_2 || null, data.b7_visit_3 || null, data.b7_visit_4 || null, data.b7_comment || null,
      data.b8_visit_1 || null, data.b8_visit_2 || null, data.b8_visit_3 || null, data.b8_visit_4 || null, data.b8_comment || null,
      data.b9_visit_1 || null, data.b9_visit_2 || null, data.b9_visit_3 || null, data.b9_visit_4 || null, data.b9_comment || null,
      data.b10_visit_1 || null, data.b10_visit_2 || null, data.b10_visit_3 || null, data.b10_visit_4 || null, data.b10_comment || null
    ]);
  }
  
  async function insertServiceDeliveryResponses(client, formId, data) {
    if (!data) return;
    
    const query = `
      INSERT INTO service_delivery_responses (
        form_id, 
        ha_total_staff, ha_mhdc_trained, ha_fen_trained, ha_other_ncd_trained,
        sr_ahw_total_staff, sr_ahw_mhdc_trained, sr_ahw_fen_trained, sr_ahw_other_ncd_trained,
        ahw_total_staff, ahw_mhdc_trained, ahw_fen_trained, ahw_other_ncd_trained,
        sr_anm_total_staff, sr_anm_mhdc_trained, sr_anm_fen_trained, sr_anm_other_ncd_trained,
        anm_total_staff, anm_mhdc_trained, anm_fen_trained, anm_other_ncd_trained,
        others_total_staff, others_mhdc_trained, others_fen_trained, others_other_ncd_trained
      ) VALUES (
        $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13,
        $14, $15, $16, $17, $18, $19, $20, $21, $22, $23, $24, $25
      )
    `;
    
    return client.query(query, [
      formId,
      data.ha_total_staff || null, data.ha_mhdc_trained || null, data.ha_fen_trained || null, data.ha_other_ncd_trained || null,
      data.sr_ahw_total_staff || null, data.sr_ahw_mhdc_trained || null, data.sr_ahw_fen_trained || null, data.sr_ahw_other_ncd_trained || null,
      data.ahw_total_staff || null, data.ahw_mhdc_trained || null, data.ahw_fen_trained || null, data.ahw_other_ncd_trained || null,
      data.sr_anm_total_staff || null, data.sr_anm_mhdc_trained || null, data.sr_anm_fen_trained || null, data.sr_anm_other_ncd_trained || null,
      data.anm_total_staff || null, data.anm_mhdc_trained || null, data.anm_fen_trained || null, data.anm_other_ncd_trained || null,
      data.others_total_staff || null, data.others_mhdc_trained || null, data.others_fen_trained || null, data.others_other_ncd_trained || null
    ]);
  }
  
  async function insertServiceStandardsResponses(client, formId, data) {
    if (!data) return;
    
    const query = `
      INSERT INTO service_standards_responses (
        form_id,
        c2_blood_pressure_v1, c2_blood_pressure_v2, c2_blood_pressure_v3, c2_blood_pressure_v4,
        c2_blood_sugar_v1, c2_blood_sugar_v2, c2_blood_sugar_v3, c2_blood_sugar_v4,
        c2_bmi_measurement_v1, c2_bmi_measurement_v2, c2_bmi_measurement_v3, c2_bmi_measurement_v4,
        c2_waist_circumference_v1, c2_waist_circumference_v2, c2_waist_circumference_v3, c2_waist_circumference_v4,
        c2_cvd_risk_estimation_v1, c2_cvd_risk_estimation_v2, c2_cvd_risk_estimation_v3, c2_cvd_risk_estimation_v4,
        c2_urine_protein_measurement_v1, c2_urine_protein_measurement_v2, c2_urine_protein_measurement_v3, c2_urine_protein_measurement_v4,
        c2_peak_expiratory_flow_rate_v1, c2_peak_expiratory_flow_rate_v2, c2_peak_expiratory_flow_rate_v3, c2_peak_expiratory_flow_rate_v4,
        c2_egfr_calculation_v1, c2_egfr_calculation_v2, c2_egfr_calculation_v3, c2_egfr_calculation_v4,
        c2_brief_intervention_v1, c2_brief_intervention_v2, c2_brief_intervention_v3, c2_brief_intervention_v4,
        c2_foot_examination_v1, c2_foot_examination_v2, c2_foot_examination_v3, c2_foot_examination_v4,
        c2_oral_examination_v1, c2_oral_examination_v2, c2_oral_examination_v3, c2_oral_examination_v4,
        c2_eye_examination_v1, c2_eye_examination_v2, c2_eye_examination_v3, c2_eye_examination_v4,
        c2_health_education_v1, c2_health_education_v2, c2_health_education_v3, c2_health_education_v4,
        c3_visit_1, c3_visit_2, c3_visit_3, c3_visit_4, c3_comment,
        c4_visit_1, c4_visit_2, c4_visit_3, c4_visit_4, c4_comment,
        c5_visit_1, c5_visit_2, c5_visit_3, c5_visit_4, c5_comment,
        c6_visit_1, c6_visit_2, c6_visit_3, c6_visit_4, c6_comment,
        c7_visit_1, c7_visit_2, c7_visit_3, c7_visit_4, c7_comment
      ) VALUES (
        $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13,
        $14, $15, $16, $17, $18, $19, $20, $21, $22, $23, $24, $25,
        $26, $27, $28, $29, $30, $31, $32, $33, $34, $35, $36, $37,
        $38, $39, $40, $41, $42, $43, $44, $45, $46, $47, $48, $49,
        $50, $51, $52, $53, $54, $55, $56, $57, $58, $59, $60, $61,
        $62, $63, $64, $65, $66, $67, $68, $69, $70, $71, $72, $73,
        $74, $75, $76, $77
      )
    `;
    
    return client.query(query, [
      formId,
      data.c2_blood_pressure_v1 || null, data.c2_blood_pressure_v2 || null, data.c2_blood_pressure_v3 || null, data.c2_blood_pressure_v4 || null,
      data.c2_blood_sugar_v1 || null, data.c2_blood_sugar_v2 || null, data.c2_blood_sugar_v3 || null, data.c2_blood_sugar_v4 || null,
      data.c2_bmi_measurement_v1 || null, data.c2_bmi_measurement_v2 || null, data.c2_bmi_measurement_v3 || null, data.c2_bmi_measurement_v4 || null,
      data.c2_waist_circumference_v1 || null, data.c2_waist_circumference_v2 || null, data.c2_waist_circumference_v3 || null, data.c2_waist_circumference_v4 || null,
      data.c2_cvd_risk_estimation_v1 || null, data.c2_cvd_risk_estimation_v2 || null, data.c2_cvd_risk_estimation_v3 || null, data.c2_cvd_risk_estimation_v4 || null,
      data.c2_urine_protein_measurement_v1 || null, data.c2_urine_protein_measurement_v2 || null, data.c2_urine_protein_measurement_v3 || null, data.c2_urine_protein_measurement_v4 || null,
      data.c2_peak_expiratory_flow_rate_v1 || null, data.c2_peak_expiratory_flow_rate_v2 || null, data.c2_peak_expiratory_flow_rate_v3 || null, data.c2_peak_expiratory_flow_rate_v4 || null,
      data.c2_egfr_calculation_v1 || null, data.c2_egfr_calculation_v2 || null, data.c2_egfr_calculation_v3 || null, data.c2_egfr_calculation_v4 || null,
      data.c2_brief_intervention_v1 || null, data.c2_brief_intervention_v2 || null, data.c2_brief_intervention_v3 || null, data.c2_brief_intervention_v4 || null,
      data.c2_foot_examination_v1 || null, data.c2_foot_examination_v2 || null, data.c2_foot_examination_v3 || null, data.c2_foot_examination_v4 || null,
      data.c2_oral_examination_v1 || null, data.c2_oral_examination_v2 || null, data.c2_oral_examination_v3 || null, data.c2_oral_examination_v4 || null,
      data.c2_eye_examination_v1 || null, data.c2_eye_examination_v2 || null, data.c2_eye_examination_v3 || null, data.c2_eye_examination_v4 || null,
      data.c2_health_education_v1 || null, data.c2_health_education_v2 || null, data.c2_health_education_v3 || null, data.c2_health_education_v4 || null,
      data.c3_visit_1 || null, data.c3_visit_2 || null, data.c3_visit_3 || null, data.c3_visit_4 || null, data.c3_comment || null,
      data.c4_visit_1 || null, data.c4_visit_2 || null, data.c4_visit_3 || null, data.c4_visit_4 || null, data.c4_comment || null,
      data.c5_visit_1 || null, data.c5_visit_2 || null, data.c5_visit_3 || null, data.c5_visit_4 || null, data.c5_comment || null,
      data.c6_visit_1 || null, data.c6_visit_2 || null, data.c6_visit_3 || null, data.c6_visit_4 || null, data.c6_comment || null,
      data.c7_visit_1 || null, data.c7_visit_2 || null, data.c7_visit_3 || null, data.c7_visit_4 || null, data.c7_comment || null
    ]);
  }
  
  async function insertHealthInformationResponses(client, formId, data) {
    if (!data) return;
    
    const query = `
      INSERT INTO health_information_responses (
        form_id,
        d1_visit_1, d1_visit_2, d1_visit_3, d1_visit_4, d1_comment,
        d2_visit_1, d2_visit_2, d2_visit_3, d2_visit_4, d2_comment,
        d3_visit_1, d3_visit_2, d3_visit_3, d3_visit_4, d3_comment,
        d4_visit_1, d4_visit_2, d4_visit_3, d4_visit_4, d4_comment,
        d5_visit_1, d5_visit_2, d5_visit_3, d5_visit_4, d5_comment
      ) VALUES (
        $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11,
        $12, $13, $14, $15, $16, $17, $18, $19, $20, $21,
        $22, $23, $24, $25, $26
      )
    `;
    
    return client.query(query, [
      formId,
      data.d1_visit_1 || null, data.d1_visit_2 || null, data.d1_visit_3 || null, data.d1_visit_4 || null, data.d1_comment || null,
      data.d2_visit_1 || null, data.d2_visit_2 || null, data.d2_visit_3 || null, data.d2_visit_4 || null, data.d2_comment || null,
      data.d3_visit_1 || null, data.d3_visit_2 || null, data.d3_visit_3 || null, data.d3_visit_4 || null, data.d3_comment || null,
      data.d4_visit_1 || null, data.d4_visit_2 || null, data.d4_visit_3 || null, data.d4_visit_4 || null, data.d4_comment || null,
      data.d5_visit_1 || null, data.d5_visit_2 || null, data.d5_visit_3 || null, data.d5_visit_4 || null, data.d5_comment || null
    ]);
  }
  
  async function insertIntegrationResponses(client, formId, data) {
    if (!data) return;
    
    const query = `
      INSERT INTO integration_responses (
        form_id,
        e1_visit_1, e1_visit_2, e1_visit_3, e1_visit_4, e1_comment,
        e2_visit_1, e2_visit_2, e2_visit_3, e2_visit_4, e2_comment,
        e3_visit_1, e3_visit_2, e3_visit_3, e3_visit_4, e3_comment
      ) VALUES (
        $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16
      )
    `;
    
    return client.query(query, [
      formId,
      data.e1_visit_1 || null, data.e1_visit_2 || null, data.e1_visit_3 || null, data.e1_visit_4 || null, data.e1_comment || null,
      data.e2_visit_1 || null, data.e2_visit_2 || null, data.e2_visit_3 || null, data.e2_visit_4 || null, data.e2_comment || null,
      data.e3_visit_1 || null, data.e3_visit_2 || null, data.e3_visit_3 || null, data.e3_visit_4 || null, data.e3_comment || null
    ]);
  }

// Helper function to calculate facility improvement trends
function calculateFacilityTrends(visitHistory) {
  if (visitHistory.length < 2) {
    return { message: 'Need at least 2 visits to calculate trends' };
  }

  const trends = {
    medicineAvailability: [],
    equipmentFunctionality: [],
    staffTraining: [],
    serviceQuality: []
  };

  // Calculate trends for each visit
  visitHistory.forEach((visit, index) => {
    if (visit.logistics) {
      // Medicine availability trend
      const medicineScore = calculateMedicineScore(visit.logistics);
      trends.medicineAvailability.push({
        visitNumber: index + 1,
        date: visit.form_created_at,
        score: medicineScore
      });
    }

    if (visit.equipment) {
      // Equipment functionality trend
      const equipmentScore = calculateEquipmentScore(visit.equipment);
      trends.equipmentFunctionality.push({
        visitNumber: index + 1,
        date: visit.form_created_at,
        score: equipmentScore
      });
    }

    if (visit.serviceDelivery) {
      // Staff training trend
      const trainingScore = calculateTrainingScore(visit.serviceDelivery);
      trends.staffTraining.push({
        visitNumber: index + 1,
        date: visit.form_created_at,
        score: trainingScore
      });
    }
  });

  return trends;
}

// Helper functions to calculate scores
function calculateMedicineScore(logistics) {
  // Calculate percentage of available medicines
  const medicineFields = Object.keys(logistics).filter(key => 
    key.includes('mg_v') && !key.includes('comment')
  );
  const availableMedicines = medicineFields.filter(field => 
    logistics[field] === 'Y'
  ).length;
  return Math.round((availableMedicines / medicineFields.length) * 100);
}

function calculateEquipmentScore(equipment) {
  // Calculate percentage of functional equipment
  const equipmentFields = Object.keys(equipment).filter(key => 
    key.includes('_v') && !key.includes('comment')
  );
  const functionalEquipment = equipmentFields.filter(field => 
    equipment[field] === 'Y'
  ).length;
  return Math.round((functionalEquipment / equipmentFields.length) * 100);
}

function calculateTrainingScore(serviceDelivery) {
  // Calculate staff training coverage
  const trainingFields = Object.keys(serviceDelivery).filter(key => 
    key.includes('trained')
  );
  let totalStaff = 0;
  let trainedStaff = 0;
  
  trainingFields.forEach(field => {
    const totalField = field.replace('_trained', '_total_staff');
    totalStaff += serviceDelivery[totalField] || 0;
    trainedStaff += serviceDelivery[field] || 0;
  });
  
  return totalStaff > 0 ? Math.round((trainedStaff / totalStaff) * 100) : 0;
}

async function getOverallObservationsResponses(formId) {
    const result = await db.query('SELECT * FROM overall_observations_responses WHERE form_id = $1', [formId]);
    return result.rows[0] || null;
  }
  
  async function insertOverallObservationsResponses(client, formId, data) {
    if (!data) return;
    
    const query = `
      INSERT INTO overall_observations_responses (
        form_id,
        recommendations_visit_1, recommendations_visit_2, recommendations_visit_3, recommendations_visit_4,
        supervisor_signature_v1, supervisor_signature_v2, supervisor_signature_v3, supervisor_signature_v4,
        facility_representative_signature_v1, facility_representative_signature_v2, 
        facility_representative_signature_v3, facility_representative_signature_v4
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
    `;
    
    return client.query(query, [
      formId,
      data.recommendations_visit_1 || null, data.recommendations_visit_2 || null, 
      data.recommendations_visit_3 || null, data.recommendations_visit_4 || null,
      data.supervisor_signature_v1 || null, data.supervisor_signature_v2 || null, 
      data.supervisor_signature_v3 || null, data.supervisor_signature_v4 || null,
      data.facility_representative_signature_v1 || null, data.facility_representative_signature_v2 || null, 
      data.facility_representative_signature_v3 || null, data.facility_representative_signature_v4 || null
    ]);
  }
module.exports = router;