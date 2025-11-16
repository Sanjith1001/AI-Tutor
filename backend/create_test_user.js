const mongoose = require('mongoose');
const User = require('./models/User');
require('dotenv').config();

const createTestUser = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/bytebrain_db');
    console.log('✅ Connected to MongoDB');

    // Delete existing test user if exists
    await User.deleteOne({ email: 'test@bytebrain.com' });

    // Create test user
    const testUser = new User({
      email: 'test@bytebrain.com',
      password: 'test123',
      firstName: 'Test',
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

    await testUser.save();
    console.log('✅ Test user created successfully');
    console.log('📧 Email: test@bytebrain.com');
    console.log('🔑 Password: test123');

    // Also create admin user
    await User.deleteOne({ email: 'admin@bytebrain.com' });
    
    const adminUser = new User({
      email: 'admin@bytebrain.com',
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

    await adminUser.save();
    console.log('✅ Admin user created successfully');
    console.log('📧 Email: admin@bytebrain.com');
    console.log('🔑 Password: admin123');

    console.log('\n🎯 Test these credentials in your Flutter app!');

  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    await mongoose.connection.close();
  }
};

createTestUser();