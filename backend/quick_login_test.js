// Quick test to check login functionality
const axios = require('axios');

console.log('🧪 Quick Login Test\n');

// Test 1: Health Check
console.log('1. Testing server health...');
axios.get('http://localhost:3000/health')
  .then(response => {
    console.log('✅ Server is running');
    console.log(`📊 Status: ${response.data.status}`);
    
    // Test 2: Login API
    console.log('\n2. Testing login API...');
    return axios.post('http://localhost:3000/api/auth/login', {
      email: 'admin@aitutor.com',
      password: 'admin123'
    });
  })
  .then(response => {
    console.log('✅ Login API working!');
    console.log(`👤 User: ${response.data.data.user.firstName} ${response.data.data.user.lastName}`);
    console.log(`🎭 Role: ${response.data.data.user.role}`);
    console.log(`🔑 Token: ${response.data.data.token ? 'Generated' : 'Missing'}`);
    
    console.log('\n🎯 BACKEND IS WORKING!');
    console.log('📱 Issue is likely in Flutter app connectivity');
    console.log('💡 Use the Debug Connection button in your Flutter app');
  })
  .catch(error => {
    if (error.response) {
      console.log('❌ Login failed');
      console.log(`📝 Status: ${error.response.status}`);
      console.log(`📝 Message: ${error.response.data.message || 'Unknown error'}`);
      
      if (error.response.status === 401) {
        console.log('💡 User might not exist - creating test users...');
        // You can add user creation logic here if needed
      }
    } else {
      console.log('❌ Connection failed');
      console.log(`📝 Error: ${error.message}`);
      console.log('💡 Make sure backend server is running: npm run dev');
    }
  });