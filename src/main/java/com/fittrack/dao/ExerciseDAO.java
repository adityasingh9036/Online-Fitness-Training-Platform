package com.fittrack.dao;

import com.fittrack.exception.DatabaseException;
import com.fittrack.model.Exercise;
import com.fittrack.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for Exercise items.
 */
public class ExerciseDAO implements GenericDAO<Exercise, Integer> {

    @Override
    public Exercise findById(Integer id) {
        String sql = "SELECT id, name, description, muscle_group, sets, reps, duration FROM exercises WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToExercise(rs);
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Error finding exercise by ID: " + id, e);
        }
        return null;
    }

    @Override
    public List<Exercise> findAll() {
        List<Exercise> list = new ArrayList<>();
        String sql = "SELECT id, name, description, muscle_group, sets, reps, duration FROM exercises ORDER BY name ASC";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                list.add(mapRowToExercise(rs));
            }
        } catch (SQLException e) {
            throw new DatabaseException("Error retrieving all exercises", e);
        }
        return list;
    }

    public List<Exercise> findByMuscleGroup(String muscleGroup) {
        List<Exercise> list = new ArrayList<>();
        String sql = "SELECT id, name, description, muscle_group, sets, reps, duration FROM exercises WHERE LOWER(muscle_group) = LOWER(?) ORDER BY name ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, muscleGroup);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToExercise(rs));
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Error retrieving exercises by muscle group: " + muscleGroup, e);
        }
        return list;
    }

    public List<Exercise> findByPlanId(int planId) {
        List<Exercise> list = new ArrayList<>();
        String sql = "SELECT e.id, e.name, e.description, e.muscle_group, e.sets, e.reps, e.duration " +
                     "FROM exercises e " +
                     "JOIN plan_exercises pe ON e.id = pe.exercise_id " +
                     "WHERE pe.plan_id = ? ORDER BY e.name ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, planId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToExercise(rs));
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Error retrieving exercises for plan ID: " + planId, e);
        }
        return list;
    }

    @Override
    public boolean save(Exercise exercise) {
        String sql = "INSERT INTO exercises (name, description, muscle_group, sets, reps, duration) VALUES (?, ?, ?, ?, ?, ?) RETURNING id";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, exercise.getName());
            ps.setString(2, exercise.getDescription());
            ps.setString(3, exercise.getMuscleGroup());
            ps.setInt(4, exercise.getSets());
            ps.setInt(5, exercise.getReps());
            ps.setInt(6, exercise.getDuration());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    exercise.setId(rs.getInt("id"));
                    return true;
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Error saving exercise: " + exercise.getName(), e);
        }
        return false;
    }

    @Override
    public boolean update(Exercise exercise) {
        String sql = "UPDATE exercises SET name = ?, description = ?, muscle_group = ?, sets = ?, reps = ?, duration = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, exercise.getName());
            ps.setString(2, exercise.getDescription());
            ps.setString(3, exercise.getMuscleGroup());
            ps.setInt(4, exercise.getSets());
            ps.setInt(5, exercise.getReps());
            ps.setInt(6, exercise.getDuration());
            ps.setInt(7, exercise.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new DatabaseException("Error updating exercise ID: " + exercise.getId(), e);
        }
    }

    @Override
    public boolean delete(Integer id) {
        String sql = "DELETE FROM exercises WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new DatabaseException("Error deleting exercise ID: " + id, e);
        }
    }

    private Exercise mapRowToExercise(ResultSet rs) throws SQLException {
        return new Exercise(
                rs.getInt("id"),
                rs.getString("name"),
                rs.getString("description"),
                rs.getString("muscle_group"),
                rs.getInt("sets"),
                rs.getInt("reps"),
                rs.getInt("duration")
        );
    }
}
