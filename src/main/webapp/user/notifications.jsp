<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.fittrack.model.Notification" %>
<%@ page import="java.util.List" %>
<%
    List<Notification> notifications = (List<Notification>) request.getAttribute("notifications");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Notification Center - FitTrack</title>
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
            <li><a href="<%= request.getContextPath() %>/user/messages" class="nav-link">Coach Chat</a></li>
            <li><a href="<%= request.getContextPath() %>/user/notifications" class="nav-link active">Notifications</a></li>
            <li><a href="<%= request.getContextPath() %>/logout" class="btn btn-secondary btn-sm">Logout</a></li>
        </ul>
    </nav>

    <div class="main-container" style="max-width: 800px;">

        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem;">
            <div>
                <h1 style="font-size: 1.75rem; font-weight: 700;">Notification Center</h1>
                <p style="color: var(--text-muted); font-size: 0.95rem;">System alerts, trainer responses, and milestone notifications.</p>
            </div>

            <% if (notifications != null && !notifications.isEmpty()) { %>
                <form action="<%= request.getContextPath() %>/notifications/read-all" method="POST">
                    <button type="submit" class="btn btn-secondary btn-sm">Mark All as Read</button>
                </form>
            <% } %>
        </div>

        <div class="card">
            <% if (notifications == null || notifications.isEmpty()) { %>
                <p style="color: var(--text-muted); text-align: center; padding: 2rem 0;">You have no notifications at this time.</p>
            <% } else { %>
                <div style="display: flex; flex-direction: column; gap: 0.85rem;">
                    <% for (Notification n : notifications) { %>
                        <div style="background: <%= n.isRead() ? "rgba(255,255,255,0.02)" : "rgba(16,185,129,0.07)" %>; 
                                    border: 1px solid <%= n.isRead() ? "var(--card-border)" : "rgba(16,185,129,0.3)" %>; 
                                    border-radius: var(--radius-sm); padding: 1rem; display: flex; justify-content: space-between; align-items: center;">
                            <div>
                                <p style="color: #fff; font-size: 0.95rem; margin-bottom: 0.25rem;"><%= n.getMessage() %></p>
                                <span style="font-size: 0.75rem; color: var(--text-dim);">
                                    <%= n.getCreatedAt() != null ? n.getCreatedAt().toString().substring(0, 16) : "" %>
                                </span>
                            </div>

                            <% if (!n.isRead()) { %>
                                <form action="<%= request.getContextPath() %>/notifications/read" method="POST" style="margin-left: 1rem;">
                                    <input type="hidden" name="id" value="<%= n.getId() %>">
                                    <button type="submit" class="btn btn-primary btn-sm">Mark Read</button>
                                </form>
                            <% } else { %>
                                <span class="badge badge-secondary" style="font-size: 0.7rem; color: var(--text-dim);">Read</span>
                            <% } %>
                        </div>
                    <% } %>
                </div>
            <% } %>
        </div>

    </div>

    <footer class="footer">
        <p>FitTrack Fitness Member Portal &copy; 2026.</p>
    </footer>

</body>
</html>
