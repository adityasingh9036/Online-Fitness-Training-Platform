package com.fittrack.dao;

import com.fittrack.exception.DatabaseException;
import com.fittrack.model.Exercise;
import com.fittrack.model.UserWorkoutPlan;
import com.fittrack.model.WorkoutPlan;
import com.fittrack.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Data Access Object for Workout Plans, Plan-Exercise associations, and User enrollments.
 */
public class WorkoutPlanDAO implements GenericDAO<WorkoutPlan, Integer> {

    private final ExerciseDAO exerciseDAO = new ExerciseDAO();

    @Override
    public WorkoutPlan findById(Integer id) {
        String sql = "SELECT wp.id, wp.trainer_id, u.name AS trainer_name, wp.title, " +
                     "wp.description, wp.difficulty, wp.duration, wp.status, wp.created_at " +
                     "FROM workout_plans wp " +
                     "JOIN users u ON wp.trainer_id = u.id " +
                     "WHERE wp.id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    WorkoutPlan plan = mapRowToPlan(rs);
                    plan.setExercises(exerciseDAO.findByPlanId(plan.getId()));
                    return plan;
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Error finding workout plan by ID: " + id, e);
        }
        return null;
    }

    @Override
    public List<WorkoutPlan> findAll() {
        List<WorkoutPlan> list = new ArrayList<>();
        String sql = "SELECT wp.id, wp.trainer_id, u.name AS trainer_name, wp.title, " +
                     "wp.description, wp.difficulty, wp.duration, wp.status, wp.created_at " +
                     "FROM workout_plans wp " +
                     "JOIN users u ON wp.trainer_id = u.id " +
                     "ORDER BY wp.id DESC";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                WorkoutPlan plan = mapRowToPlan(rs);
                plan.setExercises(exerciseDAO.findByPlanId(plan.getId()));
                list.add(plan);
            }
        } catch (SQLException e) {
            throw new DatabaseException("Error fetching all workout plans", e);
        }
        return list;
    }

    public List<WorkoutPlan> findApprovedPlans() {
        return findByStatus("APPROVED");
    }

    public List<WorkoutPlan> findByStatus(String status) {
        List<WorkoutPlan> list = new ArrayList<>();
        String sql = "SELECT wp.id, wp.trainer_id, u.name AS trainer_name, wp.title, " +
                     "wp.description, wp.difficulty, wp.duration, wp.status, wp.created_at " +
                     "FROM workout_plans wp " +
                     "JOIN users u ON wp.trainer_id = u.id " +
                     "WHERE wp.status = ? " +
                     "ORDER BY wp.id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status.toUpperCase());
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    WorkoutPlan plan = mapRowToPlan(rs);
                    plan.setExercises(exerciseDAO.findByPlanId(plan.getId()));
                    list.add(plan);
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Error fetching plans by status: " + status, e);
        }
        return list;
    }

    public List<WorkoutPlan> findByTrainerId(int trainerId) {
        List<WorkoutPlan> list = new ArrayList<>();
        String sql = "SELECT wp.id, wp.trainer_id, u.name AS trainer_name, wp.title, " +
                     "wp.description, wp.difficulty, wp.duration, wp.status, wp.created_at " +
                     "FROM workout_plans wp " +
                     "JOIN users u ON wp.trainer_id = u.id " +
                     "WHERE wp.trainer_id = ? " +
                     "ORDER BY wp.id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, trainerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    WorkoutPlan plan = mapRowToPlan(rs);
                    plan.setExercises(exerciseDAO.findByPlanId(plan.getId()));
                    list.add(plan);
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Error fetching plans for trainer ID: " + trainerId, e);
        }
        return list;
    }

    @Override
    public boolean save(WorkoutPlan plan) {
        String sql = "INSERT INTO workout_plans (trainer_id, title, description, difficulty, duration, status) " +
                     "VALUES (?, ?, ?, ?, ?, ?) RETURNING id, created_at";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, plan.getTrainerId());
            ps.setString(2, plan.getTitle());
            ps.setString(3, plan.getDescription());
            ps.setString(4, plan.getDifficulty());
            ps.setInt(5, plan.getDuration());
            ps.setString(6, plan.getStatus() != null ? plan.getStatus().toUpperCase() : "PENDING");
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    plan.setId(rs.getInt("id"));
                    plan.setCreatedAt(rs.getTimestamp("created_at"));
                    return true;
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Error saving workout plan: " + plan.getTitle(), e);
        }
        return false;
    }

    @Override
    public boolean update(WorkoutPlan plan) {
        String sql = "UPDATE workout_plans SET title = ?, description = ?, difficulty = ?, duration = ?, status = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, plan.getTitle());
            ps.setString(2, plan.getDescription());
            ps.setString(3, plan.getDifficulty());
            ps.setInt(4, plan.getDuration());
            ps.setString(5, plan.getStatus());
            ps.setInt(6, plan.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new DatabaseException("Error updating workout plan ID: " + plan.getId(), e);
        }
    }

    public boolean updateStatus(int planId, String status) {
        String sql = "UPDATE workout_plans SET status = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status.toUpperCase());
            ps.setInt(2, planId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new DatabaseException("Error updating status for plan ID: " + planId, e);
        }
    }

    @Override
    public boolean delete(Integer id) {
        String sql = "DELETE FROM workout_plans WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new DatabaseException("Error deleting workout plan ID: " + id, e);
        }
    }

    public boolean addExerciseToPlan(int planId, int exerciseId) {
        String sql = "INSERT INTO plan_exercises (plan_id, exercise_id) VALUES (?, ?) ON CONFLICT DO NOTHING";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, planId);
            ps.setInt(2, exerciseId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new DatabaseException("Error linking exercise ID: " + exerciseId + " to plan ID: " + planId, e);
        }
    }

    public boolean removeExerciseFromPlan(int planId, int exerciseId) {
        String sql = "DELETE FROM plan_exercises WHERE plan_id = ? AND exercise_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, planId);
            ps.setInt(2, exerciseId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new DatabaseException("Error unlinking exercise ID: " + exerciseId + " from plan ID: " + planId, e);
        }
    }

    public int countTotalPlans() {
        String sql = "SELECT COUNT(*) FROM workout_plans";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            throw new DatabaseException("Error counting workout plans", e);
        }
        return 0;
    }

    public int countPendingPlans() {
        String sql = "SELECT COUNT(*) FROM workout_plans WHERE status = 'PENDING'";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            throw new DatabaseException("Error counting pending plans", e);
        }
        return 0;
    }

    // User Enrollment in Workout Plans
    public boolean enrollUserInPlan(int userId, int planId) {
        // First set any currently ACTIVE plan to DROPPED or COMPLETED
        String updateOldSql = "UPDATE user_workout_plans SET status = 'DROPPED' WHERE user_id = ? AND status = 'ACTIVE'";
        String insertSql = "INSERT INTO user_workout_plans (user_id, plan_id, status) VALUES (?, ?, 'ACTIVE') " +
                           "ON CONFLICT (user_id, plan_id) DO UPDATE SET status = 'ACTIVE', enrolled_at = CURRENT_TIMESTAMP";
        try (Connection conn = DBConnection.getConnection()) {
            try (PreparedStatement psUpdate = conn.prepareStatement(updateOldSql)) {
                psUpdate.setInt(1, userId);
                psUpdate.executeUpdate();
            }
            try (PreparedStatement psInsert = conn.prepareStatement(insertSql)) {
                psInsert.setInt(1, userId);
                psInsert.setInt(2, planId);
                return psInsert.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            throw new DatabaseException("Error enrolling user " + userId + " in plan " + planId, e);
        }
    }

    public List<UserWorkoutPlan> getUserEnrolledPlans(int userId) {
        List<UserWorkoutPlan> list = new ArrayList<>();
        String sql = "SELECT uwp.id, uwp.user_id, uwp.plan_id, wp.title, wp.difficulty, " +
                     "wp.duration, u.name AS trainer_name, uwp.status, uwp.enrolled_at " +
                     "FROM user_workout_plans uwp " +
                     "JOIN workout_plans wp ON uwp.plan_id = wp.id " +
                     "JOIN users u ON wp.trainer_id = u.id " +
                     "WHERE uwp.user_id = ? ORDER BY uwp.enrolled_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new UserWorkoutPlan(
                            rs.getInt("id"),
                            rs.getInt("user_id"),
                            rs.getInt("plan_id"),
                            rs.getString("title"),
                            rs.getString("difficulty"),
                            rs.getInt("duration"),
                            rs.getString("trainer_name"),
                            rs.getString("status"),
                            rs.getTimestamp("enrolled_at")
                    ));
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Error fetching enrolled plans for user ID: " + userId, e);
        }
        return list;
    }

    public UserWorkoutPlan getUserActivePlan(int userId) {
        String sql = "SELECT uwp.id, uwp.user_id, uwp.plan_id, wp.title, wp.difficulty, " +
                     "wp.duration, u.name AS trainer_name, uwp.status, uwp.enrolled_at " +
                     "FROM user_workout_plans uwp " +
                     "JOIN workout_plans wp ON uwp.plan_id = wp.id " +
                     "JOIN users u ON wp.trainer_id = u.id " +
                     "WHERE uwp.user_id = ? AND uwp.status = 'ACTIVE' LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new UserWorkoutPlan(
                            rs.getInt("id"),
                            rs.getInt("user_id"),
                            rs.getInt("plan_id"),
                            rs.getString("title"),
                            rs.getString("difficulty"),
                            rs.getInt("duration"),
                            rs.getString("trainer_name"),
                            rs.getString("status"),
                            rs.getTimestamp("enrolled_at")
                    );
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Error fetching active plan for user: " + userId, e);
        }
        return null;
    }

    public boolean completePlan(int userId, int planId) {
        String sql = "UPDATE user_workout_plans SET status = 'COMPLETED' WHERE user_id = ? AND plan_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, planId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new DatabaseException("Error completing plan for user: " + userId, e);
        }
    }

    // --- Member Exercise Tracking & Weekly Progress ---

    public boolean markExerciseCompleted(int userId, int planId, int exerciseId) {
        String sql = "INSERT INTO user_exercise_completions (user_id, plan_id, exercise_id, completed_date) " +
                     "VALUES (?, ?, ?, CURRENT_DATE) " +
                     "ON CONFLICT (user_id, plan_id, exercise_id, completed_date) DO NOTHING";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, planId);
            ps.setInt(3, exerciseId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new DatabaseException("Error recording exercise completion for user " + userId, e);
        }
    }

    public boolean unmarkExerciseCompleted(int userId, int planId, int exerciseId) {
        String sql = "DELETE FROM user_exercise_completions " +
                     "WHERE user_id = ? AND plan_id = ? AND exercise_id = ? AND completed_date = CURRENT_DATE";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, planId);
            ps.setInt(3, exerciseId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new DatabaseException("Error removing exercise completion for user " + userId, e);
        }
    }

    public Set<Integer> getCompletedExerciseIdsToday(int userId, int planId) {
        Set<Integer> completed = new HashSet<>();
        String sql = "SELECT exercise_id FROM user_exercise_completions " +
                     "WHERE user_id = ? AND plan_id = ? AND completed_date = CURRENT_DATE";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, planId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    completed.add(rs.getInt("exercise_id"));
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Error fetching today's completed exercises", e);
        }
        return completed;
    }

    public int getWeeklyCompletedCount(int userId, int planId) {
        String sql = "SELECT COUNT(DISTINCT exercise_id) FROM user_exercise_completions " +
                     "WHERE user_id = ? AND plan_id = ? AND completed_date >= CURRENT_DATE - INTERVAL '7 days'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, planId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            throw new DatabaseException("Error counting weekly completed exercises", e);
        }
        return 0;
    }

    public Map<String, Object> getWeeklyProgress(int userId, int planId) {
        Map<String, Object> progress = new HashMap<>();
        List<Exercise> exercises = exerciseDAO.findByPlanId(planId);
        int totalExercises = exercises != null ? exercises.size() : 0;
        int completedWeekly = getWeeklyCompletedCount(userId, planId);
        int percentage = totalExercises > 0 ? Math.min(100, (int) Math.round(((double) completedWeekly / totalExercises) * 100)) : 0;
        Set<Integer> completedToday = getCompletedExerciseIdsToday(userId, planId);

        progress.put("totalExercises", totalExercises);
        progress.put("completedWeekly", completedWeekly);
        progress.put("percentage", percentage);
        progress.put("completedTodaySet", completedToday);
        progress.put("completedTodayCount", completedToday.size());
        return progress;
    }

    // --- Trainer Member Assignments ---

    public List<UserWorkoutPlan> getEnrolledMembersForTrainer(int trainerId) {
        List<UserWorkoutPlan> list = new ArrayList<>();
        String sql = "SELECT uwp.id, uwp.user_id, u.name AS user_name, u.email AS user_email, " +
                     "uwp.plan_id, wp.title, wp.difficulty, wp.duration, uwp.status, uwp.enrolled_at " +
                     "FROM user_workout_plans uwp " +
                     "JOIN workout_plans wp ON uwp.plan_id = wp.id " +
                     "JOIN users u ON uwp.user_id = u.id " +
                     "WHERE wp.trainer_id = ? " +
                     "ORDER BY uwp.enrolled_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, trainerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    UserWorkoutPlan uwp = new UserWorkoutPlan(
                            rs.getInt("id"),
                            rs.getInt("user_id"),
                            rs.getInt("plan_id"),
                            rs.getString("title"),
                            rs.getString("difficulty"),
                            rs.getInt("duration"),
                            "",
                            rs.getString("status"),
                            rs.getTimestamp("enrolled_at")
                    );
                    uwp.setUserName(rs.getString("user_name"));
                    uwp.setUserEmail(rs.getString("user_email"));
                    list.add(uwp);
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Error fetching enrolled members for trainer ID: " + trainerId, e);
        }
        return list;
    }

    private WorkoutPlan mapRowToPlan(ResultSet rs) throws SQLException {
        WorkoutPlan plan = new WorkoutPlan(
                rs.getInt("id"),
                rs.getInt("trainer_id"),
                rs.getString("title"),
                rs.getString("description"),
                rs.getString("difficulty"),
                rs.getInt("duration"),
                rs.getString("status"),
                rs.getTimestamp("created_at")
        );
        plan.setTrainerName(rs.getString("trainer_name"));
        return plan;
    }
}
