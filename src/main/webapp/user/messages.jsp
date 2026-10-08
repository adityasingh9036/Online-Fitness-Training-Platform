<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.fittrack.model.User, com.fittrack.model.Message" %>
<%@ page import="java.util.List" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    List<User> trainers = (List<User>) request.getAttribute("trainers");
    List<Message> conversation = (List<Message>) request.getAttribute("conversation");
    Integer activeTrainerId = (Integer) request.getAttribute("activeTrainerId");
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
        <a href="<%= request.getContextPath() %>/user/dashboard" class="nav-brand">
            <div class="brand-icon">⚡</div>
            <span>FitTrack</span>
        </a>
        <ul class="nav-menu">
            <li><a href="<%= request.getContextPath() %>/user/dashboard" class="nav-link">Dashboard</a></li>
            <li><a href="<%= request.getContextPath() %>/user/workouts" class="nav-link">Workouts</a></li>
            <li><a href="<%= request.getContextPath() %>/user/progress" class="nav-link">My Progress</a></li>
            <li><a href="<%= request.getContextPath() %>/user/messages" class="nav-link active">Coach Chat</a></li>
            <li><a href="<%= request.getContextPath() %>/user/notifications" class="nav-link">Notifications</a></li>
            <li><a href="<%= request.getContextPath() %>/logout" class="btn btn-secondary btn-sm">Logout</a></li>
        </ul>
    </nav>

    <div class="main-container">

        <h1 style="font-size: 1.75rem; font-weight: 700; margin-bottom: 0.5rem;">Direct Coach Consultation</h1>
        <p style="color: var(--text-muted); font-size: 0.95rem; margin-bottom: 1.5rem;">Ask workout form questions, request nutrition adjustments, and receive guidance.</p>

        <div class="chat-container">
            
            <!-- Sidebar: Available Trainers -->
            <div class="chat-sidebar">
                <div style="padding: 1rem; border-bottom: 1px solid var(--card-border); font-weight: 600; font-size: 0.85rem; color: var(--text-muted); text-transform: uppercase;">
                    Certified Trainers
                </div>
                <% if (trainers != null) {
                    for (User t : trainers) { 
                        boolean isActive = (activeTrainerId != null && activeTrainerId == t.getId());
                    %>
                    <a href="<%= request.getContextPath() %>/user/messages?trainerId=<%= t.getId() %>" 
                       class="chat-item <%= isActive ? "active" : "" %>">
                        <strong style="display: block; font-size: 0.9rem;"><%= t.getName() %></strong>
                        <span style="font-size: 0.75rem; color: var(--text-dim);"><%= t.getEmail() %></span>
                    </a>
                <%  }
                   } %>
            </div>

            <!-- Chat Area -->
            <div class="chat-area">
                <% if (activeTrainerId != null && activeTrainerId > 0) { %>
                    <div class="chat-messages">
                        <% if (conversation == null || conversation.isEmpty()) { %>
                            <div style="text-align: center; color: var(--text-dim); margin-top: 5rem;">
                                No previous conversation. Send your first question to the coach below!
                            </div>
                        <% } else {
                            for (Message m : conversation) { 
                                boolean isMine = (m.getSenderId() == currentUser.getId());
                        %>
                            <div class="message-bubble <%= isMine ? "message-outgoing" : "message-incoming" %>">
                                <div><%= m.getMessage() %></div>
                                <div style="font-size: 0.7rem; opacity: 0.75; text-align: right; margin-top: 0.25rem;">
                                    <%= m.getCreatedAt() != null ? m.getCreatedAt().toString().substring(11, 16) : "" %>
                                </div>
                            </div>
                        <%  }
                           } %>
                    </div>

                    <form action="<%= request.getContextPath() %>/user/messages" method="POST" class="chat-input-bar">
                        <input type="hidden" name="trainerId" value="<%= activeTrainerId %>">
                        <input type="text" name="message" class="form-control" placeholder="Ask your coach anything..." required autocomplete="off">
                        <button type="submit" class="btn btn-primary">Send</button>
                    </form>
                <% } else { %>
                    <div style="display: flex; align-items: center; justify-content: center; height: 100%; color: var(--text-muted);">
                        Select a coach from the left sidebar to begin messaging.
                    </div>
                <% } %>
            </div>

        </div>

    </div>

    <footer class="footer">
        <p>FitTrack Fitness Member Portal &copy; 2026.</p>
    </footer>

</body>
</html>
