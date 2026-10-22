<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="java.util.List" %>
<%@ page import="com.school.dao.SectionDAO" %>
<%@ page import="com.school.dao.ClassDAO" %>
<%@ page import="com.school.model.Section" %>
<%@ page import="com.school.model.SchoolClass" %>

<%
    if (session == null || session.getAttribute("userId") == null
            || !"ADMIN".equals(session.getAttribute("role"))) {
        response.sendRedirect(request.getContextPath() + "/login.html");
        return;
    }

    int schoolId = Integer.parseInt(session.getAttribute("schoolId").toString());

    String idText = request.getParameter("classId");
    if (idText == null || idText.trim().isEmpty()) {
        response.sendRedirect("classes.jsp");
        return;
    }

    long classId = Long.parseLong(idText);

    ClassDAO classDAO = new ClassDAO();
    SchoolClass c = classDAO.getClassById(classId, schoolId);
    if (c == null) {
        response.sendRedirect("classes.jsp");
        return;
    }

    SectionDAO sectionDAO = new SectionDAO();
    List<Section> sections = sectionDAO.getSectionsByClass(classId, schoolId);

    String success = request.getParameter("success");
    String error   = request.getParameter("error");
%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sections | <%= c.getClassName() %></title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

    <style>
        * { box-sizing:border-box; }
        body { margin:0; font-family:"Inter","Segoe UI",sans-serif;
            background:#f4f7fb; color:#1e293b; }
        .sidebar { width:250px; min-height:100vh; position:fixed; left:0; top:0;
            background:linear-gradient(180deg,#2563eb 0%,#1d4ed8 55%,#1e40af 100%);
            color:white; padding:22px 15px; z-index:1000;
            box-shadow:5px 0 20px rgba(37,99,235,0.15); }
        .brand { display:flex; align-items:center; gap:12px; padding:4px 10px 28px; }
        .brand-icon { width:45px; height:45px; border-radius:13px;
            background:rgba(255,255,255,0.18); border:1px solid rgba(255,255,255,0.25);
            display:flex; align-items:center; justify-content:center; font-size:21px; }
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
        .sidebar a:hover { background:rgba(255,255,255,0.15); color:white; }
        .sidebar a.active { background:white; color:#1557c0; font-weight:650; }
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
            font-weight:600; background:linear-gradient(135deg,#2563eb,#1d4ed8); }
        .table-card { background:white; border-radius:18px; padding:25px;
            border:1px solid #edf1f7; box-shadow:0 5px 20px rgba(15,23,42,0.06); }
        .table-card h5 { font-weight:700; margin:0; color:#172033; }
        .table-card h5 i { color:#2563eb; }
        .table-card .badge.bg-light { background:#eff6ff !important;
            color:#2563eb !important; padding:8px 13px;
            border-radius:20px; font-weight:600; }
        table { margin-bottom:0 !important; }
        thead th { color:#475569; font-size:12px; font-weight:700;
            background:#f8fafc !important; border-bottom:1px solid #e2e8f0; }
        tbody td { font-size:14px; color:#334155; vertical-align:middle;
            padding-top:15px !important; padding-bottom:15px !important;
            border-color:#f1f5f9; }
        tbody tr:hover { background:#f8fbff; }
        .section-icon { width:43px; height:43px; border-radius:12px;
            background:linear-gradient(135deg,#e0e7ff,#c7d2fe); color:#4338ca;
            display:flex; align-items:center; justify-content:center;
            font-size:17px; font-weight:700; }
        .badge-active { background:#dcfce7; color:#15803d;
            padding:6px 12px; border-radius:20px;
            font-size:12px; font-weight:650; display:inline-block; }
        .badge-inactive { background:#fee2e2; color:#b91c1c;
            padding:6px 12px; border-radius:20px;
            font-size:12px; font-weight:650; display:inline-block; }
        .action-btn { width:34px; height:34px; padding:0;
            display:inline-flex; align-items:center; justify-content:center;
            border-radius:9px; font-size:14px; margin:0 2px; transition:0.15s; }
        .action-btn:hover { transform:translateY(-2px); }
        .alert { border:none; border-radius:12px; }
        .back-btn { border-radius:10px; padding:9px 17px; font-weight:600; }
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
                <h2 class="page-title"><%= c.getClassName() %> — Sections</h2>
                <p class="page-subtitle">Manage sections for this class</p>
            </div>
            <div class="d-flex gap-2">
                <a href="classes.jsp" class="btn btn-outline-secondary back-btn">
                    <i class="bi bi-arrow-left me-1"></i> All Classes
                </a>
                <a href="add-section.jsp?classId=<%= classId %>" class="btn btn-primary add-btn">
                    <i class="bi bi-plus-lg me-1"></i> Add Section
                </a>
            </div>
        </div>
    </div>

    <% if ("added".equals(success)) { %>
        <div class="alert alert-success alert-dismissible fade show">
            <i class="bi bi-check-circle-fill me-2"></i> Section added successfully.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    <% } %>
    <% if ("updated".equals(success)) { %>
        <div class="alert alert-success alert-dismissible fade show">
            <i class="bi bi-check-circle-fill me-2"></i> Section updated successfully.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    <% } %>
    <% if ("deleted".equals(success)) { %>
        <div class="alert alert-success alert-dismissible fade show">
            <i class="bi bi-check-circle-fill me-2"></i> Section marked as INACTIVE.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    <% } %>
    <% if ("hasStudents".equals(error)) { %>
        <div class="alert alert-danger alert-dismissible fade show">
            <i class="bi bi-exclamation-triangle-fill me-2"></i>
            Cannot delete — students are enrolled in this section.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    <% } %>
    <% if ("failed".equals(error)) { %>
        <div class="alert alert-danger alert-dismissible fade show">
            <i class="bi bi-exclamation-triangle-fill me-2"></i> Operation failed. Try again.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    <% } %>

    <div class="table-card">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h5><i class="bi bi-grid-3x3-gap me-2"></i> Section List</h5>
                <small class="text-secondary">All sections in <%= c.getClassName() %></small>
            </div>
            <span class="badge bg-light text-dark"><%= sections.size() %> Sections</span>
        </div>

        <div class="table-responsive">
            <table class="table table-hover align-middle">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Section</th>
                        <th>Room</th>
                        <th>Class Teacher</th>
                        <th>Status</th>
                        <th class="text-end">Actions</th>
                    </tr>
                </thead>
                <tbody>

                <%
                    if (sections.isEmpty()) {
                %>
                    <tr>
                        <td colspan="6" class="text-center py-5">
                            <div class="text-secondary">
                                <i class="bi bi-grid-3x3-gap" style="font-size:40px;"></i>
                                <div class="mt-2">No sections yet.</div>
                                <div class="small">Click "Add Section" to create one.</div>
                            </div>
                        </td>
                    </tr>
                <%
                    } else {
                        int n = 1;
                        for (Section s : sections) {
                            String st = s.getStatus() == null ? "ACTIVE" : s.getStatus();
                            String badgeClass = "ACTIVE".equalsIgnoreCase(st)
                                              ? "badge-active" : "badge-inactive";
                            String teacher = (s.getClassTeacherName() == null
                                            || s.getClassTeacherName().trim().isEmpty())
                                           ? "—"
                                           : s.getClassTeacherName();
                            String room = (s.getRoomNumber() == null
                                        || s.getRoomNumber().trim().isEmpty())
                                        ? "—"
                                        : s.getRoomNumber();
                %>
                    <tr>
                        <td><%= n++ %></td>

                        <td>
                            <div class="d-flex align-items-center gap-3">
                                <div class="section-icon"><%= s.getSectionName() %></div>
                                <div>
                                    <div class="fw-semibold">Section <%= s.getSectionName() %></div>
                                    <small class="text-secondary">Room <%= room %></small>
                                </div>
                            </div>
                        </td>

                        <td><%= room %></td>
                        <td><%= teacher %></td>
                        <td><span class="<%= badgeClass %>"><%= st %></span></td>

                        <td class="text-end">
                            <a href="edit-section.jsp?id=<%= s.getSectionId() %>"
                               class="btn btn-outline-warning action-btn"
                               title="Edit">
                                <i class="bi bi-pencil"></i>
                            </a>
                            <button type="button"
                                    class="btn btn-outline-danger action-btn"
                                    title="Delete"
                                    onclick="confirmDelete(<%= s.getSectionId() %>, '<%= s.getSectionName().replace("'","\\'") %>')">
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

<form id="deleteForm" action="<%= request.getContextPath() %>/DeleteSectionServlet"
      method="post" style="display:none;">
    <input type="hidden" name="sectionId" id="deleteSectionId">
    <input type="hidden" name="classId" value="<%= classId %>">
</form>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.bundle.min.js"></script>
<script>
function confirmDelete(sectionId, sectionName) {
    if (confirm("Mark Section " + sectionName + " as INACTIVE?")) {
        document.getElementById("deleteSectionId").value = sectionId;
        document.getElementById("deleteForm").submit();
    }
}
</script>

</body>
</html>
