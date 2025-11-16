@echo off
echo ByteBrain Python Chatbot Launcher
echo ===================================

:menu
echo.
echo Choose an option:
echo 1. Run Simple Chatbot (Command Line)
echo 2. Run Simple Chatbot (HTTP Server - Port 5002)
echo 3. Run Advanced Chatbot (HTTP Server - Port 5001)
echo 4. Test Chatbots
echo 5. Install Dependencies
echo 6. Exit

set /p choice="Enter your choice (1-6): "

if "%choice%"=="1" goto simple_cli
if "%choice%"=="2" goto simple_server
if "%choice%"=="3" goto advanced_server
if "%choice%"=="4" goto test
if "%choice%"=="5" goto install
if "%choice%"=="6" goto exit

echo Invalid choice. Please try again.
goto menu

:simple_cli
echo.
echo Starting Simple Chatbot (Command Line Interface)...
python simple_chatbot.py
goto menu

:simple_server
echo.
echo Starting Simple Chatbot HTTP Server on port 5002...
echo Open http://localhost:5002/health to test
python simple_chatbot.py server 5002
goto menu

:advanced_server
echo.
echo Starting Advanced Chatbot HTTP Server on port 5001...
echo Make sure you have set up your .env file with OpenAI API key
echo Open http://localhost:5001/health to test
python chatbot_server.py
goto menu

:test
echo.
echo Running chatbot tests...
python test_chatbot.py
echo.
echo To test HTTP servers, make sure they are running first!
pause
goto menu

:install
echo.
echo Installing Python dependencies...
pip install -r requirements.txt
echo.
echo Dependencies installed!
pause
goto menu

:exit
echo.
echo Goodbye!
exit /b 0