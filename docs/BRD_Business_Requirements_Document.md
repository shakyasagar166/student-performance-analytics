# Business Requirements Document (BRD)
## Student Performance & Placement Analytics System
**Document Version:** 1.0  
**Project Lead / Author:** Uncodemy Student (Business Analyst)  
**Target Enterprise:** EdTech Training Academy / Career Acceleration Institute  
**Date:** October 2024 / Q3 FY24-25  

---

## 1. Executive Summary & Problem Statement

### 1.1 Business Context
Modern professional upskilling academies operate in an intensely competitive career transition market. The institute enrolls 1,000+ students annually across six specialized software and data engineering disciplines. While gross admissions have grown by 35% YoY, operational leadership identified three critical bottlenecks impacting bottom-line profitability and brand equity:
1. **Unmonitored Student Dropouts (14.2% Attrition):** Significant learner drop-off occurs midway through programs (Modules 4–7) without proactive counselor intervention.
2. **Placement Conversion Stagnation (68% vs 80% Target):** A large volume of graduates completed coursework but failed technical/mock interview screens.
3. **Information Silos:** Academic mentors tracked attendance in disparate spreadsheets, trainers graded assessments offline, and the corporate relations placement team operated with zero real-time visibility into student readiness.

### 1.2 Proposed Solution
The **Student Performance Analytics System** establishes a unified, single source of truth across MySQL 8.0, Microsoft Excel 365, and Power BI dashboards, backed by an interactive Python REST API. The platform provides real-time early warning dropout indicators, automated counselor queues, and an employer talent pipeline matching algorithm.

---

## 2. Business Objectives & Key Results (OKRs)

| Strategic Pillar | Metric | Baseline (Pre-Analytics) | Target (Post-Analytics) | Strategic Impact |
| :--- | :--- | :--- | :--- | :--- |
| **Student Retention** | Course Dropout Rate | 14.2% | **< 6.0%** | Protects ₹28.5 Lakhs in tuition fee installments |
| **Placement Success** | Placement Conversion % | 68.4% | **>= 78.0%** | Elevates campus hiring partnerships by 25% |
| **Salary Premium** | Average Graduate CTC | ₹5.40 LPA | **>= ₹6.80 LPA** | Strengthens institute brand authority |
| **Intervention Speed** | At-Risk Detection Latency | 30 Days (End of Cohort) | **< 24 Hours** | Enables immediate mentor 1-on-1 counseling |

---

## 3. Stakeholder Analysis & User Personas

```
+-----------------------------------------------------------------------------------------+
|                                    STAKEHOLDER MATRIX                                   |
+--------------------------+------------------------------+-------------------------------+
| Stakeholder Role         | Primary Needs                | Key Analytical Artifact       |
+--------------------------+------------------------------+-------------------------------+
| Executive Leadership     | Gross revenue, Placement %,  | Power BI Executive Cockpit,   |
| (MD / Academic Dean)     | Course ROI, Faculty ratings  | Excel Financial Model         |
+--------------------------+------------------------------+-------------------------------+
| Academic Mentors         | Attendance trends, Failed    | Early Warning Dropout Queue,  |
| & Batch Coordinators     | assignments, Risk flags      | Interactive Web UI Alerts     |
+--------------------------+------------------------------+-------------------------------+
| Corporate Placement Head | Talent pool readiness, CTC   | Recruiter Matching Dashboard, |
| & Campus Recruiters      | benchmarks, High-achievers   | SQL High-Performer Query #21  |
+--------------------------+------------------------------+-------------------------------+
| Enrolled Students        | Progress tracking, Strengths | Student 360 Profile View,     |
| (Uncodemy Learners)      | & skill gaps breakdown       | Assessment Gradecard          |
+--------------------------+------------------------------+-------------------------------+
```

---

## 4. Functional Requirements (FR)

### FR-01: Centralized Data Warehouse & Schema
* The system shall store student demographic, batch, curriculum, attendance, assessment, and placement records within a normalized 3NF MySQL relational database and a high-performance SQLite engine.
* The relational schema must enforce foreign key integrity and check constraints on attendance and test score percentages.

### FR-02: Automated Early Warning Dropout Detection
* The system shall automatically flag any student as **"At-Risk"** if their rolling module attendance drops below **70%** OR their cumulative assessment average drops below **60%**.
* Mentors must be provided with an immediate operational contact list (email, phone, batch, trainer) for counseling outreach.

### FR-03: Real-Time Employability Index Calculation
* The system shall evaluate student placement readiness using a weighted algorithmic index:
  $$\text{Employability Index} = (0.40 \times \text{Assessments}) + (0.30 \times \text{Attendance}) + (0.30 \times \text{Mock Interview Score})$$

### FR-04: Corporate Placement & CTC Benchmark Analytics
* The system shall calculate company-tier placement distributions (Tier-1 MNCs vs High-Growth Startups), tracking salary offers (CTC in LPA), interview rounds cleared, and recruiter hiring volumes.

### FR-05: Dynamic Ad-Hoc SQL Playground & Excel Export
* The business analyst interface must allow non-technical staff and BI analysts to execute custom SQL queries directly from the web browser and export results to formatted Microsoft Excel `.xlsx` files with a single click.

---

## 5. Non-Functional Requirements (NFR)

* **Performance & Latency:** All REST API endpoints must respond in `< 150 ms` for 1,000+ student records.
* **Compatibility:** Front-end must render flawlessly across modern desktop browsers (Chrome, Edge, Firefox) with responsive glassmorphic styling.
* **Zero Dependency Overhead:** The back-end must operate cleanly using Python's standard library (`http.server`, `sqlite3`, `csv`) with optional fallback to `openpyxl`.
* **Security & Role-Based Integrity:** Student contact numbers and academic records must be shielded against unauthorized modification using strict database schema constraints.
