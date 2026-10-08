package com.fittrack.model;

import java.io.Serializable;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/**
 * Model representing a Workout Plan designed by a Trainer.
 * Contains a collection of associated exercises (Collections & Generics).
 */
public class WorkoutPlan implements Serializable {

    private static final long serialVersionUID = 1L;

    private int id;
    private int trainerId;
    private String trainerName;
    private String title;
    private String description;
    private String difficulty; // BEGINNER, INTERMEDIATE, ADVANCED
    private int duration; // in weeks
    private String status; // PENDING, APPROVED, REJECTED
    private Timestamp createdAt;
    private List<Exercise> exercises = new ArrayList<>();
    private int enrolledUsersCount = 0;

    public WorkoutPlan() {
    }

    public WorkoutPlan(int id, int trainerId, String title, String description,
                       String difficulty, int duration, String status, Timestamp createdAt) {
        this.id = id;
        this.trainerId = trainerId;
        this.title = title;
        this.description = description;
        this.difficulty = difficulty;
        this.duration = duration;
        this.status = status;
        this.createdAt = createdAt;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getTrainerId() {
        return trainerId;
    }

    public void setTrainerId(int trainerId) {
        this.trainerId = trainerId;
    }

    public String getTrainerName() {
        return trainerName;
    }

    public void setTrainerName(String trainerName) {
        this.trainerName = trainerName;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
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

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public List<Exercise> getExercises() {
        return exercises;
    }

    public void setExercises(List<Exercise> exercises) {
        this.exercises = exercises != null ? exercises : new ArrayList<>();
    }

    public void addExercise(Exercise exercise) {
        if (this.exercises == null) {
            this.exercises = new ArrayList<>();
        }
        this.exercises.add(exercise);
    }

    public int getEnrolledUsersCount() {
        return enrolledUsersCount;
    }

    public void setEnrolledUsersCount(int enrolledUsersCount) {
        this.enrolledUsersCount = enrolledUsersCount;
    }

    public boolean isApproved() {
        return "APPROVED".equalsIgnoreCase(this.status);
    }

    public boolean isPending() {
        return "PENDING".equalsIgnoreCase(this.status);
    }

    public String getDifficultyBadgeClass() {
        if ("BEGINNER".equalsIgnoreCase(difficulty)) return "badge-success";
        if ("INTERMEDIATE".equalsIgnoreCase(difficulty)) return "badge-warning";
        return "badge-danger";
    }

    public String getStatusBadgeClass() {
        if ("APPROVED".equalsIgnoreCase(status)) return "badge-success";
        if ("REJECTED".equalsIgnoreCase(status)) return "badge-danger";
        return "badge-warning";
    }
}
