package com.fittrack;

import com.fittrack.dao.NotificationDAO;
import com.fittrack.dao.ProgressDAO;
import com.fittrack.exception.ValidationException;
import com.fittrack.model.*;
import com.fittrack.service.NotificationService;
import com.fittrack.service.ProgressService;
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

        // Verify valid hash matching
        assertTrue(PasswordUtil.verifyPassword(raw, hashed));
        assertFalse(PasswordUtil.verifyPassword("wrongPassword", hashed));

        // Verify insecure plaintext password fallback is removed:
        // A raw password passed as the stored hash must NEVER be accepted as valid
        assertFalse(PasswordUtil.verifyPassword(raw, raw), "Plaintext password must not be authenticated directly");
        assertFalse(PasswordUtil.verifyPassword("", hashed), "Empty candidate password must be rejected");
        assertFalse(PasswordUtil.verifyPassword(null, hashed), "Null candidate password must be rejected");
        assertFalse(PasswordUtil.verifyPassword(raw, null), "Null stored hash must be rejected");
    }

    @Test
    public void testPublicRegistrationRoleSecurity() {
        // Supported roles for public registration
        assertDoesNotThrow(() -> ValidationUtil.validatePublicRegistrationRole("USER"));
        assertDoesNotThrow(() -> ValidationUtil.validatePublicRegistrationRole("TRAINER"));
        assertDoesNotThrow(() -> ValidationUtil.validatePublicRegistrationRole("user"));
        assertDoesNotThrow(() -> ValidationUtil.validatePublicRegistrationRole("trainer"));

        // Privilege escalation attempts and disallowed roles must be strictly rejected
        assertThrows(ValidationException.class, () -> ValidationUtil.validatePublicRegistrationRole("ADMIN"));
        assertThrows(ValidationException.class, () -> ValidationUtil.validatePublicRegistrationRole("admin"));
        assertThrows(ValidationException.class, () -> ValidationUtil.validatePublicRegistrationRole("SUPERADMIN"));
        assertThrows(ValidationException.class, () -> ValidationUtil.validatePublicRegistrationRole("ROOT"));
        assertThrows(ValidationException.class, () -> ValidationUtil.validatePublicRegistrationRole("HACKER"));
        assertThrows(ValidationException.class, () -> ValidationUtil.validatePublicRegistrationRole(""));
        assertThrows(ValidationException.class, () -> ValidationUtil.validatePublicRegistrationRole(null));
    }

    @Test
    public void testProgressRecordOwnershipEnforcement() {
        // Mock ProgressDAO tracking records and owners to verify IDOR protection
        ProgressDAO mockDao = new ProgressDAO() {
            private final java.util.Map<Integer, Integer> recordOwners = new java.util.HashMap<>() {{
                put(101, 10); // Record #101 belongs to User #10
                put(102, 20); // Record #102 belongs to User #20
            }};

            @Override
            public boolean deleteByIdAndUserId(int id, int userId) {
                Integer owner = recordOwners.get(id);
                if (owner != null && owner == userId) {
                    recordOwners.remove(id);
                    return true;
                }
                return false;
            }
        };

        ProgressService service = new ProgressService(mockDao);

        // User #10 deleting their own record #101 -> Should SUCCEED
        assertTrue(service.deleteProgress(101, 10), "Owner must be allowed to delete their own record");

        // User #10 attempting IDOR exploit to delete User #20's record #102 -> Must FAIL
        assertFalse(service.deleteProgress(102, 10), "User must NOT be allowed to delete another user's record");

        // Non-existent record #999 -> Should return false
        assertFalse(service.deleteProgress(999, 10), "Non-existent record deletion must return false");
    }

    @Test
    public void testNotificationOwnershipEnforcement() {
        // Track notifications with user ID and read status to verify IDOR protection
        class NotificationEntry {
            final int userId;
            boolean isRead;
            NotificationEntry(int userId, boolean isRead) {
                this.userId = userId;
                this.isRead = isRead;
            }
        }

        NotificationDAO mockDao = new NotificationDAO() {
            private final java.util.Map<Integer, NotificationEntry> notifs = new java.util.HashMap<>() {{
                put(501, new NotificationEntry(10, false)); // Notification #501 belongs to User #10
                put(502, new NotificationEntry(20, false)); // Notification #502 belongs to User #20
            }};

            @Override
            public boolean markAsRead(int notificationId, int userId) {
                NotificationEntry entry = notifs.get(notificationId);
                if (entry != null && entry.userId == userId) {
                    entry.isRead = true;
                    return true;
                }
                return false;
            }

            @Override
            public boolean markAllAsRead(int userId) {
                boolean updated = false;
                for (NotificationEntry entry : notifs.values()) {
                    if (entry.userId == userId && !entry.isRead) {
                        entry.isRead = true;
                        updated = true;
                    }
                }
                return updated;
            }
        };

        NotificationService service = new NotificationService(mockDao);

        // 1. User #10 marks their own notification #501 as read -> Should SUCCEED
        assertTrue(service.markAsRead(501, 10), "Owner must be allowed to mark their own notification as read");

        // 2. User #10 attempts IDOR exploit by tampering with notification ID to #502 (belongs to User #20) -> Must FAIL
        assertFalse(service.markAsRead(502, 10), "User must NOT be allowed to modify another user's notification");

        // 3. Mark non-existent notification #999 -> Must return false
        assertFalse(service.markAsRead(999, 10), "Non-existent notification must return false");

        // 4. User #20 marks all their notifications as read -> Should only mark User #20's notifications
        assertTrue(service.markAllAsRead(20), "User #20 must be able to mark all their notifications as read");
    }

    @Test
    public void testNotificationAuthFilterConfiguration() {
        jakarta.servlet.annotation.WebFilter filterAnnotation = 
                com.fittrack.servlet.AuthFilter.class.getAnnotation(jakarta.servlet.annotation.WebFilter.class);
        assertNotNull(filterAnnotation, "AuthFilter must be annotated with @WebFilter");
        String[] patterns = filterAnnotation.urlPatterns();
        assertNotNull(patterns);
        boolean protectsNotifications = false;
        for (String pattern : patterns) {
            if ("/notifications/*".equals(pattern)) {
                protectsNotifications = true;
                break;
            }
        }
        assertTrue(protectsNotifications, "AuthFilter must protect /notifications/* to require authentication");
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

    @Test
    public void testDatabaseConfigurationFallback() {
        // Verify default pooler host and username
        assertTrue(com.fittrack.util.DBConnection.getDbUrl().contains("aws-0-ap-south-1.pooler.supabase.com"),
                "DB URL must point to Supabase IPv4 Session Pooler by default");
        assertEquals("postgres.kclihlnwczjifrmakfsp", com.fittrack.util.DBConnection.getDbUser(),
                "DB User must be postgres.kclihlnwczjifrmakfsp by default");

        // Verify that getConnection cleanly rejects unconfigured password without throwing null pointer
        if (!com.fittrack.util.DBConnection.isPasswordConfigured()) {
            com.fittrack.exception.DatabaseException ex = assertThrows(
                    com.fittrack.exception.DatabaseException.class,
                    com.fittrack.util.DBConnection::getConnection
            );
            assertTrue(ex.getMessage().contains("password is not configured"),
                    "Exception message must guide user to configure DB_PASSWORD");
        }
    }

    @Test
    public void testExerciseRestTimeAndFormatting() {
        Exercise e1 = new Exercise(1, "Barbell Bench Press", "Flat bench", "Chest", 4, 8, 90);
        assertEquals("1m 30s rest", e1.getRestTimeFormatted());
        assertEquals("4 sets × 8 reps (1m 30s rest)", e1.getSummary());
        assertFalse(e1.isCompletedToday());
        e1.setCompletedToday(true);
        assertTrue(e1.isCompletedToday());

        Exercise e2 = new Exercise(2, "Push Ups", "Bodyweight", "Chest", 3, 15, 45);
        assertEquals("45s rest", e2.getRestTimeFormatted());

        Exercise e3 = new Exercise(3, "Plank", "Isometric hold", "Core", 3, 1, 0);
        assertEquals("No Rest / Continuous", e3.getRestTimeFormatted());

        Exercise e4 = new Exercise(4, "Squats", "Leg volume", "Legs", 5, 5, 120);
        assertEquals("2m rest", e4.getRestTimeFormatted());
    }

    @Test
    public void testWorkoutPlanGoalCategorization() {
        WorkoutPlan p1 = new WorkoutPlan(1, 2, "Hypertrophy Muscle Builder", "Build lean muscle mass and volume", "INTERMEDIATE", 8, "APPROVED", null);
        assertEquals("Muscle Gain", p1.getGoalType());
        assertTrue(p1.matchesGoal("Muscle Gain"));
        assertTrue(p1.matchesGoal("muscle"));
        assertEquals("badge-primary", p1.getGoalBadgeClass());

        WorkoutPlan p2 = new WorkoutPlan(2, 2, "Fat Loss & High Conditioning", "Cardio burn and metabolic cut", "BEGINNER", 6, "APPROVED", null);
        assertEquals("Weight Loss & Conditioning", p2.getGoalType());
        assertTrue(p2.matchesGoal("Weight Loss"));
        assertTrue(p2.matchesGoal("fat loss"));
        assertEquals("badge-warning", p2.getGoalBadgeClass());

        WorkoutPlan p3 = new WorkoutPlan(3, 2, "Pure Strength & Powerlifting", "Heavy compound power progression", "ADVANCED", 12, "APPROVED", null);
        assertEquals("Strength & Power", p3.getGoalType());
        assertTrue(p3.matchesGoal("Strength"));
        assertEquals("badge-danger", p3.getGoalBadgeClass());

        WorkoutPlan p4 = new WorkoutPlan(4, 2, "Daily Mobility", "General health routines", "BEGINNER", 4, "APPROVED", null);
        assertEquals("General Fitness", p4.getGoalType());
        assertEquals("badge-secondary", p4.getGoalBadgeClass());
    }

    @Test
    public void testTrainerPlanAssignmentAndAdherence() throws Exception {
        // Mock WorkoutPlanDAO to verify trainer assignment and progress calculation
        final java.util.Map<Integer, UserWorkoutPlan> assignments = new java.util.HashMap<>();

        com.fittrack.dao.WorkoutPlanDAO mockPlanDao = new com.fittrack.dao.WorkoutPlanDAO() {
            @Override
            public WorkoutPlan findById(Integer id) {
                if (id == 100) {
                    WorkoutPlan p = new WorkoutPlan(100, 5, "Coach Marcus Strength", "Strength routine", "INTERMEDIATE", 6, "APPROVED", null);
                    return p;
                }
                return null;
            }

            @Override
            public boolean enrollUserInPlan(int userId, int planId) {
                UserWorkoutPlan uwp = new UserWorkoutPlan(1, userId, planId, "Coach Marcus Strength", "INTERMEDIATE", 6, "Coach Marcus", "ACTIVE", null);
                assignments.put(userId, uwp);
                return true;
            }
        };

        com.fittrack.dao.ExerciseDAO mockExerciseDao = new com.fittrack.dao.ExerciseDAO();
        com.fittrack.dao.NotificationDAO mockNotifDao = new com.fittrack.dao.NotificationDAO() {
            @Override
            public boolean save(Notification notification) {
                return true;
            }
        };

        com.fittrack.service.WorkoutService service = new com.fittrack.service.WorkoutService(mockPlanDao, mockExerciseDao, mockNotifDao);

        // Assign plan 100 to member 42 by trainer 5 -> Should succeed
        boolean assigned = service.assignPlanToMember(5, 42, 100);
        assertTrue(assigned, "Trainer must be able to assign their plan to a member");
        assertTrue(assignments.containsKey(42), "Member must be enrolled in the plan");
        assertEquals("Coach Marcus Strength", assignments.get(42).getPlanTitle());

        // Assignment of non-existent plan -> Throws ValidationException
        assertThrows(ValidationException.class, () -> service.assignPlanToMember(5, 42, 999));

        // Invalid member ID or plan ID -> Throws ValidationException
        assertThrows(ValidationException.class, () -> service.assignPlanToMember(5, -1, 100));
        assertThrows(ValidationException.class, () -> service.assignPlanToMember(-1, 42, 100));
    }
}
