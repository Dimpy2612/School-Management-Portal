package com.school.controller;

import java.io.IOException;

import com.school.dao.StudentDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/AddStudentServlet")
public class AddStudentServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private StudentDAO studentDAO;

    @Override
    public void init() throws ServletException {
        studentDAO = new StudentDAO();
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

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
                    request.getContextPath() + "/admin/students.jsp");
            return;
        }

        int schoolId = Integer.parseInt(schoolIdObj.toString());

        // =============================================
        // GET FORM DATA
        // =============================================
        String firstName             = request.getParameter("firstName");
        String lastName              = request.getParameter("lastName");
        String username              = request.getParameter("username");
        String email                 = request.getParameter("email");
        String password              = request.getParameter("password");
        String phone                 = request.getParameter("phone");
        String admissionNo           = request.getParameter("admissionNo");
        String dateOfBirth           = request.getParameter("dateOfBirth");
        String gender                = request.getParameter("gender");
        String bloodGroup            = request.getParameter("bloodGroup");
        String address               = request.getParameter("address");
        String admissionDate         = request.getParameter("admissionDate");
        String emergencyContactName  = request.getParameter("emergencyContactName");
        String emergencyContactPhone = request.getParameter("emergencyContactPhone");
        String classIdText           = request.getParameter("classId");
        String sectionIdText         = request.getParameter("sectionId");
        String rollNumber            = request.getParameter("rollNumber");

        // =============================================
        // VALIDATION
        // =============================================
        if (firstName == null || firstName.trim().isEmpty() ||
            username  == null || username.trim().isEmpty()  ||
            email     == null || email.trim().isEmpty()     ||
            password  == null || password.trim().isEmpty()  ||
            admissionNo == null || admissionNo.trim().isEmpty() ||
            classIdText == null || classIdText.trim().isEmpty() ||
            sectionIdText == null || sectionIdText.trim().isEmpty()) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/add-student.jsp?error=required");
            return;
        }

        firstName    = firstName.trim();
        lastName     = (lastName == null) ? "" : lastName.trim();
        username     = username.trim();
        email        = email.trim();
        password     = password.trim();
        phone        = (phone == null) ? "" : phone.trim();
        admissionNo  = admissionNo.trim();
        dateOfBirth  = (dateOfBirth == null) ? "" : dateOfBirth.trim();
        gender       = (gender == null) ? "" : gender.trim();
        bloodGroup   = (bloodGroup == null) ? "" : bloodGroup.trim();
        address      = (address == null) ? "" : address.trim();
        admissionDate= (admissionDate == null) ? "" : admissionDate.trim();
        emergencyContactName  = (emergencyContactName == null) ? "" : emergencyContactName.trim();
        emergencyContactPhone = (emergencyContactPhone == null) ? "" : emergencyContactPhone.trim();
        rollNumber   = (rollNumber == null) ? "" : rollNumber.trim();

        long classId;
        long sectionId;

        try {
            classId = Long.parseLong(classIdText);
            sectionId = Long.parseLong(sectionIdText);
        } catch (Exception e) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/add-student.jsp?error=required");
            return;
        }

        // =============================================
        // DUPLICATE CHECKS
        // =============================================
        if (studentDAO.usernameExists(username)) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/add-student.jsp?error=username");
            return;
        }

        if (studentDAO.emailExists(email)) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/add-student.jsp?error=email");
            return;
        }

        if (studentDAO.admissionNoExists(admissionNo)) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/add-student.jsp?error=admissionNo");
            return;
        }

        // =============================================
        // ADD STUDENT
        // =============================================
        boolean success;

        try {
            success = studentDAO.addStudent(
                    schoolId,
                    username, email, password,
                    firstName, lastName, phone,
                    admissionNo, dateOfBirth, gender,
                    bloodGroup, address, admissionDate,
                    emergencyContactName, emergencyContactPhone,
                    classId, sectionId, rollNumber);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/add-student.jsp?error=failed");
            return;
        }

        if (success) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/students.jsp?success=added");
        } else {
            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/add-student.jsp?error=failed");
        }
    }
}
