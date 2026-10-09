<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.fittrack.model.User, com.fittrack.model.Message" %>
<%@ page import="java.util.List" %>
<%
    User trainer = (User) session.getAttribute("currentUser");
    List<User> contacts = (List<User>) request.getAttribute("contacts");
    List<Message> conversation = (List<Message>) request.getAttribute("conversation");
    Integer activeChatPartnerId = (Integer) request.getAttribute("activeChatPartnerId");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Coach Messaging - FitTrack</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <script src="<%= request.getContextPath() %>/js/main.js"></script>
</head>
<body>

    <nav class="navbar">
        <a href="<%= request.getContextPath() %>/trainer/dashboard" class="nav-brand">
            <div class="brand-icon">💪</div>
            <span>FitTrack Coach</span>
        </a>
        <ul class="nav-menu">
            <li><a href="<%= request.getContextPath() %>/trainer/dashboard" class="nav-link">Dashboard</a></li>
            <li><a href="<%= request.getContextPath() %>/trainer/workouts" class="nav-link">Workouts</a></li>
            <li><a href="<%= request.getContextPath() %>/trainer/progress" class="nav-link">Trainee Progress</a></li>
            <li><a href="<%= request.getContextPath() %>/trainer/messages" class="nav-link active">Messages</a></li>
            <li><a href="<%= request.getContextPath() %>/logout" class="btn btn-secondary btn-sm">Logout</a></li>
        </ul>
    </nav>

    <div class="main-container">

        <h1 style="font-size: 1.75rem; font-weight: 700; margin-bottom: 0.5rem;">Trainee Communications</h1>
        <p style="color: var(--text-muted); font-size: 0.95rem; margin-bottom: 1.5rem;">Direct feedback channel with your clients.</p>

        <div class="chat-container">
            
            <!-- Sidebar Contacts -->
            <div class="chat-sidebar">
                <div style="padding: 1rem; border-bottom: 1px solid var(--card-border); font-weight: 600; font-size: 0.85rem; color: var(--text-muted); text-transform: uppercase;">
                    Client List
                </div>
                <% if (contacts != null) {
                    for (User c : contacts) { 
                        boolean isActive = (activeChatPartnerId != null && activeChatPartnerId == c.getId());
                    %>
                    <a href="<%= request.getContextPath() %>/trainer/messages?userId=<%= c.getId() %>" 
                       class="chat-item <%= isActive ? "active" : "" %>">
                        <strong style="display: block; font-size: 0.9rem;"><%= c.getName() %></strong>
                        <span style="font-size: 0.75rem; color: var(--text-dim);"><%= c.getEmail() %></span>
                    </a>
                <%  }
                   } %>
            </div>

            <!-- Chat Area -->
            <div class="chat-area">
                <% if (activeChatPartnerId != null && activeChatPartnerId > 0) { %>
                    <div class="chat-messages">
                        <% if (conversation == null || conversation.isEmpty()) { %>
                            <div style="text-align: center; color: var(--text-dim); margin-top: 5rem;">
                                No messages yet. Send coaching feedback below!
                            </div>
                        <% } else {
                            for (Message m : conversation) { 
                                boolean isMine = (m.getSenderId() == trainer.getId());
                        %>
                            <div class="message-bubble <%= isMine ? "message-outgoing" : "message-incoming" %>">
                                <div><%= m.getMessage() %></div>
                                <div style="font-size: 0.7rem; opacity: 0.75; text-align: right; margin-top: 0.25rem;">
                                    <%= m.getFormattedTimeIST() %>
                                </div>
                            </div>
                        <%  }
                           } %>
                    </div>

                    <form action="<%= request.getContextPath() %>/trainer/messages" method="POST" class="chat-input-bar">
                        <input type="hidden" name="action" value="send_message">
                        <input type="hidden" name="receiverId" value="<%= activeChatPartnerId %>">
                        <input type="text" name="message" class="form-control" placeholder="Type your advice or answer..." required autocomplete="off">
                        <button type="submit" class="btn btn-primary">Send</button>
                    </form>
                <% } else { %>
                    <div style="display: flex; align-items: center; justify-content: center; height: 100%; color: var(--text-muted);">
                        Select a client from the left to start a conversation.
                    </div>
                <% } %>
            </div>

        </div>

    </div>

    <footer class="footer">
        <p>FitTrack Coach Portal &copy; 2026.</p>
    </footer>

</body>
</html>
