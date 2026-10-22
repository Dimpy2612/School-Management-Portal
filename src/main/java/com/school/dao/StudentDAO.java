package com.school.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.school.model.Student;
import com.school.util.DBConnection;

public class StudentDAO {

    // =====================================================
    // Get current academic year for a school
    // =====================================================
    public long getCurrentAcademicYear(int schoolId) {
        String sql = "SELECT academic_year_id FROM academicyears " +
                     "WHERE school_id = ? AND is_current = 1 LIMIT 1";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, schoolId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getLong("academic_year_id");
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }


    // =====================================================
    // ADD STUDENT
    // =====================================================
    public boolean addStudent(
            int schoolId,
            String username, String email, String passwordHash,
            String firstName, String lastName, String phone,
            String admissionNo, String dateOfBirth, String gender,
            String bloodGroup, String address, String admissionDate,
            String emergencyContactName, String emergencyContactPhone,
            long classId, long sectionId, String rollNumber) {

        Connection con = null;
        PreparedStatement userStmt = null;
        PreparedStatement studentStmt = null;
        PreparedStatement classStmt = null;
        ResultSet userKeys = null;
        ResultSet studentKeys = null;

        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            String userSql =
                "INSERT INTO users (school_id, username, email, password_hash, role, " +
                "first_name, last_name, phone, is_active) " +
                "VALUES (?, ?, ?, ?, 'STUDENT', ?, ?, ?, 1)";

            userStmt = con.prepareStatement(userSql, PreparedStatement.RETURN_GENERATED_KEYS);
            userStmt.setInt(1, schoolId);
            userStmt.setString(2, username);
            userStmt.setString(3, email);
            userStmt.setString(4, passwordHash);
            userStmt.setString(5, firstName);
            userStmt.setString(6, lastName);
            userStmt.setString(7, phone);
            userStmt.executeUpdate();

            userKeys = userStmt.getGeneratedKeys();
            if (!userKeys.next()) { con.rollback(); return false; }
            long userId = userKeys.getLong(1);

            String studentSql =
                "INSERT INTO students (user_id, school_id, admission_no, date_of_birth, " +
                "gender, blood_group, address, admission_date, " +
                "emergency_contact_name, emergency_contact_phone, status) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'ACTIVE')";

            studentStmt = con.prepareStatement(studentSql, PreparedStatement.RETURN_GENERATED_KEYS);
            studentStmt.setLong(1, userId);
            studentStmt.setInt(2, schoolId);
            studentStmt.setString(3, admissionNo);

            if (dateOfBirth == null || dateOfBirth.trim().isEmpty()) {
                studentStmt.setNull(4, java.sql.Types.DATE);
            } else {
                studentStmt.setDate(4, java.sql.Date.valueOf(dateOfBirth));
            }

            if (gender == null || gender.trim().isEmpty()) {
                studentStmt.setNull(5, java.sql.Types.VARCHAR);
            } else {
                studentStmt.setString(5, gender);
            }

            studentStmt.setString(6, bloodGroup);
            studentStmt.setString(7, address);

            if (admissionDate == null || admissionDate.trim().isEmpty()) {
                studentStmt.setNull(8, java.sql.Types.DATE);
            } else {
                studentStmt.setDate(8, java.sql.Date.valueOf(admissionDate));
            }

            studentStmt.setString(9, emergencyContactName);
            studentStmt.setString(10, emergencyContactPhone);
            studentStmt.executeUpdate();

            studentKeys = studentStmt.getGeneratedKeys();
            if (!studentKeys.next()) { con.rollback(); return false; }
            long studentId = studentKeys.getLong(1);

            long academicYearId = getCurrentAcademicYear(schoolId);
            if (academicYearId <= 0) { con.rollback(); return false; }

            String classSql =
                "INSERT INTO studentclasses " +
                "(student_id, academic_year_id, class_id, section_id, " +
                "roll_number, admission_date, status) " +
                "VALUES (?, ?, ?, ?, ?, ?, 'ACTIVE')";

            classStmt = con.prepareStatement(classSql);
            classStmt.setLong(1, studentId);
            classStmt.setLong(2, academicYearId);
            classStmt.setLong(3, classId);
            classStmt.setLong(4, sectionId);
            classStmt.setString(5, rollNumber);

            if (admissionDate == null || admissionDate.trim().isEmpty()) {
                classStmt.setNull(6, java.sql.Types.DATE);
            } else {
                classStmt.setDate(6, java.sql.Date.valueOf(admissionDate));
            }

            classStmt.executeUpdate();

            con.commit();
            return true;

        } catch (Exception e) {
            e.printStackTrace();
            try { if (con != null) con.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            return false;

        } finally {
            try { if (userKeys != null) userKeys.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (studentKeys != null) studentKeys.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (userStmt != null) userStmt.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (studentStmt != null) studentStmt.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (classStmt != null) classStmt.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (con != null) { con.setAutoCommit(true); con.close(); } } catch (SQLException e) { e.printStackTrace(); }
        }
    }


    // =====================================================
    // GET ALL STUDENTS (with optional search + filters)
    // =====================================================
    public List<Student> getAllStudents(
            int schoolId, String search, Long classId, Long sectionId) {

        List<Student> students = new ArrayList<>();

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT s.student_id, s.user_id, s.school_id, s.admission_no, ");
        sql.append("s.date_of_birth, s.gender, s.blood_group, s.address, s.admission_date, ");
        sql.append("s.emergency_contact_name, s.emergency_contact_phone, s.status, ");
        sql.append("u.username, u.email, u.first_name, u.last_name, u.phone, ");
        sql.append("sc.student_class_id, sc.class_id, sc.section_id, sc.roll_number, sc.academic_year_id, ");
        sql.append("c.class_name, sec.section_name ");
        sql.append("FROM students s ");
        sql.append("INNER JOIN users u ON u.user_id = s.user_id ");
        sql.append("LEFT JOIN studentclasses sc ON sc.student_id = s.student_id AND sc.status = 'ACTIVE' ");
        sql.append("LEFT JOIN classes c ON c.class_id = sc.class_id ");
        sql.append("LEFT JOIN sections sec ON sec.section_id = sc.section_id ");
        sql.append("WHERE s.school_id = ? ");

        List<Object> params = new ArrayList<>();
        params.add(schoolId);

        // ==================================================
        // SEARCH: split words, match any word against any field
        // e.g. "Ronit Garg" matches Ronit (first_name) OR Garg (last_name)
        // ==================================================
        if (search != null && !search.trim().isEmpty()) {
            String[] words = search.trim().split("\\s+");

            sql.append("AND (");
            for (int i = 0; i < words.length; i++) {
                if (i > 0) sql.append(" OR ");
                sql.append("(u.first_name LIKE ? ");
                sql.append("OR u.last_name LIKE ? ");
                sql.append("OR u.username LIKE ? ");
                sql.append("OR u.email LIKE ? ");
                sql.append("OR s.admission_no LIKE ?)");

                String pattern = "%" + words[i] + "%";
                params.add(pattern);
                params.add(pattern);
                params.add(pattern);
                params.add(pattern);
                params.add(pattern);
            }
            sql.append(") ");
        }

        if (classId != null && classId > 0) {
            sql.append("AND sc.class_id = ? ");
            params.add(classId);
        }

        if (sectionId != null && sectionId > 0) {
            sql.append("AND sc.section_id = ? ");
            params.add(sectionId);
        }

        sql.append("ORDER BY s.student_id DESC");



        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    students.add(mapStudent(rs));
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }

        return students;
    }


    // =====================================================
    // GET ONE STUDENT BY ID
    // =====================================================
    public Student getStudentById(long studentId, int schoolId) {

        String sql =
            "SELECT s.student_id, s.user_id, s.school_id, s.admission_no, " +
            "s.date_of_birth, s.gender, s.blood_group, s.address, s.admission_date, " +
            "s.emergency_contact_name, s.emergency_contact_phone, s.status, " +
            "u.username, u.email, u.first_name, u.last_name, u.phone, " +
            "sc.student_class_id, sc.class_id, sc.section_id, sc.roll_number, sc.academic_year_id, " +
            "c.class_name, sec.section_name " +
            "FROM students s " +
            "INNER JOIN users u ON u.user_id = s.user_id " +
            "LEFT JOIN studentclasses sc ON sc.student_id = s.student_id AND sc.status = 'ACTIVE' " +
            "LEFT JOIN classes c ON c.class_id = sc.class_id " +
            "LEFT JOIN sections sec ON sec.section_id = sc.section_id " +
            "WHERE s.student_id = ? AND s.school_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setLong(1, studentId);
            ps.setInt(2, schoolId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapStudent(rs);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }


    // =====================================================
    // UPDATE STUDENT
    // =====================================================
    public boolean updateStudent(
            long studentId, int schoolId,
            String firstName, String lastName, String phone,
            String admissionNo, String dateOfBirth, String gender,
            String bloodGroup, String address, String admissionDate,
            String emergencyContactName, String emergencyContactPhone,
            long classId, long sectionId, String rollNumber, String status) {

        Connection con = null;
        PreparedStatement userStmt = null;
        PreparedStatement studentStmt = null;
        PreparedStatement classStmt = null;

        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            String userSql = "UPDATE users SET first_name = ?, last_name = ?, phone = ? " +
                             "WHERE user_id = (SELECT user_id FROM students WHERE student_id = ?)";
            userStmt = con.prepareStatement(userSql);
            userStmt.setString(1, firstName);
            userStmt.setString(2, lastName);
            userStmt.setString(3, phone);
            userStmt.setLong(4, studentId);
            userStmt.executeUpdate();

            String studentSql =
                "UPDATE students SET admission_no = ?, date_of_birth = ?, gender = ?, " +
                "blood_group = ?, address = ?, admission_date = ?, " +
                "emergency_contact_name = ?, emergency_contact_phone = ?, status = ? " +
                "WHERE student_id = ? AND school_id = ?";

            studentStmt = con.prepareStatement(studentSql);
            studentStmt.setString(1, admissionNo);

            if (dateOfBirth == null || dateOfBirth.trim().isEmpty()) {
                studentStmt.setNull(2, java.sql.Types.DATE);
            } else {
                studentStmt.setDate(2, java.sql.Date.valueOf(dateOfBirth));
            }

            if (gender == null || gender.trim().isEmpty()) {
                studentStmt.setNull(3, java.sql.Types.VARCHAR);
            } else {
                studentStmt.setString(3, gender);
            }

            studentStmt.setString(4, bloodGroup);
            studentStmt.setString(5, address);

            if (admissionDate == null || admissionDate.trim().isEmpty()) {
                studentStmt.setNull(6, java.sql.Types.DATE);
            } else {
                studentStmt.setDate(6, java.sql.Date.valueOf(admissionDate));
            }

            studentStmt.setString(7, emergencyContactName);
            studentStmt.setString(8, emergencyContactPhone);
            studentStmt.setString(9, status);
            studentStmt.setLong(10, studentId);
            studentStmt.setInt(11, schoolId);
            studentStmt.executeUpdate();

            String checkSql = "SELECT student_class_id FROM studentclasses " +
                              "WHERE student_id = ? AND status = 'ACTIVE' LIMIT 1";
            long studentClassId = -1;
            try (PreparedStatement check = con.prepareStatement(checkSql)) {
                check.setLong(1, studentId);
                try (ResultSet rs = check.executeQuery()) {
                    if (rs.next()) studentClassId = rs.getLong("student_class_id");
                }
            }

            long academicYearId = getCurrentAcademicYear(schoolId);

            if (studentClassId > 0) {
                String updateClassSql =
                    "UPDATE studentclasses SET class_id = ?, section_id = ?, " +
                    "roll_number = ?, admission_date = ?, status = ? " +
                    "WHERE student_class_id = ?";
                classStmt = con.prepareStatement(updateClassSql);
                classStmt.setLong(1, classId);
                classStmt.setLong(2, sectionId);
                classStmt.setString(3, rollNumber);

                if (admissionDate == null || admissionDate.trim().isEmpty()) {
                    classStmt.setNull(4, java.sql.Types.DATE);
                } else {
                    classStmt.setDate(4, java.sql.Date.valueOf(admissionDate));
                }

                classStmt.setString(5, "ACTIVE".equals(status) ? "ACTIVE" : "INACTIVE");
                classStmt.setLong(6, studentClassId);
                classStmt.executeUpdate();

            } else if (academicYearId > 0) {
                String insertClassSql =
                    "INSERT INTO studentclasses " +
                    "(student_id, academic_year_id, class_id, section_id, " +
                    "roll_number, admission_date, status) " +
                    "VALUES (?, ?, ?, ?, ?, ?, 'ACTIVE')";
                classStmt = con.prepareStatement(insertClassSql);
                classStmt.setLong(1, studentId);
                classStmt.setLong(2, academicYearId);
                classStmt.setLong(3, classId);
                classStmt.setLong(4, sectionId);
                classStmt.setString(5, rollNumber);

                if (admissionDate == null || admissionDate.trim().isEmpty()) {
                    classStmt.setNull(6, java.sql.Types.DATE);
                } else {
                    classStmt.setDate(6, java.sql.Date.valueOf(admissionDate));
                }
                classStmt.executeUpdate();
            }

            con.commit();
            return true;

        } catch (Exception e) {
            e.printStackTrace();
            try { if (con != null) con.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            return false;

        } finally {
            try { if (userStmt != null) userStmt.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (studentStmt != null) studentStmt.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (classStmt != null) classStmt.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (con != null) { con.setAutoCommit(true); con.close(); } } catch (SQLException e) { e.printStackTrace(); }
        }
    }


    // =====================================================
    // SOFT DELETE STUDENT
    // =====================================================
    public boolean deleteStudent(long studentId, int schoolId) {

        Connection con = null;
        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            try (PreparedStatement ps1 = con.prepareStatement(
                    "UPDATE students SET status = 'INACTIVE' " +
                    "WHERE student_id = ? AND school_id = ?")) {
                ps1.setLong(1, studentId);
                ps1.setInt(2, schoolId);
                ps1.executeUpdate();
            }

            try (PreparedStatement ps2 = con.prepareStatement(
                    "UPDATE studentclasses SET status = 'INACTIVE' " +
                    "WHERE student_id = ?")) {
                ps2.setLong(1, studentId);
                ps2.executeUpdate();
            }

            con.commit();
            return true;

        } catch (Exception e) {
            e.printStackTrace();
            try { if (con != null) con.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            return false;
        } finally {
            try { if (con != null) { con.setAutoCommit(true); con.close(); } } catch (SQLException e) { e.printStackTrace(); }
        }
    }


    // =====================================================
    // DUPLICATE CHECKS
    // =====================================================
    public boolean usernameExists(String username) {
        String sql = "SELECT user_id FROM users WHERE username = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    public boolean emailExists(String email) {
        String sql = "SELECT user_id FROM users WHERE email = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    public boolean admissionNoExists(String admissionNo) {
        String sql = "SELECT student_id FROM students WHERE admission_no = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, admissionNo);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    public boolean admissionNoExistsExcept(String admissionNo, long studentId) {
        String sql = "SELECT student_id FROM students " +
                     "WHERE admission_no = ? AND student_id <> ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, admissionNo);
            ps.setLong(2, studentId);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }


    // =====================================================
    // STATS
    // =====================================================
    public int getCountByStatus(int schoolId, String status) {
        String sql = "SELECT COUNT(*) FROM students WHERE school_id = ? AND status = ?";
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


    // =====================================================
    // Helper: map ResultSet row to Student
    // =====================================================
    private Student mapStudent(ResultSet rs) throws SQLException {
        Student s = new Student();
        s.setStudentId(rs.getLong("student_id"));
        s.setUserId(rs.getLong("user_id"));
        s.setSchoolId(rs.getInt("school_id"));
        s.setAdmissionNo(rs.getString("admission_no"));
        s.setDateOfBirth(rs.getDate("date_of_birth"));
        s.setGender(rs.getString("gender"));
        s.setBloodGroup(rs.getString("blood_group"));
        s.setAddress(rs.getString("address"));
        s.setAdmissionDate(rs.getDate("admission_date"));
        s.setEmergencyContactName(rs.getString("emergency_contact_name"));
        s.setEmergencyContactPhone(rs.getString("emergency_contact_phone"));
        s.setStatus(rs.getString("status"));

        s.setUsername(rs.getString("username"));
        s.setEmail(rs.getString("email"));
        s.setFirstName(rs.getString("first_name"));
        s.setLastName(rs.getString("last_name"));
        s.setPhone(rs.getString("phone"));

        long scId = rs.getLong("student_class_id");
        if (!rs.wasNull()) {
            s.setStudentClassId(scId);
            s.setClassId(rs.getLong("class_id"));
            s.setSectionId(rs.getLong("section_id"));
            s.setRollNumber(rs.getString("roll_number"));
            s.setAcademicYearId(rs.getLong("academic_year_id"));
            s.setClassName(rs.getString("class_name"));
            s.setSectionName(rs.getString("section_name"));
        }
        return s;
    }
}
