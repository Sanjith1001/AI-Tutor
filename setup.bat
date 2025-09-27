@echo off
REM setup.bat - Quick setup script for ByteBrain AI Learning Platform (Windows)

echo 🚀 Setting up ByteBrain AI Learning Platform...
echo.

REM Check if Flutter is installed
flutter --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Flutter is not installed. Please install Flutter first:
    echo    https://docs.flutter.dev/get-started/install
    pause
    exit /b 1
)

REM Check Flutter doctor
echo 🔍 Checking Flutter setup...
flutter doctor

REM Copy environment template if .env doesn't exist
if not exist ".env" (
    if exist ".env.example" (
        copy ".env.example" ".env" >nul
        echo ✅ Created .env file from template
        echo.
        echo ⚠️  IMPORTANT: Edit .env file and add your Groq API key!
        echo    1. Get API key from: https://console.groq.com/keys
        echo    2. Replace 'your_groq_api_key_here' with your actual key
        echo.
    ) else (
        echo ❌ .env.example file not found
        pause
        exit /b 1
    )
) else (
    echo ✅ .env file already exists
)

REM Install dependencies
echo 📦 Installing Flutter dependencies...
flutter pub get

if %errorlevel% equ 0 (
    echo.
    echo 🎉 Setup completed successfully!
    echo.
    echo 📝 Next steps:
    echo    1. Edit .env file with your Groq API key ^(if not done already^)
    echo    2. Run the app:
    echo       - Web: flutter run -d chrome
    echo       - Windows: flutter run -d windows
    echo       - Android: flutter run -d android
    echo.
    echo 🔗 Need help? Check the README.md file for detailed instructions.
) else (
    echo ❌ Failed to install dependencies
    echo Try running 'flutter clean' and then 'flutter pub get'
    pause
    exit /b 1
)

pause