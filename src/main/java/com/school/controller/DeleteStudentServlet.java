package com.school.controller;

import java.io.IOException;

import com.school.dao.StudentDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/DeleteStudentServlet")
public class DeleteStudentServlet extends HttpServlet {

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

        String studentIdText = request.getParameter("studentId");

        long studentId;

        try {
            studentId = Long.parseLong(studentIdText);
        } catch (Exception e) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/students.jsp?error=invalid");
            return;
        }

        boolean success = studentDAO.deleteStudent(studentId, schoolId);

        if (success) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/students.jsp?success=deleted");
        } else {
            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/students.jsp?error=failed");
        }
    }
}
