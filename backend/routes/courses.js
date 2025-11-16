const express = require('express');
const { body, validationResult, query } = require('express-validator');
const Course = require('../models/Course');
const User = require('../models/User');
const { auth, authorize, optionalAuth } = require('../middleware/auth');
const CacheService = require('../services/cache_service');

const router = express.Router();

// @route   GET /api/courses
// @desc    Get all published courses with filtering and pagination
// @access  Public
router.get('/', [
  query('page').optional().isInt({ min: 1 }).withMessage('Page must be a positive integer'),
  query('limit').optional().isInt({ min: 1, max: 50 }).withMessage('Limit must be between 1 and 50'),
  query('category').optional().isString().withMessage('Category must be a string'),
  query('difficulty').optional().isIn(['beginner', 'intermediate', 'advanced']).withMessage('Invalid difficulty level'),
  query('search').optional().isString().withMessage('Search must be a string'),
  query('sort').optional().isIn(['newest', 'oldest', 'popular', 'rating']).withMessage('Invalid sort option'),
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array(),
      });
    }

    const {
      page = 1,
      limit = 12,
      category,
      difficulty,
      search,
      sort = 'newest',
      isFree
    } = req.query;

    // Check cache for search results
    const cacheKey = CacheService.generateKey('courses', page, limit, category, difficulty, search, sort, isFree);
    const cachedResult = CacheService.get(cacheKey);
    
    if (cachedResult) {
      return res.json({
        ...cachedResult,
        cached: true,
        cacheTime: new Date().toISOString()
      });
    }

    // Build query
    const query = { isPublished: true, isActive: true };
    
    if (category) query.category = category;
    if (difficulty) query.difficulty = difficulty;
    if (isFree !== undefined) query.isFree = isFree === 'true';
    
    // Handle search
    if (search) {
      query.$text = { $search: search };
    }

    // Build sort
    let sortOption = {};
    switch (sort) {
      case 'oldest':
        sortOption = { createdAt: 1 };
        break;
      case 'popular':
        sortOption = { enrollmentCount: -1, averageRating: -1 };
        break;
      case 'rating':
        sortOption = { averageRating: -1, totalRatings: -1 };
        break;
      case 'newest':
      default:
        sortOption = { createdAt: -1 };
        break;
    }
    
    if (search) {
      sortOption = { score: { $meta: 'textScore' }, ...sortOption };
    }

    const courses = await Course.find(query)
      .populate('createdBy', 'firstName lastName email')
      .populate('instructors', 'firstName lastName email')
      .sort(sortOption)
      .limit(parseInt(limit))
      .skip((parseInt(page) - 1) * parseInt(limit))
      .select('-enrolledStudents -ratings'); // Exclude sensitive data

    const totalCourses = await Course.countDocuments(query);

    const result = {
      success: true,
      data: {
        courses,
        pagination: {
          currentPage: parseInt(page),
          totalPages: Math.ceil(totalCourses / parseInt(limit)),
          totalCourses,
          hasNext: parseInt(page) < Math.ceil(totalCourses / parseInt(limit)),
          hasPrev: parseInt(page) > 1,
        },
      },
    };

    // Cache the result for 5 minutes
    CacheService.set(cacheKey, result, 5 * 60 * 1000);

    res.json(result);
  } catch (error) {
    console.error('Get courses error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// @route   GET /api/courses/:id
// @desc    Get single course by ID
// @access  Public
router.get('/:id', optionalAuth, async (req, res) => {
  try {
    const course = await Course.findById(req.params.id)
      .populate('createdBy', 'firstName lastName email bio')
      .populate('instructors', 'firstName lastName email bio')
      .populate('ratings.user', 'firstName lastName');

    if (!course) {
      return res.status(404).json({
        success: false,
        message: 'Course not found',
      });
    }

    // Check if user is enrolled (if authenticated)
    let isEnrolled = false;
    let userProgress = null;
    
    if (req.user) {
      const enrollment = course.enrolledStudents.find(
        e => e.user.toString() === req.user.id
      );
      
      if (enrollment) {
        isEnrolled = true;
        userProgress = {
          progress: enrollment.progress,
          completedModules: enrollment.completedModules,
          lastAccessedAt: enrollment.lastAccessedAt,
          certificateIssued: enrollment.certificateIssued
        };
      }
    }

    // Increment view count
    await Course.findByIdAndUpdate(req.params.id, { $inc: { views: 1 } });

    // Remove sensitive enrollment data for non-enrolled users
    const courseData = course.toObject();
    if (!isEnrolled) {
      courseData.enrolledStudents = [];
    }

    res.json({
      success: true,
      data: {
        course: courseData,
        isEnrolled,
        userProgress,
      },
    });
  } catch (error) {
    console.error('Get course error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// @route   POST /api/courses/:id/enroll
// @desc    Enroll in a course
// @access  Private
router.post('/:id/enroll', auth, async (req, res) => {
  try {
    const course = await Course.findById(req.params.id);
    
    if (!course) {
      return res.status(404).json({
        success: false,
        message: 'Course not found',
      });
    }

    if (!course.isPublished || !course.isActive) {
      return res.status(400).json({
        success: false,
        message: 'Course is not available for enrollment',
      });
    }

    // Check if already enrolled
    const existingEnrollment = course.enrolledStudents.find(
      e => e.user.toString() === req.user.id
    );

    if (existingEnrollment) {
      return res.status(400).json({
        success: false,
        message: 'Already enrolled in this course',
      });
    }

    await course.enroll(req.user.id);

    // Update user's enrolled courses
    await User.findByIdAndUpdate(req.user.id, {
      $addToSet: { coursesEnrolled: req.params.id }
    });

    res.json({
      success: true,
      message: 'Successfully enrolled in course',
    });
  } catch (error) {
    console.error('Enroll course error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// @route   POST /api/courses
// @desc    Create a new course (for testing)
// @access  Private
router.post('/', auth, async (req, res) => {
  try {
    const courseData = {
      ...req.body,
      createdBy: req.user.id,
      instructors: [req.user.id],
      isPublished: true,
      isActive: true
    };

    const course = await Course.create(courseData);
    
    await course.populate('createdBy', 'firstName lastName email');

    res.status(201).json({
      success: true,
      message: 'Course created successfully',
      data: { course },
    });
  } catch (error) {
    console.error('Create course error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

module.exports = router;