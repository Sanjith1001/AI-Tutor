# Project Reorganization Guide

## 📁 Files to Move to `frontend/` Folder

### ✅ **Flutter Core Files**
Move these folders and files to `frontend/`:

```
✓ lib/                          → frontend/lib/
✓ assets/                       → frontend/assets/
✓ test/                         → frontend/test/
✓ pubspec.yaml                  → frontend/pubspec.yaml
✓ pubspec.lock                  → frontend/pubspec.lock
✓ analysis_options.yaml         → frontend/analysis_options.yaml
✓ .metadata                     → frontend/.metadata
✓ .flutter-plugins-dependencies → frontend/.flutter-plugins-dependencies
```

### ✅ **Platform-Specific Folders**
Move these platform folders to `frontend/`:

```
✓ android/                      → frontend/android/
✓ ios/                          → frontend/ios/
✓ web/                          → frontend/web/
✓ windows/                      → frontend/windows/
✓ linux/                        → frontend/linux/
✓ macos/                        → frontend/macos/
```

### ✅ **Build Folders** (Optional - can be regenerated)
```
✓ build/                        → frontend/build/
✓ .dart_tool/                   → frontend/.dart_tool/
```

### ✅ **Frontend Environment File**
```
✓ .env (if it contains Flutter config) → frontend/.env
```

---

## 📁 Files to Keep in Root

### ❌ **DO NOT MOVE** - Keep in Root:
```
✗ backend/                      (Backend Node.js server)
✗ Byte_Brain/                   (Python AI chatbot)
✗ .git/                         (Git repository)
✗ .gitignore                    (Git configuration)
✗ docker-compose.yml            (Docker configuration)
✗ package.json                  (Root dependencies)
✗ package-lock.json             (Root dependencies)
✗ node_modules/                 (Root dependencies)
```

### 📚 **Documentation** - Move to `docs/`:
```
✓ README.md                     → docs/README.md
✓ PROJECT_STRUCTURE.md          → docs/PROJECT_STRUCTURE.md
✓ SETUP_GUIDE.md                → docs/SETUP_GUIDE.md
✓ SETUP_CHECKLIST.md            → docs/SETUP_CHECKLIST.md
✓ GROQ_CHATBOT_INTEGRATION.md   → docs/GROQ_CHATBOT_INTEGRATION.md
✓ PYTHON_CHATBOT_INTEGRATION.md → docs/PYTHON_CHATBOT_INTEGRATION.md
✓ YOUTUBE_INTEGRATION.md        → docs/YOUTUBE_INTEGRATION.md
✓ YOUTUBE_INTERFACE_README.md   → docs/YOUTUBE_INTERFACE_README.md
✓ fix_socket_error.md           → docs/fix_socket_error.md
```

### 🔧 **Scripts** - Move to `scripts/`:
```
✓ start_bytebrain_groq.bat      → scripts/start_bytebrain_groq.bat
✓ start_groq_chatbot.bat        → scripts/start_groq_chatbot.bat
✓ start_groq_chatbot.sh         → scripts/start_groq_chatbot.sh
✓ start_python_chatbot.bat      → scripts/start_python_chatbot.bat
✓ start_python_chatbot.sh       → scripts/start_python_chatbot.sh
✓ setup.bat                     → scripts/setup.bat
✓ setup.sh                      → scripts/setup.sh
✓ reorganize_project.bat        → scripts/reorganize_project.bat
```

### 🗑️ **Temporary Files** - Can Delete:
```
✗ fix_script.dart               (Delete or move to scripts/)
✗ temp_personalized_fix.dart    (Delete)
✗ apikey.txt                    (Delete - use .env instead)
```

---

## 🗄️ Database Folder Structure

Create `database/` folder and add:

```
database/
├── README.md                   (Database documentation)
├── schemas/                    (Database schema definitions)
│   ├── user.schema.md
│   ├── course.schema.md
│   ├── progress.schema.md
│   └── assessment.schema.md
└── migrations/                 (Database migration scripts)
```

---

## 📋 Step-by-Step Instructions

### Step 1: Move Frontend Files
```bash
# In your project root, run:
move lib frontend\
move assets frontend\
move android frontend\
move ios frontend\
move web frontend\
move windows frontend\
move linux frontend\
move macos frontend\
move test frontend\
move pubspec.yaml frontend\
move pubspec.lock frontend\
move analysis_options.yaml frontend\
move .metadata frontend\
```

### Step 2: Create and Organize Docs
```bash
mkdir docs
move *.md docs\
```

### Step 3: Create and Organize Scripts
```bash
mkdir scripts
move *.bat scripts\
move *.sh scripts\
```

### Step 4: Create Database Folder
```bash
mkdir database
mkdir database\schemas
mkdir database\migrations
```

### Step 5: Update Flutter Commands
After moving, run Flutter commands from the frontend folder:
```bash
cd frontend
flutter pub get
flutter run
```

---

## 🎯 Final Project Structure

```
bytebrain/
├── frontend/                   # Flutter Application
│   ├── lib/
│   ├── assets/
│   ├── android/
│   ├── ios/
│   ├── web/
│   ├── windows/
│   ├── linux/
│   ├── macos/
│   ├── test/
│   ├── pubspec.yaml
│   └── .env
│
├── backend/                    # Node.js Server
│   ├── server.js
│   ├── routes/
│   ├── models/
│   ├── controllers/
│   ├── package.json
│   └── .env
│
├── Byte_Brain/                 # Python AI Chatbot
│   ├── server.py
│   ├── requirements.txt
│   └── .env
│
├── database/                   # Database Documentation
│   ├── README.md
│   ├── schemas/
│   └── migrations/
│
├── docs/                       # Documentation
│   ├── README.md
│   ├── SETUP_GUIDE.md
│   └── *.md
│
├── scripts/                    # Startup Scripts
│   ├── start_groq_chatbot.bat
│   └── *.bat, *.sh
│
├── .git/                       # Git Repository
├── .gitignore
├── docker-compose.yml
└── package.json
```

---

## ⚠️ Important Notes

1. **Backup First**: Make sure all changes are committed to git before moving files
2. **Update Paths**: After moving, update any hardcoded paths in your code
3. **Flutter Commands**: Run all Flutter commands from the `frontend/` directory
4. **Environment Variables**: Update any paths in `.env` files
5. **Git**: Add `frontend/`, `docs/`, `scripts/`, `database/` to git

---

## 🔄 After Reorganization

### Run Frontend:
```bash
cd frontend
flutter pub get
flutter run
```

### Run Backend:
```bash
cd backend
npm install
npm start
```

### Run AI Chatbot:
```bash
cd Byte_Brain
python server.py
```

---

## ✅ Verification Checklist

- [ ] All Flutter files moved to `frontend/`
- [ ] Documentation moved to `docs/`
- [ ] Scripts moved to `scripts/`
- [ ] Database folder created
- [ ] Flutter runs from `frontend/` folder
- [ ] Backend still works
- [ ] AI Chatbot still works
- [ ] All changes committed to git
