package com.school.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import com.school.util.DBConnection;

public class ClassSectionDAO {

    // Map<class_id, class_name>
    public Map<Long, String> getClasses(int schoolId) {
        Map<Long, String> map = new LinkedHashMap<>();
        String sql = "SELECT class_id, class_name FROM classes " +
                     "WHERE school_id = ? AND status = 'ACTIVE' ORDER BY class_order";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, schoolId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    map.put(rs.getLong("class_id"), rs.getString("class_name"));
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return map;
    }

    // Map<section_id, section_name> for a class
    public Map<Long, String> getSections(long classId) {
        Map<Long, String> map = new LinkedHashMap<>();
        String sql = "SELECT section_id, section_name FROM sections " +
                     "WHERE class_id = ? AND status = 'ACTIVE' ORDER BY section_name";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setLong(1, classId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    map.put(rs.getLong("section_id"), rs.getString("section_name"));
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return map;
    }
}
