const os = require('os');
const mongoose = require('mongoose');
const User = require('../models/User');
const Course = require('../models/Course');
const CacheService = require('./cache_service');
const ChatService = require('./chat_service');

class MonitoringService {
  constructor() {
    this.startTime = Date.now();
    this.requestCount = 0;
    this.errorCount = 0;
    this.responseTimeSum = 0;
    this.slowQueries = [];
    
    // Start periodic health checks
    this.startHealthChecks();
    
    console.log('📊 Monitoring Service initialized');
  }

  // Middleware to track requests
  trackRequest() {
    return (req, res, next) => {
      const startTime = Date.now();
      this.requestCount++;

      // Track response time
      res.on('finish', () => {
        const responseTime = Date.now() - startTime;
        this.responseTimeSum += responseTime;

        // Log slow requests (>1000ms)
        if (responseTime > 1000) {
          console.warn(`🐌 Slow request: ${req.method} ${req.path} - ${responseTime}ms`);
        }

        // Track errors
        if (res.statusCode >= 400) {
          this.errorCount++;
        }
      });

      next();
    };
  }

  // Get system health metrics
  async getHealthMetrics() {
    const uptime = Date.now() - this.startTime;
    const avgResponseTime = this.requestCount > 0 ? this.responseTimeSum / this.requestCount : 0;

    return {
      system: {
        uptime: Math.floor(uptime / 1000), // seconds
        uptimeFormatted: this.formatUptime(uptime),
        nodeVersion: process.version,
        platform: process.platform,
        arch: process.arch,
        pid: process.pid
      },
      performance: {
        requestCount: this.requestCount,
        errorCount: this.errorCount,
        errorRate: this.requestCount > 0 ? (this.errorCount / this.requestCount * 100).toFixed(2) : 0,
        avgResponseTime: Math.round(avgResponseTime),
        memoryUsage: this.getMemoryUsage(),
        cpuUsage: this.getCpuUsage(),
        loadAverage: os.loadavg()
      },
      database: await this.getDatabaseHealth(),
      cache: this.getCacheHealth(),
      realtime: this.getRealtimeHealth(),
      timestamp: new Date().toISOString()
    };
  }

  // Get memory usage
  getMemoryUsage() {
    const usage = process.memoryUsage();
    return {
      rss: Math.round(usage.rss / 1024 / 1024), // MB
      heapTotal: Math.round(usage.heapTotal / 1024 / 1024), // MB
      heapUsed: Math.round(usage.heapUsed / 1024 / 1024), // MB
      external: Math.round(usage.external / 1024 / 1024), // MB
      systemTotal: Math.round(os.totalmem() / 1024 / 1024), // MB
      systemFree: Math.round(os.freemem() / 1024 / 1024), // MB
      systemUsage: Math.round((1 - os.freemem() / os.totalmem()) * 100) // %
    };
  }

  // Get CPU usage
  getCpuUsage() {
    const cpus = os.cpus();
    return {
      cores: cpus.length,
      model: cpus[0].model,
      speed: cpus[0].speed
    };
  }

  // Get database health
  async getDatabaseHealth() {
    try {
      const dbState = mongoose.connection.readyState;
      const stateNames = ['disconnected', 'connected', 'connecting', 'disconnecting'];
      
      // Get database stats
      const userCount = await User.countDocuments();
      const courseCount = await Course.countDocuments();
      const onlineUsers = await User.countDocuments({ isOnline: true });

      // Test query performance
      const queryStart = Date.now();
      await User.findOne().limit(1);
      const queryTime = Date.now() - queryStart;

      return {
        status: stateNames[dbState] || 'unknown',
        connected: dbState === 1,
        host: mongoose.connection.host,
        name: mongoose.connection.name,
        queryTime,
        collections: {
          users: userCount,
          courses: courseCount,
          onlineUsers
        }
      };
    } catch (error) {
      return {
        status: 'error',
        connected: false,
        error: error.message
      };
    }
  }

  // Get cache health
  getCacheHealth() {
    try {
      const stats = CacheService.getStats();
      return {
        status: 'healthy',
        ...stats
      };
    } catch (error) {
      return {
        status: 'error',
        error: error.message
      };
    }
  }

  // Get real-time service health
  getRealtimeHealth() {
    try {
      const onlineCount = ChatService.getOnlineUsersCount();
      return {
        status: 'healthy',
        onlineUsers: onlineCount,
        service: 'Socket.IO'
      };
    } catch (error) {
      return {
        status: 'error',
        error: error.message
      };
    }
  }

  // Format uptime
  formatUptime(ms) {
    const seconds = Math.floor(ms / 1000);
    const minutes = Math.floor(seconds / 60);
    const hours = Math.floor(minutes / 60);
    const days = Math.floor(hours / 24);

    if (days > 0) {
      return `${days}d ${hours % 24}h ${minutes % 60}m`;
    } else if (hours > 0) {
      return `${hours}h ${minutes % 60}m`;
    } else if (minutes > 0) {
      return `${minutes}m ${seconds % 60}s`;
    } else {
      return `${seconds}s`;
    }
  }

  // Start periodic health checks
  startHealthChecks() {
    // Check every 5 minutes
    setInterval(async () => {
      try {
        const health = await this.getHealthMetrics();
        
        // Log warnings for high resource usage
        if (health.performance.memoryUsage.systemUsage > 90) {
          console.warn('⚠️  High memory usage:', health.performance.memoryUsage.systemUsage + '%');
        }
        
        if (health.performance.errorRate > 10) {
          console.warn('⚠️  High error rate:', health.performance.errorRate + '%');
        }
        
        if (health.performance.avgResponseTime > 2000) {
          console.warn('⚠️  High average response time:', health.performance.avgResponseTime + 'ms');
        }

        // Cache health metrics
        CacheService.set('health_metrics', health, 5 * 60 * 1000); // 5 minutes
        
      } catch (error) {
        console.error('❌ Health check failed:', error);
      }
    }, 5 * 60 * 1000); // 5 minutes

    console.log('🔄 Health monitoring started (checks every 5 minutes)');
  }

  // Get application statistics
  async getAppStats() {
    try {
      const [userStats, courseStats] = await Promise.all([
        User.aggregate([
          {
            $group: {
              _id: null,
              totalUsers: { $sum: 1 },
              activeUsers: { $sum: { $cond: ['$isActive', 1, 0] } },
              onlineUsers: { $sum: { $cond: ['$isOnline', 1, 0] } },
              verifiedUsers: { $sum: { $cond: ['$isEmailVerified', 1, 0] } },
              studentCount: { $sum: { $cond: [{ $eq: ['$role', 'student'] }, 1, 0] } },
              teacherCount: { $sum: { $cond: [{ $eq: ['$role', 'teacher'] }, 1, 0] } },
              adminCount: { $sum: { $cond: [{ $eq: ['$role', 'admin'] }, 1, 0] } }
            }
          }
        ]),
        Course.aggregate([
          {
            $group: {
              _id: null,
              totalCourses: { $sum: 1 },
              publishedCourses: { $sum: { $cond: ['$isPublished', 1, 0] } },
              totalEnrollments: { $sum: { $size: '$enrolledStudents' } },
              avgRating: { $avg: '$averageRating' }
            }
          }
        ])
      ]);

      return {
        users: userStats[0] || {},
        courses: courseStats[0] || {},
        timestamp: new Date().toISOString()
      };
    } catch (error) {
      console.error('Get app stats error:', error);
      return { error: error.message };
    }
  }

  // Log slow query
  logSlowQuery(query, duration) {
    this.slowQueries.push({
      query,
      duration,
      timestamp: new Date().toISOString()
    });

    // Keep only last 100 slow queries
    if (this.slowQueries.length > 100) {
      this.slowQueries = this.slowQueries.slice(-100);
    }

    console.warn(`🐌 Slow query detected: ${duration}ms - ${query}`);
  }

  // Get slow queries
  getSlowQueries() {
    return this.slowQueries.slice(-20); // Last 20 slow queries
  }

  // Reset metrics
  resetMetrics() {
    this.requestCount = 0;
    this.errorCount = 0;
    this.responseTimeSum = 0;
    this.slowQueries = [];
    this.startTime = Date.now();
    
    console.log('📊 Monitoring metrics reset');
  }

  // Get alerts
  async getAlerts() {
    const health = await this.getHealthMetrics();
    const alerts = [];

    // Memory alerts
    if (health.performance.memoryUsage.systemUsage > 90) {
      alerts.push({
        type: 'critical',
        category: 'memory',
        message: `High memory usage: ${health.performance.memoryUsage.systemUsage}%`,
        timestamp: new Date().toISOString()
      });
    }

    // Error rate alerts
    if (health.performance.errorRate > 10) {
      alerts.push({
        type: 'warning',
        category: 'errors',
        message: `High error rate: ${health.performance.errorRate}%`,
        timestamp: new Date().toISOString()
      });
    }

    // Response time alerts
    if (health.performance.avgResponseTime > 2000) {
      alerts.push({
        type: 'warning',
        category: 'performance',
        message: `High response time: ${health.performance.avgResponseTime}ms`,
        timestamp: new Date().toISOString()
      });
    }

    // Database alerts
    if (!health.database.connected) {
      alerts.push({
        type: 'critical',
        category: 'database',
        message: 'Database connection lost',
        timestamp: new Date().toISOString()
      });
    }

    return alerts;
  }
}

module.exports = new MonitoringService();