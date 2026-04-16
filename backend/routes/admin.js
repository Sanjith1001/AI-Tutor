const express = require('express');
const { body, validationResult, query } = require('express-validator');
const User = require('../models/User');
const Course = require('../models/Course');
const AnalyticsService = require('../services/analytics_service');
const NotificationService = require('../services/notification_service');
const { auth, authorize } = require('../middleware/auth');

const router = express.Router();

// @route   GET /api/admin/dashboard
// @desc    Get admin dashboard overview
// @access  Private/Admin
router.get('/dashboard', [auth, authorize('admin')], async (req, res) => {
  try {
    const analytics = await AnalyticsService.getPlatformAnalytics();
    
    if (!analytics.success) {
      return res.status(500).json({
        success: false,
        message: analytics.message
      });
    }

    // Get recent activities
    const recentUsers = await User.find()
      .sort({ createdAt: -1 })
      .limit(5)
      .select('fullName email createdAt lastLoginAt');

    const recentCourses = await Course.find()
      .sort({ createdAt: -1 })
      .limit(5)
      .select('title category createdAt isPublished enrollmentCount')
      .populate('createdBy', 'fullName');

    res.json({
      success: true,
      data: {
        ...analytics.data,
        recentUsers,
        recentCourses
      }
    });
  } catch (error) {
    console.error('Admin dashboard error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   GET /api/admin/users
// @desc    Get all users with pagination and filtering
// @access  Private/Admin
router.get('/users', [
  auth,
  authorize('admin'),
  query('page').optional().isInt({ min: 1 }).withMessage('Page must be a positive integer'),
  query('limit').optional().isInt({ min: 1, max: 100 }).withMessage('Limit must be between 1 and 100'),
  query('search').optional().isString().withMessage('Search must be a string'),
  query('role').optional().isIn(['student', 'teacher', 'admin']).withMessage('Invalid role'),
  query('status').optional().isIn(['active', 'inactive']).withMessage('Invalid status')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const {
      page = 1,
      limit = 20,
      search,
      role,
      status
    } = req.query;

    // Build query
    const query = {};
    
    if (search) {
      query.$or = [
        { fullName: { $regex: search, $options: 'i' } },
        { email: { $regex: search, $options: 'i' } }
      ];
    }
    
    if (role) query.role = role;
    if (status === 'active') {
      query.lastLoginAt = { $gte: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000) };
    } else if (status === 'inactive') {
      query.$or = [
        { lastLoginAt: { $lt: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000) } },
        { lastLoginAt: { $exists: false } }
      ];
    }

    const users = await User.find(query)
      .select('-password -refreshToken')
      .sort({ createdAt: -1 })
      .limit(parseInt(limit))
      .skip((parseInt(page) - 1) * parseInt(limit));

    const totalUsers = await User.countDocuments(query);

    res.json({
      success: true,
      data: {
        users,
        pagination: {
          currentPage: parseInt(page),
          totalPages: Math.ceil(totalUsers / parseInt(limit)),
          totalUsers,
          hasNext: parseInt(page) < Math.ceil(totalUsers / parseInt(limit)),
          hasPrev: parseInt(page) > 1
        }
      }
    });
  } catch (error) {
    console.error('Get users error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   PUT /api/admin/users/:id
// @desc    Update user details
// @access  Private/Admin
router.put('/users/:id', [
  auth,
  authorize('admin'),
  body('fullName').optional().trim().isLength({ min: 1, max: 100 }).withMessage('Full name is required'),
  body('email').optional().isEmail().withMessage('Valid email is required'),
  body('role').optional().isIn(['student', 'teacher', 'admin']).withMessage('Invalid role')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const user = await User.findById(req.params.id);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Check if email is already taken (if email is being updated)
    if (req.body.email && req.body.email !== user.email) {
      const existingUser = await User.findOne({ email: req.body.email });
      if (existingUser) {
        return res.status(400).json({
          success: false,
          message: 'Email already exists'
        });
      }
    }

    const updatedUser = await User.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    ).select('-password -refreshToken');

    res.json({
      success: true,
      message: 'User updated successfully',
      data: { user: updatedUser }
    });
  } catch (error) {
    console.error('Update user error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   DELETE /api/admin/users/:id
// @desc    Delete user
// @access  Private/Admin
router.delete('/users/:id', [auth, authorize('admin')], async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Prevent admin from deleting themselves
    if (req.params.id === req.user.id) {
      return res.status(400).json({
        success: false,
        message: 'Cannot delete your own account'
      });
    }

    await User.findByIdAndDelete(req.params.id);

    res.json({
      success: true,
      message: 'User deleted successfully'
    });
  } catch (error) {
    console.error('Delete user error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   GET /api/admin/courses
// @desc    Get all courses for admin management
// @access  Private/Admin
router.get('/courses', [
  auth,
  authorize('admin'),
  query('page').optional().isInt({ min: 1 }).withMessage('Page must be a positive integer'),
  query('limit').optional().isInt({ min: 1, max: 100 }).withMessage('Limit must be between 1 and 100'),
  query('search').optional().isString().withMessage('Search must be a string'),
  query('category').optional().isString().withMessage('Category must be a string'),
  query('status').optional().isIn(['draft', 'published', 'archived']).withMessage('Invalid status')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const {
      page = 1,
      limit = 20,
      search,
      category,
      status
    } = req.query;

    // Build query
    const query = {};
    
    if (search) {
      query.$or = [
        { title: { $regex: search, $options: 'i' } },
        { description: { $regex: search, $options: 'i' } }
      ];
    }
    
    if (category) query.category = category;
    if (status === 'published') query.isPublished = true;
    if (status === 'draft') query.isPublished = false;
    if (status === 'archived') query.isActive = false;

    const courses = await Course.find(query)
      .populate('createdBy', 'fullName email')
      .sort({ createdAt: -1 })
      .limit(parseInt(limit))
      .skip((parseInt(page) - 1) * parseInt(limit));

    const totalCourses = await Course.countDocuments(query);

    res.json({
      success: true,
      data: {
        courses,
        pagination: {
          currentPage: parseInt(page),
          totalPages: Math.ceil(totalCourses / parseInt(limit)),
          totalCourses,
          hasNext: parseInt(page) < Math.ceil(totalCourses / parseInt(limit)),
          hasPrev: parseInt(page) > 1
        }
      }
    });
  } catch (error) {
    console.error('Get admin courses error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   PUT /api/admin/courses/:id/publish
// @desc    Publish/unpublish a course
// @access  Private/Admin
router.put('/courses/:id/publish', [auth, authorize('admin')], async (req, res) => {
  try {
    const { isPublished } = req.body;
    
    const course = await Course.findById(req.params.id);
    if (!course) {
      return res.status(404).json({
        success: false,
        message: 'Course not found'
      });
    }

    course.isPublished = isPublished;
    if (isPublished && !course.publishedAt) {
      course.publishedAt = new Date();
    }
    
    await course.save();

    res.json({
      success: true,
      message: `Course ${isPublished ? 'published' : 'unpublished'} successfully`,
      data: { course }
    });
  } catch (error) {
    console.error('Publish course error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   GET /api/admin/analytics/course/:id
// @desc    Get detailed course analytics
// @access  Private/Admin
router.get('/analytics/course/:id', [auth, authorize('admin')], async (req, res) => {
  try {
    const analytics = await AnalyticsService.getCourseAnalytics(req.params.id);
    
    if (!analytics.success) {
      return res.status(404).json({
        success: false,
        message: analytics.message
      });
    }

    res.json(analytics);
  } catch (error) {
    console.error('Get course analytics error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   GET /api/admin/analytics/user/:id
// @desc    Get detailed user analytics
// @access  Private/Admin
router.get('/analytics/user/:id', [auth, authorize('admin')], async (req, res) => {
  try {
    const analytics = await AnalyticsService.getUserAnalytics(req.params.id);
    
    if (!analytics.success) {
      return res.status(404).json({
        success: false,
        message: analytics.message
      });
    }

    res.json(analytics);
  } catch (error) {
    console.error('Get user analytics error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   POST /api/admin/notifications/send
// @desc    Send bulk notification to users
// @access  Private/Admin
router.post('/notifications/send', [
  auth,
  authorize('admin'),
  body('userIds').isArray().withMessage('User IDs must be an array'),
  body('subject').trim().isLength({ min: 1 }).withMessage('Subject is required'),
  body('message').trim().isLength({ min: 1 }).withMessage('Message is required'),
  body('type').optional().isIn(['general', 'announcement', 'maintenance']).withMessage('Invalid notification type')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const { userIds, subject, message, type = 'general' } = req.body;

    const result = await NotificationService.sendBulkNotification(
      userIds,
      subject,
      message,
      type
    );

    res.json(result);
  } catch (error) {
    console.error('Send bulk notification error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   GET /api/admin/system/health
// @desc    Get system health status
// @access  Private/Admin
router.get('/system/health', [auth, authorize('admin')], async (req, res) => {
  try {
    const mongoose = require('mongoose');
    
    // Check database connection
    const dbStatus = mongoose.connection.readyState === 1 ? 'connected' : 'disconnected';
    
    // Get system stats
    const totalUsers = await User.countDocuments();
    const totalCourses = await Course.countDocuments();
    const publishedCourses = await Course.countDocuments({ isPublished: true });
    
    // Memory usage
    const memoryUsage = process.memoryUsage();
    
    // Uptime
    const uptime = process.uptime();
    
    res.json({
      success: true,
      data: {
        status: 'healthy',
        timestamp: new Date().toISOString(),
        database: {
          status: dbStatus,
          name: mongoose.connection.name
        },
        statistics: {
          totalUsers,
          totalCourses,
          publishedCourses
        },
        system: {
          uptime: Math.floor(uptime),
          memory: {
            used: Math.round(memoryUsage.heapUsed / 1024 / 1024),
            total: Math.round(memoryUsage.heapTotal / 1024 / 1024),
            external: Math.round(memoryUsage.external / 1024 / 1024)
          },
          nodeVersion: process.version,
          platform: process.platform
        }
      }
    });
  } catch (error) {
    console.error('System health check error:', error);
    res.status(500).json({
      success: false,
      message: 'System health check failed',
      error: error.message
    });
  }
});

// @route   POST /api/admin/system/backup
// @desc    Create system backup (placeholder)
// @access  Private/Admin
router.post('/system/backup', [auth, authorize('admin')], async (req, res) => {
  try {
    // This is a placeholder for backup functionality
    // In a real implementation, you would:
    // 1. Create database backup
    // 2. Backup uploaded files
    // 3. Store backup in cloud storage
    // 4. Return backup information
    
    const backupId = `backup_${Date.now()}`;
    
    res.json({
      success: true,
      message: 'Backup created successfully',
      data: {
        backupId,
        createdAt: new Date().toISOString(),
        status: 'completed',
        size: '0 MB', // Placeholder
        location: 'cloud-storage' // Placeholder
      }
    });
  } catch (error) {
    console.error('System backup error:', error);
    res.status(500).json({
      success: false,
      message: 'Backup creation failed'
    });
  }
});

module.exports = router;