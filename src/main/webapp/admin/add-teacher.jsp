<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Add Teacher | School Management Portal</title>

    <!-- Bootstrap -->
    <link
        href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css"
        rel="stylesheet">

    <!-- Bootstrap Icons -->
    <link
        rel="stylesheet"
        href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

    <style>

        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            font-family: "Inter", "Segoe UI", sans-serif;
            background: #f5f7fb;
            color: #1e293b;
        }


        /* =========================================
           SIDEBAR
        ========================================= */

        .sidebar {
            width: 250px;
            min-height: 100vh;
            position: fixed;
            left: 0;
            top: 0;
            background:linear-gradient(180deg, #2563eb 0%, #1d4ed8 55%, #1e40af 100%);

            color: white;
            padding: 24px 16px;
            z-index: 1000;
        }


        /* BRAND */

        .brand {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 0 10px 28px;
        }

        .brand-icon {
            width: 42px;
            height: 42px;
            border-radius: 12px;
            background: #2563eb;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
        }

        .brand-text h5 {
            margin: 0;
            font-weight: 700;
        }

        .brand-text small {
            color: #9ca3af;
        }


        .menu-title {
            font-size: 11px;
            text-transform: uppercase;
            color: #6b7280;
            letter-spacing: 1px;
            padding: 10px 12px;
            margin-top: 5px;
        }


        /* SIDEBAR LINKS */

        .sidebar a {
            display: flex;
            align-items: center;
            gap: 13px;
            padding: 11px 13px;
            margin: 4px 0;
            border-radius: 10px;
            color: #cbd5e1;
            text-decoration: none;
            font-size: 14px;
            transition: 0.2s;
        }

        .sidebar a i {
            font-size: 17px;
        }

        .sidebar a:hover,
        .sidebar a.active {
            background: #2563eb;
            color: white;
        }


        /* =========================================
           MAIN
        ========================================= */

        .main {
            margin-left: 250px;
            min-height: 100vh;
            padding: 30px;
        }


        /* =========================================
           TOP HEADER
        ========================================= */

        .top-card {
            background: white;
            border-radius: 16px;
            padding: 24px 26px;
            box-shadow:
                0 4px 15px rgba(0,0,0,0.06);
        }

        .page-title {
            font-weight: 700;
            margin-bottom: 4px;
        }

        .page-subtitle {
            color: #6b7280;
            margin: 0;
        }


        /* =========================================
           FORM CARD
        ========================================= */

        .form-card {
            background: white;
            border-radius: 16px;
            padding: 25px;
            box-shadow:
                0 4px 15px rgba(0,0,0,0.06);
        }


        .section-title {
            font-weight: 700;
            margin: 0;
        }


        .section-subtitle {
            color: #6b7280;
            font-size: 13px;
            margin-top: 4px;
        }


        .section-header {
            padding-bottom: 18px;
            margin-bottom: 22px;
            border-bottom: 1px solid #eef0f4;
        }


        /* =========================================
           FORM
        ========================================= */

        .form-label {
            font-size: 13px;
            font-weight: 600;
            color: #334155;
            margin-bottom: 7px;
        }

        .required {
            color: #dc2626;
        }

        .form-control,
        .form-select {
            border-radius: 10px;
            border: 1px solid #dbe1ea;
            padding: 11px 13px;
            font-size: 14px;
            color: #334155;
        }

        .form-control:focus,
        .form-select:focus {
            border-color: #2563eb;
            box-shadow:
                0 0 0 3px rgba(37,99,235,0.10);
        }

        textarea.form-control {
            resize: vertical;
        }


        /* =========================================
           BUTTONS
        ========================================= */

        .add-btn {
            border-radius: 10px;
            padding: 10px 17px;
            font-weight: 600;
        }

        .cancel-btn {
            border-radius: 10px;
            padding: 10px 17px;
            font-weight: 600;
        }


        /* =========================================
           ALERT
        ========================================= */

        .alert {
            border-radius: 12px;
            border: none;
        }


        /* =========================================
           MOBILE
        ========================================= */

        @media (max-width: 991px) {

            .sidebar {
                width: 220px;
            }

            .main {
                margin-left: 220px;
                padding: 20px;
            }

        }


        @media (max-width: 768px) {

            .sidebar {
                position: relative;
                width: 100%;
                min-height: auto;
            }

            .main {
                margin-left: 0;
                padding: 15px;
            }

        }

    </style>

</head>


<body>


<!-- =====================================================
     SIDEBAR
===================================================== -->

<div class="sidebar">


    <!-- BRAND -->

    <div class="brand">

        <div class="brand-icon">

            <i class="bi bi-mortarboard-fill"></i>

        </div>


        <div class="brand-text">

            <h5>School Portal</h5>

            <small>Administration</small>

        </div>

    </div>


    <!-- MENU -->

    <div class="menu-title">
        Main Menu
    </div>


    <a href="dashboard.jsp">

        <i class="bi bi-grid"></i>

        Dashboard

    </a>


    <a href="students.jsp">

        <i class="bi bi-people"></i>

        Students

    </a>


    <!-- TEACHERS ACTIVE -->

    <a href="teachers.jsp" class="active">

        <i class="bi bi-person-badge"></i>

        Teachers

    </a>


    <a href="classes.jsp">

        <i class="bi bi-building"></i>

        Classes

    </a>


    <a href="subjects.jsp">

        <i class="bi bi-book"></i>

        Subjects

    </a>


    <a href="attendance.jsp">

        <i class="bi bi-calendar-check"></i>

        Attendance

    </a>


    <a href="exams.jsp">

        <i class="bi bi-file-earmark-text"></i>

        Exams

    </a>


    <a href="fees.jsp">

        <i class="bi bi-cash-stack"></i>

        Fees

    </a>


    <a href="notices.jsp">

        <i class="bi bi-megaphone"></i>

        Notices

    </a>


    <hr style="border-color:#374151;">


    <a href="LogoutServlet">

        <i class="bi bi-box-arrow-right"></i>

        Logout

    </a>


</div>


<!-- =====================================================
     MAIN CONTENT
===================================================== -->

<div class="main">


    <!-- HEADER -->

    <div class="top-card mb-4">

        <div class="d-flex justify-content-between align-items-center">


            <div>

                <h2 class="page-title">

                    Add Teacher

                </h2>

                <p class="page-subtitle">

                    Add a new teacher to your school

                </p>

            </div>


            <a href="teachers.jsp"
               class="btn btn-outline-secondary cancel-btn">

                <i class="bi bi-arrow-left me-1"></i>

                Back to Teachers

            </a>


        </div>

    </div>


    <!-- =================================================
         ERROR MESSAGES
    ================================================= -->

    <%

        String error = request.getParameter("error");

    %>


    <% if ("required".equals(error)) { %>

        <div class="alert alert-danger alert-dismissible fade show">

            <i class="bi bi-exclamation-triangle-fill me-2"></i>

            Please fill all required fields.

            <button type="button"
                    class="btn-close"
                    data-bs-dismiss="alert">
            </button>

        </div>

    <% } %>


    <% if ("username".equals(error)) { %>

        <div class="alert alert-danger alert-dismissible fade show">

            <i class="bi bi-exclamation-triangle-fill me-2"></i>

            Username already exists.

            <button type="button"
                    class="btn-close"
                    data-bs-dismiss="alert">
            </button>

        </div>

    <% } %>


    <% if ("email".equals(error)) { %>

        <div class="alert alert-danger alert-dismissible fade show">

            <i class="bi bi-exclamation-triangle-fill me-2"></i>

            Email already exists.

            <button type="button"
                    class="btn-close"
                    data-bs-dismiss="alert">
            </button>

        </div>

    <% } %>


    <% if ("employeeCode".equals(error)) { %>

        <div class="alert alert-danger alert-dismissible fade show">

            <i class="bi bi-exclamation-triangle-fill me-2"></i>

            Employee code already exists.

            <button type="button"
                    class="btn-close"
                    data-bs-dismiss="alert">
            </button>

        </div>

    <% } %>


    <% if ("failed".equals(error)) { %>

        <div class="alert alert-danger alert-dismissible fade show">

            <i class="bi bi-exclamation-triangle-fill me-2"></i>

            Failed to add teacher. Please try again.

            <button type="button"
                    class="btn-close"
                    data-bs-dismiss="alert">
            </button>

        </div>

    <% } %>


    <!-- =================================================
         FORM CARD
    ================================================= -->

    <div class="form-card">


        <form action="<%= request.getContextPath() %>/TeacherServlet"
              method="post">


            <!-- =================================================
                 PERSONAL INFORMATION
            ================================================= -->

            <div class="section-header">

                <h5 class="section-title">

                    <i class="bi bi-person-badge me-2 text-primary"></i>

                    Personal Information

                </h5>

                <div class="section-subtitle">

                    Enter the teacher's basic personal details.

                </div>

            </div>


            <div class="row g-4">


                <!-- FIRST NAME -->

                <div class="col-md-6">

                    <label class="form-label">

                        First Name

                        <span class="required">*</span>

                    </label>

                    <input type="text"
                           name="firstName"
                           class="form-control"
                           placeholder="Enter first name"
                           required>

                </div>


                <!-- LAST NAME -->

                <div class="col-md-6">

                    <label class="form-label">

                        Last Name

                    </label>

                    <input type="text"
                           name="lastName"
                           class="form-control"
                           placeholder="Enter last name">

                </div>


                <!-- DATE OF BIRTH -->

                <div class="col-md-4">

                    <label class="form-label">

                        Date of Birth

                    </label>

                    <input type="date"
                           name="dateOfBirth"
                           class="form-control">

                </div>


                <!-- GENDER -->

                <div class="col-md-4">

                    <label class="form-label">

                        Gender

                    </label>

                    <select name="gender"
                            class="form-select">

                        <option value="">
                            Select Gender
                        </option>

                        <option value="MALE">
                            Male
                        </option>

                        <option value="FEMALE">
                            Female
                        </option>

                        <option value="OTHER">
                            Other
                        </option>

                    </select>

                </div>


                <!-- PHONE -->

                <div class="col-md-4">

                    <label class="form-label">

                        Phone

                    </label>

                    <input type="text"
                           name="phone"
                           class="form-control"
                           placeholder="Enter phone number">

                </div>


                <!-- ADDRESS -->

                <div class="col-12">

                    <label class="form-label">

                        Address

                    </label>

                    <textarea name="address"
                              class="form-control"
                              rows="3"
                              placeholder="Enter address"></textarea>

                </div>

            </div>


            <!-- =================================================
                 ACCOUNT INFORMATION
            ================================================= -->

            <div class="section-header mt-5">

                <h5 class="section-title">

                    <i class="bi bi-shield-lock me-2 text-primary"></i>

                    Account Information

                </h5>

                <div class="section-subtitle">

                    Create login credentials for the teacher.

                </div>

            </div>


            <div class="row g-4">


                <!-- USERNAME -->

                <div class="col-md-6">

                    <label class="form-label">

                        Username

                        <span class="required">*</span>

                    </label>

                    <input type="text"
                           name="username"
                           class="form-control"
                           placeholder="Enter username"
                           required>

                </div>


                <!-- EMAIL -->

                <div class="col-md-6">

                    <label class="form-label">

                        Email

                        <span class="required">*</span>

                    </label>

                    <input type="email"
                           name="email"
                           class="form-control"
                           placeholder="Enter email address"
                           required>

                </div>


                <!-- PASSWORD -->

                <div class="col-md-6">

                    <label class="form-label">

                        Password

                        <span class="required">*</span>

                    </label>

                    <input type="password"
                           name="password"
                           class="form-control"
                           placeholder="Enter password"
                           required>

                </div>

            </div>


            <!-- =================================================
                 PROFESSIONAL INFORMATION
            ================================================= -->

            <div class="section-header mt-5">

                <h5 class="section-title">

                    <i class="bi bi-briefcase me-2 text-primary"></i>

                    Professional Information

                </h5>

                <div class="section-subtitle">

                    Enter employment and qualification details.

                </div>

            </div>


            <div class="row g-4">


                <!-- EMPLOYEE CODE -->

                <div class="col-md-6">

                    <label class="form-label">

                        Employee Code

                        <span class="required">*</span>

                    </label>

                    <input type="text"
                           name="employeeCode"
                           class="form-control"
                           placeholder="Example: EMP001"
                           required>

                </div>


                <!-- QUALIFICATION -->

                <div class="col-md-6">

                    <label class="form-label">

                        Qualification

                    </label>

                    <input type="text"
                           name="qualification"
                           class="form-control"
                           placeholder="Example: B.Ed, M.Ed, M.Sc">

                </div>


                <!-- SPECIALIZATION -->

                <div class="col-md-6">

                    <label class="form-label">

                        Specialization

                    </label>

                    <input type="text"
                           name="specialization"
                           class="form-control"
                           placeholder="Example: Mathematics">

                </div>


                <!-- JOINING DATE -->

                <div class="col-md-3">

                    <label class="form-label">

                        Joining Date

                    </label>

                    <input type="date"
                           name="joiningDate"
                           class="form-control">

                </div>


                <!-- EXPERIENCE -->

                <div class="col-md-3">

                    <label class="form-label">

                        Experience Years

                    </label>

                    <input type="number"
                           step="0.1"
                           min="0"
                           name="experienceYears"
                           class="form-control"
                           placeholder="0">

                </div>

            </div>


            <!-- =================================================
                 BUTTONS
            ================================================= -->

            <div class="d-flex justify-content-end gap-2 mt-5 pt-3 border-top">


                <a href="teachers.jsp"
                   class="btn btn-outline-secondary cancel-btn">

                    <i class="bi bi-x-lg me-1"></i>

                    Cancel

                </a>


                <button type="submit"
                        class="btn btn-primary add-btn">

                    <i class="bi bi-person-plus-fill me-1"></i>

                    Add Teacher

                </button>


            </div>


        </form>

    </div>


</div>


<!-- Bootstrap JS -->

<script
    src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.bundle.min.js">
</script>


</body>

</html>
