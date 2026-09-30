# 30+ Production DAX Measures Reference
**Project:** Student Performance Analytics  
**Role:** Business Analyst Portfolio  
**Author / Creator:** Uncodemy Student  
**Target Architecture:** Microsoft Power BI Desktop / Power BI Service

---

All DAX formulas are organized within a dedicated calculation table `_All_Measures` using logical display folders.

---

### Folder: 01. Headcount & Enrollment Measures

#### Measure 1: Total Enrolled Students
```dax
Total Students = 
DISTINCTCOUNT(Dim_Students[student_id])
```

#### Measure 2: Active Learners
```dax
Active Students = 
CALCULATE(
    [Total Students],
    Dim_Students[status] IN {"Active", "Enrolled"}
)
```

#### Measure 3: Graduated Alumni
```dax
Graduated Students = 
CALCULATE(
    [Total Students],
    Dim_Students[status] IN {"Completed", "Placed"}
)
```

#### Measure 4: At-Risk Headcount
```dax
At-Risk Students = 
CALCULATE(
    [Total Students],
    Dim_Students[status] = "At-Risk"
)
```

#### Measure 5: Dropped Students
```dax
Dropped Students = 
CALCULATE(
    [Total Students],
    Dim_Students[status] = "Dropped"
)
```

---

### Folder: 02. Academic Performance & Attendance Measures

#### Measure 6: Overall Average Attendance Rate
```dax
Avg Attendance % = 
AVERAGE(Fact_Attendance[attendance_pct])
```

#### Measure 7: Benchmark Attendance Compliance Count (>= 80%)
```dax
High Attendance Students = 
CALCULATE(
    [Total Students],
    FILTER(
        VALUES(Dim_Students[student_id]),
        CALCULATE(AVERAGE(Fact_Attendance[attendance_pct])) >= 80
    )
)
```

#### Measure 8: Average Assessment Score
```dax
Avg Assessment Score % = 
AVERAGE(Fact_Assessments[score_pct])
```

#### Measure 9: Assessment Pass Rate %
```dax
Assessment Pass Rate % = 
DIVIDE(
    CALCULATE(COUNTROWS(Fact_Assessments), Fact_Assessments[is_passed] = TRUE()),
    COUNTROWS(Fact_Assessments),
    0
) * 100
```

#### Measure 10: Capstone Project Average Score
```dax
Avg Capstone Project Score = 
CALCULATE(
    AVERAGE(Fact_Assessments[score_pct]),
    Fact_Assessments[assessment_type] = "Project"
)
```

#### Measure 11: Mock Interview Readiness Score
```dax
Avg Mock Interview Score = 
CALCULATE(
    AVERAGE(Fact_Assessments[score_pct]),
    Fact_Assessments[assessment_type] = "Mock Interview"
)
```

---

### Folder: 03. Retention, Attrition & Conversion Ratios

#### Measure 12: Course Completion Rate %
```dax
Completion Rate % = 
DIVIDE(
    [Graduated Students],
    [Total Students],
    0
) * 100
```

#### Measure 13: Dropout Attrition Rate %
```dax
Dropout Rate % = 
DIVIDE(
    [Dropped Students],
    [Total Students],
    0
) * 100
```

#### Measure 14: Placement Conversion Rate %
```dax
Placement Rate % = 
DIVIDE(
    [Placed Students],
    [Graduated Students],
    0
) * 100
```

#### Measure 15: Retention Health Score (Index 0-100)
```dax
Retention Health Score = 
100 - [Dropout Rate %]
```

---

### Folder: 04. Career Placement & Compensation Analytics

#### Measure 16: Placed Students Count
```dax
Placed Students = 
DISTINCTCOUNT(Fact_Placements[student_id])
```

#### Measure 17: Average Package (CTC in LPA)
```dax
Avg CTC LPA = 
AVERAGE(Fact_Placements[ctc_lpa])
```

#### Measure 18: Median Package (CTC in LPA)
```dax
Median CTC LPA = 
MEDIAN(Fact_Placements[ctc_lpa])
```

#### Measure 19: Peak Package (Highest CTC)
```dax
Highest CTC LPA = 
MAX(Fact_Placements[ctc_lpa])
```

#### Measure 20: Minimum Package (CTC LPA)
```dax
Min CTC LPA = 
MIN(Fact_Placements[ctc_lpa])
```

#### Measure 21: Tier-1 MNC Placement Count
```dax
Tier-1 Placements = 
CALCULATE(
    [Placed Students],
    Fact_Placements[company_tier] = "Tier-1 MNC"
)
```

#### Measure 22: High-Paying Offers Count (>= 8.0 LPA)
```dax
Offers Above 8 LPA = 
CALCULATE(
    [Placed Students],
    Fact_Placements[ctc_lpa] >= 8.0
)
```

---

### Folder: 05. Financial & Revenue Performance

#### Measure 23: Gross Contracted Tuition Revenue (INR)
```dax
Gross Tuition Potential INR = 
SUMX(
    Dim_Students,
    RELATED(Dim_Courses[fee_inr])
)
```

#### Measure 24: Net Tuition Cash Realized (INR)
```dax
Realized Tuition Revenue INR = 
SUMX(
    Dim_Students,
    RELATED(Dim_Courses[fee_inr]) * (Dim_Students[fees_paid_pct] / 100)
)
```

#### Measure 25: Outstanding Student Receivables (INR)
```dax
Outstanding Receivables INR = 
[Gross Tuition Potential INR] - [Realized Tuition Revenue INR]
```

#### Measure 26: Fee Collection Realization Rate %
```dax
Fee Collection Rate % = 
DIVIDE(
    [Realized Tuition Revenue INR],
    [Gross Tuition Potential INR],
    0
) * 100
```

---

### Folder: 06. Time Intelligence & Period-over-Period DAX

#### Measure 27: Enrollments Year-to-Date (YTD)
```dax
Enrollments YTD = 
TOTALYTD(
    [Total Students],
    Dim_Date[Date]
)
```

#### Measure 28: Placements Month-over-Month Growth (MoM %)
```dax
Placements MoM % = 
VAR CurrentMonthPlacements = [Placed Students]
VAR PriorMonthPlacements = 
    CALCULATE(
        [Placed Students],
        DATEADD(Dim_Date[Date], -1, MONTH)
    )
RETURN
    DIVIDE(
        CurrentMonthPlacements - PriorMonthPlacements,
        PriorMonthPlacements,
        0
    ) * 100
```

#### Measure 29: Revenue Quarter-over-Quarter Growth (QoQ %)
```dax
Revenue QoQ % = 
VAR CurrentQtr = [Realized Tuition Revenue INR]
VAR PriorQtr = 
    CALCULATE(
        [Realized Tuition Revenue INR],
        DATEADD(Dim_Date[Date], -1, QUARTER)
    )
RETURN
    DIVIDE(
        CurrentQtr - PriorQtr,
        PriorQtr,
        0
    ) * 100
```

---

### Folder: 07. Advanced Business Intelligence Indices

#### Measure 30: Student Employability Index (Composite 0-100)
```dax
Student Employability Index = 
-- Weighted Model: 40% Assessments + 30% Attendance + 30% Mock Interviews
VAR AvgScore = [Avg Assessment Score %]
VAR AvgAtt = [Avg Attendance %]
VAR MockScore = [Avg Mock Interview Score]
RETURN
    ROUND(
        (0.40 * AvgScore) + 
        (0.30 * AvgAtt) + 
        (0.30 * MockScore),
        1
    )
```

#### Measure 31: Dynamic KPI Indicator Status
```dax
Placement Health Indicator = 
SWITCH(
    TRUE(),
    [Placement Rate %] >= 75, "🟢 Exceptional (>75%)",
    [Placement Rate %] >= 65, "🟡 Target Range (65-74%)",
    "🔴 Action Needed (<65%)"
)
```

#### Measure 32: Trainer Effectiveness Score
```dax
Trainer Effectiveness Score = 
ROUND(
    (0.50 * [Avg Assessment Score %]) + 
    (0.30 * [Avg Attendance %]) + 
    (0.20 * ([Placement Rate %])),
    1
)
```
