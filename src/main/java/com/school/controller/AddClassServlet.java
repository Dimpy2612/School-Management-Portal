package com.school.controller;

import java.io.IOException;

import com.school.dao.ClassDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/AddClassServlet")
public class AddClassServlet extends HttpServlet {

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

        Object sidObj = session.getAttribute("schoolId");
        if (sidObj == null) {
            response.sendRedirect(request.getContextPath() + "/admin/classes.jsp");
            return;
        }
        int schoolId = Integer.parseInt(sidObj.toString());

        String className = request.getParameter("className");
        String orderText = request.getParameter("classOrder");

        if (className == null || className.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath()
                    + "/admin/add-class.jsp?error=required");
            return;
        }

        className = className.trim();
        int classOrder;
        try {
            classOrder = Integer.parseInt(orderText);
        } catch (Exception e) {
            classOrder = classDAO.getNextClassOrder(schoolId);
        }

        if (classDAO.classNameExists(schoolId, className, -1)) {
            response.sendRedirect(request.getContextPath()
                    + "/admin/add-class.jsp?error=duplicate");
            return;
        }

        boolean ok = classDAO.addClass(schoolId, className, classOrder);

        if (ok) {
            response.sendRedirect(request.getContextPath()
                    + "/admin/classes.jsp?success=added");
        } else {
            response.sendRedirect(request.getContextPath()
                    + "/admin/add-class.jsp?error=failed");
        }
    }
}
