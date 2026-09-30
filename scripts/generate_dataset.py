"""
Student Performance Analytics - Relational Dataset Generator
Generates realistic datasets for an EdTech training institute (Uncodemy model).
Tables generated:
1. students.csv (1,000 records)
2. courses.csv (6 records)
3. trainers.csv (20 records)
4. batches.csv (35 records)
5. attendance.csv (10,500 records)
6. assessments.csv (6,000 records)
7. placements.csv (1,000 records)
Author: Uncodemy Student
"""

import os
import random
from datetime import datetime, timedelta
import pandas as pd
import numpy as np

random.seed(42)
np.random.seed(42)

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA_DIR = os.path.join(BASE_DIR, "data", "raw")
os.makedirs(DATA_DIR, exist_ok=True)

print(f"Generating Student Performance Datasets into: {DATA_DIR}")

# -----------------------------------------------------------------------------
# Configuration Constants
# -----------------------------------------------------------------------------
CITIES = ["Noida", "Delhi NCR", "Bengaluru", "Hyderabad", "Pune", "Lucknow", "Jaipur"]
CITY_WEIGHTS = [0.30, 0.25, 0.15, 0.12, 0.08, 0.05, 0.05]

EDUCATION_BACKGROUNDS = ["B.Tech / B.E (CS/IT)", "B.Tech (Non-CS)", "BCA / MCA", "B.Sc (Maths/Stats)", "B.Com / BBA (Non-Tech)"]
EDU_WEIGHTS = [0.35, 0.25, 0.20, 0.10, 0.10]

EMPLOYMENT_STATUS = ["Fresher / College Graduate", "Working Professional (Switching)", "Career Gap (>1 Year)"]
EMP_WEIGHTS = [0.60, 0.30, 0.10]

FIRST_NAMES = [
    "Aarav", "Pooja", "Rohan", "Ananya", "Vikram", "Sneha", "Karan", "Divya",
    "Arjun", "Neha", "Rahul", "Priya", "Aditya", "Tanvi", "Siddharth", "Kavya",
    "Amit", "Isha", "Varun", "Meera", "Gaurav", "Nidhi", "Naveen", "Swati",
    "Rishi", "Riya", "Rajesh", "Shreya", "Manish", "Anjali", "Deepak", "Simran",
    "Akash", "Komal", "Mayank", "Preeti", "Alok", "Rashmi", "Sachin", "Monika"
]
LAST_NAMES = [
    "Sharma", "Verma", "Patel", "Mehta", "Iyer", "Nair", "Reddy", "Rao",
    "Gupta", "Malhotra", "Kapoor", "Chopra", "Deshmukh", "Kulkarni", "Bose",
    "Chatterjee", "Singh", "Yadav", "Joshi", "Bhat", "Das", "Menon", "Jain",
    "Pandey", "Mishra", "Saxena", "Chauhan", "Trivedi", "Shukla", "Agrawal"
]

# -----------------------------------------------------------------------------
# 1. Courses (6 Core Tracks)
# -----------------------------------------------------------------------------
courses = [
    {"course_id": "CRS-101", "course_name": "Data Analytics Masterclass", "category": "Data & AI", "duration_weeks": 16, "course_fee": 38000, "min_passing_score": 65},
    {"course_id": "CRS-102", "course_name": "Full Stack Java Development", "category": "Software Engineering", "duration_weeks": 20, "course_fee": 45000, "min_passing_score": 70},
    {"course_id": "CRS-103", "course_name": "Data Science & Machine Learning", "category": "Data & AI", "duration_weeks": 24, "course_fee": 52000, "min_passing_score": 70},
    {"course_id": "CRS-104", "course_name": "Full Stack Python & Django", "category": "Software Engineering", "duration_weeks": 18, "course_fee": 42000, "min_passing_score": 65},
    {"course_id": "CRS-105", "course_name": "Business Intelligence & Power BI", "category": "Business Analytics", "duration_weeks": 12, "course_fee": 28000, "min_passing_score": 60},
    {"course_id": "CRS-106", "course_name": "Digital Marketing & Performance Growth", "category": "Digital Marketing", "duration_weeks": 12, "course_fee": 25000, "min_passing_score": 60}
]
df_courses = pd.DataFrame(courses)
df_courses.to_csv(os.path.join(DATA_DIR, "courses.csv"), index=False)

# -----------------------------------------------------------------------------
# 2. Trainers (20 Instructors)
# -----------------------------------------------------------------------------
trainers = []
specializations = ["Data Analytics & SQL", "Java & Spring Boot", "Python & Machine Learning", "Power BI & Tableau", "Full Stack Web Dev", "Digital Media Strategy"]

for tid in range(1, 21):
    fname = random.choice(FIRST_NAMES)
    lname = random.choice(LAST_NAMES)
    exp_years = random.randint(4, 14)
    rating = round(random.uniform(3.9, 4.9), 1)
    spec = random.choice(specializations)
    
    trainers.append({
        "trainer_id": f"TRN-{tid:03d}",
        "trainer_name": f"{fname} {lname}",
        "specialization": spec,
        "experience_years": exp_years,
        "trainer_rating": rating,
        "city": random.choice(["Noida", "Delhi NCR", "Bengaluru", "Hyderabad"])
    })
df_trainers = pd.DataFrame(trainers)
df_trainers.to_csv(os.path.join(DATA_DIR, "trainers.csv"), index=False)

# -----------------------------------------------------------------------------
# 3. Batches (35 Batches across 2024)
# -----------------------------------------------------------------------------
batches = []
batch_start_base = datetime(2024, 1, 8)

for bid in range(1, 36):
    course = random.choice(courses)
    trainer = random.choice(trainers)
    start_date = batch_start_base + timedelta(days=(bid - 1) * 9)
    end_date = start_date + timedelta(weeks=course["duration_weeks"])
    batch_type = random.choice(["Weekend Batch (Sat-Sun)", "Weekday Morning (Mon-Thu)", "Weekday Evening (Mon-Thu)"])
    
    batches.append({
        "batch_id": f"BTC-2024-{bid:03d}",
        "batch_name": f"{course['course_name'][:12].strip()} ({batch_type.split()[0]})",
        "course_id": course["course_id"],
        "trainer_id": trainer["trainer_id"],
        "batch_type": batch_type,
        "start_date": start_date.strftime("%Y-%m-%d"),
        "end_date": end_date.strftime("%Y-%m-%d"),
        "batch_capacity": 35
    })
df_batches = pd.DataFrame(batches)
df_batches.to_csv(os.path.join(DATA_DIR, "batches.csv"), index=False)

# -----------------------------------------------------------------------------
# 4. Students (1,000 Enrolled Students)
# -----------------------------------------------------------------------------
print("Creating Students table (1,000 records)...")
students = []
used_emails = set()

for sid in range(1, 1001):
    fname = random.choice(FIRST_NAMES)
    lname = random.choice(LAST_NAMES)
    assigned_batch = random.choice(batches)
    b_start = datetime.strptime(assigned_batch["start_date"], "%Y-%m-%d")
    enroll_date = b_start - timedelta(days=random.randint(4, 25))
    
    city = np.random.choice(CITIES, p=CITY_WEIGHTS)
    edu = np.random.choice(EDUCATION_BACKGROUNDS, p=EDU_WEIGHTS)
    emp = np.random.choice(EMPLOYMENT_STATUS, p=EMP_WEIGHTS)
    gender = random.choice(["Male", "Female"])
    
    email_base = f"{fname.lower()}.{lname.lower()}{random.randint(10, 999)}@gmail.com"
    while email_base in used_emails:
        email_base = f"{fname.lower()}.{lname.lower()}{random.randint(100, 9999)}@gmail.com"
    used_emails.add(email_base)
    
    # Intrinsic aptitude / engagement factor (affects attendance, assessments, and placement)
    engagement_factor = round(random.betavariate(2.8, 1.8), 2) # Skewed towards 0.6 - 0.95
    
    students.append({
        "student_id": f"UNC-STU-{sid:04d}",
        "student_name": f"{fname} {lname}",
        "email": email_base,
        "phone": f"+91-9{random.randint(100000000, 999999999)}",
        "city": city,
        "education_background": edu,
        "employment_status": emp,
        "gender": gender,
        "batch_id": assigned_batch["batch_id"],
        "course_id": assigned_batch["course_id"],
        "enrollment_date": enroll_date.strftime("%Y-%m-%d"),
        "engagement_factor": engagement_factor
    })
df_students = pd.DataFrame(students)
# Save without internal engagement factor
df_students.drop(columns=["engagement_factor"]).to_csv(os.path.join(DATA_DIR, "students.csv"), index=False)

# -----------------------------------------------------------------------------
# 5. Attendance (10,500 Session Records)
# -----------------------------------------------------------------------------
print("Creating Attendance table...")
attendance = []
att_counter = 1

# Generate 12 key milestone sessions per student
for stu in students:
    sid = stu["student_id"]
    bid = stu["batch_id"]
    b_rec = next(b for b in batches if b["batch_id"] == bid)
    b_start = datetime.strptime(b_rec["start_date"], "%Y-%m-%d")
    eng = stu["engagement_factor"]
    
    # Calculate attendance probability based on engagement factor
    p_present = min(0.96, max(0.40, eng + 0.05))
    p_late = min(0.15, max(0.02, (1 - p_present) * 0.3))
    p_absent = max(0.02, 1.0 - p_present - p_late)
    
    topics = [
        "Orientation & Industry Introduction", "Core Fundamentals & Setup", "Data Wrangling & Logic",
        "Intermediate Concepts Module 1", "Intermediate Concepts Module 2", "Hands-on Project Lab 1",
        "Advanced Problem Solving", "System Architecture & Best Practices", "Capstone Project Review 1",
        "Capstone Project Review 2", "Mock Technical Interview 1", "Final Placement Readiness Audit"
    ]
    
    for s_idx, topic in enumerate(topics):
        sess_date = b_start + timedelta(days=s_idx * 9)
        status = np.random.choice(["Present", "Late", "Absent"], p=[p_present, p_late, p_absent])
        mins_attended = 120 if status == "Present" else (random.randint(60, 95) if status == "Late" else 0)
        
        attendance.append({
            "attendance_id": f"ATT-{att_counter:07d}",
            "student_id": sid,
            "batch_id": bid,
            "session_number": s_idx + 1,
            "session_topic": topic,
            "session_date": sess_date.strftime("%Y-%m-%d"),
            "attendance_status": status,
            "duration_minutes": mins_attended
        })
        att_counter += 1

df_attendance = pd.DataFrame(attendance)
df_attendance.to_csv(os.path.join(DATA_DIR, "attendance.csv"), index=False)

# -----------------------------------------------------------------------------
# 6. Assessments (6,000 Records: 6 Evaluations per Student)
# -----------------------------------------------------------------------------
print("Creating Assessments table...")
assessments = []
asmt_counter = 1

evaluation_types = [
    ("Quiz 1: Fundamentals", 50, 1),
    ("Assignment 1: Data Modeling", 100, 2),
    ("Mid-Term Practical Exam", 100, 3),
    ("Quiz 2: Advanced Techniques", 50, 4),
    ("Major Capstone Project", 100, 5),
    ("Final Technical Mock Interview", 100, 6)
]

for stu in students:
    sid = stu["student_id"]
    bid = stu["batch_id"]
    eng = stu["engagement_factor"]
    
    for ev_name, max_s, seq in evaluation_types:
        # Base score driven by engagement factor + random noise
        base_pct = min(0.98, max(0.35, eng + random.uniform(-0.12, 0.10)))
        score = round(max_s * base_pct)
        
        # Submission timeliness
        if base_pct >= 0.70:
            sub_status = "On-Time"
        elif base_pct >= 0.50:
            sub_status = np.random.choice(["On-Time", "Delayed (<24h)"], p=[0.70, 0.30])
        else:
            sub_status = np.random.choice(["Delayed (<24h)", "Missed / Incomplete"], p=[0.55, 0.45])
            if sub_status == "Missed / Incomplete":
                score = round(score * 0.4)
                
        assessments.append({
            "assessment_id": f"ASM-{asmt_counter:06d}",
            "student_id": sid,
            "batch_id": bid,
            "assessment_name": ev_name,
            "sequence_order": seq,
            "max_score": max_s,
            "score_obtained": score,
            "percentage_score": round((score / max_s) * 100, 1),
            "submission_status": sub_status
        })
        asmt_counter += 1

df_assessments = pd.DataFrame(assessments)
df_assessments.to_csv(os.path.join(DATA_DIR, "assessments.csv"), index=False)

# -----------------------------------------------------------------------------
# 7. Placements & Employability (1,000 Records: 1 per Student)
# -----------------------------------------------------------------------------
print("Creating Placements table...")
placements = []
hiring_companies = [
    "TCS", "Infosys", "Wipro", "Accenture", "Cognizant", "Deloitte", "HCLTech",
    "Capgemini", "Amazon (AWS Support)", "Genpact", "Tech Mahindra", "EY", "KPMG",
    "Analytics Edge", "Razorpay", "Swiggy", "Zomato Tech", "Flipkart"
]

for p_idx, stu in enumerate(students, start=1):
    sid = stu["student_id"]
    eng = stu["engagement_factor"]
    edu = stu["education_background"]
    emp = stu["employment_status"]
    
    # Calculate student assessment avg
    stu_asmts = [a for a in assessments if a["student_id"] == sid]
    avg_asmt = sum(a["percentage_score"] for a in stu_asmts) / len(stu_asmts) if stu_asmts else 60.0
    
    # Attendance %
    stu_atts = [a for a in attendance if a["student_id"] == sid]
    present_cnt = sum(1 for a in stu_atts if a["attendance_status"] == "Present")
    att_pct = (present_cnt / len(stu_atts)) * 100 if stu_atts else 65.0
    
    # Employability Index Score (Weighted: 50% Assessments, 30% Attendance, 20% Mock Interview)
    mock_score = round(min(98, max(38, avg_asmt * 0.95 + random.randint(-5, 6))))
    employability_score = round((avg_asmt * 0.50) + (att_pct * 0.30) + (mock_score * 0.20), 1)
    
    # Placement outcome
    if employability_score >= 75.0:
        status = np.random.choice(["Placed", "In Pipeline"], p=[0.88, 0.12])
    elif employability_score >= 60.0:
        status = np.random.choice(["Placed", "In Pipeline", "Not Ready"], p=[0.55, 0.30, 0.15])
    else:
        status = np.random.choice(["In Pipeline", "Not Ready"], p=[0.30, 0.70])
        
    company = random.choice(hiring_companies) if status == "Placed" else "N/A"
    
    # Salary package calculation in LPA (Lakhs Per Annum)
    if status == "Placed":
        if employability_score >= 88:
            pkg = round(random.uniform(9.0, 16.5), 1)
        elif employability_score >= 75:
            pkg = round(random.uniform(5.5, 9.5), 1)
        else:
            pkg = round(random.uniform(3.6, 5.5), 1)
        interviews_attended = random.randint(2, 6)
        resumes_sent = random.randint(12, 35)
    else:
        pkg = 0.0
        interviews_attended = random.randint(0, 3)
        resumes_sent = random.randint(5, 20)
        
    placements.append({
        "placement_id": f"PLC-{p_idx:05d}",
        "student_id": sid,
        "attendance_pct": round(att_pct, 1),
        "assessment_avg_pct": round(avg_asmt, 1),
        "mock_interview_score": mock_score,
        "employability_index": employability_score,
        "placement_status": status,
        "hiring_company": company,
        "salary_package_lpa": pkg,
        "resumes_sent": resumes_sent,
        "interviews_attended": interviews_attended
    })

df_placements = pd.DataFrame(placements)
df_placements.to_csv(os.path.join(DATA_DIR, "placements.csv"), index=False)

print("\n--- Summary of Student Performance Dataset ---")
print(f"Courses:     {len(df_courses):,} records")
print(f"Trainers:    {len(df_trainers):,} records")
print(f"Batches:     {len(df_batches):,} records")
print(f"Students:    {len(df_students):,} records")
print(f"Attendance:  {len(df_attendance):,} records")
print(f"Assessments: {len(df_assessments):,} records")
print(f"Placements:  {len(df_placements):,} records")
print("Data Generation Completed by Uncodemy Student!")
