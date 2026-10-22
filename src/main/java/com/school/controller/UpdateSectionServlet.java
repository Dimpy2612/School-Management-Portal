package com.school.controller;

import java.io.IOException;

import com.school.dao.SectionDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/UpdateSectionServlet")
public class UpdateSectionServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private SectionDAO sectionDAO;

    @Override
    public void init() { sectionDAO = new SectionDAO(); }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null
                || !"ADMIN".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/login.html");
            return;
        }

        long sectionId;
        try {
            sectionId = Long.parseLong(request.getParameter("sectionId"));
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/admin/classes.jsp");
            return;
        }

        long classId;
        try {
            classId = Long.parseLong(request.getParameter("classId"));
        } catch (Exception e) {
            classId = 0;
        }

        String sectionName = request.getParameter("sectionName");
        String roomNumber = request.getParameter("roomNumber");
        String teacherIdText = request.getParameter("classTeacherId");
        String status = request.getParameter("status");

        if (sectionName == null || sectionName.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath()
                    + "/admin/edit-section.jsp?id=" + sectionId + "&error=required");
            return;
        }
        sectionName = sectionName.trim();
        roomNumber = (roomNumber == null) ? "" : roomNumber.trim();
        status = (status == null || status.trim().isEmpty()) ? "ACTIVE" : status.trim();

        Long classTeacherId = null;
        if (teacherIdText != null && !teacherIdText.trim().isEmpty()) {
            try { classTeacherId = Long.parseLong(teacherIdText); } catch (Exception ignore) {}
        }

        if (sectionDAO.sectionNameExists(classId, sectionName, sectionId)) {
            response.sendRedirect(request.getContextPath()
                    + "/admin/edit-section.jsp?id=" + sectionId + "&error=duplicate");
            return;
        }

        boolean ok = sectionDAO.updateSection(sectionId, sectionName, roomNumber,
                                              classTeacherId, status);

        if (ok) {
            response.sendRedirect(request.getContextPath()
                    + "/admin/sections.jsp?classId=" + classId + "&success=updated");
        } else {
            response.sendRedirect(request.getContextPath()
                    + "/admin/edit-section.jsp?id=" + sectionId + "&error=failed");
        }
    }
}
