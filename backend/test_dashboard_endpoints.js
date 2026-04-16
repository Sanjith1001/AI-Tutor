/**
 * Dashboard Endpoints Test Script
 * Tests all backend endpoints required for the dashboard to work
 * 
 * Usage: node test_dashboard_endpoints.js
 */

const http = require('http');

const BASE_URL = 'http://localhost:3000/api';
let authToken = null;
let userId = null;

// ANSI color codes for console output
const colors = {
  reset: '\x1b[0m',
  green: '\x1b[32m',
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m',
};

function log(color, message) {
  console.log(`${color}${message}${colors.reset}`);
}

function request(method, path, data = null) {
  return new Promise((resolve, reject) => {
    const url = new URL(BASE_URL + path);
    const options = {
      hostname: url.hostname,
      port: url.port || 3000,
      path: url.pathname + url.search,
      method: method,
      headers: {
        'Content-Type': 'application/json',
        ...(authToken && { Authorization: `Bearer ${authToken}` }),
      },
    };

    const req = http.request(options, (res) => {
      let responseData = '';

      res.on('data', (chunk) => {
        responseData += chunk;
      });

      res.on('end', () => {
        try {
          const parsed = JSON.parse(responseData);
          resolve({
            statusCode: res.statusCode,
            body: parsed,
            headers: res.headers,
          });
        } catch (e) {
          resolve({
            statusCode: res.statusCode,
            body: responseData,
            headers: res.headers,
          });
        }
      });
    });

    req.on('error', reject);

    if (data) {
      req.write(JSON.stringify(data));
    }

    req.end();
  });
}

async function runTests() {
  log(colors.cyan, '\n=== Dashboard Endpoints Test Suite ===\n');

  // Test 1: Register a test user
  log(colors.blue, '1️⃣  Testing User Registration...');
  try {
    const testEmail = `test_${Date.now()}@example.com`;
    const registerRes = await request('POST', '/auth/register', {
      email: testEmail,
      password: 'Test123456',
      firstName: 'Test',
      lastName: 'User',
    });

    if (registerRes.statusCode === 201 && registerRes.body.success) {
      log(colors.green, `✅ User registered: ${testEmail}`);
      authToken = registerRes.body.data.token;
      userId = registerRes.body.data.user._id;
      log(colors.green, `✅ Auth token received\n`);
    } else {
      log(colors.red, `❌ Registration failed: ${registerRes.body.message}`);
      return;
    }
  } catch (error) {
    log(colors.red, `❌ Registration error: ${error.message}\n`);
    return;
  }

  // Test 2: Get current user
  log(colors.blue, '2️⃣  Testing Get Current User...');
  try {
    const meRes = await request('GET', '/auth/me');
    if (meRes.statusCode === 200 && meRes.body.success) {
      const user = meRes.body.data.user;
      log(colors.green, `✅ Current user fetched: ${user.firstName} ${user.lastName}`);
      log(colors.cyan, `   ID: ${user._id}`);
      log(colors.cyan, `   Email: ${user.email}\n`);
    } else {
      log(colors.red, `❌ Get user failed: ${meRes.body.message}\n`);
    }
  } catch (error) {
    log(colors.red, `❌ Get user error: ${error.message}\n`);
  }

  // Test 3: Add a course activity
  log(colors.blue, '3️⃣  Testing Add Activity (course)...');
  try {
    const courseRes = await request('POST', '/activities', {
      type: 'course',
      title: 'Completed Python Basics',
      description: 'Finished the Python basics course',
      metadata: { course: 'python-basics' },
      completed: true,
      score: 85,
    });

    if (courseRes.statusCode === 201 && courseRes.body.success) {
      log(colors.green, `✅ Course activity recorded\n`);
    } else {
      log(colors.red, `❌ Course activity failed: ${courseRes.body.message}\n`);
    }
  } catch (error) {
    log(colors.red, `❌ Course activity error: ${error.message}\n`);
  }

  // Test 4: Add a quiz activity
  log(colors.blue, '4️⃣  Testing Add Activity (quiz)...');
  try {
    const quizRes = await request('POST', '/activities', {
      type: 'quiz',
      title: 'Completed JavaScript Quiz',
      description: 'Passed quiz with 92% score',
      metadata: { quiz: 'js-quiz-001' },
      score: 92,
      completed: true,
    });

    if (quizRes.statusCode === 201 && quizRes.body.success) {
      log(colors.green, `✅ Quiz activity recorded\n`);
    } else {
      log(colors.red, `❌ Quiz activity failed: ${quizRes.body.message}\n`);
    }
  } catch (error) {
    log(colors.red, `❌ Quiz activity error: ${error.message}\n`);
  }

  // Test 5: Add a module activity
  log(colors.blue, '5️⃣  Testing Add Activity (module)...');
  try {
    const moduleRes = await request('POST', '/activities', {
      type: 'module',
      title: 'Completed Module: Data Structures',
      description: 'Finished learning data structures',
      metadata: { module: 'data-structures-101' },
      completed: true,
    });

    if (moduleRes.statusCode === 201 && moduleRes.body.success) {
      log(colors.green, `✅ Module activity recorded\n`);
    } else {
      log(colors.red, `❌ Module activity failed: ${moduleRes.body.message}\n`);
    }
  } catch (error) {
    log(colors.red, `❌ Module activity error: ${error.message}\n`);
  }

  // Test 6: Add an assessment activity
  log(colors.blue, '6️⃣  Testing Add Activity (assessment)...');
  try {
    const assessmentRes = await request('POST', '/activities', {
      type: 'assessment',
      title: 'Completed AI Assessment',
      description: 'Score: 78% • Skill Level: Intermediate',
      metadata: { topic: 'Artificial Intelligence', skillLevel: 'Intermediate' },
      score: 78,
      completed: true,
    });

    if (assessmentRes.statusCode === 201 && assessmentRes.body.success) {
      log(colors.green, `✅ Assessment activity recorded\n`);
    } else {
      log(colors.red, `❌ Assessment activity failed: ${assessmentRes.body.message}\n`);
    }
  } catch (error) {
    log(colors.red, `❌ Assessment activity error: ${error.message}\n`);
  }

  // Test 7: Get recent activities
  log(colors.blue, '7️⃣  Testing Get Recent Activities...');
  try {
    const activitiesRes = await request('GET', '/activities?limit=10');
    if (activitiesRes.statusCode === 200 && activitiesRes.body.success) {
      const activities = activitiesRes.body.data.activities;
      log(colors.green, `✅ Activities fetched: ${activities.length} items`);
      activities.forEach((activity, index) => {
        log(colors.cyan, `   ${index + 1}. [${activity.type}] ${activity.title}`);
      });
      log('', '');
    } else {
      log(colors.red, `❌ Activities fetch failed: ${activitiesRes.body.message}\n`);
    }
  } catch (error) {
    log(colors.red, `❌ Activities fetch error: ${error.message}\n`);
  }

  // Test 8: Get dashboard stats
  log(colors.blue, '8️⃣  Testing Get Dashboard Stats...');
  try {
    const statsRes = await request('GET', '/activities/stats');
    if (statsRes.statusCode === 200 && statsRes.body.success) {
      const stats = statsRes.body.data.stats;
      log(colors.green, `✅ Dashboard stats fetched:`);
      log(colors.cyan, `   Total Activities: ${stats.totalActivities}`);
      log(colors.cyan, `   Courses Completed: ${stats.coursesCompleted}`);
      log(colors.cyan, `   Modules Completed: ${stats.modulesCompleted}`);
      log(colors.cyan, `   Quizzes Taken: ${stats.quizzesTaken}`);
      log(colors.cyan, `   Assessments Taken: ${stats.assessmentsTaken}`);
      log(colors.cyan, `   Total Score: ${stats.totalScore}`);
      log(colors.cyan, `   Total Quizzes with Score: ${stats.totalQuizzes}`);
      log(colors.cyan, `   Average Score: ${stats.averageScore?.toFixed(2) || 0}%`);
      log(colors.cyan, `   Last Activity: ${stats.lastActivity}`);
      log('', '');
    } else {
      log(colors.red, `❌ Stats fetch failed: ${statsRes.body.message}\n`);
    }
  } catch (error) {
    log(colors.red, `❌ Stats fetch error: ${error.message}\n`);
  }

  log(colors.cyan, '=== Test Suite Complete ===\n');
}

runTests().catch(error => {
  log(colors.red, `Fatal error: ${error.message}`);
  process.exit(1);
});
