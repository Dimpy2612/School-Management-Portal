package com.school.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.school.model.Teacher;
import com.school.util.DBConnection;

public class TeacherDAO {

    // =========================================================
    // ADD TEACHER
    // =========================================================
    public boolean addTeacher(
            int schoolId,
            String username,
            String email,
            String passwordHash,
            String firstName,
            String lastName,
            String phone,
            String employeeCode,
            String qualification,
            String specialization,
            String joiningDate,
            String experienceYears,
            String dateOfBirth,
            String gender,
            String address) {

        Connection con = null;
        PreparedStatement userStmt = null;
        PreparedStatement teacherStmt = null;
        ResultSet generatedKeys = null;

        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            String userSql =
                    "INSERT INTO users " +
                    "(school_id, username, email, password_hash, role, " +
                    "first_name, last_name, phone, is_active) " +
                    "VALUES (?, ?, ?, ?, 'TEACHER', ?, ?, ?, 1)";

            userStmt = con.prepareStatement(
                    userSql,
                    PreparedStatement.RETURN_GENERATED_KEYS
            );

            userStmt.setInt(1, schoolId);
            userStmt.setString(2, username);
            userStmt.setString(3, email);
            userStmt.setString(4, passwordHash);
            userStmt.setString(5, firstName);
            userStmt.setString(6, lastName);
            userStmt.setString(7, phone);

            userStmt.executeUpdate();

            generatedKeys = userStmt.getGeneratedKeys();

            if (!generatedKeys.next()) {
                con.rollback();
                return false;
            }

            long userId = generatedKeys.getLong(1);

            String teacherSql =
                    "INSERT INTO teachers " +
                    "(user_id, school_id, employee_code, qualification, " +
                    "specialization, joining_date, experience_years, " +
                    "date_of_birth, gender, address, status) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'ACTIVE')";

            teacherStmt = con.prepareStatement(teacherSql);

            teacherStmt.setLong(1, userId);
            teacherStmt.setInt(2, schoolId);
            teacherStmt.setString(3, employeeCode);
            teacherStmt.setString(4, qualification);
            teacherStmt.setString(5, specialization);

            if (joiningDate == null || joiningDate.trim().isEmpty()) {
                teacherStmt.setNull(6, java.sql.Types.DATE);
            } else {
                teacherStmt.setDate(6, java.sql.Date.valueOf(joiningDate));
            }

            if (experienceYears == null || experienceYears.trim().isEmpty()) {
                teacherStmt.setNull(7, java.sql.Types.DECIMAL);
            } else {
                teacherStmt.setBigDecimal(
                        7, new java.math.BigDecimal(experienceYears));
            }

            if (dateOfBirth == null || dateOfBirth.trim().isEmpty()) {
                teacherStmt.setNull(8, java.sql.Types.DATE);
            } else {
                teacherStmt.setDate(8, java.sql.Date.valueOf(dateOfBirth));
            }

            if (gender == null || gender.trim().isEmpty()) {
                teacherStmt.setNull(9, java.sql.Types.VARCHAR);
            } else {
                teacherStmt.setString(9, gender);
            }

            teacherStmt.setString(10, address);

            teacherStmt.executeUpdate();

            con.commit();
            return true;

        } catch (Exception e) {
            e.printStackTrace();
            try { if (con != null) con.rollback(); }
            catch (SQLException ex) { ex.printStackTrace(); }
            return false;

        } finally {
            try { if (generatedKeys != null) generatedKeys.close(); }
            catch (SQLException e) { e.printStackTrace(); }
            try { if (userStmt != null) userStmt.close(); }
            catch (SQLException e) { e.printStackTrace(); }
            try { if (teacherStmt != null) teacherStmt.close(); }
            catch (SQLException e) { e.printStackTrace(); }
            try { if (con != null) { con.setAutoCommit(true); con.close(); } }
            catch (SQLException e) { e.printStackTrace(); }
        }
    }


    // =========================================================
    // CHECK USERNAME
    // =========================================================
    public boolean usernameExists(String username) {
        String sql = "SELECT user_id FROM users WHERE username = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }


    // =========================================================
    // CHECK EMAIL
    // =========================================================
    public boolean emailExists(String email) {
        String sql = "SELECT user_id FROM users WHERE email = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }


    // =========================================================
    // CHECK EMPLOYEE CODE
    // =========================================================
    public boolean employeeCodeExists(String employeeCode) {
        String sql = "SELECT teacher_id FROM teachers WHERE employee_code = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, employeeCode);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }


    // =========================================================
    // CHECK EMPLOYEE CODE (EXCLUDING ONE TEACHER — for edit)
    // =========================================================
    public boolean employeeCodeExistsExcept(String employeeCode, long teacherId) {
        String sql =
                "SELECT teacher_id FROM teachers " +
                "WHERE employee_code = ? AND teacher_id <> ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, employeeCode);
            ps.setLong(2, teacherId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }


    // =========================================================
    // GET ALL TEACHERS
    // =========================================================
    public List<Teacher> getAllTeachers(int schoolId) {

        List<Teacher> teachers = new ArrayList<>();

        String sql =
                "SELECT " +
                "t.teacher_id, t.employee_code, t.qualification, " +
                "t.specialization, t.joining_date, t.experience_years, " +
                "t.date_of_birth, t.gender, t.address, t.status, " +
                "u.user_id, u.username, u.email, " +
                "u.first_name, u.last_name, u.phone " +
                "FROM teachers t " +
                "INNER JOIN users u ON t.user_id = u.user_id " +
                "WHERE t.school_id = ? " +
                "AND u.role = 'TEACHER' " +
                "ORDER BY t.teacher_id DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, schoolId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Teacher teacher = new Teacher();
                    teacher.setTeacherId(rs.getLong("teacher_id"));
                    teacher.setUserId(rs.getLong("user_id"));
                    teacher.setEmployeeCode(rs.getString("employee_code"));
                    teacher.setUsername(rs.getString("username"));
                    teacher.setEmail(rs.getString("email"));
                    teacher.setFirstName(rs.getString("first_name"));
                    teacher.setLastName(rs.getString("last_name"));
                    teacher.setPhone(rs.getString("phone"));
                    teacher.setQualification(rs.getString("qualification"));
                    teacher.setSpecialization(rs.getString("specialization"));
                    teacher.setJoiningDate(rs.getDate("joining_date"));
                    teacher.setExperienceYears(rs.getBigDecimal("experience_years"));
                    teacher.setDateOfBirth(rs.getDate("date_of_birth"));
                    teacher.setGender(rs.getString("gender"));
                    teacher.setAddress(rs.getString("address"));
                    teacher.setStatus(rs.getString("status"));
                    teachers.add(teacher);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }

        return teachers;
    }


    // =========================================================
    // GET ONE TEACHER BY ID
    // =========================================================
    public Teacher getTeacherById(long teacherId, int schoolId) {

        Teacher teacher = null;

        String sql =
                "SELECT " +
                "t.teacher_id, t.employee_code, t.qualification, " +
                "t.specialization, t.joining_date, t.experience_years, " +
                "t.date_of_birth, t.gender, t.address, t.status, " +
                "u.user_id, u.username, u.email, " +
                "u.first_name, u.last_name, u.phone " +
                "FROM teachers t " +
                "INNER JOIN users u ON t.user_id = u.user_id " +
                "WHERE t.teacher_id = ? AND t.school_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setLong(1, teacherId);
            ps.setInt(2, schoolId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    teacher = new Teacher();
                    teacher.setTeacherId(rs.getLong("teacher_id"));
                    teacher.setUserId(rs.getLong("user_id"));
                    teacher.setEmployeeCode(rs.getString("employee_code"));
                    teacher.setUsername(rs.getString("username"));
                    teacher.setEmail(rs.getString("email"));
                    teacher.setFirstName(rs.getString("first_name"));
                    teacher.setLastName(rs.getString("last_name"));
                    teacher.setPhone(rs.getString("phone"));
                    teacher.setQualification(rs.getString("qualification"));
                    teacher.setSpecialization(rs.getString("specialization"));
                    teacher.setJoiningDate(rs.getDate("joining_date"));
                    teacher.setExperienceYears(rs.getBigDecimal("experience_years"));
                    teacher.setDateOfBirth(rs.getDate("date_of_birth"));
                    teacher.setGender(rs.getString("gender"));
                    teacher.setAddress(rs.getString("address"));
                    teacher.setStatus(rs.getString("status"));
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }

        return teacher;
    }


    // =========================================================
    // UPDATE TEACHER
    // =========================================================
    public boolean updateTeacher(
            long teacherId,
            int schoolId,
            String firstName,
            String lastName,
            String phone,
            String employeeCode,
            String qualification,
            String specialization,
            String joiningDate,
            String experienceYears,
            String dateOfBirth,
            String gender,
            String address,
            String status) {

        Connection con = null;
        PreparedStatement userStmt = null;
        PreparedStatement teacherStmt = null;

        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            String userSql =
                    "UPDATE users SET " +
                    "first_name = ?, last_name = ?, phone = ? " +
                    "WHERE user_id = (SELECT user_id FROM teachers " +
                    "                 WHERE teacher_id = ?)";

            userStmt = con.prepareStatement(userSql);
            userStmt.setString(1, firstName);
            userStmt.setString(2, lastName);
            userStmt.setString(3, phone);
            userStmt.setLong(4, teacherId);
            userStmt.executeUpdate();

            String teacherSql =
                    "UPDATE teachers SET " +
                    "employee_code = ?, qualification = ?, specialization = ?, " +
                    "joining_date = ?, experience_years = ?, date_of_birth = ?, " +
                    "gender = ?, address = ?, status = ? " +
                    "WHERE teacher_id = ? AND school_id = ?";

            teacherStmt = con.prepareStatement(teacherSql);
            teacherStmt.setString(1, employeeCode);
            teacherStmt.setString(2, qualification);
            teacherStmt.setString(3, specialization);

            if (joiningDate == null || joiningDate.trim().isEmpty()) {
                teacherStmt.setNull(4, java.sql.Types.DATE);
            } else {
                teacherStmt.setDate(4, java.sql.Date.valueOf(joiningDate));
            }

            if (experienceYears == null || experienceYears.trim().isEmpty()) {
                teacherStmt.setNull(5, java.sql.Types.DECIMAL);
            } else {
                teacherStmt.setBigDecimal(5, new java.math.BigDecimal(experienceYears));
            }

            if (dateOfBirth == null || dateOfBirth.trim().isEmpty()) {
                teacherStmt.setNull(6, java.sql.Types.DATE);
            } else {
                teacherStmt.setDate(6, java.sql.Date.valueOf(dateOfBirth));
            }

            if (gender == null || gender.trim().isEmpty()) {
                teacherStmt.setNull(7, java.sql.Types.VARCHAR);
            } else {
                teacherStmt.setString(7, gender);
            }

            teacherStmt.setString(8, address);
            teacherStmt.setString(9, status);
            teacherStmt.setLong(10, teacherId);
            teacherStmt.setInt(11, schoolId);

            int rows = teacherStmt.executeUpdate();

            con.commit();
            return rows > 0;

        } catch (Exception e) {
            e.printStackTrace();
            try { if (con != null) con.rollback(); }
            catch (SQLException ex) { ex.printStackTrace(); }
            return false;

        } finally {
            try { if (userStmt != null) userStmt.close(); }
            catch (SQLException e) { e.printStackTrace(); }
            try { if (teacherStmt != null) teacherStmt.close(); }
            catch (SQLException e) { e.printStackTrace(); }
            try { if (con != null) { con.setAutoCommit(true); con.close(); } }
            catch (SQLException e) { e.printStackTrace(); }
        }
    }


    // =========================================================
    // SOFT DELETE TEACHER (set status = INACTIVE)
    // =========================================================
    public boolean deleteTeacher(long teacherId, int schoolId) {
        String sql =
                "UPDATE teachers SET status = 'INACTIVE' " +
                "WHERE teacher_id = ? AND school_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setLong(1, teacherId);
            ps.setInt(2, schoolId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }
}
