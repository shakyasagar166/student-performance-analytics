-- ==============================================================================
-- PROJECT: Student Performance Analytics (EdTech Domain)
-- CREATOR / AUTHOR: Uncodemy Student
-- DATABASE ENGINE: MySQL 8.0+
-- SCRIPT 02: Bulk Data Ingestion Script (LOAD DATA INFILE & ETL Pipeline)
-- ==============================================================================

USE student_performance_db;

-- ------------------------------------------------------------------------------
-- PRE-REQUISITE CONFIGURATION
-- Note: In MySQL 8.0, local infile loading requires client and server flags enabled:
-- SET GLOBAL local_infile = 1;
-- ------------------------------------------------------------------------------
SET GLOBAL local_infile = 1;

-- 1. Ingest Courses
LOAD DATA LOCAL INFILE 'C:/Users/Asus/.gemini/antigravity/scratch/student-performance-analytics/data/raw/courses.csv'
INTO TABLE courses
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(course_id, course_name, domain, duration_weeks, fee_inr, total_modules);

-- 2. Ingest Trainers
LOAD DATA LOCAL INFILE 'C:/Users/Asus/.gemini/antigravity/scratch/student-performance-analytics/data/raw/trainers.csv'
INTO TABLE trainers
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(trainer_id, trainer_name, domain, experience_yrs, rating, corporate_tieups);

-- 3. Ingest Batches
LOAD DATA LOCAL INFILE 'C:/Users/Asus/.gemini/antigravity/scratch/student-performance-analytics/data/raw/batches.csv'
INTO TABLE batches
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(batch_id, batch_name, course_id, trainer_id, start_date, end_date, batch_type, timing_slot, status);

-- 4. Ingest Students
LOAD DATA LOCAL INFILE 'C:/Users/Asus/.gemini/antigravity/scratch/student-performance-analytics/data/raw/students.csv'
INTO TABLE students
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(student_id, full_name, email, phone, gender, age, education_background, prior_coding_exp, batch_id, enrollment_date, status, city, fees_paid_pct);

-- 5. Ingest Attendance
LOAD DATA LOCAL INFILE 'C:/Users/Asus/.gemini/antigravity/scratch/student-performance-analytics/data/raw/attendance.csv'
INTO TABLE attendance
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(attendance_id, student_id, batch_id, module_number, sessions_conducted, sessions_attended, attendance_pct, recorded_at);

-- 6. Ingest Assessments
LOAD DATA LOCAL INFILE 'C:/Users/Asus/.gemini/antigravity/scratch/student-performance-analytics/data/raw/assessments.csv'
INTO TABLE assessments
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(assessment_id, student_id, module_number, assessment_type, max_score, score_obtained, score_pct, is_passed, submission_date);

-- 7. Ingest Placements
LOAD DATA LOCAL INFILE 'C:/Users/Asus/.gemini/antigravity/scratch/student-performance-analytics/data/raw/placements.csv'
INTO TABLE placements
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(placement_id, student_id, company_name, company_tier, job_role, ctc_lpa, interview_rounds_cleared, offer_date, status);

-- ------------------------------------------------------------------------------
-- POST-INGESTION INTEGRITY CHECK
-- ------------------------------------------------------------------------------
SELECT 'courses' AS table_name, COUNT(*) AS total_rows FROM courses
UNION ALL
SELECT 'trainers', COUNT(*) FROM trainers
UNION ALL
SELECT 'batches', COUNT(*) FROM batches
UNION ALL
SELECT 'students', COUNT(*) FROM students
UNION ALL
SELECT 'attendance', COUNT(*) FROM attendance
UNION ALL
SELECT 'assessments', COUNT(*) FROM assessments
UNION ALL
SELECT 'placements', COUNT(*) FROM placements;
