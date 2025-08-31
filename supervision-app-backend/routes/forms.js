const express = require('express');
const db = require('../config/database');
const { requireAdmin, canModifyResource } = require('../middleware/auth');
const { 
  validateSupervisionForm,
  validateVisit,
  validateId,
  validateVisitNumber,
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
      whereConditions.push(`sf.created_at >= $${paramIndex}`);
      queryParams.push(startDate);
      paramIndex++;
    }

    if (endDate) {
      whereConditions.push(`sf.created_at <= $${paramIndex}`);
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

    // Get forms with user information and detailed visit information
    const formsQuery = `
      SELECT 
        sf.id,
        sf.health_facility_name,
        sf.province,
        sf.district,
        sf.created_at,
        sf.updated_at,
        sf.sync_status,
        sf.is_active,
        u.username,
        u.full_name as doctor_name,
        COUNT(sv.id) as visit_count,
        MAX(sv.visit_date) as last_visit_date,
        MIN(sv.visit_date) as first_visit_date,
        MAX(sv.visit_number) as highest_visit_number,
        STRING_AGG(DISTINCT sv.visit_number::text, ',' ORDER BY sv.visit_number::text) as completed_visits
      FROM supervision_forms sf
      JOIN users u ON sf.user_id = u.id
      LEFT JOIN supervision_visits sv ON sf.id = sv.form_id
      ${whereClause}
      GROUP BY sf.id, u.username, u.full_name
      ORDER BY sf.updated_at DESC, sf.created_at DESC
      LIMIT $${paramIndex} OFFSET $${paramIndex + 1}
    `;
    
    queryParams.push(limit, offset);
    const formsResult = await db.query(formsQuery, queryParams);

    const totalPages = Math.ceil(totalForms / limit);

    res.json({
      forms: formsResult.rows.map(form => {
        const visitCount = parseInt(form.visit_count) || 0;
        const completedVisits = form.completed_visits ? 
          form.completed_visits.split(',').map(v => parseInt(v)) : [];
        
        return {
          ...form,
          visit_count: visitCount,
          highest_visit_number: parseInt(form.highest_visit_number) || 0,
          completed_visits: completedVisits,
          completion_status: visitCount === 4 ? 'complete' : 
                           visitCount === 0 ? 'no_visits' : 'in_progress',
          completion_percentage: Math.round((visitCount / 4) * 100),
          next_visit_number: visitCount < 4 ? visitCount + 1 : null,
          days_since_last_visit: form.last_visit_date ? 
            Math.floor((new Date() - new Date(form.last_visit_date)) / (1000 * 60 * 60 * 24)) : null
        };
      }),
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

// Get specific visit for a form
router.get('/:id/visits/:visitNumber', validateId, validateVisitNumber, async (req, res, next) => {
  try {
    const formId = parseInt(req.params.id);
    const visitNumber = parseInt(req.params.visitNumber);

    // Build query based on user role
    let userFilter = '';
    let queryParams = [formId, visitNumber];
    
    if (req.user.role !== 'admin') {
      userFilter = 'AND sf.user_id = $3';
      queryParams.push(req.user.id);
    }

    // Get form and visit info
    const visitQuery = `
      SELECT 
        sf.id as form_id,
        sf.health_facility_name,
        sf.province,
        sf.district,
        sf.created_at as form_created_at,
        u.username,
        u.full_name as doctor_name,
        sv.*
      FROM supervision_forms sf
      JOIN users u ON sf.user_id = u.id
      JOIN supervision_visits sv ON sf.id = sv.form_id
      WHERE sf.id = $1 AND sv.visit_number = $2 ${userFilter}
    `;

    const visitResult = await db.query(visitQuery, queryParams);

    if (visitResult.rows.length === 0) {
      return res.status(404).json({
        error: 'Not Found',
        message: 'Visit not found'
      });
    }

    const visit = visitResult.rows[0];

    // Get detailed visit data with enhanced functions
    const visitData = {
      ...visit,
      adminManagement: await getVisitAdminManagementResponses(visit.id),
      logistics: await getVisitLogisticsResponses(visit.id),
      equipment: await getVisitEquipmentResponses(visit.id),
      mhdcManagement: await getVisitMhdcManagementResponses(visit.id),
      serviceStandards: await getVisitServiceStandardsResponses(visit.id),
      healthInformation: await getVisitHealthInformationResponses(visit.id),
      integration: await getVisitIntegrationResponses(visit.id),
      medicineDetails: await getVisitMedicineDetails(visit.id),
      patientVolumes: await getVisitPatientVolumes(visit.id),
      equipmentFunctionality: await getVisitEquipmentFunctionality(visit.id),
      qualityAssurance: await getVisitQualityAssurance(visit.id)
    };

    res.json({ visit: visitData });

  } catch (error) {
    next(error);
  }
});

// Get supervision form by ID with all visits
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

    // Get all visits for this form
    const visitsQuery = `
      SELECT * FROM supervision_visits 
      WHERE form_id = $1 
      ORDER BY visit_number
    `;
    const visitsResult = await db.query(visitsQuery, [formId]);

    // Get staff training data (form-level)
    const staffTrainingQuery = `
      SELECT * FROM form_staff_training WHERE form_id = $1
    `;
    const staffTrainingResult = await db.query(staffTrainingQuery, [formId]);

    // Get facility infrastructure data
    const infrastructureQuery = `
      SELECT * FROM form_facility_infrastructure WHERE form_id = $1
    `;
    const infrastructureResult = await db.query(infrastructureQuery, [formId]);

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
        integration: await getVisitIntegrationResponses(visit.id),
        medicineDetails: await getVisitMedicineDetails(visit.id),
        patientVolumes: await getVisitPatientVolumes(visit.id),
        equipmentFunctionality: await getVisitEquipmentFunctionality(visit.id),
        qualityAssurance: await getVisitQualityAssurance(visit.id)
      };
      visits.push(visitData);
    }

    const completeForm = {
      ...form,
      visits: visits,
      staffTraining: staffTrainingResult.rows[0] || null,
      infrastructure: infrastructureResult.rows[0] || null
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
      staffTraining,
      infrastructure
    } = req.body;

    // Create form within transaction
    const result = await db.transaction(async (client) => {
      // Insert main form
      const formQuery = `
        INSERT INTO supervision_forms (
          user_id, health_facility_name, province, district, sync_status
        ) VALUES ($1, $2, $3, $4, $5)
        RETURNING id, created_at
      `;

      const formResult = await client.query(formQuery, [
        req.user.id,
        healthFacilityName,
        province,
        district,
        'local'
      ]);

      const formId = formResult.rows[0].id;

      // Insert staff training data if provided
      if (staffTraining) {
        await insertStaffTraining(client, formId, staffTraining);
      }

      // Insert infrastructure data if provided
      if (infrastructure) {
        await insertInfrastructure(client, formId, infrastructure);
      }

      return formResult.rows[0];
    });

    res.status(201).json({
      message: 'Supervision form created successfully',
      form: {
        id: result.id,
        createdAt: result.created_at,
        syncStatus: 'local'
      }
    });

  } catch (error) {
    next(error);
  }
});

// Add a visit to an existing form
router.post('/:id/visits', validateId, validateVisit, async (req, res, next) => {
  try {
    const formId = parseInt(req.params.id);
    const {
      visitNumber,
      visitDate,
      recommendations,
      actionsAgreed,
      supervisorSignature,
      facilityRepresentativeSignature,
      adminManagement,
      logistics,
      equipment,
      mhdcManagement,
      serviceStandards,
      healthInformation,
      integration,
      medicineDetails,
      patientVolumes,
      equipmentFunctionality,
      qualityAssurance
    } = req.body;

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

    // Check if visit number already exists
    const visitExistsQuery = `
      SELECT id FROM supervision_visits 
      WHERE form_id = $1 AND visit_number = $2
    `;
    const visitExistsResult = await db.query(visitExistsQuery, [formId, visitNumber]);

    if (visitExistsResult.rows.length > 0) {
      return res.status(409).json({
        error: 'Conflict',
        message: `Visit ${visitNumber} already exists for this form`
      });
    }

    // Create visit within transaction
    const result = await db.transaction(async (client) => {
      // Insert visit
      const visitQuery = `
        INSERT INTO supervision_visits (
          form_id, visit_number, visit_date, recommendations, actions_agreed,
          supervisor_signature, facility_representative_signature, sync_status
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
        RETURNING id, created_at
      `;

      const visitResult = await client.query(visitQuery, [
        formId,
        visitNumber,
        visitDate,
        recommendations,
        actionsAgreed,
        supervisorSignature,
        facilityRepresentativeSignature,
        'local'
      ]);

      const visitId = visitResult.rows[0].id;

      // Insert visit section responses
      if (adminManagement) await insertVisitAdminManagementResponses(client, visitId, adminManagement);
      if (logistics) await insertVisitLogisticsResponses(client, visitId, logistics);
      if (equipment) await insertVisitEquipmentResponses(client, visitId, equipment);
      if (mhdcManagement) await insertVisitMhdcManagementResponses(client, visitId, mhdcManagement);
      if (serviceStandards) await insertVisitServiceStandardsResponses(client, visitId, serviceStandards);
      if (healthInformation) await insertVisitHealthInformationResponses(client, visitId, healthInformation);
      if (integration) await insertVisitIntegrationResponses(client, visitId, integration);
      if (medicineDetails && Array.isArray(medicineDetails)) {
        for (const medicine of medicineDetails) {
          await insertVisitMedicineDetail(client, visitId, medicine);
        }
      }
      if (patientVolumes) await insertVisitPatientVolumes(client, visitId, patientVolumes);
      if (equipmentFunctionality && Array.isArray(equipmentFunctionality)) {
        for (const equipment of equipmentFunctionality) {
          await insertVisitEquipmentFunctionality(client, visitId, equipment);
        }
      }
      if (qualityAssurance) await insertVisitQualityAssurance(client, visitId, qualityAssurance);

      // Update form's updated_at timestamp
      await client.query(
        'UPDATE supervision_forms SET updated_at = CURRENT_TIMESTAMP WHERE id = $1',
        [formId]
      );

      return visitResult.rows[0];
    });

    res.status(201).json({
      message: 'Visit added successfully',
      visit: {
        id: result.id,
        visitNumber: visitNumber,
        createdAt: result.created_at,
        syncStatus: 'local'
      }
    });

  } catch (error) {
    next(error);
  }
});

// Update a visit
router.put('/:id/visits/:visitNumber', validateId, validateVisitNumber, async (req, res, next) => {
  try {
    const formId = parseInt(req.params.id);
    const visitNumber = parseInt(req.params.visitNumber);

    // Check permissions
    let userFilter = '';
    let queryParams = [formId, visitNumber];
    
    if (req.user.role !== 'admin') {
      userFilter = 'AND sf.user_id = $3';
      queryParams.push(req.user.id);
    }

    const visitQuery = `
      SELECT sv.id as visit_id
      FROM supervision_visits sv
      JOIN supervision_forms sf ON sv.form_id = sf.id
      WHERE sf.id = $1 AND sv.visit_number = $2 ${userFilter}
    `;

    const visitResult = await db.query(visitQuery, queryParams);

    if (visitResult.rows.length === 0) {
      return res.status(404).json({
        error: 'Not Found',
        message: 'Visit not found'
      });
    }

    const visitId = visitResult.rows[0].visit_id;
    const updateData = req.body;

    // Update visit within transaction
    await db.transaction(async (client) => {
      // Update basic visit info if provided
      if (updateData.visitDate || updateData.recommendations || updateData.actionsAgreed) {
        const updateFields = [];
        const updateValues = [];
        let paramIndex = 1;

        if (updateData.visitDate) {
          updateFields.push(`visit_date = $${paramIndex++}`);
          updateValues.push(updateData.visitDate);
        }
        if (updateData.recommendations) {
          updateFields.push(`recommendations = $${paramIndex++}`);
          updateValues.push(updateData.recommendations);
        }
        if (updateData.actionsAgreed) {
          updateFields.push(`actions_agreed = $${paramIndex++}`);
          updateValues.push(updateData.actionsAgreed);
        }
        
        updateFields.push(`updated_at = CURRENT_TIMESTAMP`);
        updateValues.push(visitId);

        const updateQuery = `
          UPDATE supervision_visits 
          SET ${updateFields.join(', ')}
          WHERE id = $${paramIndex}
        `;

        await client.query(updateQuery, updateValues);
      }

      // Update section data if provided
      if (updateData.adminManagement) {
        await updateVisitAdminManagementResponses(client, visitId, updateData.adminManagement);
      }
      if (updateData.logistics) {
        await updateVisitLogisticsResponses(client, visitId, updateData.logistics);
      }
      // Add other section updates as needed...

      // Update form timestamp
      await client.query(
        'UPDATE supervision_forms SET updated_at = CURRENT_TIMESTAMP WHERE id = $1',
        [formId]
      );
    });

    res.json({
      message: 'Visit updated successfully'
    });

  } catch (error) {
    next(error);
  }
});

// Delete a visit
router.delete('/:id/visits/:visitNumber', validateId, validateVisitNumber, async (req, res, next) => {
  try {
    const formId = parseInt(req.params.id);
    const visitNumber = parseInt(req.params.visitNumber);

    // Check permissions
    let userFilter = '';
    let queryParams = [formId, visitNumber];
    
    if (req.user.role !== 'admin') {
      userFilter = 'AND sf.user_id = $3';
      queryParams.push(req.user.id);
    }

    const visitQuery = `
      SELECT sv.id as visit_id
      FROM supervision_visits sv
      JOIN supervision_forms sf ON sv.form_id = sf.id
      WHERE sf.id = $1 AND sv.visit_number = $2 ${userFilter}
    `;

    const visitResult = await db.query(visitQuery, queryParams);

    if (visitResult.rows.length === 0) {
      return res.status(404).json({
        error: 'Not Found',
        message: 'Visit not found'
      });
    }

    const visitId = visitResult.rows[0].visit_id;

    // Delete visit (cascade will handle related records)
    await db.query('DELETE FROM supervision_visits WHERE id = $1', [visitId]);

    // Update form timestamp
    await db.query(
      'UPDATE supervision_forms SET updated_at = CURRENT_TIMESTAMP WHERE id = $1',
      [formId]
    );

    res.json({
      message: 'Visit deleted successfully'
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

async function getVisitMedicineDetails(visitId) {
  const result = await db.query('SELECT * FROM visit_medicine_details WHERE visit_id = $1 ORDER BY medicine_name', [visitId]);
  return result.rows;
}

async function getVisitPatientVolumes(visitId) {
  const result = await db.query('SELECT * FROM visit_patient_volumes WHERE visit_id = $1', [visitId]);
  return result.rows[0] || null;
}

async function getVisitEquipmentFunctionality(visitId) {
  const result = await db.query('SELECT * FROM visit_equipment_functionality WHERE visit_id = $1 ORDER BY equipment_name', [visitId]);
  return result.rows;
}

async function getVisitQualityAssurance(visitId) {
  const result = await db.query('SELECT * FROM visit_quality_assurance WHERE visit_id = $1', [visitId]);
  return result.rows[0] || null;
}

// Helper functions for inserting form-level data
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
      others_total_staff, others_mhdc_trained, others_fen_trained, others_other_ncd_trained,
      last_mhdc_training_date, last_fen_training_date, last_other_training_date, 
      training_provider, training_certificates_verified
    ) VALUES (
      $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13,
      $14, $15, $16, $17, $18, $19, $20, $21, $22, $23, $24, $25,
      $26, $27, $28, $29, $30
    )
  `;
  
  return client.query(query, [
    formId,
    data.ha_total_staff || 0, data.ha_mhdc_trained || 0, data.ha_fen_trained || 0, data.ha_other_ncd_trained || 0,
    data.sr_ahw_total_staff || 0, data.sr_ahw_mhdc_trained || 0, data.sr_ahw_fen_trained || 0, data.sr_ahw_other_ncd_trained || 0,
    data.ahw_total_staff || 0, data.ahw_mhdc_trained || 0, data.ahw_fen_trained || 0, data.ahw_other_ncd_trained || 0,
    data.sr_anm_total_staff || 0, data.sr_anm_mhdc_trained || 0, data.sr_anm_fen_trained || 0, data.sr_anm_other_ncd_trained || 0,
    data.anm_total_staff || 0, data.anm_mhdc_trained || 0, data.anm_fen_trained || 0, data.anm_other_ncd_trained || 0,
    data.others_total_staff || 0, data.others_mhdc_trained || 0, data.others_fen_trained || 0, data.others_other_ncd_trained || 0,
    data.last_mhdc_training_date || null, data.last_fen_training_date || null, data.last_other_training_date || null,
    data.training_provider || null, data.training_certificates_verified || false
  ]);
}

async function insertInfrastructure(client, formId, data) {
  if (!data) return;
  
  const query = `
    INSERT INTO form_facility_infrastructure (
      form_id, total_rooms, consultation_rooms, waiting_area_adequate,
      waiting_area_capacity, pharmacy_storage_adequate, pharmacy_storage_size_sqm,
      cold_chain_available, cold_chain_temperature_monitored, 
      medicine_storage_conditions_appropriate, generator_backup, generator_capacity_kw,
      water_supply_reliable, water_storage_capacity_liters, electricity_stable,
      internet_connectivity, waste_disposal_system, sharps_disposal_appropriate,
      biomedical_waste_segregation, accessibility_features, wheelchair_accessible,
      fire_safety_equipment, emergency_protocols_displayed, laboratory_available,
      xray_available, ambulance_service, assessment_date, assessed_by,
      infrastructure_score, priority_improvements
    ) VALUES (
      $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15,
      $16, $17, $18, $19, $20, $21, $22, $23, $24, $25, $26, $27, $28, $29, $30
    )
  `;
  
  return client.query(query, [
    formId,
    data.total_rooms || null, data.consultation_rooms || null, data.waiting_area_adequate || false,
    data.waiting_area_capacity || null, data.pharmacy_storage_adequate || false, data.pharmacy_storage_size_sqm || null,
    data.cold_chain_available || false, data.cold_chain_temperature_monitored || false,
    data.medicine_storage_conditions_appropriate || false, data.generator_backup || false, data.generator_capacity_kw || null,
    data.water_supply_reliable || false, data.water_storage_capacity_liters || null, data.electricity_stable || false,
    data.internet_connectivity || false, data.waste_disposal_system || false, data.sharps_disposal_appropriate || false,
    data.biomedical_waste_segregation || false, data.accessibility_features || false, data.wheelchair_accessible || false,
    data.fire_safety_equipment || false, data.emergency_protocols_displayed || false, data.laboratory_available || false,
    data.xray_available || false, data.ambulance_service || false, data.assessment_date || null, data.assessed_by || null,
    data.infrastructure_score || null, data.priority_improvements || null
  ]);
}

// Helper functions for inserting visit section data
async function insertVisitAdminManagementResponses(client, visitId, data) {
  if (!data) return;
  
  const query = `
    INSERT INTO visit_admin_management_responses (
      visit_id, a1_response, a1_comment, a1_respondents_comment,
      a2_response, a2_comment, a2_respondents_comment,
      a3_response, a3_comment, a3_respondents_comment, actions_agreed
    ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
  `;
  
  return client.query(query, [
    visitId,
    data.a1_response || null, data.a1_comment || null, data.a1_respondents_comment || null,
    data.a2_response || null, data.a2_comment || null, data.a2_respondents_comment || null,
    data.a3_response || null, data.a3_comment || null, data.a3_respondents_comment || null,
    data.actions_agreed || null
  ]);
}

async function insertVisitLogisticsResponses(client, visitId, data) {
  if (!data) return;
  
  const query = `
    INSERT INTO visit_logistics_responses (
      visit_id, b1_response, b1_comment, b1_respondents_comment, b1_validation_note,
      amlodipine_5_10mg, amlodipine_5_10mg_quantity, amlodipine_5_10mg_units,
      enalapril_2_5_10mg, enalapril_2_5_10mg_quantity, enalapril_2_5_10mg_units,
      losartan_25_50mg, losartan_25_50mg_quantity, losartan_25_50mg_units,
      hydrochlorothiazide_12_5_25mg, hydrochlorothiazide_12_5_25mg_quantity, hydrochlorothiazide_12_5_25mg_units,
      chlorthalidone_6_25_12_5mg, chlorthalidone_6_25_12_5mg_quantity, chlorthalidone_6_25_12_5mg_units,
      other_antihypertensives, other_antihypertensives_quantity, other_antihypertensives_units, other_antihypertensives_specify,
      atorvastatin_5mg, atorvastatin_5mg_quantity, atorvastatin_5mg_units,
      atorvastatin_10mg, atorvastatin_10mg_quantity, atorvastatin_10mg_units,
      atorvastatin_20mg, atorvastatin_20mg_quantity, atorvastatin_20mg_units,
      other_statins, other_statins_quantity, other_statins_units, other_statins_specify,
      metformin_500mg, metformin_500mg_quantity, metformin_500mg_units,
      metformin_1000mg, metformin_1000mg_quantity, metformin_1000mg_units,
      glimepiride_1_2mg, glimepiride_1_2mg_quantity, glimepiride_1_2mg_units,
      gliclazide_40_80mg, gliclazide_40_80mg_quantity, gliclazide_40_80mg_units,
      glipizide_2_5_5mg, glipizide_2_5_5mg_quantity, glipizide_2_5_5mg_units,
      sitagliptin_50mg, sitagliptin_50mg_quantity, sitagliptin_50mg_units,
      pioglitazone_5mg, pioglitazone_5mg_quantity, pioglitazone_5mg_units,
      empagliflozin_10mg, empagliflozin_10mg_quantity, empagliflozin_10mg_units,
      insulin_soluble_inj, insulin_soluble_inj_quantity, insulin_soluble_inj_units,
      insulin_nph_inj, insulin_nph_inj_quantity, insulin_nph_inj_units,
      other_hypoglycemic_agents, other_hypoglycemic_agents_quantity, other_hypoglycemic_agents_units, other_hypoglycemic_agents_specify,
      dextrose_25_solution, dextrose_25_solution_quantity, dextrose_25_solution_units,
      aspirin_75mg, aspirin_75mg_quantity, aspirin_75mg_units,
      clopidogrel_75mg, clopidogrel_75mg_quantity, clopidogrel_75mg_units,
      metoprolol_succinate_12_5_25_50mg, metoprolol_succinate_12_5_25_50mg_quantity, metoprolol_succinate_12_5_25_50mg_units,
      isosorbide_dinitrate_5mg, isosorbide_dinitrate_5mg_quantity, isosorbide_dinitrate_5mg_units,
      other_drugs, other_drugs_quantity, other_drugs_units, other_drugs_specify,
      amoxicillin_clavulanic_potassium_625mg, amoxicillin_clavulanic_potassium_625mg_quantity, amoxicillin_clavulanic_potassium_625mg_units,
      azithromycin_500mg, azithromycin_500mg_quantity, azithromycin_500mg_units,
      other_antibiotics, other_antibiotics_quantity, other_antibiotics_units, other_antibiotics_specify,
      salbutamol_dpi, salbutamol_dpi_quantity, salbutamol_dpi_units,
      salbutamol, salbutamol_quantity, salbutamol_units,
      ipratropium, ipratropium_quantity, ipratropium_units,
      tiotropium_bromide, tiotropium_bromide_quantity, tiotropium_bromide_units,
      formoterol, formoterol_quantity, formoterol_units,
      other_bronchodilators, other_bronchodilators_quantity, other_bronchodilators_units, other_bronchodilators_specify,
      prednisolone_5_10_20mg, prednisolone_5_10_20mg_quantity, prednisolone_5_10_20mg_units,
      other_steroids_oral, other_steroids_oral_quantity, other_steroids_oral_units, other_steroids_oral_specify,
      b2_response, b2_comment, b2_respondents_comment, b2_validation_note, b2_random_records_checked, b2_explanation_if_not_in_use,
      b3_response, b3_comment, b3_respondents_comment, b3_validation_note, b3_expiry_date_verified, b3_storage_conditions_verified,
      b4_response, b4_comment, b4_respondents_comment, b4_validation_note, b4_expiry_date_verified, b4_storage_conditions_verified,
      b5_response, b5_comment, b5_respondents_comment, b5_validation_note,
      medicine_quantities, expiry_dates_checked, storage_conditions_verified,
      antihypertensive_comments, statin_comments, diabetes_medication_comments,
      cardiovascular_medication_comments, respiratory_medication_comments, actions_agreed
    ) VALUES (
      $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20,
      $21, $22, $23, $24, $25, $26, $27, $28, $29, $30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $40,
      $41, $42, $43, $44, $45, $46, $47, $48, $49, $50, $51, $52, $53, $54, $55, $56, $57, $58, $59, $60,
      $61, $62, $63, $64, $65, $66, $67, $68, $69, $70, $71, $72, $73, $74, $75, $76, $77, $78, $79, $80,
      $81, $82, $83, $84, $85, $86, $87, $88, $89, $90, $91, $92, $93, $94, $95, $96, $97, $98, $99, $100,
      $101, $102, $103, $104, $105, $106, $107, $108, $109, $110, $111, $112, $113, $114, $115, $116, $117, $118, $119, $120,
      $121, $122, $123, $124, $125, $126, $127, $128, $129, $130
    )
  `;
  
  return client.query(query, [
    visitId,
    data.b1_response || null, data.b1_comment || null, data.b1_respondents_comment || null, data.b1_validation_note || null,
    data.amlodipine_5_10mg || null, data.amlodipine_5_10mg_quantity || null, data.amlodipine_5_10mg_units || null,
    data.enalapril_2_5_10mg || null, data.enalapril_2_5_10mg_quantity || null, data.enalapril_2_5_10mg_units || null,
    data.losartan_25_50mg || null, data.losartan_25_50mg_quantity || null, data.losartan_25_50mg_units || null,
    data.hydrochlorothiazide_12_5_25mg || null, data.hydrochlorothiazide_12_5_25mg_quantity || null, data.hydrochlorothiazide_12_5_25mg_units || null,
    data.chlorthalidone_6_25_12_5mg || null, data.chlorthalidone_6_25_12_5mg_quantity || null, data.chlorthalidone_6_25_12_5mg_units || null,
    data.other_antihypertensives || null, data.other_antihypertensives_quantity || null, data.other_antihypertensives_units || null, data.other_antihypertensives_specify || null,
    data.atorvastatin_5mg || null, data.atorvastatin_5mg_quantity || null, data.atorvastatin_5mg_units || null,
    data.atorvastatin_10mg || null, data.atorvastatin_10mg_quantity || null, data.atorvastatin_10mg_units || null,
    data.atorvastatin_20mg || null, data.atorvastatin_20mg_quantity || null, data.atorvastatin_20mg_units || null,
    data.other_statins || null, data.other_statins_quantity || null, data.other_statins_units || null, data.other_statins_specify || null,
    data.metformin_500mg || null, data.metformin_500mg_quantity || null, data.metformin_500mg_units || null,
    data.metformin_1000mg || null, data.metformin_1000mg_quantity || null, data.metformin_1000mg_units || null,
    data.glimepiride_1_2mg || null, data.glimepiride_1_2mg_quantity || null, data.glimepiride_1_2mg_units || null,
    data.gliclazide_40_80mg || null, data.gliclazide_40_80mg_quantity || null, data.gliclazide_40_80mg_units || null,
    data.glipizide_2_5_5mg || null, data.glipizide_2_5_5mg_quantity || null, data.glipizide_2_5_5mg_units || null,
    data.sitagliptin_50mg || null, data.sitagliptin_50mg_quantity || null, data.sitagliptin_50mg_units || null,
    data.pioglitazone_5mg || null, data.pioglitazone_5mg_quantity || null, data.pioglitazone_5mg_units || null,
    data.empagliflozin_10mg || null, data.empagliflozin_10mg_quantity || null, data.empagliflozin_10mg_units || null,
    data.insulin_soluble_inj || null, data.insulin_soluble_inj_quantity || null, data.insulin_soluble_inj_units || null,
    data.insulin_nph_inj || null, data.insulin_nph_inj_quantity || null, data.insulin_nph_inj_units || null,
    data.other_hypoglycemic_agents || null, data.other_hypoglycemic_agents_quantity || null, data.other_hypoglycemic_agents_units || null, data.other_hypoglycemic_agents_specify || null,
    data.dextrose_25_solution || null, data.dextrose_25_solution_quantity || null, data.dextrose_25_solution_units || null,
    data.aspirin_75mg || null, data.aspirin_75mg_quantity || null, data.aspirin_75mg_units || null,
    data.clopidogrel_75mg || null, data.clopidogrel_75mg_quantity || null, data.clopidogrel_75mg_units || null,
    data.metoprolol_succinate_12_5_25_50mg || null, data.metoprolol_succinate_12_5_25_50mg_quantity || null, data.metoprolol_succinate_12_5_25_50mg_units || null,
    data.isosorbide_dinitrate_5mg || null, data.isosorbide_dinitrate_5mg_quantity || null, data.isosorbide_dinitrate_5mg_units || null,
    data.other_drugs || null, data.other_drugs_quantity || null, data.other_drugs_units || null, data.other_drugs_specify || null,
    data.amoxicillin_clavulanic_potassium_625mg || null, data.amoxicillin_clavulanic_potassium_625mg_quantity || null, data.amoxicillin_clavulanic_potassium_625mg_units || null,
    data.azithromycin_500mg || null, data.azithromycin_500mg_quantity || null, data.azithromycin_500mg_units || null,
    data.other_antibiotics || null, data.other_antibiotics_quantity || null, data.other_antibiotics_units || null, data.other_antibiotics_specify || null,
    data.salbutamol_dpi || null, data.salbutamol_dpi_quantity || null, data.salbutamol_dpi_units || null,
    data.salbutamol || null, data.salbutamol_quantity || null, data.salbutamol_units || null,
    data.ipratropium || null, data.ipratropium_quantity || null, data.ipratropium_units || null,
    data.tiotropium_bromide || null, data.tiotropium_bromide_quantity || null, data.tiotropium_bromide_units || null,
    data.formoterol || null, data.formoterol_quantity || null, data.formoterol_units || null,
    data.other_bronchodilators || null, data.other_bronchodilators_quantity || null, data.other_bronchodilators_units || null, data.other_bronchodilators_specify || null,
    data.prednisolone_5_10_20mg || null, data.prednisolone_5_10_20mg_quantity || null, data.prednisolone_5_10_20mg_units || null,
    data.other_steroids_oral || null, data.other_steroids_oral_quantity || null, data.other_steroids_oral_units || null, data.other_steroids_oral_specify || null,
    data.b2_response || null, data.b2_comment || null, data.b2_respondents_comment || null, data.b2_validation_note || null, data.b2_random_records_checked || false, data.b2_explanation_if_not_in_use || null,
    data.b3_response || null, data.b3_comment || null, data.b3_respondents_comment || null, data.b3_validation_note || null, data.b3_expiry_date_verified || false, data.b3_storage_conditions_verified || false,
    data.b4_response || null, data.b4_comment || null, data.b4_respondents_comment || null, data.b4_validation_note || null, data.b4_expiry_date_verified || false, data.b4_storage_conditions_verified || false,
    data.b5_response || null, data.b5_comment || null, data.b5_respondents_comment || null, data.b5_validation_note || null,
    data.medicine_quantities ? JSON.stringify(data.medicine_quantities) : null, data.expiry_dates_checked || false, data.storage_conditions_verified || false,
    data.antihypertensive_comments || null, data.statin_comments || null, data.diabetes_medication_comments || null,
    data.cardiovascular_medication_comments || null, data.respiratory_medication_comments || null, data.actions_agreed || null
  ]);
}

async function insertVisitEquipmentResponses(client, visitId, data) {
  if (!data) return;
  
  const query = `
    INSERT INTO visit_equipment_responses (
      visit_id, sphygmomanometer, sphygmomanometer_quantity, sphygmomanometer_units,
      weighing_scale, weighing_scale_quantity, weighing_scale_units,
      measuring_tape, measuring_tape_quantity, measuring_tape_units,
      peak_expiratory_flow_meter, peak_expiratory_flow_meter_quantity, peak_expiratory_flow_meter_units,
      oxygen, oxygen_quantity, oxygen_units,
      oxygen_mask, oxygen_mask_quantity, oxygen_mask_units,
      nebulizer, nebulizer_quantity, nebulizer_units,
      pulse_oximetry, pulse_oximetry_quantity, pulse_oximetry_units,
      glucometer, glucometer_quantity, glucometer_units,
      glucometer_strips, glucometer_strips_quantity, glucometer_strips_units,
      lancets, lancets_quantity, lancets_units,
      urine_dipstick, urine_dipstick_quantity, urine_dipstick_units,
      ecg, ecg_quantity, ecg_units,
      other_equipment, other_equipment_quantity, other_equipment_units, other_equipment_specify,
      stethoscope, stethoscope_quantity,
      thermometer, thermometer_quantity,
      examination_table, examination_table_quantity,
      privacy_screen, privacy_screen_quantity,
      actions_agreed
    ) VALUES (
      $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16,
      $17, $18, $19, $20, $21, $22, $23, $24, $25, $26, $27, $28, $29, $30, $31,
      $32, $33, $34, $35, $36, $37, $38, $39, $40, $41, $42, $43, $44, $45, $46, $47
    )
  `;
  
  return client.query(query, [
    visitId,
    data.sphygmomanometer || null, data.sphygmomanometer_quantity || null, data.sphygmomanometer_units || null,
    data.weighing_scale || null, data.weighing_scale_quantity || null, data.weighing_scale_units || null,
    data.measuring_tape || null, data.measuring_tape_quantity || null, data.measuring_tape_units || null,
    data.peak_expiratory_flow_meter || null, data.peak_expiratory_flow_meter_quantity || null, data.peak_expiratory_flow_meter_units || null,
    data.oxygen || null, data.oxygen_quantity || null, data.oxygen_units || null,
    data.oxygen_mask || null, data.oxygen_mask_quantity || null, data.oxygen_mask_units || null,
    data.nebulizer || null, data.nebulizer_quantity || null, data.nebulizer_units || null,
    data.pulse_oximetry || null, data.pulse_oximetry_quantity || null, data.pulse_oximetry_units || null,
    data.glucometer || null, data.glucometer_quantity || null, data.glucometer_units || null,
    data.glucometer_strips || null, data.glucometer_strips_quantity || null, data.glucometer_strips_units || null,
    data.lancets || null, data.lancets_quantity || null, data.lancets_units || null,
    data.urine_dipstick || null, data.urine_dipstick_quantity || null, data.urine_dipstick_units || null,
    data.ecg || null, data.ecg_quantity || null, data.ecg_units || null,
    data.other_equipment || null, data.other_equipment_quantity || null, data.other_equipment_units || null, data.other_equipment_specify || null,
    data.stethoscope || null, data.stethoscope_quantity || null,
    data.thermometer || null, data.thermometer_quantity || null,
    data.examination_table || null, data.examination_table_quantity || null,
    data.privacy_screen || null, data.privacy_screen_quantity || null,
    data.actions_agreed || null
  ]);
}

async function insertVisitMhdcManagementResponses(client, visitId, data) {
  if (!data) return;
  
  const query = `
    INSERT INTO visit_mhdc_management_responses (
      visit_id, b6_response, b6_comment, b6_respondents_comment, b6_healthcare_workers_refer_easily, b6_kept_in_opd_use,
      b7_response, b7_comment, b7_respondents_comment, b7_available_at_health_center,
      b8_response, b8_comment, b8_respondents_comment, b8_available_and_filled_properly,
      b9_response, b9_comment, b9_respondents_comment, b9_available_for_patient_care,
      b10_response, b10_comment, b10_respondents_comment, b10_in_use_for_patient_care,
      b9_chart_version, b9_chart_condition, b10_staff_trained_on_chart, 
      b10_charts_completed_during_visit, b10_risk_stratification_accurate, actions_agreed
    ) VALUES (
      $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18,
      $19, $20, $21, $22, $23, $24, $25, $26
    )
  `;
  
  return client.query(query, [
    visitId,
    data.b6_response || null, data.b6_comment || null, data.b6_respondents_comment || null, 
    data.b6_healthcare_workers_refer_easily || false, data.b6_kept_in_opd_use || false,
    data.b7_response || null, data.b7_comment || null, data.b7_respondents_comment || null, data.b7_available_at_health_center || false,
    data.b8_response || null, data.b8_comment || null, data.b8_respondents_comment || null, data.b8_available_and_filled_properly || false,
    data.b9_response || null, data.b9_comment || null, data.b9_respondents_comment || null, data.b9_available_for_patient_care || false,
    data.b10_response || null, data.b10_comment || null, data.b10_respondents_comment || null, data.b10_in_use_for_patient_care || false,
    data.b9_chart_version || null, data.b9_chart_condition || null, data.b10_staff_trained_on_chart || false,
    data.b10_charts_completed_during_visit || null, data.b10_risk_stratification_accurate || false, data.actions_agreed || null
  ]);
}

async function insertVisitServiceStandardsResponses(client, visitId, data) {
  if (!data) return;
  
  const query = `
    INSERT INTO visit_service_standards_responses (
      visit_id, c2_main_response, c2_main_comment, c2_respondents_comment,
      c2_blood_pressure, c2_blood_pressure_comment, c2_blood_pressure_equipment_calibrated, c2_blood_pressure_protocol_followed,
      c2_blood_sugar, c2_blood_sugar_comment, c2_blood_sugar_strips_available, c2_blood_sugar_quality_control,
      c2_bmi_measurement, c2_bmi_measurement_comment, c2_bmi_calculation_accurate,
      c2_waist_circumference, c2_waist_circumference_comment, c2_waist_measurement_technique_correct,
      c2_cvd_risk_estimation, c2_cvd_risk_estimation_comment, c2_cvd_chart_available_and_used,
      c2_urine_protein_measurement, c2_urine_protein_measurement_comment, c2_urine_protein_strips_not_expired,
      c2_peak_expiratory_flow_rate, c2_peak_expiratory_flow_rate_comment, c2_peak_flow_meter_calibrated,
      c2_egfr_calculation, c2_egfr_calculation_comment, c2_egfr_formula_used_correctly,
      c2_brief_intervention, c2_brief_intervention_comment,
      c2_foot_examination, c2_foot_examination_comment,
      c2_oral_examination, c2_oral_examination_comment,
      c2_eye_examination, c2_eye_examination_comment,
      c2_health_education, c2_health_education_comment,
      c3_response, c3_comment, c3_respondents_comment,
      c4_response, c4_comment, c4_respondents_comment,
      c5_response, c5_comment, c5_respondents_comment,
      c6_response, c6_comment, c6_respondents_comment,
      c7_response, c7_comment, c7_respondents_comment,
      actions_agreed
    ) VALUES (
      $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18,
      $19, $20, $21, $22, $23, $24, $25, $26, $27, $28, $29, $30, $31, $32, $33, $34,
      $35, $36, $37, $38, $39, $40, $41, $42, $43, $44, $45, $46, $47, $48
    )
  `;
  
  return client.query(query, [
    visitId,
    data.c2_main_response || null, data.c2_main_comment || null, data.c2_respondents_comment || null,
    data.c2_blood_pressure || null, data.c2_blood_pressure_comment || null, data.c2_blood_pressure_equipment_calibrated || false, data.c2_blood_pressure_protocol_followed || false,
    data.c2_blood_sugar || null, data.c2_blood_sugar_comment || null, data.c2_blood_sugar_strips_available || false, data.c2_blood_sugar_quality_control || false,
    data.c2_bmi_measurement || null, data.c2_bmi_measurement_comment || null, data.c2_bmi_calculation_accurate || false,
    data.c2_waist_circumference || null, data.c2_waist_circumference_comment || null, data.c2_waist_measurement_technique_correct || false,
    data.c2_cvd_risk_estimation || null, data.c2_cvd_risk_estimation_comment || null, data.c2_cvd_chart_available_and_used || false,
    data.c2_urine_protein_measurement || null, data.c2_urine_protein_measurement_comment || null, data.c2_urine_protein_strips_not_expired || false,
    data.c2_peak_expiratory_flow_rate || null, data.c2_peak_expiratory_flow_rate_comment || null, data.c2_peak_flow_meter_calibrated || false,
    data.c2_egfr_calculation || null, data.c2_egfr_calculation_comment || null, data.c2_egfr_formula_used_correctly || false,
    data.c2_brief_intervention || null, data.c2_brief_intervention_comment || null,
    data.c2_foot_examination || null, data.c2_foot_examination_comment || null,
    data.c2_oral_examination || null, data.c2_oral_examination_comment || null,
    data.c2_eye_examination || null, data.c2_eye_examination_comment || null,
    data.c2_health_education || null, data.c2_health_education_comment || null,
    data.c3_response || null, data.c3_comment || null, data.c3_respondents_comment || null,
    data.c4_response || null, data.c4_comment || null, data.c4_respondents_comment || null,
    data.c5_response || null, data.c5_comment || null, data.c5_respondents_comment || null,
    data.c6_response || null, data.c6_comment || null, data.c6_respondents_comment || null,
    data.c7_response || null, data.c7_comment || null, data.c7_respondents_comment || null,
    data.actions_agreed || null
  ]);
}

async function insertVisitHealthInformationResponses(client, visitId, data) {
  if (!data) return;
  
  const query = `
    INSERT INTO visit_health_information_responses (
      visit_id, d1_response, d1_comment, d1_respondents_comment,
      d2_response, d2_comment, d2_respondents_comment,
      d3_response, d3_comment, d3_respondents_comment,
      d4_response, d4_comment, d4_respondents_comment, d4_number_of_people, d4_previous_month_data,
      d5_response, d5_comment, d5_respondents_comment,
      actions_agreed
    ) VALUES (
      $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19
    )
  `;
  
  return client.query(query, [
    visitId,
    data.d1_response || null, data.d1_comment || null, data.d1_respondents_comment || null,
    data.d2_response || null, data.d2_comment || null, data.d2_respondents_comment || null,
    data.d3_response || null, data.d3_comment || null, data.d3_respondents_comment || null,
    data.d4_response || null, data.d4_comment || null, data.d4_respondents_comment || null, 
    data.d4_number_of_people || null, data.d4_previous_month_data || false,
    data.d5_response || null, data.d5_comment || null, data.d5_respondents_comment || null,
    data.actions_agreed || null
  ]);
}

async function insertVisitIntegrationResponses(client, visitId, data) {
  if (!data) return;
  
  const query = `
    INSERT INTO visit_integration_responses (
      visit_id, e1_response, e1_comment, e1_respondents_comment,
      e2_response, e2_comment, e2_respondents_comment,
      e3_response, e3_comment, e3_respondents_comment,
      actions_agreed
    ) VALUES (
      $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11
    )
  `;
  
  return client.query(query, [
    visitId,
    data.e1_response || null, data.e1_comment || null, data.e1_respondents_comment || null,
    data.e2_response || null, data.e2_comment || null, data.e2_respondents_comment || null,
    data.e3_response || null, data.e3_comment || null, data.e3_respondents_comment || null,
    data.actions_agreed || null
  ]);
}

async function insertVisitMedicineDetail(client, visitId, medicine) {
  if (!medicine) return;
  
  const query = `
    INSERT INTO visit_medicine_details (
      visit_id, medicine_name, medicine_category, availability, quantity_available,
      unit_of_measurement, expiry_date, batch_number, storage_temperature_ok, 
      storage_humidity_ok, storage_location, procurement_source, cost_per_unit,
      last_restocked_date, minimum_stock_level, stock_out_frequency, quality_issues_noted
    ) VALUES (
      $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17
    )
  `;
  
  return client.query(query, [
    visitId,
    medicine.medicine_name || null,
    medicine.medicine_category || null,
    medicine.availability || null,
    medicine.quantity_available || null,
    medicine.unit_of_measurement || null,
    medicine.expiry_date || null,
    medicine.batch_number || null,
    medicine.storage_temperature_ok || false,
    medicine.storage_humidity_ok || false,
    medicine.storage_location || null,
    medicine.procurement_source || null,
    medicine.cost_per_unit || null,
    medicine.last_restocked_date || null,
    medicine.minimum_stock_level || null,
    medicine.stock_out_frequency || null,
    medicine.quality_issues_noted || null
  ]);
}

async function insertVisitPatientVolumes(client, visitId, data) {
  if (!data) return;
  
  const query = `
    INSERT INTO visit_patient_volumes (
      visit_id, total_patients_seen, ncd_patients_new, ncd_patients_followup,
      diabetes_patients, hypertension_patients, copd_patients, cardiovascular_patients,
      other_ncd_patients, referrals_made, referrals_received, emergency_cases,
      month_year, data_source, data_verified
    ) VALUES (
      $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15
    )
  `;
  
  return client.query(query, [
    visitId,
    data.total_patients_seen || null,
    data.ncd_patients_new || null,
    data.ncd_patients_followup || null,
    data.diabetes_patients || null,
    data.hypertension_patients || null,
    data.copd_patients || null,
    data.cardiovascular_patients || null,
    data.other_ncd_patients || null,
    data.referrals_made || null,
    data.referrals_received || null,
    data.emergency_cases || null,
    data.month_year || null,
    data.data_source || null,
    data.data_verified || false
  ]);
}

async function insertVisitEquipmentFunctionality(client, visitId, equipment) {
  if (!equipment) return;
  
  const query = `
    INSERT INTO visit_equipment_functionality (
      visit_id, equipment_name, equipment_category, brand_model, serial_number,
      availability, functionality_status, last_calibration_date, calibration_due_date,
      maintenance_schedule, usage_frequency, staff_trained_on_equipment,
      user_manual_available, spare_parts_available, warranty_status, issues_noted,
      repair_history, procurement_date, cost, funding_source
    ) VALUES (
      $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20
    )
  `;
  
  return client.query(query, [
    visitId,
    equipment.equipment_name || null,
    equipment.equipment_category || null,
    equipment.brand_model || null,
    equipment.serial_number || null,
    equipment.availability || null,
    equipment.functionality_status || null,
    equipment.last_calibration_date || null,
    equipment.calibration_due_date || null,
    equipment.maintenance_schedule || null,
    equipment.usage_frequency || null,
    equipment.staff_trained_on_equipment || false,
    equipment.user_manual_available || false,
    equipment.spare_parts_available || false,
    equipment.warranty_status || null,
    equipment.issues_noted || null,
    equipment.repair_history || null,
    equipment.procurement_date || null,
    equipment.cost || null,
    equipment.funding_source || null
  ]);
}

async function insertVisitQualityAssurance(client, visitId, data) {
  if (!data) return;
  
  const query = `
    INSERT INTO visit_quality_assurance (
      visit_id, guidelines_followed, protocols_updated, clinical_audit_conducted,
      patient_satisfaction_assessed, records_complete, documentation_legible,
      consent_forms_used, privacy_maintained, infection_control_practices,
      hand_hygiene_facilities, emergency_procedures_known, adverse_events_reported,
      staff_knowledge_adequate, continuing_education_provided, supervision_regular,
      overall_quality_score, areas_for_improvement, good_practices_observed
    ) VALUES (
      $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19
    )
  `;
  
  return client.query(query, [
    visitId,
    data.guidelines_followed || false,
    data.protocols_updated || false,
    data.clinical_audit_conducted || false,
    data.patient_satisfaction_assessed || false,
    data.records_complete || false,
    data.documentation_legible || false,
    data.consent_forms_used || false,
    data.privacy_maintained || false,
    data.infection_control_practices || false,
    data.hand_hygiene_facilities || false,
    data.emergency_procedures_known || false,
    data.adverse_events_reported || false,
    data.staff_knowledge_adequate || false,
    data.continuing_education_provided || false,
    data.supervision_regular || false,
    data.overall_quality_score || null,
    data.areas_for_improvement || null,
    data.good_practices_observed || null
  ]);
}

// Helper functions for updating visit section data
async function updateVisitAdminManagementResponses(client, visitId, data) {
  if (!data) return;
  
  const updateFields = [];
  const updateValues = [];
  let paramIndex = 1;

  Object.keys(data).forEach(key => {
    if (data[key] !== undefined) {
      updateFields.push(`${key} = ${paramIndex++}`);
      updateValues.push(data[key]);
    }
  });

  if (updateFields.length === 0) return;

  updateFields.push(`updated_at = CURRENT_TIMESTAMP`);
  updateValues.push(visitId);

  const query = `
    UPDATE visit_admin_management_responses 
    SET ${updateFields.join(', ')}
    WHERE visit_id = ${paramIndex}
  `;

  return client.query(query, updateValues);
}

async function updateVisitLogisticsResponses(client, visitId, data) {
  if (!data) return;
  
  const updateFields = [];
  const updateValues = [];
  let paramIndex = 1;

  Object.keys(data).forEach(key => {
    if (data[key] !== undefined) {
      if (key === 'medicine_quantities' && typeof data[key] === 'object') {
        updateFields.push(`${key} = ${paramIndex++}`);
        updateValues.push(JSON.stringify(data[key]));
      } else {
        updateFields.push(`${key} = ${paramIndex++}`);
        updateValues.push(data[key]);
      }
    }
  });

  if (updateFields.length === 0) return;

  updateValues.push(visitId);

  const query = `
    UPDATE visit_logistics_responses 
    SET ${updateFields.join(', ')}
    WHERE visit_id = ${paramIndex}
  `;

  return client.query(query, updateValues);
}

// Get analytics data for dashboard
router.get('/analytics/dashboard', async (req, res, next) => {
  try {
    // Build user filter for analytics
    let userFilter = '';
    let queryParams = [];
    
    if (req.user.role !== 'admin') {
      userFilter = 'WHERE sf.user_id = $1';
      queryParams.push(req.user.id);
    }

    // Get overall form statistics
    const overallStatsQuery = `
      SELECT 
        COUNT(DISTINCT sf.id) as total_forms,
        COUNT(DISTINCT sv.id) as total_visits,
        COUNT(DISTINCT CASE WHEN sf.sync_status = 'local' THEN sf.id END) as local_forms,
        COUNT(DISTINCT CASE WHEN sf.sync_status = 'synced' THEN sf.id END) as synced_forms,
        COUNT(DISTINCT CASE WHEN sf.sync_status = 'verified' THEN sf.id END) as verified_forms,
        COUNT(DISTINCT sf.province) as provinces_covered,
        COUNT(DISTINCT sf.district) as districts_covered,
        AVG(CASE WHEN sv.visit_number = 4 THEN 1.0 ELSE 0.0 END) * 100 as completion_rate
      FROM supervision_forms sf
      LEFT JOIN supervision_visits sv ON sf.id = sv.form_id
      ${userFilter}
    `;

    const overallStats = await db.query(overallStatsQuery, queryParams);

    // Get recent activity
    const recentActivityQuery = `
      SELECT 
        sf.health_facility_name,
        sf.province,
        sf.district,
        sv.visit_number,
        sv.visit_date,
        u.full_name as doctor_name
      FROM supervision_forms sf
      JOIN users u ON sf.user_id = u.id
      LEFT JOIN supervision_visits sv ON sf.id = sv.form_id
      ${userFilter}
      ORDER BY COALESCE(sv.visit_date, sf.created_at) DESC
      LIMIT 10
    `;

    const recentActivity = await db.query(recentActivityQuery, queryParams);

    // Get facility distribution by province
    const provinceDistributionQuery = `
      SELECT 
        sf.province,
        COUNT(DISTINCT sf.id) as facility_count,
        COUNT(DISTINCT sv.id) as visit_count
      FROM supervision_forms sf
      LEFT JOIN supervision_visits sv ON sf.id = sv.form_id
      ${userFilter}
      GROUP BY sf.province
      ORDER BY facility_count DESC
    `;

    const provinceDistribution = await db.query(provinceDistributionQuery, queryParams);

    res.json({
      overallStats: overallStats.rows[0],
      recentActivity: recentActivity.rows,
      provinceDistribution: provinceDistribution.rows
    });

  } catch (error) {
    next(error);
  }
});

// Get medicine availability analytics
router.get('/analytics/medicines', async (req, res, next) => {
  try {
    let userFilter = '';
    let queryParams = [];
    
    if (req.user.role !== 'admin') {
      userFilter = 'AND sf.user_id = $1';
      queryParams.push(req.user.id);
    }

    const medicineAnalyticsQuery = `
      SELECT 
        vmd.medicine_name,
        vmd.medicine_category,
        COUNT(*) as total_records,
        COUNT(CASE WHEN vmd.availability = 'Y' THEN 1 END) as available_count,
        COUNT(CASE WHEN vmd.availability = 'N' THEN 1 END) as not_available_count,
        ROUND(AVG(CASE WHEN vmd.availability = 'Y' THEN 1.0 ELSE 0.0 END) * 100, 2) as availability_percentage,
        AVG(vmd.quantity_available) as avg_quantity,
        COUNT(CASE WHEN vmd.expiry_date < CURRENT_DATE THEN 1 END) as expired_count,
        COUNT(CASE WHEN vmd.expiry_date BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '6 months' THEN 1 END) as expiring_soon_count
      FROM visit_medicine_details vmd
      JOIN supervision_visits sv ON vmd.visit_id = sv.id
      JOIN supervision_forms sf ON sv.form_id = sf.id
      WHERE vmd.medicine_name IS NOT NULL ${userFilter}
      GROUP BY vmd.medicine_name, vmd.medicine_category
      ORDER BY availability_percentage DESC, vmd.medicine_name
    `;

    const medicineAnalytics = await db.query(medicineAnalyticsQuery, queryParams);

    res.json({
      medicines: medicineAnalytics.rows
    });

  } catch (error) {
    next(error);
  }
});

// Export comprehensive form data
router.get('/:id/export', validateId, async (req, res, next) => {
  try {
    const formId = parseInt(req.params.id);

    // Check permissions
    let userFilter = '';
    let queryParams = [formId];
    
    if (req.user.role !== 'admin') {
      userFilter = 'AND sf.user_id = $2';
      queryParams.push(req.user.id);
    }

    // Use the comprehensive view from migration
    const exportQuery = `
      SELECT * FROM complete_supervision_data 
      WHERE form_id = $1 ${userFilter}
      ORDER BY visit_number
    `;

    const exportResult = await db.query(exportQuery, queryParams);

    if (exportResult.rows.length === 0) {
      return res.status(404).json({
        error: 'Not Found',
        message: 'Supervision form not found or no access'
      });
    }

    res.json({
      export_data: exportResult.rows,
      export_timestamp: new Date().toISOString(),
      total_visits: exportResult.rows.length
    });

  } catch (error) {
    next(error);
  }
});

module.exports = router;