const mongoose = require('mongoose');
const Course = require('../models/Course');
const User = require('../models/User');
require('dotenv').config();

const connectDB = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ MongoDB Connected for Course Seeding');
  } catch (error) {
    console.error('❌ MongoDB connection error:', error);
    process.exit(1);
  }
};

const seedCourses = async () => {
  try {
    // Find admin user to be the course creator
    const adminUser = await User.findOne({ email: 'admin@aitutor.com' });
    if (!adminUser) {
      console.error('❌ Admin user not found. Please run user seed first.');
      return;
    }

    // Clear existing courses
    await Course.deleteMany({});
    console.log('🗑️  Cleared existing courses');

    const sampleCourses = [
      {
        title: 'Introduction to JavaScript Programming',
        description: 'Learn the fundamentals of JavaScript programming from scratch. This comprehensive course covers variables, functions, objects, arrays, and modern ES6+ features. Perfect for beginners who want to start their programming journey.',
        shortDescription: 'Master JavaScript fundamentals with hands-on projects and real-world examples.',
        category: 'programming',
        subcategory: 'web-development',
        difficulty: 'beginner',
        prerequisites: ['Basic computer skills', 'Text editor knowledge'],
        isPublished: true,
        isFree: true,
        thumbnail: 'https://images.unsplash.com/photo-1627398242454-45a1465c2479?w=400',
        learningOutcomes: [
          'Understand JavaScript syntax and fundamentals',
          'Work with variables, functions, and objects',
          'Build interactive web applications',
          'Use modern ES6+ features effectively'
        ],
        tags: ['javascript', 'programming', 'web-development', 'beginner'],
        createdBy: adminUser._id,
        instructors: [adminUser._id],
        modules: [
          {
            title: 'Getting Started with JavaScript',
            description: 'Introduction to JavaScript, setting up development environment, and writing your first program.',
            content: `# Welcome to JavaScript Programming!

JavaScript is one of the most popular programming languages in the world. It's used for:
- Web development (frontend and backend)
- Mobile app development
- Desktop applications
- Game development

## Setting Up Your Environment

1. **Code Editor**: We recommend Visual Studio Code
2. **Web Browser**: Chrome or Firefox with developer tools
3. **Node.js**: For running JavaScript outside the browser

## Your First JavaScript Program

\`\`\`javascript
console.log("Hello, World!");
\`\`\`

This simple line of code will output "Hello, World!" to the console.

## Variables in JavaScript

Variables are containers for storing data values:

\`\`\`javascript
let name = "John";
const age = 25;
var city = "New York";
\`\`\`

- \`let\`: Block-scoped variable
- \`const\`: Block-scoped constant
- \`var\`: Function-scoped variable (older syntax)
`,
            contentType: 'text',
            duration: 45,
            order: 1,
            learningObjectives: [
              'Set up JavaScript development environment',
              'Understand what JavaScript is used for',
              'Write your first JavaScript program',
              'Learn about variables and their types'
            ],
            resources: [
              {
                title: 'MDN JavaScript Guide',
                url: 'https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide',
                type: 'article'
              },
              {
                title: 'Visual Studio Code Download',
                url: 'https://code.visualstudio.com/',
                type: 'link'
              }
            ]
          },
          {
            title: 'Data Types and Operators',
            description: 'Learn about JavaScript data types, operators, and how to work with different kinds of data.',
            content: `# JavaScript Data Types

JavaScript has several built-in data types:

## Primitive Types

1. **Number**: \`42\`, \`3.14\`, \`-7\`
2. **String**: \`"Hello"\`, \`'World'\`, \`\`template\`\`
3. **Boolean**: \`true\`, \`false\`
4. **Undefined**: \`undefined\`
5. **Null**: \`null\`
6. **Symbol**: \`Symbol('id')\`
7. **BigInt**: \`123n\`

## Complex Types

1. **Object**: \`{name: "John", age: 30}\`
2. **Array**: \`[1, 2, 3, 4, 5]\`
3. **Function**: \`function greet() { return "Hello"; }\`

## Operators

### Arithmetic Operators
\`\`\`javascript
let a = 10;
let b = 3;

console.log(a + b); // 13 (addition)
console.log(a - b); // 7 (subtraction)
console.log(a * b); // 30 (multiplication)
console.log(a / b); // 3.333... (division)
console.log(a % b); // 1 (modulus)
\`\`\`

### Comparison Operators
\`\`\`javascript
console.log(5 == "5");  // true (loose equality)
console.log(5 === "5"); // false (strict equality)
console.log(10 > 5);    // true
console.log(3 <= 3);    // true
\`\`\`

### Logical Operators
\`\`\`javascript
console.log(true && false); // false (AND)
console.log(true || false); // true (OR)
console.log(!true);         // false (NOT)
\`\`\`
`,
            contentType: 'text',
            duration: 60,
            order: 2,
            learningObjectives: [
              'Identify different JavaScript data types',
              'Use arithmetic operators effectively',
              'Understand comparison and logical operators',
              'Work with strings, numbers, and booleans'
            ]
          },
          {
            title: 'Functions and Scope',
            description: 'Master JavaScript functions, parameters, return values, and understand scope concepts.',
            content: `# JavaScript Functions

Functions are reusable blocks of code that perform specific tasks.

## Function Declaration

\`\`\`javascript
function greet(name) {
    return "Hello, " + name + "!";
}

console.log(greet("Alice")); // "Hello, Alice!"
\`\`\`

## Function Expression

\`\`\`javascript
const add = function(a, b) {
    return a + b;
};

console.log(add(5, 3)); // 8
\`\`\`

## Arrow Functions (ES6+)

\`\`\`javascript
const multiply = (a, b) => a * b;
const square = x => x * x;
const sayHello = () => "Hello!";

console.log(multiply(4, 5)); // 20
console.log(square(6));      // 36
console.log(sayHello());     // "Hello!"
\`\`\`

## Scope

### Global Scope
Variables declared outside any function have global scope:

\`\`\`javascript
let globalVar = "I'm global";

function showGlobal() {
    console.log(globalVar); // Accessible
}
\`\`\`

### Function Scope
Variables declared inside a function are only accessible within that function:

\`\`\`javascript
function myFunction() {
    let localVar = "I'm local";
    console.log(localVar); // Accessible
}

// console.log(localVar); // Error: localVar is not defined
\`\`\`

### Block Scope
Variables declared with \`let\` and \`const\` have block scope:

\`\`\`javascript
if (true) {
    let blockVar = "I'm in a block";
    console.log(blockVar); // Accessible
}

// console.log(blockVar); // Error: blockVar is not defined
\`\`\`
`,
            contentType: 'text',
            duration: 75,
            order: 3,
            learningObjectives: [
              'Create and call functions',
              'Use parameters and return values',
              'Understand different function syntaxes',
              'Master scope concepts in JavaScript'
            ]
          }
        ]
      },
      {
        title: 'Python for Data Science',
        description: 'Comprehensive Python course focused on data science applications. Learn pandas, numpy, matplotlib, and machine learning basics with real-world datasets and projects.',
        shortDescription: 'Master Python for data analysis, visualization, and machine learning.',
        category: 'programming',
        subcategory: 'data-science',
        difficulty: 'intermediate',
        prerequisites: ['Basic programming knowledge', 'High school mathematics'],
        isPublished: true,
        isFree: false,
        price: 99.99,
        thumbnail: 'https://images.unsplash.com/photo-1526379095098-d400fd0bf935?w=400',
        learningOutcomes: [
          'Master Python programming for data science',
          'Analyze and visualize data with pandas and matplotlib',
          'Build machine learning models',
          'Work with real-world datasets'
        ],
        tags: ['python', 'data-science', 'machine-learning', 'pandas', 'numpy'],
        createdBy: adminUser._id,
        instructors: [adminUser._id],
        modules: [
          {
            title: 'Python Fundamentals for Data Science',
            description: 'Essential Python concepts needed for data science work.',
            content: `# Python for Data Science

Python is the most popular language for data science due to its simplicity and powerful libraries.

## Why Python for Data Science?

- **Easy to learn**: Clean, readable syntax
- **Rich ecosystem**: NumPy, Pandas, Matplotlib, Scikit-learn
- **Community support**: Large, active community
- **Versatility**: Web development, automation, AI/ML

## Essential Python Concepts

### Lists and List Comprehensions
\`\`\`python
# Basic list operations
numbers = [1, 2, 3, 4, 5]
squared = [x**2 for x in numbers]
print(squared)  # [1, 4, 9, 16, 25]

# Filtering with list comprehensions
even_numbers = [x for x in numbers if x % 2 == 0]
print(even_numbers)  # [2, 4]
\`\`\`

### Dictionaries for Data
\`\`\`python
# Student data
student = {
    'name': 'Alice',
    'age': 22,
    'grades': [85, 92, 78, 96]
}

print(f"{student['name']} is {student['age']} years old")
print(f"Average grade: {sum(student['grades']) / len(student['grades'])}")
\`\`\`

### Functions for Reusability
\`\`\`python
def calculate_statistics(data):
    return {
        'mean': sum(data) / len(data),
        'min': min(data),
        'max': max(data),
        'count': len(data)
    }

grades = [85, 92, 78, 96, 88]
stats = calculate_statistics(grades)
print(stats)
\`\`\`
`,
            contentType: 'text',
            duration: 90,
            order: 1,
            learningObjectives: [
              'Review Python fundamentals',
              'Master list comprehensions',
              'Work with dictionaries effectively',
              'Create reusable functions for data processing'
            ]
          }
        ]
      },
      {
        title: 'Digital Marketing Fundamentals',
        description: 'Complete guide to digital marketing including SEO, social media marketing, content marketing, email marketing, and analytics. Learn to create effective marketing campaigns.',
        shortDescription: 'Master digital marketing strategies and tools for business growth.',
        category: 'business',
        subcategory: 'marketing',
        difficulty: 'beginner',
        prerequisites: ['Basic computer skills', 'Understanding of social media'],
        isPublished: true,
        isFree: true,
        thumbnail: 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=400',
        learningOutcomes: [
          'Understand digital marketing landscape',
          'Create effective SEO strategies',
          'Manage social media campaigns',
          'Analyze marketing performance'
        ],
        tags: ['marketing', 'seo', 'social-media', 'analytics', 'business'],
        createdBy: adminUser._id,
        instructors: [adminUser._id],
        modules: [
          {
            title: 'Introduction to Digital Marketing',
            description: 'Overview of digital marketing channels, strategies, and the modern marketing landscape.',
            content: `# Digital Marketing in the Modern World

Digital marketing has revolutionized how businesses reach and engage with customers.

## What is Digital Marketing?

Digital marketing encompasses all marketing efforts that use electronic devices or the internet. It includes:

- **Search Engine Optimization (SEO)**
- **Pay-Per-Click Advertising (PPC)**
- **Social Media Marketing**
- **Content Marketing**
- **Email Marketing**
- **Affiliate Marketing**
- **Influencer Marketing**

## The Digital Marketing Funnel

### 1. Awareness Stage
- **Goal**: Make potential customers aware of your brand
- **Tactics**: Content marketing, social media, SEO, display ads
- **Metrics**: Impressions, reach, brand mentions

### 2. Consideration Stage
- **Goal**: Nurture leads and build trust
- **Tactics**: Email campaigns, retargeting, webinars, case studies
- **Metrics**: Click-through rates, time on site, downloads

### 3. Conversion Stage
- **Goal**: Convert prospects into customers
- **Tactics**: Landing pages, special offers, testimonials
- **Metrics**: Conversion rate, cost per acquisition, sales

### 4. Retention Stage
- **Goal**: Keep customers engaged and encourage repeat business
- **Tactics**: Email newsletters, loyalty programs, customer support
- **Metrics**: Customer lifetime value, retention rate, repeat purchases

## Key Digital Marketing Channels

### Search Engine Marketing
- **Organic (SEO)**: Optimize content to rank higher in search results
- **Paid (PPC)**: Pay for ads to appear in search results

### Social Media Marketing
- **Organic**: Build community and engage with followers
- **Paid**: Target specific audiences with sponsored content

### Content Marketing
- Create valuable, relevant content to attract and retain customers
- Blog posts, videos, podcasts, infographics, ebooks

### Email Marketing
- Direct communication with subscribers
- Newsletters, promotional emails, automated sequences
`,
            contentType: 'text',
            duration: 60,
            order: 1,
            learningObjectives: [
              'Understand the digital marketing landscape',
              'Learn about different marketing channels',
              'Understand the marketing funnel',
              'Identify key performance metrics'
            ]
          }
        ]
      }
    ];

    const createdCourses = await Course.insertMany(sampleCourses);
    
    console.log('✅ Sample courses created successfully!');
    console.log(`📚 Created ${createdCourses.length} courses:`);
    
    createdCourses.forEach((course, index) => {
      console.log(`${index + 1}. ${course.title} (${course.category})`);
      console.log(`   - Difficulty: ${course.difficulty}`);
      console.log(`   - Modules: ${course.modules.length}`);
      console.log(`   - Free: ${course.isFree ? 'Yes' : 'No'}`);
      console.log('');
    });

  } catch (error) {
    console.error('❌ Error seeding courses:', error);
  }
};

const runSeed = async () => {
  await connectDB();
  await seedCourses();
  await mongoose.connection.close();
  console.log('🔌 Database connection closed');
};

runSeed();