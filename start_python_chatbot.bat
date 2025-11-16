@echo off
echo Starting ByteBrain Python Chatbot...
echo =====================================

cd backend\python_chatbot

echo Checking if Python is installed...
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed or not in PATH
    echo Please install Python from https://python.org
    pause
    exit /b 1
)

echo Python found! Starting simple chatbot server...
echo.
echo The chatbot will be available at: http://localhost:5002
echo Health check: http://localhost:5002/health
echo.
echo Press Ctrl+C to stop the server
echo =====================================

python simple_chatbot.py server 5002