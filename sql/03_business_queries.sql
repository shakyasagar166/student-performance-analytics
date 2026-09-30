-- ==============================================================================
-- PROJECT: Student Performance Analytics (EdTech / Career Institute Domain)
-- CREATOR / AUTHOR: Uncodemy Student
-- DATABASE ENGINE: MySQL 8.0+ / SQLite 3
-- SCRIPT 03: 21 Core Business Analyst SQL Queries & Window Functions
-- ==============================================================================

USE student_performance_db;

-- ==============================================================================
-- 1. EXECUTIVE KPI SUMMARY
-- Business Question: What is the overall health of the academy across enrollment,
-- completion, placement conversion, and compensation?
-- ==============================================================================
SELECT 
    COUNT(DISTINCT s.student_id) AS total_enrolled_students,
    SUM(CASE WHEN s.status IN ('Completed', 'Placed') THEN 1 ELSE 0 END) AS total_graduated,
    ROUND(SUM(CASE WHEN s.status IN ('Completed', 'Placed') THEN 1 ELSE 0 END) * 100.0 / COUNT(s.student_id), 2) AS completion_rate_pct,
    COUNT(DISTINCT p.student_id) AS total_placed_students,
    ROUND(COUNT(DISTINCT p.student_id) * 100.0 / NULLIF(SUM(CASE WHEN s.status IN ('Completed', 'Placed') THEN 1 ELSE 0 END), 0), 2) AS placement_rate_pct,
    ROUND(AVG(p.ctc_lpa), 2) AS avg_package_lpa,
    MAX(p.ctc_lpa) AS highest_package_lpa,
    MIN(p.ctc_lpa) AS min_package_lpa
FROM students s
LEFT JOIN placements p ON s.student_id = p.student_id;


-- ==============================================================================
-- 2. DOMAIN-WISE ENROLLMENT & REVENUE CONTRIBUTION
-- Business Question: Which technical domains drive the highest enrollment volume
-- and gross tuition fee revenues?
-- ==============================================================================
SELECT 
    c.domain,
    c.course_name,
    COUNT(s.student_id) AS enrolled_students,
    ROUND(COUNT(s.student_id) * 100.0 / SUM(COUNT(s.student_id)) OVER(), 2) AS share_of_enrollment_pct,
    SUM(c.fee_inr * (s.fees_paid_pct / 100.0)) AS realized_revenue_inr,
    ROUND(AVG(s.fees_paid_pct), 1) AS avg_fee_collection_pct
FROM students s
JOIN batches b ON s.batch_id = b.batch_id
JOIN courses c ON b.course_id = c.course_id
GROUP BY c.domain, c.course_name
ORDER BY realized_revenue_inr DESC;


-- ==============================================================================
-- 3. COURSE COMPLETION & ATTRITION BENCHMARK
-- Business Question: Which courses experience the highest student dropouts vs successful completions?
-- ==============================================================================
SELECT 
    c.course_name,
    COUNT(s.student_id) AS total_students,
    SUM(CASE WHEN s.status = 'Placed' THEN 1 ELSE 0 END) AS placed_count,
    SUM(CASE WHEN s.status = 'Completed' THEN 1 ELSE 0 END) AS completed_unplaced,
    SUM(CASE WHEN s.status = 'At-Risk' THEN 1 ELSE 0 END) AS at_risk_count,
    SUM(CASE WHEN s.status = 'Dropped' THEN 1 ELSE 0 END) AS dropped_count,
    ROUND(SUM(CASE WHEN s.status = 'Dropped' THEN 1 ELSE 0 END) * 100.0 / COUNT(s.student_id), 2) AS dropout_rate_pct
FROM courses c
JOIN batches b ON c.course_id = b.course_id
JOIN students s ON b.batch_id = s.batch_id
GROUP BY c.course_name
ORDER BY dropout_rate_pct DESC;


-- ==============================================================================
-- 4. ATTENDANCE TIER VS PLACEMENT SALARY CORRELATION
-- Business Question: Does disciplined class attendance directly translate to higher salary packages?
-- ==============================================================================
WITH StudentAvgAttendance AS (
    SELECT 
        student_id,
        ROUND(AVG(attendance_pct), 2) AS overall_attendance_pct
    FROM attendance
    GROUP BY student_id
)
SELECT 
    CASE 
        WHEN a.overall_attendance_pct >= 90 THEN '90% - 100% (High Attendance)'
        WHEN a.overall_attendance_pct >= 80 THEN '80% - 89% (Optimal Attendance)'
        WHEN a.overall_attendance_pct >= 70 THEN '70% - 79% (Borderline Attendance)'
        ELSE 'Below 70% (Poor Attendance)'
    END AS attendance_tier,
    COUNT(s.student_id) AS student_count,
    COUNT(p.placement_id) AS placed_count,
    ROUND(COUNT(p.placement_id) * 100.0 / COUNT(s.student_id), 2) AS placement_conversion_pct,
    ROUND(AVG(p.ctc_lpa), 2) AS avg_ctc_lpa,
    MAX(p.ctc_lpa) AS peak_ctc_lpa
FROM students s
JOIN StudentAvgAttendance a ON s.student_id = a.student_id
LEFT JOIN placements p ON s.student_id = p.student_id
GROUP BY attendance_tier
ORDER BY avg_ctc_lpa DESC;


-- ==============================================================================
-- 5. EARLY WARNING AT-RISK DROPOUT DETECTION
-- Business Question: Identify current active students who are at severe risk of failing or dropping out.
-- Business Trigger: Average attendance < 70% AND assessment score < 60%.
-- ==============================================================================
WITH StudentMetrics AS (
    SELECT 
        s.student_id,
        s.full_name,
        s.email,
        s.phone,
        b.batch_name,
        c.course_name,
        ROUND(AVG(att.attendance_pct), 2) AS avg_attendance,
        ROUND(AVG(ass.score_pct), 2) AS avg_assessment_score
    FROM students s
    JOIN batches b ON s.batch_id = b.batch_id
    JOIN courses c ON b.course_id = c.course_id
    LEFT JOIN attendance att ON s.student_id = att.student_id
    LEFT JOIN assessments ass ON s.student_id = ass.student_id
    WHERE s.status IN ('Active', 'At-Risk')
    GROUP BY s.student_id, s.full_name, s.email, s.phone, b.batch_name, c.course_name
)
SELECT 
    student_id,
    full_name,
    batch_name,
    course_name,
    avg_attendance,
    avg_assessment_score,
    CASE 
        WHEN avg_attendance < 60 AND avg_assessment_score < 50 THEN 'CRITICAL INTERVENTION'
        WHEN avg_attendance < 70 OR avg_assessment_score < 60 THEN 'MODERATE RISK'
        ELSE 'MONITOR'
    END AS risk_urgency_level
FROM StudentMetrics
WHERE avg_attendance < 70 OR avg_assessment_score < 60
ORDER BY avg_assessment_score ASC, avg_attendance ASC;


-- ==============================================================================
-- 6. MODULE DIFFICULTY DIAGNOSTIC (BOTTLENECK ANALYSIS)
-- Business Question: Which curriculum modules cause the steepest score drops across cohorts?
-- ==============================================================================
SELECT 
    c.course_name,
    ass.module_number,
    ROUND(AVG(ass.score_pct), 2) AS avg_score_pct,
    ROUND(MIN(ass.score_pct), 2) AS min_score_pct,
    ROUND(SUM(CASE WHEN ass.score_pct < 60 THEN 1 ELSE 0 END) * 100.0 / COUNT(ass.assessment_id), 2) AS failure_rate_pct,
    COUNT(ass.assessment_id) AS total_submissions
FROM assessments ass
JOIN students s ON ass.student_id = s.student_id
JOIN batches b ON s.batch_id = b.batch_id
JOIN courses c ON b.course_id = c.course_id
GROUP BY c.course_name, ass.module_number
HAVING avg_score_pct < 70 OR failure_rate_pct > 25
ORDER BY failure_rate_pct DESC, avg_score_pct ASC;


-- ==============================================================================
-- 7. TRAINER EFFECTIVENESS & STUDENT OUTCOME SCORECARD
-- Business Question: Evaluate trainer performance based on student pass rate, batch completion,
-- and placement success.
-- ==============================================================================
SELECT 
    t.trainer_id,
    t.trainer_name,
    t.domain,
    t.rating AS trainer_internal_rating,
    COUNT(DISTINCT b.batch_id) AS total_batches_mentored,
    COUNT(DISTINCT s.student_id) AS total_students_taught,
    ROUND(AVG(att.attendance_pct), 1) AS avg_student_attendance,
    ROUND(AVG(ass.score_pct), 1) AS avg_student_score,
    COUNT(DISTINCT p.placement_id) AS placed_students,
    ROUND(COUNT(DISTINCT p.placement_id) * 100.0 / NULLIF(COUNT(DISTINCT s.student_id), 0), 2) AS batch_placement_rate_pct,
    ROUND(AVG(p.ctc_lpa), 2) AS avg_placed_ctc
FROM trainers t
JOIN batches b ON t.trainer_id = b.trainer_id
JOIN students s ON b.batch_id = s.batch_id
LEFT JOIN attendance att ON s.student_id = att.student_id
LEFT JOIN assessments ass ON s.student_id = ass.student_id
LEFT JOIN placements p ON s.student_id = p.student_id
GROUP BY t.trainer_id, t.trainer_name, t.domain, t.rating
ORDER BY batch_placement_rate_pct DESC, avg_student_score DESC;


-- ==============================================================================
-- 8. COHORT RETENTION & ATTENDANCE DROP-OFF ACROSS MODULES
-- Business Question: How does student engagement trend from Module 1 through Module 12?
-- ==============================================================================
SELECT 
    module_number,
    COUNT(DISTINCT student_id) AS active_attendees,
    ROUND(AVG(attendance_pct), 2) AS mean_attendance_pct,
    ROUND(
        (AVG(attendance_pct) - LAG(AVG(attendance_pct), 1) OVER (ORDER BY module_number)), 
        2
    ) AS wow_attendance_change_pct
FROM attendance
GROUP BY module_number
ORDER BY module_number ASC;


-- ==============================================================================
-- 9. ASSESSMENT TYPE PERFORMANCE (QUIZ VS CAPSTONE VS MOCK INTERVIEW)
-- Business Question: Where do students struggle more: theoretical quizzes, hands-on capstones,
-- or behavioral/technical mock interviews?
-- ==============================================================================
SELECT 
    assessment_type,
    COUNT(assessment_id) AS total_evaluations,
    ROUND(AVG(score_pct), 2) AS avg_score,
    ROUND(STDDEV(score_pct), 2) AS score_volatility,
    ROUND(SUM(CASE WHEN score_pct >= 80 THEN 1 ELSE 0 END) * 100.0 / COUNT(assessment_id), 2) AS high_performer_pct,
    ROUND(SUM(CASE WHEN score_pct < 60 THEN 1 ELSE 0 END) * 100.0 / COUNT(assessment_id), 2) AS struggling_pct
FROM assessments
GROUP BY assessment_type
ORDER BY avg_score ASC;


-- ==============================================================================
-- 10. GENDER DIVERSITY & SALARY PARITY ANALYSIS
-- Business Question: Evaluate female and male representation, completion rates, and average CTC.
-- ==============================================================================
SELECT 
    s.gender,
    COUNT(s.student_id) AS enrolled_count,
    ROUND(COUNT(s.student_id) * 100.0 / SUM(COUNT(s.student_id)) OVER (), 2) AS cohort_share_pct,
    ROUND(AVG(ass.score_pct), 2) AS avg_assessment_score,
    COUNT(p.placement_id) AS placed_count,
    ROUND(COUNT(p.placement_id) * 100.0 / COUNT(s.student_id), 2) AS placement_rate,
    ROUND(AVG(p.ctc_lpa), 2) AS avg_placed_ctc_lpa
FROM students s
LEFT JOIN assessments ass ON s.student_id = ass.student_id
LEFT JOIN placements p ON s.student_id = p.student_id
GROUP BY s.gender
ORDER BY enrolled_count DESC;


-- ==============================================================================
-- 11. NON-IT TO IT CAREER TRANSITION ANALYSIS (BACKGROUND IMPACT)
-- Business Question: How do Non-Engineering/Non-CS graduates perform compared to B.Tech/BCA graduates?
-- ==============================================================================
SELECT 
    s.education_background,
    s.prior_coding_exp,
    COUNT(s.student_id) AS student_count,
    ROUND(AVG(ass.score_pct), 2) AS avg_assessment_score,
    COUNT(p.placement_id) AS placements_achieved,
    ROUND(COUNT(p.placement_id) * 100.0 / COUNT(s.student_id), 2) AS placement_success_pct,
    ROUND(AVG(p.ctc_lpa), 2) AS avg_ctc_lpa
FROM students s
LEFT JOIN assessments ass ON s.student_id = ass.student_id
LEFT JOIN placements p ON s.student_id = p.student_id
GROUP BY s.education_background, s.prior_coding_exp
ORDER BY student_count DESC;


-- ==============================================================================
-- 12. TOP 10 RECRUITING PARTNERS & CTC PACKAGES
-- Business Question: Who are our premier corporate hiring partners by intake volume and CTC?
-- ==============================================================================
SELECT 
    company_name,
    company_tier,
    COUNT(placement_id) AS total_hires,
    ROUND(AVG(ctc_lpa), 2) AS avg_ctc_offered,
    MIN(ctc_lpa) AS min_ctc,
    MAX(ctc_lpa) AS max_ctc,
    ROUND(AVG(interview_rounds_cleared), 1) AS avg_rounds_cleared
FROM placements
GROUP BY company_name, company_tier
ORDER BY total_hires DESC, avg_ctc_offered DESC
LIMIT 10;


-- ==============================================================================
-- 13. JOB ROLE DISTRIBUTION & SALARY BENCHMARKS
-- Business Question: What roles command the highest starting compensation for academy graduates?
-- ==============================================================================
SELECT 
    job_role,
    COUNT(placement_id) AS graduates_placed,
    ROUND(AVG(ctc_lpa), 2) AS avg_ctc_lpa,
    ROUND(STDDEV(ctc_lpa), 2) AS ctc_stddev,
    MIN(ctc_lpa) AS entry_min_ctc,
    MAX(ctc_lpa) AS top_max_ctc
FROM placements
GROUP BY job_role
ORDER BY avg_ctc_lpa DESC;


-- ==============================================================================
-- 14. CUMULATIVE REVENUE TREND (RUNNING TOTAL USING WINDOW FUNCTION)
-- Business Question: What is the cumulative fee realization month-over-month?
-- ==============================================================================
WITH MonthlyRevenue AS (
    SELECT 
        DATE_FORMAT(s.enrollment_date, '%Y-%m') AS enrollment_month,
        COUNT(s.student_id) AS monthly_enrolled,
        SUM(c.fee_inr * (s.fees_paid_pct / 100.0)) AS monthly_revenue_inr
    FROM students s
    JOIN batches b ON s.batch_id = b.batch_id
    JOIN courses c ON b.course_id = c.course_id
    GROUP BY DATE_FORMAT(s.enrollment_date, '%Y-%m')
)
SELECT 
    enrollment_month,
    monthly_enrolled,
    monthly_revenue_inr,
    SUM(monthly_revenue_inr) OVER (ORDER BY enrollment_month) AS cumulative_revenue_inr,
    ROUND(
        (monthly_revenue_inr - LAG(monthly_revenue_inr, 1) OVER (ORDER BY enrollment_month)) * 100.0 / 
        NULLIF(LAG(monthly_revenue_inr, 1) OVER (ORDER BY enrollment_month), 0), 
        2
    ) AS mom_revenue_growth_pct
FROM MonthlyRevenue
ORDER BY enrollment_month ASC;


-- ==============================================================================
-- 15. TOP 3 HIGHEST PERFORMING STUDENTS PER COURSE (DENSE_RANK)
-- Business Question: Recognize top academic achievers for prestigious placement referrals.
-- ==============================================================================
WITH StudentCourseScores AS (
    SELECT 
        c.course_name,
        s.student_id,
        s.full_name,
        ROUND(AVG(ass.score_pct), 2) AS academic_score,
        ROUND(AVG(att.attendance_pct), 2) AS avg_attendance,
        DENSE_RANK() OVER (
            PARTITION BY c.course_name 
            ORDER BY AVG(ass.score_pct) DESC, AVG(att.attendance_pct) DESC
        ) AS rank_in_course
    FROM students s
    JOIN batches b ON s.batch_id = b.batch_id
    JOIN courses c ON b.course_id = c.course_id
    JOIN assessments ass ON s.student_id = ass.student_id
    JOIN attendance att ON s.student_id = att.student_id
    GROUP BY c.course_name, s.student_id, s.full_name
)
SELECT 
    course_name,
    rank_in_course,
    student_id,
    full_name,
    academic_score,
    avg_attendance
FROM StudentCourseScores
WHERE rank_in_course <= 3
ORDER BY course_name, rank_in_course;


-- ==============================================================================
-- 16. STUDENT PERFORMANCE QUINTILES (NTILE BUCKETING)
-- Business Question: Segment learners into 5 distinct tiers (Top 20% to Bottom 20%)
-- to tailor mentorship programs.
-- ==============================================================================
WITH StudentAggregates AS (
    SELECT 
        s.student_id,
        s.full_name,
        ROUND(AVG(ass.score_pct), 2) AS composite_score,
        NTILE(5) OVER (ORDER BY AVG(ass.score_pct) DESC) AS performance_quintile
    FROM students s
    JOIN assessments ass ON s.student_id = ass.student_id
    GROUP BY s.student_id, s.full_name
)
SELECT 
    CASE performance_quintile
        WHEN 1 THEN 'Tier 1 - High Flyers (Top 20%)'
        WHEN 2 THEN 'Tier 2 - Strong Achievers (60-80%)'
        WHEN 3 THEN 'Tier 3 - Core Average (40-60%)'
        WHEN 4 THEN 'Tier 4 - Needs Assistance (20-40%)'
        WHEN 5 THEN 'Tier 5 - High Risk Priority (Bottom 20%)'
    END AS quintile_label,
    COUNT(student_id) AS student_count,
    ROUND(AVG(composite_score), 2) AS avg_tier_score,
    MIN(composite_score) AS tier_min_score,
    MAX(composite_score) AS tier_max_score
FROM StudentAggregates
GROUP BY performance_quintile
ORDER BY performance_quintile ASC;


-- ==============================================================================
-- 17. MONTH-OVER-MONTH PLACEMENT ACCELERATION (LAG FUNCTION)
-- Business Question: How has placement momentum expanded over consecutive recruitment quarters?
-- ==============================================================================
WITH MonthlyPlacements AS (
    SELECT 
        DATE_FORMAT(offer_date, '%Y-%m') AS placement_month,
        COUNT(placement_id) AS total_offers,
        ROUND(AVG(ctc_lpa), 2) AS monthly_avg_ctc
    FROM placements
    GROUP BY DATE_FORMAT(offer_date, '%Y-%m')
)
SELECT 
    placement_month,
    total_offers,
    LAG(total_offers, 1) OVER (ORDER BY placement_month) AS prior_month_offers,
    total_offers - LAG(total_offers, 1) OVER (ORDER BY placement_month) AS net_offers_delta,
    ROUND(
        (total_offers - LAG(total_offers, 1) OVER (ORDER BY placement_month)) * 100.0 / 
        NULLIF(LAG(total_offers, 1) OVER (ORDER BY placement_month), 0),
        2
    ) AS mom_placement_growth_pct,
    monthly_avg_ctc
FROM MonthlyPlacements
ORDER BY placement_month ASC;


-- ==============================================================================
-- 18. EARLY FOUNDATION VS CAPSTONE MASTERY PROGRESSION
-- Business Question: Did students improve significantly between early modules (1-3)
-- and advanced capstone modules (10-12)?
-- ==============================================================================
WITH PhaseComparison AS (
    SELECT 
        s.student_id,
        s.full_name,
        ROUND(AVG(CASE WHEN ass.module_number <= 3 THEN ass.score_pct END), 2) AS early_modules_avg,
        ROUND(AVG(CASE WHEN ass.module_number >= 10 THEN ass.score_pct END), 2) AS late_modules_avg
    FROM students s
    JOIN assessments ass ON s.student_id = ass.student_id
    GROUP BY s.student_id, s.full_name
)
SELECT 
    CASE 
        WHEN (late_modules_avg - early_modules_avg) >= 15 THEN 'Rapid Improver (+15% or more)'
        WHEN (late_modules_avg - early_modules_avg) > 0 THEN 'Steady Growth (0% to 15%)'
        WHEN (late_modules_avg - early_modules_avg) BETWEEN -10 AND 0 THEN 'Stable / Minor Dip'
        ELSE 'Severe Score Decline (Down >10%)'
    END AS trajectory_category,
    COUNT(student_id) AS student_count,
    ROUND(AVG(early_modules_avg), 1) AS baseline_avg,
    ROUND(AVG(late_modules_avg), 1) AS final_phase_avg
FROM PhaseComparison
WHERE early_modules_avg IS NOT NULL AND late_modules_avg IS NOT NULL
GROUP BY trajectory_category
ORDER BY student_count DESC;


-- ==============================================================================
-- 19. GEOGRAPHIC RECRUITMENT SPREAD & CTC PACKAGES
-- Business Question: Which student hometowns / metro areas achieve the best hiring outcomes?
-- ==============================================================================
SELECT 
    s.city,
    COUNT(s.student_id) AS total_enrolled,
    COUNT(p.placement_id) AS total_placed,
    ROUND(COUNT(p.placement_id) * 100.0 / COUNT(s.student_id), 2) AS placement_pct,
    ROUND(AVG(p.ctc_lpa), 2) AS avg_package_lpa,
    MAX(p.ctc_lpa) AS top_package_lpa
FROM students s
LEFT JOIN placements p ON s.student_id = p.student_id
GROUP BY s.city
ORDER BY total_enrolled DESC;


-- ==============================================================================
-- 20. HIRING COMPANY TIER COMPARISON
-- Business Question: Compare hiring criteria, packages, and rigor between MNCs and Startups.
-- ==============================================================================
SELECT 
    company_tier,
    COUNT(placement_id) AS total_offers,
    ROUND(AVG(ctc_lpa), 2) AS avg_ctc_lpa,
    ROUND(MIN(ctc_lpa), 2) AS min_ctc_lpa,
    ROUND(MAX(ctc_lpa), 2) AS max_ctc_lpa,
    ROUND(AVG(interview_rounds_cleared), 1) AS avg_rounds_demanded
FROM placements
GROUP BY company_tier
ORDER BY avg_ctc_lpa DESC;


-- ==============================================================================
-- 21. HIGH-POTENTIAL PLACEMENT REFERRAL CANDIDATES (INSTITUTE SHOWCASE)
-- Business Question: Pull learners who maintain >85% attendance, >80% assessment score,
-- and have completed all modules with 100% fees cleared.
-- ==============================================================================
SELECT 
    s.student_id,
    s.full_name,
    s.email,
    s.phone,
    c.course_name,
    s.city,
    ROUND(AVG(att.attendance_pct), 1) AS avg_attendance_pct,
    ROUND(AVG(ass.score_pct), 1) AS avg_score_pct,
    COUNT(DISTINCT ass.assessment_id) AS assessments_completed
FROM students s
JOIN batches b ON s.batch_id = b.batch_id
JOIN courses c ON b.course_id = c.course_id
JOIN attendance att ON s.student_id = att.student_id
JOIN assessments ass ON s.student_id = ass.student_id
WHERE s.status IN ('Active', 'Completed') 
  AND s.fees_paid_pct = 100.00
GROUP BY s.student_id, s.full_name, s.email, s.phone, c.course_name, s.city
HAVING avg_attendance_pct >= 85.00 AND avg_score_pct >= 80.00
ORDER BY avg_score_pct DESC, avg_attendance_pct DESC;
