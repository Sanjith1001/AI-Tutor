const http = require('http');
const mongoose = require('mongoose');
require('dotenv').config();

console.log('🔍 LOGIN DIAGNOSIS STARTING...\n');

// Step 1: Check if server is running
console.log('1️⃣ Checking if backend server is running...');
const healthReq = http.request({
  hostname: 'localhost',
  port: 3000,
  path: '/health',
  method: 'GET',
  timeout: 5000
}, (res) => {
  console.log(`✅ Server is running (Status: ${res.statusCode})`);
  
  let data = '';
  res.on('data', chunk => data += chunk);
  res.on('end', () => {
    console.log(`📊 Health response: ${data}\n`);
    checkDatabase();
  });
});

healthReq.on('error', (e) => {
  console.log(`❌ Server is NOT running: ${e.message}`);
  console.log('💡 Solution: Run "npm run dev" in backend folder\n');
  process.exit(1);
});

healthReq.on('timeout', () => {
  console.log('❌ Server timeout - server might be starting up');
  console.log('💡 Wait a moment and try again\n');
  process.exit(1);
});

healthReq.end();

// Step 2: Check database connection and users
async function checkDatabase() {
  console.log('2️⃣ Checking database connection and users...');
  
  try {
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/bytebrain_db');
    console.log('✅ Database connected successfully');
    
    // Check if users collection exists
    const db = mongoose.connection.db;
    const collections = await db.listCollections().toArray();
    const hasUsers = collections.some(col => col.name === 'users');
    
    if (!hasUsers) {
      console.log('❌ No users collection found');
      console.log('💡 Creating users collection with test users...');
      await createTestUsers(db);
    } else {
      console.log('✅ Users collection exists');
      
      // Check for test users
      const users = await db.collection('users').find({}).toArray();
      console.log(`📊 Found ${users.length} users in database`);
      
      if (users.length === 0) {
        console.log('❌ No users in database');
        console.log('💡 Creating test users...');
        await createTestUsers(db);
      } else {
        console.log('✅ Users found:');
        users.forEach((user, i) => {
          console.log(`   ${i+1}. ${user.firstName} ${user.lastName} (${user.email}) - ${user.role}`);
        });
      }
    }
    
    await mongoose.connection.close();
    console.log('\n3️⃣ Testing login API...');
    testLoginAPI();
    
  } catch (error) {
    console.log(`❌ Database error: ${error.message}`);
    console.log('💡 Make sure MongoDB is running');
    process.exit(1);
  }
}

// Step 3: Test login API
function testLoginAPI() {
  const loginData = JSON.stringify({
    email: 'admin@aitutor.com',
    password: 'admin123'
  });

  const loginReq = http.request({
    hostname: 'localhost',
    port: 3000,
    path: '/api/auth/login',
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(loginData)
    },
    timeout: 10000
  }, (res) => {
    console.log(`📡 Login API Status: ${res.statusCode}`);
    
    let data = '';
    res.on('data', chunk => data += chunk);
    res.on('end', () => {
      try {
        const response = JSON.parse(data);
        
        if (res.statusCode === 200 && response.success) {
          console.log('✅ LOGIN API WORKING!');
          console.log(`👤 Logged in as: ${response.data.user.firstName} ${response.data.user.lastName}`);
          console.log(`🎭 Role: ${response.data.user.role}`);
          console.log(`🔑 Token: ${response.data.token ? 'Generated' : 'Missing'}`);
          
          console.log('\n🎯 DIAGNOSIS COMPLETE - API IS WORKING!');
          console.log('📱 Flutter app issue might be:');
          console.log('   1. Wrong URL (use Debug Connection in app)');
          console.log('   2. Network/firewall blocking connection');
          console.log('   3. Emulator network issues');
          
        } else {
          console.log('❌ LOGIN FAILED');
          console.log(`📝 Response: ${JSON.stringify(response, null, 2)}`);
          
          if (response.message) {
            console.log(`💡 Error: ${response.message}`);
          }
        }
      } catch (e) {
        console.log('❌ Invalid JSON response');
        console.log(`📝 Raw response: ${data}`);
      }
      
      console.log('\n🔧 NEXT STEPS:');
      console.log('1. If API works: Check Flutter app network connection');
      console.log('2. Use Debug Login Screen in Flutter app');
      console.log('3. Try different URLs in Flutter (10.0.2.2, localhost, your IP)');
      console.log('4. Check Windows Firewall settings');
    });
  });

  loginReq.on('error', (e) => {
    console.log(`❌ Login API error: ${e.message}`);
    console.log('💡 Check if auth routes are properly configured');
  });

  loginReq.on('timeout', () => {
    console.log('❌ Login API timeout');
    console.log('💡 Server might be overloaded or hanging');
  });

  loginReq.write(loginData);
  loginReq.end();
}

// Create test users
async function createTestUsers(db) {
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

  try {
    await db.collection('users').insertMany(testUsers);
    console.log('✅ Test users created successfully');
    console.log('🔐 Credentials:');
    console.log('   Admin: admin@aitutor.com / admin123');
    console.log('   Student: student@aitutor.com / student123');
  } catch (error) {
    console.log(`❌ Failed to create users: ${error.message}`);
  }
}