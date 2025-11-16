// Simple script to check users in database
const mongoose = require('mongoose');
require('dotenv').config();

async function checkUsers() {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/bytebrain_db');
    console.log('✅ Connected to MongoDB');

    // Get users directly from database
    const db = mongoose.connection.db;
    const users = await db.collection('users').find({}).toArray();

    console.log(`\n📊 Found ${users.length} users in database:`);
    
    if (users.length === 0) {
      console.log('❌ No users found - this is why login fails!');
      console.log('💡 Creating test users...');
      
      const bcrypt = require('bcryptjs');
      const testUsers = [
        {
          email: 'admin@aitutor.com',
          password: await bcrypt.hash('admin123', 12),
          firstName: 'Admin',
          lastName: 'User',
          role: 'admin',
          isEmailVerified: true,
          isActive: true,
          loginCount: 0,
          learningStyle: { visual: 25, auditory: 25, reading: 25, kinesthetic: 25 },
          preferences: {
            theme: 'light',
            language: 'en',
            notifications: { email: true, push: true, reminders: true },
            difficulty: 'intermediate'
          },
          coursesEnrolled: [],
          coursesCompleted: [],
          totalLearningTime: 0,
          createdAt: new Date(),
          updatedAt: new Date()
        },
        {
          email: 'student@aitutor.com',
          password: await bcrypt.hash('student123', 12),
          firstName: 'Student',
          lastName: 'User',
          role: 'student',
          isEmailVerified: true,
          isActive: true,
          loginCount: 0,
          learningStyle: { visual: 25, auditory: 25, reading: 25, kinesthetic: 25 },
          preferences: {
            theme: 'light',
            language: 'en',
            notifications: { email: true, push: true, reminders: true },
            difficulty: 'intermediate'
          },
          coursesEnrolled: [],
          coursesCompleted: [],
          totalLearningTime: 0,
          createdAt: new Date(),
          updatedAt: new Date()
        }
      ];

      await db.collection('users').insertMany(testUsers);
      console.log('✅ Test users created!');
    } else {
      users.forEach((user, i) => {
        console.log(`${i + 1}. ${user.firstName} ${user.lastName}`);
        console.log(`   📧 Email: ${user.email}`);
        console.log(`   🎭 Role: ${user.role}`);
        console.log(`   ✅ Active: ${user.isActive}`);
        console.log(`   🔐 Has Password: ${user.password ? 'Yes' : 'No'}`);
      });
    }

    console.log('\n🔐 Test Credentials:');
    console.log('   Admin: admin@aitutor.com / admin123');
    console.log('   Student: student@aitutor.com / student123');

  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await mongoose.connection.close();
    console.log('\n🔌 Database connection closed');
  }
}

checkUsers();