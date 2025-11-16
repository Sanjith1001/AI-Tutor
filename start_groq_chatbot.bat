@echo off
echo Starting ByteBrain Groq Chatbot Server...
echo ==========================================

cd chatbot

echo Checking if Python is installed...
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed or not in PATH
    echo Please install Python from https://python.org
    pause
    exit /b 1
)

echo Python found! Checking dependencies...

echo Installing/updating dependencies...
pip install flask flask-cors groq python-dotenv

echo.
echo Checking for GROQ_API_KEY...
if not exist .env (
    echo WARNING: .env file not found!
    echo Please create .env file with your GROQ_API_KEY
    echo Example: GROQ_API_KEY=your_api_key_here
    echo.
    echo You can get a free API key from: https://console.groq.com/
    pause
)

echo.
echo Starting Groq chatbot server...
echo.
echo The chatbot will be available at: http://localhost:5000
echo Health check: http://localhost:5000/health
echo Chat endpoint: http://localhost:5000/chat
echo.
echo Press Ctrl+C to stop the server
echo ==========================================

python server.py