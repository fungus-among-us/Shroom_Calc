@echo off
setlocal enabledelayedexpansion

echo.
echo 🍄 Compound Calculator Setup Script
echo ==================================
echo.

REM Check if Flutter is installed
where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ Flutter is not installed or not in PATH
    echo Please install Flutter from https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

for /f "tokens=*" %%a in ('flutter --version ^| findstr /C:"Flutter"') do (
    echo ✓ Flutter found: %%a
)
echo.

REM Check Flutter doctor
echo Running Flutter doctor...
flutter doctor
echo.

REM Get dependencies
echo Installing dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo ❌ Failed to install dependencies
    pause
    exit /b 1
)
echo.

REM Run code generation
echo Running code generation...
flutter pub run build_runner build --delete-conflicting-outputs
if %errorlevel% neq 0 (
    echo ❌ Code generation failed
    pause
    exit /b 1
)
echo.

REM Run tests
echo Running tests...
flutter test
if %errorlevel% neq 0 (
    echo ⚠️ Some tests failed
)
echo.

echo ✅ Setup complete!
echo.
echo To run the app:
echo   flutter run
echo.
echo To build for release:
echo   flutter build apk       # Android
echo   flutter build windows   # Windows
echo.
pause
