@echo off
echo ========================================
echo Starting ByteBrain Flutter Frontend
echo ========================================
echo.

cd frontend

echo Checking Flutter installation...
flutter doctor

echo.
echo Running Flutter app on Windows...
flutter run -d windows

pause
