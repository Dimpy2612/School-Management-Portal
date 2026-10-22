<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="java.util.List" %>
<%@ page import="com.school.dao.ClassDAO" %>
<%@ page import="com.school.model.SchoolClass" %>

<%
    if (session == null || session.getAttribute("userId") == null
            || !"ADMIN".equals(session.getAttribute("role"))) {
        response.sendRedirect(request.getContextPath() + "/login.html");
        return;
    }

    int schoolId = Integer.parseInt(session.getAttribute("schoolId").toString());

    String success = request.getParameter("success");
    String error   = request.getParameter("error");
    String search  = request.getParameter("search");

    ClassDAO classDAO = new ClassDAO();
    List<SchoolClass> classes = classDAO.getAllClasses(schoolId, search);

    int activeClasses   = classDAO.getCountByStatus(schoolId, "ACTIVE");
    int inactiveClasses = classDAO.getCountByStatus(schoolId, "INACTIVE");
    int totalSections   = classDAO.getTotalSections(schoolId);
%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Classes | School Management Portal</title>

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
            display:flex; align-items:center; justify-content:center;
            font-size:21px; box-shadow:0 5px 15px rgba(0,0,0,0.12); }
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

        .class-icon { width:43px; height:43px; border-radius:12px;
            background:linear-gradient(135deg,#dbeafe,#bfdbfe); color:#1d4ed8;
            display:flex; align-items:center; justify-content:center;
            font-size:17px; font-weight:700; }

        .badge-active { background:#dcfce7; color:#15803d;
            padding:6px 12px; border-radius:20px;
            font-size:12px; font-weight:650; display:inline-block; }
        .badge-inactive { background:#fee2e2; color:#b91c1c;
            padding:6px 12px; border-radius:20px;
            font-size:12px; font-weight:650; display:inline-block; }

        .alert { border:none; border-radius:12px;
            box-shadow:0 5px 15px rgba(22,163,74,0.08); }

        .action-btn { width:34px; height:34px; padding:0;
            display:inline-flex; align-items:center; justify-content:center;
            border-radius:9px; font-size:14px; margin:0 2px; transition:0.15s; }
        .action-btn:hover { transform:translateY(-2px); }

        @media (max-width:991px) {
            .sidebar { width:220px; } .main { margin-left:220px; padding:20px; } }
        @media (max-width:768px) {
            .sidebar { position:relative; width:100%; min-height:auto; }
            .main { margin-left:0; padding:15px; } }
    </style>
</head>

<body>

<div class="sidebar">
    <div class="brand">
        <div class="brand-icon"><i class="bi bi-mortarboard-fill"></i></div>
        <div class="brand-text"><h5>School Portal</h5><small>Administration</small></div>
    </div>
    <div class="menu-title">Main Menu</div>
    <a href="dashboard.jsp"><i class="bi bi-grid"></i> Dashboard</a>
    <a href="students.jsp"><i class="bi bi-people"></i> Students</a>
    <a href="teachers.jsp"><i class="bi bi-person-badge"></i> Teachers</a>
    <a href="classes.jsp" class="active"><i class="bi bi-building"></i> Classes</a>
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
                <h2 class="page-title">Classes</h2>
                <p class="page-subtitle">Manage all classes and sections of your school</p>
            </div>
            <a href="add-class.jsp" class="btn btn-primary add-btn">
                <i class="bi bi-plus-lg me-1"></i> Add Class
            </a>
        </div>
    </div>

    <% if ("added".equals(success)) { %>
        <div class="alert alert-success alert-dismissible fade show">
            <i class="bi bi-check-circle-fill me-2"></i> Class added successfully.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    <% } %>
    <% if ("updated".equals(success)) { %>
        <div class="alert alert-success alert-dismissible fade show">
            <i class="bi bi-check-circle-fill me-2"></i> Class updated successfully.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    <% } %>
    <% if ("deleted".equals(success)) { %>
        <div class="alert alert-success alert-dismissible fade show">
            <i class="bi bi-check-circle-fill me-2"></i> Class marked as INACTIVE.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    <% } %>
    <% if ("failed".equals(error)) { %>
        <div class="alert alert-danger alert-dismissible fade show">
            <i class="bi bi-exclamation-triangle-fill me-2"></i> Operation failed. Try again.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    <% } %>

    <div class="row g-4 mb-4">
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-icon blue"><i class="bi bi-building"></i></div>
                <div class="stat-number"><%= classes.size() %></div>
                <div class="stat-label">Matching Filter</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-icon green"><i class="bi bi-check-circle-fill"></i></div>
                <div class="stat-number"><%= activeClasses %></div>
                <div class="stat-label">Active Classes</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-icon orange"><i class="bi bi-x-circle-fill"></i></div>
                <div class="stat-number"><%= inactiveClasses %></div>
                <div class="stat-label">Inactive Classes</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-icon purple"><i class="bi bi-grid-3x3-gap-fill"></i></div>
                <div class="stat-number"><%= totalSections %></div>
                <div class="stat-label">Total Sections</div>
            </div>
        </div>
    </div>

    <div class="filter-card mb-4">
        <form method="get" action="classes.jsp" class="row g-3 align-items-end">
            <div class="col-md-8">
                <label class="form-label fw-semibold" style="font-size:13px;">Search</label>
                <input type="text" name="search" class="form-control"
                       placeholder="Class name"
                       value="<%= search == null ? "" : search %>">
            </div>
            <div class="col-md-4 d-flex gap-2">
                <button type="submit" class="btn btn-primary w-100">
                    <i class="bi bi-funnel me-1"></i> Filter
                </button>
                <a href="classes.jsp" class="btn btn-outline-secondary">
                    <i class="bi bi-x-lg"></i>
                </a>
            </div>
        </form>
    </div>

    <div class="table-card">

        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h5><i class="bi bi-building me-2"></i> Class List</h5>
                <small class="text-secondary">All classes for your school</small>
            </div>
            <span class="badge bg-light text-dark"><%= classes.size() %> Classes</span>
        </div>

        <div class="table-responsive">
            <table class="table table-hover align-middle">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Class</th>
                        <th>Order</th>
                        <th>Sections</th>
                        <th>Students</th>
                        <th>Status</th>
                        <th class="text-end">Actions</th>
                    </tr>
                </thead>
                <tbody>

                <%
                    int counter = 1;
                    if (classes.isEmpty()) {
                %>
                    <tr>
                        <td colspan="7" class="text-center py-5">
                            <div class="text-secondary">
                                <i class="bi bi-building" style="font-size:40px;"></i>
                                <div class="mt-2">No classes found.</div>
                                <div class="small">Click "Add Class" to add one.</div>
                            </div>
                        </td>
                    </tr>
                <%
                    } else {
                        for (SchoolClass c : classes) {
                            String st = c.getStatus() == null ? "ACTIVE" : c.getStatus();
                            String badgeClass = "ACTIVE".equalsIgnoreCase(st)
                                              ? "badge-active" : "badge-inactive";
                %>
                    <tr>
                        <td><%= counter++ %></td>

                        <td>
                            <div class="d-flex align-items-center gap-3">
                                <div class="class-icon"><%= c.getClassName().charAt(0) %></div>
                                <div>
                                    <div class="fw-semibold"><%= c.getClassName() %></div>
                                    <small class="text-secondary">Class</small>
                                </div>
                            </div>
                        </td>

                        <td><%= c.getClassOrder() %></td>
                        <td><span class="fw-semibold"><%= c.getSectionCount() %></span></td>
                        <td><span class="fw-semibold"><%= c.getStudentCount() %></span></td>

                        <td><span class="<%= badgeClass %>"><%= st %></span></td>

                        <td class="text-end">
                            <a href="sections.jsp?classId=<%= c.getClassId() %>"
                               class="btn btn-outline-info action-btn"
                               title="Manage Sections">
                                <i class="bi bi-grid-3x3-gap"></i>
                            </a>
                            <a href="edit-class.jsp?id=<%= c.getClassId() %>"
                               class="btn btn-outline-warning action-btn"
                               title="Edit">
                                <i class="bi bi-pencil"></i>
                            </a>
                            <button type="button"
                                    class="btn btn-outline-danger action-btn"
                                    title="Delete"
                                    onclick="confirmDelete(<%= c.getClassId() %>, '<%= c.getClassName().replace("'","\\'") %>')">
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

<form id="deleteForm" action="<%= request.getContextPath() %>/DeleteClassServlet"
      method="post" style="display:none;">
    <input type="hidden" name="classId" id="deleteClassId">
</form>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.bundle.min.js"></script>
<script>
function confirmDelete(classId, className) {
    if (confirm("Mark class \"" + className + "\" as INACTIVE?\n\nReversible via Edit.")) {
        document.getElementById("deleteClassId").value = classId;
        document.getElementById("deleteForm").submit();
    }
}
</script>

</body>
</html>
