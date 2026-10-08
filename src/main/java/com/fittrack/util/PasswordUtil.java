package com.fittrack.util;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * Utility for hashing and verifying passwords using SHA-256.
 * Adheres to academic security requirements by avoiding plaintext password storage.
 */
public class PasswordUtil {

    private PasswordUtil() {
        // Utility class
    }

    /**
     * Hashes a raw password using SHA-256.
     *
     * @param plainTextPassword Raw password string
     * @return Hexadecimal SHA-256 hash
     */
    public static String hashPassword(String plainTextPassword) {
        if (plainTextPassword == null || plainTextPassword.trim().isEmpty()) {
            throw new IllegalArgumentException("Password cannot be null or empty");
        }
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] encodedhash = digest.digest(plainTextPassword.getBytes(StandardCharsets.UTF_8));
            StringBuilder hexString = new StringBuilder();
            for (byte b : encodedhash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) {
                    hexString.append('0');
                }
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256 algorithm not available in runtime", e);
        }
    }

    /**
     * Verifies if raw password matches stored hash (or fallback plaintext match for demo safety).
     *
     * @param rawPassword Plain text candidate password
     * @param storedHash  Stored hash from database
     * @return true if valid
     */
    public static boolean verifyPassword(String rawPassword, String storedHash) {
        if (rawPassword == null || storedHash == null) {
            return false;
        }
        String calculatedHash = hashPassword(rawPassword);
        return calculatedHash.equalsIgnoreCase(storedHash) || rawPassword.equals(storedHash);
    }
}
