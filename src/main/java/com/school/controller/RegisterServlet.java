package com.school.controller;

import java.io.IOException;
import java.io.PrintWriter;

import com.school.dao.UserDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String schoolIdText = request.getParameter("schoolId");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        response.setContentType("text/html;charset=UTF-8");

        PrintWriter out = response.getWriter();

        // Check password
        if (!password.equals(confirmPassword)) {

            out.println("<h2>Password and Confirm Password do not match.</h2>");
            out.println("<a href='register.html'>Go Back</a>");

            return;
        }

        try {

            long schoolId = Long.parseLong(schoolIdText);

            /*
             * Temporary:
             * Later we will replace this with BCrypt hashing.
             */
            String passwordHash = password;

            UserDAO userDAO = new UserDAO();

            boolean registered = userDAO.registerAdmin(
                    firstName,
                    lastName,
                    username,
                    email,
                    phone,
                    schoolId,
                    passwordHash
            );

            if (registered) {

                out.println("<!DOCTYPE html>");
                out.println("<html>");
                out.println("<head>");
                out.println("<title>Registration Successful</title>");
                out.println("</head>");

                out.println("<body>");

                out.println("<h2>Admin Registration Successful!</h2>");

                out.println("<p>Your admin account has been created successfully.</p>");

                out.println("<a href='login.html'>Go to Login</a>");

                out.println("</body>");
                out.println("</html>");

            } else {

                out.println("<h2>Registration Failed.</h2>");
                out.println("<p>Please try again.</p>");
                out.println("<a href='register.html'>Go Back</a>");
            }

        } catch (NumberFormatException e) {

            out.println("<h2>Invalid School Selection.</h2>");
            out.println("<a href='register.html'>Go Back</a>");

        } catch (Exception e) {

            e.printStackTrace();

            out.println("<h2>Something went wrong.</h2>");
            out.println("<p>" + e.getMessage() + "</p>");
            out.println("<a href='register.html'>Go Back</a>");
        }
    }
}
