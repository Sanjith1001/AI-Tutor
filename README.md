# ByteBrain

ByteBrain is an AI-assisted learning platform for personalized courses, quizzes,
progress tracking, educational videos, and chatbot-based question answering.
The repository contains a Flutter client, a Node.js API, and optional Python
chatbot services.

## Features

- Flutter application for web, Windows, Android, iOS, macOS, and Linux.
- User registration, login, profile, learning preferences, and progress history.
- Courses, modules, quizzes, dashboard analytics, and activity tracking.
- AI-generated learning content and chat using Groq.
- Optional Python chatbot services for educational Q&A.
- MongoDB persistence, Socket.IO support, and Docker Compose infrastructure.

## Repository layout

```text
bytebrain/
├── frontend/                 # Flutter application
│   ├── lib/                  # Screens, services, widgets, themes, and models
│   ├── assets/               # Images, fonts, data, and avatars
│   └── pubspec.yaml
├── backend/                  # Node.js/Express REST API
│   ├── config/               # Database and service configuration
│   ├── middleware/           # Authentication and error handling
│   ├── models/               # Mongoose models
│   ├── routes/               # API route modules
│   ├── services/             # Application services
│   └── package.json
├── backend/groq_chatbot/     # Flask chatbot backed by Groq
├── backend/python_chatbot/   # Optional Python chatbot service
├── docker-compose.yml        # MongoDB, Redis, API, and proxy stack
└── .gitignore
```

The `nginx/` directory is intentionally ignored because reverse-proxy
configuration and TLS certificates are deployment-specific. Keep local copies
outside Git or provide deployment configuration through your hosting platform.

## Requirements

- Git
- Flutter SDK 3.0 or newer
- Node.js 18 or newer and npm
- MongoDB (local or MongoDB Atlas)
- Python 3.9 or newer for the chatbot services
- Docker Desktop (optional, for the containerized stack)

## Configuration

Copy the relevant example files and keep credentials local. Never commit API
keys, database passwords, JWT secrets, service-account JSON files, or production
`.env` files.

### Frontend

Create `frontend/.env`:

```env
BACKEND_URL=http://localhost:3000
API_URL=http://localhost:3000/api
GROQ_CHATBOT_URL=http://localhost:5000
GROQ_API_KEY=your_groq_api_key
YOUTUBE_API_KEY=your_youtube_api_key
```

### Node.js backend

Create `backend/.env`:

```env
PORT=3000
NODE_ENV=development
MONGODB_URI=mongodb://localhost:27017/bytebrain_db
JWT_SECRET=replace_with_a_long_random_secret
JWT_EXPIRE=7d
JWT_REFRESH_EXPIRE=30d
```

### Groq chatbot

Create `backend/.env` or configure the environment before starting the service:

```env
GROQ_API_KEY=your_groq_api_key
```

The Groq chatbot listens on port `5000` by default. If no key is configured,
its health endpoint still works, while chat requests return a clear
configuration error.

## Local development

Install dependencies once:

```powershell
cd backend
npm install

cd ..\frontend
flutter pub get
```

Start MongoDB, then run the services in separate terminals:

```powershell
# Terminal 1: Node.js API
cd backend
npm run dev

# Terminal 2: Groq chatbot
cd backend\groq_chatbot
python server.py

# Terminal 3: Flutter frontend
cd frontend
flutter run -d chrome
```

Other Flutter targets:

```powershell
flutter run -d windows
flutter run -d android
flutter run -d ios
```

Useful health checks:

```text
Node API:       http://localhost:3000/health
Groq chatbot:   http://localhost:5000/health
```

## Docker Compose

Docker Compose can run MongoDB, Redis, and the Node.js API:

```powershell
docker compose up --build
```

The compose file also contains an optional Nginx reverse-proxy service. Because
`nginx/` is ignored, provide your own `nginx/nginx.conf` and certificate files
locally before enabling that service.

Stop the stack:

```powershell
docker compose down
```

Remove local database and cache volumes only when you intentionally want to
delete development data:

```powershell
docker compose down -v
```

## Testing and quality checks

```powershell
# Flutter
cd frontend
flutter analyze
flutter test

# Backend
cd ..\backend
npm test
```

Run the backend integration checks only after the API and its database are
available:

```powershell
npm run test:backend
```

## API overview

The API is served from `http://localhost:3000`. Common route groups include:

- `/auth` - registration, login, token refresh, and account recovery
- `/users` - profiles, preferences, and learning style
- `/courses` - courses and learning modules
- `/quizzes` - quiz content and responses
- `/activities` - activity history and dashboard statistics
- `/analytics` - learning analytics
- `/youtube` - educational video search
- `/health` - service health

See `backend/docs/api_documentation.js` and the route files under
`backend/routes/` for endpoint details.

## Git and secrets

Generated files, dependency directories, local environments, logs, build
outputs, database files, credentials, and the deployment-specific `nginx/`
directory are ignored by Git. Dependency lockfiles such as
`backend/package-lock.json` and `frontend/pubspec.lock` remain tracked for
reproducible installs.

Before pushing changes:

```powershell
git status
git diff --check
git add .
git diff --cached --stat
git commit -m "Describe the change"
git push origin main
```

If a secret was previously committed, rotate it immediately. Removing a file
from the latest commit does not remove it from Git history.
