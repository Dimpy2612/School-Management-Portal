<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="java.util.Map" %>
<%@ page import="com.school.dao.StudentDAO" %>
<%@ page import="com.school.dao.ClassSectionDAO" %>
<%@ page import="com.school.model.Student" %>

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
        response.sendRedirect("students.jsp");
        return;
    }

    long studentId = Long.parseLong(idText);

    StudentDAO studentDAO = new StudentDAO();
    Student s = studentDAO.getStudentById(studentId, schoolId);

    if (s == null) {
        response.sendRedirect("students.jsp");
        return;
    }

    ClassSectionDAO csDAO = new ClassSectionDAO();
    Map<Long, String> classes = csDAO.getClasses(schoolId);
    Map<Long, String> sections = (s.getClassId() > 0)
                               ? csDAO.getSections(s.getClassId())
                               : new java.util.LinkedHashMap<>();

    String error = request.getParameter("error");

    String dobStr  = (s.getDateOfBirth()  == null) ? "" : s.getDateOfBirth().toString();
    String admStr  = (s.getAdmissionDate()== null) ? "" : s.getAdmissionDate().toString();
    String gender  = (s.getGender() == null) ? "" : s.getGender();
    String status  = (s.getStatus() == null) ? "ACTIVE" : s.getStatus();
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Student | School Management Portal</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

    <style>
        * { box-sizing:border-box; }
        body { margin:0; font-family:"Inter","Segoe UI",sans-serif;
            background:#f5f7fb; color:#1e293b; }

        .sidebar { width:250px; min-height:100vh; position:fixed;
            left:0; top:0;
            background:linear-gradient(180deg,#2563eb 0%,#1d4ed8 55%,#1e40af 100%);
            color:white; padding:24px 16px; z-index:1000; }
        .brand { display:flex; align-items:center; gap:12px; padding:0 10px 28px; }
        .brand-icon { width:42px; height:42px; border-radius:12px;
            background:#2563eb; display:flex; align-items:center;
            justify-content:center; font-size:20px; }
        .brand-text h5 { margin:0; font-weight:700; }
        .brand-text small { color:#9ca3af; }

        .menu-title { font-size:11px; text-transform:uppercase;
            color:#6b7280; letter-spacing:1px;
            padding:10px 12px; margin-top:5px; }
        .sidebar a { display:flex; align-items:center; gap:13px;
            padding:11px 13px; margin:4px 0; border-radius:10px;
            color:#cbd5e1; text-decoration:none; font-size:14px;
            transition:0.2s; }
        .sidebar a i { font-size:17px; }
        .sidebar a:hover, .sidebar a.active { background:#2563eb; color:white; }

        .main { margin-left:250px; min-height:100vh; padding:30px; }

        .top-card { background:white; border-radius:16px; padding:24px 26px;
            box-shadow:0 4px 15px rgba(0,0,0,0.06); }
        .page-title { font-weight:700; margin-bottom:4px; }
        .page-subtitle { color:#6b7280; margin:0; }

        .form-card { background:white; border-radius:16px; padding:25px;
            box-shadow:0 4px 15px rgba(0,0,0,0.06); }
        .section-title { font-weight:700; margin:0; }
        .section-subtitle { color:#6b7280; font-size:13px; margin-top:4px; }
        .section-header { padding-bottom:18px; margin-bottom:22px;
            border-bottom:1px solid #eef0f4; }

        .form-label { font-size:13px; font-weight:600;
            color:#334155; margin-bottom:7px; }
        .required { color:#dc2626; }
        .form-control, .form-select { border-radius:10px;
            border:1px solid #dbe1ea; padding:11px 13px;
            font-size:14px; color:#334155; }
        .form-control:focus, .form-select:focus {
            border-color:#2563eb;
            box-shadow:0 0 0 3px rgba(37,99,235,0.10); }
        textarea.form-control { resize:vertical; }
        .add-btn { border-radius:10px; padding:10px 17px; font-weight:600; }
        .cancel-btn { border-radius:10px; padding:10px 17px; font-weight:600; }
        .alert { border-radius:12px; border:none; }
        .readonly-badge { background:#f1f5f9; color:#64748b;
            padding:11px 13px; border-radius:10px;
            font-size:14px; border:1px solid #dbe1ea; }

        @media (max-width: 991px) {
            .sidebar { width:220px; }
            .main { margin-left:220px; padding:20px; }
        }
        @media (max-width: 768px) {
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
    <a href="students.jsp" class="active"><i class="bi bi-people"></i> Students</a>
    <a href="teachers.jsp"><i class="bi bi-person-badge"></i> Teachers</a>
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

    <div class="top-card mb-4">
        <div class="d-flex justify-content-between align-items-center">
            <div>
                <h2 class="page-title">Edit Student</h2>
                <p class="page-subtitle">Update student information</p>
            </div>
            <a href="students.jsp" class="btn btn-outline-secondary cancel-btn">
                <i class="bi bi-arrow-left me-1"></i> Back to Students
            </a>
        </div>
    </div>

    <% if ("required".equals(error)) { %>
        <div class="alert alert-danger alert-dismissible fade show">
            <i class="bi bi-exclamation-triangle-fill me-2"></i>
            Please fill all required fields.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    <% } %>
    <% if ("admissionNo".equals(error)) { %>
        <div class="alert alert-danger alert-dismissible fade show">
            <i class="bi bi-exclamation-triangle-fill me-2"></i>
            Admission number already used by another student.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    <% } %>
    <% if ("failed".equals(error)) { %>
        <div class="alert alert-danger alert-dismissible fade show">
            <i class="bi bi-exclamation-triangle-fill me-2"></i>
            Failed to update student. Please try again.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    <% } %>

    <div class="form-card">

        <form action="<%= request.getContextPath() %>/UpdateStudentServlet" method="post">

            <input type="hidden" name="studentId" value="<%= s.getStudentId() %>">

            <!-- PERSONAL -->
            <div class="section-header">
                <h5 class="section-title">
                    <i class="bi bi-person-badge me-2 text-primary"></i>
                    Personal Information
                </h5>
                <div class="section-subtitle">Update personal details</div>
            </div>

            <div class="row g-4">

                <div class="col-md-6">
                    <label class="form-label">First Name <span class="required">*</span></label>
                    <input type="text" name="firstName" class="form-control"
                           value="<%= s.getFirstName() == null ? "" : s.getFirstName() %>" required>
                </div>

                <div class="col-md-6">
                    <label class="form-label">Last Name</label>
                    <input type="text" name="lastName" class="form-control"
                           value="<%= s.getLastName() == null ? "" : s.getLastName() %>">
                </div>

                <div class="col-md-4">
                    <label class="form-label">Date of Birth</label>
                    <input type="date" name="dateOfBirth" class="form-control"
                           value="<%= dobStr %>">
                </div>

                <div class="col-md-4">
                    <label class="form-label">Gender</label>
                    <select name="gender" class="form-select">
                        <option value="" <%= gender.isEmpty() ? "selected" : "" %>>Select Gender</option>
                        <option value="MALE"   <%= "MALE".equals(gender)   ? "selected" : "" %>>Male</option>
                        <option value="FEMALE" <%= "FEMALE".equals(gender) ? "selected" : "" %>>Female</option>
                        <option value="OTHER"  <%= "OTHER".equals(gender)  ? "selected" : "" %>>Other</option>
                    </select>
                </div>

                <div class="col-md-4">
                    <label class="form-label">Blood Group</label>
                    <input type="text" name="bloodGroup" class="form-control"
                           value="<%= s.getBloodGroup() == null ? "" : s.getBloodGroup() %>"
                           maxlength="5">
                </div>

                <div class="col-md-6">
                    <label class="form-label">Phone</label>
                    <input type="text" name="phone" class="form-control"
                           value="<%= s.getPhone() == null ? "" : s.getPhone() %>">
                </div>

                <div class="col-md-6">
                    <label class="form-label">Emergency Contact Name</label>
                    <input type="text" name="emergencyContactName" class="form-control"
                           value="<%= s.getEmergencyContactName() == null ? "" : s.getEmergencyContactName() %>">
                </div>

                <div class="col-md-6">
                    <label class="form-label">Emergency Contact Phone</label>
                    <input type="text" name="emergencyContactPhone" class="form-control"
                           value="<%= s.getEmergencyContactPhone() == null ? "" : s.getEmergencyContactPhone() %>">
                </div>

                <div class="col-12">
                    <label class="form-label">Address</label>
                    <textarea name="address" class="form-control" rows="3"><%= s.getAddress() == null ? "" : s.getAddress() %></textarea>
                </div>
            </div>


            <!-- ACADEMIC -->
            <div class="section-header mt-5">
                <h5 class="section-title">
                    <i class="bi bi-mortarboard me-2 text-primary"></i>
                    Academic Information
                </h5>
                <div class="section-subtitle">Update admission and class details</div>
            </div>

            <div class="row g-4">

                <div class="col-md-4">
                    <label class="form-label">Admission No <span class="required">*</span></label>
                    <input type="text" name="admissionNo" class="form-control"
                           value="<%= s.getAdmissionNo() == null ? "" : s.getAdmissionNo() %>" required>
                </div>

                <div class="col-md-4">
                    <label class="form-label">Admission Date</label>
                    <input type="date" name="admissionDate" class="form-control"
                           value="<%= admStr %>">
                </div>

                <div class="col-md-4">
                    <label class="form-label">Roll Number</label>
                    <input type="text" name="rollNumber" class="form-control"
                           value="<%= s.getRollNumber() == null ? "" : s.getRollNumber() %>">
                </div>

                <div class="col-md-6">
                    <label class="form-label">Class <span class="required">*</span></label>
                    <select name="classId" id="classId" class="form-select" required
                            onchange="loadSections()">
                        <option value="">Select Class</option>
                        <% for (Map.Entry<Long, String> c : classes.entrySet()) {
                            String sel = (s.getClassId() == c.getKey()) ? "selected" : "";
                        %>
                            <option value="<%= c.getKey() %>" <%= sel %>><%= c.getValue() %></option>
                        <% } %>
                    </select>
                </div>

                <div class="col-md-6">
                    <label class="form-label">Section <span class="required">*</span></label>
                    <select name="sectionId" id="sectionId" class="form-select" required>
                        <option value="">Select Section</option>
                        <% for (Map.Entry<Long, String> sec : sections.entrySet()) {
                            String sel = (s.getSectionId() == sec.getKey()) ? "selected" : "";
                        %>
                            <option value="<%= sec.getKey() %>" <%= sel %>><%= sec.getValue() %></option>
                        <% } %>
                    </select>
                </div>

                <div class="col-md-6">
                    <label class="form-label">Status</label>
                    <select name="status" class="form-select">
                        <option value="ACTIVE"     <%= "ACTIVE".equals(status)     ? "selected" : "" %>>Active</option>
                        <option value="INACTIVE"   <%= "INACTIVE".equals(status)   ? "selected" : "" %>>Inactive</option>
                        <option value="PASSED_OUT" <%= "PASSED_OUT".equals(status) ? "selected" : "" %>>Passed Out</option>
                        <option value="TRANSFERRED" <%= "TRANSFERRED".equals(status) ? "selected" : "" %>>Transferred</option>
                    </select>
                </div>

            </div>


            <!-- READONLY ACCOUNT -->
            <div class="section-header mt-5">
                <h5 class="section-title">
                    <i class="bi bi-shield-lock me-2 text-primary"></i>
                    Account Information
                </h5>
                <div class="section-subtitle">Login credentials cannot be changed here</div>
            </div>

            <div class="row g-4">
                <div class="col-md-6">
                    <label class="form-label">Username</label>
                    <div class="readonly-badge"><%= s.getUsername() %></div>
                </div>
                <div class="col-md-6">
                    <label class="form-label">Email</label>
                    <div class="readonly-badge"><%= s.getEmail() %></div>
                </div>
            </div>

            <div class="d-flex justify-content-end gap-2 mt-5 pt-3 border-top">
                <a href="students.jsp" class="btn btn-outline-secondary cancel-btn">
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
<script>
function loadSections() {
    var classId = document.getElementById("classId").value;
    var sectionSel = document.getElementById("sectionId");
    sectionSel.innerHTML = '<option value="">Loading...</option>';

    if (!classId) {
        sectionSel.innerHTML = '<option value="">Select Class First</option>';
        return;
    }

    fetch("<%= request.getContextPath() %>/GetSectionsServlet?classId=" + classId)
        .then(response => response.json())
        .then(data => {
            var html = '<option value="">Select Section</option>';
            data.forEach(function(s) {
                html += '<option value="' + s.section_id + '">' + s.section_name + '</option>';
            });
            sectionSel.innerHTML = html;
        })
        .catch(err => {
            sectionSel.innerHTML = '<option value="">Error loading sections</option>';
        });
}
</script>

</body>
</html>
