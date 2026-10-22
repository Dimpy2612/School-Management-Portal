<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="java.util.List" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.school.dao.SectionDAO" %>
<%@ page import="com.school.model.Section" %>
<%@ page import="com.school.util.DBConnection" %>

<%
    if (session == null || session.getAttribute("userId") == null
            || !"ADMIN".equals(session.getAttribute("role"))) {
        response.sendRedirect(request.getContextPath() + "/login.html");
        return;
    }

    int schoolId = Integer.parseInt(session.getAttribute("schoolId").toString());

    String idText = request.getParameter("id");
    if (idText == null || idText.trim().isEmpty()) {
        response.sendRedirect("classes.jsp");
        return;
    }

    long sectionId = Long.parseLong(idText);

    SectionDAO sectionDAO = new SectionDAO();
    Section s = sectionDAO.getSectionById(sectionId, schoolId);
    if (s == null) {
        response.sendRedirect("classes.jsp");
        return;
    }

    long classId = s.getClassId();
    String error = request.getParameter("error");
    String status = s.getStatus() == null ? "ACTIVE" : s.getStatus();

    // Load all active teachers
    java.util.List<String[]> teachers = new java.util.ArrayList<>();
    String tSql =
        "SELECT t.teacher_id, u.first_name, u.last_name " +
        "FROM teachers t " +
        "INNER JOIN users u ON u.user_id = t.user_id " +
        "WHERE t.school_id = ? AND t.status = 'ACTIVE' " +
        "ORDER BY u.first_name";
    try (Connection con = DBConnection.getConnection();
         PreparedStatement ps = con.prepareStatement(tSql)) {
        ps.setInt(1, schoolId);
        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String fn = rs.getString("first_name");
                String ln = rs.getString("last_name");
                String name = (fn == null ? "" : fn);
                if (ln != null && !ln.trim().isEmpty()) name += " " + ln;
                teachers.add(new String[]{
                    String.valueOf(rs.getLong("teacher_id")),
                    name.trim()
                });
            }
        }
    } catch (Exception e) { e.printStackTrace(); }
%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Section | School Management Portal</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

    <style>
        * { box-sizing:border-box; }
        html, body { overflow-x:hidden; overflow-y:auto; min-height:100vh; height:auto; }
        body { margin:0; font-family:"Inter","Segoe UI",sans-serif;
            background:#f5f7fb; color:#1e293b; }
        .sidebar { width:250px; min-height:100vh; position:fixed; left:0; top:0;
            background:linear-gradient(180deg,#2563eb 0%,#1d4ed8 55%,#1e40af 100%);
            color:white; padding:24px 16px; z-index:1000; }
        .brand { display:flex; align-items:center; gap:12px; padding:0 10px 28px; }
        .brand-icon { width:42px; height:42px; border-radius:12px;
            background:#2563eb; display:flex; align-items:center;
            justify-content:center; font-size:20px; }
        .brand-text h5 { margin:0; font-weight:700; }
        .brand-text small { color:#9ca3af; }
        .menu-title { font-size:11px; text-transform:uppercase;
            color:#6b7280; letter-spacing:1px; padding:10px 12px; margin-top:5px; }
        .sidebar a { display:flex; align-items:center; gap:13px;
            padding:11px 13px; margin:4px 0; border-radius:10px;
            color:#cbd5e1; text-decoration:none; font-size:14px; transition:0.2s; }
        .sidebar a i { font-size:17px; }
        .sidebar a:hover, .sidebar a.active { background:#2563eb; color:white; }
        .main { margin-left:250px; min-height:100vh; padding:30px; }
        .top-card { background:white; border-radius:16px; padding:24px 26px;
            box-shadow:0 4px 15px rgba(0,0,0,0.06); }
        .page-title { font-weight:700; margin-bottom:4px; }
        .page-subtitle { color:#6b7280; margin:0; }
        .form-card { background:white; border-radius:16px; padding:25px;
            box-shadow:0 4px 15px rgba(0,0,0,0.06); }
        .section-header { padding-bottom:18px; margin-bottom:22px;
            border-bottom:1px solid #eef0f4; }
        .section-title { font-weight:700; margin:0; }
        .form-label { font-size:13px; font-weight:600; color:#334155; margin-bottom:7px; }
        .required { color:#dc2626; }
        .form-control, .form-select { border-radius:10px;
            border:1px solid #dbe1ea; padding:11px 13px;
            font-size:14px; color:#334155; }
        .form-control:focus, .form-select:focus {
            border-color:#2563eb;
            box-shadow:0 0 0 3px rgba(37,99,235,0.10); }
        .add-btn { border-radius:10px; padding:10px 17px; font-weight:600; }
        .cancel-btn { border-radius:10px; padding:10px 17px; font-weight:600; }
        .alert { border-radius:12px; border:none; }
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
    <hr style="border-color:#374151;">
    <a href="LogoutServlet"><i class="bi bi-box-arrow-right"></i> Logout</a>
</div>

<div class="main">

    <div class="top-card mb-4">
        <div class="d-flex justify-content-between align-items-center">
            <div>
                <h2 class="page-title">Edit Section — <%= s.getSectionName() %></h2>
                <p class="page-subtitle">Update section details</p>
            </div>
            <a href="sections.jsp?classId=<%= classId %>" class="btn btn-outline-secondary cancel-btn">
                <i class="bi bi-arrow-left me-1"></i> Back to Sections
            </a>
        </div>
    </div>

    <% if ("required".equals(error)) { %>
        <div class="alert alert-danger alert-dismissible fade show">
            <i class="bi bi-exclamation-triangle-fill me-2"></i> Section name is required.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    <% } %>
    <% if ("duplicate".equals(error)) { %>
        <div class="alert alert-danger alert-dismissible fade show">
            <i class="bi bi-exclamation-triangle-fill me-2"></i> Another section already has that name.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    <% } %>
    <% if ("failed".equals(error)) { %>
        <div class="alert alert-danger alert-dismissible fade show">
            <i class="bi bi-exclamation-triangle-fill me-2"></i> Failed to update section.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    <% } %>

    <div class="form-card">
        <form action="<%= request.getContextPath() %>/UpdateSectionServlet" method="post">

            <input type="hidden" name="sectionId" value="<%= s.getSectionId() %>">
            <input type="hidden" name="classId" value="<%= classId %>">

            <div class="section-header">
                <h5 class="section-title">
                    <i class="bi bi-grid-3x3-gap me-2 text-primary"></i> Section Details
                </h5>
            </div>

            <div class="row g-4">

                <div class="col-md-6">
                    <label class="form-label">Section Name <span class="required">*</span></label>
                    <input type="text" name="sectionName" class="form-control"
                           value="<%= s.getSectionName() %>" required maxlength="20">
                </div>

                <div class="col-md-6">
                    <label class="form-label">Room Number</label>
                    <input type="text" name="roomNumber" class="form-control"
                           value="<%= s.getRoomNumber() == null ? "" : s.getRoomNumber() %>"
                           maxlength="30">
                </div>

                <div class="col-md-6">
                    <label class="form-label">Class Teacher</label>
                    <select name="classTeacherId" class="form-select">
                        <option value="">— None —</option>
                        <% for (String[] t : teachers) {
                            String sel = (s.getClassTeacherId() != null
                                       && s.getClassTeacherId() == Long.parseLong(t[0]))
                                       ? "selected" : "";
                        %>
                            <option value="<%= t[0] %>" <%= sel %>><%= t[1] %></option>
                        <% } %>
                    </select>
                </div>

                <div class="col-md-6">
                    <label class="form-label">Status</label>
                    <select name="status" class="form-select">
                        <option value="ACTIVE"   <%= "ACTIVE".equals(status)   ? "selected" : "" %>>Active</option>
                        <option value="INACTIVE" <%= "INACTIVE".equals(status) ? "selected" : "" %>>Inactive</option>
                    </select>
                </div>

            </div>

            <div class="d-flex justify-content-end gap-2 mt-5 pt-3 border-top">
                <a href="sections.jsp?classId=<%= classId %>" class="btn btn-outline-secondary cancel-btn">
                    <i class="bi bi-x-lg me-1"></i> Cancel
                </a>
                <button type="submit" class="btn btn-primary add-btn">
                    <i class="bi bi-check-lg me-1"></i> Save Changes
                </button>
            </div>

        </form>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
