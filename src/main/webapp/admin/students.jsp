<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="com.school.dao.StudentDAO" %>
<%@ page import="com.school.dao.ClassSectionDAO" %>
<%@ page import="com.school.model.Student" %>

<%
    // AUTH CHECK
    if (session == null ||
        session.getAttribute("userId") == null ||
        !"ADMIN".equals(session.getAttribute("role"))) {
        response.sendRedirect(request.getContextPath() + "/login.html");
        return;
    }

    Object schoolIdObj = session.getAttribute("schoolId");
    int schoolId = (schoolIdObj != null)
                 ? Integer.parseInt(schoolIdObj.toString())
                 : 0;

    String success = request.getParameter("success");
    String error   = request.getParameter("error");

    // Search + filter params
    String search    = request.getParameter("search");
    String classIdS  = request.getParameter("classId");
    String sectionIdS= request.getParameter("sectionId");

    Long classIdFilter = null;
    Long sectionIdFilter = null;

    try { if (classIdS != null && !classIdS.isEmpty()) classIdFilter = Long.parseLong(classIdS); }
    catch (Exception ignore) { }

    try { if (sectionIdS != null && !sectionIdS.isEmpty()) sectionIdFilter = Long.parseLong(sectionIdS); }
    catch (Exception ignore) { }

    StudentDAO studentDAO = new StudentDAO();
    ClassSectionDAO csDAO = new ClassSectionDAO();

    List<Student> students = studentDAO.getAllStudents(
            schoolId, search, classIdFilter, sectionIdFilter);

    int totalStudents    = studentDAO.getCountByStatus(schoolId, "ACTIVE")
                         + studentDAO.getCountByStatus(schoolId, "INACTIVE")
                         + studentDAO.getCountByStatus(schoolId, "PASSED_OUT")
                         + studentDAO.getCountByStatus(schoolId, "TRANSFERRED");
    int activeStudents   = studentDAO.getCountByStatus(schoolId, "ACTIVE");
    int inactiveStudents = studentDAO.getCountByStatus(schoolId, "INACTIVE");

    Map<Long, String> classes = csDAO.getClasses(schoolId);

    Map<Long, String> sections = new java.util.LinkedHashMap<>();
    if (classIdFilter != null && classIdFilter > 0) {
        sections = csDAO.getSections(classIdFilter);
    }
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Students | School Management Portal</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

    <style>
        * { box-sizing: border-box; }
        body { margin:0; font-family:"Inter","Segoe UI",sans-serif; background:#f4f7fb; color:#1e293b; }

        .sidebar { width:250px; min-height:100vh; position:fixed; left:0; top:0;
            background:linear-gradient(180deg,#2563eb 0%,#1d4ed8 55%,#1e40af 100%);
            color:white; padding:22px 15px; z-index:1000;
            box-shadow:5px 0 20px rgba(37,99,235,0.15); }

        .brand { display:flex; align-items:center; gap:12px; padding:4px 10px 28px; }
        .brand-icon { width:45px; height:45px; border-radius:13px;
            background:rgba(255,255,255,0.18); border:1px solid rgba(255,255,255,0.25);
            display:flex; align-items:center; justify-content:center; font-size:21px;
            box-shadow:0 5px 15px rgba(0,0,0,0.12); }
        .brand-text h5 { margin:0; font-weight:700; font-size:17px; }
        .brand-text small { color:rgba(255,255,255,0.72); font-size:12px; }

        .menu-title { font-size:10px; text-transform:uppercase;
            color:rgba(255,255,255,0.55); letter-spacing:1.2px;
            padding:10px 12px; margin-top:3px; }

        .sidebar a { display:flex; align-items:center; gap:13px;
            padding:11px 13px; margin:4px 0; border-radius:11px;
            color:rgba(255,255,255,0.78); text-decoration:none;
            font-size:14px; font-weight:500; transition:all 0.2s ease; }
        .sidebar a i { font-size:17px; width:20px; text-align:center; }
        .sidebar a:hover { background:rgba(255,255,255,0.15); color:white; transform:translateX(3px); }
        .sidebar a.active { background:white; color:#1557c0; font-weight:650;
            box-shadow:0 6px 18px rgba(0,0,0,0.12); }
        .sidebar a.active i { color:#2563eb; }
        .sidebar hr { border:0; border-top:1px solid rgba(255,255,255,0.18); margin:18px 5px; }
        .sidebar a[href*="Logout"] { color:#ffe4e6; }
        .sidebar a[href*="Logout"]:hover { background:rgba(239,68,68,0.18); color:white; }

        .main { margin-left:250px; min-height:100vh; padding:30px; }

        .top-card { background:white; border-radius:18px; padding:24px 26px;
            border:1px solid #edf1f7; box-shadow:0 5px 20px rgba(15,23,42,0.06); }
        .page-title { font-weight:750; margin-bottom:4px; color:#172033; }
        .page-subtitle { color:#64748b; margin:0; font-size:14px; }

        .add-btn { border:none; border-radius:11px; padding:11px 18px;
            font-weight:600; background:linear-gradient(135deg,#2563eb,#1d4ed8);
            box-shadow:0 6px 15px rgba(37,99,235,0.25); transition:0.2s; }
        .add-btn:hover { transform:translateY(-2px);
            box-shadow:0 9px 20px rgba(37,99,235,0.30); }

        .stat-card { background:white; border-radius:17px; padding:21px;
            border:1px solid #edf1f7; box-shadow:0 5px 18px rgba(15,23,42,0.05);
            height:100%; transition:all 0.2s ease; }
        .stat-card:hover { transform:translateY(-4px);
            box-shadow:0 10px 25px rgba(15,23,42,0.09); }

        .stat-icon { width:48px; height:48px; border-radius:13px;
            display:flex; align-items:center; justify-content:center; font-size:20px; }
        .stat-icon.blue { background:#dbeafe; color:#2563eb; }
        .stat-icon.green { background:#dcfce7; color:#16a34a; }
        .stat-icon.orange { background:#ffedd5; color:#ea580c; }
        .stat-icon.purple { background:#ede9fe; color:#7c3aed; }

        .stat-number { font-size:27px; font-weight:750; margin-top:12px; color:#172033; }
        .stat-label { color:#64748b; font-size:13px; margin-top:2px; }

        .filter-card { background:white; border-radius:16px; padding:20px 22px;
            border:1px solid #edf1f7; box-shadow:0 5px 15px rgba(15,23,42,0.04); }

        .table-card { background:white; border-radius:18px; padding:25px;
            border:1px solid #edf1f7; box-shadow:0 5px 20px rgba(15,23,42,0.06); }
        .table-card h5 { font-weight:700; margin:0; color:#172033; }
        .table-card h5 i { color:#2563eb; }
        .table-card .badge.bg-light { background:#eff6ff !important;
            color:#2563eb !important; padding:8px 13px;
            border-radius:20px; font-weight:600; }

        table { margin-bottom:0 !important; }
        thead th { color:#475569; font-size:12px; font-weight:700;
            background:#f8fafc !important; white-space:nowrap;
            border-bottom:1px solid #e2e8f0; }
        tbody td { font-size:14px; color:#334155;
            padding-top:15px !important; padding-bottom:15px !important;
            vertical-align:middle; border-color:#f1f5f9; }
        tbody tr { transition:0.15s; }
        tbody tr:hover { background:#f8fbff; }

        .student-icon { width:43px; height:43px; border-radius:50%;
            background:linear-gradient(135deg,#dbeafe,#bfdbfe); color:#1d4ed8;
            display:flex; align-items:center; justify-content:center;
            font-size:17px; font-weight:700; border:2px solid #eff6ff; }

        .badge-active { background:#dcfce7; color:#15803d;
            padding:6px 12px; border-radius:20px;
            font-size:12px; font-weight:650; display:inline-block; }
        .badge-inactive { background:#fee2e2; color:#b91c1c;
            padding:6px 12px; border-radius:20px;
            font-size:12px; font-weight:650; display:inline-block; }
        .badge-other { background:#fef3c7; color:#92400e;
            padding:6px 12px; border-radius:20px;
            font-size:12px; font-weight:650; display:inline-block; }

        .alert { border:none; border-radius:12px;
            box-shadow:0 5px 15px rgba(22,163,74,0.08); }

        .action-btn { width:34px; height:34px; padding:0;
            display:inline-flex; align-items:center; justify-content:center;
            border-radius:9px; font-size:14px; margin:0 2px; transition:0.15s; }
        .action-btn:hover { transform:translateY(-2px); }

        ::-webkit-scrollbar { width:7px; height:7px; }
        ::-webkit-scrollbar-track { background:#f1f5f9; }
        ::-webkit-scrollbar-thumb { background:#cbd5e1; border-radius:10px; }
        ::-webkit-scrollbar-thumb:hover { background:#94a3b8; }

        @media (max-width: 991px) {
            .sidebar { width:220px; }
            .main { margin-left:220px; padding:20px; }
        }
        @media (max-width: 768px) {
            .sidebar { position:relative; width:100%; min-height:auto; }
            .main { margin-left:0; padding:15px; }
            .top-card { padding:20px; }
        }
    </style>
</head>

<body>

<div class="sidebar">
    <div class="brand">
        <div class="brand-icon"><i class="bi bi-mortarboard-fill"></i></div>
        <div class="brand-text">
            <h5>School Portal</h5>
            <small>Administration</small>
        </div>
    </div>

    <div class="menu-title">Main Menu</div>
    <a href="dashboard.jsp"><i class="bi bi-grid"></i> Dashboard</a>
    <a href="students.jsp" class="active"><i class="bi bi-people"></i> Students</a>
    <a href="teachers.jsp"><i class="bi bi-person-badge"></i> Teachers</a>
    <a href="classes.jsp"><i class="bi bi-building"></i> Classes</a>
    <a href="subjects.jsp"><i class="bi bi-book"></i> Subjects</a>
    <a href="attendance.jsp"><i class="bi bi-calendar-check"></i> Attendance</a>
    <a href="exams.jsp"><i class="bi bi-file-earmark-text"></i> Exams</a>
    <a href="fees.jsp"><i class="bi bi-cash-stack"></i> Fees</a>
    <a href="notices.jsp"><i class="bi bi-megaphone"></i> Notices</a>
    <hr>
    <a href="LogoutServlet"><i class="bi bi-box-arrow-right"></i> Logout</a>
</div>


<div class="main">

    <div class="top-card mb-4">
        <div class="d-flex justify-content-between align-items-center">
            <div>
                <h2 class="page-title">Students</h2>
                <p class="page-subtitle">Manage all students of your school</p>
            </div>
            <a href="add-student.jsp" class="btn btn-primary add-btn">
                <i class="bi bi-plus-lg me-1"></i> Add Student
            </a>
        </div>
    </div>

    <!-- SUCCESS -->
    <% if ("added".equals(success)) { %>
        <div class="alert alert-success alert-dismissible fade show">
            <i class="bi bi-check-circle-fill me-2"></i> Student added successfully.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    <% } %>
    <% if ("updated".equals(success)) { %>
        <div class="alert alert-success alert-dismissible fade show">
            <i class="bi bi-check-circle-fill me-2"></i> Student updated successfully.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    <% } %>
    <% if ("deleted".equals(success)) { %>
        <div class="alert alert-success alert-dismissible fade show">
            <i class="bi bi-check-circle-fill me-2"></i> Student marked as INACTIVE successfully.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    <% } %>
    <% if ("failed".equals(error)) { %>
        <div class="alert alert-danger alert-dismissible fade show">
            <i class="bi bi-exclamation-triangle-fill me-2"></i> Operation failed. Please try again.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    <% } %>

    <!-- STAT CARDS -->
    <div class="row g-4 mb-4">

        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-icon blue"><i class="bi bi-people-fill"></i></div>
                <div class="stat-number"><%= totalStudents %></div>
                <div class="stat-label">Total Students</div>
            </div>
        </div>

        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-icon green"><i class="bi bi-person-check-fill"></i></div>
                <div class="stat-number"><%= activeStudents %></div>
                <div class="stat-label">Active Students</div>
            </div>
        </div>

        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-icon orange"><i class="bi bi-person-x-fill"></i></div>
                <div class="stat-number"><%= inactiveStudents %></div>
                <div class="stat-label">Inactive Students</div>
            </div>
        </div>

        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-icon purple"><i class="bi bi-search"></i></div>
                <div class="stat-number"><%= students.size() %></div>
                <div class="stat-label">Matching Filter</div>
            </div>
        </div>

    </div>

    <!-- FILTER / SEARCH -->
    <div class="filter-card mb-4">
        <form method="get" action="students.jsp" class="row g-3 align-items-end">

            <div class="col-md-4">
                <label class="form-label fw-semibold" style="font-size:13px;">Search</label>
                <input type="text" name="search" class="form-control"
                       placeholder="Name, admission no, email, username"
                       value="<%= search == null ? "" : search %>">
            </div>

            <div class="col-md-3">
                <label class="form-label fw-semibold" style="font-size:13px;">Class</label>
                <select name="classId" class="form-select">
                    <option value="">All Classes</option>
                    <% for (Map.Entry<Long, String> c : classes.entrySet()) {
                        String sel = (classIdFilter != null && classIdFilter == c.getKey()) ? "selected" : "";
                    %>
                        <option value="<%= c.getKey() %>" <%= sel %>><%= c.getValue() %></option>
                    <% } %>
                </select>
            </div>

            <div class="col-md-3">
                <label class="form-label fw-semibold" style="font-size:13px;">Section</label>
                <select name="sectionId" class="form-select">
                    <option value="">All Sections</option>
                    <% for (Map.Entry<Long, String> s : sections.entrySet()) {
                        String sel = (sectionIdFilter != null && sectionIdFilter == s.getKey()) ? "selected" : "";
                    %>
                        <option value="<%= s.getKey() %>" <%= sel %>><%= s.getValue() %></option>
                    <% } %>
                </select>
            </div>

            <div class="col-md-2 d-flex gap-2">
                <button type="submit" class="btn btn-primary w-100">
                    <i class="bi bi-funnel me-1"></i> Filter
                </button>
                <a href="students.jsp" class="btn btn-outline-secondary">
                    <i class="bi bi-x-lg"></i>
                </a>
            </div>

        </form>
    </div>

    <!-- STUDENT TABLE -->
    <div class="table-card">

        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h5><i class="bi bi-people me-2"></i> Student List</h5>
                <small class="text-secondary">All students matching your criteria</small>
            </div>
            <span class="badge bg-light text-dark"><%= students.size() %> Students</span>
        </div>

        <div class="table-responsive">
            <table class="table table-hover align-middle">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Student</th>
                        <th>Admission No</th>
                        <th>Class</th>
                        <th>Section</th>
                        <th>Roll No</th>
                        <th>Email</th>
                        <th>Status</th>
                        <th class="text-end">Actions</th>
                    </tr>
                </thead>
                <tbody>

                <%
                    int counter = 1;
                    if (students.isEmpty()) {
                %>
                    <tr>
                        <td colspan="9" class="text-center py-5">
                            <div class="text-secondary">
                                <i class="bi bi-person-x" style="font-size:40px;"></i>
                                <div class="mt-2">No students found.</div>
                                <div class="small">Try changing filters or click "Add Student".</div>
                            </div>
                        </td>
                    </tr>
                <%
                    } else {
                        for (Student s : students) {
                            String fullName = (s.getFirstName() == null ? "" : s.getFirstName());
                            if (s.getLastName() != null && !s.getLastName().trim().isEmpty()) {
                                fullName += " " + s.getLastName();
                            }
                            String firstLetter = fullName.isEmpty()
                                               ? "S"
                                               : fullName.substring(0, 1).toUpperCase();
                            String st = s.getStatus() == null ? "ACTIVE" : s.getStatus();
                            String statusClass =
                                "ACTIVE".equalsIgnoreCase(st) ? "badge-active" :
                                "INACTIVE".equalsIgnoreCase(st) ? "badge-inactive" : "badge-other";
                %>
                    <tr>
                        <td><%= counter++ %></td>

                        <td>
                            <div class="d-flex align-items-center gap-3">
                                <div class="student-icon"><%= firstLetter %></div>
                                <div>
                                    <div class="fw-semibold"><%= fullName %></div>
                                    <small class="text-secondary">Student</small>
                                </div>
                            </div>
                        </td>

                        <td><span class="fw-semibold"><%= s.getAdmissionNo() %></span></td>
                        <td><%= s.getClassName() == null ? "-" : s.getClassName() %></td>
                        <td><%= s.getSectionName() == null ? "-" : s.getSectionName() %></td>
                        <td><%= s.getRollNumber() == null ? "-" : s.getRollNumber() %></td>
                        <td><%= s.getEmail() %></td>

                        <td>
                            <span class="<%= statusClass %>"><%= st %></span>
                        </td>

                        <td class="text-end">
                            <a href="view-student.jsp?id=<%= s.getStudentId() %>"
                               class="btn btn-outline-primary action-btn" title="View">
                                <i class="bi bi-eye"></i>
                            </a>
                            <a href="edit-student.jsp?id=<%= s.getStudentId() %>"
                               class="btn btn-outline-warning action-btn" title="Edit">
                                <i class="bi bi-pencil"></i>
                            </a>
                            <button type="button"
                                    class="btn btn-outline-danger action-btn"
                                    title="Delete"
                                    onclick="confirmDelete(<%= s.getStudentId() %>, '<%= fullName.replace("'", "\\'") %>')">
                                <i class="bi bi-trash"></i>
                            </button>
                        </td>
                    </tr>
                <%
                        }
                    }
                %>

                </tbody>
            </table>
        </div>
    </div>

</div>

<form id="deleteForm"
      action="<%= request.getContextPath() %>/DeleteStudentServlet"
      method="post" style="display:none;">
    <input type="hidden" name="studentId" id="deleteStudentId">
</form>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.bundle.min.js"></script>
<script>
function confirmDelete(studentId, studentName) {
    var ok = confirm(
        "Mark this student as INACTIVE?\n\n" +
        studentName +
        "\n\nThis is reversible — you can reactivate the student later."
    );
    if (ok) {
        document.getElementById("deleteStudentId").value = studentId;
        document.getElementById("deleteForm").submit();
    }
}
</script>

</body>
</html>
