package com.school.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import com.school.model.Subject;
import com.school.util.DBConnection;

public class SubjectDAO {

    // ============================================
    // Get all subjects (search + class filter)
    // ============================================
    public List<Subject> getAllSubjects(int schoolId, String search, Long classId) {
        List<Subject> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT s.subject_id, s.school_id, s.class_id, s.subject_name, ");
        sql.append("s.subject_code, s.subject_type, s.max_marks, s.passing_marks, s.status, ");
        sql.append("c.class_name ");
        sql.append("FROM subjects s ");
        sql.append("INNER JOIN classes c ON c.class_id = s.class_id ");
        sql.append("WHERE s.school_id = ? ");

        List<Object> params = new ArrayList<>();
        params.add(schoolId);

        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (LOWER(s.subject_name) LIKE LOWER(?) ");
            sql.append("OR LOWER(s.subject_code) LIKE LOWER(?)) ");
            String pattern = "%" + search.trim() + "%";
            params.add(pattern);
            params.add(pattern);
        }

        if (classId != null && classId > 0) {
            sql.append("AND s.class_id = ? ");
            params.add(classId);
        }

        sql.append("ORDER BY c.class_order ASC, s.subject_name ASC");

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // ============================================
    // Get one subject by ID
    // ============================================
    public Subject getSubjectById(long subjectId, int schoolId) {
        String sql =
            "SELECT s.subject_id, s.school_id, s.class_id, s.subject_name, " +
            "s.subject_code, s.subject_type, s.max_marks, s.passing_marks, s.status, " +
            "c.class_name " +
            "FROM subjects s " +
            "INNER JOIN classes c ON c.class_id = s.class_id " +
            "WHERE s.subject_id = ? AND s.school_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setLong(1, subjectId);
            ps.setInt(2, schoolId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    // ============================================
    // Add subject
    // ============================================
    public boolean addSubject(int schoolId, long classId, String subjectName,
                              String subjectCode, String subjectType,
                              double maxMarks, double passingMarks) {
        String sql = "INSERT INTO subjects " +
                     "(school_id, class_id, subject_name, subject_code, subject_type, " +
                     "max_marks, passing_marks, status) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, 'ACTIVE')";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, schoolId);
            ps.setLong(2, classId);
            ps.setString(3, subjectName);
            ps.setString(4, subjectCode);
            ps.setString(5, subjectType);
            ps.setDouble(6, maxMarks);
            ps.setDouble(7, passingMarks);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    // ============================================
    // Update subject
    // ============================================
    public boolean updateSubject(long subjectId, int schoolId, long classId,
                                 String subjectName, String subjectCode,
                                 String subjectType, double maxMarks,
                                 double passingMarks, String status) {
        String sql = "UPDATE subjects SET class_id = ?, subject_name = ?, " +
                     "subject_code = ?, subject_type = ?, max_marks = ?, " +
                     "passing_marks = ?, status = ? " +
                     "WHERE subject_id = ? AND school_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setLong(1, classId);
            ps.setString(2, subjectName);
            ps.setString(3, subjectCode);
            ps.setString(4, subjectType);
            ps.setDouble(5, maxMarks);
            ps.setDouble(6, passingMarks);
            ps.setString(7, status);
            ps.setLong(8, subjectId);
            ps.setInt(9, schoolId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    // ============================================
    // Soft delete subject
    // ============================================
    public boolean deleteSubject(long subjectId, int schoolId) {
        String sql = "UPDATE subjects SET status = 'INACTIVE' " +
                     "WHERE subject_id = ? AND school_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setLong(1, subjectId);
            ps.setInt(2, schoolId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    // ============================================
    // Duplicate check for subject code
    // ============================================
    public boolean subjectCodeExists(int schoolId, String code, long excludeId) {
        String sql = "SELECT subject_id FROM subjects " +
                     "WHERE school_id = ? AND LOWER(subject_code) = LOWER(?) " +
                     "AND subject_id <> ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, schoolId);
            ps.setString(2, code);
            ps.setLong(3, excludeId);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    // ============================================
    // Stats
    // ============================================
    public int getCountByStatus(int schoolId, String status) {
        String sql = "SELECT COUNT(*) FROM subjects WHERE school_id = ? AND status = ?";
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

    public int getCountByType(int schoolId, String type) {
        String sql = "SELECT COUNT(*) FROM subjects " +
                     "WHERE school_id = ? AND status = 'ACTIVE' AND subject_type = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, schoolId);
            ps.setString(2, type);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    // ============================================
    // Helper
    // ============================================
    private Subject map(ResultSet rs) throws SQLException {
        Subject s = new Subject();
        s.setSubjectId(rs.getLong("subject_id"));
        s.setSchoolId(rs.getInt("school_id"));
        s.setClassId(rs.getLong("class_id"));
        s.setSubjectName(rs.getString("subject_name"));
        s.setSubjectCode(rs.getString("subject_code"));
        try { s.setSubjectType(rs.getString("subject_type")); } catch (Exception ignore) {}
        s.setMaxMarks(rs.getBigDecimal("max_marks"));
        s.setPassingMarks(rs.getBigDecimal("passing_marks"));
        s.setStatus(rs.getString("status"));
        try { s.setClassName(rs.getString("class_name")); } catch (Exception ignore) {}
        return s;
    }
}
