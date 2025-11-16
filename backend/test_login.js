const mongoose = require('mongoose');
const User = require('./models/User');
require('dotenv').config();

// Connect to MongoDB
const connectDB = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/bytebrain_db');
    console.log('✅ MongoDB connected for testing');
  } catch (error) {
    console.error('❌ MongoDB connection failed:', error);
    process.exit(1);
  }
};

// Test login functionality
const testLogin = async () => {
  try {
    console.log('🧪 Testing login functionality...');

    // Check if any users exist
    const userCount = await User.countDocuments();
    console.log(`📊 Total users in database: ${userCount}`);

    if (userCount === 0) {
      console.log('👤 Creating test user...');
      
      // Create a test user
      const testUser = new User({
        email: 'test@bytebrain.com',
        password: 'test123',
        firstName: 'Test',
        lastName: 'User',
        role: 'student',
        isEmailVerified: true,
        learningStyle: {
          visual: 25,
          auditory: 25,
          reading: 25,
          kinesthetic: 25
        }
      });

      await testUser.save();
      console.log('✅ Test user created successfully');
    }

    // Test finding user by email
    const user = await User.findOne({ email: 'test@bytebrain.com' }).select('+password');
    if (!user) {
      console.log('❌ User not found');
      return;
    }

    console.log('✅ User found:', {
      id: user._id,
      email: user.email,
      name: `${user.firstName} ${user.lastName}`,
      role: user.role,
      isEmailVerified: user.isEmailVerified
    });

    // Test password comparison
    const isPasswordValid = await user.comparePassword('test123');
    console.log('🔐 Password validation:', isPasswordValid ? '✅ Valid' : '❌ Invalid');

    // Test wrong password
    const isWrongPasswordValid = await user.comparePassword('wrongpassword');
    console.log('🔐 Wrong password validation:', isWrongPasswordValid ? '❌ Should be invalid' : '✅ Correctly invalid');

    console.log('\n🎯 Test Credentials:');
    console.log('Email: test@bytebrain.com');
    console.log('Password: test123');
    console.log('\n📱 You can now test login in your Flutter app!');

  } catch (error) {
    console.error('❌ Test failed:', error);
  } finally {
    await mongoose.connection.close();
    console.log('🔌 Database connection closed');
  }
};

// Run test
connectDB().then(testLogin);