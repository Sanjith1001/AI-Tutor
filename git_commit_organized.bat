@echo off
echo ========================================
echo Git Commit - Project Reorganization
echo ========================================
echo.

echo Step 1: Updating .gitignore...
git add .gitignore

echo Step 2: Adding important project files...
git add frontend/lib/
git add frontend/assets/
git add frontend/pubspec.yaml
git add frontend/.env
git add backend/
git add start_groq_chatbot.bat
git add start_groq_chatbot.sh
git add start_bytebrain_groq.bat
git add PROJECT_STRUCTURE.md
git add REORGANIZATION_GUIDE.md
git add README.md

echo.
echo Step 3: Checking status...
git status

echo.
echo ========================================
echo Ready to commit!
echo ========================================
echo.
echo Files staged for commit. Review above.
echo.
set /p commit_msg="Enter commit message (or press Enter for default): "

if "%commit_msg%"=="" (
    set commit_msg=Reorganize project structure: Move frontend to frontend/ folder and update gitignore
)

echo.
echo Committing with message: %commit_msg%
git commit -m "%commit_msg%"

echo.
echo ========================================
echo Commit complete!
echo ========================================
echo.
echo To push to remote:
echo   git push origin main
echo.
echo Or run: git push
echo.
pause
