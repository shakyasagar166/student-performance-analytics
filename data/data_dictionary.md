# Data Dictionary - Student Performance Analytics
## Author: Uncodemy Student (Business Analyst Portfolio)
### Entity Relationship & Schema Specifications (EdTech & Training Platform Model)

---

## 1. Table: `students`
Stores demographic, educational, and enrollment records of registered students.

| Column Name | Data Type | Nullable | Key | Description | Example |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `student_id` | `VARCHAR(15)` | No | **PK** | Unique student identifier | `UNC-STU-0001` |
| `student_name` | `VARCHAR(100)` | No | None | Full student name | `Aarav Sharma` |
| `email` | `VARCHAR(120)` | No | Unique | Contact email address | `aarav.sharma@gmail.com` |
| `phone` | `VARCHAR(20)` | No | None | Contact mobile number | `+91-9876543210` |
| `city` | `VARCHAR(50)` | No | None | Base city (`Noida`, `Delhi NCR`, `Bengaluru`, etc.) | `Noida` |
| `education_background` | `VARCHAR(60)` | No | None | Prior degree (`B.Tech (CS)`, `BCA`, `B.Sc`, `Non-Tech`)| `B.Tech / B.E (CS/IT)` |
| `employment_status` | `VARCHAR(50)` | No | None | Work status (`Fresher`, `Working Pro`, `Career Gap`)| `Fresher / College Graduate` |
| `gender` | `VARCHAR(10)` | No | None | Demographic gender | `Male` |
| `batch_id` | `VARCHAR(20)` | No | **FK** | Linked batch ID (`batches.batch_id`) | `BTC-2024-001` |
| `course_id` | `VARCHAR(15)` | No | **FK** | Linked course ID (`courses.course_id`) | `CRS-101` |
| `enrollment_date` | `DATE` | No | None | Date of admission | `2023-12-28` |

---

## 2. Table: `courses`
Catalog of professional career training tracks.

| Column Name | Data Type | Nullable | Key | Description | Example |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `course_id` | `VARCHAR(15)` | No | **PK** | Unique course reference | `CRS-101` |
| `course_name` | `VARCHAR(100)`| No | None | Career program title | `Data Analytics Masterclass` |
| `category` | `VARCHAR(50)` | No | None | Technical domain | `Data & AI` |
| `duration_weeks` | `INT` | No | None | Program length in calendar weeks | `16` |
| `course_fee` | `DECIMAL(10,2)`| No | None | Tuition fee in INR | `38000.00` |
| `min_passing_score` | `INT` | No | None | Passing benchmark percentage | `65` |

---

## 3. Table: `trainers`
Faculty profile and subject-matter expertise metrics.

| Column Name | Data Type | Nullable | Key | Description | Example |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `trainer_id` | `VARCHAR(15)` | No | **PK** | Unique instructor ID | `TRN-001` |
| `trainer_name` | `VARCHAR(100)`| No | None | Full instructor name | `Vikram Malhotra` |
| `specialization`| `VARCHAR(60)` | No | None | Core training domain | `Data Analytics & SQL` |
| `experience_years` | `INT` | No | None | Years of industry experience | `11` |
| `trainer_rating`| `DECIMAL(2,1)`| No | None | Student review feedback score (1.0 to 5.0) | `4.9` |
| `city` | `VARCHAR(50)` | No | None | Operating branch city | `Noida` |

---

## 4. Table: `batches`
Cohort scheduling and delivery format.

| Column Name | Data Type | Nullable | Key | Description | Example |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `batch_id` | `VARCHAR(20)` | No | **PK** | Unique batch identifier | `BTC-2024-001` |
| `batch_name` | `VARCHAR(100)`| No | None | Cohort display name | `Data Analytics (Weekend)` |
| `course_id` | `VARCHAR(15)` | No | **FK** | Linked course reference | `CRS-101` |
| `trainer_id` | `VARCHAR(15)` | No | **FK** | Assigned lead trainer | `TRN-001` |
| `batch_type` | `VARCHAR(40)` | No | None | Timing format (`Weekend Batch`, `Weekday Morning`) | `Weekend Batch (Sat-Sun)` |
| `start_date` | `DATE` | No | None | Batch kickoff date | `2024-01-06` |
| `end_date` | `DATE` | No | None | Expected completion date | `2024-04-28` |
| `batch_capacity`| `INT` | No | None | Maximum enrolled seat limit | `35` |

---

## 5. Table: `attendance`
Session-level attendance telemetry tracking engagement.

| Column Name | Data Type | Nullable | Key | Description | Example |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `attendance_id` | `VARCHAR(20)` | No | **PK** | Unique session attendance record | `ATT-0000001` |
| `student_id` | `VARCHAR(15)` | No | **FK** | Enrolled student ID | `UNC-STU-0001` |
| `batch_id` | `VARCHAR(20)` | No | **FK** | Batch session ID | `BTC-2024-001` |
| `session_number`| `INT` | No | None | Chronological session index (1 to 12) | `1` |
| `session_topic` | `VARCHAR(100)`| No | None | Module curriculum topic | `Orientation & Setup` |
| `session_date` | `DATE` | No | None | Session calendar date | `2024-01-06` |
| `attendance_status` | `VARCHAR(20)`| No | None | Attendance mark (`Present`, `Late`, `Absent`)| `Present` |
| `duration_minutes` | `INT` | No | None | Logged classroom minutes | `120` |

---

## 6. Table: `assessments`
Continuous evaluation grades tracking theoretical and practical skill development.

| Column Name | Data Type | Nullable | Key | Description | Example |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `assessment_id` | `VARCHAR(20)` | No | **PK** | Unique evaluation record | `ASM-000001` |
| `student_id` | `VARCHAR(15)` | No | **FK** | Evaluated student ID | `UNC-STU-0001` |
| `batch_id` | `VARCHAR(20)` | No | **FK** | Batch reference | `BTC-2024-001` |
| `assessment_name` | `VARCHAR(100)`| No | None | Test title (`Quiz 1`, `Capstone Project`) | `Quiz 1: Fundamentals`|
| `sequence_order` | `INT` | No | None | Curriculum sequence (1 to 6) | `1` |
| `max_score` | `INT` | No | None | Total possible marks | `50` |
| `score_obtained`| `INT` | No | None | Marks scored by student | `46` |
| `percentage_score`| `DECIMAL(5,1)`| No | None | Calculated score % | `92.0` |
| `submission_status`| `VARCHAR(30)`| No | None | Submission timeliness (`On-Time`, `Delayed`, `Missed`)| `On-Time` |

---

## 7. Table: `placements`
Career placement outcomes, mock interviews, and salary packages.

| Column Name | Data Type | Nullable | Key | Description | Example |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `placement_id` | `VARCHAR(20)` | No | **PK** | Unique placement outcome record | `PLC-00001` |
| `student_id` | `VARCHAR(15)` | No | **FK** | Student candidate ID | `UNC-STU-0001` |
| `attendance_pct`| `DECIMAL(5,1)`| No | None | Overall course attendance % | `91.7` |
| `assessment_avg_pct`| `DECIMAL(5,1)`| No | None | Overall evaluation score % | `88.4` |
| `mock_interview_score`| `INT` | No | None | Technical readiness interview score (0-100)| `90` |
| `employability_index`| `DECIMAL(5,1)`| No | None | Weighted Readiness Score: 50% Exam + 30% Att + 20% Mock | `89.8` |
| `placement_status`| `VARCHAR(30)` | No | None | Career outcome (`Placed`, `In Pipeline`, `Not Ready`)| `Placed` |
| `hiring_company` | `VARCHAR(100)`| Yes| None | Employer organization (`TCS`, `Deloitte`, `Accenture`)| `Deloitte` |
| `salary_package_lpa`| `DECIMAL(4,1)`| No | None | Annual starting compensation (INR Lakhs)| `9.4` |
| `resumes_sent` | `INT` | No | None | Number of job applications submitted | `24` |
| `interviews_attended`| `INT`| No | None | Number of company interviews cleared | `4` |
