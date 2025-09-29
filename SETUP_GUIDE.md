# Quick Setup Guide for New Devices

## 🎯 One-Command Setup

### For Linux/macOS:
```bash
git clone https://github.com/Sanjith1001/AI-Tutor.git
cd AI-Tutor
chmod +x setup.sh
./setup.sh
```

### For Windows:
```cmd
git clone https://github.com/Sanjith1001/AI-Tutor.git
cd AI-Tutor
setup.bat
```

## 📋 Manual Setup Steps

If the automated scripts don't work, follow these manual steps:

### 1. Prerequisites Check
- ✅ Flutter SDK installed (`flutter --version`)
- ✅ Git installed (`git --version`)
- ✅ IDE with Flutter support (VS Code/Android Studio)

### 2. Clone & Navigate
```bash
git clone https://github.com/Sanjith1001/AI-Tutor.git
cd AI-Tutor
```

### 3. Environment Setup
```bash
# Copy the environment template
cp .env.example .env

# Edit .env file and add your API key:
# GROQ_API_KEY=your_actual_groq_api_key_here
```

### 4. Dependencies & Run
```bash
flutter pub get
flutter run -d chrome  # or -d windows, -d android
```

## 🔑 Getting Your API Keys

### Groq API Key (AI Features)
1. **Visit**: https://console.groq.com/keys
2. **Sign up/Login** to your account
3. **Create** a new API key
4. **Copy** the key (starts with `gsk_`)

### YouTube API Key (Video Features)
1. **Visit**: https://console.developers.google.com/
2. **Create** a new project or select existing
3. **Enable** YouTube Data API v3
4. **Create credentials** (API Key)
5. **Copy** the API key

### Update .env file
```env
GROQ_API_KEY=gsk_your_groq_key_here
YOUTUBE_API_KEY=your_youtube_key_here
```

## 🎮 Running the App

| Platform | Command |
|----------|---------|
| **Web** | `flutter run -d chrome` |
| **Windows** | `flutter run -d windows` |
| **Android** | `flutter run -d android` |
| **iOS** | `flutter run -d ios` |

## ⚠️ Common Issues

### "API Key not found"
- Check if `.env` file exists
- Verify API key format in `.env`
- Restart the app after changing `.env`

### "Flutter not found"
- Install Flutter SDK
- Add Flutter to system PATH
- Run `flutter doctor` to verify

### Dependencies issues
```bash
flutter clean
flutter pub get
```

## ✅ Success Indicators

When setup is successful, you should see:
- ✅ App launches without errors
- ✅ AI modules load content
- ✅ No authentication errors in console
- ✅ Interactive features work properly

## 🆘 Need Help?

1. **Check README.md** for detailed instructions
2. **Run `flutter doctor`** to diagnose issues
3. **Verify `.env` file** contains valid API key
4. **Check console logs** for specific error messages
5. **Create GitHub issue** with error details if needed

---
**Happy Learning! 🚀**