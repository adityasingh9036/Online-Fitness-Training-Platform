<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.fittrack.model.User, com.fittrack.model.WorkoutPlan, com.fittrack.model.Message" %>
<%@ page import="java.util.List, java.util.Map" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    Map<String, Object> stats = (Map<String, Object>) request.getAttribute("stats");
    List<WorkoutPlan> pendingPlans = (List<WorkoutPlan>) request.getAttribute("pendingPlans");
    List<Message> recentMessages = (List<Message>) request.getAttribute("recentMessages");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - FitTrack</title>
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
            <li><a href="<%= request.getContextPath() %>/admin/dashboard" class="nav-link active">Dashboard</a></li>
            <li><a href="<%= request.getContextPath() %>/admin/users" class="nav-link">Users</a></li>
            <li><a href="<%= request.getContextPath() %>/admin/workouts" class="nav-link">Workouts</a></li>
            <li><a href="<%= request.getContextPath() %>/admin/settings" class="nav-link">Settings</a></li>
            <li><a href="<%= request.getContextPath() %>/logout" class="btn btn-secondary btn-sm">Logout</a></li>
        </ul>
    </nav>

    <div class="main-container">
        
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem;">
            <div>
                <h1 style="font-size: 1.75rem; font-weight: 700;">System Overview</h1>
                <p style="color: var(--text-muted); font-size: 0.95rem;">
                    Welcome back, <%= currentUser != null ? currentUser.getName() : "Administrator" %>! Role: <span class="badge badge-danger">ADMIN</span>
                </p>
            </div>
            <a href="<%= request.getContextPath() %>/admin/users" class="btn btn-primary btn-sm">+ Add New User</a>
        </div>

        <!-- 4 Metric Cards as per PRD Section 12 -->
        <div class="stats-grid">
            <div class="stat-card">
                <span class="stat-label">Total Users</span>
                <span class="stat-value"><%= stats != null ? stats.get("totalUsers") : 0 %></span>
                <span class="stat-desc">Registered platform accounts</span>
            </div>
            <div class="stat-card">
                <span class="stat-label">Total Trainers</span>
                <span class="stat-value" style="color: #60a5fa;"><%= stats != null ? stats.get("totalTrainers") : 0 %></span>
                <span class="stat-desc">Active fitness coaches</span>
            </div>
            <div class="stat-card">
                <span class="stat-label">Total Workout Plans</span>
                <span class="stat-value" style="color: #34d399;"><%= stats != null ? stats.get("totalPlans") : 0 %></span>
                <span class="stat-desc">Created programs</span>
            </div>
            <div class="stat-card">
                <span class="stat-label">Pending Approvals</span>
                <span class="stat-value" style="color: #fbbf24;"><%= stats != null ? stats.get("pendingPlans") : 0 %></span>
                <span class="stat-desc">Requires admin review</span>
            </div>
        </div>

        <!-- Pending Workout Plan Approval Section -->
        <div class="card">
            <div class="card-header">
                <h2 class="card-title">Pending Workout Plan Approvals</h2>
                <span class="badge badge-warning"><%= pendingPlans != null ? pendingPlans.size() : 0 %> Pending</span>
            </div>

            <% if (pendingPlans == null || pendingPlans.isEmpty()) { %>
                <p style="color: var(--text-muted); padding: 1rem 0;">No workout plans currently pending approval.</p>
            <% } else { %>
                <div class="table-responsive">
                    <table class="custom-table">
                        <thead>
                            <tr>
                                <th>Plan Title</th>
                                <th>Trainer</th>
                                <th>Difficulty</th>
                                <th>Duration</th>
                                <th>Exercises</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (WorkoutPlan p : pendingPlans) { %>
                                <tr>
                                    <td><strong><%= p.getTitle() %></strong></td>
                                    <td><%= p.getTrainerName() %></td>
                                    <td><span class="badge <%= p.getDifficultyBadgeClass() %>"><%= p.getDifficulty() %></span></td>
                                    <td><%= p.getDuration() %> Weeks</td>
                                    <td><%= p.getExercises() != null ? p.getExercises().size() : 0 %> exercises</td>
                                    <td>
                                        <div style="display: flex; gap: 0.5rem;">
                                            <form action="<%= request.getContextPath() %>/admin/workouts" method="POST" style="display: inline;">
                                                <input type="hidden" name="action" value="approve_plan">
                                                <input type="hidden" name="planId" value="<%= p.getId() %>">
                                                <button type="submit" class="btn btn-success btn-sm">Approve</button>
                                            </form>
                                            <form action="<%= request.getContextPath() %>/admin/workouts" method="POST" style="display: inline;">
                                                <input type="hidden" name="action" value="reject_plan">
                                                <input type="hidden" name="planId" value="<%= p.getId() %>">
                                                <button type="submit" class="btn btn-danger btn-sm" onclick="return confirmAction('Reject this plan?')">Reject</button>
                                            </form>
                                        </div>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            <% } %>
        </div>

        <!-- Recent Communications Log -->
        <div class="card">
            <div class="card-header">
                <h2 class="card-title">Recent User Interactions</h2>
                <span class="badge badge-primary">Direct Messages Log</span>
            </div>
            <% if (recentMessages == null || recentMessages.isEmpty()) { %>
                <p style="color: var(--text-muted);">No interactions recorded yet.</p>
            <% } else { %>
                <div class="table-responsive">
                    <table class="custom-table">
                        <thead>
                            <tr>
                                <th>Timestamp</th>
                                <th>Sender</th>
                                <th>Receiver</th>
                                <th>Message Excerpt</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Message m : recentMessages) { %>
                                <tr>
                                    <td><%= m.getCreatedAt() != null ? m.getCreatedAt().toString().substring(0, 16) : "" %></td>
                                    <td><%= m.getSenderName() %> (<span style="font-size:0.75rem; color: var(--text-dim);"><%= m.getSenderRole() %></span>)</td>
                                    <td><%= m.getReceiverName() %> (<span style="font-size:0.75rem; color: var(--text-dim);"><%= m.getReceiverRole() %></span>)</td>
                                    <td><%= m.getMessage() %></td>
                                    <td>
                                        <span class="badge <%= m.isRead() ? "badge-success" : "badge-warning" %>">
                                            <%= m.isRead() ? "READ" : "UNREAD" %>
                                        </span>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            <% } %>
        </div>

    </div>

    <footer class="footer">
        <p>FitTrack Administrator Console &copy; 2026.</p>
    </footer>

</body>
</html>
