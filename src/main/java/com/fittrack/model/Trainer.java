package com.fittrack.model;

import java.sql.Timestamp;

/**
 * Concrete Trainer role representation.
 * Overrides User methods with Trainer-specific permissions and navigation.
 */
public class Trainer extends User {

    private static final long serialVersionUID = 1L;
    private String specialization = "General Fitness & Hypertrophy";
    private int activeTraineesCount = 0;

    public Trainer() {
        super();
        setRole("TRAINER");
    }

    public Trainer(int id, String name, String email, String password, Timestamp createdAt) {
        super(id, name, email, password, "TRAINER", createdAt);
    }

    public String getSpecialization() {
        return specialization;
    }

    public void setSpecialization(String specialization) {
        this.specialization = specialization;
    }

    public int getActiveTraineesCount() {
        return activeTraineesCount;
    }

    public void setActiveTraineesCount(int activeTraineesCount) {
        this.activeTraineesCount = activeTraineesCount;
    }

    @Override
    public String getRoleTitle() {
        return "Certified Fitness Trainer";
    }

    @Override
    public String getPermissionsOverview() {
        return "Design workout programs, monitor trainee progress, and provide coaching feedback.";
    }

    @Override
    public String getDashboardUrl() {
        return "trainer/dashboard";
    }

    @Override
    public String getRoleBadgeColor() {
        return "badge-primary";
    }

    @Override
    public String getRoleDescription() {
        return "Fitness Coach & Program Designer";
    }
}
