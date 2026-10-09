package com.fittrack.model;

import java.io.Serializable;
import java.sql.Timestamp;
import java.time.Instant;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;

/**
 * Model representing a direct communication message between Users and Trainers.
 */
public class Message implements Serializable {

    private static final long serialVersionUID = 1L;

    public static final ZoneId IST_ZONE = ZoneId.of("Asia/Kolkata");
    public static final ZoneId UTC_ZONE = ZoneId.of("UTC");
    private static final DateTimeFormatter TIME_FORMATTER = DateTimeFormatter.ofPattern("HH:mm");
    private static final DateTimeFormatter DATE_TIME_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

    private int id;
    private int senderId;
    private String senderName;
    private String senderRole;
    private int receiverId;
    private String receiverName;
    private String receiverRole;
    private String message;
    private Timestamp createdAt;
    private boolean isRead;

    public Message() {
    }

    public Message(int id, int senderId, int receiverId, String message, Timestamp createdAt, boolean isRead) {
        this.id = id;
        this.senderId = senderId;
        this.receiverId = receiverId;
        this.message = message;
        this.createdAt = createdAt;
        this.isRead = isRead;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getSenderId() {
        return senderId;
    }

    public void setSenderId(int senderId) {
        this.senderId = senderId;
    }

    public String getSenderName() {
        return senderName;
    }

    public void setSenderName(String senderName) {
        this.senderName = senderName;
    }

    public String getSenderRole() {
        return senderRole;
    }

    public void setSenderRole(String senderRole) {
        this.senderRole = senderRole;
    }

    public int getReceiverId() {
        return receiverId;
    }

    public void setReceiverId(int receiverId) {
        this.receiverId = receiverId;
    }

    public String getReceiverName() {
        return receiverName;
    }

    public void setReceiverName(String receiverName) {
        this.receiverName = receiverName;
    }

    public String getReceiverRole() {
        return receiverRole;
    }

    public void setReceiverRole(String receiverRole) {
        this.receiverRole = receiverRole;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public void setCreatedAt(Instant instant) {
        this.createdAt = (instant != null) ? Timestamp.from(instant) : null;
    }

    public void setCreatedAt(ZonedDateTime zdt) {
        this.createdAt = (zdt != null) ? Timestamp.from(zdt.toInstant()) : null;
    }

    /**
     * Converts the stored message timestamp into a ZonedDateTime in Indian Standard Time (Asia/Kolkata).
     *
     * @return ZonedDateTime in Asia/Kolkata, or null if createdAt is null
     */
    public ZonedDateTime getCreatedAtIST() {
        if (createdAt == null) {
            return null;
        }
        return createdAt.toInstant().atZone(IST_ZONE);
    }

    /**
     * Returns the message time formatted in Indian Standard Time (HH:mm).
     *
     * @return formatted time string (e.g. "14:30") or empty string if null
     */
    public String getFormattedTimeIST() {
        ZonedDateTime ist = getCreatedAtIST();
        return ist != null ? ist.format(TIME_FORMATTER) : "";
    }

    /**
     * Convenience method returning formatted time in Indian Standard Time.
     *
     * @return formatted time string (e.g. "14:30") or empty string if null
     */
    public String getFormattedTime() {
        return getFormattedTimeIST();
    }

    /**
     * Returns the message date and time formatted in Indian Standard Time (yyyy-MM-dd HH:mm).
     *
     * @return formatted date-time string (e.g. "2026-10-09 14:30") or empty string if null
     */
    public String getFormattedDateTimeIST() {
        ZonedDateTime ist = getCreatedAtIST();
        return ist != null ? ist.format(DATE_TIME_FORMATTER) : "";
    }

    /**
     * Convenience method returning formatted date and time in Indian Standard Time.
     *
     * @return formatted date-time string (e.g. "2026-10-09 14:30") or empty string if null
     */
    public String getFormattedDateTime() {
        return getFormattedDateTimeIST();
    }

    public boolean isRead() {
        return isRead;
    }

    public void setRead(boolean read) {
        isRead = read;
    }
}
