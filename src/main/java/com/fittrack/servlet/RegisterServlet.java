package com.fittrack.servlet;

import com.fittrack.exception.AuthenticationException;
import com.fittrack.exception.ValidationException;
import com.fittrack.model.User;
import com.fittrack.service.UserService;
import com.fittrack.thread.NotificationThread;
import com.fittrack.util.ValidationUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * Servlet handling new user account registration.
 */
@WebServlet(name = "RegisterServlet", urlPatterns = {"/register"})
public class RegisterServlet extends HttpServlet {

    private final UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.getRequestDispatcher("/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String role = request.getParameter("role");

        if (role == null || role.trim().isEmpty()) {
            role = "USER";
        }
        role = role.trim().toUpperCase();

        try {
            // Strictly validate role to prevent privilege escalation (e.g. creating ADMIN accounts)
            ValidationUtil.validatePublicRegistrationRole(role);

            if (password == null || !password.equals(confirmPassword)) {
                throw new ValidationException("Passwords do not match.");
            }

            User registered = userService.registerUser(name, email, password, role);

            // Asynchronous welcome notification dispatched via worker thread
            NotificationThread.getInstance().enqueueNotification(
                    registered.getId(),
                    "Welcome to FitTrack, " + registered.getName() + "! Your account was successfully created."
            );

            response.sendRedirect(request.getContextPath() + "/login?success=Account+created+successfully!+Please+login.");

        } catch (ValidationException | AuthenticationException e) {
            request.setAttribute("errorMessage", e.getMessage());
            request.setAttribute("name", name);
            request.setAttribute("email", email);
            request.setAttribute("selectedRole", role);
            request.getRequestDispatcher("/register.jsp").forward(request, response);
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Registration failed: " + e.getMessage());
            request.getRequestDispatcher("/register.jsp").forward(request, response);
        }
    }
}
