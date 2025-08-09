const express = require('express');
const bcrypt = require('bcryptjs');
const db = require('../config/database');
const { requireAdmin } = require('../middleware/auth');
const { 
  validateUserRegistration, 
  validateUserUpdate, 
  validateId 
} = require('../middleware/validation');

const router = express.Router();

// Get all users (Admin only)
router.get('/', requireAdmin, async (req, res, next) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const offset = (page - 1) * limit;
    const search = req.query.search || '';
    const role = req.query.role || '';
    const isActive = req.query.isActive;

    // Build WHERE clause
    let whereConditions = [];
    let queryParams = [];
    let paramIndex = 1;

    if (search) {
      whereConditions.push(`(username ILIKE $${paramIndex} OR email ILIKE $${paramIndex} OR full_name ILIKE $${paramIndex})`);
      queryParams.push(`%${search}%`);
      paramIndex++;
    }

    if (role) {
      whereConditions.push(`role = $${paramIndex}`);
      queryParams.push(role);
      paramIndex++;
    }

    if (isActive !== undefined) {
      whereConditions.push(`is_active = $${paramIndex}`);
      queryParams.push(isActive === 'true');
      paramIndex++;
    }

    const whereClause = whereConditions.length > 0 ? `WHERE ${whereConditions.join(' AND ')}` : '';

    // Get total count
    const countQuery = `
      SELECT COUNT(*) as total 
      FROM users 
      ${whereClause}
    `;
    const countResult = await db.query(countQuery, queryParams);
    const totalUsers = parseInt(countResult.rows[0].total);

    // Get users with pagination
    const usersQuery = `
      SELECT id, username, email, full_name, role, is_active, created_at, updated_at
      FROM users 
      ${whereClause}
      ORDER BY created_at DESC
      LIMIT $${paramIndex} OFFSET $${paramIndex + 1}
    `;
    
    queryParams.push(limit, offset);
    const usersResult = await db.query(usersQuery, queryParams);

    const totalPages = Math.ceil(totalUsers / limit);

    res.json({
      users: usersResult.rows.map(user => ({
        id: user.id,
        username: user.username,
        email: user.email,
        fullName: user.full_name,
        role: user.role,
        isActive: user.is_active,
        createdAt: user.created_at,
        updatedAt: user.updated_at
      })),
      pagination: {
        currentPage: page,
        totalPages,
        totalUsers,
        hasNextPage: page < totalPages,
        hasPrevPage: page > 1
      }
    });

  } catch (error) {
    next(error);
  }
});

// Get user by ID (Admin only)
router.get('/:id', requireAdmin, validateId, async (req, res, next) => {
  try {
    const userId = parseInt(req.params.id);

    const userQuery = `
      SELECT id, username, email, full_name, role, is_active, created_at, updated_at
      FROM users 
      WHERE id = $1
    `;

    const result = await db.query(userQuery, [userId]);

    if (result.rows.length === 0) {
      return res.status(404).json({
        error: 'Not Found',
        message: 'User not found'
      });
    }

    const user = result.rows[0];

    res.json({
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        fullName: user.full_name,
        role: user.role,
        isActive: user.is_active,
        createdAt: user.created_at,
        updatedAt: user.updated_at
      }
    });

  } catch (error) {
    next(error);
  }
});

// Create new user (Admin only)
router.post('/', requireAdmin, validateUserRegistration, async (req, res, next) => {
  try {
    const { username, email, password, fullName, role = 'user' } = req.body;

    // Check if user already exists
    const existingUserQuery = `
      SELECT id FROM users 
      WHERE username = $1 OR email = $2
    `;
    const existingUser = await db.query(existingUserQuery, [username, email]);

    if (existingUser.rows.length > 0) {
      return res.status(409).json({
        error: 'Conflict',
        message: 'Username or email already exists'
      });
    }

    // Hash password
    const saltRounds = 12;
    const hashedPassword = await bcrypt.hash(password, saltRounds);

    // Insert new user
    const insertUserQuery = `
      INSERT INTO users (username, email, password_hash, full_name, role, created_at, updated_at)
      VALUES ($1, $2, $3, $4, $5, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
      RETURNING id, username, email, full_name, role, is_active, created_at
    `;

    const result = await db.query(insertUserQuery, [
      username,
      email,
      hashedPassword,
      fullName,
      role
    ]);

    const newUser = result.rows[0];

    res.status(201).json({
      message: 'User created successfully',
      user: {
        id: newUser.id,
        username: newUser.username,
        email: newUser.email,
        fullName: newUser.full_name,
        role: newUser.role,
        isActive: newUser.is_active,
        createdAt: newUser.created_at
      }
    });

  } catch (error) {
    next(error);
  }
});

// Update user (Admin only)
router.put('/:id', requireAdmin, validateId, validateUserUpdate, async (req, res, next) => {
  try {
    const userId = parseInt(req.params.id);
    const { username, email, fullName, role, isActive } = req.body;

    // Check if user exists
    const existingUserQuery = `
      SELECT id FROM users WHERE id = $1
    `;
    const existingUser = await db.query(existingUserQuery, [userId]);

    if (existingUser.rows.length === 0) {
      return res.status(404).json({
        error: 'Not Found',
        message: 'User not found'
      });
    }

    // Check for duplicate username/email (excluding current user)
    if (username || email) {
      const duplicateQuery = `
        SELECT id FROM users 
        WHERE (username = $1 OR email = $2) AND id != $3
      `;
      const duplicateResult = await db.query(duplicateQuery, [
        username || '', 
        email || '', 
        userId
      ]);

      if (duplicateResult.rows.length > 0) {
        return res.status(409).json({
          error: 'Conflict',
          message: 'Username or email already exists'
        });
      }
    }

    // Build update query dynamically
    const updateFields = [];
    const queryParams = [];
    let paramIndex = 1;

    if (username !== undefined) {
      updateFields.push(`username = $${paramIndex}`);
      queryParams.push(username);
      paramIndex++;
    }

    if (email !== undefined) {
      updateFields.push(`email = $${paramIndex}`);
      queryParams.push(email);
      paramIndex++;
    }

    if (fullName !== undefined) {
      updateFields.push(`full_name = $${paramIndex}`);
      queryParams.push(fullName);
      paramIndex++;
    }

    if (role !== undefined) {
      updateFields.push(`role = $${paramIndex}`);
      queryParams.push(role);
      paramIndex++;
    }

    if (isActive !== undefined) {
      updateFields.push(`is_active = $${paramIndex}`);
      queryParams.push(isActive);
      paramIndex++;
    }

    if (updateFields.length === 0) {
      return res.status(400).json({
        error: 'Bad Request',
        message: 'No fields to update'
      });
    }

    updateFields.push(`updated_at = CURRENT_TIMESTAMP`);
    queryParams.push(userId);

    const updateQuery = `
      UPDATE users 
      SET ${updateFields.join(', ')}
      WHERE id = $${paramIndex}
      RETURNING id, username, email, full_name, role, is_active, updated_at
    `;

    const result = await db.query(updateQuery, queryParams);
    const updatedUser = result.rows[0];

    res.json({
      message: 'User updated successfully',
      user: {
        id: updatedUser.id,
        username: updatedUser.username,
        email: updatedUser.email,
        fullName: updatedUser.full_name,
        role: updatedUser.role,
        isActive: updatedUser.is_active,
        updatedAt: updatedUser.updated_at
      }
    });

  } catch (error) {
    next(error);
  }
});

// Delete user (Admin only) - Soft delete
router.delete('/:id', requireAdmin, validateId, async (req, res, next) => {
  try {
    const userId = parseInt(req.params.id);

    // Prevent admin from deleting themselves
    if (userId === req.user.id) {
      return res.status(400).json({
        error: 'Bad Request',
        message: 'You cannot delete your own account'
      });
    }

    // Check if user exists
    const existingUserQuery = `
      SELECT id FROM users WHERE id = $1
    `;
    const existingUser = await db.query(existingUserQuery, [userId]);

    if (existingUser.rows.length === 0) {
      return res.status(404).json({
        error: 'Not Found',
        message: 'User not found'
      });
    }

    // Soft delete by setting is_active to false
    const deleteQuery = `
      UPDATE users 
      SET is_active = false, updated_at = CURRENT_TIMESTAMP
      WHERE id = $1
      RETURNING id, username
    `;

    const result = await db.query(deleteQuery, [userId]);
    const deletedUser = result.rows[0];

    res.json({
      message: 'User deleted successfully',
      user: {
        id: deletedUser.id,
        username: deletedUser.username
      }
    });

  } catch (error) {
    next(error);
  }
});

// Restore user (Admin only)
router.put('/:id/restore', requireAdmin, validateId, async (req, res, next) => {
  try {
    const userId = parseInt(req.params.id);

    // Check if user exists
    const existingUserQuery = `
      SELECT id, username, is_active FROM users WHERE id = $1
    `;
    const existingUser = await db.query(existingUserQuery, [userId]);

    if (existingUser.rows.length === 0) {
      return res.status(404).json({
        error: 'Not Found',
        message: 'User not found'
      });
    }

    const user = existingUser.rows[0];

    if (user.is_active) {
      return res.status(400).json({
        error: 'Bad Request',
        message: 'User is already active'
      });
    }

    // Restore user by setting is_active to true
    const restoreQuery = `
      UPDATE users 
      SET is_active = true, updated_at = CURRENT_TIMESTAMP
      WHERE id = $1
      RETURNING id, username
    `;

    const result = await db.query(restoreQuery, [userId]);
    const restoredUser = result.rows[0];

    res.json({
      message: 'User restored successfully',
      user: {
        id: restoredUser.id,
        username: restoredUser.username
      }
    });

  } catch (error) {
    next(error);
  }
});

// Reset user password (Admin only)
router.put('/:id/reset-password', requireAdmin, validateId, async (req, res, next) => {
  try {
    const userId = parseInt(req.params.id);
    const { newPassword } = req.body;

    if (!newPassword || newPassword.length < 8) {
      return res.status(400).json({
        error: 'Bad Request',
        message: 'New password must be at least 8 characters long'
      });
    }

    // Check if user exists
    const existingUserQuery = `
      SELECT id FROM users WHERE id = $1
    `;
    const existingUser = await db.query(existingUserQuery, [userId]);

    if (existingUser.rows.length === 0) {
      return res.status(404).json({
        error: 'Not Found',
        message: 'User not found'
      });
    }

    // Hash new password
    const saltRounds = 12;
    const hashedPassword = await bcrypt.hash(newPassword, saltRounds);

    // Update password
    const updateQuery = `
      UPDATE users 
      SET password_hash = $1, updated_at = CURRENT_TIMESTAMP
      WHERE id = $2
    `;

    await db.query(updateQuery, [hashedPassword, userId]);

    res.json({
      message: 'Password reset successfully'
    });

  } catch (error) {
    next(error);
  }
});

module.exports = router;