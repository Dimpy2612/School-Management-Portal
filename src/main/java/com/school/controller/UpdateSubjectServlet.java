package com.school.controller;

import java.io.IOException;

import com.school.dao.SubjectDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/UpdateSubjectServlet")
public class UpdateSubjectServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private SubjectDAO subjectDAO;

    @Override
    public void init() { subjectDAO = new SubjectDAO(); }

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

        long subjectId;
        try {
            subjectId = Long.parseLong(request.getParameter("subjectId"));
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/admin/subjects.jsp");
            return;
        }

        String classIdText = request.getParameter("classId");
        String subjectName = request.getParameter("subjectName");
        String subjectCode = request.getParameter("subjectCode");
        String subjectType = request.getParameter("subjectType");
        String maxText = request.getParameter("maxMarks");
        String passText = request.getParameter("passingMarks");
        String status = request.getParameter("status");

        if (classIdText == null || classIdText.trim().isEmpty()
            || subjectName == null || subjectName.trim().isEmpty()
            || subjectCode == null || subjectCode.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath()
                    + "/admin/edit-subject.jsp?id=" + subjectId + "&error=required");
            return;
        }

        long classId = Long.parseLong(classIdText);
        subjectName = subjectName.trim();
        subjectCode = subjectCode.trim().toUpperCase();
        subjectType = (subjectType == null || subjectType.trim().isEmpty())
                    ? "THEORY" : subjectType.trim();
        status = (status == null || status.trim().isEmpty()) ? "ACTIVE" : status.trim();

        double maxMarks = 100;
        double passMarks = 33;
        try { maxMarks = Double.parseDouble(maxText); } catch (Exception ignore) {}
        try { passMarks = Double.parseDouble(passText); } catch (Exception ignore) {}

        if (subjectDAO.subjectCodeExists(schoolId, subjectCode, subjectId)) {
            response.sendRedirect(request.getContextPath()
                    + "/admin/edit-subject.jsp?id=" + subjectId + "&error=duplicate");
            return;
        }

        boolean ok = subjectDAO.updateSubject(subjectId, schoolId, classId,
                subjectName, subjectCode, subjectType, maxMarks, passMarks, status);

        if (ok) {
            response.sendRedirect(request.getContextPath()
                    + "/admin/subjects.jsp?success=updated");
        } else {
            response.sendRedirect(request.getContextPath()
                    + "/admin/edit-subject.jsp?id=" + subjectId + "&error=failed");
        }
    }
}
