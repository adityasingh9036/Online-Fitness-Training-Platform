package com.fittrack.dao;

import com.fittrack.exception.DatabaseException;
import com.fittrack.model.Progress;
import com.fittrack.util.DBConnection;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for User Fitness Progress Tracking.
 */
public class ProgressDAO implements GenericDAO<Progress, Integer> {

    @Override
    public Progress findById(Integer id) {
        String sql = "SELECT p.id, p.user_id, u.name AS user_name, p.weight, p.height, " +
                     "p.body_measurement, p.fitness_goal, p.record_date " +
                     "FROM progress p " +
                     "JOIN users u ON p.user_id = u.id " +
                     "WHERE p.id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToProgress(rs);
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Error finding progress by ID: " + id, e);
        }
        return null;
    }

    @Override
    public List<Progress> findAll() {
        List<Progress> list = new ArrayList<>();
        String sql = "SELECT p.id, p.user_id, u.name AS user_name, p.weight, p.height, " +
                     "p.body_measurement, p.fitness_goal, p.record_date " +
                     "FROM progress p " +
                     "JOIN users u ON p.user_id = u.id " +
                     "ORDER BY p.record_date DESC";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                list.add(mapRowToProgress(rs));
            }
        } catch (SQLException e) {
            throw new DatabaseException("Error fetching all progress logs", e);
        }
        return list;
    }

    public List<Progress> findByUserId(int userId) {
        List<Progress> list = new ArrayList<>();
        String sql = "SELECT p.id, p.user_id, u.name AS user_name, p.weight, p.height, " +
                     "p.body_measurement, p.fitness_goal, p.record_date " +
                     "FROM progress p " +
                     "JOIN users u ON p.user_id = u.id " +
                     "WHERE p.user_id = ? " +
                     "ORDER BY p.record_date DESC, p.id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToProgress(rs));
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Error fetching progress for user ID: " + userId, e);
        }

        // Calculate delta differences between consecutive records
        for (int i = 0; i < list.size(); i++) {
            if (i < list.size() - 1) {
                double diff = list.get(i).getWeight() - list.get(i + 1).getWeight();
                list.get(i).setWeightChange(Math.round(diff * 10.0) / 10.0);
            } else {
                list.get(i).setWeightChange(0.0);
            }
        }
        return list;
    }

    public Progress findLatestByUserId(int userId) {
        String sql = "SELECT p.id, p.user_id, u.name AS user_name, p.weight, p.height, " +
                     "p.body_measurement, p.fitness_goal, p.record_date " +
                     "FROM progress p " +
                     "JOIN users u ON p.user_id = u.id " +
                     "WHERE p.user_id = ? " +
                     "ORDER BY p.record_date DESC, p.id DESC LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToProgress(rs);
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Error fetching latest progress for user ID: " + userId, e);
        }
        return null;
    }

    @Override
    public boolean save(Progress p) {
        String sql = "INSERT INTO progress (user_id, weight, height, body_measurement, fitness_goal, record_date) " +
                     "VALUES (?, ?, ?, ?, ?, ?) RETURNING id";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, p.getUserId());
            ps.setDouble(2, p.getWeight());
            ps.setDouble(3, p.getHeight());
            ps.setString(4, p.getBodyMeasurement());
            ps.setString(5, p.getFitnessGoal());
            ps.setDate(6, p.getRecordDate() != null ? p.getRecordDate() : new Date(System.currentTimeMillis()));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    p.setId(rs.getInt("id"));
                    return true;
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Error saving progress entry", e);
        }
        return false;
    }

    @Override
    public boolean update(Progress p) {
        String sql = "UPDATE progress SET weight = ?, height = ?, body_measurement = ?, fitness_goal = ?, record_date = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDouble(1, p.getWeight());
            ps.setDouble(2, p.getHeight());
            ps.setString(3, p.getBodyMeasurement());
            ps.setString(4, p.getFitnessGoal());
            ps.setDate(5, p.getRecordDate());
            ps.setInt(6, p.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new DatabaseException("Error updating progress entry ID: " + p.getId(), e);
        }
    }

    @Override
    public boolean delete(Integer id) {
        String sql = "DELETE FROM progress WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new DatabaseException("Error deleting progress entry ID: " + id, e);
        }
    }

    /**
     * Securely deletes a progress entry ensuring record ownership.
     * Prevents Insecure Direct Object Reference (IDOR) by requiring matching user_id in the SQL DELETE query.
     *
     * @param id     Progress record ID
     * @param userId ID of the authenticated user attempting deletion
     * @return true if a record matching both id and user_id was deleted, false otherwise
     */
    public boolean deleteByIdAndUserId(int id, int userId) {
        String sql = "DELETE FROM progress WHERE id = ? AND user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new DatabaseException("Error deleting progress entry ID: " + id + " for user ID: " + userId, e);
        }
    }

    public boolean delete(int id, int userId) {
        return deleteByIdAndUserId(id, userId);
    }

    private Progress mapRowToProgress(ResultSet rs) throws SQLException {
        Progress p = new Progress(
                rs.getInt("id"),
                rs.getInt("user_id"),
                rs.getDouble("weight"),
                rs.getDouble("height"),
                rs.getString("body_measurement"),
                rs.getString("fitness_goal"),
                rs.getDate("record_date")
        );
        p.setUserName(rs.getString("user_name"));
        return p;
    }
}
