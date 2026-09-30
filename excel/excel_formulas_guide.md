# Microsoft Excel Analytics & Financial Model Guide
**Project:** Student Performance Analytics  
**Role:** Business Analyst Portfolio  
**Author / Creator:** Uncodemy Student  
**File Reference:** `excel/Student_Performance_Model.xlsx`

---

## 1. Executive Summary & Workbook Architecture
The Microsoft Excel analytical model (`Student_Performance_Model.xlsx`) is structured into four integrated worksheets designed for EdTech business intelligence, financial tracking, and student risk management:

```
Student_Performance_Model.xlsx
 ├── 1. Raw_Students (Master Demographic & Enrollment Database)
 ├── 2. Performance_Fact (Consolidated Academic, Attendance & Placement Matrix)
 ├── 3. Pivot_Summary (Dynamic Cross-tabulation by Domain & Batch Type)
 └── 4. KPI_Scorecard (Executive C-Suite KPI Dashboard with Dynamic Excel Formulas)
```

---

## 2. Dynamic Excel Formulas & Production Implementations

### A. Dynamic Cross-Table Lookups (`XLOOKUP`)
* **Business Objective:** Retrieve the Course Domain, Course Fee, and Trainer Name dynamically into the student master table without hardcoding or VLOOKUP column-index fragility.
* **Excel 365 Formula:**
  ```excel
  =XLOOKUP(D2, Courses!$A$2:$A$7, Courses!$B$2:$B$7, "Not Found", 0)
  ```
* **Explanation:** Searches for `course_id` in column D against `Courses!A2:A7` and returns the exact course name from `Courses!B2:B7`.

### B. Multi-Tier Student Performance Classification (`IFS`)
* **Business Objective:** Assign automated academic honors and risk categories to students based on composite assessment and attendance performance.
* **Formula:**
  ```excel
  =IFS(
      AND(H2>=85, G2>=85), "Tier 1: High Honors & Priority Placement",
      AND(H2>=75, G2>=75), "Tier 2: Job Ready (Standard Placement)",
      AND(H2>=60, G2>=60), "Tier 3: Satisfactory (Remedial Needed)",
      OR(H2<60, G2<70),    "Tier 4: At-Risk (Counselor Escalation)"
  )
  ```
  *(Where `G2` is Attendance % and `H2` is Assessment Score %)*

### C. Fee Collection & Tuition Revenue Realization (`SUMIFS`)
* **Business Objective:** Calculate realized tuition revenue specifically for the "Data Analytics" track across Weekend batches.
* **Formula:**
  ```excel
  =SUMIFS(
      Performance_Fact!$I$2:$I$1001, 
      Performance_Fact!$C$2:$C$1001, "Data Analytics", 
      Performance_Fact!$D$2:$D$1001, "Weekend"
  )
  ```

### D. Qualified Placement Conversion Rate (`COUNTIFS`)
* **Business Objective:** Calculate the percentage of graduated students who successfully secured placement offers with salaries above ₹6.0 LPA.
* **Formula:**
  ```excel
  =COUNTIFS(
      Performance_Fact!$K$2:$K$1001, "Placed", 
      Performance_Fact!$L$2:$L$1001, ">=6.0"
  ) / COUNTIF(Performance_Fact!$K$2:$K$1001, "Placed")
  ```

### E. Domain-Weighted Average Salary Benchmark (`AVERAGEIFS`)
* **Business Objective:** Compute the average CTC offered exclusively to students who achieved >=80% attendance in Cloud/DevOps or Full Stack tracks.
* **Formula:**
  ```excel
  =AVERAGEIFS(
      Performance_Fact!$L$2:$L$1001, 
      Performance_Fact!$G$2:$G$1001, ">=80", 
      Performance_Fact!$C$2:$C$1001, "Full Stack Java"
  )
  ```

### F. Modern Dynamic Array Extraction (`FILTER` & `SORT`)
* **Business Objective:** Dynamically spill the Top 10 placed candidates sorted descending by their CTC package onto an executive briefing tab.
* **Formula:**
  ```excel
  =SORT(
      FILTER(
          CHOOSECOLS(Performance_Fact!A2:L1001, 1, 2, 3, 11, 12), 
          Performance_Fact!K2:K1001="Placed"
      ), 
      5, -1
  )
  ```

---

## 3. Pivot Table Architecture & Business Analysis

### Pivot Table 1: Domain-wise Performance & Placement Yield
- **Rows:** `course_name` (Data Analytics, Full Stack Java, Data Science, etc.)
- **Columns:** `batch_type` (Weekday, Weekend)
- **Values:**
  - `Count of student_id` (Enrollment volume)
  - `Average of attendance_pct` (Engagement metric)
  - `Average of score_pct` (Academic mastery)
  - `Count of ctc_lpa` (Placed count)
  - `Average of ctc_lpa` (Salary benchmark)

### Pivot Table 2: Educational Background vs Placement Conversion
- **Rows:** `education_background` (B.Tech / BE, BCA / MCA, B.Sc / M.Sc, Non-STEM / Commerce)
- **Values:**
  - `Total Students`
  - `Placed %` (Calculated field: `= Placed / Total`)
  - `Average CTC (LPA)`

---

## 4. Conditional Formatting Business Rules
1. **Attendance Warning (Red Alert):** Any cell in `attendance_pct` < 75.0% is highlighted with Soft Red (`#FEE2E2`) and Dark Red text (`#991B1B`).
2. **Exemplary Performance (Green Alert):** Assessment scores >= 85.0% are highlighted with Soft Green (`#DCFCE7`) and Dark Green text (`#166534`).
3. **Data Bars on Compensation:** Column `ctc_lpa` utilizes subtle gradient data bars (Slate Blue) to display salary distribution directly in the tabular grid.
