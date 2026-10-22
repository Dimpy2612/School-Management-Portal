package com.school.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import com.school.util.DBConnection;

public class UserDAO {

    public boolean registerAdmin(
            String firstName,
            String lastName,
            String username,
            String email,
            String phone,
            long schoolId,
            String passwordHash) {

        String sql = "INSERT INTO users "
                + "(school_id, username, email, password_hash, role, "
                + "first_name, last_name, phone, is_active, email_verified) "
                + "VALUES (?, ?, ?, ?, 'ADMIN', ?, ?, ?, 1, 0)";

        try (
            Connection connection = DBConnection.getConnection();
            PreparedStatement statement = connection.prepareStatement(sql)
        ) {

            statement.setLong(1, schoolId);
            statement.setString(2, username);
            statement.setString(3, email);
            statement.setString(4, passwordHash);
            statement.setString(5, firstName);
            statement.setString(6, lastName);
            statement.setString(7, phone);

            int rowsInserted = statement.executeUpdate();

            return rowsInserted > 0;

        } catch (SQLException e) {

            e.printStackTrace();
            return false;
        }
    }
}
