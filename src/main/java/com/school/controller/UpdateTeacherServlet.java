package com.school.controller;

import java.io.IOException;

import com.school.dao.TeacherDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/UpdateTeacherServlet")
public class UpdateTeacherServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private TeacherDAO teacherDAO;

    @Override
    public void init() throws ServletException {
        teacherDAO = new TeacherDAO();
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // =============================================
        // AUTH CHECK
        // =============================================
        HttpSession session = request.getSession(false);

        if (session == null ||
            session.getAttribute("userId") == null ||
            !"ADMIN".equals(session.getAttribute("role"))) {

            response.sendRedirect(
                    request.getContextPath() + "/login.html");
            return;
        }

        Object schoolIdObj = session.getAttribute("schoolId");
        if (schoolIdObj == null) {
            response.sendRedirect(
                    request.getContextPath() + "/admin/teachers.jsp");
            return;
        }

        int schoolId = Integer.parseInt(schoolIdObj.toString());

        // =============================================
        // GET FORM DATA
        // =============================================
        String teacherIdText    = request.getParameter("teacherId");
        String firstName        = request.getParameter("firstName");
        String lastName         = request.getParameter("lastName");
        String phone            = request.getParameter("phone");
        String employeeCode     = request.getParameter("employeeCode");
        String qualification    = request.getParameter("qualification");
        String specialization   = request.getParameter("specialization");
        String joiningDate      = request.getParameter("joiningDate");
        String experienceYears  = request.getParameter("experienceYears");
        String dateOfBirth      = request.getParameter("dateOfBirth");
        String gender           = request.getParameter("gender");
        String address          = request.getParameter("address");
        String status           = request.getParameter("status");

        long teacherId;

        try {
            teacherId = Long.parseLong(teacherIdText);
        } catch (Exception e) {
            response.sendRedirect(
                    request.getContextPath() + "/admin/teachers.jsp");
            return;
        }

        // =============================================
        // BASIC VALIDATION
        // =============================================
        if (firstName == null || firstName.trim().isEmpty() ||
            employeeCode == null || employeeCode.trim().isEmpty()) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/edit-teacher.jsp?id=" + teacherId
                    + "&error=required");
            return;
        }

        // =============================================
        // TRIM VALUES
        // =============================================
        firstName       = firstName.trim();
        lastName        = (lastName == null) ? "" : lastName.trim();
        phone           = (phone == null) ? "" : phone.trim();
        employeeCode    = employeeCode.trim();
        qualification   = (qualification == null) ? "" : qualification.trim();
        specialization  = (specialization == null) ? "" : specialization.trim();
        joiningDate     = (joiningDate == null) ? "" : joiningDate.trim();
        experienceYears = (experienceYears == null) ? "" : experienceYears.trim();
        dateOfBirth     = (dateOfBirth == null) ? "" : dateOfBirth.trim();
        gender          = (gender == null) ? "" : gender.trim();
        address         = (address == null) ? "" : address.trim();
        status          = (status == null || status.trim().isEmpty())
                        ? "ACTIVE" : status.trim();

        // =============================================
        // CHECK DUPLICATE EMPLOYEE CODE
        // =============================================
        if (teacherDAO.employeeCodeExistsExcept(employeeCode, teacherId)) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/edit-teacher.jsp?id=" + teacherId
                    + "&error=duplicate");
            return;
        }

        // =============================================
        // UPDATE
        // =============================================
        boolean success = teacherDAO.updateTeacher(
                teacherId, schoolId,
                firstName, lastName, phone,
                employeeCode, qualification, specialization,
                joiningDate, experienceYears, dateOfBirth,
                gender, address, status);

        // =============================================
        // RESULT
        // =============================================
        if (success) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/teachers.jsp?success=updated");
        } else {
            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/edit-teacher.jsp?id=" + teacherId
                    + "&error=failed");
        }
    }
}
