const express = require('express');
const { body, validationResult } = require('express-validator');
const Activity = require('../models/Activity');
const { auth } = require('../middleware/auth');

const router = express.Router();

// @route   GET /api/activities
// @desc    Get user's recent activities
// @access  Private
router.get('/', auth, async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 10;
    const activities = await Activity.getUserActivities(req.user.id, limit);

    res.json({
      success: true,
      data: {
        activities,
        hasActivities: activities.length > 0,
      },
    });
  } catch (error) {
    console.error('Get activities error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching activities',
    });
  }
});

// @route   POST /api/activities
// @desc    Add a new activity
// @access  Private
router.post('/', [
  auth,
  body('type').isIn(['quiz', 'course', 'module', 'assessment', 'login', 'vark_quiz', 'skill_assessment'])
    .withMessage('Invalid activity type'),
  body('title').trim().isLength({ min: 1, max: 200 }).withMessage('Title is required (1-200 characters)'),
  body('description').trim().isLength({ min: 1, max: 500 }).withMessage('Description is required (1-500 characters)'),
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

    const { type, title, description, metadata, score, completed } = req.body;

    const activity = await Activity.create({
      userId: req.user.id,
      type,
      title,
      description,
      metadata: metadata || {},
      score: score || null,
      completed: completed || false,
    });

    res.status(201).json({
      success: true,
      message: 'Activity added successfully',
      data: { activity },
    });
  } catch (error) {
    console.error('Add activity error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while adding activity',
    });
  }
});

// @route   GET /api/activities/stats
// @desc    Get user's activity statistics
// @access  Private
router.get('/stats', auth, async (req, res) => {
  try {
    const stats = await Activity.getUserStats(req.user.id);

    res.json({
      success: true,
      data: { stats },
    });
  } catch (error) {
    console.error('Get activity stats error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching activity stats',
    });
  }
});

// @route   DELETE /api/activities
// @desc    Clear user's activities (for testing)
// @access  Private
router.delete('/', auth, async (req, res) => {
  try {
    await Activity.deleteMany({ userId: req.user.id });

    res.json({
      success: true,
      message: 'All activities cleared successfully',
    });
  } catch (error) {
    console.error('Clear activities error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while clearing activities',
    });
  }
});

module.exports = router;