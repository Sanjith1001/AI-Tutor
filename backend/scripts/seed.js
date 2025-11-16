const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
require('dotenv').config();

const User = require('../models/User');

const seedUsers = [
  {
    email: 'admin@bytebrain.com',
    password: 'admin123',
    firstName: 'Admin',
    lastName: 'User',
    role: 'admin',
    isEmailVerified: true,
    learningStyle: {
      visual: 30,
      auditory: 25,
      reading: 25,
      kinesthetic: 20,
    },
    preferences: {
      theme: 'dark',
      language: 'en',
      notifications: {
        email: true,
        push: true,
        reminders: true,
      },
      difficulty: 'advanced',
    },
    bio: 'System administrator for AI-Tutor platform',
    country: 'United States',
    timezone: 'America/New_York',
  },
  {
    email: 'student@bytebrain.com',
    password: 'student123',
    firstName: 'John',
    lastName: 'Doe',
    role: 'student',
    isEmailVerified: true,
    learningStyle: {
      visual: 35,
      auditory: 25,
      reading: 25,
      kinesthetic: 15,
    },
    preferences: {
      theme: 'light',
      language: 'en',
      notifications: {
        email: true,
        push: true,
        reminders: true,
      },
      difficulty: 'beginner',
    },
    bio: 'Enthusiastic learner exploring AI and technology',
    country: 'United Kingdom',
    timezone: 'Europe/London',
  },
  {
    email: 'demo@bytebrain.com',
    password: 'demo123',
    firstName: 'Demo',
    lastName: 'Student',
    role: 'student',
    isEmailVerified: true,
    learningStyle: {
      visual: 40,
      auditory: 30,
      reading: 20,
      kinesthetic: 10,
    },
    preferences: {
      theme: 'auto',
      language: 'en',
      notifications: {
        email: false,
        push: true,
        reminders: false,
      },
      difficulty: 'intermediate',
    },
    bio: 'Demo user for testing the AI-Tutor platform features',
    country: 'Australia',
    timezone: 'Australia/Sydney',
  },
];

const connectDB = async () => {
  try {
    const mongoURI = process.env.MONGODB_URI || 'mongodb://localhost:27017/ai_tutor_db';
    await mongoose.connect(mongoURI);
    console.log('✅ MongoDB Connected for seeding');
  } catch (error) {
    console.error('❌ MongoDB connection failed:', error.message);
    process.exit(1);
  }
};

const seedDatabase = async () => {
  try {
    console.log('🌱 Starting database seeding...');

    // Clear existing users
    await User.deleteMany({});
    console.log('🗑️  Cleared existing users');

    // Create seed users
    for (const userData of seedUsers) {
      const user = new User(userData);
      await user.save();
      console.log(`✅ Created user: ${user.email} (${user.role})`);
    }

    console.log('🎉 Database seeding completed successfully!');
    console.log('\n📋 Seed Users Created:');
    console.log('Admin: admin@bytebrain.com / admin123');
    console.log('Student: student@bytebrain.com / student123');
    console.log('Demo: demo@bytebrain.com / demo123');
    
  } catch (error) {
    console.error('❌ Seeding failed:', error);
  } finally {
    await mongoose.connection.close();
    console.log('🔌 Database connection closed');
    process.exit(0);
  }
};

// Run seeding
const runSeed = async () => {
  await connectDB();
  await seedDatabase();
};

// Check if script is run directly
if (require.main === module) {
  runSeed();
}

module.exports = { seedDatabase, seedUsers };