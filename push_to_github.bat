@echo off
title Push Student Performance Analytics to GitHub - Uncodemy Student
color 0B
echo ======================================================================
echo    🎓 STUDENT PERFORMANCE ANALYTICS - GITHUB PUSH WIZARD
echo    👨‍💻 Author: Uncodemy Student (Business Analyst Portfolio)
echo ======================================================================
echo.

:: Check if git is installed
where git >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Git is not installed or not in your PATH.
    echo Please install Git from https://git-scm.com/ and try again.
    pause
    exit /b
)

cd /d "%~dp0"

echo [1/5] Initializing Git repository...
if not exist ".git" (
    git init
) else (
    echo Git repository already initialized.
)

echo.
echo [2/5] Staging all project files...
git add .

echo.
echo [3/5] Creating initial commit...
git commit -m "feat: complete Student Performance Analytics platform by Uncodemy Student (MySQL, Excel, Power BI, Web App)"

echo.
echo [4/5] Setting main branch...
git branch -M main

echo.
echo ======================================================================
echo Step 1: Go to https://github.com/new
echo Step 2: Create a new repository named: student-performance-analytics
echo Step 3: Copy the HTTPS repository URL
echo         (Example: https://github.com/your-username/student-performance-analytics.git)
echo ======================================================================
echo.

set /p REPO_URL="Enter your GitHub Repository URL: "

if "%REPO_URL%"=="" (
    echo [ERROR] Repository URL cannot be empty.
    pause
    exit /b
)

echo.
echo [5/5] Adding remote and pushing to GitHub...
git remote remove origin 2>nul
git remote add origin %REPO_URL%

echo Pushing code to %REPO_URL% ...
git push -u origin main

if %errorlevel% equ 0 (
    echo.
    echo ======================================================================
    echo  SUCCESS! Your Uncodemy Student Portfolio is now live on GitHub!
    echo ======================================================================
) else (
    echo.
    echo [NOTE] If push failed due to authentication, please log in to GitHub in your browser/terminal.
)

echo.
pause
