<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.fittrack.model.User, com.fittrack.model.WorkoutPlan, com.fittrack.model.Message" %>
<%@ page import="java.util.List, java.util.Map" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    Map<String, Object> stats = (Map<String, Object>) request.getAttribute("stats");
    List<WorkoutPlan> pendingPlans = (List<WorkoutPlan>) request.getAttribute("pendingPlans");
    List<Message> recentMessages = (List<Message>) request.getAttribute("recentMessages");

    int totalUsersVal = stats != null && stats.get("totalUsers") != null ? ((Number) stats.get("totalUsers")).intValue() : 0;
    int totalTrainersVal = stats != null && stats.get("totalTrainers") != null ? ((Number) stats.get("totalTrainers")).intValue() : 0;
    int totalMembersVal = stats != null && stats.get("totalMembers") != null ? ((Number) stats.get("totalMembers")).intValue() : 0;
    int adminUsersVal = Math.max(0, totalUsersVal - totalTrainersVal - totalMembersVal);
    
    int totalPlansVal = stats != null && stats.get("totalPlans") != null ? ((Number) stats.get("totalPlans")).intValue() : 0;
    int pendingPlansVal = stats != null && stats.get("pendingPlans") != null ? ((Number) stats.get("pendingPlans")).intValue() : 0;
    int approvedPlansVal = Math.max(0, totalPlansVal - pendingPlansVal);
    
    int planApprovalPct = totalPlansVal > 0 ? (int) Math.round((approvedPlansVal * 100.0) / totalPlansVal) : 0;
    int pendingPlanPct = totalPlansVal > 0 ? (100 - planApprovalPct) : 0;
    
    int memberPct = totalUsersVal > 0 ? (int) Math.round((totalMembersVal * 100.0) / totalUsersVal) : 0;
    int trainerPct = totalUsersVal > 0 ? (int) Math.round((totalTrainersVal * 100.0) / totalUsersVal) : 0;
    int adminPct = totalUsersVal > 0 ? Math.max(0, 100 - memberPct - trainerPct) : 0;
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
        
        <% if (request.getParameter("success") != null) { %>
            <div class="alert alert-success">
                <span><%= request.getParameter("success") %></span>
            </div>
        <% } %>
        <% if (request.getParameter("error") != null) { %>
            <div class="alert alert-error">
                <span><%= request.getParameter("error") %></span>
            </div>
        <% } %>

        <div class="page-header">
            <div>
                <h1 class="page-title">System Overview</h1>
                <p class="page-subtitle">
                    Welcome back, <%= currentUser != null ? currentUser.getName() : "Administrator" %> | Role: <span class="badge badge-danger">ADMIN</span>
                </p>
            </div>
            <div style="display: flex; gap: 0.5rem; flex-wrap: wrap;">
                <a href="<%= request.getContextPath() %>/admin/users" class="btn btn-primary btn-sm">+ Add New User</a>
                <a href="<%= request.getContextPath() %>/admin/settings" class="btn btn-secondary btn-sm">System Config</a>
            </div>
        </div>

        <!-- 4 Refined Metric Cards -->
        <div class="stats-grid">
            <div class="stat-card stat-indigo">
                <div style="display: flex; justify-content: space-between; align-items: flex-start;">
                    <span class="stat-label">Total Users</span>
                    <div class="stat-icon stat-icon-indigo">👥</div>
                </div>
                <span class="stat-value"><%= totalUsersVal %></span>
                <span class="stat-desc">Registered platform accounts</span>
            </div>
            <div class="stat-card stat-blue">
                <div style="display: flex; justify-content: space-between; align-items: flex-start;">
                    <span class="stat-label">Total Coaches</span>
                    <div class="stat-icon stat-icon-blue">🏋️</div>
                </div>
                <span class="stat-value" style="color: #60a5fa;"><%= totalTrainersVal %></span>
                <span class="stat-desc">Active fitness trainers</span>
            </div>
            <div class="stat-card stat-emerald">
                <div style="display: flex; justify-content: space-between; align-items: flex-start;">
                    <span class="stat-label">Workout Plans</span>
                    <div class="stat-icon stat-icon-emerald">📋</div>
                </div>
                <span class="stat-value" style="color: #34d399;"><%= totalPlansVal %></span>
                <span class="stat-desc">Authored programs</span>
            </div>
            <div class="stat-card stat-amber">
                <div style="display: flex; justify-content: space-between; align-items: flex-start;">
                    <span class="stat-label">Pending Review</span>
                    <div class="stat-icon stat-icon-amber">⏳</div>
                </div>
                <span class="stat-value" style="color: #fbbf24;"><%= pendingPlansVal %></span>
                <span class="stat-desc">Requires admin review</span>
            </div>
        </div>

        <!-- Real Database Workout Activity & Platform Analytics Chart -->
        <div class="chart-container">
            <div class="chart-card">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.25rem;">
                    <div>
                        <h3 style="font-size: 1.05rem; font-weight: 600; color: #fff;">Workout Plan Distribution</h3>
                        <p style="font-size: 0.8rem; color: var(--text-muted); margin: 0;">Live status breakdown of submitted programs</p>
                    </div>
                    <span class="badge badge-primary"><%= totalPlansVal %> Total</span>
                </div>

                <div class="chart-row">
                    <div class="chart-row-label">
                        <span>Approved & Active Plans</span>
                        <strong><%= approvedPlansVal %> (<%= planApprovalPct %>%)</strong>
                    </div>
                    <div class="chart-bar-bg">
                        <div class="chart-bar-fill" style="width: <%= planApprovalPct %>%; background: #10b981;"></div>
                    </div>
                </div>

                <div class="chart-row" style="margin-bottom: 0.5rem;">
                    <div class="chart-row-label">
                        <span>Pending Admin Moderation</span>
                        <strong><%= pendingPlansVal %> (<%= pendingPlanPct %>%)</strong>
                    </div>
                    <div class="chart-bar-bg">
                        <div class="chart-bar-fill" style="width: <%= pendingPlanPct %>%; background: #f59e0b;"></div>
                    </div>
                </div>
            </div>

            <div class="chart-card">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.25rem;">
                    <div>
                        <h3 style="font-size: 1.05rem; font-weight: 600; color: #fff;">User Role Composition</h3>
                        <p style="font-size: 0.8rem; color: var(--text-muted); margin: 0;">Registered accounts breakdown by role</p>
                    </div>
                    <span class="badge badge-primary"><%= totalUsersVal %> Total</span>
                </div>

                <div class="chart-row">
                    <div class="chart-row-label">
                        <span>Fitness Members (USER)</span>
                        <strong><%= totalMembersVal %> (<%= memberPct %>%)</strong>
                    </div>
                    <div class="chart-bar-bg">
                        <div class="chart-bar-fill" style="width: <%= memberPct %>%; background: #10b981;"></div>
                    </div>
                </div>

                <div class="chart-row">
                    <div class="chart-row-label">
                        <span>Certified Coaches (TRAINER)</span>
                        <strong><%= totalTrainersVal %> (<%= trainerPct %>%)</strong>
                    </div>
                    <div class="chart-bar-bg">
                        <div class="chart-bar-fill" style="width: <%= trainerPct %>%; background: #3b82f6;"></div>
                    </div>
                </div>

                <div class="chart-row" style="margin-bottom: 0.5rem;">
                    <div class="chart-row-label">
                        <span>System Administrators (ADMIN)</span>
                        <strong><%= adminUsersVal %> (<%= adminPct %>%)</strong>
                    </div>
                    <div class="chart-bar-bg">
                        <div class="chart-bar-fill" style="width: <%= adminPct %>%; background: #ef4444;"></div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Pending Workout Plan Approval Section -->
        <div class="card">
            <div class="card-header">
                <div>
                    <h2 class="card-title">Pending Workout Plan Approvals</h2>
                    <p class="card-subtitle">Trainer submissions that require administrative verification before publishing</p>
                </div>
                <span class="badge <%= (pendingPlans != null && !pendingPlans.isEmpty()) ? "badge-warning" : "badge-success" %>">
                    <%= pendingPlans != null ? pendingPlans.size() : 0 %> Pending
                </span>
            </div>

            <% if (pendingPlans == null || pendingPlans.isEmpty()) { %>
                <div class="empty-state">
                    <div class="empty-state-icon">✅</div>
                    <div class="empty-state-title">No Plans Awaiting Approval</div>
                    <p class="empty-state-desc">All submitted workout plans have been reviewed. When coaches author new programs, they will appear here for verification.</p>
                </div>
            <% } else { %>
                <div class="table-responsive">
                    <table class="custom-table">
                        <thead>
                            <tr>
                                <th>Plan Title</th>
                                <th>Coach</th>
                                <th>Difficulty</th>
                                <th>Duration</th>
                                <th>Exercises</th>
                                <th style="text-align: right;">Moderation Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (WorkoutPlan p : pendingPlans) { %>
                                <tr>
                                    <td>
                                        <strong style="color: #f1f5f9; display: block;"><%= p.getTitle() %></strong>
                                        <span style="font-size: 0.8rem; color: var(--text-dim);"><%= p.getDescription() != null && p.getDescription().length() > 60 ? p.getDescription().substring(0, 60) + "..." : p.getDescription() %></span>
                                    </td>
                                    <td>
                                        <div style="display: flex; align-items: center; gap: 0.4rem;">
                                            <span style="color: #60a5fa;">🏋️</span>
                                            <span><%= p.getTrainerName() %></span>
                                        </div>
                                    </td>
                                    <td><span class="badge <%= p.getDifficultyBadgeClass() %>"><%= p.getDifficulty() %></span></td>
                                    <td><%= p.getDuration() %> Weeks</td>
                                    <td><span class="badge badge-primary"><%= p.getExercises() != null ? p.getExercises().size() : 0 %> movements</span></td>
                                    <td style="text-align: right;">
                                        <div style="display: inline-flex; gap: 0.5rem;">
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
                <div>
                    <h2 class="card-title">Recent User Interactions</h2>
                    <p class="card-subtitle">Real-time consultation log between coaches and members</p>
                </div>
                <span class="badge badge-primary">Direct Message Stream</span>
            </div>
            <% if (recentMessages == null || recentMessages.isEmpty()) { %>
                <div class="empty-state">
                    <div class="empty-state-icon">💬</div>
                    <div class="empty-state-title">No Recent Inquiries</div>
                    <p class="empty-state-desc">Trainer-to-trainee messages and platform consultations will be logged here for administrative visibility.</p>
                </div>
            <% } else { %>
                <div class="table-responsive">
                    <table class="custom-table">
                        <thead>
                            <tr>
                                <th>Timestamp</th>
                                <th>Sender</th>
                                <th>Recipient</th>
                                <th>Message Excerpt</th>
                                <th style="text-align: right;">Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Message m : recentMessages) { %>
                                <tr>
                                    <td style="white-space: nowrap; font-size: 0.82rem; color: var(--text-dim);">
                                        <%= m.getFormattedDateTimeIST() %>
                                    </td>
                                    <td>
                                        <div style="font-weight: 500; color: #f1f5f9;"><%= m.getSenderName() %></div>
                                        <span class="badge <%= "TRAINER".equals(m.getSenderRole()) ? "badge-primary" : "badge-success" %>" style="font-size: 0.7rem; padding: 0.15rem 0.45rem;">
                                            <%= m.getSenderRole() %>
                                        </span>
                                    </td>
                                    <td>
                                        <div style="font-weight: 500; color: #f1f5f9;"><%= m.getReceiverName() %></div>
                                        <span class="badge <%= "TRAINER".equals(m.getReceiverRole()) ? "badge-primary" : "badge-success" %>" style="font-size: 0.7rem; padding: 0.15rem 0.45rem;">
                                            <%= m.getReceiverRole() %>
                                        </span>
                                    </td>
                                    <td style="max-width: 380px;">
                                        <span style="color: var(--text-secondary); line-height: 1.4; display: block;">
                                            <%= m.getMessage() %>
                                        </span>
                                    </td>
                                    <td style="text-align: right;">
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
        <p>FitTrack Administrator Console &copy; 2026. Java Web &amp; PostgreSQL SaaS Platform.</p>
    </footer>

</body>
</html>
