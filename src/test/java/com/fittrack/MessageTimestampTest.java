package com.fittrack;

import com.fittrack.dao.MessageDAO;
import com.fittrack.model.Message;
import com.fittrack.service.MessageService;
import com.fittrack.util.DBConnection;
import org.junit.jupiter.api.Test;

import java.sql.Timestamp;
import java.time.Instant;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Verification Suite for FitTrack Messaging Timezone and Timestamps.
 * Validates UTC storage, java.time conversion to Asia/Kolkata (IST), and formatting.
 */
public class MessageTimestampTest {

    @Test
    public void testMessageModelTimezoneConversion() {
        Message msg = new Message();
        assertNull(msg.getCreatedAtIST());
        assertEquals("", msg.getFormattedTimeIST());
        assertEquals("", msg.getFormattedDateTimeIST());

        // Given a specific UTC instant: 2026-10-09 10:30:00 UTC
        Instant utcInstant = Instant.parse("2026-10-09T10:30:00Z");
        msg.setCreatedAt(Timestamp.from(utcInstant));

        // When converted to Asia/Kolkata (UTC + 05:30), it should be 16:00 (4:00 PM) on 2026-10-09
        ZonedDateTime ist = msg.getCreatedAtIST();
        assertNotNull(ist);
        assertEquals(ZoneId.of("Asia/Kolkata"), ist.getZone());
        assertEquals(2026, ist.getYear());
        assertEquals(10, ist.getMonthValue());
        assertEquals(9, ist.getDayOfMonth());
        assertEquals(16, ist.getHour());
        assertEquals(0, ist.getMinute());

        // Verify formatting outputs
        assertEquals("16:00", msg.getFormattedTimeIST());
        assertEquals("16:00", msg.getFormattedTime());
        assertEquals("2026-10-09 16:00", msg.getFormattedDateTimeIST());
        assertEquals("2026-10-09 16:00", msg.getFormattedDateTime());
    }

    @Test
    public void testMessageDAOAndServiceSendAndRetrieve() throws Exception {
        org.junit.jupiter.api.Assumptions.assumeTrue(
                DBConnection.isPasswordConfigured(),
                "Supabase DB password not configured; skipping remote messaging test."
        );

        MessageService messageService = new MessageService();
        MessageDAO messageDAO = new MessageDAO();

        String testContent = "Automated test message for IST timestamp verification " + System.currentTimeMillis();
        Message sentMessage = null;

        try {
            // Send a test message from trainer (ID: 2) to user (ID: 3)
            sentMessage = messageService.sendMessage(2, 3, testContent);
            assertNotNull(sentMessage);
            assertTrue(sentMessage.getId() > 0, "Saved message must have generated ID");
            assertNotNull(sentMessage.getCreatedAt(), "Saved message must have created_at timestamp");

            final int sentId = sentMessage.getId();

            // Verify the model converts the timestamp to IST
            ZonedDateTime ist = sentMessage.getCreatedAtIST();
            assertNotNull(ist, "IST ZonedDateTime must not be null");
            assertFalse(sentMessage.getFormattedTimeIST().isEmpty(), "Formatted time must not be empty");

            // Retrieve conversation
            List<Message> conversation = messageService.getConversation(2, 3);
            assertNotNull(conversation);
            assertFalse(conversation.isEmpty());

            // Find the sent message in the conversation
            Message retrieved = conversation.stream()
                    .filter(m -> m.getId() == sentId)
                    .findFirst()
                    .orElse(null);

            assertNotNull(retrieved, "Retrieved conversation must contain the newly sent message");
            assertNotNull(retrieved.getCreatedAt(), "Retrieved message must have created_at");
            assertNotNull(retrieved.getCreatedAtIST(), "Retrieved message must have IST time");
            assertEquals(sentMessage.getFormattedTimeIST(), retrieved.getFormattedTimeIST(),
                    "Formatted time must match between sent and retrieved message");

            // Verify recent interactions retrieval
            List<Message> recent = messageService.getRecentInteractions(2);
            assertNotNull(recent);
            boolean foundInRecent = recent.stream().anyMatch(m -> m.getId() == sentId);
            assertTrue(foundInRecent, "Recent interactions must contain newly sent message");

        } finally {
            // Cleanup test message
            if (sentMessage != null && sentMessage.getId() > 0) {
                messageDAO.delete(sentMessage.getId());
            }
        }
    }
}
