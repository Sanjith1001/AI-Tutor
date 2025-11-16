const mongoose = require('mongoose');
require('dotenv').config();

async function viewAllUsers() {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/bytebrain_db');
    console.log('✅ Connected to MongoDB\n');

    // Get all users from database
    const db = mongoose.connection.db;
    const users = await db.collection('users').find({}).toArray();

    console.log('👥 ALL USERS IN DATABASE');
    console.log('='.repeat(60));

    if (users.length === 0) {
      console.log('❌ No users found in database!');
      console.log('\n💡 To create test users, run:');
      console.log('   node check_users.js');
      console.log('   OR');
      console.log('   npm run simple  (starts server and creates users)');
    } else {
      console.log(`📊 Total Users: ${users.length}\n`);

      users.forEach((user, index) => {
        console.log(`${index + 1}. USER DETAILS:`);
        console.log(`   📧 Email: ${user.email}`);
        console.log(`   👤 Name: ${user.firstName} ${user.lastName}`);
        console.log(`   🎭 Role: ${user.role}`);
        console.log(`   ✅ Email Verified: ${user.isEmailVerified}`);
        console.log(`   🟢 Active: ${user.isActive}`);
        console.log(`   🔐 Has Password: ${user.password ? 'Yes' : 'No'}`);
        console.log(`   📅 Created: ${user.createdAt}`);
        console.log(`   🔄 Login Count: ${user.loginCount || 0}`);
        console.log('   ' + '-'.repeat(50));
      });

      console.log('\n🔑 LOGIN CREDENTIALS:');
      console.log('='.repeat(40));
      
      // Show known test credentials
      const adminUser = users.find(u => u.email === 'admin@aitutor.com');
      const studentUser = users.find(u => u.email === 'student@aitutor.com');
      
      if (adminUser) {
        console.log('👑 ADMIN LOGIN:');
        console.log('   Email: admin@aitutor.com');
        console.log('   Password: admin123');
      }
      
      if (studentUser) {
        console.log('🎓 STUDENT LOGIN:');
        console.log('   Email: student@aitutor.com');
        console.log('   Password: student123');
      }

      // Show other users (passwords are hashed, so we can't show them)
      const otherUsers = users.filter(u => 
        u.email !== 'admin@aitutor.com' && 
        u.email !== 'student@aitutor.com'
      );

      if (otherUsers.length > 0) {
        console.log('\n📝 OTHER USERS (passwords are hashed):');
        otherUsers.forEach(user => {
          console.log(`   📧 ${user.email} (${user.role})`);
        });
      }
    }

    console.log('\n🌐 FLUTTER APP URLS TO TRY:');
    console.log('='.repeat(40));
    console.log('Android Emulator: http://10.0.2.2:3000/api');
    console.log('iOS Simulator: http://localhost:3000/api');
    console.log('Physical Device: http://YOUR_COMPUTER_IP:3000/api');

  } catch (error) {
    console.error('❌ Error:', error.message);
    
    if (error.message.includes('ECONNREFUSED')) {
      console.log('\n💡 MongoDB is not running. Start it with:');
      console.log('   - Windows: Start MongoDB service');
      console.log('   - Or install MongoDB Community Server');
    }
  } finally {
    await mongoose.connection.close();
    console.log('\n🔌 Database connection closed');
  }
}

viewAllUsers();