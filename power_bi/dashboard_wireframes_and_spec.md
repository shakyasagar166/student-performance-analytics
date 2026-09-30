# Power BI Multi-Page Dashboard Specifications & Visual Layouts
**Project:** Student Performance Analytics  
**Role:** Business Analyst Portfolio  
**Author / Creator:** Uncodemy Student  
**Target Screen Resolution:** 16:9 Landscape (1920 x 1080 px)

---

## Color Palette & Theme Tokens
* **Primary Brand / Header:** Deep Navy (`#0F172A`)
* **Accent / Success:** Emerald Green (`#10B981`)
* **Secondary Accent:** Electric Indigo (`#6366F1`)
* **Warning / Alert:** Amber Gold (`#F59E0B`)
* **Danger / Dropouts:** Crimson Coral (`#EF4444`)
* **Card Background:** Crisp White (`#FFFFFF`) with Soft Gray Borders (`#E2E8F0`)
* **Canvas Background:** Light Slate (`#F8FAFC`)

---

## Page 1: Executive Academic & Financial Cockpit
* **Target Audience:** Academy Founder, Managing Director, Academic Dean
* **Core Purpose:** High-level strategic visibility over student admissions, graduation rates, placement yield, and realized revenues.

### Visual Architecture & Layout Grid
```
+---------------------------------------------------------------------------------------------------+
|  [LOGO: Uncodemy Student Portfolio]    STUDENT PERFORMANCE ANALYTICS COCKPIT    [Date Slicer | Track] |
+---------------------------------------------------------------------------------------------------+
| [KPI 1: Enrolled]   | [KPI 2: Completion %] | [KPI 3: Placement %] | [KPI 4: Avg CTC] | [KPI 5: Revenue]  |
| 1,000 Students     | 82.4% Completion     | 73.8% Conversion    | ₹6.82 LPA        | ₹4.85 Cr          |
+---------------------+-----------------------+----------------------+------------------+-------------------+
|                                             |                                                     |
| [Visual 1: Clustered Column & Line]         | [Visual 2: Donut Chart]                             |
| Course Domain Enrollment & Revenue Yield    | Student Status Distribution                         |
| (X: Domain, Y: Realized INR, Line: Placed%) | (Active, Placed, Completed, At-Risk, Dropped)       |
|                                             |                                                     |
+---------------------------------------------+-----------------------------------------------------+
|                                             |                                                     |
| [Visual 3: Matrix Grid with Data Bars]      | [Visual 4: Scatter Plot]                            |
| Faculty & Trainer Performance Scorecard     | Batch Size vs Placement Conversion Benchmark        |
| (Trainer, Batches, Att%, Avg Score, CTC)    | (X: Avg Attendance %, Y: Avg CTC LPA, Bubble: Size) |
|                                             |                                                     |
+---------------------------------------------------------------------------------------------------+
```

---

## Page 2: Student Dropout Risk & Module Diagnostic
* **Target Audience:** Academic Mentors, Batch Coordinators, Student Success Officers
* **Core Purpose:** Early intervention alert engine to identify struggling learners before they drop out.

### Visual Architecture & Layout Grid
```
+---------------------------------------------------------------------------------------------------+
| FILTERS: [Batch Type: All] | [Trainer: All] | [Risk Tier: High / Medium] | [Module: 1-12]         |
+---------------------------------------------------------------------------------------------------+
| [KPI: At-Risk Students: 114] | [Avg Attendance: 76.4%] | [Failures in Projects: 18.2%]            |
+---------------------------------------------------------------------------------------------------+
|                                             |                                                     |
| [Visual 1: Heatmap / 100% Stacked Bar]      | [Visual 2: Funnel Chart]                            |
| Module-wise Drop-off & Score Decline        | Student Retention Pipeline                          |
| (Modules 1 to 12 vs Avg Score & Absenteeism)| (Module 1 -> Module 4 -> Module 8 -> Capstone)     |
|                                             |                                                     |
+---------------------------------------------+-----------------------------------------------------+
| [Visual 3: Drill-Through Operational Table: "Intervention Priority Action List"]                  |
| Student ID | Name | Phone | Batch | Att % | Avg Score % | Capstone Status | Recommended Action    |
| (Conditional formatting: Red alert for Att < 70% and Score < 60%)                                 |
+---------------------------------------------------------------------------------------------------+
```

---

## Page 3: Corporate Placement & Compensation Insights
* **Target Audience:** Head of Corporate Relations, Placement Officers, Prospective Learners
* **Core Purpose:** Detailed breakdown of campus hiring, salary brackets, hiring partners, and alumni career paths.

### Visual Architecture & Layout Grid
```
+---------------------------------------------------------------------------------------------------+
| FILTERS: [Company Tier: Tier-1 MNC / Startup] | [Job Role: Analyst / Dev] | [CTC Bracket: All]    |
+---------------------------------------------------------------------------------------------------+
| [KPI: Total Placed: 608] | [Avg Package: 6.82 LPA] | [Top Package: 16.5 LPA] | [Hiring Partners: 48] |
+---------------------------------------------------------------------------------------------------+
|                                             |                                                     |
| [Visual 1: Horizontal Bar Chart]            | [Visual 2: Histogram / Box & Whisker]               |
| Top 15 Recruiting Companies by Hires & CTC  | CTC Distribution by Technical Specialization Track  |
|                                             | (Data Analytics vs Full Stack vs AI/ML)             |
|                                             |                                                     |
+---------------------------------------------+-----------------------------------------------------+
|                                             |                                                     |
| [Visual 3: Ribbon Chart]                    | [Visual 4: Decomposition Tree (AI Visual)]          |
| MoM Placement Velocity & Offer Growth       | CTC Drivers Root Cause Exploration                  |
| (Month-over-month hiring volume progression)| (Placement CTC -> Domain -> Education -> Att Tier)  |
|                                             |                                                     |
+---------------------------------------------------------------------------------------------------+
```
