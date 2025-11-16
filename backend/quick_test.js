const axios = require('axios');

// Test the login endpoint directly
const testLogin = async () => {
  try {
    console.log('🧪 Testing login endpoint...');
    
    // First, let's test if the server is running
    try {
      const healthResponse = await axios.get('http://localhost:3000/health');
      console.log('✅ Server is running:', healthResponse.data);
    } catch (error) {
      console.log('❌ Server not responding:', error.message);
      return;
    }

    // Test login with invalid credentials first
    try {
      const loginResponse = await axios.post('http://localhost:3000/api/auth/login', {
        email: 'test@example.com',
        password: 'wrongpassword'
      });
      console.log('Login response:', loginResponse.data);
    } catch (error) {
      console.log('Expected login failure:', error.response?.data || error.message);
    }

    // Test registration first
    try {
      const registerResponse = await axios.post('http://localhost:3000/api/auth/register', {
        email: 'quicktest@bytebrain.com',
        password: 'test123',
        firstName: 'Quick',
        lastName: 'Test'
      });
      console.log('✅ Registration successful:', registerResponse.data);
    } catch (error) {
      console.log('Registration response:', error.response?.data || error.message);
    }

    // Now test login with the registered user
    try {
      const loginResponse = await axios.post('http://localhost:3000/api/auth/login', {
        email: 'quicktest@bytebrain.com',
        password: 'test123'
      });
      console.log('✅ Login successful:', loginResponse.data);
      
      // Test getting current user
      const token = loginResponse.data.data.token;
      const meResponse = await axios.get('http://localhost:3000/api/auth/me', {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });
      console.log('✅ Current user:', meResponse.data);
      
    } catch (error) {
      console.log('❌ Login failed:', error.response?.data || error.message);
    }

  } catch (error) {
    console.error('❌ Test error:', error.message);
  }
};

testLogin();