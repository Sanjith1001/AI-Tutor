// Simple test without external dependencies
const http = require('http');

console.log('🧪 Testing backend server...');

// Test if server is running
const options = {
  hostname: 'localhost',
  port: 3000,
  path: '/health',
  method: 'GET'
};

const req = http.request(options, (res) => {
  console.log(`✅ Server responding: ${res.statusCode}`);
  
  let data = '';
  res.on('data', (chunk) => {
    data += chunk;
  });
  
  res.on('end', () => {
    console.log('📊 Health response:', data);
    
    // Now test login endpoint
    testLogin();
  });
});

req.on('error', (e) => {
  console.log('❌ Server not running:', e.message);
  console.log('💡 Make sure to run: npm run dev');
});

req.end();

function testLogin() {
  const loginData = JSON.stringify({
    email: 'admin@aitutor.com',
    password: 'admin123'
  });

  const options = {
    hostname: 'localhost',
    port: 3000,
    path: '/api/auth/login',
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(loginData)
    }
  };

  const req = http.request(options, (res) => {
    console.log(`🔐 Login test: ${res.statusCode}`);
    
    let data = '';
    res.on('data', (chunk) => {
      data += chunk;
    });
    
    res.on('end', () => {
      console.log('📝 Login response:', data);
    });
  });

  req.on('error', (e) => {
    console.log('❌ Login test failed:', e.message);
  });

  req.write(loginData);
  req.end();
}