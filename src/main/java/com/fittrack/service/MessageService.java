package com.fittrack.service;

import com.fittrack.dao.MessageDAO;
import com.fittrack.dao.NotificationDAO;
import com.fittrack.exception.ValidationException;
import com.fittrack.model.Message;
import com.fittrack.model.Notification;
import com.fittrack.util.ValidationUtil;

import java.util.List;

/**
 * Service managing direct messaging between Users and Trainers.
 */
public class MessageService {

    private final MessageDAO messageDAO;
    private final NotificationDAO notificationDAO;

    public MessageService() {
        this.messageDAO = new MessageDAO();
        this.notificationDAO = new NotificationDAO();
    }

    public MessageService(MessageDAO messageDAO, NotificationDAO notificationDAO) {
        this.messageDAO = messageDAO;
        this.notificationDAO = notificationDAO;
    }

    public Message sendMessage(int senderId, int receiverId, String content) throws ValidationException {
        ValidationUtil.validateNotEmpty(content, "Message");

        Message msg = new Message();
        msg.setSenderId(senderId);
        msg.setReceiverId(receiverId);
        msg.setMessage(content.trim());
        msg.setRead(false);

        boolean saved = messageDAO.save(msg);
        if (saved) {
            // Send automatic notification to receiver
            notificationDAO.save(new Notification(
                    0,
                    receiverId,
                    "You received a new message from user #" + senderId + ": " + 
                            (content.length() > 30 ? content.substring(0, 30) + "..." : content),
                    false,
                    null
            ));
        }
        return msg;
    }

    public List<Message> getConversation(int user1Id, int user2Id) {
        // Automatically mark as read for receiver
        messageDAO.markConversationAsRead(user1Id, user2Id);
        return messageDAO.getConversation(user1Id, user2Id);
    }

    public List<Message> getRecentInteractions(int userId) {
        return messageDAO.findRecentUserInteractions(userId);
    }

    public int getUnreadMessageCount(int userId) {
        return messageDAO.countUnreadMessages(userId);
    }
}
