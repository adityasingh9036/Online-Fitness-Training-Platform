package com.fittrack.util;

import com.fittrack.exception.ValidationException;
import java.util.regex.Pattern;

/**
 * Input validation utility class for user data, workouts, and measurements.
 */
public class ValidationUtil {

    private static final Pattern EMAIL_PATTERN = Pattern.compile("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$");

    private ValidationUtil() {
        // Utility class
    }

    public static void validateNotEmpty(String value, String fieldName) throws ValidationException {
        if (value == null || value.trim().isEmpty()) {
            throw new ValidationException(fieldName + " is required and cannot be empty.");
        }
    }

    public static void validateEmail(String email) throws ValidationException {
        validateNotEmpty(email, "Email");
        if (!EMAIL_PATTERN.matcher(email.trim()).matches()) {
            throw new ValidationException("Invalid email format. Please enter a valid email address.");
        }
    }

    public static void validatePassword(String password) throws ValidationException {
        validateNotEmpty(password, "Password");
        if (password.trim().length() < 6) {
            throw new ValidationException("Password must be at least 6 characters long.");
        }
    }

    public static void validatePositiveNumber(double value, String fieldName) throws ValidationException {
        if (value <= 0) {
            throw new ValidationException(fieldName + " must be greater than zero.");
        }
    }

    public static void validateRole(String role) throws ValidationException {
        validateNotEmpty(role, "Role");
        String upper = role.trim().toUpperCase();
        if (!upper.equals("ADMIN") && !upper.equals("TRAINER") && !upper.equals("USER")) {
            throw new ValidationException("Invalid role: " + role + ". Must be ADMIN, TRAINER, or USER.");
        }
    }
}
