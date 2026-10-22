package com.school.controller;

import java.io.IOException;

import com.school.dao.SubjectDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/DeleteSubjectServlet")
public class DeleteSubjectServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private SubjectDAO subjectDAO;

    @Override
    public void init() { subjectDAO = new SubjectDAO(); }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null
                || !"ADMIN".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/login.html");
            return;
        }

        int schoolId = Integer.parseInt(session.getAttribute("schoolId").toString());

        long subjectId;
        try {
            subjectId = Long.parseLong(request.getParameter("subjectId"));
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/admin/subjects.jsp");
            return;
        }

        boolean ok = subjectDAO.deleteSubject(subjectId, schoolId);

        if (ok) {
            response.sendRedirect(request.getContextPath()
                    + "/admin/subjects.jsp?success=deleted");
        } else {
            response.sendRedirect(request.getContextPath()
                    + "/admin/subjects.jsp?error=failed");
        }
    }
}
