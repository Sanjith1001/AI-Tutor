#!/bin/bash
# setup.sh - Quick setup script for ByteBrain AI Learning Platform

echo "🚀 Setting up ByteBrain AI Learning Platform..."
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first:"
    echo "   https://docs.flutter.dev/get-started/install"
    exit 1
fi

# Check Flutter doctor
echo "🔍 Checking Flutter setup..."
flutter doctor

# Copy environment template if .env doesn't exist
if [ ! -f ".env" ]; then
    if [ -f ".env.example" ]; then
        cp .env.example .env
        echo "✅ Created .env file from template"
        echo ""
        echo "⚠️  IMPORTANT: Edit .env file and add your Groq API key!"
        echo "   1. Get API key from: https://console.groq.com/keys"
        echo "   2. Replace 'your_groq_api_key_here' with your actual key"
        echo ""
    else
        echo "❌ .env.example file not found"
        exit 1
    fi
else
    echo "✅ .env file already exists"
fi

# Install dependencies
echo "📦 Installing Flutter dependencies..."
flutter pub get

if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 Setup completed successfully!"
    echo ""
    echo "📝 Next steps:"
    echo "   1. Edit .env file with your Groq API key (if not done already)"
    echo "   2. Run the app:"
    echo "      - Web: flutter run -d chrome"
    echo "      - Windows: flutter run -d windows"
    echo "      - Android: flutter run -d android"
    echo ""
    echo "🔗 Need help? Check the README.md file for detailed instructions."
else
    echo "❌ Failed to install dependencies"
    echo "Try running 'flutter clean' and then 'flutter pub get'"
    exit 1
fi