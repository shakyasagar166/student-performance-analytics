-- ==============================================================================
-- PROJECT: Student Performance Analytics (EdTech Domain)
-- CREATOR / AUTHOR: Uncodemy Student
-- DATABASE ENGINE: MySQL 8.0+
-- SCRIPT 04: BI Analytical Views & Automated Stored Procedures
-- ==============================================================================

USE student_performance_db;

-- ==============================================================================
-- VIEW 1: vw_student_360_profile
-- 360-degree aggregated profile of every student combining demographic, academic,
-- attendance, and recruitment outcome data.
-- ==============================================================================
DROP VIEW IF EXISTS vw_student_360_profile;
CREATE VIEW vw_student_360_profile AS
SELECT 
    s.student_id,
    s.full_name,
    s.email,
    s.gender,
    s.age,
    s.education_background,
    s.prior_coding_exp,
    s.city,
    s.status AS student_status,
    b.batch_id,
    b.batch_name,
    c.course_id,
    c.course_name,
    c.domain AS course_domain,
    t.trainer_name,
    ROUND(COALESCE(AVG(att.attendance_pct), 0), 2) AS overall_attendance_pct,
    ROUND(COALESCE(AVG(ass.score_pct), 0), 2) AS overall_assessment_score_pct,
    COUNT(DISTINCT ass.assessment_id) AS total_assessments_taken,
    p.company_name AS placed_company,
    p.company_tier AS placed_company_tier,
    p.job_role AS placed_role,
    p.ctc_lpa AS placed_ctc_lpa,
    p.offer_date AS placement_offer_date,
    CASE 
        WHEN p.placement_id IS NOT NULL THEN 'Placed'
        WHEN s.status = 'Completed' THEN 'Unplaced Alum'
        WHEN s.status = 'At-Risk' THEN 'Needs Intervention'
        WHEN s.status = 'Dropped' THEN 'Dropped Out'
        ELSE 'Active Training'
    END AS career_readiness_status
FROM students s
JOIN batches b ON s.batch_id = b.batch_id
JOIN courses c ON b.course_id = c.course_id
JOIN trainers t ON b.trainer_id = t.trainer_id
LEFT JOIN attendance att ON s.student_id = att.student_id
LEFT JOIN assessments ass ON s.student_id = ass.student_id
LEFT JOIN placements p ON s.student_id = p.student_id
GROUP BY 
    s.student_id, s.full_name, s.email, s.gender, s.age, s.education_background,
    s.prior_coding_exp, s.city, s.status, b.batch_id, b.batch_name, c.course_id,
    c.course_name, c.domain, t.trainer_name, p.company_name, p.company_tier,
    p.job_role, p.ctc_lpa, p.offer_date, p.placement_id;


-- ==============================================================================
-- VIEW 2: vw_course_performance_summary
-- Executive scorecard per course track
-- ==============================================================================
DROP VIEW IF EXISTS vw_course_performance_summary;
CREATE VIEW vw_course_performance_summary AS
SELECT 
    c.course_id,
    c.course_name,
    c.domain,
    c.fee_inr,
    COUNT(DISTINCT s.student_id) AS total_enrolled,
    SUM(CASE WHEN s.status = 'Placed' THEN 1 ELSE 0 END) AS total_placed,
    ROUND(SUM(CASE WHEN s.status = 'Placed' THEN 1 ELSE 0 END) * 100.0 / COUNT(DISTINCT s.student_id), 2) AS placement_rate_pct,
    ROUND(AVG(p.ctc_lpa), 2) AS avg_ctc_lpa,
    MAX(p.ctc_lpa) AS max_ctc_lpa,
    SUM(c.fee_inr * (s.fees_paid_pct / 100.0)) AS total_tuition_revenue_inr
FROM courses c
JOIN batches b ON c.course_id = b.course_id
JOIN students s ON b.batch_id = s.batch_id
LEFT JOIN placements p ON s.student_id = p.student_id
GROUP BY c.course_id, c.course_name, c.domain, c.fee_inr;


-- ==============================================================================
-- VIEW 3: vw_at_risk_students
-- Live diagnostic operational feed for mentors and academic counselors
-- ==============================================================================
DROP VIEW IF EXISTS vw_at_risk_students;
CREATE VIEW vw_at_risk_students AS
SELECT 
    s.student_id,
    s.full_name,
    s.email,
    s.phone,
    b.batch_name,
    c.course_name,
    t.trainer_name,
    ROUND(AVG(att.attendance_pct), 1) AS attendance_pct,
    ROUND(AVG(ass.score_pct), 1) AS score_pct,
    CASE 
        WHEN AVG(att.attendance_pct) < 60 AND AVG(ass.score_pct) < 50 THEN 'High Urgency (Call Parent/Student)'
        WHEN AVG(att.attendance_pct) < 70 THEN 'Attendance Warning (Session Remedial)'
        WHEN AVG(ass.score_pct) < 60 THEN 'Academic Warning (1-on-1 Doubt Clearing)'
        ELSE 'Borderline Watchlist'
    END AS intervention_action_plan
FROM students s
JOIN batches b ON s.batch_id = b.batch_id
JOIN courses c ON b.course_id = c.course_id
JOIN trainers t ON b.trainer_id = t.trainer_id
LEFT JOIN attendance att ON s.student_id = att.student_id
LEFT JOIN assessments ass ON s.student_id = ass.student_id
WHERE s.status IN ('Active', 'At-Risk')
GROUP BY s.student_id, s.full_name, s.email, s.phone, b.batch_name, c.course_name, t.trainer_name
HAVING attendance_pct < 70 OR score_pct < 60;


-- ==============================================================================
-- STORED PROCEDURE 1: sp_GetBatchPerformanceReport
-- Generates a thorough operational audit report for any batch ID
-- ==============================================================================
DELIMITER //
DROP PROCEDURE IF EXISTS sp_GetBatchPerformanceReport //
CREATE PROCEDURE sp_GetBatchPerformanceReport(IN in_batch_id VARCHAR(10))
BEGIN
    -- Batch Overview Summary
    SELECT 
        b.batch_id,
        b.batch_name,
        c.course_name,
        t.trainer_name,
        b.start_date,
        b.end_date,
        b.status AS batch_status,
        COUNT(s.student_id) AS enrolled_count,
        ROUND(AVG(att.attendance_pct), 2) AS batch_avg_attendance,
        ROUND(AVG(ass.score_pct), 2) AS batch_avg_assessment_score
    FROM batches b
    JOIN courses c ON b.course_id = c.course_id
    JOIN trainers t ON b.trainer_id = t.trainer_id
    LEFT JOIN students s ON b.batch_id = s.batch_id
    LEFT JOIN attendance att ON s.student_id = att.student_id
    LEFT JOIN assessments ass ON s.student_id = ass.student_id
    WHERE b.batch_id = in_batch_id
    GROUP BY b.batch_id, b.batch_name, c.course_name, t.trainer_name, b.start_date, b.end_date, b.status;

    -- Detailed Student List in the Batch
    SELECT 
        s.student_id,
        s.full_name,
        s.email,
        s.status,
        ROUND(AVG(att.attendance_pct), 2) AS attendance_pct,
        ROUND(AVG(ass.score_pct), 2) AS score_pct,
        p.company_name AS placed_company,
        p.ctc_lpa
    FROM students s
    LEFT JOIN attendance att ON s.student_id = att.student_id
    LEFT JOIN assessments ass ON s.student_id = ass.student_id
    LEFT JOIN placements p ON s.student_id = p.student_id
    WHERE s.batch_id = in_batch_id
    GROUP BY s.student_id, s.full_name, s.email, s.status, p.company_name, p.ctc_lpa
    ORDER BY score_pct DESC;
END //
DELIMITER ;


-- ==============================================================================
-- STORED PROCEDURE 2: sp_IdentifyDropoutCandidates
-- Dynamic parameters to filter high-risk students across the entire institution
-- ==============================================================================
DELIMITER //
DROP PROCEDURE IF EXISTS sp_IdentifyDropoutCandidates //
CREATE PROCEDURE sp_IdentifyDropoutCandidates(
    IN in_attendance_threshold DECIMAL(5,2),
    IN in_score_threshold DECIMAL(5,2)
)
BEGIN
    SELECT 
        s.student_id,
        s.full_name,
        s.email,
        s.phone,
        b.batch_name,
        c.course_name,
        t.trainer_name,
        ROUND(AVG(att.attendance_pct), 2) AS attendance_pct,
        ROUND(AVG(ass.score_pct), 2) AS score_pct
    FROM students s
    JOIN batches b ON s.batch_id = b.batch_id
    JOIN courses c ON b.course_id = c.course_id
    JOIN trainers t ON b.trainer_id = t.trainer_id
    LEFT JOIN attendance att ON s.student_id = att.student_id
    LEFT JOIN assessments ass ON s.student_id = ass.student_id
    WHERE s.status IN ('Active', 'At-Risk')
    GROUP BY s.student_id, s.full_name, s.email, s.phone, b.batch_name, c.course_name, t.trainer_name
    HAVING attendance_pct < in_attendance_threshold AND score_pct < in_score_threshold
    ORDER BY attendance_pct ASC, score_pct ASC;
END //
DELIMITER ;
