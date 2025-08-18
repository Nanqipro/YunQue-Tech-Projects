@echo off
setlocal enabledelayedexpansion

REM AI Image Platform - Backend Startup Script (Windows)
REM This script starts the backend API service with conda environment

echo ========================================
echo AI Image Platform - Backend Startup
echo ========================================
echo.

REM Check for help flag
if "%1"=="--help" (
    echo Usage: backend_start.bat [--help] [--production]
    echo.
    echo Options:
    echo   --help        Show this help message
    echo   --production  Run in production mode
    echo.
    goto :eof
)

REM Set production mode flag
set PRODUCTION_MODE=false
if "%1"=="--production" set PRODUCTION_MODE=true

REM Check system dependencies
echo [INFO] Checking system dependencies...

REM Check if conda is installed
conda --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] conda is not installed or not in PATH
    echo Please install Anaconda or Miniconda first
    echo Download from: https://www.anaconda.com/products/distribution
    pause
    exit /b 1
)
echo [OK] conda is available

REM Check if python is available
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] python is not installed or not in PATH
    pause
    exit /b 1
)
echo [OK] python is available

REM Check if pip is available
pip --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] pip is not installed or not in PATH
    pause
    exit /b 1
)
echo [OK] pip is available

echo.

REM Virtual Environment Setup
echo [INFO] Setting up conda virtual environment...

REM Check if ai-image conda environment exists
conda info --envs | findstr "ai-image" >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Conda environment 'ai-image' does not exist
    echo Please create it first with:
    echo   conda create -n ai-image python=3.9
    echo   conda activate ai-image
    pause
    exit /b 1
)
echo [OK] ai-image conda environment exists

REM Activate conda environment
echo [INFO] Activating ai-image conda environment...
call conda activate ai-image
if errorlevel 1 (
    echo [ERROR] Failed to activate ai-image conda environment
    pause
    exit /b 1
)
echo [OK] ai-image conda environment activated
echo.

REM Change to backend directory
cd /d "%~dp0backend"
if errorlevel 1 (
    echo [ERROR] Failed to change to backend directory
    pause
    exit /b 1
)
echo [INFO] Changed to backend directory: %cd%
echo.

REM Install backend dependencies
echo [INFO] Installing backend dependencies...
if exist requirements.txt (
    pip install -r requirements.txt
    if errorlevel 1 (
        echo [ERROR] Failed to install backend dependencies
        echo.
        echo Troubleshooting suggestions:
        echo 1. Check your internet connection
        echo 2. Try: pip install --upgrade pip
        echo 3. Try: pip install -r requirements.txt --no-cache-dir
        echo 4. Check if you're behind a corporate firewall
        pause
        exit /b 1
    )
    echo [OK] Backend dependencies installed successfully
) else (
    echo [WARNING] requirements.txt not found, skipping dependency installation
)
echo.

REM Check if port 5002 is available
echo [INFO] Checking if port 5002 is available...
netstat -an | findstr ":5002" >nul 2>&1
if not errorlevel 1 (
    echo [WARNING] Port 5002 is already in use
    echo Please stop the existing service or use a different port
    pause
)

REM Database initialization
echo [INFO] Initializing database...
if not exist "instance\app.db" (
    echo [INFO] Database not found, creating new database...
    python run.py --init-db
    if errorlevel 1 (
        echo [ERROR] Failed to initialize database
        pause
        exit /b 1
    )
    echo [OK] Database initialized successfully
) else (
    echo [OK] Database already exists
)
echo.

REM Start backend service
echo [INFO] Starting backend API service...
echo [INFO] Backend will be available at: http://localhost:5002
echo [INFO] API documentation at: http://localhost:5002/docs
echo.
echo [INFO] Press Ctrl+C to stop the backend service
echo ========================================
echo.

REM Start the backend service
if "%PRODUCTION_MODE%"=="true" (
    echo [INFO] Starting in production mode...
    python run.py --production
) else (
    echo [INFO] Starting in development mode...
    python run.py
)

REM Handle service shutdown
echo.
echo [INFO] Backend service stopped
echo [INFO] Cleaning up...

REM Cleanup function
:cleanup
echo [INFO] Performing cleanup...
echo [INFO] Backend startup script finished
pause
goto :eof

REM Error handler
:error
echo [ERROR] An error occurred during backend startup
echo [INFO] Please check the error messages above
pause
exit /b 1