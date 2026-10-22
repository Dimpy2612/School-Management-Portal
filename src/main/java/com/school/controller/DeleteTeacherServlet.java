package com.school.controller;

import java.io.IOException;

import com.school.dao.TeacherDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/DeleteTeacherServlet")
public class DeleteTeacherServlet extends HttpServlet {

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

        HttpSession session = request.getSession(false);

        System.out.println(">>> DeleteServlet reached");
        System.out.println(">>> session = " + session);
        System.out.println(">>> JSESSIONID requested = " + request.getRequestedSessionId());
        if (session != null) {
            System.out.println(">>> userId = " + session.getAttribute("userId"));
            System.out.println(">>> role   = " + session.getAttribute("role"));
            System.out.println(">>> schoolId = " + session.getAttribute("schoolId"));
        }

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

        String teacherIdText = request.getParameter("teacherId");

        long teacherId;

        try {
            teacherId = Long.parseLong(teacherIdText);
        } catch (Exception e) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/teachers.jsp?error=invalid");
            return;
        }

        boolean success = teacherDAO.deleteTeacher(teacherId, schoolId);

        if (success) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/teachers.jsp?success=deleted");
        } else {
            response.sendRedirect(
                    request.getContextPath()
                    + "/admin/teachers.jsp?error=failed");
        }
    }
}
