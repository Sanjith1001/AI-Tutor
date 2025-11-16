const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
require('dotenv').config();

async function setupLoginCredentials() {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/bytebrain_db');
    console.log('✅ Connected to MongoDB');

    const db = mongoose.connection.db;

    // Define test users with clear credentials
    const testUsers = [
      {
        email: 'admin@aitutor.com',
        password: 'admin123',
        firstName: 'Admin',
        lastName: 'User',
        role: 'admin'
      },
      {
        email: 'student@aitutor.com',
        password: 'student123',
        firstName: 'Student',
        lastName: 'User',
        role: 'student'
      },
      {
        email: 'teacher@aitutor.com',
        password: 'teacher123',
        firstName: 'Teacher',
        lastName: 'User',
        role: 'teacher'
      },
      {
        email: 'test@bytebrain.com',
        password: 'test123',
        firstName: 'Test',
        lastName: 'User',
        role: 'student'
      }
    ];

    console.log('\n🔧 Setting up login credentials...\n');

    for (const userData of testUsers) {
      // Check if user already exists
      const existingUser = await db.collection('users').findOne({ email: userData.email });
      
      if (existingUser) {
        console.log(`✅ User exists: ${userData.email}`);
      } else {
        // Create new user
        const hashedPassword = await bcrypt.hash(userData.password, 12);
        
        const newUser = {
          email: userData.email,
          password: hashedPassword,
          firstName: userData.firstName,
          lastName: userData.lastName,
          role: userData.role,
          isEmailVerified: true,
          isActive: true,
          loginCount: 0,
          learningStyle: {
            visual: 25,
            auditory: 25,
            reading: 25,
            kinesthetic: 25
          },
          preferences: {
            theme: 'light',
            language: 'en',
            notifications: {
              email: true,
              push: true,
              reminders: true
            },
            difficulty: 'intermediate'
          },
          coursesEnrolled: [],
          coursesCompleted: [],
          totalLearningTime: 0,
          createdAt: new Date(),
          updatedAt: new Date()
        };

        await db.collection('users').insertOne(newUser);
        console.log(`✅ Created user: ${userData.email}`);
      }
    }

    // Show all credentials
    console.log('\n🔑 LOGIN CREDENTIALS FOR YOUR APP:');
    console.log('='.repeat(50));
    
    testUsers.forEach((user, index) => {
      const roleIcon = user.role === 'admin' ? '👑' : 
                      user.role === 'teacher' ? '👨‍🏫' : '🎓';
      
      console.log(`${index + 1}. ${roleIcon} ${user.role.toUpperCase()}:`);
      console.log(`   📧 Email: ${user.email}`);
      console.log(`   🔑 Password: ${user.password}`);
      console.log('');
    });

    console.log('📱 FLUTTER APP TESTING:');
    console.log('='.repeat(30));
    console.log('1. Start your backend server: npm run dev');
    console.log('2. Open Flutter app');
    console.log('3. Go to Login screen');
    console.log('4. Use any of the credentials above');
    console.log('5. Or click "Debug Connection" to test URLs');

    // Count total users
    const totalUsers = await db.collection('users').countDocuments();
    console.log(`\n📊 Total users in database: ${totalUsers}`);

  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await mongoose.connection.close();
    console.log('\n🔌 Database connection closed');
  }
}

setupLoginCredentials();