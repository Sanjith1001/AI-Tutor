const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

const connectDB = require('./config/database');
const authRoutes = require('./routes/auth');
const userRoutes = require('./routes/users');
const { startCleanupJob } = require('./jobs/cleanup');
const ChatService = require('./services/chat_service');
const http = require('http');
const { errorHandler } = require('./middleware/errorHandler');

const app = express();
const PORT = process.env.PORT || 3000;

// Security Middleware
app.use(helmet());

// Rate Limiting
const limiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 15 * 60 * 1000, // 15 minutes
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS) || 100, // limit each IP to 100 requests per windowMs
  message: {
    error: 'Too many requests from this IP, please try again later.',
  },
});
app.use(limiter);

// CORS Configuration - allow all origins
// NOTE: This allows requests from any origin. Remove or tighten for production.
app.use(cors({
  origin: true,
  credentials: true,
}));

// Body Parser Middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Import monitoring service
const MonitoringService = require('./services/monitoring_service');

// Import push notification service (initializes Firebase)
const PushNotificationService = require('./services/push_notification_service');

// Add monitoring middleware
app.use(MonitoringService.trackRequest());

// Simple test endpoint
app.get('/test', (req, res) => {
  res.json({
    success: true,
    message: 'Backend is working!',
    timestamp: new Date().toISOString(),
    database: mongoose.connection.readyState === 1 ? 'Connected' : 'Disconnected'
  });
});

// Health Check Endpoint
app.get('/health', async (req, res) => {
  try {
    const health = await MonitoringService.getHealthMetrics();
    const isHealthy = health.database.connected && health.performance.errorRate < 50;
    
    res.status(isHealthy ? 200 : 503).json({
      status: isHealthy ? 'OK' : 'DEGRADED',
      message: 'ByteBrain Backend Health Check',
      ...health
    });
  } catch (error) {
    res.status(503).json({
      status: 'ERROR',
      message: 'Health check failed',
      error: error.message,
      timestamp: new Date().toISOString()
    });
  }
});

// Detailed health endpoint
app.get('/health/detailed', async (req, res) => {
  try {
    const [health, stats, alerts] = await Promise.all([
      MonitoringService.getHealthMetrics(),
      MonitoringService.getAppStats(),
      MonitoringService.getAlerts()
    ]);

    res.json({
      status: 'OK',
      health,
      stats,
      alerts,
      slowQueries: MonitoringService.getSlowQueries()
    });
  } catch (error) {
    res.status(500).json({
      status: 'ERROR',
      message: 'Detailed health check failed',
      error: error.message
    });
  }
});

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/courses', require('./routes/courses'));
app.use('/api/admin', require('./routes/admin'));
app.use('/api/media', require('./routes/media'));
app.use('/api/youtube', require('./routes/youtube'));
app.use('/api/analytics', require('./routes/analytics'));
app.use('/api/notifications', require('./routes/notifications'));
app.use('/api/activities', require('./routes/activities'));
app.use('/api/quizzes', require('./routes/quizzes'));

// API Documentation
const APIDocumentationGenerator = require('./docs/api_documentation');
app.get('/docs', (req, res) => {
  const docGenerator = new APIDocumentationGenerator();
  const html = docGenerator.generateHTML();
  res.send(html);
});

app.get('/docs/json', (req, res) => {
  const docGenerator = new APIDocumentationGenerator();
  const docs = docGenerator.generateDocumentation();
  res.json(docs);
});

// 404 Handler
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Route not found',
    message: `Cannot ${req.method} ${req.originalUrl}`,
  });
});

// Global Error Handler
app.use(errorHandler);

// Database Connection and Server Start
const startServer = async () => {
  try {
    // Connect to MongoDB
    await connectDB();
    console.log('✅ MongoDB connection established successfully.');

    // Create test users for development
    if (process.env.NODE_ENV === 'development') {
      const createTestUsers = require('./add_users');
      await createTestUsers();
    }

    // Create HTTP server for Socket.IO
    const server = http.createServer(app);
    
    // Initialize WebSocket chat service
    ChatService.initialize(server);
    
    // Start server
    server.listen(PORT, () => {
      console.log(`🚀 AI-Tutor Backend Server running on port ${PORT}`);
      console.log(`📊 Health check: http://localhost:${PORT}/health`);
      console.log(`🔐 Auth endpoints: http://localhost:${PORT}/api/auth`);
      console.log(`👤 User endpoints: http://localhost:${PORT}/api/users`);
      console.log(`🔥 Real-time Chat: WebSocket enabled`);
      console.log(`🗄️  MongoDB: ${process.env.MONGODB_URI || 'mongodb://localhost:27017/bytebrain_db'}`);
      
      // Start background jobs
      startCleanupJob();
    });
  } catch (error) {
    console.error('❌ Unable to start server:', error);
    process.exit(1);
  }
};

// Handle unhandled promise rejections
process.on('unhandledRejection', (err) => {
  console.error('Unhandled Promise Rejection:', err);
  process.exit(1);
});

// Handle uncaught exceptions
process.on('uncaughtException', (err) => {
  console.error('Uncaught Exception:', err);
  process.exit(1);
});

startServer();

module.exports = app;