/* ==============================================================================
   PROJECT: Student Performance Analytics
   CREATOR / AUTHOR: Uncodemy Student
   JAVASCRIPT: Full-Stack Client Logic, Chart.js Integrations, SQL Engine Client
   ============================================================================== */

// Predefined Business Analyst SQL Queries for Quick Selection
const PRESET_QUERIES = {
  "1": `-- Query 1: Executive KPI Summary
SELECT 
    COUNT(DISTINCT s.student_id) AS total_enrolled,
    SUM(CASE WHEN s.status IN ('Completed', 'Placed') THEN 1 ELSE 0 END) AS graduated,
    ROUND(SUM(CASE WHEN s.status IN ('Completed', 'Placed') THEN 1 ELSE 0 END) * 100.0 / COUNT(s.student_id), 1) AS completion_pct,
    COUNT(DISTINCT p.student_id) AS placed_students,
    ROUND(COUNT(DISTINCT p.student_id) * 100.0 / NULLIF(SUM(CASE WHEN s.status IN ('Completed', 'Placed') THEN 1 ELSE 0 END), 0), 1) AS placement_pct,
    ROUND(AVG(p.ctc_lpa), 2) AS avg_ctc_lpa,
    MAX(p.ctc_lpa) AS max_ctc_lpa
FROM students s
LEFT JOIN placements p ON s.student_id = p.student_id;`,

  "2": `-- Query 2: Domain-wise Enrollment & Revenue Contribution
SELECT 
    c.domain,
    c.course_name,
    COUNT(s.student_id) AS enrolled_students,
    ROUND(SUM(c.fee_inr * (s.fees_paid_pct / 100.0)) / 100000.0, 2) AS realized_revenue_lakhs,
    ROUND(AVG(s.fees_paid_pct), 1) AS avg_fee_collection_pct
FROM students s
JOIN batches b ON s.batch_id = b.batch_id
JOIN courses c ON b.course_id = c.course_id
GROUP BY c.domain, c.course_name
ORDER BY realized_revenue_lakhs DESC;`,

  "3": `-- Query 3: Course Completion & Dropout Benchmark
SELECT 
    c.course_name,
    COUNT(s.student_id) AS total_students,
    SUM(CASE WHEN s.status = 'Placed' THEN 1 ELSE 0 END) AS placed,
    SUM(CASE WHEN s.status = 'At-Risk' THEN 1 ELSE 0 END) AS at_risk,
    SUM(CASE WHEN s.status = 'Dropped' THEN 1 ELSE 0 END) AS dropped,
    ROUND(SUM(CASE WHEN s.status = 'Dropped' THEN 1 ELSE 0 END) * 100.0 / COUNT(s.student_id), 2) AS dropout_rate_pct
FROM courses c
JOIN batches b ON c.course_id = b.course_id
JOIN students s ON b.batch_id = s.batch_id
GROUP BY c.course_name
ORDER BY dropout_rate_pct DESC;`,

  "4": `-- Query 4: Attendance Tier vs Placement Salary Correlation
SELECT 
    CASE 
        WHEN a.att_avg >= 90 THEN '90% - 100% (High Attendance)'
        WHEN a.att_avg >= 80 THEN '80% - 89% (Optimal Attendance)'
        WHEN a.att_avg >= 70 THEN '70% - 79% (Borderline Attendance)'
        ELSE 'Below 70% (Poor Attendance)'
    END AS attendance_tier,
    COUNT(s.student_id) AS student_count,
    COUNT(p.placement_id) AS placed_count,
    ROUND(COUNT(p.placement_id) * 100.0 / COUNT(s.student_id), 1) AS placement_rate_pct,
    ROUND(AVG(p.ctc_lpa), 2) AS avg_ctc_lpa,
    MAX(p.ctc_lpa) AS max_ctc_lpa
FROM students s
JOIN (
    SELECT student_id, AVG(attendance_pct) AS att_avg
    FROM attendance
    GROUP BY student_id
) a ON s.student_id = a.student_id
LEFT JOIN placements p ON s.student_id = p.student_id
GROUP BY attendance_tier
ORDER BY avg_ctc_lpa DESC;`,

  "5": `-- Query 5: Early Warning At-Risk Dropout Detection
SELECT 
    s.student_id,
    s.full_name,
    b.batch_name,
    c.course_name,
    ROUND(AVG(att.attendance_pct), 1) AS avg_attendance,
    ROUND(AVG(ass.score_pct), 1) AS avg_score,
    CASE 
        WHEN AVG(att.attendance_pct) < 60 AND AVG(ass.score_pct) < 50 THEN 'CRITICAL ALERT'
        ELSE 'MODERATE RISK'
    END AS urgency_level
FROM students s
JOIN batches b ON s.batch_id = b.batch_id
JOIN courses c ON b.course_id = c.course_id
LEFT JOIN attendance att ON s.student_id = att.student_id
LEFT JOIN assessments ass ON s.student_id = ass.student_id
WHERE s.status IN ('Active', 'At-Risk')
GROUP BY s.student_id, s.full_name, b.batch_name, c.course_name
HAVING avg_attendance < 70 OR avg_score < 60
ORDER BY avg_score ASC, avg_attendance ASC
LIMIT 15;`,

  "7": `-- Query 7: Trainer Effectiveness Scorecard
SELECT 
    t.trainer_name,
    t.domain,
    t.rating AS trainer_rating,
    COUNT(DISTINCT s.student_id) AS students_taught,
    ROUND(AVG(att.attendance_pct), 1) AS avg_attendance,
    ROUND(AVG(ass.score_pct), 1) AS avg_score,
    COUNT(DISTINCT p.placement_id) AS placed_count,
    ROUND(AVG(p.ctc_lpa), 2) AS avg_ctc
FROM trainers t
JOIN batches b ON t.trainer_id = b.trainer_id
JOIN students s ON b.batch_id = s.batch_id
LEFT JOIN attendance att ON s.student_id = att.student_id
LEFT JOIN assessments ass ON s.student_id = ass.student_id
LEFT JOIN placements p ON s.student_id = p.student_id
GROUP BY t.trainer_id, t.trainer_name, t.domain, t.rating
ORDER BY avg_score DESC;`,

  "12": `-- Query 12: Top Recruiting Partners by Hires & CTC
SELECT 
    company_name,
    company_tier,
    COUNT(placement_id) AS total_hires,
    ROUND(AVG(ctc_lpa), 2) AS avg_ctc_offered,
    MIN(ctc_lpa) AS min_ctc,
    MAX(ctc_lpa) AS max_ctc
FROM placements
GROUP BY company_name, company_tier
ORDER BY total_hires DESC, avg_ctc_offered DESC
LIMIT 10;`,

  "13": `-- Query 13: Job Role Salary Benchmarks
SELECT 
    job_role,
    COUNT(placement_id) AS graduates_placed,
    ROUND(AVG(ctc_lpa), 2) AS avg_ctc_lpa,
    MIN(ctc_lpa) AS min_ctc,
    MAX(ctc_lpa) AS max_ctc
FROM placements
GROUP BY job_role
ORDER BY avg_ctc_lpa DESC;`,

  "15": `-- Query 15: Top 3 Students per Track (Window Function: DENSE_RANK)
WITH RankedStudents AS (
    SELECT 
        c.course_name,
        s.student_id,
        s.full_name,
        ROUND(AVG(ass.score_pct), 2) AS avg_score,
        DENSE_RANK() OVER (
            PARTITION BY c.course_name 
            ORDER BY AVG(ass.score_pct) DESC
        ) AS rank_in_track
    FROM students s
    JOIN batches b ON s.batch_id = b.batch_id
    JOIN courses c ON b.course_id = c.course_id
    JOIN assessments ass ON s.student_id = ass.student_id
    GROUP BY c.course_name, s.student_id, s.full_name
)
SELECT course_name, rank_in_track, student_id, full_name, avg_score
FROM RankedStudents
WHERE rank_in_track <= 3
ORDER BY course_name, rank_in_track;`,

  "21": `-- Query 21: High-Potential Placement Candidates (Priority Referral)
SELECT 
    s.student_id,
    s.full_name,
    s.email,
    c.course_name,
    s.city,
    ROUND(AVG(att.attendance_pct), 1) AS avg_attendance,
    ROUND(AVG(ass.score_pct), 1) AS avg_score
FROM students s
JOIN batches b ON s.batch_id = b.batch_id
JOIN courses c ON b.course_id = c.course_id
JOIN attendance att ON s.student_id = att.student_id
JOIN assessments ass ON s.student_id = ass.student_id
WHERE s.status IN ('Active', 'Completed')
GROUP BY s.student_id, s.full_name, s.email, c.course_name, s.city
HAVING avg_attendance >= 85 AND avg_score >= 80
ORDER BY avg_score DESC
LIMIT 12;`
};

let chartDomainInstance = null;
let chartStatusInstance = null;
let allStudentsMasterData = [];

// ==============================================================================
// 1. INITIALIZATION & DATA FETCHING
// ==============================================================================
window.addEventListener('DOMContentLoaded', async () => {
  loadPresetQuery();
  await checkBackendStatus();
  await loadKpis();
  await loadCharts();
  await loadStudentExplorerData();
});

// Check Backend Connection Status
async function checkBackendStatus() {
  const badge = document.getElementById('backendStatusBadge');
  const text = document.getElementById('backendStatusText');
  try {
    const res = await fetch('/api/status');
    if (!res.ok) throw new Error('Status non-200');
    const data = await res.json();
    badge.className = "bg-slate-800/80 text-emerald-400 border border-emerald-500/30 px-3 py-1.5 rounded-full flex items-center gap-2";
    text.innerHTML = `<span class="w-2 h-2 rounded-full bg-emerald-400 animate-ping"></span> Live Database (${data.total_students} Students)`;
  } catch (err) {
    badge.className = "bg-slate-800/80 text-amber-400 border border-amber-500/30 px-3 py-1.5 rounded-full flex items-center gap-2";
    text.innerHTML = `<span class="w-2 h-2 rounded-full bg-amber-400"></span> Local Demo Mode`;
  }
}

// Load KPIs from Backend REST API
async function loadKpis() {
  try {
    const res = await fetch('/api/kpis');
    if (!res.ok) throw new Error('KPIs endpoint error');
    const data = await res.json();

    document.getElementById('kpiTotalStudents').textContent = Number(data.total_enrolled).toLocaleString();
    document.getElementById('kpiCompletionRate').textContent = `${data.completion_rate_pct}%`;
    document.getElementById('kpiGraduatedCount').textContent = Number(data.total_graduated).toLocaleString();
    document.getElementById('kpiPlacementRate').textContent = `${data.placement_rate_pct}%`;
    document.getElementById('kpiPlacedCount').textContent = Number(data.total_placed).toLocaleString();
    document.getElementById('kpiAvgPackage').innerHTML = `&#8377;${data.avg_package_lpa} LPA`;
    document.getElementById('kpiHighestPackage').innerHTML = `&#8377;${data.highest_package_lpa} LPA`;
    
    const revCrores = (data.realized_revenue_inr / 10000000).toFixed(2);
    document.getElementById('kpiRealizedRevenue').innerHTML = `&#8377;${revCrores} Cr`;
    document.getElementById('lastUpdatedTime').textContent = `Live Synced: ${new Date().toLocaleTimeString()}`;
  } catch (err) {
    console.warn('Fallback to static KPIs:', err);
  }
}

// Load Interactive Chart.js Visualizations
async function loadCharts() {
  // Chart 1: Domain Revenue
  try {
    const res = await fetch('/api/charts/domain-revenue');
    const d = await res.json();
    const ctx = document.getElementById('chartDomainRevenue').getContext('2d');
    if (chartDomainInstance) chartDomainInstance.destroy();
    chartDomainInstance = new Chart(ctx, {
      type: 'bar',
      data: {
        labels: d.domains,
        datasets: [
          {
            label: 'Students Enrolled',
            data: d.students,
            backgroundColor: '#818cf8',
            borderRadius: 6,
            yAxisID: 'y'
          },
          {
            label: 'Revenue (₹ Lakhs)',
            data: d.revenue_lakhs,
            type: 'line',
            borderColor: '#10b981',
            backgroundColor: '#10b981',
            borderWidth: 2,
            tension: 0.3,
            yAxisID: 'y1'
          }
        ]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        scales: {
          y: { type: 'linear', position: 'left', title: { display: true, text: 'Enrolled Count' } },
          y1: { type: 'linear', position: 'right', grid: { drawOnChartArea: false }, title: { display: true, text: 'Revenue (₹L)' } }
        }
      }
    });
  } catch (err) {
    console.error('Error loading domain chart:', err);
  }

  // Chart 2: Student Status Doughnut
  try {
    const res = await fetch('/api/charts/student-status');
    const d = await res.json();
    const ctx = document.getElementById('chartStudentStatus').getContext('2d');
    if (chartStatusInstance) chartStatusInstance.destroy();
    chartStatusInstance = new Chart(ctx, {
      type: 'doughnut',
      data: {
        labels: d.labels,
        datasets: [{
          data: d.counts,
          backgroundColor: ['#10b981', '#3b82f6', '#8b5cf6', '#f59e0b', '#ef4444', '#64748b']
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: { position: 'right', labels: { boxWidth: 12, font: { size: 11 } } }
        }
      }
    });
  } catch (err) {
    console.error('Error loading status chart:', err);
  }
}

// ==============================================================================
// 2. LIVE SQL PLAYGROUND ENGINE
// ==============================================================================
function loadPresetQuery() {
  const select = document.getElementById('presetQuerySelect');
  const query = PRESET_QUERIES[select.value] || PRESET_QUERIES["4"];
  document.getElementById('sqlInput').value = query;
}

async function runCustomSql() {
  const sql = document.getElementById('sqlInput').value.trim();
  if (!sql) return alert('Please enter a SQL query.');

  const btn = document.getElementById('btnRunSql');
  const badge = document.getElementById('queryMetaBadge');
  btn.disabled = true;
  btn.innerHTML = `<i class="fa-solid fa-spinner fa-spin"></i> Executing...`;
  badge.textContent = "Executing on relational DB...";

  const startTime = performance.now();

  try {
    const res = await fetch('/api/execute-sql', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ query: sql })
    });

    const data = await res.json();
    const elapsed = Math.round(performance.now() - startTime);

    if (data.status === 'error') {
      badge.innerHTML = `<span class="text-rose-600 font-bold"><i class="fa-solid fa-triangle-exclamation"></i> Error</span>`;
      renderSqlError(data.message);
    } else {
      badge.innerHTML = `<span class="text-emerald-600 font-bold"><i class="fa-solid fa-check"></i> ${data.total_rows} rows</span> (${elapsed} ms)`;
      renderSqlTable(data.columns, data.rows);
    }
  } catch (err) {
    badge.innerHTML = `<span class="text-rose-600 font-bold">Network / Server Error</span>`;
    renderSqlError(err.message);
  } finally {
    btn.disabled = false;
    btn.innerHTML = `<i class="fa-solid fa-play"></i> Execute Query`;
  }
}

function renderSqlTable(columns, rows) {
  const thead = document.getElementById('sqlTableHeader');
  const tbody = document.getElementById('sqlTableBody');

  if (!columns || columns.length === 0) {
    thead.innerHTML = `<tr><th class="p-3">Result</th></tr>`;
    tbody.innerHTML = `<tr><td class="p-3 text-slate-500">Query returned 0 rows.</td></tr>`;
    return;
  }

  // Header
  let headerHtml = '<tr>';
  columns.forEach(col => {
    headerHtml += `<th class="p-2.5 px-3 whitespace-nowrap bg-slate-100 text-slate-800 border-b border-slate-200">${col}</th>`;
  });
  headerHtml += '</tr>';
  thead.innerHTML = headerHtml;

  // Body
  let bodyHtml = '';
  rows.forEach((row, idx) => {
    const bgClass = idx % 2 === 0 ? 'bg-white' : 'bg-slate-50/60';
    bodyHtml += `<tr class="${bgClass} hover:bg-indigo-50/50 transition">`;
    columns.forEach(col => {
      let val = row[col];
      if (val === null || val === undefined) val = '<span class="text-slate-300 italic">NULL</span>';
      bodyHtml += `<td class="p-2.5 px-3 whitespace-nowrap text-slate-700 font-mono text-[11px]">${val}</td>`;
    });
    bodyHtml += '</tr>';
  });
  tbody.innerHTML = bodyHtml;
}

function renderSqlError(message) {
  const thead = document.getElementById('sqlTableHeader');
  const tbody = document.getElementById('sqlTableBody');
  thead.innerHTML = `<tr><th class="p-3 text-rose-600">SQL Execution Error</th></tr>`;
  tbody.innerHTML = `<tr><td class="p-4 text-rose-600 font-mono text-xs bg-rose-50">${message}</td></tr>`;
}

// Export Current SQL Query to Excel (.xlsx)
async function exportCurrentSqlExcel() {
  const sql = document.getElementById('sqlInput').value.trim();
  if (!sql) return alert('Please enter a SQL query to export.');

  const btn = document.getElementById('btnExportExcel');
  btn.disabled = true;
  btn.innerHTML = `<i class="fa-solid fa-spinner fa-spin"></i> Generating Excel...`;

  try {
    const res = await fetch('/api/export-sql-excel', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ query: sql })
    });

    if (!res.ok) throw new Error('Excel export failed');
    const blob = await res.blob();
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `Uncodemy_Student_Analytics_${Date.now()}.xlsx`;
    document.body.appendChild(a);
    a.click();
    a.remove();
  } catch (err) {
    alert('Could not export Excel: ' + err.message);
  } finally {
    btn.disabled = false;
    btn.innerHTML = `<i class="fa-solid fa-file-excel"></i> Export Result to Excel (.xlsx)`;
  }
}

// ==============================================================================
// 3. STUDENT 360 & AT-RISK EXPLORER
// ==============================================================================
async function loadStudentExplorerData() {
  const sql = `
    SELECT 
        s.student_id,
        s.full_name,
        c.course_name,
        s.city,
        ROUND(COALESCE(att.att_avg, 0), 1) AS attendance_pct,
        ROUND(COALESCE(ass.score_avg, 0), 1) AS score_pct,
        s.status,
        COALESCE(p.company_name, '-') AS company_name,
        COALESCE(p.ctc_lpa, 0) AS ctc_lpa
    FROM students s
    JOIN batches b ON s.batch_id = b.batch_id
    JOIN courses c ON b.course_id = c.course_id
    LEFT JOIN (SELECT student_id, AVG(attendance_pct) AS att_avg FROM attendance GROUP BY student_id) att ON s.student_id = att.student_id
    LEFT JOIN (SELECT student_id, AVG(score_pct) AS score_avg FROM assessments GROUP BY student_id) ass ON s.student_id = ass.student_id
    LEFT JOIN placements p ON s.student_id = p.student_id
    LIMIT 250;
  `;

  try {
    const res = await fetch('/api/execute-sql', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ query: sql })
    });
    const data = await res.json();
    if (data.status === 'success') {
      allStudentsMasterData = data.rows;
      renderStudentDirectoryTable(allStudentsMasterData);
    }
  } catch (err) {
    console.error('Error loading student explorer:', err);
  }
}

function renderStudentDirectoryTable(students) {
  const tbody = document.getElementById('studentTableBody');
  if (!students || students.length === 0) {
    tbody.innerHTML = `<tr><td colspan="9" class="p-4 text-center text-slate-400">No matching student records found.</td></tr>`;
    return;
  }

  let html = '';
  students.forEach((stu, idx) => {
    // Status Badge
    let statusBadge = '';
    if (stu.status === 'Placed') statusBadge = '<span class="badge badge-success"><i class="fa-solid fa-check"></i> Placed</span>';
    else if (stu.status === 'At-Risk') statusBadge = '<span class="badge badge-danger"><i class="fa-solid fa-triangle-exclamation"></i> At-Risk</span>';
    else if (stu.status === 'Active') statusBadge = '<span class="badge badge-info"><i class="fa-solid fa-book-open"></i> Active</span>';
    else if (stu.status === 'Completed') statusBadge = '<span class="badge badge-purple"><i class="fa-solid fa-graduation-cap"></i> Completed</span>';
    else statusBadge = '<span class="badge badge-warning">Dropped</span>';

    // Attendance Color
    const attVal = parseFloat(stu.attendance_pct);
    const attClass = attVal < 70 ? 'text-rose-600 font-bold' : (attVal >= 85 ? 'text-emerald-600 font-bold' : 'text-slate-700 font-semibold');

    // Score Color
    const scoreVal = parseFloat(stu.score_pct);
    const scoreClass = scoreVal < 60 ? 'text-rose-600 font-bold' : (scoreVal >= 80 ? 'text-emerald-600 font-bold' : 'text-slate-700 font-semibold');

    // CTC Display
    const ctcDisplay = stu.ctc_lpa > 0 ? `<span class="font-bold text-slate-900">${stu.company_name}</span> <span class="text-emerald-600 font-mono text-[11px]">(&#8377;${stu.ctc_lpa} LPA)</span>` : '<span class="text-slate-400">-</span>';

    // Intervention Action
    let interventionAction = '<span class="text-slate-400 text-[11px]">Normal</span>';
    if (stu.status === 'At-Risk' || attVal < 70 || scoreVal < 60) {
      interventionAction = `<span class="text-rose-600 font-semibold text-[11px]"><i class="fa-solid fa-phone"></i> Mentor Alert</span>`;
    }

    const rowBg = stu.status === 'At-Risk' ? 'bg-rose-50/40 hover:bg-rose-50' : (idx % 2 === 0 ? 'bg-white hover:bg-slate-50' : 'bg-slate-50/50 hover:bg-slate-50');

    html += `
      <tr class="${rowBg} transition text-slate-700">
        <td class="p-3 font-mono font-bold text-indigo-600">${stu.student_id}</td>
        <td class="p-3 font-medium text-slate-900">${stu.full_name}</td>
        <td class="p-3">${stu.course_name}</td>
        <td class="p-3 text-slate-500">${stu.city}</td>
        <td class="p-3 text-center ${attClass}">${stu.attendance_pct}%</td>
        <td class="p-3 text-center ${scoreClass}">${stu.score_pct}%</td>
        <td class="p-3">${statusBadge}</td>
        <td class="p-3">${ctcDisplay}</td>
        <td class="p-3 text-center">${interventionAction}</td>
      </tr>
    `;
  });

  tbody.innerHTML = html;
}

function filterStudentDirectory() {
  const search = document.getElementById('studentSearchInput').value.toLowerCase();
  const statusFilter = document.getElementById('studentStatusFilter').value;

  const filtered = allStudentsMasterData.filter(stu => {
    const matchesSearch = stu.full_name.toLowerCase().includes(search) ||
                          stu.student_id.toLowerCase().includes(search) ||
                          stu.course_name.toLowerCase().includes(search) ||
                          stu.city.toLowerCase().includes(search);
    const matchesStatus = statusFilter === 'All' || stu.status === statusFilter;
    return matchesSearch && matchesStatus;
  });

  renderStudentDirectoryTable(filtered);
}

// ==============================================================================
// 4. UI TABS & UTILITIES
// ==============================================================================
function switchAppTab(tabId) {
  ['tab-sql', 'tab-students', 'tab-portfolio'].forEach(t => {
    document.getElementById(`content-${t}`).classList.add('hidden');
    document.getElementById(`tabBtn-${t.replace('tab-', '')}`).classList.remove('active');
  });

  document.getElementById(`content-${tabId}`).classList.remove('hidden');
  document.getElementById(`tabBtn-${tabId.replace('tab-', '')}`).classList.add('active');

  if (tabId === 'tab-sql' && document.getElementById('sqlTableBody').children.length <= 1) {
    runCustomSql();
  }
}

function copyElevatorPitch() {
  const pitchText = document.getElementById('elevatorPitchText').innerText;
  navigator.clipboard.writeText(pitchText).then(() => {
    alert('Elevator pitch copied to clipboard! Ready for your interview preparation.');
  });
}
