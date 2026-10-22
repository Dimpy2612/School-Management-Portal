<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="com.school.util.DBConnection" %>

<%
    Object schoolIdObj = session.getAttribute("schoolId");

    int schoolId = 1;

    if (schoolIdObj != null) {
        schoolId = Integer.parseInt(schoolIdObj.toString());
    }

    String success = request.getParameter("success");
    String error   = request.getParameter("error");
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Teachers | School Management Portal</title>

    <link
        href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css"
        rel="stylesheet">

    <link
        rel="stylesheet"
        href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

    <style>

        * { box-sizing: border-box; }

        body {
            margin: 0;
            font-family: "Inter", "Segoe UI", sans-serif;
            background: #f4f7fb;
            color: #1e293b;
        }

        .sidebar {
            width: 250px;
            min-height: 100vh;
            position: fixed;
            left: 0;
            top: 0;
            background: linear-gradient(180deg, #2563eb 0%, #1d4ed8 55%, #1e40af 100%);
            color: white;
            padding: 22px 15px;
            z-index: 1000;
            box-shadow: 5px 0 20px rgba(37, 99, 235, 0.15);
        }

        .brand {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 4px 10px 28px;
        }

        .brand-icon {
            width: 45px;
            height: 45px;
            border-radius: 13px;
            background: rgba(255,255,255,0.18);
            border: 1px solid rgba(255,255,255,0.25);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 21px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.12);
        }

        .brand-text h5 { margin: 0; font-weight: 700; font-size: 17px; }
        .brand-text small { color: rgba(255,255,255,0.72); font-size: 12px; }

        .menu-title {
            font-size: 10px;
            text-transform: uppercase;
            color: rgba(255,255,255,0.55);
            letter-spacing: 1.2px;
            padding: 10px 12px;
            margin-top: 3px;
        }

        .sidebar a {
            display: flex;
            align-items: center;
            gap: 13px;
            padding: 11px 13px;
            margin: 4px 0;
            border-radius: 11px;
            color: rgba(255,255,255,0.78);
            text-decoration: none;
            font-size: 14px;
            font-weight: 500;
            transition: all 0.2s ease;
        }

        .sidebar a i { font-size: 17px; width: 20px; text-align: center; }

        .sidebar a:hover {
            background: rgba(255,255,255,0.15);
            color: white;
            transform: translateX(3px);
        }

        .sidebar a.active {
            background: white;
            color: #1557c0;
            font-weight: 650;
            box-shadow: 0 6px 18px rgba(0,0,0,0.12);
        }

        .sidebar a.active i { color: #2563eb; }

        .sidebar hr {
            border: 0;
            border-top: 1px solid rgba(255,255,255,0.18);
            margin: 18px 5px;
        }

        .sidebar a[href*="Logout"] { color: #ffe4e6; }
        .sidebar a[href*="Logout"]:hover {
            background: rgba(239,68,68,0.18);
            color: white;
        }

        .main {
            margin-left: 250px;
            min-height: 100vh;
            padding: 30px;
        }

        .top-card {
            background: white;
            border-radius: 18px;
            padding: 24px 26px;
            border: 1px solid #edf1f7;
            box-shadow: 0 5px 20px rgba(15,23,42,0.06);
        }

        .page-title { font-weight: 750; margin-bottom: 4px; color: #172033; }
        .page-subtitle { color: #64748b; margin: 0; font-size: 14px; }

        .add-btn {
            border: none;
            border-radius: 11px;
            padding: 11px 18px;
            font-weight: 600;
            background: linear-gradient(135deg, #2563eb, #1d4ed8);
            box-shadow: 0 6px 15px rgba(37,99,235,0.25);
            transition: 0.2s;
        }

        .add-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 9px 20px rgba(37,99,235,0.30);
        }

        .stat-card {
            background: white;
            border-radius: 17px;
            padding: 21px;
            border: 1px solid #edf1f7;
            box-shadow: 0 5px 18px rgba(15,23,42,0.05);
            height: 100%;
            transition: all 0.2s ease;
        }

        .stat-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 10px 25px rgba(15,23,42,0.09);
        }

        .stat-icon {
            width: 48px;
            height: 48px;
            border-radius: 13px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
        }

        .stat-icon.blue { background: #dbeafe; color: #2563eb; }
        .stat-icon.green { background: #dcfce7; color: #16a34a; }
        .stat-icon.orange { background: #ffedd5; color: #ea580c; }

        .stat-number { font-size: 27px; font-weight: 750; margin-top: 12px; color: #172033; }
        .stat-label { color: #64748b; font-size: 13px; margin-top: 2px; }

        .table-card {
            background: white;
            border-radius: 18px;
            padding: 25px;
            border: 1px solid #edf1f7;
            box-shadow: 0 5px 20px rgba(15,23,42,0.06);
        }

        .table-card h5 { font-weight: 700; margin: 0; color: #172033; }
        .table-card h5 i { color: #2563eb; }

        .table-card .badge.bg-light {
            background: #eff6ff !important;
            color: #2563eb !important;
            padding: 8px 13px;
            border-radius: 20px;
            font-weight: 600;
        }

        table { margin-bottom: 0 !important; }

        thead th {
            color: #475569;
            font-size: 12px;
            font-weight: 700;
            background: #f8fafc !important;
            white-space: nowrap;
            border-bottom: 1px solid #e2e8f0;
        }

        tbody td {
            font-size: 14px;
            color: #334155;
            padding-top: 15px !important;
            padding-bottom: 15px !important;
            vertical-align: middle;
            border-color: #f1f5f9;
        }

        tbody tr { transition: 0.15s; }
        tbody tr:hover { background: #f8fbff; }

        .teacher-icon {
            width: 43px;
            height: 43px;
            border-radius: 50%;
            background: linear-gradient(135deg, #dbeafe, #bfdbfe);
            color: #1d4ed8;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 17px;
            font-weight: 700;
            border: 2px solid #eff6ff;
        }

        .badge-active {
            background: #dcfce7;
            color: #15803d;
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 650;
            display: inline-block;
        }

        .badge-inactive {
            background: #fee2e2;
            color: #b91c1c;
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 650;
            display: inline-block;
        }

        .alert { border: none; border-radius: 12px; box-shadow: 0 5px 15px rgba(22,163,74,0.08); }

        ::-webkit-scrollbar { width: 7px; height: 7px; }
        ::-webkit-scrollbar-track { background: #f1f5f9; }
        ::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 10px; }
        ::-webkit-scrollbar-thumb:hover { background: #94a3b8; }

        /* Action buttons */
        .action-btn {
            width: 34px;
            height: 34px;
            padding: 0;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border-radius: 9px;
            font-size: 14px;
            margin: 0 2px;
            transition: 0.15s;
        }

        .action-btn:hover { transform: translateY(-2px); }

        @media (max-width: 991px) {
            .sidebar { width: 220px; }
            .main { margin-left: 220px; padding: 20px; }
        }

        @media (max-width: 768px) {
            .sidebar { position: relative; width: 100%; min-height: auto; }
            .main { margin-left: 0; padding: 15px; }
            .top-card { padding: 20px; }
        }

    </style>

</head>

<body>

<!-- SIDEBAR -->
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
    <hr>
    <a href="LogoutServlet"><i class="bi bi-box-arrow-right"></i> Logout</a>
</div>


<!-- MAIN -->
<div class="main">

    <div class="top-card mb-4">
        <div class="d-flex justify-content-between align-items-center">
            <div>
                <h2 class="page-title">Teachers</h2>
                <p class="page-subtitle">Manage all teachers of your school</p>
            </div>
            <a href="add-teacher.jsp" class="btn btn-primary add-btn">
                <i class="bi bi-plus-lg me-1"></i> Add Teacher
            </a>
        </div>
    </div>

    <!-- SUCCESS -->
    <% if ("added".equals(success)) { %>
        <div class="alert alert-success alert-dismissible fade show">
            <i class="bi bi-check-circle-fill me-2"></i>
            Teacher added successfully.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    <% } %>

    <% if ("updated".equals(success)) { %>
        <div class="alert alert-success alert-dismissible fade show">
            <i class="bi bi-check-circle-fill me-2"></i>
            Teacher updated successfully.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    <% } %>

    <% if ("deleted".equals(success)) { %>
        <div class="alert alert-success alert-dismissible fade show">
            <i class="bi bi-check-circle-fill me-2"></i>
            Teacher marked as INACTIVE successfully.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    <% } %>

    <% if ("failed".equals(error)) { %>
        <div class="alert alert-danger alert-dismissible fade show">
            <i class="bi bi-exclamation-triangle-fill me-2"></i>
            Operation failed. Please try again.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    <% } %>


    <!-- STAT CARDS -->
    <div class="row g-4 mb-4">

        <%
            int totalTeachers = 0;
            int activeTeachers = 0;
            int inactiveTeachers = 0;

            String countSql =
                "SELECT " +
                "COUNT(*) AS total, " +
                "SUM(CASE WHEN status='ACTIVE' THEN 1 ELSE 0 END) AS active, " +
                "SUM(CASE WHEN status='INACTIVE' THEN 1 ELSE 0 END) AS inactive " +
                "FROM teachers WHERE school_id=?";

            try (Connection con = DBConnection.getConnection();
                 PreparedStatement ps = con.prepareStatement(countSql)) {

                ps.setInt(1, schoolId);

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        totalTeachers = rs.getInt("total");
                        activeTeachers = rs.getInt("active");
                        inactiveTeachers = rs.getInt("inactive");
                    }
                }
            } catch (Exception e) { e.printStackTrace(); }
        %>

        <div class="col-md-4">
            <div class="stat-card">
                <div class="stat-icon blue"><i class="bi bi-person-badge-fill"></i></div>
                <div class="stat-number"><%= totalTeachers %></div>
                <div class="stat-label">Total Teachers</div>
            </div>
        </div>

        <div class="col-md-4">
            <div class="stat-card">
                <div class="stat-icon green"><i class="bi bi-person-check-fill"></i></div>
                <div class="stat-number"><%= activeTeachers %></div>
                <div class="stat-label">Active Teachers</div>
            </div>
        </div>

        <div class="col-md-4">
            <div class="stat-card">
                <div class="stat-icon orange"><i class="bi bi-person-x-fill"></i></div>
                <div class="stat-number"><%= inactiveTeachers %></div>
                <div class="stat-label">Inactive Teachers</div>
            </div>
        </div>
    </div>


    <!-- TEACHER TABLE -->
    <div class="table-card">

        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h5><i class="bi bi-person-badge me-2"></i> Teacher List</h5>
                <small class="text-secondary">All teachers registered in your school</small>
            </div>
            <span class="badge bg-light text-dark"><%= totalTeachers %> Teachers</span>
        </div>

        <div class="table-responsive">
            <table class="table table-hover align-middle">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Teacher</th>
                        <th>Employee Code</th>
                        <th>Email</th>
                        <th>Phone</th>
                        <th>Qualification</th>
                        <th>Status</th>
                        <th class="text-end">Actions</th>
                    </tr>
                </thead>
                <tbody>

<%
    String sql =
        "SELECT t.teacher_id, t.employee_code, t.qualification, t.status, " +
        "u.first_name, u.last_name, u.email, u.phone " +
        "FROM teachers t " +
        "INNER JOIN users u ON t.user_id = u.user_id " +
        "WHERE t.school_id = ? " +
        "ORDER BY t.teacher_id DESC";

    try (Connection con = DBConnection.getConnection();
         PreparedStatement ps = con.prepareStatement(sql)) {

        ps.setInt(1, schoolId);

        try (ResultSet rs = ps.executeQuery()) {

            int count = 1;
            boolean hasTeachers = false;

            while (rs.next()) {

                hasTeachers = true;

                long teacherId    = rs.getLong("teacher_id");
                String firstName  = rs.getString("first_name");
                String lastName   = rs.getString("last_name");
                String status     = rs.getString("status");

                String fullName = (firstName == null) ? "" : firstName;
                if (lastName != null && !lastName.trim().isEmpty()) {
                    fullName += " " + lastName;
                }

                String firstLetter = fullName.isEmpty()
                                   ? "T"
                                   : fullName.substring(0, 1).toUpperCase();
%>

                    <tr>
                        <td><%= count++ %></td>

                        <td>
                            <div class="d-flex align-items-center gap-3">
                                <div class="teacher-icon"><%= firstLetter %></div>
                                <div>
                                    <div class="fw-semibold"><%= fullName %></div>
                                    <small class="text-secondary">Teacher</small>
                                </div>
                            </div>
                        </td>

                        <td><span class="fw-semibold"><%= rs.getString("employee_code") %></span></td>
                        <td><%= rs.getString("email") %></td>
                        <td><%= rs.getString("phone") == null ? "-" : rs.getString("phone") %></td>
                        <td><%= rs.getString("qualification") == null ? "-" : rs.getString("qualification") %></td>

                        <td>
                            <% if ("ACTIVE".equalsIgnoreCase(status)) { %>
                                <span class="badge-active">Active</span>
                            <% } else { %>
                                <span class="badge-inactive"><%= status %></span>
                            <% } %>
                        </td>

                        <td class="text-end">
                            <a href="view-teacher.jsp?id=<%= teacherId %>"
                               class="btn btn-outline-primary action-btn"
                               title="View">
                                <i class="bi bi-eye"></i>
                            </a>

                            <a href="edit-teacher.jsp?id=<%= teacherId %>"
                               class="btn btn-outline-warning action-btn"
                               title="Edit">
                                <i class="bi bi-pencil"></i>
                            </a>

                            <button type="button"
                                    class="btn btn-outline-danger action-btn"
                                    title="Delete"
                                    onclick="confirmDelete(<%= teacherId %>, '<%= fullName.replace("'", "\\'") %>')">
                                <i class="bi bi-trash"></i>
                            </button>
                        </td>
                    </tr>

<%
            }

            if (!hasTeachers) {
%>

                <tr>
                    <td colspan="8" class="text-center py-5">
                        <div class="text-secondary">
                            <i class="bi bi-person-x" style="font-size:40px;"></i>
                            <div class="mt-2">No teachers found.</div>
                            <div class="small">Click "Add Teacher" to add a teacher.</div>
                        </div>
                    </td>
                </tr>

<%
            }
        }

    } catch (Exception e) {
        e.printStackTrace();
%>

                <tr>
                    <td colspan="8" class="text-center text-danger py-4">
                        Unable to load teachers.
                    </td>
                </tr>

<%
    }
%>

                </tbody>
            </table>
        </div>
    </div>

</div>

<!-- Hidden delete form -->
<form id="deleteForm"
      action="<%= request.getContextPath() %>/DeleteTeacherServlet"
      method="post"
      style="display:none;">
    <input type="hidden" name="teacherId" id="deleteTeacherId">
</form>

<script
    src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.bundle.min.js">
</script>

<script>
function confirmDelete(teacherId, teacherName) {
    var ok = confirm(
        "Are you sure you want to delete teacher:\n\n" +
        teacherName +
        "\n\nThis will mark the teacher as INACTIVE."
    );
    if (ok) {
        document.getElementById("deleteTeacherId").value = teacherId;
        document.getElementById("deleteForm").submit();
    }
}
</script>

</body>
</html>
