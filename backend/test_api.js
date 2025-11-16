const http = require('http');

// Test the API endpoints
const testAPI = () => {
  console.log('🧪 Testing API endpoints...\n');

  // Test 1: Health check
  console.log('1. Testing health endpoint...');
  const healthReq = http.request({
    hostname: 'localhost',
    port: 3000,
    path: '/health',
    method: 'GET'
  }, (res) => {
    let data = '';
    res.on('data', chunk => data += chunk);
    res.on('end', () => {
      console.log(`   Status: ${res.statusCode}`);
      console.log(`   Response: ${data}\n`);
      
      // Test 2: Login
      testLogin();
    });
  });

  healthReq.on('error', (e) => {
    console.log(`   ❌ Health check failed: ${e.message}`);
    console.log('   💡 Make sure your server is running: npm run dev\n');
  });

  healthReq.end();
};

const testLogin = () => {
  console.log('2. Testing login endpoint...');
  
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
    }
  }, (res) => {
    let data = '';
    res.on('data', chunk => data += chunk);
    res.on('end', () => {
      console.log(`   Status: ${res.statusCode}`);
      try {
        const response = JSON.parse(data);
        if (response.success) {
          console.log(`   ✅ Login successful for: ${response.data.user.firstName} ${response.data.user.lastName}`);
          console.log(`   🎭 Role: ${response.data.user.role}`);
          console.log(`   🔑 Token received: ${response.data.token ? 'Yes' : 'No'}`);
        } else {
          console.log(`   ❌ Login failed: ${response.message}`);
        }
      } catch (e) {
        console.log(`   ❌ Invalid response: ${data}`);
      }
      console.log('\n🎯 If login failed, run: node simple_db_check.js');
    });
  });

  loginReq.on('error', (e) => {
    console.log(`   ❌ Login test failed: ${e.message}`);
  });

  loginReq.write(loginData);
  loginReq.end();
};

testAPI();