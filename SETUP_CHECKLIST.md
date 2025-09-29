# 📋 New Device Setup Checklist

When setting up ByteBrain on a new device, follow this checklist:

## ✅ Prerequisites
- [ ] Flutter SDK installed (check: `flutter --version`)
- [ ] Git installed (check: `git --version`) 
- [ ] Code editor with Flutter support (VS Code/Android Studio)

## ✅ Quick Setup (Choose One)

### Option A: Automated Setup
**Linux/macOS:**
```bash
git clone https://github.com/Sanjith1001/AI-Tutor.git
cd AI-Tutor
chmod +x setup.sh && ./setup.sh
```

**Windows:**
```cmd
git clone https://github.com/Sanjith1001/AI-Tutor.git
cd AI-Tutor
setup.bat
```

### Option B: Manual Setup
- [ ] `git clone https://github.com/Sanjith1001/AI-Tutor.git`
- [ ] `cd AI-Tutor`
- [ ] `cp .env.example .env` (or copy manually)
- [ ] Edit `.env` and add your Groq API key
- [ ] `flutter pub get`

## ✅ API Key Setup
- [ ] Visit https://console.groq.com/keys
- [ ] Create/get your API key (starts with `gsk_`)
- [ ] Open `.env` file 
- [ ] Replace `your_groq_api_key_here` with your actual key
- [ ] Save the file

## ✅ Verification
- [ ] Run `flutter doctor` (fix any issues)
- [ ] Run `flutter run -d chrome` (or preferred platform)
- [ ] Test AI features in the app
- [ ] No API authentication errors in console

## 🎯 Success!
If all checkboxes are complete, your ByteBrain setup is ready to use!

## 🆘 Need Help?
- Check `README.md` for detailed instructions
- Check `SETUP_GUIDE.md` for troubleshooting
- Run `flutter clean && flutter pub get` if issues persist