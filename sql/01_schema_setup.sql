-- ==============================================================================
-- PROJECT: Student Performance Analytics (EdTech / Career Institute Domain)
-- CREATOR / AUTHOR: Uncodemy Student
-- DATABASE ENGINE: MySQL 8.0+ / MariaDB 10.5+
-- SCRIPT 01: Schema Definition & Table Creation (DDL)
-- ==============================================================================

CREATE DATABASE IF NOT EXISTS student_performance_db;
USE student_performance_db;

-- ------------------------------------------------------------------------------
-- 1. COURSES TABLE
-- Dimension table holding course curriculum specifications and fees
-- ------------------------------------------------------------------------------
DROP TABLE IF EXISTS placements;
DROP TABLE IF EXISTS assessments;
DROP TABLE IF EXISTS attendance;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS batches;
DROP TABLE IF EXISTS trainers;
DROP TABLE IF EXISTS courses;

CREATE TABLE courses (
    course_id VARCHAR(10) PRIMARY KEY,
    course_name VARCHAR(100) NOT NULL,
    domain VARCHAR(50) NOT NULL,
    duration_weeks INT NOT NULL CHECK (duration_weeks > 0),
    fee_inr DECIMAL(10, 2) NOT NULL CHECK (fee_inr >= 0),
    total_modules INT NOT NULL DEFAULT 12,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------------------------
-- 2. TRAINERS TABLE
-- Dimension table for faculty, mentors, and corporate trainer profiles
-- ------------------------------------------------------------------------------
CREATE TABLE trainers (
    trainer_id VARCHAR(10) PRIMARY KEY,
    trainer_name VARCHAR(100) NOT NULL,
    domain VARCHAR(50) NOT NULL,
    experience_yrs INT NOT NULL CHECK (experience_yrs >= 0),
    rating DECIMAL(3, 2) NOT NULL CHECK (rating BETWEEN 1.00 AND 5.00),
    corporate_tieups VARCHAR(150),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------------------------
-- 3. BATCHES TABLE
-- Operational cohort table linking Courses and Trainers
-- ------------------------------------------------------------------------------
CREATE TABLE batches (
    batch_id VARCHAR(10) PRIMARY KEY,
    batch_name VARCHAR(100) NOT NULL,
    course_id VARCHAR(10) NOT NULL,
    trainer_id VARCHAR(10) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    batch_type ENUM('Weekday', 'Weekend') NOT NULL DEFAULT 'Weekday',
    timing_slot VARCHAR(50) NOT NULL,
    status ENUM('Completed', 'In-Progress', 'Upcoming') NOT NULL DEFAULT 'In-Progress',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_batch_course FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE,
    CONSTRAINT fk_batch_trainer FOREIGN KEY (trainer_id) REFERENCES trainers(trainer_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------------------------
-- 4. STUDENTS TABLE
-- Dimension & Master Entity for enrolled learners
-- ------------------------------------------------------------------------------
CREATE TABLE students (
    student_id VARCHAR(10) PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    phone VARCHAR(20),
    gender ENUM('Male', 'Female', 'Other') NOT NULL,
    age INT CHECK (age >= 17 AND age <= 50),
    education_background VARCHAR(60) NOT NULL,
    prior_coding_exp ENUM('None', 'Basic', 'Intermediate', 'Advanced') NOT NULL DEFAULT 'None',
    batch_id VARCHAR(10) NOT NULL,
    enrollment_date DATE NOT NULL,
    status ENUM('Enrolled', 'Active', 'Completed', 'Placed', 'At-Risk', 'Dropped') NOT NULL DEFAULT 'Active',
    city VARCHAR(60) NOT NULL,
    fees_paid_pct DECIMAL(5, 2) NOT NULL DEFAULT 100.00 CHECK (fees_paid_pct BETWEEN 0 AND 100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_student_batch FOREIGN KEY (batch_id) REFERENCES batches(batch_id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------------------------
-- 5. ATTENDANCE TABLE
-- Fact table tracking module-wise attendance compliance
-- ------------------------------------------------------------------------------
CREATE TABLE attendance (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id VARCHAR(10) NOT NULL,
    batch_id VARCHAR(10) NOT NULL,
    module_number INT NOT NULL CHECK (module_number BETWEEN 1 AND 12),
    sessions_conducted INT NOT NULL DEFAULT 8,
    sessions_attended INT NOT NULL,
    attendance_pct DECIMAL(5, 2) NOT NULL,
    recorded_at DATE NOT NULL,
    CONSTRAINT fk_att_student FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    CONSTRAINT fk_att_batch FOREIGN KEY (batch_id) REFERENCES batches(batch_id) ON DELETE CASCADE,
    CONSTRAINT chk_sessions CHECK (sessions_attended <= sessions_conducted)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------------------------
-- 6. ASSESSMENTS TABLE
-- Fact table tracking Quizzes, Capstone Projects, and Mock Interview Scores
-- ------------------------------------------------------------------------------
CREATE TABLE assessments (
    assessment_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id VARCHAR(10) NOT NULL,
    module_number INT NOT NULL CHECK (module_number BETWEEN 1 AND 12),
    assessment_type ENUM('Quiz', 'Project', 'Mock Interview') NOT NULL,
    max_score INT NOT NULL DEFAULT 100,
    score_obtained DECIMAL(5, 2) NOT NULL,
    score_pct DECIMAL(5, 2) NOT NULL,
    is_passed BOOLEAN NOT NULL DEFAULT TRUE,
    submission_date DATE NOT NULL,
    CONSTRAINT fk_ass_student FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------------------------
-- 7. PLACEMENTS TABLE
-- Fact / Outcome table recording employment packages and campus recruitment
-- ------------------------------------------------------------------------------
CREATE TABLE placements (
    placement_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id VARCHAR(10) NOT NULL UNIQUE,
    company_name VARCHAR(100) NOT NULL,
    company_tier ENUM('Tier-1 MNC', 'Tier-2 Tech', 'High-Growth Startup', 'Boutique Consultancy') NOT NULL,
    job_role VARCHAR(100) NOT NULL,
    ctc_lpa DECIMAL(5, 2) NOT NULL CHECK (ctc_lpa > 0),
    interview_rounds_cleared INT NOT NULL DEFAULT 3,
    offer_date DATE NOT NULL,
    status ENUM('Offer Accepted', 'Joined', 'Offer Declined') NOT NULL DEFAULT 'Joined',
    CONSTRAINT fk_plc_student FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------------------------
-- PERFORMANCE INDEXES (Optimized for Business Analytics & BI Reporting)
-- ------------------------------------------------------------------------------
CREATE INDEX idx_students_batch ON students(batch_id);
CREATE INDEX idx_students_status ON students(status);
CREATE INDEX idx_batches_course ON batches(course_id);
CREATE INDEX idx_batches_trainer ON batches(trainer_id);
CREATE INDEX idx_attendance_student_module ON attendance(student_id, module_number);
CREATE INDEX idx_assessments_student_type ON assessments(student_id, assessment_type);
CREATE INDEX idx_placements_company_ctc ON placements(company_name, ctc_lpa);
