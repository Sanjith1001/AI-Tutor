const mongoose = require('mongoose');
const User = require('./models/User');
require('dotenv').config();

const testDatabase = async () => {
  try {
    console.log('🔄 Connecting to MongoDB...');
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ MongoDB Connected');
    
    // Check if users exist
    const userCount = await User.countDocuments();
    console.log(`👤 Users in database: ${userCount}`);
    
    if (userCount === 0) {
      console.log('🌱 No users found. Creating test user...');
      
      const testUser = new User({
        email: 'student@bytebrain.com',
        password: 'student123',
        firstName: 'Test',
        lastName: 'Student',
        role: 'student',
        isEmailVerified: true,
        learningStyle: {
          visual: 25,
          auditory: 25,
          reading: 25,
          kinesthetic: 25,
        }
      });
      
      await testUser.save();
      console.log('✅ Test user created: student@bytebrain.com / student123');
    } else {
      console.log('📋 Existing users:');
      const users = await User.find().select('email firstName lastName role');
      users.forEach(user => {
        console.log(`  - ${user.email} (${user.firstName} ${user.lastName}) - ${user.role}`);
      });
    }
    
    await mongoose.connection.close();
    console.log('🔌 Database connection closed');
    
  } catch (error) {
    console.error('❌ Database test failed:', error);
    process.exit(1);
  }
};

testDatabase();