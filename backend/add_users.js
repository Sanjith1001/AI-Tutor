// Add this to your server.js temporarily to create test users
const User = require('./models/User');

async function createTestUsers() {
  try {
    // Check if users already exist
    const adminExists = await User.findOne({ email: 'admin@aitutor.com' });
    const studentExists = await User.findOne({ email: 'student@aitutor.com' });

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

    console.log('🎯 Test users ready!');
  } catch (error) {
    console.error('❌ Error creating test users:', error);
  }
}

module.exports = createTestUsers;