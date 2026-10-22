<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="com.school.dao.TeacherDAO" %>
<%@ page import="com.school.model.Teacher" %>

<%
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

    String idText = request.getParameter("id");

    if (idText == null || idText.trim().isEmpty()) {
        response.sendRedirect("teachers.jsp");
        return;
    }

    long teacherId = Long.parseLong(idText);

    TeacherDAO dao = new TeacherDAO();
    Teacher t = dao.getTeacherById(teacherId, schoolId);

    if (t == null) {
        response.sendRedirect("teachers.jsp");
        return;
    }

    String fullName = (t.getFirstName() == null ? "" : t.getFirstName());
    if (t.getLastName() != null && !t.getLastName().trim().isEmpty()) {
        fullName += " " + t.getLastName();
    }

    String firstLetter = fullName.isEmpty()
                       ? "T"
                       : fullName.substring(0, 1).toUpperCase();

    String phone          = (t.getPhone() == null)           ? "-" : t.getPhone();
    String qualification  = (t.getQualification() == null)   ? "-" : t.getQualification();
    String specialization = (t.getSpecialization() == null)  ? "-" : t.getSpecialization();
    String joiningDate    = (t.getJoiningDate() == null)     ? "-" : t.getJoiningDate().toString();
    String experience     = (t.getExperienceYears() == null) ? "-" : t.getExperienceYears().toString();
    String dob            = (t.getDateOfBirth() == null)     ? "-" : t.getDateOfBirth().toString();
    String gender         = (t.getGender() == null)          ? "-" : t.getGender();
    String address        = (t.getAddress() == null)         ? "-" : t.getAddress();
    String status         = (t.getStatus() == null)          ? "-" : t.getStatus();
%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>View Teacher | School Management Portal</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

    <style>
        body { margin:0; font-family:"Inter","Segoe UI",sans-serif; background:#f5f7fb; color:#1e293b; }
        .sidebar { width:250px; min-height:100vh; position:fixed; left:0; top:0;
            background:linear-gradient(180deg,#2563eb 0%,#1d4ed8 55%,#1e40af 100%);
            color:white; padding:24px 16px; z-index:1000; }
        .brand { display:flex; align-items:center; gap:12px; padding:0 10px 28px; }
        .brand-icon { width:42px; height:42px; border-radius:12px; background:#2563eb;
            display:flex; align-items:center; justify-content:center; font-size:20px; }
        .brand-text h5 { margin:0; font-weight:700; }
        .brand-text small { color:#9ca3af; }
        .menu-title { font-size:11px; text-transform:uppercase; color:#6b7280;
            letter-spacing:1px; padding:10px 12px; margin-top:5px; }
        .sidebar a { display:flex; align-items:center; gap:13px; padding:11px 13px;
            margin:4px 0; border-radius:10px; color:#cbd5e1; text-decoration:none;
            font-size:14px; transition:0.2s; }
        .sidebar a i { font-size:17px; }
        .sidebar a:hover, .sidebar a.active { background:#2563eb; color:white; }
        .main { margin-left:250px; min-height:100vh; padding:30px; }
        .top-card { background:white; border-radius:16px; padding:24px 26px;
            box-shadow:0 4px 15px rgba(0,0,0,0.06); }
        .page-title { font-weight:700; margin-bottom:4px; }
        .page-subtitle { color:#6b7280; margin:0; }
        .info-card { background:white; border-radius:16px; padding:25px;
            box-shadow:0 4px 15px rgba(0,0,0,0.06); }
        .teacher-avatar { width:80px; height:80px; border-radius:50%;
            background:linear-gradient(135deg,#2563eb,#7c3aed); color:white;
            display:flex; align-items:center; justify-content:center;
            font-size:32px; font-weight:700; flex-shrink:0; }
        .info-label { font-size:12px; text-transform:uppercase; color:#64748b;
            letter-spacing:0.5px; font-weight:600; }
        .info-value { font-size:15px; color:#1e293b; font-weight:500;
            margin-top:4px; word-break:break-word; }
        .section-header { padding-bottom:14px; margin-bottom:20px;
            border-bottom:1px solid #eef0f4; font-weight:700;
            font-size:16px; color:#1e293b; }
        .badge-active { background:#dcfce7; color:#15803d; padding:6px 14px;
            border-radius:20px; font-size:12px; font-weight:650; display:inline-block; }
        .badge-inactive { background:#fee2e2; color:#b91c1c; padding:6px 14px;
            border-radius:20px; font-size:12px; font-weight:650; display:inline-block; }
        .btn { border-radius:10px; padding:9px 17px; font-weight:600; }
        @media (max-width:768px) {
            .sidebar { position:relative; width:100%; min-height:auto; }
            .main { margin-left:0; padding:15px; }
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
    <a href="students.jsp"><i class="bi bi-people"></i> Students</a>
    <a href="teachers.jsp" class="active"><i class="bi bi-person-badge"></i> Teachers</a>
    <a href="classes.jsp"><i class="bi bi-building"></i> Classes</a>
    <a href="subjects.jsp"><i class="bi bi-book"></i> Subjects</a>
    <a href="attendance.jsp"><i class="bi bi-calendar-check"></i> Attendance</a>
    <a href="exams.jsp"><i class="bi bi-file-earmark-text"></i> Exams</a>
    <a href="fees.jsp"><i class="bi bi-cash-stack"></i> Fees</a>
    <a href="notices.jsp"><i class="bi bi-megaphone"></i> Notices</a>
    <hr style="border-color:#374151;">
    <a href="LogoutServlet"><i class="bi bi-box-arrow-right"></i> Logout</a>
</div>


<div class="main">

    <div class="top-card mb-4 d-flex justify-content-between align-items-center">
        <div>
            <h2 class="page-title">Teacher Details</h2>
            <p class="page-subtitle">View full profile of this teacher</p>
        </div>
        <a href="teachers.jsp" class="btn btn-outline-secondary">
            <i class="bi bi-arrow-left me-1"></i> Back to Teachers
        </a>
    </div>

    <div class="info-card">

        <div class="d-flex align-items-center gap-3 mb-4 pb-4 border-bottom">
            <div class="teacher-avatar"><%= firstLetter %></div>
            <div class="flex-grow-1">
                <h3 class="mb-1 fw-bold"><%= fullName %></h3>
                <div class="text-secondary">
                    <i class="bi bi-envelope me-1"></i> <%= t.getEmail() %>
                </div>
                <div class="mt-2">
                    <% if ("ACTIVE".equalsIgnoreCase(status)) { %>
                        <span class="badge-active"><i class="bi bi-check-circle me-1"></i> Active</span>
                    <% } else { %>
                        <span class="badge-inactive"><i class="bi bi-x-circle me-1"></i> <%= status %></span>
                    <% } %>
                </div>
            </div>
            <a href="edit-teacher.jsp?id=<%= t.getTeacherId() %>" class="btn btn-primary">
                <i class="bi bi-pencil me-1"></i> Edit
            </a>
        </div>

        <div class="section-header"><i class="bi bi-person-badge me-2 text-primary"></i> Personal Information</div>
        <div class="row g-4 mb-4">
            <div class="col-md-4"><div class="info-label">First Name</div><div class="info-value"><%= t.getFirstName() %></div></div>
            <div class="col-md-4"><div class="info-label">Last Name</div><div class="info-value"><%= t.getLastName() == null ? "-" : t.getLastName() %></div></div>
            <div class="col-md-4"><div class="info-label">Phone</div><div class="info-value"><%= phone %></div></div>
            <div class="col-md-4"><div class="info-label">Date of Birth</div><div class="info-value"><%= dob %></div></div>
            <div class="col-md-4"><div class="info-label">Gender</div><div class="info-value"><%= gender %></div></div>
            <div class="col-md-4"><div class="info-label">Username</div><div class="info-value"><%= t.getUsername() %></div></div>
            <div class="col-12"><div class="info-label">Address</div><div class="info-value"><%= address %></div></div>
        </div>

        <div class="section-header"><i class="bi bi-briefcase me-2 text-primary"></i> Professional Information</div>
        <div class="row g-4">
            <div class="col-md-4"><div class="info-label">Employee Code</div><div class="info-value"><%= t.getEmployeeCode() %></div></div>
            <div class="col-md-4"><div class="info-label">Qualification</div><div class="info-value"><%= qualification %></div></div>
            <div class="col-md-4"><div class="info-label">Specialization</div><div class="info-value"><%= specialization %></div></div>
            <div class="col-md-4"><div class="info-label">Joining Date</div><div class="info-value"><%= joiningDate %></div></div>
            <div class="col-md-4"><div class="info-label">Experience (Years)</div><div class="info-value"><%= experience %></div></div>
        </div>

    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
