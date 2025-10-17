# AI-Tutor Backend API 🚀

A robust Node.js backend API for the AI-Tutor Flutter application, providing authentication, user management, and personalized learning features using MongoDB.

## 🏗️ Architecture

```
backend/
├── config/
│   └── database.js          # MongoDB connection configuration
├── middleware/
│   ├── auth.js             # JWT authentication & authorization
│   └── errorHandler.js     # Global error handling
├── models/
│   └── User.js             # User model with VARK learning styles
├── routes/
│   ├── auth.js             # Authentication endpoints
│   └── users.js            # User management endpoints
├── scripts/
│   └── seed.js             # Database seeding script
├── utils/
│   └── email.js            # Email service with templates
├── .env.example            # Environment variables template
├── package.json            # Dependencies and scripts
└── server.js               # Main application entry point
```

## 🚀 Quick Start

### 1. Install Dependencies
```bash
cd backend
npm install
```

### 2. Database Setup

#### Option A: Local MongoDB
```bash
# Install MongoDB Community Edition
# Windows: Download from https://www.mongodb.com/try/download/community
# macOS: brew install mongodb-community
# Ubuntu: Follow official MongoDB installation guide

# Start MongoDB service
# Windows: Start MongoDB service from Services
# macOS: brew services start mongodb-community
# Ubuntu: sudo systemctl start mongod

# MongoDB will create the database automatically when first used
```

#### Option B: MongoDB Atlas (Cloud)
1. Create account at [MongoDB Atlas](https://www.mongodb.com/atlas)
2. Create a new cluster
3. Get connection string and update `.env` file

### 3. Environment Configuration
```bash
# Copy environment template
cp .env.example .env

# Edit .env with your configuration
```

### 4. Seed Database (Optional)
```bash
# Create initial admin, teacher, and student users
npm run seed
```

### 5. Start Development Server
```bash
npm run dev
```

The server will start on `http://localhost:3000`

## 🔐 Authentication Endpoints

### Register User
```http
POST /api/auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "securepassword",
  "firstName": "John",
  "lastName": "Doe",
  "learningStyle": {
    "visual": 40,
    "auditory": 30,
    "reading": 20,
    "kinesthetic": 10
  }
}
```

### Login User
```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "securepassword"
}
```

### Get Current User
```http
GET /api/auth/me
Authorization: Bearer <jwt_token>
```

### Refresh Token
```http
POST /api/auth/refresh
Content-Type: application/json

{
  "refreshToken": "<refresh_token>"
}
```

### Verify Email
```http
POST /api/auth/verify-email
Content-Type: application/json

{
  "token": "<verification_token>"
}
```

### Forgot Password
```http
POST /api/auth/forgot-password
Content-Type: application/json

{
  "email": "user@example.com"
}
```

### Reset Password
```http
POST /api/auth/reset-password
Content-Type: application/json

{
  "token": "<reset_token>",
  "password": "newpassword"
}
```

## 👤 User Management Endpoints

### Get User Profile
```http
GET /api/users/profile
Authorization: Bearer <jwt_token>
```

### Update Profile
```http
PUT /api/users/profile
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "firstName": "John",
  "lastName": "Doe",
  "bio": "Learning enthusiast",
  "country": "United States",
  "timezone": "America/New_York"
}
```

### Update Learning Style
```http
PUT /api/users/learning-style
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "learningStyle": {
    "visual": 50,
    "auditory": 25,
    "reading": 15,
    "kinesthetic": 10
  }
}
```

### Update Preferences
```http
PUT /api/users/preferences
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "preferences": {
    "theme": "dark",
    "language": "en",
    "notifications": {
      "email": true,
      "push": false,
      "reminders": true
    },
    "difficulty": "advanced"
  }
}
```

### Change Password
```http
PUT /api/users/change-password
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "currentPassword": "oldpassword",
  "newPassword": "newpassword"
}
```

## 🔧 Configuration

### Environment Variables

```env
# Server Configuration
PORT=3000
NODE_ENV=development

# MongoDB Configuration
MONGODB_URI=mongodb://localhost:27017/ai_tutor_db
# For MongoDB Atlas (cloud):
# MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/ai_tutor_db?retryWrites=true&w=majority

# JWT Configuration
JWT_SECRET=your_super_secret_jwt_key_here_make_it_long_and_random
JWT_EXPIRE=7d
JWT_REFRESH_EXPIRE=30d

# Email Configuration
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=your_email@gmail.com
EMAIL_PASSWORD=your_app_password

# Frontend URLs
FRONTEND_URL=http://localhost:3000
FLUTTER_APP_URL=http://localhost:8080

# Security
BCRYPT_SALT_ROUNDS=12
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100

# File Upload
MAX_FILE_SIZE=10485760
UPLOAD_PATH=uploads/
```

### Email Setup (Gmail)

1. Enable 2-Factor Authentication on your Gmail account
2. Generate an App Password:
   - Go to Google Account settings
   - Security → 2-Step Verification → App passwords
   - Generate password for "Mail"
3. Use the generated password in `EMAIL_PASSWORD`

## 📊 Database Schema

### Users Collection
```javascript
{
  _id: ObjectId,
  email: String, // unique, required
  password: String, // hashed, required
  firstName: String, // required
  lastName: String, // required
  role: String, // enum: ['student', 'teacher', 'admin']
  isEmailVerified: Boolean,
  emailVerificationToken: String,
  passwordResetToken: String,
  passwordResetExpires: Date,
  lastLogin: Date,
  isActive: Boolean,
  
  // VARK Learning Style
  learningStyle: {
    visual: Number, // 0-100
    auditory: Number, // 0-100
    reading: Number, // 0-100
    kinesthetic: Number // 0-100
  },
  
  // User Preferences
  preferences: {
    theme: String, // enum: ['light', 'dark', 'auto']
    language: String,
    notifications: {
      email: Boolean,
      push: Boolean,
      reminders: Boolean
    },
    difficulty: String // enum: ['beginner', 'intermediate', 'advanced']
  },
  
  // Profile Information
  avatar: String,
  bio: String,
  dateOfBirth: Date,
  country: String,
  timezone: String,
  
  // Analytics
  loginCount: Number,
  coursesEnrolled: [ObjectId], // refs to Course
  coursesCompleted: [ObjectId], // refs to Course
  totalLearningTime: Number, // in minutes
  
  createdAt: Date,
  updatedAt: Date
}
```

## 🛡️ Security Features

- **JWT Authentication** with access and refresh tokens
- **Password Hashing** using bcrypt with configurable salt rounds
- **Rate Limiting** to prevent abuse
- **Input Validation** using express-validator
- **CORS Protection** with configurable origins
- **Helmet.js** for security headers
- **Email Verification** for account activation
- **Password Reset** with time-limited tokens
- **Role-based Authorization** (student, teacher, admin)

## 🧪 Testing

### Health Check
```bash
curl http://localhost:3000/health
```

### Test Registration
```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "testpassword",
    "firstName": "Test",
    "lastName": "User"
  }'
```

## 📈 Next Steps

1. **Course Management Service** - CRUD operations for courses and modules
2. **AI Service Integration** - Groq API for content generation
3. **Media Service** - File upload and CDN integration
4. **YouTube Service** - Video content management
5. **Analytics Service** - Progress tracking and reporting
6. **Notification Service** - Push notifications and email campaigns

## 🤝 Integration with Flutter

### HTTP Client Setup
```dart
// In your Flutter app
class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';
  
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
      }),
    );
    
    return json.decode(response.body);
  }
}
```

## 🐛 Troubleshooting

### Common Issues

1. **Database Connection Failed**
   - Ensure MongoDB is running (`mongod` service)
   - Check MONGODB_URI in `.env`
   - For Atlas: verify connection string and network access

2. **Email Sending Failed**
   - Check Gmail App Password setup
   - Verify EMAIL_* environment variables
   - Test with `npm run test-email` (if implemented)

3. **JWT Token Issues**
   - Ensure JWT_SECRET is set and secure
   - Check token expiration settings
   - Verify Authorization header format: `Bearer <token>`

4. **Seeding Issues**
   - Run `npm run seed` to create initial users
   - Check MongoDB connection before seeding
   - Default users: admin@aitutor.com, teacher@aitutor.com, student@aitutor.com

## 📝 API Response Format

### Success Response
```json
{
  "success": true,
  "message": "Operation completed successfully",
  "data": {
    "user": { ... },
    "token": "jwt_token_here"
  }
}
```

### Error Response
```json
{
  "success": false,
  "message": "Error description",
  "errors": [
    {
      "field": "email",
      "message": "Email is required"
    }
  ]
}
```

## 🚀 Deployment

### Production Checklist
- [ ] Set `NODE_ENV=production`
- [ ] Use strong JWT_SECRET (32+ characters)
- [ ] Configure production database
- [ ] Set up SSL/HTTPS
- [ ] Configure CORS for production domains
- [ ] Set up monitoring and logging
- [ ] Configure email service for production
- [ ] Set up database backups

---

**Built with ❤️ for AI-Tutor Flutter App**