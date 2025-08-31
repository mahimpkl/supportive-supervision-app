const express = require('express');
const db = require('../config/database');
const { requireAdmin } = require('../middleware/auth');
const { body, validationResult } = require('express-validator');

const router = express.Router();

// Validation middleware for sync operations (updated for visit-based)
const validateSyncData = [
  body('forms').isArray().withMessage('Forms must be an array'),
  body('forms.*.tempId').notEmpty().withMessage('Each form must have a tempId'),
  body('forms.*.healthFacilityName').notEmpty().withMessage('Health facility name is required'),
  body('forms.*.visits').optional().isArray().withMessage('Visits must be an array'),
  body('forms.*.visits.*.visitNumber').optional().isInt({ min: 1, max: 4 }).withMessage('Visit number must be between 1 and 4'),
  body('forms.*.visits.*.visitDate').optional().isISO8601().withMessage('Visit date must be valid'),
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

// Upload forms from mobile app (sync from local to server) - Updated for visits
router.post('/upload', validateSyncData, async (req, res, next) => {
  try {
    const { forms, deviceId } = req.body;
    const userId = req.user.id;
    const uploadResults = [];
    const errors = [];

    console.log(`📤 Sync upload started for user ${userId}, device ${deviceId}, ${forms.length} forms`);

    for (const formData of forms) {
      const { tempId, visits = [], staffTraining, ...formContent } = formData;
      
      try {
        // Start transaction for each form
        const result = await db.transaction(async (client) => {
          // Insert main supervision form
          const formQuery = `
            INSERT INTO supervision_forms (
              user_id, health_facility_name, province, district,
              created_at, sync_status, updated_at
            ) VALUES ($1, $2, $3, $4, $5, $6, CURRENT_TIMESTAMP)
            RETURNING id, created_at
          `;

          const formResult = await client.query(formQuery, [
            userId,
            formContent.healthFacilityName,
            formContent.province,
            formContent.district,
            formContent.formCreatedAt || new Date(),
            'synced'
          ]);

          const formId = formResult.rows[0].id;

          // Insert staff training if provided
          if (staffTraining) {
            await insertStaffTraining(client, formId, staffTraining);
          }

          // Insert visits
          const visitResults = [];
          for (const visit of visits) {
            const visitQuery = `
              INSERT INTO supervision_visits (
                form_id, visit_number, visit_date, recommendations,
                supervisor_signature, facility_representative_signature,
                created_at, sync_status
              ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
              RETURNING id
            `;

            const visitResult = await client.query(visitQuery, [
              formId,
              visit.visitNumber,
              visit.visitDate,
              visit.recommendations || null,
              visit.supervisorSignature || null,
              visit.facilityRepresentativeSignature || null,
              visit.createdAt || new Date(),
              'synced'
            ]);

            const visitId = visitResult.rows[0].id;

            // Insert visit section responses
            if (visit.adminManagement) {
              await insertVisitAdminManagementResponses(client, visitId, visit.adminManagement);
            }
            if (visit.logistics) {
              await insertVisitLogisticsResponses(client, visitId, visit.logistics);
            }
            if (visit.equipment) {
              await insertVisitEquipmentResponses(client, visitId, visit.equipment);
            }
            if (visit.mhdcManagement) {
              await insertVisitMhdcManagementResponses(client, visitId, visit.mhdcManagement);
            }
            if (visit.serviceStandards) {
              await insertVisitServiceStandardsResponses(client, visitId, visit.serviceStandards);
            }
            if (visit.healthInformation) {
              await insertVisitHealthInformationResponses(client, visitId, visit.healthInformation);
            }
            if (visit.integration) {
              await insertVisitIntegrationResponses(client, visitId, visit.integration);
            }

            visitResults.push({ visitNumber: visit.visitNumber, visitId });
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
            syncedAt: formResult.rows[0].created_at,
            visitCount: visitResults.length,
            visits: visitResults
          };
        });

        uploadResults.push({
          tempId: result.tempId,
          serverId: result.serverId,
          visitCount: result.visitCount,
          status: 'success',
          syncedAt: result.syncedAt
        });

        console.log(`✅ Form ${tempId} synced successfully as ID ${result.serverId} with ${result.visitCount} visits`);

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
      errorCount: errors.length,
      totalVisits: uploadResults.reduce((sum, result) => sum + (result.visitCount || 0), 0)
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

// Download updates for mobile app (sync from server to local) - Updated for visits
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
      whereClause += ` AND (sf.updated_at > $${paramIndex} OR EXISTS (
        SELECT 1 FROM supervision_visits sv 
        WHERE sv.form_id = sf.id AND sv.updated_at > $${paramIndex}
      ))`;
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
      ORDER BY sf.updated_at DESC
      LIMIT 100
    `;

    const formsResult = await db.query(formsQuery, queryParams);
    const updatedForms = [];

    // Get complete form data with all visits
    for (const form of formsResult.rows) {
      const formId = form.id;
      
      // Get staff training
      const staffTrainingQuery = `SELECT * FROM form_staff_training WHERE form_id = $1`;
      const staffTrainingResult = await db.query(staffTrainingQuery, [formId]);

      // Get all visits for this form
      const visitsQuery = `
        SELECT * FROM supervision_visits 
        WHERE form_id = $1 
        ORDER BY visit_number
      `;
      const visitsResult = await db.query(visitsQuery, [formId]);

      // Get detailed data for each visit
      const visits = [];
      for (const visit of visitsResult.rows) {
        const visitData = {
          ...visit,
          adminManagement: await getVisitAdminManagementResponses(visit.id),
          logistics: await getVisitLogisticsResponses(visit.id),
          equipment: await getVisitEquipmentResponses(visit.id),
          mhdcManagement: await getVisitMhdcManagementResponses(visit.id),
          serviceStandards: await getVisitServiceStandardsResponses(visit.id),
          healthInformation: await getVisitHealthInformationResponses(visit.id),
          integration: await getVisitIntegrationResponses(visit.id)
        };
        visits.push(visitData);
      }

      const completeForm = {
        ...form,
        visits: visits,
        staffTraining: staffTrainingResult.rows[0] || null
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

    const totalVisits = updatedForms.reduce((sum, form) => sum + form.visits.length, 0);

    console.log(`📥 Sync download completed: ${updatedForms.length} forms sent with ${totalVisits} visits`);

    res.json({
      message: `${updatedForms.length} updated forms available with ${totalVisits} visits`,
      forms: updatedForms,
      syncTime: new Date().toISOString(),
      hasMore: updatedForms.length === 100 // Indicate if there might be more
    });

  } catch (error) {
    console.error('Sync download error:', error);
    next(error);
  }
});

// Get sync status and logs (Admin only) - Updated for visit tracking
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

    // Get sync logs with user and form information
    const logsQuery = `
      SELECT 
        sl.*,
        u.username,
        u.full_name,
        sf.health_facility_name,
        sv.visit_number
      FROM sync_logs sl
      JOIN users u ON sl.user_id = u.id
      LEFT JOIN supervision_forms sf ON sl.form_id = sf.id
      LEFT JOIN supervision_visits sv ON sl.visit_id = sv.id
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
        COUNT(DISTINCT device_id) as active_devices,
        COUNT(DISTINCT form_id) as synced_forms,
        COUNT(DISTINCT visit_id) as synced_visits
      FROM sync_logs sl
      ${whereClause}
    `;

    const statsResult = await db.query(statsQuery, queryParams.slice(0, -2)); // Remove limit and offset

    res.json({
      syncLogs: logsResult.rows,
      statistics: {
        ...statsResult.rows[0],
        total_syncs: parseInt(statsResult.rows[0].total_syncs),
        successful_syncs: parseInt(statsResult.rows[0].successful_syncs),
        failed_syncs: parseInt(statsResult.rows[0].failed_syncs),
        uploads: parseInt(statsResult.rows[0].uploads),
        downloads: parseInt(statsResult.rows[0].downloads),
        active_users: parseInt(statsResult.rows[0].active_users),
        active_devices: parseInt(statsResult.rows[0].active_devices),
        synced_forms: parseInt(statsResult.rows[0].synced_forms),
        synced_visits: parseInt(statsResult.rows[0].synced_visits)
      },
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

// Mark form as verified (Admin only) - Updated for visit-based
router.put('/verify/:formId', requireAdmin, async (req, res, next) => {
  try {
    const formId = parseInt(req.params.formId);
    const { notes } = req.body;

    // Update form status to verified
    const updateQuery = `
      UPDATE supervision_forms 
      SET sync_status = 'verified', updated_at = CURRENT_TIMESTAMP
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

    // Also update all visits to verified
    await db.query(`
      UPDATE supervision_visits 
      SET sync_status = 'verified', updated_at = CURRENT_TIMESTAMP
      WHERE form_id = $1
    `, [formId]);

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
      message: 'Form and all visits verified successfully',
      form: result.rows[0]
    });

  } catch (error) {
    next(error);
  }
});

// Helper functions for getting visit section data
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

// Helper functions for inserting visit section data
async function insertStaffTraining(client, formId, data) {
  if (!data) return;
  
  const query = `
    INSERT INTO form_staff_training (
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
    data.ha_total_staff || 0, data.ha_mhdc_trained || 0, data.ha_fen_trained || 0, data.ha_other_ncd_trained || 0,
    data.sr_ahw_total_staff || 0, data.sr_ahw_mhdc_trained || 0, data.sr_ahw_fen_trained || 0, data.sr_ahw_other_ncd_trained || 0,
    data.ahw_total_staff || 0, data.ahw_mhdc_trained || 0, data.ahw_fen_trained || 0, data.ahw_other_ncd_trained || 0,
    data.sr_anm_total_staff || 0, data.sr_anm_mhdc_trained || 0, data.sr_anm_fen_trained || 0, data.sr_anm_other_ncd_trained || 0,
    data.anm_total_staff || 0, data.anm_mhdc_trained || 0, data.anm_fen_trained || 0, data.anm_other_ncd_trained || 0,
    data.others_total_staff || 0, data.others_mhdc_trained || 0, data.others_fen_trained || 0, data.others_other_ncd_trained || 0
  ]);
}

async function insertVisitAdminManagementResponses(client, visitId, data) {
  if (!data) return;
  
  const query = `
    INSERT INTO visit_admin_management_responses (
      visit_id, a1_response, a1_comment, a2_response, a2_comment, a3_response, a3_comment
    ) VALUES ($1, $2, $3, $4, $5, $6, $7)
  `;
  
  return client.query(query, [
    visitId,
    data.a1_response || null, data.a1_comment || null,
    data.a2_response || null, data.a2_comment || null,
    data.a3_response || null, data.a3_comment || null
  ]);
}

async function insertVisitLogisticsResponses(client, visitId, data) {
  if (!data) return;
  
  const query = `
    INSERT INTO visit_logistics_responses (
      visit_id, b1_response, b1_comment,
      amlodipine_5_10mg, enalapril_2_5_10mg, losartan_25_50mg, hydrochlorothiazide_12_5_25mg,
      chlorthalidone_6_25_12_5mg, other_antihypertensives, atorvastatin_5mg, atorvastatin_10mg,
      atorvastatin_20mg, other_statins, metformin_500mg, metformin_1000mg, glimepiride_1_2mg,
      gliclazide_40_80mg, glipizide_2_5_5mg, sitagliptin_50mg, pioglitazone_5mg, empagliflozin_10mg,
      insulin_soluble_inj, insulin_nph_inj, other_hypoglycemic_agents, dextrose_25_solution,
      aspirin_75mg, clopidogrel_75mg, metoprolol_succinate_12_5_25_50mg, isosorbide_dinitrate_5mg,
      other_drugs, amoxicillin_clavulanic_potassium_625mg, azithromycin_500mg, other_antibiotics,
      salbutamol_dpi, salbutamol, ipratropium, tiotropium_bromide, formoterol, other_bronchodilators,
      prednisolone_5_10_20mg, other_steroids_oral,
      b2_response, b2_comment, b3_response, b3_comment, b4_response, b4_comment, b5_response, b5_comment
    ) VALUES (
      $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16,
      $17, $18, $19, $20, $21, $22, $23, $24, $25, $26, $27, $28, $29, $30,
      $31, $32, $33, $34, $35, $36, $37, $38, $39, $40, $41, $42, $43, $44, $45, $46, $47, $48, $49
    )
  `;
  
  return client.query(query, [
    visitId,
    data.b1_response || null, data.b1_comment || null,
    data.amlodipine_5_10mg || null, data.enalapril_2_5_10mg || null, data.losartan_25_50mg || null,
    data.hydrochlorothiazide_12_5_25mg || null, data.chlorthalidone_6_25_12_5mg || null,
    data.other_antihypertensives || null, data.atorvastatin_5mg || null, data.atorvastatin_10mg || null,
    data.atorvastatin_20mg || null, data.other_statins || null, data.metformin_500mg || null,
    data.metformin_1000mg || null, data.glimepiride_1_2mg || null, data.gliclazide_40_80mg || null,
    data.glipizide_2_5_5mg || null, data.sitagliptin_50mg || null, data.pioglitazone_5mg || null,
    data.empagliflozin_10mg || null, data.insulin_soluble_inj || null, data.insulin_nph_inj || null,
    data.other_hypoglycemic_agents || null, data.dextrose_25_solution || null, data.aspirin_75mg || null,
    data.clopidogrel_75mg || null, data.metoprolol_succinate_12_5_25_50mg || null,
    data.isosorbide_dinitrate_5mg || null, data.other_drugs || null,
    data.amoxicillin_clavulanic_potassium_625mg || null, data.azithromycin_500mg || null,
    data.other_antibiotics || null, data.salbutamol_dpi || null, data.salbutamol || null,
    data.ipratropium || null, data.tiotropium_bromide || null, data.formoterol || null,
    data.other_bronchodilators || null, data.prednisolone_5_10_20mg || null, data.other_steroids_oral || null,
    data.b2_response || null, data.b2_comment || null, data.b3_response || null, data.b3_comment || null,
    data.b4_response || null, data.b4_comment || null, data.b5_response || null, data.b5_comment || null
  ]);
}

async function insertVisitEquipmentResponses(client, visitId, data) {
  if (!data) return;
  
  const query = `
    INSERT INTO visit_equipment_responses (
      visit_id, sphygmomanometer, weighing_scale, measuring_tape, peak_expiratory_flow_meter,
      oxygen, oxygen_mask, nebulizer, pulse_oximetry, glucometer, glucometer_strips,
      lancets, urine_dipstick, ecg, other_equipment
    ) VALUES (
      $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15
    )
  `;
  
  return client.query(query, [
    visitId,
    data.sphygmomanometer || null, data.weighing_scale || null, data.measuring_tape || null,
    data.peak_expiratory_flow_meter || null, data.oxygen || null, data.oxygen_mask || null,
    data.nebulizer || null, data.pulse_oximetry || null, data.glucometer || null,
    data.glucometer_strips || null, data.lancets || null, data.urine_dipstick || null,
    data.ecg || null, data.other_equipment || null
  ]);
}

async function insertVisitMhdcManagementResponses(client, visitId, data) {
  if (!data) return;
  
  const query = `
    INSERT INTO visit_mhdc_management_responses (
      visit_id, b6_response, b6_comment, b7_response, b7_comment, b8_response, b8_comment,
      b9_response, b9_comment, b10_response, b10_comment
    ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
  `;
  
  return client.query(query, [
    visitId,
    data.b6_response || null, data.b6_comment || null,
    data.b7_response || null, data.b7_comment || null,
    data.b8_response || null, data.b8_comment || null,
    data.b9_response || null, data.b9_comment || null,
    data.b10_response || null, data.b10_comment || null
  ]);
}

async function insertVisitServiceStandardsResponses(client, visitId, data) {
  if (!data) return;
  
  const query = `
    INSERT INTO visit_service_standards_responses (
      visit_id, c2_blood_pressure, c2_blood_sugar, c2_bmi_measurement, c2_waist_circumference,
      c2_cvd_risk_estimation, c2_urine_protein_measurement, c2_peak_expiratory_flow_rate,
      c2_egfr_calculation, c2_brief_intervention, c2_foot_examination, c2_oral_examination,
      c2_eye_examination, c2_health_education, c3_response, c3_comment, c4_response, c4_comment,
      c5_response, c5_comment, c6_response, c6_comment, c7_response, c7_comment
    ) VALUES (
      $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22, $23, $24
    )
  `;
  
  return client.query(query, [
    visitId,
    data.c2_blood_pressure || null, data.c2_blood_sugar || null, data.c2_bmi_measurement || null,
    data.c2_waist_circumference || null, data.c2_cvd_risk_estimation || null,
    data.c2_urine_protein_measurement || null, data.c2_peak_expiratory_flow_rate || null,
    data.c2_egfr_calculation || null, data.c2_brief_intervention || null, data.c2_foot_examination || null,
    data.c2_oral_examination || null, data.c2_eye_examination || null, data.c2_health_education || null,
    data.c3_response || null, data.c3_comment || null, data.c4_response || null, data.c4_comment || null,
    data.c5_response || null, data.c5_comment || null, data.c6_response || null, data.c6_comment || null,
    data.c7_response || null, data.c7_comment || null
  ]);
}

async function insertVisitHealthInformationResponses(client, visitId, data) {
  if (!data) return;
  
  const query = `
    INSERT INTO visit_health_information_responses (
      visit_id, d1_response, d1_comment, d2_response, d2_comment, d3_response, d3_comment,
      d4_response, d4_comment, d5_response, d5_comment
    ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
  `;
  
  return client.query(query, [
    visitId,
    data.d1_response || null, data.d1_comment || null,
    data.d2_response || null, data.d2_comment || null,
    data.d3_response || null, data.d3_comment || null,
    data.d4_response || null, data.d4_comment || null,
    data.d5_response || null, data.d5_comment || null
  ]);
}

async function insertVisitIntegrationResponses(client, visitId, data) {
  if (!data) return;
  
  const query = `
    INSERT INTO visit_integration_responses (
      visit_id, e1_response, e1_comment, e2_response, e2_comment, e3_response, e3_comment
    ) VALUES ($1, $2, $3, $4, $5, $6, $7)
  `;
  
  return client.query(query, [
    visitId,
    data.e1_response || null, data.e1_comment || null,
    data.e2_response || null, data.e2_comment || null,
    data.e3_response || null, data.e3_comment || null
  ]);
}

module.exports = router;