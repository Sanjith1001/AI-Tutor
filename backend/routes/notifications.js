const express = require('express');
const { body, validationResult } = require('express-validator');
const User = require('../models/User');
const PushNotificationService = require('../services/push_notification_service');
const { auth, authorize } = require('../middleware/auth');

const router = express.Router();

// @route   POST /api/notifications/register-token
// @desc    Register FCM token for user
// @access  Private
router.post('/register-token', [
  auth,
  body('fcmToken').notEmpty().withMessage('FCM token is required')
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

    const { fcmToken } = req.body;
    const userId = req.user.id;

    // Update user's FCM token
    await User.findByIdAndUpdate(userId, { fcmToken });

    // Subscribe to general topics
    await PushNotificationService.subscribeToTopic(fcmToken, 'announcements');
    await PushNotificationService.subscribeToTopic(fcmToken, `user_${userId}`);

    res.json({
      success: true,
      message: 'FCM token registered successfully'
    });
  } catch (error) {
    console.error('Register FCM token error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   DELETE /api/notifications/unregister-token
// @desc    Unregister FCM token for user
// @access  Private
router.delete('/unregister-token', auth, async (req, res) => {
  try {
    const userId = req.user.id;
    const user = await User.findById(userId).select('fcmToken');

    if (user && user.fcmToken) {
      // Unsubscribe from topics
      await PushNotificationService.unsubscribeFromTopic(user.fcmToken, 'announcements');
      await PushNotificationService.unsubscribeFromTopic(user.fcmToken, `user_${userId}`);
    }

    // Remove FCM token
    await User.findByIdAndUpdate(userId, { $unset: { fcmToken: 1 } });

    res.json({
      success: true,
      message: 'FCM token unregistered successfully'
    });
  } catch (error) {
    console.error('Unregister FCM token error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   POST /api/notifications/send
// @desc    Send push notification to user (Admin only)
// @access  Private/Admin
router.post('/send', [
  auth,
  authorize('admin'),
  body('userId').notEmpty().withMessage('User ID is required'),
  body('title').notEmpty().withMessage('Title is required'),
  body('body').notEmpty().withMessage('Body is required')
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

    const { userId, title, body, data = {} } = req.body;

    const result = await PushNotificationService.sendToUser(userId, { title, body }, data);

    res.json({
      success: result.success,
      message: result.success ? 'Notification sent successfully' : result.message,
      data: result
    });
  } catch (error) {
    console.error('Send notification error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   POST /api/notifications/broadcast
// @desc    Broadcast notification to all users (Admin only)
// @access  Private/Admin
router.post('/broadcast', [
  auth,
  authorize('admin'),
  body('title').notEmpty().withMessage('Title is required'),
  body('body').notEmpty().withMessage('Body is required')
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

    const { title, body, data = {} } = req.body;

    const result = await PushNotificationService.broadcastAnnouncement(title, body, data);

    res.json({
      success: result.success,
      message: result.success ? 'Broadcast sent successfully' : result.message,
      data: result
    });
  } catch (error) {
    console.error('Broadcast notification error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   POST /api/notifications/test
// @desc    Send test notification to current user
// @access  Private
router.post('/test', auth, async (req, res) => {
  try {
    const userId = req.user.id;
    
    const result = await PushNotificationService.sendToUser(userId, {
      title: '🧪 Test Notification',
      body: 'This is a test push notification from ByteBrain!'
    }, {
      type: 'test',
      timestamp: new Date().toISOString()
    });

    res.json({
      success: result.success,
      message: result.success ? 'Test notification sent' : result.message,
      data: result
    });
  } catch (error) {
    console.error('Test notification error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   GET /api/notifications/status
// @desc    Get push notification service status
// @access  Private/Admin
router.get('/status', [auth, authorize('admin')], (req, res) => {
  try {
    const status = PushNotificationService.getStatus();
    
    res.json({
      success: true,
      data: status
    });
  } catch (error) {
    console.error('Get notification status error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

module.exports = router;