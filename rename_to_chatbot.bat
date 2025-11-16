@echo off
echo ========================================
echo Renaming Byte_Brain to chatbot
echo ========================================
echo.

echo Step 1: Renaming folder...
rename Byte_Brain chatbot

if errorlevel 1 (
    echo ERROR: Could not rename folder. Make sure:
    echo - The folder exists
    echo - No programs are using files in the folder
    echo - You have permission to rename it
    pause
    exit /b 1
)

echo.
echo SUCCESS: Folder renamed to 'chatbot'
echo.
echo ========================================
echo IMPORTANT: Update these references manually:
echo ========================================
echo.
echo 1. Update startup scripts:
echo    - start_groq_chatbot.bat (line 6: cd Byte_Brain → cd chatbot)
echo    - start_groq_chatbot.sh (line 7: cd Byte_Brain → cd chatbot)
echo    - start_bytebrain_groq.bat (line 6: cd Byte_Brain → cd chatbot)
echo.
echo 2. Update documentation:
echo    - GROQ_CHATBOT_INTEGRATION.md
echo    - PROJECT_STRUCTURE.md
echo    - REORGANIZATION_GUIDE.md
echo.
echo 3. Update Flutter code:
echo    - frontend/lib/screens/ai_chatbot_screen.dart (line 64)
echo.
echo 4. Run from new location:
echo    cd chatbot
echo    python server.py
echo.
echo ========================================
pause
