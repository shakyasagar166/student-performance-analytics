@echo off
title Student Performance Analytics - Uncodemy Student
echo ======================================================================
echo    🎓 STUDENT PERFORMANCE ANALYTICS - FULL STACK APPLICATION
echo    👨‍💻 Author: Uncodemy Student (Business Analyst Portfolio)
echo ======================================================================
echo 1. Initializing EdTech Database (data/student_performance.db)...
echo 2. Generating Formatted Excel Model (excel/Student_Performance_Model.xlsx)...
echo 3. Starting Python REST API Backend on Port 8000...
echo 4. Opening Web Dashboard at http://localhost:8000 ...
echo ======================================================================

start http://localhost:8000
python server.py

pause
