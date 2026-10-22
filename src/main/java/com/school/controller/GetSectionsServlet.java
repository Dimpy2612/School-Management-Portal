package com.school.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import com.school.util.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/GetSectionsServlet")
public class GetSectionsServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String classIdText = request.getParameter("classId");
        PrintWriter out = response.getWriter();

        if (classIdText == null || classIdText.trim().isEmpty()) {
            out.print("[]");
            return;
        }

        long classId;
        try {
            classId = Long.parseLong(classIdText);
        } catch (Exception e) {
            out.print("[]");
            return;
        }

        StringBuilder json = new StringBuilder("[");
        boolean first = true;

        String sql = "SELECT section_id, section_name FROM sections " +
                     "WHERE class_id = ? AND status = 'ACTIVE' " +
                     "ORDER BY section_name";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setLong(1, classId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    if (!first) json.append(",");
                    first = false;
                    json.append("{\"section_id\":")
                        .append(rs.getLong("section_id"))
                        .append(",\"section_name\":\"")
                        .append(rs.getString("section_name").replace("\"", "\\\""))
                        .append("\"}");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        json.append("]");
        out.print(json.toString());
    }
}
