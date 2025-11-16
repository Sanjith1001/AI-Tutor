// Simple backend test script
const http = require('http');

console.log('🧪 Testing Backend Server...\n');

// Test 1: Health Check
function testHealth() {
  return new Promise((resolve, reject) => {
    console.log('1️⃣ Testing health endpoint...');
    
    const req = http.request({
      hostname: 'localhost',
      port: 3000,
      path: '/health',
      method: 'GET',
      timeout: 5000
    }, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        if (res.statusCode === 200) {
          console.log('✅ Health check passed');
          console.log(`📊 Response: ${data}`);
          resolve();
        } else {
          console.log(`❌ Health check failed: ${res.statusCode}`);
          reject(new Error(`Health check failed: ${res.statusCode}`));
        }
      });
    });

    req.on('error', (e) => {
      console.log(`❌ Health check error: ${e.message}`);
      reject(e);
    });

    req.on('timeout', () => {
      console.log('❌ Health check timeout');
      reject(new Error('Timeout'));
    });

    req.end();
  });
}

// Test 2: Login API
function testLogin() {
  return new Promise((resolve, reject) => {
    console.log('\n2️⃣ Testing login API...');
    
    const loginData = JSON.stringify({
      email: 'admin@aitutor.com',
      password: 'admin123'
    });

    const req = http.request({
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
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
          const response = JSON.parse(data);
          
          if (res.statusCode === 200 && response.success) {
            console.log('✅ Login API working!');
            console.log(`👤 User: ${response.data.user.firstName} ${response.data.user.lastName}`);
            console.log(`🎭 Role: ${response.data.user.role}`);
            console.log(`🔑 Token: ${response.data.token ? 'Generated' : 'Missing'}`);
            resolve();
          } else {
            console.log('❌ Login failed');
            console.log(`📝 Status: ${res.statusCode}`);
            console.log(`📝 Response: ${JSON.stringify(response, null, 2)}`);
            reject(new Error('Login failed'));
          }
        } catch (e) {
          console.log('❌ Invalid JSON response');
          console.log(`📝 Raw response: ${data}`);
          reject(e);
        }
      });
    });

    req.on('error', (e) => {
      console.log(`❌ Login API error: ${e.message}`);
      reject(e);
    });

    req.on('timeout', () => {
      console.log('❌ Login API timeout');
      reject(new Error('Login timeout'));
    });

    req.write(loginData);
    req.end();
  });
}

// Run tests
async function runTests() {
  try {
    await testHealth();
    await testLogin();
    
    console.log('\n🎉 ALL TESTS PASSED!');
    console.log('✅ Backend is working correctly');
    console.log('📱 You can now test Flutter app connectivity');
    
  } catch (error) {
    console.log('\n❌ TESTS FAILED');
    console.log('💡 Troubleshooting steps:');
    console.log('   1. Make sure server is running: npm run dev');
    console.log('   2. Check MongoDB is running');
    console.log('   3. Check for port conflicts');
    console.log('   4. Try the simple server: node server_simple.js');
  }
}

runTests();