const mongoose = require('mongoose');
const User = require('../models/User');
const Course = require('../models/Course');
require('dotenv').config();

// Connect to MongoDB
const connectDB = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/bytebrain_db');
    console.log('✅ MongoDB connected for seeding');
  } catch (error) {
    console.error('❌ MongoDB connection failed:', error);
    process.exit(1);
  }
};

// Sample users data
const sampleUsers = [
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
      kinesthetic: 20
    },
    preferences: {
      theme: 'dark',
      language: 'en',
      difficulty: 'advanced'
    }
  },
  {
    email: 'teacher@bytebrain.com',
    password: 'teacher123',
    firstName: 'Sarah',
    lastName: 'Johnson',
    role: 'teacher',
    isEmailVerified: true,
    bio: 'Experienced educator with 10+ years in computer science',
    learningStyle: {
      visual: 35,
      auditory: 30,
      reading: 25,
      kinesthetic: 10
    },
    preferences: {
      theme: 'light',
      language: 'en',
      difficulty: 'advanced'
    }
  },
  {
    email: 'student1@bytebrain.com',
    password: 'student123',
    firstName: 'Alex',
    lastName: 'Chen',
    role: 'student',
    isEmailVerified: true,
    bio: 'Computer science student passionate about AI and machine learning',
    learningStyle: {
      visual: 40,
      auditory: 20,
      reading: 30,
      kinesthetic: 10
    },
    preferences: {
      theme: 'auto',
      language: 'en',
      difficulty: 'intermediate'
    }
  },
  {
    email: 'student2@bytebrain.com',
    password: 'student123',
    firstName: 'Maria',
    lastName: 'Rodriguez',
    role: 'student',
    isEmailVerified: true,
    bio: 'Learning web development and UI/UX design',
    learningStyle: {
      visual: 50,
      auditory: 15,
      reading: 20,
      kinesthetic: 15
    },
    preferences: {
      theme: 'light',
      language: 'en',
      difficulty: 'beginner'
    }
  },
  {
    email: 'student3@bytebrain.com',
    password: 'student123',
    firstName: 'David',
    lastName: 'Kim',
    role: 'student',
    isEmailVerified: true,
    bio: 'Data science enthusiast exploring machine learning',
    learningStyle: {
      visual: 25,
      auditory: 35,
      reading: 30,
      kinesthetic: 10
    },
    preferences: {
      theme: 'dark',
      language: 'en',
      difficulty: 'intermediate'
    }
  }
];

// Sample courses data
const sampleCourses = [
  {
    title: 'Introduction to JavaScript',
    description: 'Learn the fundamentals of JavaScript programming language',
    category: 'Programming',
    difficulty: 'beginner',
    duration: 480, // 8 hours
    price: 49.99,
    tags: ['javascript', 'programming', 'web-development'],
    learningObjectives: [
      'Understand JavaScript syntax and basic concepts',
      'Work with variables, functions, and objects',
      'Handle events and DOM manipulation',
      'Build interactive web applications'
    ],
    modules: [
      {
        title: 'Getting Started with JavaScript',
        description: 'Introduction to JavaScript and setting up development environment',
        duration: 60,
        order: 1,
        content: {
          text: 'JavaScript is a versatile programming language...',
          videoUrl: 'https://example.com/js-intro',
          resources: ['https://developer.mozilla.org/en-US/docs/Web/JavaScript']
        }
      },
      {
        title: 'Variables and Data Types',
        description: 'Learn about different data types and how to work with variables',
        duration: 90,
        order: 2,
        content: {
          text: 'Variables are containers for storing data values...',
          videoUrl: 'https://example.com/js-variables',
          resources: ['https://javascript.info/variables']
        }
      }
    ],
    isPublished: true
  },
  {
    title: 'React Fundamentals',
    description: 'Master the basics of React.js for building modern web applications',
    category: 'Web Development',
    difficulty: 'intermediate',
    duration: 720, // 12 hours
    price: 79.99,
    tags: ['react', 'javascript', 'frontend', 'components'],
    learningObjectives: [
      'Understand React components and JSX',
      'Manage state and props effectively',
      'Handle events and user interactions',
      'Build reusable UI components'
    ],
    modules: [
      {
        title: 'Introduction to React',
        description: 'What is React and why use it?',
        duration: 90,
        order: 1,
        content: {
          text: 'React is a JavaScript library for building user interfaces...',
          videoUrl: 'https://example.com/react-intro',
          resources: ['https://reactjs.org/docs/getting-started.html']
        }
      }
    ],
    isPublished: true
  },
  {
    title: 'Python for Data Science',
    description: 'Learn Python programming with focus on data analysis and visualization',
    category: 'Data Science',
    difficulty: 'intermediate',
    duration: 960, // 16 hours
    price: 99.99,
    tags: ['python', 'data-science', 'pandas', 'numpy', 'matplotlib'],
    learningObjectives: [
      'Master Python programming fundamentals',
      'Work with NumPy and Pandas libraries',
      'Create data visualizations with Matplotlib',
      'Perform statistical analysis on datasets'
    ],
    modules: [
      {
        title: 'Python Basics for Data Science',
        description: 'Essential Python concepts for data analysis',
        duration: 120,
        order: 1,
        content: {
          text: 'Python is an excellent language for data science...',
          videoUrl: 'https://example.com/python-data-intro',
          resources: ['https://pandas.pydata.org/docs/']
        }
      }
    ],
    isPublished: true
  }
];

// Seed function
const seedDatabase = async () => {
  try {
    console.log('🌱 Starting database seeding...');

    // Clear existing data
    await User.deleteMany({});
    await Course.deleteMany({});
    console.log('🗑️  Cleared existing data');

    // Create users
    const createdUsers = [];
    for (const userData of sampleUsers) {
      const user = new User(userData);
      await user.save();
      createdUsers.push(user);
      console.log(`👤 Created user: ${user.email} (${user.role})`);
    }

    // Create courses and assign instructor
    const teacher = createdUsers.find(user => user.role === 'teacher');
    const students = createdUsers.filter(user => user.role === 'student');

    for (const courseData of sampleCourses) {
      courseData.instructor = teacher._id;
      const course = new Course(courseData);
      await course.save();

      // Enroll some students in courses
      const enrolledStudents = students.slice(0, Math.floor(Math.random() * students.length) + 1);
      for (const student of enrolledStudents) {
        course.enrolledStudents.push({
          student: student._id,
          enrolledAt: new Date(),
          progress: Math.floor(Math.random() * 50) // Random progress 0-50%
        });
        student.coursesEnrolled.push(course._id);
        await student.save();
      }
      await course.save();

      console.log(`📚 Created course: ${course.title} with ${enrolledStudents.length} students`);
    }

    console.log('\n✅ Database seeding completed successfully!');
    console.log('\n📋 Test Accounts Created:');
    console.log('Admin: admin@bytebrain.com / admin123');
    console.log('Teacher: teacher@bytebrain.com / teacher123');
    console.log('Student 1: student1@bytebrain.com / student123');
    console.log('Student 2: student2@bytebrain.com / student123');
    console.log('Student 3: student3@bytebrain.com / student123');
    console.log('\n🚀 You can now test the API endpoints!');

  } catch (error) {
    console.error('❌ Seeding failed:', error);
  } finally {
    await mongoose.connection.close();
    console.log('🔌 Database connection closed');
  }
};

// Run seeding
connectDB().then(seedDatabase);