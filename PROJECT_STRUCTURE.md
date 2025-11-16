# ByteBrain Project Structure

## 📁 Current Organization

```
bytebrain/
├── 📱 FRONTEND (Flutter/Dart)
│   ├── lib/                          # Flutter application code
│   │   ├── main.dart                 # App entry point
│   │   ├── screens/                  # UI screens
│   │   ├── widgets/                  # Reusable widgets
│   │   ├── services/                 # API & business logic
│   │   ├── themes/                   # App styling
│   │   └── models/                   # Data models
│   ├── assets/                       # Images, fonts, etc.
│   ├── android/                      # Android platform code
│   ├── ios/                          # iOS platform code
│   ├── web/                          # Web platform code
│   ├── windows/                      # Windows platform code
│   ├── linux/                        # Linux platform code
│   ├── macos/                        # macOS platform code
│   └── pubspec.yaml                  # Flutter dependencies
│
├── 🔧 BACKEND (Node.js/Express)
│   ├── backend/
│   │   ├── server.js                 # Main server file
│   │   ├── routes/                   # API routes
│   │   ├── controllers/              # Business logic
│   │   ├── models/                   # Database models
│   │   ├── middleware/               # Auth, validation, etc.
│   │   ├── config/                   # Configuration files
│   │   ├── utils/                    # Helper functions
│   │   ├── .env                      # Environment variables
│   │   └── package.json              # Node dependencies
│   │
│   ├── Byte_Brain/                   # Python AI Chatbot
│   │   ├── server.py                 # Groq chatbot server
│   │   ├── .env                      # Groq API key
│   │   ├── requirements.txt          # Python dependencies
│   │   └── .venv/                    # Python virtual environment
│   │
│   └── backend/python_chatbot/       # Alternative Python chatbot
│       ├── simple_chatbot.py         # Pattern-based chatbot
│       ├── chatbot_server.py         # Advanced chatbot
│       └── requirements.txt          # Python dependencies
│
├── 🗄️ DATABASE
│   ├── MongoDB (Cloud/Local)         # Main database
│   │   └── Connection via backend/config/db.js
│   │
│   └── Database Schema:
│       ├── Users                     # User accounts
│       ├── Courses                   # Course content
│       ├── Progress                  # Learning progress
│       ├── Assessments               # Quiz results
│       └── Activities                # User activities
│
├── 🚀 DEPLOYMENT
│   ├── docker-compose.yml            # Docker configuration
│   ├── nginx/                        # Web server config
│   └── Startup scripts:
│       ├── start_groq_chatbot.bat    # Start Groq server
│       ├── start_groq_chatbot.sh     # Start Groq server (Linux)
│       └── setup.bat/sh              # Project setup
│
└── 📚 DOCUMENTATION
    ├── README.md                     # Project overview
    ├── SETUP_GUIDE.md                # Setup instructions
    ├── GROQ_CHATBOT_INTEGRATION.md  # Chatbot docs
    ├── PYTHON_CHATBOT_INTEGRATION.md # Python chatbot docs
    └── YOUTUBE_INTEGRATION.md        # YouTube feature docs
```

## 🎯 Component Breakdown

### Frontend (Flutter)
**Location**: `lib/`
- **Purpose**: Mobile/Web/Desktop application
- **Technology**: Flutter/Dart
- **Key Files**:
  - `lib/main.dart` - App entry point
  - `lib/screens/` - All UI screens
  - `lib/services/` - API communication
  - `lib/widgets/` - Reusable components

### Backend (Node.js)
**Location**: `backend/`
- **Purpose**: REST API server
- **Technology**: Node.js, Express, MongoDB
- **Key Files**:
  - `backend/server.js` - Main server
  - `backend/routes/` - API endpoints
  - `backend/models/` - Database schemas
  - `backend/controllers/` - Business logic

### AI Chatbot (Python)
**Location**: `Byte_Brain/`
- **Purpose**: AI-powered educational assistant
- **Technology**: Python, Groq API, Llama 3.1
- **Key Files**:
  - `Byte_Brain/server.py` - Groq chatbot server
  - `Byte_Brain/.env` - API configuration
  - Port: 5000

### Database (MongoDB)
**Location**: Cloud/Local MongoDB instance
- **Purpose**: Data persistence
- **Technology**: MongoDB
- **Collections**:
  - users
  - courses
  - progress
  - assessments
  - activities

## 🔄 Data Flow

```
┌─────────────┐
│   Flutter   │ ◄──── User Interface
│   Frontend  │
└──────┬──────┘
       │ HTTP/REST API
       ▼
┌─────────────┐
│   Node.js   │ ◄──── Business Logic
│   Backend   │
└──────┬──────┘
       │ MongoDB Driver
       ▼
┌─────────────┐
│   MongoDB   │ ◄──── Data Storage
│   Database  │
└─────────────┘

┌─────────────┐
│   Python    │ ◄──── AI Assistant
│   Chatbot   │       (Groq/Llama 3.1)
└─────────────┘
       ▲
       │ HTTP API
       │
   Flutter App
```

## 📦 Dependencies

### Frontend (Flutter)
- flutter_dotenv
- http
- shared_preferences
- flutter_markdown
- url_launcher
- video_player
- youtube_player_flutter

### Backend (Node.js)
- express
- mongoose
- cors
- dotenv
- bcryptjs
- jsonwebtoken

### AI Chatbot (Python)
- flask
- flask-cors
- groq
- python-dotenv

## 🚀 Getting Started

### 1. Setup Backend
```bash
cd backend
npm install
npm start
```

### 2. Setup AI Chatbot
```bash
cd Byte_Brain
pip install -r requirements.txt
python server.py
```

### 3. Setup Frontend
```bash
flutter pub get
flutter run
```

## 🔐 Environment Variables

### Backend (.env)
```
MONGODB_URI=your_mongodb_connection_string
JWT_SECRET=your_jwt_secret
PORT=3000
```

### AI Chatbot (Byte_Brain/.env)
```
GROQ_API_KEY=your_groq_api_key
```

### Frontend (.env)
```
BACKEND_URL=http://localhost:3000
GROQ_CHATBOT_URL=http://localhost:5000
```

## 📊 Port Configuration

- **Frontend**: Various (Flutter dev server)
- **Backend**: 3000 (Node.js/Express)
- **AI Chatbot**: 5000 (Python/Flask)
- **Database**: 27017 (MongoDB default)

## 🎓 Key Features by Layer

### Frontend Features
- User authentication
- Course browsing
- VARK learning style quiz
- AI chatbot interface
- Progress tracking
- Video content player
- Dynamic assessments

### Backend Features
- User management
- Course CRUD operations
- Authentication & authorization
- Progress tracking
- Assessment management
- Activity logging

### AI Chatbot Features
- Educational Q&A
- Contextual suggestions
- Conversation memory
- Multi-subject support
- Real-time responses

### Database Features
- User profiles
- Course content
- Learning progress
- Quiz results
- Activity logs
- Session management
