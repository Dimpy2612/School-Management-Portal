package com.school.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import com.school.util.DBConnection;

public class DashboardDAO {

    // =====================================================
    // Count total students (per school)
    // =====================================================
    public int getTotalStudents(int schoolId) {
        String sql = "SELECT COUNT(*) FROM students WHERE school_id = ?";
        try (
            Connection connection = DBConnection.getConnection();
            PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setInt(1, schoolId);
            try (ResultSet result = statement.executeQuery()) {
                if (result.next()) return result.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // =====================================================
    // Count total teachers (per school)
    // =====================================================
    public int getTotalTeachers(int schoolId) {
        String sql = "SELECT COUNT(*) FROM teachers WHERE school_id = ?";
        try (
            Connection connection = DBConnection.getConnection();
            PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setInt(1, schoolId);
            try (ResultSet result = statement.executeQuery()) {
                if (result.next()) return result.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // =====================================================
    // Count total subjects (per school)
    // =====================================================
    public int getTotalSubjects(int schoolId) {
        String sql = "SELECT COUNT(*) FROM subjects WHERE school_id = ?";
        try (
            Connection connection = DBConnection.getConnection();
            PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setInt(1, schoolId);
            try (ResultSet result = statement.executeQuery()) {
                if (result.next()) return result.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // =====================================================
    // Count total classes (per school)
    // =====================================================
    public int getTotalClasses(int schoolId) {
        String sql = "SELECT COUNT(*) FROM classes WHERE school_id = ?";
        try (
            Connection connection = DBConnection.getConnection();
            PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setInt(1, schoolId);
            try (ResultSet result = statement.executeQuery()) {
                if (result.next()) return result.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }


    // =====================================================
    // Today's present students (per school)
    // Join path: attendance → student classes → students
    // =====================================================
    public int getTodayAttendance(int schoolId) {
        String sql =
            "SELECT COUNT(*) FROM attendance a " +
            "INNER JOIN studentclasses sc ON sc.student_class_id = a.student_class_id " +
            "INNER JOIN students s ON s.student_id = sc.student_id " +
            "WHERE s.school_id = ? " +
            "AND a.attendance_date = CURDATE() " +
            "AND a.status = 'PRESENT'";
        try (
            Connection connection = DBConnection.getConnection();
            PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setInt(1, schoolId);
            try (ResultSet result = statement.executeQuery()) {
                if (result.next()) return result.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // =====================================================
    // Pending fees (per school, via students join)
    // =====================================================
    public int getPendingFees(int schoolId) {
        String sql =
            "SELECT COUNT(*) FROM fees f " +
            "INNER JOIN students s ON s.student_id = f.student_id " +
            "WHERE s.school_id = ? " +
            "AND f.status IN ('PENDING', 'PARTIAL', 'OVERDUE')";
        try (
            Connection connection = DBConnection.getConnection();
            PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setInt(1, schoolId);
            try (ResultSet result = statement.executeQuery()) {
                if (result.next()) return result.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // =====================================================
    // Upcoming exams (per school, via classes join)
    // =====================================================
    public int getUpcomingExams(int schoolId) {
        String sql =
            "SELECT COUNT(*) FROM exams e " +
            "INNER JOIN classes c ON c.class_id = e.class_id " +
            "WHERE c.school_id = ? " +
            "AND e.start_date >= CURDATE() " +
            "AND e.status IN ('SCHEDULED', 'ONGOING')";
        try (
            Connection connection = DBConnection.getConnection();
            PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setInt(1, schoolId);
            try (ResultSet result = statement.executeQuery()) {
                if (result.next()) return result.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // =====================================================
    // Published notices (per school)
    // =====================================================
    public int getPublishedNotices(int schoolId) {
        String sql =
            "SELECT COUNT(*) FROM notices " +
            "WHERE school_id = ? " +
            "AND is_published = 1 " +
            "AND (expiry_at IS NULL OR expiry_at >= NOW())";
        try (
            Connection connection = DBConnection.getConnection();
            PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setInt(1, schoolId);
            try (ResultSet result = statement.executeQuery()) {
                if (result.next()) return result.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }
}
