    @echo off
    echo ========================================
    echo ByteBrain Project Reorganization Script
    echo ========================================
    echo.
    echo WARNING: This will reorganize your project structure.
    echo Make sure you have committed all changes to git first!
    echo.
    pause

    echo Creating new folder structure...

    REM Create main folders
    mkdir frontend 2>nul
    mkdir database 2>nul
    mkdir docs 2>nul
    mkdir scripts 2>nul

    echo.
    echo Moving Frontend files...
    REM Move Flutter frontend files
    move lib frontend\ 2>nul
    move assets frontend\ 2>nul
    move android frontend\ 2>nul
    move ios frontend\ 2>nul
    move web frontend\ 2>nul
    move windows frontend\ 2>nul
    move linux frontend\ 2>nul
    move macos frontend\ 2>nul
    move test frontend\ 2>nul
    move pubspec.yaml frontend\ 2>nul
    move pubspec.lock frontend\ 2>nul
    move analysis_options.yaml frontend\ 2>nul
    move .metadata frontend\ 2>nul

    echo.
    echo Moving Documentation files...
    move *.md docs\ 2>nul
    move SETUP_CHECKLIST.md docs\ 2>nul
    move SETUP_GUIDE.md docs\ 2>nul

    echo.
    echo Moving Startup scripts...
    move *.bat scripts\ 2>nul
    move *.sh scripts\ 2>nul
    move setup.bat scripts\ 2>nul
    move setup.sh scripts\ 2>nul

    echo.
    echo Creating database documentation...
    echo # Database Configuration > database\README.md
    echo. >> database\README.md
    echo ## MongoDB Connection >> database\README.md
    echo Connection string is configured in backend/.env >> database\README.md
    echo. >> database\README.md
    echo ## Collections: >> database\README.md
    echo - users >> database\README.md
    echo - courses >> database\README.md
    echo - progress >> database\README.md
    echo - assessments >> database\README.md
    echo - activities >> database\README.md

    echo.
    echo ========================================
    echo Reorganization Complete!
    echo ========================================
    echo.
    echo New Structure:
    echo   frontend/     - Flutter application
    echo   backend/      - Node.js server
    echo   Byte_Brain/   - Python AI chatbot
    echo   database/     - Database documentation
    echo   docs/         - Project documentation
    echo   scripts/      - Startup scripts
    echo.
    echo IMPORTANT: You need to update import paths!
    echo Run: cd frontend
    echo Then: flutter pub get
    echo.
    pause
