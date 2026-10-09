package com.fittrack.dao;

import com.fittrack.exception.DatabaseException;
import com.fittrack.model.Notification;
import com.fittrack.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for Notifications.
 */
public class NotificationDAO implements GenericDAO<Notification, Integer> {

    @Override
    public Notification findById(Integer id) {
        String sql = "SELECT id, user_id, message, is_read, created_at FROM notifications WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToNotification(rs);
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Error finding notification by ID: " + id, e);
        }
        return null;
    }

    @Override
    public List<Notification> findAll() {
        List<Notification> list = new ArrayList<>();
        String sql = "SELECT id, user_id, message, is_read, created_at FROM notifications ORDER BY created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                list.add(mapRowToNotification(rs));
            }
        } catch (SQLException e) {
            throw new DatabaseException("Error retrieving all notifications", e);
        }
        return list;
    }

    public List<Notification> findByUserId(int userId) {
        List<Notification> list = new ArrayList<>();
        String sql = "SELECT id, user_id, message, is_read, created_at FROM notifications WHERE user_id = ? ORDER BY created_at DESC LIMIT 20";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToNotification(rs));
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Error retrieving notifications for user: " + userId, e);
        }
        return list;
    }

    public List<Notification> findUnreadByUserId(int userId) {
        List<Notification> list = new ArrayList<>();
        String sql = "SELECT id, user_id, message, is_read, created_at FROM notifications WHERE user_id = ? AND is_read = FALSE ORDER BY created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToNotification(rs));
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Error retrieving unread notifications for user: " + userId, e);
        }
        return list;
    }

    @Override
    public boolean save(Notification n) {
        String sql = "INSERT INTO notifications (user_id, message, is_read) VALUES (?, ?, ?) RETURNING id, created_at";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, n.getUserId());
            ps.setString(2, n.getMessage());
            ps.setBoolean(3, n.isRead());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    n.setId(rs.getInt("id"));
                    n.setCreatedAt(rs.getTimestamp("created_at"));
                    return true;
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Error saving notification", e);
        }
        return false;
    }

    @Override
    public boolean update(Notification n) {
        String sql = "UPDATE notifications SET message = ?, is_read = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, n.getMessage());
            ps.setBoolean(2, n.isRead());
            ps.setInt(3, n.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new DatabaseException("Error updating notification ID: " + n.getId(), e);
        }
    }

    /**
     * Marks a notification as read only if it belongs to the authenticated user.
     * Enforces ownership directly at the database query level to prevent IDOR vulnerabilities.
     *
     * @param notificationId Notification record ID
     * @param userId         Authenticated user ID owning the notification
     * @return true if updated, false if not found or unauthorized
     */
    public boolean markAsRead(int notificationId, int userId) {
        String sql = "UPDATE notifications SET is_read = TRUE WHERE id = ? AND user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, notificationId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new DatabaseException("Error marking notification ID " + notificationId + " as read for user ID: " + userId, e);
        }
    }

    public boolean markAsRead(int notificationId) {
        String sql = "UPDATE notifications SET is_read = TRUE WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, notificationId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new DatabaseException("Error marking notification ID " + notificationId + " as read", e);
        }
    }

    public boolean markAllAsRead(int userId) {
        String sql = "UPDATE notifications SET is_read = TRUE WHERE user_id = ? AND is_read = FALSE";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new DatabaseException("Error marking all notifications as read for user ID: " + userId, e);
        }
    }

    public int countUnreadByUserId(int userId) {
        String sql = "SELECT COUNT(*) FROM notifications WHERE user_id = ? AND is_read = FALSE";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            throw new DatabaseException("Error counting unread notifications for user: " + userId, e);
        }
        return 0;
    }

    @Override
    public boolean delete(Integer id) {
        String sql = "DELETE FROM notifications WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new DatabaseException("Error deleting notification ID: " + id, e);
        }
    }

    private Notification mapRowToNotification(ResultSet rs) throws SQLException {
        return new Notification(
                rs.getInt("id"),
                rs.getInt("user_id"),
                rs.getString("message"),
                rs.getBoolean("is_read"),
                rs.getTimestamp("created_at")
        );
    }
}
