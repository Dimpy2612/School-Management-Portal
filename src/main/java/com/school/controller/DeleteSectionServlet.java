package com.school.controller;

import java.io.IOException;

import com.school.dao.SectionDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/DeleteSectionServlet")
public class DeleteSectionServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private SectionDAO sectionDAO;

    @Override
    public void init() { sectionDAO = new SectionDAO(); }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null
                || !"ADMIN".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/login.html");
            return;
        }

        long sectionId;
        long classId;
        try {
            sectionId = Long.parseLong(request.getParameter("sectionId"));
            classId = Long.parseLong(request.getParameter("classId"));
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/admin/classes.jsp");
            return;
        }

        // Safety: block delete if students are enrolled
        int studentCount = sectionDAO.getStudentCountInSection(sectionId);
        if (studentCount > 0) {
            response.sendRedirect(request.getContextPath()
                    + "/admin/sections.jsp?classId=" + classId + "&error=hasStudents");
            return;
        }

        boolean ok = sectionDAO.deleteSection(sectionId);

        if (ok) {
            response.sendRedirect(request.getContextPath()
                    + "/admin/sections.jsp?classId=" + classId + "&success=deleted");
        } else {
            response.sendRedirect(request.getContextPath()
                    + "/admin/sections.jsp?classId=" + classId + "&error=failed");
        }
    }
}
