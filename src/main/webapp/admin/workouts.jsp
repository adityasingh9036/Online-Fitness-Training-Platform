<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.fittrack.model.WorkoutPlan" %>
<%@ page import="java.util.List" %>
<%
    List<WorkoutPlan> plans = (List<WorkoutPlan>) request.getAttribute("plans");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Workout Moderation - FitTrack Admin</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <script src="<%= request.getContextPath() %>/js/main.js"></script>
</head>
<body>

    <nav class="navbar">
        <a href="<%= request.getContextPath() %>/admin/dashboard" class="nav-brand">
            <div class="brand-icon">⚡</div>
            <span>FitTrack Admin</span>
        </a>
        <ul class="nav-menu">
            <li><a href="<%= request.getContextPath() %>/admin/dashboard" class="nav-link">Dashboard</a></li>
            <li><a href="<%= request.getContextPath() %>/admin/users" class="nav-link">Users</a></li>
            <li><a href="<%= request.getContextPath() %>/admin/workouts" class="nav-link active">Workouts</a></li>
            <li><a href="<%= request.getContextPath() %>/admin/settings" class="nav-link">Settings</a></li>
            <li><a href="<%= request.getContextPath() %>/logout" class="btn btn-secondary btn-sm">Logout</a></li>
        </ul>
    </nav>

    <div class="main-container">

        <% if (request.getParameter("success") != null) { %>
            <div class="alert alert-success">
                <span><%= request.getParameter("success") %></span>
            </div>
        <% } %>

        <div class="card">
            <div class="card-header">
                <div>
                    <h2 class="card-title">Workout Plans Catalog & Moderation</h2>
                    <p style="color: var(--text-muted); font-size: 0.85rem;">Review, approve, or reject trainer workout submissions.</p>
                </div>
            </div>

            <div class="table-responsive">
                <table class="custom-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Title & Description</th>
                            <th>Trainer</th>
                            <th>Difficulty</th>
                            <th>Duration</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (plans != null) {
                            for (WorkoutPlan p : plans) { %>
                            <tr>
                                <td>#<%= p.getId() %></td>
                                <td>
                                    <strong><%= p.getTitle() %></strong>
                                    <div style="font-size: 0.8rem; color: var(--text-dim); max-width: 320px;"><%= p.getDescription() %></div>
                                </td>
                                <td><%= p.getTrainerName() %></td>
                                <td><span class="badge <%= p.getDifficultyBadgeClass() %>"><%= p.getDifficulty() %></span></td>
                                <td><%= p.getDuration() %> Weeks</td>
                                <td><span class="badge <%= p.getStatusBadgeClass() %>"><%= p.getStatus() %></span></td>
                                <td>
                                    <div style="display: flex; gap: 0.35rem;">
                                        <% if (!"APPROVED".equalsIgnoreCase(p.getStatus())) { %>
                                            <form action="<%= request.getContextPath() %>/admin/workouts" method="POST" style="display: inline;">
                                                <input type="hidden" name="action" value="approve_plan">
                                                <input type="hidden" name="planId" value="<%= p.getId() %>">
                                                <button type="submit" class="btn btn-success btn-sm">Approve</button>
                                            </form>
                                        <% } %>
                                        <% if (!"REJECTED".equalsIgnoreCase(p.getStatus())) { %>
                                            <form action="<%= request.getContextPath() %>/admin/workouts" method="POST" style="display: inline;">
                                                <input type="hidden" name="action" value="reject_plan">
                                                <input type="hidden" name="planId" value="<%= p.getId() %>">
                                                <button type="submit" class="btn btn-warning btn-sm">Reject</button>
                                            </form>
                                        <% } %>
                                    </div>
                                </td>
                            </tr>
                        <%  }
                           } %>
                    </tbody>
                </table>
            </div>
        </div>

    </div>

    <footer class="footer">
        <p>FitTrack Administrator Console &copy; 2026.</p>
    </footer>

</body>
</html>
