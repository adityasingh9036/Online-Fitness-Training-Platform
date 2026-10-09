package com.fittrack;

import com.fittrack.dao.ProgressDAO;
import com.fittrack.dao.UserDAO;
import com.fittrack.model.Progress;
import com.fittrack.model.User;
import com.fittrack.service.ProgressService;
import com.fittrack.thread.ProgressReportThread;
import com.fittrack.util.DBConnection;
import org.junit.jupiter.api.Test;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.Statement;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Verification Suite for BMI Formula, Weight-Change Calculations,
 * and Goal-Aware Automated Progress Reporting.
 */
public class ProgressCalculationTest {

    @Test
    public void testBMICalculationFormula() {
        // BMI = weight in kilograms / (height in metres * height in metres)
        // 70 kg, 170 cm -> 70 / (1.7 * 1.7) = 70 / 2.89 = 24.221... -> 24.2 (Normal Weight)
        Progress pCurrent = new Progress(1, 3, 70.0, 170.0, "Chest: 38in", "Muscle Gain", new Date(System.currentTimeMillis()));
        assertEquals(24.2, pCurrent.calculateBMI(), 0.05);
        assertEquals("Normal Weight", pCurrent.getBMICategory());

        // 68 kg, 170 cm -> 68 / 2.89 = 23.529... -> 23.5 (Normal Weight)
        Progress pStart = new Progress(2, 3, 68.0, 170.0, "Chest: 37in", "Muscle Gain", new Date(System.currentTimeMillis()));
        assertEquals(23.5, pStart.calculateBMI(), 0.05);
        assertEquals("Normal Weight", pStart.getBMICategory());

        // Height passed as meters (1.70 m) safeguard
        Progress pMeters = new Progress(3, 3, 70.0, 1.70, "Chest: 38in", "Muscle Gain", new Date(System.currentTimeMillis()));
        assertEquals(24.2, pMeters.calculateBMI(), 0.05);

        // Underweight test (< 18.5)
        Progress pUnder = new Progress(4, 3, 50.0, 170.0, "", "Gain", new Date(System.currentTimeMillis()));
        assertEquals(17.3, pUnder.calculateBMI(), 0.05);
        assertEquals("Underweight", pUnder.getBMICategory());

        // Overweight test (25.0 - 29.9)
        Progress pOver = new Progress(5, 3, 85.0, 175.0, "", "Loss", new Date(System.currentTimeMillis()));
        assertEquals(27.8, pOver.calculateBMI(), 0.05);
        assertEquals("Overweight", pOver.getBMICategory());

        // Obese test (>= 30.0)
        Progress pObese = new Progress(6, 3, 100.0, 170.0, "", "Loss", new Date(System.currentTimeMillis()));
        assertEquals(34.6, pObese.calculateBMI(), 0.05);
        assertEquals("Obese", pObese.getBMICategory());
    }

    @Test
    public void testWeightChangeCalculation() {
        // Formula: Current weight - Starting weight
        Date now = new Date(System.currentTimeMillis());
        Date weekAgo = new Date(System.currentTimeMillis() - 7L * 24 * 60 * 60 * 1000);
        Date twoWeeksAgo = new Date(System.currentTimeMillis() - 14L * 24 * 60 * 60 * 1000);

        ProgressDAO mockDao = new ProgressDAO() {
            @Override
            public List<Progress> findByUserId(int userId) {
                List<Progress> list = new java.util.ArrayList<>();
                Progress p1 = new Progress(3, userId, 70.0, 170.0, "Chest: 38in", "Muscle Gain", now);
                Progress p2 = new Progress(2, userId, 69.0, 170.0, "Chest: 37.5in", "Muscle Gain", weekAgo);
                Progress p3 = new Progress(1, userId, 68.0, 170.0, "Chest: 37in", "Muscle Gain", twoWeeksAgo);

                // Calculate consecutive check-in deltas
                p1.setWeightChange(Math.round((p1.getWeight() - p2.getWeight()) * 10.0) / 10.0); // +1.0
                p2.setWeightChange(Math.round((p2.getWeight() - p3.getWeight()) * 10.0) / 10.0); // +1.0
                p3.setWeightChange(0.0); // baseline

                list.add(p1);
                list.add(p2);
                list.add(p3);
                return list;
            }
        };

        ProgressService service = new ProgressService(mockDao);
        Map<String, Object> summary = service.calculateProgressSummary(3);

        assertTrue((Boolean) summary.get("hasData"));
        assertEquals(70.0, (Double) summary.get("currentWeight"), 0.01);
        assertEquals(68.0, (Double) summary.get("startWeight"), 0.01);
        assertEquals(2.0, (Double) summary.get("netChange"), 0.01); // Current weight (70.0) - Starting weight (68.0) = +2.0
        assertEquals(24.2, (Double) summary.get("currentBmi"), 0.05);
        assertEquals("Normal Weight", summary.get("bmiCategory"));
        assertEquals("Muscle Gain", summary.get("currentGoal"));
        assertEquals(3, (Integer) summary.get("logsCount"));

        // Verify deltas
        List<Progress> history = mockDao.findByUserId(3);
        assertEquals(3, history.size());
        assertEquals(1.0, history.get(0).getWeightChange(), 0.01);
        assertEquals(1.0, history.get(1).getWeightChange(), 0.01);
        assertEquals(0.0, history.get(2).getWeightChange(), 0.01);
    }

    @Test
    public void testApplyAndVerifyDemoAccountConsistency() {
        org.junit.jupiter.api.Assumptions.assumeTrue(
                DBConnection.isPasswordConfigured(),
                "Supabase DB password not configured; skipping remote demo user data verification."
        );

        UserDAO userDAO = new UserDAO();
        User demoUser = userDAO.findByEmail("user@fittrack.com");
        assertNotNull(demoUser, "Demo user user@fittrack.com must exist");
        int demoUserId = demoUser.getId();

        // Ensure database progress records for Alex Johnson are updated to consistent muscle-gain values
        try (Connection conn = DBConnection.getConnection()) {
            // Delete old inconsistent records for ONLY this demo user
            try (PreparedStatement ps = conn.prepareStatement("DELETE FROM progress WHERE user_id = ?")) {
                ps.setInt(1, demoUserId);
                ps.executeUpdate();
            }

            // Insert 3 consistent records
            String insertSql = "INSERT INTO progress (user_id, weight, height, body_measurement, fitness_goal, record_date) " +
                               "VALUES (?, ?, ?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                // Day -14: 68.0 kg, 170.0 cm
                ps.setInt(1, demoUserId);
                ps.setDouble(2, 68.0);
                ps.setDouble(3, 170.0);
                ps.setString(4, "Chest: 37in, Waist: 31in, Arms: 13.5in");
                ps.setString(5, "Muscle Gain");
                ps.setDate(6, new Date(System.currentTimeMillis() - 14L * 24 * 60 * 60 * 1000));
                ps.executeUpdate();

                // Day -7: 69.0 kg, 170.0 cm
                ps.setInt(1, demoUserId);
                ps.setDouble(2, 69.0);
                ps.setDouble(3, 170.0);
                ps.setString(4, "Chest: 37.5in, Waist: 31in, Arms: 13.8in");
                ps.setString(5, "Muscle Gain");
                ps.setDate(6, new Date(System.currentTimeMillis() - 7L * 24 * 60 * 60 * 1000));
                ps.executeUpdate();

                // Day 0: 70.0 kg, 170.0 cm
                ps.setInt(1, demoUserId);
                ps.setDouble(2, 70.0);
                ps.setDouble(3, 170.0);
                ps.setString(4, "Chest: 38in, Waist: 31.2in, Arms: 14.0in");
                ps.setString(5, "Muscle Gain");
                ps.setDate(6, new Date(System.currentTimeMillis()));
                ps.executeUpdate();
            }

            // Invalidate report cache to refresh with new data
            ProgressReportThread.invalidateCachedReport(demoUserId);

            // Verify ProgressDAO & ProgressService calculations
            ProgressDAO progressDAO = new ProgressDAO();
            ProgressService progressService = new ProgressService(progressDAO);

            Progress latest = progressService.getLatestProgress(demoUserId);
            assertNotNull(latest);
            assertEquals(70.0, latest.getWeight(), 0.01);
            assertEquals(170.0, latest.getHeight(), 0.01);
            assertEquals("Muscle Gain", latest.getFitnessGoal());
            assertEquals(24.2, latest.calculateBMI(), 0.05);
            assertEquals("Normal Weight", latest.getBMICategory());

            Map<String, Object> summary = progressService.calculateProgressSummary(demoUserId);
            assertTrue((Boolean) summary.get("hasData"));
            assertEquals(70.0, (Double) summary.get("currentWeight"), 0.01);
            assertEquals(68.0, (Double) summary.get("startWeight"), 0.01);
            assertEquals(2.0, (Double) summary.get("netChange"), 0.01); // 70 - 68 = +2.0 kg
            assertEquals(24.2, (Double) summary.get("currentBmi"), 0.05);
            assertEquals("Normal Weight", summary.get("bmiCategory"));

            // Verify report generated by thread
            String report = ProgressReportThread.getCachedReport(demoUserId);
            assertTrue(report.contains("Current Weight: 70.0 kg"));
            assertTrue(report.contains("Starting Weight: 68.0 kg"));
            assertTrue(report.contains("Net Weight Change: +2.0 kg"));
            assertTrue(report.contains("Current BMI: 24.2 (Normal Weight)"));
            assertTrue(report.contains("Active Fitness Goal: Muscle Gain"));
            assertTrue(report.contains("Progressive muscle gain trend observed"));

        } catch (Exception e) {
            fail("Failed validating demo account consistency: " + e.getMessage());
        }
    }
}
