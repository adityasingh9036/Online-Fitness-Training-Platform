package com.fittrack.service;

import com.fittrack.dao.NotificationDAO;
import com.fittrack.model.Notification;

import java.util.List;

/**
 * Service managing user notifications and alerts.
 */
public class NotificationService {

    private final NotificationDAO notificationDAO;

    public NotificationService() {
        this.notificationDAO = new NotificationDAO();
    }

    public NotificationService(NotificationDAO notificationDAO) {
        this.notificationDAO = notificationDAO;
    }

    public Notification createNotification(int userId, String message) {
        if (message == null || message.trim().isEmpty()) return null;
        Notification n = new Notification(0, userId, message.trim(), false, null);
        notificationDAO.save(n);
        return n;
    }

    public List<Notification> getUserNotifications(int userId) {
        return notificationDAO.findByUserId(userId);
    }

    public List<Notification> getUnreadNotifications(int userId) {
        return notificationDAO.findUnreadByUserId(userId);
    }

    public boolean markAsRead(int notificationId) {
        return notificationDAO.markAsRead(notificationId);
    }

    public boolean markAllAsRead(int userId) {
        return notificationDAO.markAllAsRead(userId);
    }

    public int getUnreadCount(int userId) {
        return notificationDAO.countUnreadByUserId(userId);
    }
}
