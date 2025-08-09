const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const rateLimit = require('express-rate-limit');

const db = require('../config/database');
const { 
  validateUserRegistration, 
  validateUserLogin, 
  validatePasswordChange,
  validateRefreshToken 
} = require('../middleware/validation');
const { authenticateToken, verifyRefreshToken } = require('../middleware/auth');

const router = express.Router();

// Rate limiting for auth endpoints
const authLimiter = rateLimit({
  windowMs: 3 * 60 * 1000, // 3 minutes
  max: 5, // Limit each IP to 5 requests per windowMs
  message: {
    error: 'Too Many Requests',
    message: 'Too many authentication attempts, please try again later.'
  },
  standardHeaders: true,
  legacyHeaders: false,
});

// Helper function to generate tokens
const generateTokens = (user) => {
  const payload = {
    userId: user.id,
    username: user.username,
    role: user.role
  };

  const accessToken = jwt.sign(payload, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || '24h'
  });

  const refreshToken = jwt.sign(payload, process.env.JWT_REFRESH_SECRET, {
    expiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '7d'
  });

  return { accessToken, refreshToken };
};

// Register new user (Admin only in production, open for development)
router.post('/register', validateUserRegistration, async (req, res, next) => {
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
      RETURNING id, username, email, full_name, role, created_at
    `;

    const result = await db.query(insertUserQuery, [
      username,
      email,
      hashedPassword,
      fullName,
      role
    ]);

    const newUser = result.rows[0];

    // Generate tokens
    const { accessToken, refreshToken } = generateTokens(newUser);

    res.status(201).json({
      message: 'User registered successfully',
      user: {
        id: newUser.id,
        username: newUser.username,
        email: newUser.email,
        fullName: newUser.full_name,
        role: newUser.role,
        createdAt: newUser.created_at
      },
      accessToken,
      refreshToken
    });

  } catch (error) {
    next(error);
  }
});

// Login user
router.post('/login', authLimiter, validateUserLogin, async (req, res, next) => {
  try {
    const { username, password } = req.body;

    // Find user by username or email
    const userQuery = `
      SELECT id, username, email, password_hash, full_name, role, is_active
      FROM users 
      WHERE (username = $1 OR email = $1) AND is_active = true
    `;

    const result = await db.query(userQuery, [username]);

    if (result.rows.length === 0) {
      return res.status(401).json({
        error: 'Unauthorized',
        message: 'Invalid credentials'
      });
    }

    const user = result.rows[0];

    // Verify password
    const isPasswordValid = await bcrypt.compare(password, user.password_hash);

    if (!isPasswordValid) {
      return res.status(401).json({
        error: 'Unauthorized',
        message: 'Invalid credentials'
      });
    }

    // Generate tokens
    const { accessToken, refreshToken } = generateTokens(user);

    // Update last login time
    await db.query(
      'UPDATE users SET updated_at = CURRENT_TIMESTAMP WHERE id = $1',
      [user.id]
    );

    res.json({
      message: 'Login successful',
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        fullName: user.full_name,
        role: user.role
      },
      accessToken,
      refreshToken
    });

  } catch (error) {
    next(error);
  }
});

// Refresh access token
router.post('/refresh', validateRefreshToken, verifyRefreshToken, async (req, res, next) => {
  try {
    // Generate new tokens
    const { accessToken, refreshToken } = generateTokens(req.user);

    res.json({
      message: 'Token refreshed successfully',
      accessToken,
      refreshToken
    });

  } catch (error) {
    next(error);
  }
});

// Logout (Client-side token removal)
router.post('/logout', authenticateToken, async (req, res, next) => {
  try {
    // In a more complex setup, you might want to blacklist the token
    // For now, we'll just return a success message
    // The client should remove the token from storage

    res.json({
      message: 'Logout successful'
    });

  } catch (error) {
    next(error);
  }
});

// Get current user profile
router.get('/profile', authenticateToken, async (req, res, next) => {
  try {
    const userQuery = `
      SELECT id, username, email, full_name, role, created_at, updated_at
      FROM users 
      WHERE id = $1 AND is_active = true
    `;

    const result = await db.query(userQuery, [req.user.id]);

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
        createdAt: user.created_at,
        updatedAt: user.updated_at
      }
    });

  } catch (error) {
    next(error);
  }
});

// Change password
router.put('/change-password', authenticateToken, validatePasswordChange, async (req, res, next) => {
  try {
    const { currentPassword, newPassword } = req.body;

    // Get current user's password hash
    const userQuery = `
      SELECT password_hash FROM users 
      WHERE id = $1 AND is_active = true
    `;

    const result = await db.query(userQuery, [req.user.id]);

    if (result.rows.length === 0) {
      return res.status(404).json({
        error: 'Not Found',
        message: 'User not found'
      });
    }

    const user = result.rows[0];

    // Verify current password
    const isCurrentPasswordValid = await bcrypt.compare(currentPassword, user.password_hash);

    if (!isCurrentPasswordValid) {
      return res.status(400).json({
        error: 'Bad Request',
        message: 'Current password is incorrect'
      });
    }

    // Hash new password
    const saltRounds = 12;
    const hashedNewPassword = await bcrypt.hash(newPassword, saltRounds);

    // Update password
    const updateQuery = `
      UPDATE users 
      SET password_hash = $1, updated_at = CURRENT_TIMESTAMP
      WHERE id = $2
    `;

    await db.query(updateQuery, [hashedNewPassword, req.user.id]);

    res.json({
      message: 'Password changed successfully'
    });

  } catch (error) {
    next(error);
  }
});

// Verify token (for mobile app sync)
router.post('/verify', authenticateToken, async (req, res, next) => {
  try {
    res.json({
      message: 'Token is valid',
      user: {
        id: req.user.id,
        username: req.user.username,
        email: req.user.email,
        fullName: req.user.fullName,
        role: req.user.role
      }
    });

  } catch (error) {
    next(error);
  }
});

module.exports = router;