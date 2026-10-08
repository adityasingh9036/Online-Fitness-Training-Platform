package com.fittrack.model;

import java.sql.Timestamp;

/**
 * Concrete FitnessUser (Member/Client) representation.
 * Overrides User methods with User-specific permissions and navigation.
 */
public class FitnessUser extends User {

    private static final long serialVersionUID = 1L;
    private double currentWeight;
    private double height;
    private String primaryGoal = "General Wellness";

    public FitnessUser() {
        super();
        setRole("USER");
    }

    public FitnessUser(int id, String name, String email, String password, Timestamp createdAt) {
        super(id, name, email, password, "USER", createdAt);
    }

    public double getCurrentWeight() {
        return currentWeight;
    }

    public void setCurrentWeight(double currentWeight) {
        this.currentWeight = currentWeight;
    }

    public double getHeight() {
        return height;
    }

    public void setHeight(double height) {
        this.height = height;
    }

    public String getPrimaryGoal() {
        return primaryGoal;
    }

    public void setPrimaryGoal(String primaryGoal) {
        this.primaryGoal = primaryGoal;
    }

    @Override
    public String getRoleTitle() {
        return "Fitness Member";
    }

    @Override
    public String getPermissionsOverview() {
        return "Explore approved workouts, log weekly progress, and message personal trainers.";
    }

    @Override
    public String getDashboardUrl() {
        return "user/dashboard";
    }

    @Override
    public String getRoleBadgeColor() {
        return "badge-success";
    }

    @Override
    public String getRoleDescription() {
        return "Fitness Trainee / Member";
    }
}
