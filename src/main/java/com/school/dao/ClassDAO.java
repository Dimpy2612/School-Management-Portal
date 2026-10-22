package com.school.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import com.school.model.SchoolClass;
import com.school.util.DBConnection;

public class ClassDAO {

    // ============================================
    // Get all classes for a school (strict search)
    // ============================================
    public List<SchoolClass> getAllClasses(int schoolId, String search) {
        List<SchoolClass> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT c.class_id, c.school_id, c.class_name, c.class_order, c.status, ");
        sql.append("(SELECT COUNT(*) FROM sections s WHERE s.class_id = c.class_id AND s.status='ACTIVE') AS section_count, ");
        sql.append("(SELECT COUNT(*) FROM studentclasses sc WHERE sc.class_id = c.class_id AND sc.status='ACTIVE') AS student_count ");
        sql.append("FROM classes c ");
        sql.append("WHERE c.school_id = ? ");

        List<Object> params = new ArrayList<>();
        params.add(schoolId);

        // ---- STRICT SEARCH: match the whole phrase ----
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND c.class_name LIKE ? ");
            params.add("%" + search.trim() + "%");
        }

        sql.append("ORDER BY c.class_order ASC, c.class_id ASC");

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapClass(rs));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // ============================================
    // Get one class by ID
    // ============================================
    public SchoolClass getClassById(long classId, int schoolId) {
        String sql =
            "SELECT class_id, school_id, class_name, class_order, status " +
            "FROM classes WHERE class_id = ? AND school_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setLong(1, classId);
            ps.setInt(2, schoolId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapClass(rs);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    // ============================================
    // Add class
    // ============================================
    public boolean addClass(int schoolId, String className, int classOrder) {
        String sql = "INSERT INTO classes (school_id, class_name, class_order, status) " +
                     "VALUES (?, ?, ?, 'ACTIVE')";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, schoolId);
            ps.setString(2, className);
            ps.setInt(3, classOrder);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    // ============================================
    // Update class
    // ============================================
    public boolean updateClass(long classId, int schoolId, String className,
                               int classOrder, String status) {
        String sql = "UPDATE classes SET class_name = ?, class_order = ?, status = ? " +
                     "WHERE class_id = ? AND school_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, className);
            ps.setInt(2, classOrder);
            ps.setString(3, status);
            ps.setLong(4, classId);
            ps.setInt(5, schoolId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    // ============================================
    // Soft delete class
    // ============================================
    public boolean deleteClass(long classId, int schoolId) {
        String sql = "UPDATE classes SET status = 'INACTIVE' " +
                     "WHERE class_id = ? AND school_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setLong(1, classId);
            ps.setInt(2, schoolId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    // ============================================
    // Duplicate check (excluding current class)
    // ============================================
    public boolean classNameExists(int schoolId, String className, long excludeClassId) {
        String sql = "SELECT class_id FROM classes " +
                     "WHERE school_id = ? AND LOWER(class_name) = LOWER(?) " +
                     "AND class_id <> ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, schoolId);
            ps.setString(2, className);
            ps.setLong(3, excludeClassId);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    // ============================================
    // Next class order
    // ============================================
    public int getNextClassOrder(int schoolId) {
        String sql = "SELECT COALESCE(MAX(class_order), 0) + 1 FROM classes WHERE school_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, schoolId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return 1;
    }

    // ============================================
    // Stats
    // ============================================
    public int getCountByStatus(int schoolId, String status) {
        String sql = "SELECT COUNT(*) FROM classes WHERE school_id = ? AND status = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, schoolId);
            ps.setString(2, status);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    public int getTotalSections(int schoolId) {
        String sql = "SELECT COUNT(*) FROM sections s " +
                     "INNER JOIN classes c ON c.class_id = s.class_id " +
                     "WHERE c.school_id = ? AND s.status = 'ACTIVE'";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, schoolId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    // ============================================
    // Helper
    // ============================================
    private SchoolClass mapClass(ResultSet rs) throws SQLException {
        SchoolClass c = new SchoolClass();
        c.setClassId(rs.getLong("class_id"));
        c.setSchoolId(rs.getInt("school_id"));
        c.setClassName(rs.getString("class_name"));
        c.setClassOrder(rs.getInt("class_order"));
        c.setStatus(rs.getString("status"));

        try { c.setSectionCount(rs.getInt("section_count")); } catch (Exception ignore) {}
        try { c.setStudentCount(rs.getInt("student_count")); } catch (Exception ignore) {}

        return c;
    }
}
