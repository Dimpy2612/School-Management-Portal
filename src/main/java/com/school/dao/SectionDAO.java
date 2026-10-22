package com.school.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import com.school.model.Section;
import com.school.util.DBConnection;

public class SectionDAO {

    // ============================================
    // Get sections of a class
    // ============================================
    public List<Section> getSectionsByClass(long classId, int schoolId) {
        List<Section> list = new ArrayList<>();

        String sql =
            "SELECT s.section_id, s.class_id, s.academic_year_id, s.section_name, " +
            "s.room_number, s.class_teacher_id, s.status, " +
            "c.class_name, " +
            "CONCAT(COALESCE(u.first_name,''), ' ', COALESCE(u.last_name,'')) AS teacher_name " +
            "FROM sections s " +
            "INNER JOIN classes c ON c.class_id = s.class_id " +
            "LEFT JOIN teachers t ON t.teacher_id = s.class_teacher_id " +
            "LEFT JOIN users u ON u.user_id = t.user_id " +
            "WHERE s.class_id = ? AND c.school_id = ? " +
            "ORDER BY s.section_name";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setLong(1, classId);
            ps.setInt(2, schoolId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapSection(rs));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // ============================================
    // Get one section
    // ============================================
    public Section getSectionById(long sectionId, int schoolId) {
        String sql =
            "SELECT s.section_id, s.class_id, s.academic_year_id, s.section_name, " +
            "s.room_number, s.class_teacher_id, s.status, " +
            "c.class_name, " +
            "CONCAT(COALESCE(u.first_name,''), ' ', COALESCE(u.last_name,'')) AS teacher_name " +
            "FROM sections s " +
            "INNER JOIN classes c ON c.class_id = s.class_id " +
            "LEFT JOIN teachers t ON t.teacher_id = s.class_teacher_id " +
            "LEFT JOIN users u ON u.user_id = t.user_id " +
            "WHERE s.section_id = ? AND c.school_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setLong(1, sectionId);
            ps.setInt(2, schoolId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapSection(rs);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    // ============================================
    // Add section
    // ============================================
    public boolean addSection(long classId, long academicYearId, String sectionName,
                              String roomNumber, Long classTeacherId) {
        String sql = "INSERT INTO sections " +
                     "(class_id, academic_year_id, section_name, room_number, class_teacher_id, status) " +
                     "VALUES (?, ?, ?, ?, ?, 'ACTIVE')";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setLong(1, classId);
            ps.setLong(2, academicYearId);
            ps.setString(3, sectionName);
            ps.setString(4, roomNumber);
            if (classTeacherId != null && classTeacherId > 0) {
                ps.setLong(5, classTeacherId);
            } else {
                ps.setNull(5, Types.BIGINT);
            }
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    // ============================================
    // Update section
    // ============================================
    public boolean updateSection(long sectionId, String sectionName, String roomNumber,
                                 Long classTeacherId, String status) {
        String sql = "UPDATE sections SET section_name = ?, room_number = ?, " +
                     "class_teacher_id = ?, status = ? WHERE section_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, sectionName);
            ps.setString(2, roomNumber);
            if (classTeacherId != null && classTeacherId > 0) {
                ps.setLong(3, classTeacherId);
            } else {
                ps.setNull(3, Types.BIGINT);
            }
            ps.setString(4, status);
            ps.setLong(5, sectionId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    // ============================================
    // Soft delete section
    // ============================================
    public boolean deleteSection(long sectionId) {
        String sql = "UPDATE sections SET status = 'INACTIVE' WHERE section_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setLong(1, sectionId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    // ============================================
    // Duplicate check
    // ============================================
    public boolean sectionNameExists(long classId, String sectionName, long excludeSectionId) {
        String sql = "SELECT section_id FROM sections " +
                     "WHERE class_id = ? AND LOWER(section_name) = LOWER(?) " +
                     "AND section_id <> ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setLong(1, classId);
            ps.setString(2, sectionName);
            ps.setLong(3, excludeSectionId);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    // ============================================
    // Check if any students are enrolled in a section
    // ============================================
    public int getStudentCountInSection(long sectionId) {
        String sql = "SELECT COUNT(*) FROM studentclasses " +
                     "WHERE section_id = ? AND status = 'ACTIVE'";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setLong(1, sectionId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    // ============================================
    // Helper
    // ============================================
    private Section mapSection(ResultSet rs) throws SQLException {
        Section s = new Section();
        s.setSectionId(rs.getLong("section_id"));
        s.setClassId(rs.getLong("class_id"));
        s.setAcademicYearId(rs.getLong("academic_year_id"));
        s.setSectionName(rs.getString("section_name"));
        s.setRoomNumber(rs.getString("room_number"));

        long tid = rs.getLong("class_teacher_id");
        if (!rs.wasNull()) s.setClassTeacherId(tid);

        s.setStatus(rs.getString("status"));
        try { s.setClassName(rs.getString("class_name")); } catch (Exception ignore) {}

        try {
            String tn = rs.getString("teacher_name");
            if (tn != null) s.setClassTeacherName(tn.trim());
        } catch (Exception ignore) {}

        return s;
    }
}
