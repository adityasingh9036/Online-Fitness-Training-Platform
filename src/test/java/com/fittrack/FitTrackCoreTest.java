package com.fittrack;

import com.fittrack.model.*;
import com.fittrack.thread.NotificationThread;
import com.fittrack.thread.ProgressReportThread;
import com.fittrack.util.PasswordUtil;
import com.fittrack.util.ValidationUtil;
import org.junit.jupiter.api.Test;

import java.sql.Date;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Unit & Architecture Verification Suite for FitTrack.
 * Validates OOP Hierarchy, Polymorphism, Multithreading, and Validation.
 */
public class FitTrackCoreTest {

    @Test
    public void testOOPPolymorphismAndHierarchy() {
        // Test User abstract hierarchy
        User admin = new Admin(1, "Admin User", "admin@fittrack.com", "pass", null);
        User trainer = new Trainer(2, "Coach Marcus", "trainer@fittrack.com", "pass", null);
        User member = new FitnessUser(3, "Alex Johnson", "user@fittrack.com", "pass", null);

        // Verify Inheritance
        assertTrue(admin instanceof User);
        assertTrue(trainer instanceof User);
        assertTrue(member instanceof User);

        // Verify Authenticatable contract
        assertTrue(admin instanceof Authenticatable);
        assertTrue(trainer instanceof Authenticatable);
        assertTrue(member instanceof Authenticatable);

        // Verify DashboardAccess contract
        assertTrue(admin instanceof DashboardAccess);
        assertTrue(trainer instanceof DashboardAccess);
        assertTrue(member instanceof DashboardAccess);

        // Verify Polymorphic Method Overriding
        assertEquals("System Administrator", admin.getRoleTitle());
        assertEquals("Certified Fitness Trainer", trainer.getRoleTitle());
        assertEquals("Fitness Member", member.getRoleTitle());

        assertEquals("admin/dashboard", admin.getDashboardUrl());
        assertEquals("trainer/dashboard", trainer.getDashboardUrl());
        assertEquals("user/dashboard", member.getDashboardUrl());
    }

    @Test
    public void testPasswordHashingSecurity() {
        String raw = "superSecurePass123";
        String hashed = PasswordUtil.hashPassword(raw);

        assertNotNull(hashed);
        assertNotEquals(raw, hashed);
        assertEquals(64, hashed.length(), "SHA-256 hash must be 64 hexadecimal characters");

        // Verify matching
        assertTrue(PasswordUtil.verifyPassword(raw, hashed));
        assertFalse(PasswordUtil.verifyPassword("wrongPassword", hashed));
    }

    @Test
    public void testProgressBMICalculation() {
        // Height: 180cm, Weight: 80kg -> BMI = 80 / (1.8 * 1.8) = 24.7 (Normal Weight)
        Progress p = new Progress(1, 10, 80.0, 180.0, "Waist: 32", "Maintenance", new Date(System.currentTimeMillis()));
        double bmi = p.calculateBMI();

        assertEquals(24.7, bmi, 0.1);
        assertEquals("Normal Weight", p.getBMICategory());

        // Test Overweight (25.0 - 29.9)
        Progress pOver = new Progress(2, 10, 85.0, 175.0, "Waist: 35", "Loss", new Date(System.currentTimeMillis()));
        assertEquals("Overweight", pOver.getBMICategory());
    }

    @Test
    public void testValidationUtils() {
        assertDoesNotThrow(() -> ValidationUtil.validateEmail("test@example.com"));
        assertThrows(Exception.class, () -> ValidationUtil.validateEmail("invalid-email"));

        assertDoesNotThrow(() -> ValidationUtil.validatePassword("secret123"));
        assertThrows(Exception.class, () -> ValidationUtil.validatePassword("123")); // too short

        assertDoesNotThrow(() -> ValidationUtil.validateRole("ADMIN"));
        assertDoesNotThrow(() -> ValidationUtil.validateRole("TRAINER"));
        assertDoesNotThrow(() -> ValidationUtil.validateRole("USER"));
        assertThrows(Exception.class, () -> ValidationUtil.validateRole("HACKER"));
    }

    @Test
    public void testMultithreadingComponents() throws InterruptedException {
        // Test NotificationThread worker queue
        NotificationThread notifWorker = NotificationThread.getInstance();
        assertNotNull(notifWorker);
        assertDoesNotThrow(() -> notifWorker.enqueueNotification(1, "Test multithread notification"));

        // Test ProgressReportThread execution & synchronization
        ProgressReportThread reportThread = new ProgressReportThread(999);
        reportThread.start();
        reportThread.join(2000);

        String cachedReport = ProgressReportThread.getCachedReport(999);
        assertNotNull(cachedReport);
    }
}
