const express = require('express');
const db = require('../config/database');
const { requireAdmin } = require('../middleware/auth');
const { body, validationResult } = require('express-validator');

const router = express.Router();

// Validation middleware for sync operations
const validateSyncData = [
  body('forms').isArray().withMessage('Forms must be an array'),
  body('forms.*.tempId').notEmpty().withMessage('Each form must have a tempId'),
  body('forms.*.healthFacilityName').notEmpty().withMessage('Health facility name is required'),
  body('deviceId').notEmpty().withMessage('Device ID is required'),
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation Error',
        message: 'Invalid sync data',
        details: errors.array()
      });
    }
    next();
  }
];

// Upload forms from mobile app (sync from local to server)
router.post('/upload', validateSyncData, async (req, res, next) => {
  try {
    const { forms, deviceId } = req.body;
    const userId = req.user.id;
    const uploadResults = [];
    const errors = [];

    console.log(`📤 Sync upload started for user ${userId}, device ${deviceId}, ${forms.length} forms`);

    for (const formData of forms) {
      const { tempId, ...formContent } = formData;
      
      try {
        // Start transaction for each form
        const result = await db.transaction(async (client) => {
          // Insert main supervision form
          const formQuery = `
            INSERT INTO supervision_forms (
              user_id, health_facility_name, province, district,
              visit_1_date, visit_2_date, visit_3_date, visit_4_date,
              form_created_at, sync_status, synced_at,
              supervisor_signature, facility_representative_signature
            ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, CURRENT_TIMESTAMP, $11, $12)
            RETURNING id, synced_at
          `;

          const formResult = await client.query(formQuery, [
            userId,
            formContent.healthFacilityName,
            formContent.province,
            formContent.district,
            formContent.visit1Date || null,
            formContent.visit2Date || null,
            formContent.visit3Date || null,
            formContent.visit4Date || null,
            formContent.formCreatedAt || new Date(),
            'synced',
            formContent.supervisorSignature || null,
            formContent.facilityRepresentativeSignature || null
          ]);

          const formId = formResult.rows[0].id;

          // Insert form sections if they exist
          if (formContent.adminManagement) {
            await insertAdminManagementResponses(client, formId, formContent.adminManagement);
          }
          if (formContent.logistics) {
            await insertLogisticsResponses(client, formId, formContent.logistics);
          }
          if (formContent.equipment) {
            await insertEquipmentResponses(client, formId, formContent.equipment);
          }
          if (formContent.mhdcManagement) {
            await insertMhdcManagementResponses(client, formId, formContent.mhdcManagement);
          }
          if (formContent.serviceDelivery) {
            await insertServiceDeliveryResponses(client, formId, formContent.serviceDelivery);
          }
          if (formContent.serviceStandards) {
            await insertServiceStandardsResponses(client, formId, formContent.serviceStandards);
          }
          if (formContent.healthInformation) {
            await insertHealthInformationResponses(client, formId, formContent.healthInformation);
          }
          if (formContent.integration) {
            await insertIntegrationResponses(client, formId, formContent.integration);
          }
          if (formContent.overallObservations) {
            await insertOverallObservationsResponses(client, formId, formContent.overallObservations);
          }

          // Log the sync operation
          await client.query(`
            INSERT INTO sync_logs (user_id, form_id, sync_type, device_id, ip_address, user_agent)
            VALUES ($1, $2, $3, $4, $5, $6)
          `, [
            userId,
            formId,
            'upload',
            deviceId,
            req.ip,
            req.get('User-Agent')
          ]);

          return {
            tempId,
            serverId: formId,
            syncedAt: formResult.rows[0].synced_at
          };
        });

        uploadResults.push({
          tempId: result.tempId,
          serverId: result.serverId,
          status: 'success',
          syncedAt: result.syncedAt
        });

        console.log(`✅ Form ${tempId} synced successfully as ID ${result.serverId}`);

      } catch (error) {
        console.error(`❌ Error syncing form ${tempId}:`, error.message);
        
        errors.push({
          tempId,
          status: 'error',
          error: error.message
        });

        // Log failed sync attempt
        try {
          await db.query(`
            INSERT INTO sync_logs (user_id, sync_type, device_id, sync_status, error_message, ip_address, user_agent)
            VALUES ($1, $2, $3, $4, $5, $6, $7)
          `, [
            userId,
            'upload',
            deviceId,
            'failed',
            error.message,
            req.ip,
            req.get('User-Agent')
          ]);
        } catch (logError) {
          console.error('Failed to log sync error:', logError.message);
        }
      }
    }

    const response = {
      message: `Sync completed: ${uploadResults.length} successful, ${errors.length} failed`,
      uploadResults,
      totalForms: forms.length,
      successCount: uploadResults.length,
      errorCount: errors.length
    };

    if (errors.length > 0) {
      response.errors = errors;
    }

    console.log(`📤 Sync upload completed: ${uploadResults.length}/${forms.length} forms synced`);

    res.status(200).json(response);

  } catch (error) {
    console.error('Sync upload error:', error);
    next(error);
  }
});

// Download updates for mobile app (sync from server to local)
router.get('/download', async (req, res, next) => {
  try {
    const userId = req.user.id;
    const lastSyncTime = req.query.lastSync;
    const deviceId = req.query.deviceId;

    console.log(`📥 Sync download requested for user ${userId}, device ${deviceId}`);

    let whereClause = 'WHERE sf.user_id = $1';
    let queryParams = [userId];
    let paramIndex = 2;

    // If lastSync provided, only get forms updated after that time
    if (lastSyncTime) {
      whereClause += ` AND sf.last_modified_at > $${paramIndex}`;
      queryParams.push(lastSyncTime);
      paramIndex++;
    }

    // Get updated supervision forms
    const formsQuery = `
      SELECT 
        sf.*,
        u.username,
        u.full_name as doctor_name
      FROM supervision_forms sf
      JOIN users u ON sf.user_id = u.id
      ${whereClause}
      ORDER BY sf.last_modified_at DESC
      LIMIT 100
    `;

    const formsResult = await db.query(formsQuery, queryParams);
    const updatedForms = [];

    // Get complete form data with all sections
    for (const form of formsResult.rows) {
      const formId = form.id;
      
      const completeForm = {
        ...form,
        adminManagement: await getAdminManagementResponses(formId),
        logistics: await getLogisticsResponses(formId),
        equipment: await getEquipmentResponses(formId),
        mhdcManagement: await getMhdcManagementResponses(formId),
        serviceDelivery: await getServiceDeliveryResponses(formId),
        serviceStandards: await getServiceStandardsResponses(formId),
        healthInformation: await getHealthInformationResponses(formId),
        integration: await getIntegrationResponses(formId),
        overallObservations: await getOverallObservationsResponses(formId)
      };

      updatedForms.push(completeForm);
    }

    // Log the download operation
    if (deviceId) {
      await db.query(`
        INSERT INTO sync_logs (user_id, sync_type, device_id, ip_address, user_agent)
        VALUES ($1, $2, $3, $4, $5)
      `, [
        userId,
        'download',
        deviceId,
        req.ip,
        req.get('User-Agent')
      ]);
    }

    console.log(`📥 Sync download completed: ${updatedForms.length} forms sent`);

    res.json({
      message: `${updatedForms.length} updated forms available`,
      forms: updatedForms,
      syncTime: new Date().toISOString(),
      hasMore: updatedForms.length === 100 // Indicate if there might be more
    });

  } catch (error) {
    console.error('Sync download error:', error);
    next(error);
  }
});

// Get sync status and logs (Admin only)
router.get('/status', requireAdmin, async (req, res, next) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 50;
    const offset = (page - 1) * limit;
    const userId = req.query.userId;
    const syncType = req.query.syncType;
    const syncStatus = req.query.syncStatus;

    // Build where clause
    let whereConditions = [];
    let queryParams = [];
    let paramIndex = 1;

    if (userId) {
      whereConditions.push(`sl.user_id = $${paramIndex}`);
      queryParams.push(userId);
      paramIndex++;
    }

    if (syncType) {
      whereConditions.push(`sl.sync_type = $${paramIndex}`);
      queryParams.push(syncType);
      paramIndex++;
    }

    if (syncStatus) {
      whereConditions.push(`sl.sync_status = $${paramIndex}`);
      queryParams.push(syncStatus);
      paramIndex++;
    }

    const whereClause = whereConditions.length > 0 ? `WHERE ${whereConditions.join(' AND ')}` : '';

    // Get sync logs with user information
    const logsQuery = `
      SELECT 
        sl.*,
        u.username,
        u.full_name,
        sf.health_facility_name
      FROM sync_logs sl
      JOIN users u ON sl.user_id = u.id
      LEFT JOIN supervision_forms sf ON sl.form_id = sf.id
      ${whereClause}
      ORDER BY sl.sync_timestamp DESC
      LIMIT $${paramIndex} OFFSET $${paramIndex + 1}
    `;

    queryParams.push(limit, offset);
    const logsResult = await db.query(logsQuery, queryParams);

    // Get summary statistics
    const statsQuery = `
      SELECT 
        COUNT(*) as total_syncs,
        COUNT(CASE WHEN sync_status = 'completed' THEN 1 END) as successful_syncs,
        COUNT(CASE WHEN sync_status = 'failed' THEN 1 END) as failed_syncs,
        COUNT(CASE WHEN sync_type = 'upload' THEN 1 END) as uploads,
        COUNT(CASE WHEN sync_type = 'download' THEN 1 END) as downloads,
        COUNT(DISTINCT user_id) as active_users,
        COUNT(DISTINCT device_id) as active_devices
      FROM sync_logs sl
      ${whereClause}
    `;

    const statsResult = await db.query(statsQuery, queryParams.slice(0, -2)); // Remove limit and offset

    res.json({
      syncLogs: logsResult.rows,
      statistics: statsResult.rows[0],
      pagination: {
        currentPage: page,
        limit: limit,
        total: parseInt(statsResult.rows[0].total_syncs)
      }
    });

  } catch (error) {
    next(error);
  }
});

// Mark form as verified (Admin only)
router.put('/verify/:formId', requireAdmin, async (req, res, next) => {
  try {
    const formId = parseInt(req.params.formId);
    const { notes } = req.body;

    // Update form status to verified
    const updateQuery = `
      UPDATE supervision_forms 
      SET sync_status = 'verified', last_modified_at = CURRENT_TIMESTAMP
      WHERE id = $1
      RETURNING id, health_facility_name, sync_status
    `;

    const result = await db.query(updateQuery, [formId]);

    if (result.rows.length === 0) {
      return res.status(404).json({
        error: 'Not Found',
        message: 'Supervision form not found'
      });
    }

    // Log the verification
    await db.query(`
      INSERT INTO sync_logs (user_id, form_id, sync_type, sync_status, error_message, ip_address, user_agent)
      VALUES ($1, $2, $3, $4, $5, $6, $7)
    `, [
      req.user.id,
      formId,
      'verify',
      'completed',
      notes || 'Form verified by admin',
      req.ip,
      req.get('User-Agent')
    ]);

    res.json({
      message: 'Form verified successfully',
      form: result.rows[0]
    });

  } catch (error) {
    next(error);
  }
});

// Helper functions for getting form sections
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

// Helper functions for inserting form sections
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
    data.a1_visit_1 || null, data.a1_visit_2 || null, data.a1_visit_3 || null, data.a1_visit_4 || null, data.a1_comment || null,
    data.a2_visit_1 || null, data.a2_visit_2 || null, data.a2_visit_3 || null, data.a2_visit_4 || null, data.a2_comment || null,
    data.a3_visit_1 || null, data.a3_visit_2 || null, data.a3_visit_3 || null, data.a3_visit_4 || null, data.a3_comment || null
  ]);
}

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
      other_antihypertensives_v1, other_antihypertensives_v2, other_antihypertensives_v3, other_antihypertensives_v4,
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
      insulin_soluble_inj_v1, insulin_soluble_inj_v2, insulin_soluble_inj_v3, insulin_soluble_inj_v4,
      insulin_nph_inj_v1, insulin_nph_inj_v2, insulin_nph_inj_v3, insulin_nph_inj_v4,
      other_hypoglycemic_agents_v1, other_hypoglycemic_agents_v2, other_hypoglycemic_agents_v3, other_hypoglycemic_agents_v4,
      dextrose_25_solution_v1, dextrose_25_solution_v2, dextrose_25_solution_v3, dextrose_25_solution_v4,
      aspirin_75mg_v1, aspirin_75mg_v2, aspirin_75mg_v3, aspirin_75mg_v4,
      clopidogrel_75mg_v1, clopidogrel_75mg_v2, clopidogrel_75mg_v3, clopidogrel_75mg_v4,
      metoprolol_succinate_12_5_25_50mg_v1, metoprolol_succinate_12_5_25_50mg_v2, metoprolol_succinate_12_5_25_50mg_v3, metoprolol_succinate_12_5_25_50mg_v4,
      isosorbide_dinitrate_5mg_v1, isosorbide_dinitrate_5mg_v2, isosorbide_dinitrate_5mg_v3, isosorbide_dinitrate_5mg_v4,
      other_drugs_v1, other_drugs_v2, other_drugs_v3, other_drugs_v4,
      amoxicillin_clavulanic_potassium_625mg_v1, amoxicillin_clavulanic_potassium_625mg_v2, amoxicillin_clavulanic_potassium_625mg_v3, amoxicillin_clavulanic_potassium_625mg_v4,
      azithromycin_500mg_v1, azithromycin_500mg_v2, azithromycin_500mg_v3, azithromycin_500mg_v4,
      other_antibiotics_v1, other_antibiotics_v2, other_antibiotics_v3, other_antibiotics_v4,
      salbutamol_dpi_v1, salbutamol_dpi_v2, salbutamol_dpi_v3, salbutamol_dpi_v4,
      salbutamol_v1, salbutamol_v2, salbutamol_v3, salbutamol_v4,
      ipratropium_v1, ipratropium_v2, ipratropium_v3, ipratropium_v4,
      tiotropium_bromide_v1, tiotropium_bromide_v2, tiotropium_bromide_v3, tiotropium_bromide_v4,
      formoterol_v1, formoterol_v2, formoterol_v3, formoterol_v4,
      other_bronchodilators_v1, other_bronchodilators_v2, other_bronchodilators_v3, other_bronchodilators_v4,
      prednisolone_5_10_20mg_v1, prednisolone_5_10_20mg_v2, prednisolone_5_10_20mg_v3, prednisolone_5_10_20mg_v4,
      other_steroids_oral_v1, other_steroids_oral_v2, other_steroids_oral_v3, other_steroids_oral_v4,
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
      $127, $128, $129, $130, $131, $132, $133, $134, $135, $136, $137, $138,
      $139, $140, $141, $142, $143, $144, $145, $146, $147, $148, $149, $150,
      $151, $152, $153, $154
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
    data.other_antihypertensives_v1 || null, data.other_antihypertensives_v2 || null, data.other_antihypertensives_v3 || null, data.other_antihypertensives_v4 || null,
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
    data.insulin_soluble_inj_v1 || null, data.insulin_soluble_inj_v2 || null, data.insulin_soluble_inj_v3 || null, data.insulin_soluble_inj_v4 || null,
    data.insulin_nph_inj_v1 || null, data.insulin_nph_inj_v2 || null, data.insulin_nph_inj_v3 || null, data.insulin_nph_inj_v4 || null,
    data.other_hypoglycemic_agents_v1 || null, data.other_hypoglycemic_agents_v2 || null, data.other_hypoglycemic_agents_v3 || null, data.other_hypoglycemic_agents_v4 || null,
    data.dextrose_25_solution_v1 || null, data.dextrose_25_solution_v2 || null, data.dextrose_25_solution_v3 || null, data.dextrose_25_solution_v4 || null,
    data.aspirin_75mg_v1 || null, data.aspirin_75mg_v2 || null, data.aspirin_75mg_v3 || null, data.aspirin_75mg_v4 || null,
    data.clopidogrel_75mg_v1 || null, data.clopidogrel_75mg_v2 || null, data.clopidogrel_75mg_v3 || null, data.clopidogrel_75mg_v4 || null,
    data.metoprolol_succinate_12_5_25_50mg_v1 || null, data.metoprolol_succinate_12_5_25_50mg_v2 || null, data.metoprolol_succinate_12_5_25_50mg_v3 || null, data.metoprolol_succinate_12_5_25_50mg_v4 || null,
    data.isosorbide_dinitrate_5mg_v1 || null, data.isosorbide_dinitrate_5mg_v2 || null, data.isosorbide_dinitrate_5mg_v3 || null, data.isosorbide_dinitrate_5mg_v4 || null,
    data.other_drugs_v1 || null, data.other_drugs_v2 || null, data.other_drugs_v3 || null, data.other_drugs_v4 || null,
    data.amoxicillin_clavulanic_potassium_625mg_v1 || null, data.amoxicillin_clavulanic_potassium_625mg_v2 || null, data.amoxicillin_clavulanic_potassium_625mg_v3 || null, data.amoxicillin_clavulanic_potassium_625mg_v4 || null,
    data.azithromycin_500mg_v1 || null, data.azithromycin_500mg_v2 || null, data.azithromycin_500mg_v3 || null, data.azithromycin_500mg_v4 || null,
    data.other_antibiotics_v1 || null, data.other_antibiotics_v2 || null, data.other_antibiotics_v3 || null, data.other_antibiotics_v4 || null,
    data.salbutamol_dpi_v1 || null, data.salbutamol_dpi_v2 || null, data.salbutamol_dpi_v3 || null, data.salbutamol_dpi_v4 || null,
    data.salbutamol_v1 || null, data.salbutamol_v2 || null, data.salbutamol_v3 || null, data.salbutamol_v4 || null,
    data.ipratropium_v1 || null, data.ipratropium_v2 || null, data.ipratropium_v3 || null, data.ipratropium_v4 || null,
    data.tiotropium_bromide_v1 || null, data.tiotropium_bromide_v2 || null, data.tiotropium_bromide_v3 || null, data.tiotropium_bromide_v4 || null,
    data.formoterol_v1 || null, data.formoterol_v2 || null, data.formoterol_v3 || null, data.formoterol_v4 || null,
    data.other_bronchodilators_v1 || null, data.other_bronchodilators_v2 || null, data.other_bronchodilators_v3 || null, data.other_bronchodilators_v4 || null,
    data.prednisolone_5_10_20mg_v1 || null, data.prednisolone_5_10_20mg_v2 || null, data.prednisolone_5_10_20mg_v3 || null, data.prednisolone_5_10_20mg_v4 || null,
    data.other_steroids_oral_v1 || null, data.other_steroids_oral_v2 || null, data.other_steroids_oral_v3 || null, data.other_steroids_oral_v4 || null,
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