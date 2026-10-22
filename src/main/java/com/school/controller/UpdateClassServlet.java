package com.school.controller;

import java.io.IOException;

import com.school.dao.ClassDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/UpdateClassServlet")
public class UpdateClassServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private ClassDAO classDAO;

    @Override
    public void init() { classDAO = new ClassDAO(); }

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

        long classId;
        try {
            classId = Long.parseLong(request.getParameter("classId"));
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/admin/classes.jsp");
            return;
        }

        String className = request.getParameter("className");
        String orderText = request.getParameter("classOrder");
        String status = request.getParameter("status");

        if (className == null || className.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath()
                    + "/admin/edit-class.jsp?id=" + classId + "&error=required");
            return;
        }

        className = className.trim();

        int classOrder;
        try { classOrder = Integer.parseInt(orderText); }
        catch (Exception e) { classOrder = 1; }

        if (status == null || status.trim().isEmpty()) status = "ACTIVE";

        if (classDAO.classNameExists(schoolId, className, classId)) {
            response.sendRedirect(request.getContextPath()
                    + "/admin/edit-class.jsp?id=" + classId + "&error=duplicate");
            return;
        }

        boolean ok = classDAO.updateClass(classId, schoolId, className, classOrder, status);

        if (ok) {
            response.sendRedirect(request.getContextPath()
                    + "/admin/classes.jsp?success=updated");
        } else {
            response.sendRedirect(request.getContextPath()
                    + "/admin/edit-class.jsp?id=" + classId + "&error=failed");
        }
    }
}
