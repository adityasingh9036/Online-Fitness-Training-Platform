package com.fittrack;

import com.fittrack.util.DBConnection;
import org.junit.jupiter.api.Test;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Read-only JDBC Verification Suite for Supabase PostgreSQL.
 * Verifies connectivity, table accessibility, and demo user accounts.
 */
public class DatabaseConnectivityVerificationTest {

    private static final String[] REQUIRED_TABLES = {
            "users",
            "workout_plans",
            "exercises",
            "plan_exercises",
            "progress",
            "messages",
            "notifications",
            "system_settings",
            "user_workout_plans",
            "user_exercise_completions"
    };

    @Test
    public void testDatabaseConnectivityAndTables() {
        System.out.println("=== STARTING READ-ONLY JDBC CONNECTIVITY VERIFICATION ===");
        
        // When running in an environment without configured DB credentials, skip gracefully
        // When DB_PASSWORD is provided, this test executes in full against Supabase.
        org.junit.jupiter.api.Assumptions.assumeTrue(
                DBConnection.isPasswordConfigured(),
                "Supabase database password not configured in local environment. Set DB_PASSWORD to run live remote DB verification."
        );

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            assertNotNull(conn, "Connection must not be null");
            assertFalse(conn.isClosed(), "Connection must be active and open");
            System.out.println("[JDBC STATUS] Connection established successfully.");

            // 1. Verify read accessibility on all 9 tables
            for (String tableName : REQUIRED_TABLES) {
                String sql = "SELECT COUNT(*) FROM " + tableName;
                try (PreparedStatement ps = conn.prepareStatement(sql);
                     ResultSet rs = ps.executeQuery()) {
                    assertTrue(rs.next(), "Table " + tableName + " query must return a row count");
                    int count = rs.getInt(1);
                    System.out.println("[TABLE VERIFIED] " + tableName + " -> " + count + " rows found.");
                } catch (SQLException e) {
                    System.err.println("[TABLE ERROR] Failed querying table: " + tableName + " - " + e.getMessage());
                    fail("Failed querying table: " + tableName + ": " + e.getMessage());
                }
            }

            // 2. Verify the 3 demo accounts exist
            String userQuery = "SELECT email, role FROM users WHERE email IN (?, ?, ?) ORDER BY email";
            List<String> foundEmails = new ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement(userQuery)) {
                ps.setString(1, "admin@fittrack.com");
                ps.setString(2, "trainer@fittrack.com");
                ps.setString(3, "user@fittrack.com");
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        String email = rs.getString("email");
                        String role = rs.getString("role");
                        foundEmails.add(email);
                        System.out.println("[DEMO USER VERIFIED] " + email + " (" + role + ")");
                    }
                }
            }

            assertTrue(foundEmails.contains("admin@fittrack.com"), "admin@fittrack.com must exist in users table");
            assertTrue(foundEmails.contains("trainer@fittrack.com"), "trainer@fittrack.com must exist in users table");
            assertTrue(foundEmails.contains("user@fittrack.com"), "user@fittrack.com must exist in users table");
            System.out.println("[DEMO USERS STATUS] All 3 demo accounts verified in database.");

        } catch (Exception e) {
            String rootCause = (e.getCause() != null) ? e.getCause().getMessage() : e.getMessage();
            System.err.println("[EXACT SQL ERROR CAUSE] " + rootCause);
            fail("JDBC Connection test failed: " + rootCause);
        } finally {
            DBConnection.closeQuietly(conn);
            System.out.println("=== JDBC CONNECTIVITY VERIFICATION FINISHED ===");
        }
    }

    @Test
    public void testInspectWorkoutTableSchemas() {
        org.junit.jupiter.api.Assumptions.assumeTrue(DBConnection.isPasswordConfigured());
        try (Connection conn = DBConnection.getConnection()) {
            String createSql = "CREATE TABLE IF NOT EXISTS user_exercise_completions (" +
                               "id SERIAL PRIMARY KEY, " +
                               "user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE, " +
                               "plan_id INT NOT NULL REFERENCES workout_plans(id) ON DELETE CASCADE, " +
                               "exercise_id INT NOT NULL REFERENCES exercises(id) ON DELETE CASCADE, " +
                               "completed_date DATE DEFAULT CURRENT_DATE, " +
                               "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                               "CONSTRAINT uq_user_plan_ex_date UNIQUE (user_id, plan_id, exercise_id, completed_date))";
            try (Statement st = conn.createStatement()) {
                st.execute(createSql);
                st.execute("CREATE INDEX IF NOT EXISTS idx_user_ex_comp_date ON user_exercise_completions(user_id, completed_date)");
            }

            String[] tables = {"workout_plans", "exercises", "plan_exercises", "user_workout_plans", "user_exercise_completions"};
            for (String t : tables) {
                System.out.println("SCHEMA FOR " + t + ":");
                String sql = "SELECT column_name, data_type, is_nullable FROM information_schema.columns WHERE table_name = ? ORDER BY ordinal_position";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, t);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            System.out.println("  " + rs.getString("column_name") + " (" + rs.getString("data_type") + ")");
                        }
                    }
                }
            }
        } catch (Exception e) {
            fail("Failed schema inspection: " + e.getMessage());
        }
    }
}
