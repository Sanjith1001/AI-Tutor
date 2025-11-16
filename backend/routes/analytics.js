const express = require('express');
const User = require('../models/User');
const { auth, authorize } = require('../middleware/auth');

const router = express.Router();

// @route   GET /api/analytics/online-users
// @desc    Get count of online users
// @access  Private/Admin
router.get('/online-users', [auth, authorize('admin')], async (req, res) => {
  try {
    const onlineCount = await User.getOnlineUsersCount();
    const recentlyActiveCount = await User.getRecentlyActiveCount();
    
    res.json({
      success: true,
      data: {
        onlineUsers: onlineCount,
        recentlyActive: recentlyActiveCount,
        timestamp: new Date().toISOString()
      }
    });
  } catch (error) {
    console.error('Get online users error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   GET /api/analytics/online-users/list
// @desc    Get list of online users
// @access  Private/Admin
router.get('/online-users/list', [auth, authorize('admin')], async (req, res) => {
  try {
    const onlineUsers = await User.getOnlineUsers();
    
    res.json({
      success: true,
      data: {
        users: onlineUsers,
        count: onlineUsers.length,
        timestamp: new Date().toISOString()
      }
    });
  } catch (error) {
    console.error('Get online users list error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   GET /api/analytics/user-stats
// @desc    Get comprehensive user statistics
// @access  Private/Admin
router.get('/user-stats', [auth, authorize('admin')], async (req, res) => {
  try {
    const stats = await User.getUserStats();
    
    res.json({
      success: true,
      data: stats[0] || {
        totalUsers: 0,
        activeUsers: 0,
        onlineUsers: 0,
        verifiedUsers: 0,
        studentCount: 0,
        teacherCount: 0,
        adminCount: 0
      }
    });
  } catch (error) {
    console.error('Get user stats error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   POST /api/analytics/cleanup-offline
// @desc    Cleanup users who are marked online but inactive
// @access  Private/Admin
router.post('/cleanup-offline', [auth, authorize('admin')], async (req, res) => {
  try {
    const cleanedCount = await User.cleanupOfflineUsers();
    
    res.json({
      success: true,
      message: `Cleaned up ${cleanedCount} inactive users`,
      data: {
        cleanedUsers: cleanedCount,
        timestamp: new Date().toISOString()
      }
    });
  } catch (error) {
    console.error('Cleanup offline users error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// @route   PUT /api/analytics/activity
// @desc    Update user activity (heartbeat)
// @access  Private
router.put('/activity', auth, async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    if (user) {
      await user.updateActivity();
    }
    
    res.json({
      success: true,
      message: 'Activity updated'
    });
  } catch (error) {
    console.error('Update activity error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

module.exports = router;