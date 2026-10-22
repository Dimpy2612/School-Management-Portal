package com.school.controller;

import java.io.IOException;

import com.school.dao.ClassDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/DeleteClassServlet")
public class DeleteClassServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private ClassDAO classDAO;

    @Override
    public void init() { classDAO = new ClassDAO(); }

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

        long classId;
        try {
            classId = Long.parseLong(request.getParameter("classId"));
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/admin/classes.jsp");
            return;
        }

        boolean ok = classDAO.deleteClass(classId, schoolId);

        if (ok) {
            response.sendRedirect(request.getContextPath()
                    + "/admin/classes.jsp?success=deleted");
        } else {
            response.sendRedirect(request.getContextPath()
                    + "/admin/classes.jsp?error=failed");
        }
    }
}
