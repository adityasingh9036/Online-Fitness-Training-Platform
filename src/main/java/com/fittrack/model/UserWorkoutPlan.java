package com.fittrack.model;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * Model representing a user's enrollment in a workout plan.
 */
public class UserWorkoutPlan implements Serializable {

    private static final long serialVersionUID = 1L;

    private int id;
    private int userId;
    private int planId;
    private String planTitle;
    private String difficulty;
    private int duration;
    private String trainerName;
    private String status; // ACTIVE, COMPLETED, DROPPED
    private Timestamp enrolledAt;

    public UserWorkoutPlan() {
    }

    public UserWorkoutPlan(int id, int userId, int planId, String planTitle,
                           String difficulty, int duration, String trainerName,
                           String status, Timestamp enrolledAt) {
        this.id = id;
        this.userId = userId;
        this.planId = planId;
        this.planTitle = planTitle;
        this.difficulty = difficulty;
        this.duration = duration;
        this.trainerName = trainerName;
        this.status = status;
        this.enrolledAt = enrolledAt;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public int getPlanId() {
        return planId;
    }

    public void setPlanId(int planId) {
        this.planId = planId;
    }

    public String getPlanTitle() {
        return planTitle;
    }

    public void setPlanTitle(String planTitle) {
        this.planTitle = planTitle;
    }

    public String getDifficulty() {
        return difficulty;
    }

    public void setDifficulty(String difficulty) {
        this.difficulty = difficulty;
    }

    public int getDuration() {
        return duration;
    }

    public void setDuration(int duration) {
        this.duration = duration;
    }

    public String getTrainerName() {
        return trainerName;
    }

    public void setTrainerName(String trainerName) {
        this.trainerName = trainerName;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getEnrolledAt() {
        return enrolledAt;
    }

    public void setEnrolledAt(Timestamp enrolledAt) {
        this.enrolledAt = enrolledAt;
    }

    private String userName;
    private String userEmail;
    private int completionPercentage = 0;

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getUserEmail() {
        return userEmail;
    }

    public void setUserEmail(String userEmail) {
        this.userEmail = userEmail;
    }

    public int getCompletionPercentage() {
        return completionPercentage;
    }

    public void setCompletionPercentage(int completionPercentage) {
        this.completionPercentage = completionPercentage;
    }
}
