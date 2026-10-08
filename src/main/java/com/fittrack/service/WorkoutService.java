package com.fittrack.service;

import com.fittrack.dao.ExerciseDAO;
import com.fittrack.dao.NotificationDAO;
import com.fittrack.dao.WorkoutPlanDAO;
import com.fittrack.exception.ValidationException;
import com.fittrack.model.Exercise;
import com.fittrack.model.Notification;
import com.fittrack.model.UserWorkoutPlan;
import com.fittrack.model.WorkoutPlan;
import com.fittrack.util.ValidationUtil;

import java.util.List;

/**
 * Service managing workout plans, exercises, approvals, and member enrollments.
 */
public class WorkoutService {

    private final WorkoutPlanDAO workoutPlanDAO;
    private final ExerciseDAO exerciseDAO;
    private final NotificationDAO notificationDAO;

    public WorkoutService() {
        this.workoutPlanDAO = new WorkoutPlanDAO();
        this.exerciseDAO = new ExerciseDAO();
        this.notificationDAO = new NotificationDAO();
    }

    public WorkoutService(WorkoutPlanDAO workoutPlanDAO, ExerciseDAO exerciseDAO, NotificationDAO notificationDAO) {
        this.workoutPlanDAO = workoutPlanDAO;
        this.exerciseDAO = exerciseDAO;
        this.notificationDAO = notificationDAO;
    }

    public WorkoutPlan createPlan(int trainerId, String title, String description,
                                  String difficulty, int durationWeeks, List<Integer> exerciseIds) 
            throws ValidationException {
        ValidationUtil.validateNotEmpty(title, "Plan Title");
        ValidationUtil.validateNotEmpty(description, "Plan Description");
        ValidationUtil.validateNotEmpty(difficulty, "Difficulty");
        ValidationUtil.validatePositiveNumber(durationWeeks, "Duration");

        WorkoutPlan plan = new WorkoutPlan();
        plan.setTrainerId(trainerId);
        plan.setTitle(title.trim());
        plan.setDescription(description.trim());
        plan.setDifficulty(difficulty.trim().toUpperCase());
        plan.setDuration(durationWeeks);
        plan.setStatus("PENDING"); // Requires admin approval

        boolean saved = workoutPlanDAO.save(plan);
        if (saved && exerciseIds != null) {
            for (Integer exId : exerciseIds) {
                if (exId != null && exId > 0) {
                    workoutPlanDAO.addExerciseToPlan(plan.getId(), exId);
                }
            }
        }
        return plan;
    }

    public WorkoutPlan getPlanById(int id) {
        return workoutPlanDAO.findById(id);
    }

    public List<WorkoutPlan> getAllPlans() {
        return workoutPlanDAO.findAll();
    }

    public List<WorkoutPlan> getApprovedPlans() {
        return workoutPlanDAO.findApprovedPlans();
    }

    public List<WorkoutPlan> getPlansByTrainer(int trainerId) {
        return workoutPlanDAO.findByTrainerId(trainerId);
    }

    public List<WorkoutPlan> getPendingPlans() {
        return workoutPlanDAO.findByStatus("PENDING");
    }

    public boolean approvePlan(int planId) {
        WorkoutPlan plan = workoutPlanDAO.findById(planId);
        boolean updated = workoutPlanDAO.updateStatus(planId, "APPROVED");
        if (updated && plan != null) {
            notificationDAO.save(new Notification(
                    0,
                    plan.getTrainerId(),
                    "Congratulations! Your workout plan \"" + plan.getTitle() + "\" has been APPROVED by the Admin.",
                    false,
                    null
            ));
        }
        return updated;
    }

    public boolean rejectPlan(int planId) {
        WorkoutPlan plan = workoutPlanDAO.findById(planId);
        boolean updated = workoutPlanDAO.updateStatus(planId, "REJECTED");
        if (updated && plan != null) {
            notificationDAO.save(new Notification(
                    0,
                    plan.getTrainerId(),
                    "Notice: Your workout plan \"" + plan.getTitle() + "\" was REJECTED by the Admin. Please review guidelines.",
                    false,
                    null
            ));
        }
        return updated;
    }

    public boolean deletePlan(int planId) {
        return workoutPlanDAO.delete(planId);
    }

    public boolean enrollUserInPlan(int userId, int planId) {
        WorkoutPlan plan = workoutPlanDAO.findById(planId);
        boolean enrolled = workoutPlanDAO.enrollUserInPlan(userId, planId);
        if (enrolled && plan != null) {
            notificationDAO.save(new Notification(
                    0,
                    userId,
                    "You have successfully enrolled in workout plan: " + plan.getTitle(),
                    false,
                    null
            ));
        }
        return enrolled;
    }

    public List<UserWorkoutPlan> getUserEnrolledPlans(int userId) {
        return workoutPlanDAO.getUserEnrolledPlans(userId);
    }

    public UserWorkoutPlan getUserActivePlan(int userId) {
        return workoutPlanDAO.getUserActivePlan(userId);
    }

    public boolean completePlan(int userId, int planId) {
        return workoutPlanDAO.completePlan(userId, planId);
    }

    public List<Exercise> getAllExercises() {
        return exerciseDAO.findAll();
    }

    public Exercise createExercise(String name, String description, String muscleGroup,
                                   int sets, int reps, int duration) throws ValidationException {
        ValidationUtil.validateNotEmpty(name, "Exercise Name");
        ValidationUtil.validateNotEmpty(muscleGroup, "Muscle Group");
        ValidationUtil.validatePositiveNumber(sets, "Sets");
        ValidationUtil.validatePositiveNumber(reps, "Reps");

        Exercise ex = new Exercise(0, name.trim(), description, muscleGroup.trim(), sets, reps, duration);
        exerciseDAO.save(ex);
        return ex;
    }
}
