# ByteBrain AI Learning Platform

An AI-powered educational platform built with Flutter that provides personalized learning experiences using advanced AI models.

## 🚀 Features

- **AI-Powered Content Generation**: Dynamic course content using Groq AI
- **Personalized Learning**: VARK learning style assessment and adaptation
- **Interactive Modules**: HTML/CSS, Data Preprocessing, State Management, and more
- **Progress Tracking**: Comprehensive learning analytics
- **Multi-Platform Support**: Web, Windows, iOS, and Android

## 📋 Prerequisites

Before running this project on a new device, ensure you have:

1. **Flutter SDK** (3.0.0 or higher)
   - [Install Flutter](https://docs.flutter.dev/get-started/install)
   
2. **Dart SDK** (2.17.0 or higher)
   - Comes with Flutter installation
   
3. **Git**
   - [Install Git](https://git-scm.com/downloads)

4. **IDE/Editor** (recommended)
   - [VS Code](https://code.visualstudio.com/) with Flutter extension
   - [Android Studio](https://developer.android.com/studio) with Flutter plugin

## 🛠️ Setup Instructions for New Device

### Step 1: Clone the Repository
```bash
git clone https://github.com/Sanjith1001/AI-Tutor.git
cd AI-Tutor
```

### Step 2: Set Up Environment Variables
1. **Copy the environment template:**
   ```bash
   cp .env.example .env
   ```

2. **Get your Groq API Key:**
   - Visit [Groq Console](https://console.groq.com/keys)
   - Sign up/Login to your account
   - Create a new API key
   - Copy the API key

3. **Update the .env file:**
   Open `.env` file and replace `your_groq_api_key_here` with your actual API key:
   ```env
   GROQ_API_KEY=gsk_your_actual_api_key_here
   ```

### Step 3: Install Dependencies
```bash
flutter pub get
```

### Step 4: Verify Flutter Setup
```bash
flutter doctor
```
Fix any issues reported by flutter doctor before proceeding.

### Step 5: Run the Application

#### For Web:
```bash
flutter run -d chrome
```

#### For Windows Desktop:
```bash
flutter run -d windows
```

#### For Android (requires Android Studio/device):
```bash
flutter run -d android
```

#### For iOS (requires Xcode on macOS):
```bash
flutter run -d ios
```

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point with env setup
├── models/                   # Data models (Course, User, Quiz, etc.)
├── screens/                  # UI screens and pages
│   ├── ai_module_content_screen.dart
│   ├── course_screen.dart
│   └── ...
├── services/                 # Business logic and API services
│   ├── groq_service.dart     # Groq AI API integration
│   ├── ai_service.dart       # AI content generation
│   └── ...
├── widgets/                  # Reusable UI components
└── utils/                    # Utilities and constants
```

## 🔧 Configuration Files

- **`.env`** - Environment variables (create from .env.example)
- **`.env.example`** - Template for environment variables
- **`pubspec.yaml`** - Flutter dependencies and assets
- **`.gitignore`** - Git ignore rules (includes .env for security)

## 🔒 Security Notes

- **Never commit API keys** to the repository
- The `.env` file is automatically ignored by Git
- Always use the `.env.example` template for new setups
- Keep your API keys secure and never share them publicly

## 🧪 Testing the Setup

After setup, test that the AI features work:

1. **Launch the app**
2. **Navigate to any AI module** (e.g., HTML & CSS, Data Preprocessing)
3. **Try the AI content generation features**
4. **Check for any API key related errors in the console**

If you see errors like "API key not found" or authentication failures, double-check your `.env` file setup.

## 🛠️ Development Commands

```bash
# Clean build files
flutter clean

# Get dependencies
flutter pub get

# Run with specific device
flutter run -d chrome --web-port=8080

# Build for production
flutter build web
flutter build windows
flutter build apk

# Run tests
flutter test

# Check for issues
flutter analyze
```

## 🐛 Common Issues & Solutions

### Issue: "API Key not found" error
**Solution:** Ensure `.env` file exists and contains the correct API key format.

### Issue: Flutter doctor shows issues
**Solution:** Follow flutter doctor recommendations to install missing components.

### Issue: Dependencies not resolving
**Solution:** 
```bash
flutter clean
flutter pub get
```

### Issue: Hot reload not working
**Solution:** Restart the app or use hot restart (Ctrl+Shift+F5).

## 📚 Learning Modules

The platform includes comprehensive learning modules:

- **HTML & CSS Foundations** - Web development basics
- **Data Preprocessing** - Machine learning data preparation
- **State Management** - Flutter state management patterns
- **Data Structures** - Computer science fundamentals
- **Machine Learning** - AI/ML concepts and applications

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes and commit: `git commit -m 'Add feature'`
4. Push to the branch: `git push origin feature-name`
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Support

If you encounter any issues:
1. Check this README for common solutions
2. Ensure your `.env` file is properly configured
3. Verify Flutter doctor shows no critical issues
4. Create an issue on GitHub with detailed error information

## 🔗 Useful Links

- [Flutter Documentation](https://docs.flutter.dev/)
- [Groq API Documentation](https://console.groq.com/docs)
- [Dart Language Guide](https://dart.dev/guides)
- [Material Design Guidelines](https://material.io/design)
