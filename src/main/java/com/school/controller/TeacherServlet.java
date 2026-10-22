package com.school.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import com.school.dao.TeacherDAO;
import com.school.util.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/TeacherServlet")
public class TeacherServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private TeacherDAO teacherDAO;

    @Override
    public void init() throws ServletException {
        teacherDAO = new TeacherDAO();
    }

    // =========================================================
    // POST - ADD TEACHER
    // =========================================================

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // =====================================================
        // GET EXISTING SESSION
        // =====================================================

        HttpSession session = request.getSession(false);

        if (session == null) {

            response.setContentType("text/html;charset=UTF-8");

            response.getWriter().println(
                "<h2>Session Error</h2>"
            );

            response.getWriter().println(
                "<p>No active session was found.</p>"
            );

            response.getWriter().println(
                "<p>Please login again and then open Add Teacher.</p>"
            );

            return;
        }

        // =====================================================
        // GET USER ID
        // =====================================================

        Object userIdObject =
                session.getAttribute("userId");

        if (userIdObject == null) {

            response.setContentType("text/html;charset=UTF-8");

            response.getWriter().println(
                "<h2>User Session Error</h2>"
            );

            response.getWriter().println(
                "<p>userId is missing from the session.</p>"
            );

            response.getWriter().println(
                "<p>Please logout and login again.</p>"
            );

            return;
        }

        long userId;

        try {

            userId =
                Long.parseLong(
                    userIdObject.toString()
                );

        } catch (Exception e) {

            response.setContentType("text/html;charset=UTF-8");

            response.getWriter().println(
                "<h2>User ID Error</h2>"
            );

            response.getWriter().println(
                "<p>Invalid userId in session.</p>"
            );

            return;
        }


        // =====================================================
        // CHECK ROLE
        // =====================================================

        Object roleObject =
                session.getAttribute("role");

        if (roleObject == null ||
            !"ADMIN".equalsIgnoreCase(
                roleObject.toString()
            )) {

            response.setContentType("text/html;charset=UTF-8");

            response.getWriter().println(
                "<h2>Access Denied</h2>"
            );

            response.getWriter().println(
                "<p>Only an Admin can add teachers.</p>"
            );

            return;
        }


        // =====================================================
        // GET SCHOOL ID FROM DATABASE
        // =====================================================

        int schoolId = 0;

        String schoolSql =
                "SELECT school_id " +
                "FROM users " +
                "WHERE user_id = ?";

        try (
            Connection con =
                    DBConnection.getConnection();

            PreparedStatement ps =
                    con.prepareStatement(schoolSql)
        ) {

            ps.setLong(1, userId);

            try (ResultSet rs =
                    ps.executeQuery()) {

                if (rs.next()) {

                    schoolId =
                        rs.getInt("school_id");
                }
            }

        } catch (Exception e) {

            e.printStackTrace();

            response.setContentType(
                "text/html;charset=UTF-8"
            );

            response.getWriter().println(
                "<h2>Database Error</h2>"
            );

            response.getWriter().println(
                "<p>Unable to get school ID.</p>"
            );

            response.getWriter().println(
                "<p>" + e.getMessage() + "</p>"
            );

            return;
        }


        // =====================================================
        // CHECK SCHOOL ID
        // =====================================================

        if (schoolId <= 0) {

            response.setContentType(
                "text/html;charset=UTF-8"
            );

            response.getWriter().println(
                "<h2>School ID Error</h2>"
            );

            response.getWriter().println(
                "<p>No school is associated with this admin.</p>"
            );

            response.getWriter().println(
                "<p>User ID: " + userId + "</p>"
            );

            return;
        }


        // =====================================================
        // GET FORM DATA
        // =====================================================

        String firstName =
                request.getParameter("firstName");

        String lastName =
                request.getParameter("lastName");

        String username =
                request.getParameter("username");

        String email =
                request.getParameter("email");

        String password =
                request.getParameter("password");

        String phone =
                request.getParameter("phone");

        String employeeCode =
                request.getParameter("employeeCode");

        String qualification =
                request.getParameter("qualification");

        String specialization =
                request.getParameter("specialization");

        String joiningDate =
                request.getParameter("joiningDate");

        String experienceYears =
                request.getParameter("experienceYears");

        String dateOfBirth =
                request.getParameter("dateOfBirth");

        String gender =
                request.getParameter("gender");

        String address =
                request.getParameter("address");


        // =====================================================
        // BASIC VALIDATION
        // =====================================================

        if (firstName == null ||
            firstName.trim().isEmpty() ||

            username == null ||
            username.trim().isEmpty() ||

            email == null ||
            email.trim().isEmpty() ||

            password == null ||
            password.trim().isEmpty() ||

            employeeCode == null ||
            employeeCode.trim().isEmpty()) {

            response.sendRedirect(
                request.getContextPath()
                + "/admin/add-teacher.jsp?error=required"
            );

            return;
        }


        // =====================================================
        // TRIM VALUES
        // =====================================================

        firstName =
                firstName.trim();

        lastName =
                lastName == null
                ? ""
                : lastName.trim();

        username =
                username.trim();

        email =
                email.trim();

        password =
                password.trim();

        phone =
                phone == null
                ? ""
                : phone.trim();

        employeeCode =
                employeeCode.trim();

        qualification =
                qualification == null
                ? ""
                : qualification.trim();

        specialization =
                specialization == null
                ? ""
                : specialization.trim();

        joiningDate =
                joiningDate == null
                ? ""
                : joiningDate.trim();

        experienceYears =
                experienceYears == null
                ? ""
                : experienceYears.trim();

        dateOfBirth =
                dateOfBirth == null
                ? ""
                : dateOfBirth.trim();

        gender =
                gender == null
                ? ""
                : gender.trim();

        address =
                address == null
                ? ""
                : address.trim();


        // =====================================================
        // CHECK DUPLICATE USERNAME
        // =====================================================

        if (teacherDAO.usernameExists(username)) {

            response.sendRedirect(
                request.getContextPath()
                + "/admin/add-teacher.jsp?error=username"
            );

            return;
        }


        // =====================================================
        // CHECK DUPLICATE EMAIL
        // =====================================================

        if (teacherDAO.emailExists(email)) {

            response.sendRedirect(
                request.getContextPath()
                + "/admin/add-teacher.jsp?error=email"
            );

            return;
        }


        // =====================================================
        // CHECK DUPLICATE EMPLOYEE CODE
        // =====================================================

        if (teacherDAO.employeeCodeExists(employeeCode)) {

            response.sendRedirect(
                request.getContextPath()
                + "/admin/add-teacher.jsp?error=employeeCode"
            );

            return;
        }


        // =====================================================
        // ADD TEACHER
        // =====================================================

        boolean success = false;

        try {

            success =
                teacherDAO.addTeacher(
                    schoolId,
                    username,
                    email,
                    password,
                    firstName,
                    lastName,
                    phone,
                    employeeCode,
                    qualification,
                    specialization,
                    joiningDate,
                    experienceYears,
                    dateOfBirth,
                    gender,
                    address
                );

        } catch (Exception e) {

            e.printStackTrace();

            response.setContentType(
                "text/html;charset=UTF-8"
            );

            response.getWriter().println(
                "<h2>Error while adding teacher</h2>"
            );

            response.getWriter().println(
                "<p>" + e.getMessage() + "</p>"
            );

            return;
        }


        // =====================================================
        // RESULT
        // =====================================================

        if (success) {

            response.sendRedirect(
                request.getContextPath()
                + "/admin/teachers.jsp?success=added"
            );

        } else {

            response.sendRedirect(
                request.getContextPath()
                + "/admin/add-teacher.jsp?error=failed"
            );
        }
    }


    // =========================================================
    // GET - OPEN ADD TEACHER PAGE
    // =========================================================

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        response.sendRedirect(
            request.getContextPath()
            + "/admin/add-teacher.jsp"
        );
    }
}
