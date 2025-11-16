const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Basic middleware
app.use(cors({
  origin: '*', // Allow all origins for testing
  credentials: true,
}));

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Simple health check
app.get('/health', (req, res) => {
  res.json({
    status: 'OK',
    message: 'Server is running',
    timestamp: new Date().toISOString(),
    mongodb: mongoose.connection.readyState === 1 ? 'Connected' : 'Disconnected'
  });
});

// Simple test endpoint
app.get('/test', (req, res) => {
  res.json({
    message: 'Backend is working!',
    timestamp: new Date().toISOString()
  });
});

// Auth routes
try {
  const authRoutes = require('./routes/auth');
  app.use('/api/auth', authRoutes);
  console.log('✅ Auth routes loaded');
} catch (error) {
  console.error('❌ Failed to load auth routes:', error.message);
}

// User routes
try {
  const userRoutes = require('./routes/users');
  app.use('/api/users', userRoutes);
  console.log('✅ User routes loaded');
} catch (error) {
  console.error('❌ Failed to load user routes:', error.message);
}

// Course routes
try {
  const courseRoutes = require('./routes/courses');
  app.use('/api/courses', courseRoutes);
  console.log('✅ Course routes loaded');
} catch (error) {
  console.error('❌ Failed to load course routes:', error.message);
}

// Error handling
app.use((err, req, res, next) => {
  console.error('Server error:', err);
  res.status(500).json({
    success: false,
    message: 'Internal server error',
    error: process.env.NODE_ENV === 'development' ? err.message : undefined
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    message: `Route not found: ${req.method} ${req.originalUrl}`
  });
});

// Database connection
const connectDB = async () => {
  try {
    const mongoUri = process.env.MONGODB_URI || 'mongodb://localhost:27017/bytebrain_db';
    console.log('🔄 Connecting to MongoDB:', mongoUri);
    
    await mongoose.connect(mongoUri, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    
    console.log('✅ MongoDB connected successfully');
    
    // Create test users if they don't exist
    await createTestUsers();
    
  } catch (error) {
    console.error('❌ MongoDB connection failed:', error.message);
    console.log('💡 Make sure MongoDB is running on your system');
    process.exit(1);
  }
};

// Create test users
const createTestUsers = async () => {
  try {
    const User = require('./models/User');
    
    // Check if admin user exists
    const adminExists = await User.findOne({ email: 'admin@aitutor.com' });
    if (!adminExists) {
      const admin = new User({
        email: 'admin@aitutor.com',
        password: 'admin123',
        firstName: 'Admin',
        lastName: 'User',
        role: 'admin',
        isEmailVerified: true,
        isActive: true,
        learningStyle: {
          visual: 25,
          auditory: 25,
          reading: 25,
          kinesthetic: 25
        }
      });
      await admin.save();
      console.log('✅ Admin user created: admin@aitutor.com / admin123');
    }

    // Check if student user exists
    const studentExists = await User.findOne({ email: 'student@aitutor.com' });
    if (!studentExists) {
      const student = new User({
        email: 'student@aitutor.com',
        password: 'student123',
        firstName: 'Student',
        lastName: 'User',
        role: 'student',
        isEmailVerified: true,
        isActive: true,
        learningStyle: {
          visual: 25,
          auditory: 25,
          reading: 25,
          kinesthetic: 25
        }
      });
      await student.save();
      console.log('✅ Student user created: student@aitutor.com / student123');
    }

    console.log('🎯 Test users ready for login!');
  } catch (error) {
    console.error('❌ Error creating test users:', error.message);
  }
};

// Start server
const startServer = async () => {
  try {
    await connectDB();
    
    app.listen(PORT, () => {
      console.log('\n🚀 ByteBrain Backend Server Started!');
      console.log('='.repeat(50));
      console.log(`📡 Server running on: http://localhost:${PORT}`);
      console.log(`🏥 Health check: http://localhost:${PORT}/health`);
      console.log(`🧪 Test endpoint: http://localhost:${PORT}/test`);
      console.log(`🔐 Login API: http://localhost:${PORT}/api/auth/login`);
      console.log('='.repeat(50));
      console.log('\n🔐 Test Credentials:');
      console.log('   Admin: admin@aitutor.com / admin123');
      console.log('   Student: student@aitutor.com / student123');
      console.log('\n📱 Flutter URLs to try:');
      console.log('   Android Emulator: http://10.0.2.2:3000/api');
      console.log('   iOS Simulator: http://localhost:3000/api');
      console.log('   Physical Device: http://YOUR_IP:3000/api');
      console.log('\n✅ Ready for connections!');
    });
  } catch (error) {
    console.error('❌ Failed to start server:', error);
    process.exit(1);
  }
};

// Handle process termination
process.on('SIGINT', async () => {
  console.log('\n🔄 Shutting down server...');
  await mongoose.connection.close();
  console.log('✅ Database connection closed');
  process.exit(0);
});

process.on('unhandledRejection', (err) => {
  console.error('❌ Unhandled Promise Rejection:', err);
  process.exit(1);
});

startServer();