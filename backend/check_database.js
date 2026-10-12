const mongoose = require('mongoose');
const User = require('./models/User');
const Course = require('./models/Course');
require('dotenv').config();

// Connect to MongoDB
const connectDB = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/bytebrain_db');
    console.log(' Connected to MongoDB');
  } catch (error) {
    console.error(' MongoDB connection failed:', error);
    process.exit(1);
  }
};

// Check database contents
const checkDatabase = async () => {
  try {
    console.log(' Checking database contents...\n');

    // Check Users collection
    console.log('👥 USERS COLLECTION:');
    console.log('='.repeat(50));
    
    const users = await User.find({}).select('email firstName lastName role isEmailVerified isActive createdAt');
    
    if (users.length === 0) {
      console.log(' No users found in database');
    } else {
      console.log(` Total users: ${users.length}\n`);
      
      users.forEach((user, index) => {
        console.log(`${index + 1}. ${user.firstName} ${user.lastName}`);
        console.log(`    Email: ${user.email}`);
        console.log(`    Role: ${user.role}`);
        console.log(`   Verified: ${user.isEmailVerified}`);
        console.log(`   Active: ${user.isActive}`);
        console.log(`    Created: ${user.createdAt}`);
        console.log('   ' + '-'.repeat(40));
      });
    }

    console.log('\n COURSES COLLECTION:');
    console.log('='.repeat(50));
    
    const courses = await Course.find({}).select('title instructor category difficulty isPublished createdAt');
    
    if (courses.length === 0) {
      console.log('No courses found in database');
    } else {
      console.log(` Total courses: ${courses.length}\n`);
      
      for (const course of courses) {
        const instructor = await User.findById(course.instructor).select('firstName lastName');
        console.log(`📖 ${course.title}`);
        console.log(`    Instructor: ${instructor ? `${instructor.firstName} ${instructor.lastName}` : 'Unknown'}`);
        console.log(`   Category: ${course.category}`);
        console.log(`    Difficulty: ${course.difficulty}`);
        console.log(`    Published: ${course.isPublished}`);
        console.log(`    Created: ${course.createdAt}`);
        console.log('   ' + '-'.repeat(40));
      }
    }

    // Database statistics
    console.log('\n DATABASE STATISTICS:');
    console.log('='.repeat(50));
    
    const userStats = await User.aggregate([
      {
        $group: {
          _id: '$role',
          count: { $sum: 1 }
        }
      }
    ]);

    console.log(' Users by role:');
    userStats.forEach(stat => {
      console.log(`   ${stat._id}: ${stat.count}`);
    });

    const verifiedCount = await User.countDocuments({ isEmailVerified: true });
    const activeCount = await User.countDocuments({ isActive: true });
    const publishedCourses = await Course.countDocuments({ isPublished: true });

    console.log(` Verified users: ${verifiedCount}`);
    console.log(` Active users: ${activeCount}`);
    console.log(` Published courses: ${publishedCourses}`);

    // Test login credentials
    console.log('\n TEST LOGIN CREDENTIALS:');
    console.log('='.repeat(50));
    
    const testUsers = await User.find({
      email: { $in: ['admin@aitutor.com', 'student@aitutor.com', 'test@bytebrain.com'] }
    }).select('email firstName lastName role');

    if (testUsers.length > 0) {
      testUsers.forEach(user => {
        const password = user.email.includes('admin') ? 'admin123' : 
                        user.email.includes('student') ? 'student123' : 'test123';
        console.log(` ${user.email} / 🔑 ${password} (${user.role})`);
      });
    } else {
      console.log(' No test users found. Creating them now...');
      await createTestUsers();
    }

  } catch (error) {
    console.error(' Error checking database:', error);
  } finally {
    await mongoose.connection.close();
    console.log('\n Database connection closed');
  }
};

// Create test users if they don't exist
const createTestUsers = async () => {
  try {
    const testUsers = [
      {
        email: 'admin@aitutor.com',
        password: 'admin123',
        firstName: 'Admin',
        lastName: 'User',
        role: 'admin',
        isEmailVerified: true,
        isActive: true,
        learningStyle: { visual: 25, auditory: 25, reading: 25, kinesthetic: 25 }
      },
      {
        email: 'student@aitutor.com',
        password: 'student123',
        firstName: 'Student',
        lastName: 'User',
        role: 'student',
        isEmailVerified: true,
        isActive: true,
        learningStyle: { visual: 25, auditory: 25, reading: 25, kinesthetic: 25 }
      },
      {
        email: 'test@bytebrain.com',
        password: 'test123',
        firstName: 'Test',
        lastName: 'User',
        role: 'student',
        isEmailVerified: true,
        isActive: true,
        learningStyle: { visual: 25, auditory: 25, reading: 25, kinesthetic: 25 }
      }
    ];

    for (const userData of testUsers) {
      const existingUser = await User.findOne({ email: userData.email });
      if (!existingUser) {
        const user = new User(userData);
        await user.save();
        console.log(` Created user: ${userData.email}`);
      }
    }
  } catch (error) {
    console.error(' Error creating test users:', error);
  }
};

// Run the check
connectDB().then(checkDatabase);