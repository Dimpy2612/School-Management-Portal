package com.school.controller;

import java.io.IOException;

import com.school.dao.SectionDAO;
import com.school.dao.StudentDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/AddSectionServlet")
public class AddSectionServlet extends HttpServlet {

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

        int schoolId = Integer.parseInt(session.getAttribute("schoolId").toString());

        String classIdText = request.getParameter("classId");
        String sectionName = request.getParameter("sectionName");
        String roomNumber = request.getParameter("roomNumber");
        String teacherIdText = request.getParameter("classTeacherId");

        long classId;
        try {
            classId = Long.parseLong(classIdText);
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/admin/classes.jsp");
            return;
        }

        if (sectionName == null || sectionName.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath()
                    + "/admin/add-section.jsp?classId=" + classId + "&error=required");
            return;
        }
        sectionName = sectionName.trim();
        roomNumber = (roomNumber == null) ? "" : roomNumber.trim();

        Long classTeacherId = null;
        if (teacherIdText != null && !teacherIdText.trim().isEmpty()) {
            try { classTeacherId = Long.parseLong(teacherIdText); } catch (Exception ignore) {}
        }

        if (sectionDAO.sectionNameExists(classId, sectionName, -1)) {
            response.sendRedirect(request.getContextPath()
                    + "/admin/add-section.jsp?classId=" + classId + "&error=duplicate");
            return;
        }

        StudentDAO studentDAO = new StudentDAO();
        long academicYearId = studentDAO.getCurrentAcademicYear(schoolId);
        if (academicYearId <= 0) {
            response.sendRedirect(request.getContextPath()
                    + "/admin/add-section.jsp?classId=" + classId + "&error=failed");
            return;
        }

        boolean ok = sectionDAO.addSection(classId, academicYearId, sectionName,
                                           roomNumber, classTeacherId);

        if (ok) {
            response.sendRedirect(request.getContextPath()
                    + "/admin/sections.jsp?classId=" + classId + "&success=added");
        } else {
            response.sendRedirect(request.getContextPath()
                    + "/admin/add-section.jsp?classId=" + classId + "&error=failed");
        }
    }
}
