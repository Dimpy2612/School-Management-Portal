package com.school.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.school.util.DBConnection;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String usernameOrEmail = request.getParameter("usernameOrEmail");
        String password = request.getParameter("password");
        String role = request.getParameter("role");

        String sql =
                "SELECT user_id, first_name, last_name, role "
              + "FROM users "
              + "WHERE (username = ? OR email = ?) "
              + "AND password_hash = ? "
              + "AND role = ? "
              + "AND is_active = 1";

        try (
            Connection connection = DBConnection.getConnection();
            PreparedStatement statement = connection.prepareStatement(sql)
        ) {

            statement.setString(1, usernameOrEmail);
            statement.setString(2, usernameOrEmail);
            statement.setString(3, password);
            statement.setString(4, role);

            ResultSet result = statement.executeQuery();

            if (result.next()) {

                long userId = result.getLong("user_id");
                String firstName = result.getString("first_name");
                String lastName = result.getString("last_name");
                String userRole = result.getString("role");

                // ============================================
                // Look up school_id for this user
                // ============================================
                int schoolId = 0;

                String schoolSql =
                    "SELECT school_id FROM users WHERE user_id = ?";

                try (
                    PreparedStatement ps2 =
                        connection.prepareStatement(schoolSql)
                ) {
                    ps2.setLong(1, userId);
                    try (ResultSet rs2 = ps2.executeQuery()) {
                        if (rs2.next()) {
                            schoolId = rs2.getInt("school_id");
                        }
                    }
                }

                // ============================================
                // Create session
                // ============================================
                HttpSession session = request.getSession();
                session.setAttribute("userId", userId);
                session.setAttribute("firstName", firstName);
                session.setAttribute("lastName", lastName);
                session.setAttribute("role", userRole);
                session.setAttribute("schoolId", schoolId);

                session.setMaxInactiveInterval(30 * 60);

                if ("ADMIN".equals(userRole)) {
                    response.sendRedirect(
                        request.getContextPath() + "/admin/dashboard.jsp");
                } else if ("TEACHER".equals(userRole)) {
                    response.sendRedirect(
                        request.getContextPath() + "/teacher/dashboard.jsp");
                } else if ("STUDENT".equals(userRole)) {
                    response.sendRedirect(
                        request.getContextPath() + "/student/dashboard.jsp");
                }

            } else {

                response.setContentType("text/html;charset=UTF-8");
                response.getWriter().println("<h2>Login Failed</h2>");
                response.getWriter().println(
                    "<p>Invalid username, password or role.</p>");
                response.getWriter().println(
                    "<a href='login.html'>Try Again</a>");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("text/html;charset=UTF-8");
            response.getWriter().println("<h2>Something went wrong.</h2>");
            response.getWriter().println("<p>" + e.getMessage() + "</p>");
        }
    }
}
