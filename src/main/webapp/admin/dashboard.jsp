<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="com.school.dao.DashboardDAO"%>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session == null
            || session.getAttribute("userId") == null
            || !"ADMIN".equals(session.getAttribute("role"))) {

        response.sendRedirect(request.getContextPath() + "/login.html");
        return;
    }

    DashboardDAO dashboardDAO = new DashboardDAO();

    // Read admin's school from session
    Object schoolIdObj = session.getAttribute("schoolId");

    int schoolId = (schoolIdObj != null)
            ? Integer.parseInt(schoolIdObj.toString())
            : 0;

    int totalStudents = dashboardDAO.getTotalStudents(schoolId);
    int totalTeachers = dashboardDAO.getTotalTeachers(schoolId);
    int totalClasses = dashboardDAO.getTotalClasses(schoolId);
    int totalSubjects = dashboardDAO.getTotalSubjects(schoolId);
    int todayAttendance = dashboardDAO.getTodayAttendance(schoolId);
    int pendingFees = dashboardDAO.getPendingFees(schoolId);
    int upcomingExams = dashboardDAO.getUpcomingExams(schoolId);
    int publishedNotices = dashboardDAO.getPublishedNotices(schoolId);

    String firstName = (String) session.getAttribute("firstName");
    String lastName = (String) session.getAttribute("lastName");

    String adminName = "";

    if (firstName != null && !firstName.trim().isEmpty()) {
        adminName = firstName.trim();
    }

    if (lastName != null && !lastName.trim().isEmpty()) {

        if (!adminName.isEmpty()) {
            adminName = adminName + " " + lastName.trim();
        } else {
            adminName = lastName.trim();
        }
    }

    if (adminName.isEmpty()) {
        adminName = "Admin";
    }

    String firstLetter = adminName.substring(0, 1).toUpperCase();

    // Fee percentages
    int paidPercentage = 70;
    int pendingPercentage = 30;
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
        content="width=device-width, initial-scale=1.0">

    <title>Admin Dashboard | School Management</title>

    <!-- Bootstrap -->
    <link
        href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css"
        rel="stylesheet">

    <!-- Bootstrap Icons -->
    <link
        href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css"
        rel="stylesheet">

    <style>

        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            font-family: "Segoe UI", Arial, sans-serif;
            background: #f5f7fb;
            color: #1e293b;
        }

        /* =========================================
           SIDEBAR
        ========================================= */

        .sidebar {
            position: fixed;
            top: 0;
            left: 0;
            width: 258px;
            height: 100vh;

            background: linear-gradient(
                180deg,
                #2563eb 0%,
                #1d4ed8 55%,
                #1e40af 100%
            );

            color: white;
            padding: 22px 17px;

            z-index: 1000;

            transition: width 0.3s ease;

            overflow-y: auto;
            overflow-x: visible;
        }

        .sidebar::-webkit-scrollbar {
            width: 5px;
        }

        .sidebar::-webkit-scrollbar-thumb {
            background: rgba(255, 255, 255, 0.25);
            border-radius: 10px;
        }

        /* =========================================
           BRAND
        ========================================= */

        .brand {
            display: flex;
            align-items: center;
            gap: 12px;

            padding: 4px 8px 25px;

            white-space: nowrap;
        }

        .brand-icon {
            width: 44px;
            height: 44px;

            border-radius: 12px;

            background: rgba(255, 255, 255, 0.18);

            display: flex;
            align-items: center;
            justify-content: center;

            font-size: 21px;

            flex-shrink: 0;
        }

        .brand-text {
            font-size: 19px;
            font-weight: 700;
        }

        .brand-subtitle {
            font-size: 12px;
            opacity: 0.75;
            margin-top: 2px;
        }

        /* =========================================
           SIDEBAR TOGGLE
        ========================================= */

        .sidebar-toggle {
            position: fixed !important;

            top: 28px !important;
            left: 239px !important;

            right: auto !important;

            width: 38px !important;
            height: 38px !important;

            border: 3px solid #f5f7fb !important;
            border-radius: 50% !important;

            background: #ffffff !important;
            color: #2563eb !important;

            display: flex !important;
            align-items: center !important;
            justify-content: center !important;

            padding: 0 !important;
            margin: 0 !important;

            cursor: pointer !important;

            z-index: 99999 !important;

            box-shadow: 0 3px 12px rgba(0, 0, 0, 0.20) !important;

            transition:
                background 0.2s ease,
                box-shadow 0.2s ease,
                left 0.3s ease !important;
        }

        .sidebar-toggle:hover {
            background: #eff6ff !important;

            box-shadow:
                0 5px 15px rgba(0, 0, 0, 0.25) !important;
        }

        .sidebar-toggle .toggle-arrow {
            display: block !important;

            width: 18px !important;
            height: 18px !important;

            visibility: visible !important;
            opacity: 1 !important;

            color: #2563eb !important;

            flex-shrink: 0;

            transition: transform 0.3s ease;
        }

        .sidebar.collapsed .sidebar-toggle {
            left: 61px !important;
        }

        .sidebar.collapsed .sidebar-toggle .toggle-arrow {
            transform: rotate(180deg);
        }

        /* =========================================
           MENU
        ========================================= */

        .menu-title {
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: 1px;

            opacity: 0.65;

            margin: 17px 10px 8px;
        }

        .sidebar a {
            display: flex;
            align-items: center;

            gap: 13px;

            color: rgba(255, 255, 255, 0.88);

            text-decoration: none;

            padding: 11px 12px;
            margin: 3px 0;

            border-radius: 9px;

            font-size: 14px;

            white-space: nowrap;

            transition: 0.2s ease;
        }

        .sidebar a i {
            font-size: 17px;
            width: 22px;

            text-align: center;

            flex-shrink: 0;
        }

        .sidebar a:hover,
        .sidebar a.active {
            background: rgba(255, 255, 255, 0.16);
            color: white;
        }

        /* =========================================
           COLLAPSED SIDEBAR
        ========================================= */

        .sidebar.collapsed {
            width: 80px;
        }

        .sidebar.collapsed .brand-text,
        .sidebar.collapsed .brand-subtitle,
        .sidebar.collapsed .menu-title,
        .sidebar.collapsed a span {
            display: none;
        }

        .sidebar.collapsed .brand {
            justify-content: center;

            padding-left: 0;
            padding-right: 0;
        }

        .sidebar.collapsed a {
            justify-content: center;

            padding-left: 10px;
            padding-right: 10px;
        }

        /* =========================================
           MAIN
        ========================================= */

        .main {
            margin-left: 258px;

            min-height: 100vh;

            transition: margin-left 0.3s ease;
        }

        .main.sidebar-collapsed {
            margin-left: 80px;
        }

        /* =========================================
           TOPBAR
        ========================================= */

        .topbar {
            height: 70px;

            background: white;

            border-bottom: 1px solid #e5e7eb;

            display: flex;
            align-items: center;
            justify-content: space-between;

            padding: 0 30px;
        }

        .topbar-title {
            font-size: 21px;
            font-weight: 700;

            color: #0f172a;
        }

        .topbar-subtitle {
            font-size: 12px;

            color: #64748b;

            margin-top: 2px;
        }

        .profile {
            display: flex;
            align-items: center;

            gap: 10px;
        }

        .notification {
            width: 40px;
            height: 40px;

            border-radius: 12px;

            background: #f1f5ff;

            color: #2563eb;

            display: flex;
            align-items: center;
            justify-content: center;

            margin-right: 12px;

            position: relative;
        }

        .notification-dot {
            position: absolute;

            top: 8px;
            right: 9px;

            width: 5px;
            height: 5px;

            background: #ef4444;

            border-radius: 50%;
        }

        .profile-avatar {
            width: 40px;
            height: 40px;

            border-radius: 50%;

            background: linear-gradient(
                135deg,
                #2563eb,
                #7c3aed
            );

            color: white;

            display: flex;
            align-items: center;
            justify-content: center;

            font-weight: 700;
            font-size: 15px;
        }

        .profile-info strong {
            display: block;

            font-size: 13px;

            color: #111827;
        }

        .profile-info small {
            display: block;

            font-size: 11px;

            color: #64748b;
        }

        /* =========================================
           CONTENT
        ========================================= */

        .content {
            padding: 0 30px 30px;
        }

        /* =========================================
           WELCOME CARD
        ========================================= */

        .welcome-card {
            background: linear-gradient(
                135deg,
                #2563eb,
                #4f46e5
            );

            color: white;

            border-radius: 0 0 18px 18px;

            padding: 25px 30px;

            margin-bottom: 25px;

            position: relative;

            overflow: hidden;
        }

        .welcome-card::after {
            content: "";

            position: absolute;

            width: 190px;
            height: 190px;

            border-radius: 50%;

            background: rgba(255, 255, 255, 0.08);

            right: -55px;
            top: -75px;
        }

        .welcome-card h2 {
            margin: 0 0 7px;

            font-size: 26px;

            font-weight: 700;

            position: relative;

            z-index: 2;
        }

        .welcome-card p {
            margin: 0;

            opacity: 0.88;

            font-size: 14px;

            position: relative;

            z-index: 2;
        }

        /* =========================================
           SECTION TITLE
        ========================================= */

        .section-heading {
            display: flex;

            align-items: center;
            justify-content: space-between;

            margin-bottom: 15px;
        }

        .section-heading h5 {
            margin: 0;

            font-size: 19px;

            font-weight: 700;

            color: #111827;
        }

        .section-heading span {
            font-size: 12px;

            color: #64748b;
        }

        /* =========================================
           STAT CARDS
        ========================================= */

        .stat-card {
            background: white;

            border-radius: 15px;

            padding: 20px;

            border: 1px solid #e8edf4;

            box-shadow:
                0 4px 15px rgba(15, 23, 42, 0.04);

            height: 100%;

            transition: 0.25s ease;
        }

        .stat-card:hover {
            transform: translateY(-3px);

            box-shadow:
                0 8px 22px rgba(15, 23, 42, 0.08);
        }

        .stat-top {
            display: flex;

            align-items: center;
            justify-content: space-between;
        }

        .stat-icon {
            width: 47px;
            height: 47px;

            border-radius: 12px;

            display: flex;
            align-items: center;
            justify-content: center;

            font-size: 20px;
        }

        .blue-icon {
            background: #dbeafe;
            color: #2563eb;
        }

        .green-icon {
            background: #dcfce7;
            color: #16a34a;
        }

        .purple-icon {
            background: #ede9fe;
            color: #7c3aed;
        }

        .orange-icon {
            background: #ffedd5;
            color: #ea580c;
        }

        .yellow-icon {
            background: #fef3c7;
            color: #d97706;
        }

        .red-icon {
            background: #fee2e2;
            color: #dc2626;
        }

        .cyan-icon {
            background: #cffafe;
            color: #0891b2;
        }

        .pink-icon {
            background: #fce7f3;
            color: #db2777;
        }

        .stat-number {
            font-size: 28px;

            font-weight: 750;

            margin-top: 14px;

            color: #111827;
        }

        .stat-label {
            font-size: 13px;

            color: #64748b;

            margin-top: 2px;
        }

        /* =========================================
           ANALYTICS
        ========================================= */

        .analytics-card {
            background: white;

            border-radius: 15px;

            padding: 22px;

            border: 1px solid #e8edf4;

            height: 100%;

            box-shadow:
                0 4px 15px rgba(15, 23, 42, 0.04);
        }

        .analytics-title {
            display: flex;

            align-items: center;
            justify-content: space-between;

            margin-bottom: 20px;
        }

        .analytics-title h6 {
            margin: 0;

            font-size: 15px;

            font-weight: 700;
        }

        .analytics-title i {
            font-size: 18px;

            color: #2563eb;
        }

        .analytics-right-text {
            color: #64748b;

            font-size: 12px;
        }

        /* =========================================
           ATTENDANCE
        ========================================= */

        .attendance-wrapper {
            display: flex;

            align-items: center;
            justify-content: center;

            gap: 45px;

            min-height: 150px;
        }

        .attendance-circle {
            width: 130px;
            height: 130px;

            border-radius: 50%;

            background:
                conic-gradient(
                    #2563eb 0deg 280deg,
                    #e5e7eb 280deg 360deg
                );

            display: flex;

            align-items: center;
            justify-content: center;

            flex-shrink: 0;
        }

        .attendance-inner {
            width: 94px;
            height: 94px;

            background: white;

            border-radius: 50%;

            display: flex;

            align-items: center;
            justify-content: center;

            flex-direction: column;
        }

        .attendance-inner strong {
            font-size: 24px;

            color: #2563eb;
        }

        .attendance-inner small {
            font-size: 10px;

            color: #64748b;
        }

        .attendance-info strong {
            display: block;

            font-size: 18px;
        }

        .attendance-info span {
            color: #64748b;

            font-size: 12px;
        }

        /* =========================================
           FEE OVERVIEW
        ========================================= */

        .fee-row {
            margin-bottom: 20px;
        }

        .fee-label-row {
            display: flex;

            align-items: center;
            justify-content: space-between;

            margin-bottom: 8px;
        }

        .fee-label-row strong {
            font-size: 14px;

            color: #334155;
        }

        .fee-label-row span {
            font-size: 13px;

            font-weight: 700;

            color: #111827;
        }

        .fee-progress {
            height: 9px;

            background: #e9eef5;

            border-radius: 20px;

            overflow: hidden;
        }

        .fee-paid-bar {
            height: 100%;

            width: <%=paidPercentage%>%;

            background: #198754;

            border-radius: 20px;

            transition: width 0.5s ease;
        }

        .fee-pending-bar {
            height: 100%;

            width: <%=pendingPercentage%>%;

            background: #f59e0b;

            border-radius: 20px;

            transition: width 0.5s ease;
        }

        .pending-info {
            display: flex;

            align-items: center;
            justify-content: space-between;

            margin-top: 8px;
        }

        .pending-info-left {
            display: flex;

            align-items: center;

            gap: 8px;
        }

        .pending-dot {
            width: 9px;
            height: 9px;

            background: #f59e0b;

            border-radius: 50%;
        }

        .pending-info span {
            font-size: 12px;

            color: #64748b;
        }

        .pending-info strong {
            font-size: 13px;

            color: #92400e;
        }

        .fee-status {
            margin-top: 17px;

            padding-top: 15px;

            border-top: 1px solid #eef2f7;

            display: flex;

            justify-content: space-between;
            align-items: center;
        }

        .fee-status small {
            display: block;

            color: #64748b;

            font-size: 11px;
        }

        .fee-status strong {
            font-size: 16px;

            color: #111827;
        }

        .on-track {
            color: #198754 !important;

            font-size: 13px !important;
        }

        /* =========================================
           LOWER CARDS
        ========================================= */

        .exam-card,
        .notice-card,
        .quick-card {
            background: white;

            border-radius: 15px;

            border: 1px solid #e8edf4;

            padding: 21px;

            height: 100%;

            box-shadow:
                0 4px 15px rgba(15, 23, 42, 0.04);
        }

        .exam-item {
            display: flex;

            align-items: center;

            gap: 12px;

            padding: 12px 0;

            border-bottom: 1px solid #eef2f7;
        }

        .exam-item:last-child {
            border-bottom: none;
        }

        .exam-icon {
            width: 38px;
            height: 38px;

            border-radius: 10px;

            background: #eff6ff;

            color: #2563eb;

            display: flex;

            align-items: center;
            justify-content: center;

            flex-shrink: 0;
        }

        .exam-info strong {
            display: block;

            font-size: 13px;

            color: #111827;
        }

        .exam-info small {
            color: #64748b;

            font-size: 11px;
        }

        /* =========================================
           SCIENCE ICON
        ========================================= */

        .science-icon {
            display: block !important;

            width: 20px !important;
            height: 20px !important;

            color: #2563eb !important;

            visibility: visible !important;

            opacity: 1 !important;

            flex-shrink: 0;
        }

        /* =========================================
           NOTICES
        ========================================= */

        .notice-item {
            padding: 12px 0;

            border-bottom: 1px solid #eef2f7;
        }

        .notice-item:last-child {
            border-bottom: none;
        }

        .notice-item strong {
            display: block;

            font-size: 13px;

            color: #111827;
        }

        .notice-item small {
            display: block;

            color: #64748b;

            font-size: 11px;

            margin-top: 3px;
        }

        /* =========================================
           QUICK ACTIONS
        ========================================= */

        .quick-action {
            display: flex;

            align-items: center;

            gap: 12px;

            padding: 10px;

            border-radius: 10px;

            text-decoration: none;

            color: #334155;

            transition: 0.2s ease;
        }

        .quick-action:hover {
            background: #f8fafc;

            color: #2563eb;
        }

        .quick-icon {
            width: 38px;
            height: 38px;

            border-radius: 10px;

            background: #eff6ff;

            color: #2563eb;

            display: flex;

            align-items: center;
            justify-content: center;
        }

        .quick-action span {
            font-size: 13px;

            font-weight: 600;
        }

        /* =========================================
           RESPONSIVE
        ========================================= */

        @media (max-width: 992px) {

            .sidebar {
                width: 250px;
            }

            .sidebar.collapsed {
                width: 80px;
            }

            .main {
                margin-left: 250px;
            }

            .main.sidebar-collapsed {
                margin-left: 80px;
            }

            .content {
                padding: 0 22px 22px;
            }

            .sidebar-toggle {
                left: 231px !important;
            }

            .sidebar.collapsed .sidebar-toggle {
                left: 61px !important;
            }
        }

        @media (max-width: 768px) {

            .topbar {
                padding: 0 18px;
            }

            .topbar-title {
                font-size: 17px;
            }

            .topbar-subtitle {
                display: none;
            }

            .profile-info {
                display: none;
            }

            .content {
                padding: 0 18px 18px;
            }

            .welcome-card {
                padding: 23px;
            }

            .welcome-card h2 {
                font-size: 22px;
            }

            .attendance-wrapper {
                gap: 25px;
            }
        }

        @media (max-width: 576px) {

            .sidebar {
                display: none;
            }

            .main,
            .main.sidebar-collapsed {
                margin-left: 0;
            }

            .content {
                padding: 0 15px 15px;
            }

            .topbar {
                height: 65px;
            }

            .notification {
                margin-right: 5px;
            }

            .sidebar-toggle {
                display: none !important;
            }
        }

    </style>

</head>

<body>

    <!-- =========================================
         SIDEBAR
    ========================================= -->

    <aside class="sidebar" id="sidebar">

        <!-- TOGGLE BUTTON -->

        <button
            type="button"
            class="sidebar-toggle"
            id="sidebarToggle"
            aria-label="Toggle Sidebar">

            <svg
                class="toggle-arrow"
                viewBox="0 0 24 24"
                width="18"
                height="18"
                aria-hidden="true">

                <path
                    d="M15 6L9 12L15 18"
                    fill="none"
                    stroke="currentColor"
                    stroke-width="3"
                    stroke-linecap="round"
                    stroke-linejoin="round">
                </path>

            </svg>

        </button>

        <!-- BRAND -->

        <div class="brand">

            <div class="brand-icon">
                <i class="bi bi-mortarboard-fill"></i>
            </div>

            <div>

                <div class="brand-text">
                    School Portal
                </div>

                <div class="brand-subtitle">
                    Administration
                </div>

            </div>

        </div>


        <!-- MAIN MENU -->

        <div class="menu-title">
            Main
        </div>

        <a href="#" class="active">

            <i class="bi bi-grid-1x2-fill"></i>

            <span>
                Overview
            </span>

        </a>

        <a href="${pageContext.request.contextPath}/admin/students.jsp">

            <i class="bi bi-people-fill"></i>

            <span>
                Students
            </span>

        </a>

        <a href="${pageContext.request.contextPath}/admin/teachers.jsp">

            <i class="bi bi-person-badge"></i>

            <span>
                Teachers
            </span>

        </a>

        <a href="${pageContext.request.contextPath}/admin/classes.jsp">

            <i class="bi bi-building"></i>

            <span>
                Classes
            </span>

        </a>

        <a href="${pageContext.request.contextPath}/admin/subjects.jsp">

            <i class="bi bi-book-fill"></i>

            <span>
                Subjects
            </span>

        </a>


        <!-- ACADEMICS -->

        <div class="menu-title">
            Academics
        </div>

        <a href="#">

            <i class="bi bi-calendar-check-fill"></i>

            <span>
                Attendance
            </span>

        </a>

        <a href="#">

            <i class="bi bi-calendar3"></i>

            <span>
                Timetable
            </span>

        </a>

        <a href="#">

            <i class="bi bi-journal-text"></i>

            <span>
                Assignments
            </span>

        </a>

        <a href="#">

            <i class="bi bi-file-earmark-text-fill"></i>

            <span>
                Examinations
            </span>

        </a>

        <a href="#">

            <i class="bi bi-bar-chart-fill"></i>

            <span>
                Results
            </span>

        </a>


        <!-- ADMINISTRATION -->

        <div class="menu-title">
            Administration
        </div>

        <a href="#">

            <i class="bi bi-wallet2"></i>

            <span>
                Fees
            </span>

        </a>

        <a href="#">

            <i class="bi bi-megaphone-fill"></i>

            <span>
                Notices
            </span>

        </a>

        <a href="#">

            <i class="bi bi-file-earmark-bar-graph-fill"></i>

            <span>
                Reports
            </span>

        </a>

        <a href="#">

            <i class="bi bi-gear-fill"></i>

            <span>
                Settings
            </span>

        </a>

        <!-- LOGOUT -->

        <a href="<%=request.getContextPath()%>/LogoutServlet">

            <i class="bi bi-box-arrow-right"></i>

            <span>
                Logout
            </span>

        </a>

    </aside>


    <!-- =========================================
         MAIN
    ========================================= -->

    <main class="main" id="main">

        <!-- TOPBAR -->

        <header class="topbar">

            <div>

                <div class="topbar-title">
                    Admin Workspace
                </div>

                <div class="topbar-subtitle">
                    Manage your school operations from one place
                </div>

            </div>


            <div class="profile">

                <div class="notification">

                    <i class="bi bi-bell-fill"></i>

                    <span class="notification-dot"></span>

                </div>

                <div class="profile-avatar">
                    <%=firstLetter%>
                </div>

                <div class="profile-info">

                    <strong>
                        <%=adminName%>
                    </strong>

                    <small>
                        Administrator
                    </small>

                </div>

            </div>

        </header>


        <!-- CONTENT -->

        <section class="content">

            <!-- WELCOME -->

            <div class="welcome-card">

                <h2>
                    Welcome back, <%=adminName%>! 👋
                </h2>

                <p>
                    Manage your school, stay organized, and keep everything
                    running smoothly.
                </p>

            </div>


            <!-- TODAY'S SUMMARY -->

            <div class="section-heading">

                <div>

                    <h5>
                        Today's Summary
                    </h5>

                </div>

                <span>
                    School Overview
                </span>

            </div>


            <!-- FIRST ROW -->

            <div class="row g-3 mb-3">

                <!-- TOTAL STUDENTS -->

                <div class="col-xl-3 col-md-6">

                    <div class="stat-card">

                        <div class="stat-top">

                            <div class="stat-icon blue-icon">

                                <i class="bi bi-people-fill"></i>

                            </div>

                        </div>

                        <div class="stat-number">
                            <%=totalStudents%>
                        </div>

                        <div class="stat-label">
                            Total Students
                        </div>

                    </div>

                </div>


                <!-- TOTAL TEACHERS -->

                <div class="col-xl-3 col-md-6">

                    <div class="stat-card">

                        <div class="stat-top">

                            <div class="stat-icon green-icon">

                                <i class="bi bi-person-workspace"></i>

                            </div>

                        </div>

                        <div class="stat-number">
                            <%=totalTeachers%>
                        </div>

                        <div class="stat-label">
                            Total Teachers
                        </div>

                    </div>

                </div>


                <!-- TOTAL CLASSES -->

                <div class="col-xl-3 col-md-6">

                    <div class="stat-card">

                        <div class="stat-top">

                            <div class="stat-icon purple-icon">

                                <i class="bi bi-building"></i>

                            </div>

                        </div>

                        <div class="stat-number">
                            <%=totalClasses%>
                        </div>

                        <div class="stat-label">
                            Total Classes
                        </div>

                    </div>

                </div>


                <!-- TOTAL SUBJECTS -->

                <div class="col-xl-3 col-md-6">

                    <div class="stat-card">

                        <div class="stat-top">

                            <div class="stat-icon orange-icon">

                                <i class="bi bi-book-fill"></i>

                            </div>

                        </div>

                        <div class="stat-number">
                            <%=totalSubjects%>
                        </div>

                        <div class="stat-label">
                            Total Subjects
                        </div>

                    </div>

                </div>

            </div>


            <!-- SECOND ROW -->

            <div class="row g-3 mb-4">

                <!-- ATTENDANCE -->

                <div class="col-xl-3 col-md-6">

                    <div class="stat-card">

                        <div class="stat-top">

                            <div class="stat-icon cyan-icon">

                                <i class="bi bi-calendar-check-fill"></i>

                            </div>

                        </div>

                        <div class="stat-number">
                            <%=todayAttendance%>%
                        </div>

                        <div class="stat-label">
                            Today's Attendance
                        </div>

                    </div>

                </div>


                <!-- PENDING FEES -->

                <div class="col-xl-3 col-md-6">

                    <div class="stat-card">

                        <div class="stat-top">

                            <div class="stat-icon yellow-icon">

                                <i class="bi bi-wallet2"></i>

                            </div>

                        </div>

                        <div class="stat-number">
                            <%=pendingFees%>
                        </div>

                        <div class="stat-label">
                            Pending Fees
                        </div>

                    </div>

                </div>


                <!-- UPCOMING EXAMS -->

                <div class="col-xl-3 col-md-6">

                    <div class="stat-card">

                        <div class="stat-top">

                            <div class="stat-icon red-icon">

                                <i class="bi bi-file-earmark-text-fill"></i>

                            </div>

                        </div>

                        <div class="stat-number">
                            <%=upcomingExams%>
                        </div>

                        <div class="stat-label">
                            Upcoming Exams
                        </div>

                    </div>

                </div>


                <!-- ACTIVE NOTICES -->

                <div class="col-xl-3 col-md-6">

                    <div class="stat-card">

                        <div class="stat-top">

                            <div class="stat-icon pink-icon">

                                <i class="bi bi-megaphone-fill"></i>

                            </div>

                        </div>

                        <div class="stat-number">
                            <%=publishedNotices%>
                        </div>

                        <div class="stat-label">
                            Active Notices
                        </div>

                    </div>

                </div>

            </div>


            <!-- ANALYTICS -->

            <div class="section-heading">

                <div>

                    <h5>
                        Analytics
                    </h5>

                </div>

                <span>
                    Current performance
                </span>

            </div>


            <div class="row g-3 mb-4">

                <!-- ATTENDANCE OVERVIEW -->

                <div class="col-lg-6">

                    <div class="analytics-card">

                        <div class="analytics-title">

                            <h6>
                                Attendance Overview
                            </h6>

                            <span class="analytics-right-text">
                                Today
                            </span>

                        </div>


                        <div class="attendance-wrapper">

                            <div class="attendance-circle">

                                <div class="attendance-inner">

                                    <strong>
                                        78%
                                    </strong>

                                    <small>
                                        Overall
                                    </small>

                                </div>

                            </div>


                            <div class="attendance-info">

                                <strong>
                                    <%=todayAttendance%>%
                                </strong>

                                <span>
                                    Today's Attendance
                                </span>

                                <br>
                                <br>

                                <strong>
                                    Good
                                </strong>

                                <span>
                                    Attendance status
                                </span>

                            </div>

                        </div>

                    </div>

                </div>


                <!-- FEE OVERVIEW -->

                <div class="col-lg-6">

                    <div class="analytics-card">

                        <div class="analytics-title">

                            <h6>
                                Fee Overview
                            </h6>

                            <span class="analytics-right-text">
                                Current session
                            </span>

                        </div>


                        <!-- FEES PAID -->

                        <div class="fee-row">

                            <div class="fee-label-row">

                                <strong>
                                    Fees Paid
                                </strong>

                                <span>
                                    <%=paidPercentage%>%
                                </span>

                            </div>

                            <div class="fee-progress">

                                <div class="fee-paid-bar"></div>

                            </div>

                        </div>


                        <!-- PENDING -->

                        <div class="fee-row">

                            <div class="fee-label-row">

                                <strong>
                                    Pending
                                </strong>

                                <span>
                                    <%=pendingPercentage%>%
                                </span>

                            </div>

                            <div class="fee-progress">

                                <div class="fee-pending-bar"></div>

                            </div>


                            <div class="pending-info">

                                <div class="pending-info-left">

                                    <span class="pending-dot"></span>

                                    <span>
                                        Pending Fee Students
                                    </span>

                                </div>

                                <strong>
                                    <%=pendingFees%> Students
                                </strong>

                            </div>

                        </div>


                        <!-- STATUS -->

                        <div class="fee-status">

                            <div>

                                <small>
                                    Status
                                </small>

                                <strong>
                                    Fee Collection
                                </strong>

                            </div>

                            <div>

                                <span class="on-track">

                                    <i class="bi bi-check-circle-fill"></i>

                                    On Track

                                </span>

                            </div>

                        </div>

                    </div>

                </div>

            </div>


            <!-- LOWER SECTION -->

            <div class="row g-3">


                <!-- UPCOMING EXAMS -->

                <div class="col-lg-4">

                    <div class="exam-card">

                        <div class="analytics-title">

                            <h6>
                                Upcoming Exams
                            </h6>

                            <i class="bi bi-calendar-event"></i>

                        </div>


                        <!-- MATHEMATICS -->

                        <div class="exam-item">

                            <div class="exam-icon">

                                <i class="bi bi-calculator"></i>

                            </div>

                            <div class="exam-info">

                                <strong>
                                    Mathematics
                                </strong>

                                <small>
                                    Class 10 • 25 Sep
                                </small>

                            </div>

                        </div>


                        <!-- SCIENCE -->

                        <div class="exam-item">

                            <div class="exam-icon">

                                <svg
                                    class="science-icon"
                                    viewBox="0 0 24 24"
                                    width="20"
                                    height="20"
                                    aria-hidden="true">

                                    <path
                                        d="M9 3H15"
                                        fill="none"
                                        stroke="currentColor"
                                        stroke-width="2"
                                        stroke-linecap="round">
                                    </path>

                                    <path
                                        d="M10 3V9L5.2 17.4C4.5 18.6 5.4 20 6.8 20H17.2C18.6 20 19.5 18.6 18.8 17.4L14 9V3"
                                        fill="none"
                                        stroke="currentColor"
                                        stroke-width="2"
                                        stroke-linecap="round"
                                        stroke-linejoin="round">
                                    </path>

                                    <path
                                        d="M7.2 16H16.8"
                                        fill="none"
                                        stroke="currentColor"
                                        stroke-width="2"
                                        stroke-linecap="round">
                                    </path>

                                </svg>

                            </div>

                            <div class="exam-info">

                                <strong>
                                    Science
                                </strong>

                                <small>
                                    Class 10 • 28 Sep
                                </small>

                            </div>

                        </div>


                        <!-- ENGLISH -->

                        <div class="exam-item">

                            <div class="exam-icon">

                                <i class="bi bi-translate"></i>

                            </div>

                            <div class="exam-info">

                                <strong>
                                    English
                                </strong>

                                <small>
                                    Class 9 • 30 Sep
                                </small>

                            </div>

                        </div>

                    </div>

                </div>


                <!-- RECENT NOTICES -->

                <div class="col-lg-4">

                    <div class="notice-card">

                        <div class="analytics-title">

                            <h6>
                                Recent Notices
                            </h6>

                            <i class="bi bi-megaphone"></i>

                        </div>


                        <div class="notice-item">

                            <strong>
                                Parent-Teacher Meeting
                            </strong>

                            <small>
                                Meeting scheduled for next week.
                            </small>

                        </div>


                        <div class="notice-item">

                            <strong>
                                School Holiday
                            </strong>

                            <small>
                                School will remain closed.
                            </small>

                        </div>


                        <div class="notice-item">

                            <strong>
                                Examination Schedule
                            </strong>

                            <small>
                                New exam timetable published.
                            </small>

                        </div>

                    </div>

                </div>


                <!-- QUICK ACTIONS -->

                <div class="col-lg-4">

                    <div class="quick-card">

                        <div class="analytics-title">

                            <h6>
                                Quick Actions
                            </h6>

                            <i class="bi bi-lightning-charge-fill"></i>

                        </div>


                        <a href="#" class="quick-action">

                            <div class="quick-icon">

                                <i class="bi bi-person-plus-fill"></i>

                            </div>

                            <span>
                                Add Student
                            </span>

                        </a>


                        <a href="#" class="quick-action">

                            <div class="quick-icon">

                                <i class="bi bi-person-workspace"></i>

                            </div>

                            <span>
                                Add Teacher
                            </span>

                        </a>


                        <a href="#" class="quick-action">

                            <div class="quick-icon">

                                <i class="bi bi-megaphone-fill"></i>

                            </div>

                            <span>
                                Create Notice
                            </span>

                        </a>


                        <a href="#" class="quick-action">

                            <div class="quick-icon">

                                <i class="bi bi-calendar-plus-fill"></i>

                            </div>

                            <span>
                                Schedule Exam
                            </span>

                        </a>

                    </div>

                </div>

            </div>

        </section>

    </main>


    <!-- Bootstrap JS -->

    <script
        src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.bundle.min.js">
    </script>


    <!-- SIDEBAR TOGGLE -->

    <script>

        const sidebar =
            document.getElementById("sidebar");

        const main =
            document.getElementById("main");

        const sidebarToggle =
            document.getElementById("sidebarToggle");

        sidebarToggle.addEventListener(
            "click",
            function () {

                sidebar.classList.toggle("collapsed");

                main.classList.toggle("sidebar-collapsed");

            }
        );

    </script>

</body>

</html>
