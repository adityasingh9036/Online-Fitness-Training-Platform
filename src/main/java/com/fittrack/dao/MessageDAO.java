package com.fittrack.dao;

import com.fittrack.exception.DatabaseException;
import com.fittrack.model.Message;
import com.fittrack.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for User <-> Trainer communication messages.
 */
public class MessageDAO implements GenericDAO<Message, Integer> {

    @Override
    public Message findById(Integer id) {
        String sql = "SELECT m.id, m.sender_id, u1.name AS sender_name, u1.role AS sender_role, " +
                     "m.receiver_id, u2.name AS receiver_name, u2.role AS receiver_role, " +
                     "m.message, m.created_at, m.is_read " +
                     "FROM messages m " +
                     "JOIN users u1 ON m.sender_id = u1.id " +
                     "JOIN users u2 ON m.receiver_id = u2.id " +
                     "WHERE m.id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToMessage(rs);
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Error finding message by ID: " + id, e);
        }
        return null;
    }

    @Override
    public List<Message> findAll() {
        List<Message> list = new ArrayList<>();
        String sql = "SELECT m.id, m.sender_id, u1.name AS sender_name, u1.role AS sender_role, " +
                     "m.receiver_id, u2.name AS receiver_name, u2.role AS receiver_role, " +
                     "m.message, m.created_at, m.is_read " +
                     "FROM messages m " +
                     "JOIN users u1 ON m.sender_id = u1.id " +
                     "JOIN users u2 ON m.receiver_id = u2.id " +
                     "ORDER BY m.created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                list.add(mapRowToMessage(rs));
            }
        } catch (SQLException e) {
            throw new DatabaseException("Error retrieving all messages", e);
        }
        return list;
    }

    public List<Message> getConversation(int user1Id, int user2Id) {
        List<Message> list = new ArrayList<>();
        String sql = "SELECT m.id, m.sender_id, u1.name AS sender_name, u1.role AS sender_role, " +
                     "m.receiver_id, u2.name AS receiver_name, u2.role AS receiver_role, " +
                     "m.message, m.created_at, m.is_read " +
                     "FROM messages m " +
                     "JOIN users u1 ON m.sender_id = u1.id " +
                     "JOIN users u2 ON m.receiver_id = u2.id " +
                     "WHERE (m.sender_id = ? AND m.receiver_id = ?) " +
                     "   OR (m.sender_id = ? AND m.receiver_id = ?) " +
                     "ORDER BY m.created_at ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, user1Id);
            ps.setInt(2, user2Id);
            ps.setInt(3, user2Id);
            ps.setInt(4, user1Id);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToMessage(rs));
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Error fetching conversation between " + user1Id + " and " + user2Id, e);
        }
        return list;
    }

    public List<Message> findRecentUserInteractions(int userId) {
        List<Message> list = new ArrayList<>();
        String sql = "SELECT m.id, m.sender_id, u1.name AS sender_name, u1.role AS sender_role, " +
                     "m.receiver_id, u2.name AS receiver_name, u2.role AS receiver_role, " +
                     "m.message, m.created_at, m.is_read " +
                     "FROM messages m " +
                     "JOIN users u1 ON m.sender_id = u1.id " +
                     "JOIN users u2 ON m.receiver_id = u2.id " +
                     "WHERE m.sender_id = ? OR m.receiver_id = ? " +
                     "ORDER BY m.created_at DESC LIMIT 15";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToMessage(rs));
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Error fetching recent interactions for user: " + userId, e);
        }
        return list;
    }

    @Override
    public boolean save(Message m) {
        String sql = "INSERT INTO messages (sender_id, receiver_id, message, is_read) VALUES (?, ?, ?, ?) RETURNING id, created_at";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, m.getSenderId());
            ps.setInt(2, m.getReceiverId());
            ps.setString(3, m.getMessage());
            ps.setBoolean(4, m.isRead());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    m.setId(rs.getInt("id"));
                    m.setCreatedAt(rs.getTimestamp("created_at"));
                    return true;
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Error sending message", e);
        }
        return false;
    }

    @Override
    public boolean update(Message m) {
        String sql = "UPDATE messages SET message = ?, is_read = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, m.getMessage());
            ps.setBoolean(2, m.isRead());
            ps.setInt(3, m.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new DatabaseException("Error updating message ID: " + m.getId(), e);
        }
    }

    public boolean markConversationAsRead(int receiverId, int senderId) {
        String sql = "UPDATE messages SET is_read = TRUE WHERE receiver_id = ? AND sender_id = ? AND is_read = FALSE";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, receiverId);
            ps.setInt(2, senderId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new DatabaseException("Error marking conversation as read", e);
        }
    }

    public int countUnreadMessages(int userId) {
        String sql = "SELECT COUNT(*) FROM messages WHERE receiver_id = ? AND is_read = FALSE";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            throw new DatabaseException("Error counting unread messages", e);
        }
        return 0;
    }

    @Override
    public boolean delete(Integer id) {
        String sql = "DELETE FROM messages WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new DatabaseException("Error deleting message ID: " + id, e);
        }
    }

    private Message mapRowToMessage(ResultSet rs) throws SQLException {
        Message m = new Message(
                rs.getInt("id"),
                rs.getInt("sender_id"),
                rs.getInt("receiver_id"),
                rs.getString("message"),
                rs.getTimestamp("created_at"),
                rs.getBoolean("is_read")
        );
        m.setSenderName(rs.getString("sender_name"));
        m.setSenderRole(rs.getString("sender_role"));
        m.setReceiverName(rs.getString("receiver_name"));
        m.setReceiverRole(rs.getString("receiver_role"));
        return m;
    }
}
