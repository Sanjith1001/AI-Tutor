const User = require('../models/User');

// Cleanup offline users every 5 minutes
const startCleanupJob = () => {
  setInterval(async () => {
    try {
      const cleanedCount = await User.cleanupOfflineUsers();
      if (cleanedCount > 0) {
        console.log(`🧹 Cleaned up ${cleanedCount} inactive users`);
      }
    } catch (error) {
      console.error('❌ Cleanup job error:', error);
    }
  }, 5 * 60 * 1000); // Run every 5 minutes

  console.log('🔄 User cleanup job started (runs every 5 minutes)');
};

module.exports = { startCleanupJob };