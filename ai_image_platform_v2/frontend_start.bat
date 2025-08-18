@echo off
setlocal enabledelayedexpansion

REM AI Image Platform - Frontend Startup Script (Windows)
REM This script starts the frontend development server

echo ========================================
echo AI Image Platform - Frontend Startup
echo ========================================
echo.

REM Check for help flag
if "%1"=="--help" (
    echo Usage: frontend_start.bat [--help] [--production]
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

REM Check if Node.js is installed
node --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Node.js is not installed or not in PATH
    echo Please install Node.js from: https://nodejs.org/
    pause
    exit /b 1
)
echo [OK] Node.js is available: 
node --version

REM Check if npm is installed
npm --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] npm is not installed or not in PATH
    echo npm should come with Node.js installation
    pause
    exit /b 1
)
echo [OK] npm is available: 
npm --version
echo.

REM Check if port 3000 is available
echo [INFO] Checking if port 3000 is available...
netstat -an | findstr ":3000" >nul 2>&1
if not errorlevel 1 (
    echo [WARNING] Port 3000 is already in use
    echo The development server may use a different port
    echo.
)

REM Change to frontend directory
cd /d "%~dp0frontend"
if errorlevel 1 (
    echo [ERROR] Failed to change to frontend directory
    pause
    exit /b 1
)
echo [INFO] Changed to frontend directory: %cd%
echo.

REM Install frontend dependencies
echo [INFO] Installing frontend dependencies...
if exist package.json (
    echo [INFO] Found package.json, installing dependencies...
    npm install
    if errorlevel 1 (
        echo [ERROR] Failed to install frontend dependencies
        echo.
        echo Troubleshooting suggestions:
        echo 1. Check your internet connection
        echo 2. Try: npm cache clean --force
        echo 3. Try: rm -rf node_modules package-lock.json ^&^& npm install
        echo 4. Check if you're behind a corporate firewall
        pause
        exit /b 1
    )
    echo [OK] Frontend dependencies installed successfully
) else (
    echo [ERROR] package.json not found in frontend directory
    echo Please ensure you're in the correct project directory
    pause
    exit /b 1
)
echo.

REM Start frontend development server
echo [INFO] Starting frontend development server...
echo [INFO] Frontend will be available at: http://localhost:3000
echo [INFO] The browser should open automatically
echo.
echo [INFO] Press Ctrl+C to stop the frontend server
echo ========================================
echo.

REM Start the frontend service
if "%PRODUCTION_MODE%"=="true" (
    echo [INFO] Starting in production mode...
    if exist "dist" (
        echo [INFO] Serving production build from dist directory...
        npx serve -s dist -l 3000
    ) else (
        echo [INFO] Production build not found, building first...
        npm run build
        if errorlevel 1 (
            echo [ERROR] Failed to build for production
            pause
            exit /b 1
        )
        npx serve -s dist -l 3000
    )
) else (
    echo [INFO] Starting in development mode...
    REM Check if webpack-dev-server script exists
    npm run dev >nul 2>&1
    if errorlevel 1 (
        REM Try alternative start commands
        npm start >nul 2>&1
        if errorlevel 1 (
            REM Try webpack-dev-server directly
            npx webpack serve --mode development --open
            if errorlevel 1 (
                echo [ERROR] Failed to start development server
                echo Please check your package.json scripts
                pause
                exit /b 1
            )
        )
    )
)

REM Handle service shutdown
echo.
echo [INFO] Frontend service stopped
echo [INFO] Cleaning up...

REM Cleanup function
:cleanup
echo [INFO] Performing cleanup...
echo [INFO] Frontend startup script finished
pause
goto :eof

REM Error handler
:error
echo [ERROR] An error occurred during frontend startup
echo [INFO] Please check the error messages above
pause
exit /b 1