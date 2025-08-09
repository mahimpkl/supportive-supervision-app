const jwt = require('jsonwebtoken');
const db = require('../config/database');

// Authenticate JWT token
const authenticateToken = async (req, res, next) => {
  try {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

    if (!token) {
      return res.status(401).json({
        error: 'Unauthorized',
        message: 'Access token is required'
      });
    }

    // Verify the token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    // Check if user still exists and is active
    const userQuery = `
      SELECT id, username, email, role, full_name, is_active 
      FROM users 
      WHERE id = $1 AND is_active = true
    `;
    
    const result = await db.query(userQuery, [decoded.userId]);
    
    if (result.rows.length === 0) {
      return res.status(401).json({
        error: 'Unauthorized',
        message: 'User not found or inactive'
      });
    }

    // Add user info to request object
    req.user = {
      id: result.rows[0].id,
      username: result.rows[0].username,
      email: result.rows[0].email,
      role: result.rows[0].role,
      fullName: result.rows[0].full_name
    };

    next();
  } catch (error) {
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({
        error: 'Unauthorized',
        message: 'Invalid token'
      });
    }
    
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        error: 'Unauthorized',
        message: 'Token expired'
      });
    }

    console.error('Auth middleware error:', error);
    return res.status(500).json({
      error: 'Internal Server Error',
      message: 'Authentication failed'
    });
  }
};

// Check if user is admin
const requireAdmin = (req, res, next) => {
  if (req.user.role !== 'admin') {
    return res.status(403).json({
      error: 'Forbidden',
      message: 'Admin access required'
    });
  }
  next();
};

// Check if user can modify resource (admin or resource owner)
const canModifyResource = (userIdField = 'user_id') => {
  return (req, res, next) => {
    // Admin can modify any resource
    if (req.user.role === 'admin') {
      return next();
    }

    // Check if the resource belongs to the user
    const resourceUserId = req.body[userIdField] || req.params.userId;
    
    if (parseInt(resourceUserId) !== req.user.id) {
      return res.status(403).json({
        error: 'Forbidden',
        message: 'You can only modify your own resources'
      });
    }

    next();
  };
};

// Verify refresh token
const verifyRefreshToken = async (req, res, next) => {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      return res.status(401).json({
        error: 'Unauthorized',
        message: 'Refresh token is required'
      });
    }

    // Verify the refresh token
    const decoded = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET);
    
    // Check if user exists
    const userQuery = `
      SELECT id, username, email, role, full_name, is_active 
      FROM users 
      WHERE id = $1 AND is_active = true
    `;
    
    const result = await db.query(userQuery, [decoded.userId]);
    
    if (result.rows.length === 0) {
      return res.status(401).json({
        error: 'Unauthorized',
        message: 'User not found or inactive'
      });
    }

    req.user = {
      id: result.rows[0].id,
      username: result.rows[0].username,
      email: result.rows[0].email,
      role: result.rows[0].role,
      fullName: result.rows[0].full_name
    };

    next();
  } catch (error) {
    if (error.name === 'JsonWebTokenError' || error.name === 'TokenExpiredError') {
      return res.status(401).json({
        error: 'Unauthorized',
        message: 'Invalid or expired refresh token'
      });
    }

    console.error('Refresh token verification error:', error);
    return res.status(500).json({
      error: 'Internal Server Error',
      message: 'Token verification failed'
    });
  }
};

module.exports = {
  authenticateToken,
  requireAdmin,
  canModifyResource,
  verifyRefreshToken
};