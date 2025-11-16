const os = require('os');

console.log('🌐 Network Information for Flutter Connection\n');

// Get network interfaces
const interfaces = os.networkInterfaces();
const addresses = [];

for (const name of Object.keys(interfaces)) {
  for (const interface of interfaces[name]) {
    // Skip internal and non-IPv4 addresses
    if (interface.family === 'IPv4' && !interface.internal) {
      addresses.push({
        name: name,
        address: interface.address
      });
    }
  }
}

console.log('📱 Flutter App Connection URLs:');
console.log('='.repeat(50));

if (addresses.length > 0) {
  console.log('🔹 For Android Emulator:');
  console.log('   http://10.0.2.2:3000/api');
  
  console.log('\n🔹 For iOS Simulator:');
  console.log('   http://localhost:3000/api');
  
  console.log('\n🔹 For Physical Device:');
  addresses.forEach(addr => {
    console.log(`   http://${addr.address}:3000/api (${addr.name})`);
  });
  
  console.log('\n💡 Update your Flutter AuthBackendService baseUrls with:');
  console.log('static const List<String> baseUrls = [');
  console.log('  \'http://10.0.2.2:3000/api\',      // Android Emulator');
  console.log('  \'http://localhost:3000/api\',      // iOS Simulator');
  addresses.forEach(addr => {
    console.log(`  'http://${addr.address}:3000/api',  // ${addr.name}`);
  });
  console.log('];');
  
} else {
  console.log('❌ No network interfaces found');
}

console.log('\n🧪 Test your server:');
console.log('1. Make sure backend is running: npm run dev');
console.log('2. Test health endpoint in browser: http://localhost:3000/health');
console.log('3. Use Debug Login Screen in Flutter app');

console.log('\n🔥 Current server should be running on:');
console.log('   http://localhost:3000');
console.log('   Health: http://localhost:3000/health');
console.log('   Login: http://localhost:3000/api/auth/login');