<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.fittrack.model.User, com.fittrack.model.WorkoutPlan, com.fittrack.model.Message" %>
<%@ page import="java.util.List" %>
<%
    User trainer = (User) session.getAttribute("currentUser");
    List<WorkoutPlan> myPlans = (List<WorkoutPlan>) request.getAttribute("myPlans");
    Long pendingCount = (Long) request.getAttribute("pendingCount");
    List<User> members = (List<User>) request.getAttribute("members");
    List<Message> recentMessages = (List<Message>) request.getAttribute("recentMessages");

    int myPlansCount = myPlans != null ? myPlans.size() : 0;
    long pendingVal = pendingCount != null ? pendingCount : 0L;
    int memberCount = members != null ? members.size() : 0;
    int msgCount = recentMessages != null ? recentMessages.size() : 0;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Trainer Dashboard - FitTrack</title>
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
            <li><a href="<%= request.getContextPath() %>/trainer/dashboard" class="nav-link active">Dashboard</a></li>
            <li><a href="<%= request.getContextPath() %>/trainer/workouts" class="nav-link">Workouts</a></li>
            <li><a href="<%= request.getContextPath() %>/trainer/progress" class="nav-link">Trainee Progress</a></li>
            <li><a href="<%= request.getContextPath() %>/trainer/messages" class="nav-link">Messages</a></li>
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
                <h1 class="page-title">Coach Command Center</h1>
                <p class="page-subtitle">
                    Welcome back, <%= trainer != null ? trainer.getName() : "Coach" %> | Role: <span class="badge badge-primary">TRAINER</span>
                </p>
            </div>
            <div style="display: flex; gap: 0.5rem; flex-wrap: wrap;">
                <a href="<%= request.getContextPath() %>/trainer/workouts" class="btn btn-primary btn-sm">+ New Workout Plan</a>
                <a href="<%= request.getContextPath() %>/trainer/progress" class="btn btn-secondary btn-sm">Review Trainees</a>
            </div>
        </div>

        <!-- 4 Metric Cards with Consistent SaaS Icons -->
        <div class="stats-grid">
            <div class="stat-card stat-blue">
                <div style="display: flex; justify-content: space-between; align-items: flex-start;">
                    <span class="stat-label">My Workout Plans</span>
                    <div class="stat-icon stat-icon-blue">📋</div>
                </div>
                <span class="stat-value" style="color: #60a5fa;"><%= myPlansCount %></span>
                <span class="stat-desc">Authored programs</span>
            </div>
            <div class="stat-card stat-amber">
                <div style="display: flex; justify-content: space-between; align-items: flex-start;">
                    <span class="stat-label">Pending Approval</span>
                    <div class="stat-icon stat-icon-amber">⏳</div>
                </div>
                <span class="stat-value" style="color: #fbbf24;"><%= pendingVal %></span>
                <span class="stat-desc">Awaiting admin review</span>
            </div>
            <div class="stat-card stat-emerald">
                <div style="display: flex; justify-content: space-between; align-items: flex-start;">
                    <span class="stat-label">Active Members</span>
                    <div class="stat-icon stat-icon-emerald">👥</div>
                </div>
                <span class="stat-value" style="color: #34d399;"><%= memberCount %></span>
                <span class="stat-desc">Registered fitness trainees</span>
            </div>
            <div class="stat-card stat-indigo">
                <div style="display: flex; justify-content: space-between; align-items: flex-start;">
                    <span class="stat-label">Direct Inquiries</span>
                    <div class="stat-icon stat-icon-indigo">💬</div>
                </div>
                <span class="stat-value"><%= msgCount %></span>
                <span class="stat-desc">Trainee consultations</span>
            </div>
        </div>

        <div style="display: grid; grid-template-columns: 3fr 2fr; gap: 1.5rem; margin-bottom: 2rem;">
            <!-- My Programs List -->
            <div class="card">
                <div class="card-header">
                    <div>
                        <h2 class="card-title">My Authored Programs</h2>
                        <p class="card-subtitle">Training curriculums managed by you</p>
                    </div>
                    <a href="<%= request.getContextPath() %>/trainer/workouts" class="btn btn-primary btn-sm">Manage All</a>
                </div>

                <% if (myPlans == null || myPlans.isEmpty()) { %>
                    <div class="empty-state">
                        <div class="empty-state-icon">📋</div>
                        <div class="empty-state-title">No Workout Plans Yet</div>
                        <p class="empty-state-desc">You have not created any training programs yet. Author your first structured curriculum for your trainees.</p>
                        <a href="<%= request.getContextPath() %>/trainer/workouts" class="btn btn-primary btn-sm" style="margin-top: 1rem;">+ Author First Plan</a>
                    </div>
                <% } else { %>
                    <div class="table-responsive">
                        <table class="custom-table">
                            <thead>
                                <tr>
                                    <th>Program Title</th>
                                    <th>Difficulty</th>
                                    <th>Duration</th>
                                    <th style="text-align: right;">Approval Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (WorkoutPlan p : myPlans) { %>
                                    <tr>
                                        <td>
                                            <strong style="color: #f1f5f9; display: block;"><%= p.getTitle() %></strong>
                                            <span style="font-size: 0.8rem; color: var(--text-dim);"><%= p.getExercises() != null ? p.getExercises().size() : 0 %> exercises included</span>
                                        </td>
                                        <td><span class="badge <%= p.getDifficultyBadgeClass() %>"><%= p.getDifficulty() %></span></td>
                                        <td><%= p.getDuration() %> Wks</td>
                                        <td style="text-align: right;">
                                            <span class="badge <%= p.getStatusBadgeClass() %>"><%= p.getStatus() %></span>
                                        </td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                <% } %>
            </div>

            <!-- Recent Trainee Interactions -->
            <div class="card">
                <div class="card-header">
                    <div>
                        <h2 class="card-title">Recent Inquiries</h2>
                        <p class="card-subtitle">Latest messages from trainees</p>
                    </div>
                    <a href="<%= request.getContextPath() %>/trainer/messages" class="btn btn-secondary btn-sm">Open Inbox</a>
                </div>

                <% if (recentMessages == null || recentMessages.isEmpty()) { %>
                    <div class="empty-state">
                        <div class="empty-state-icon">💬</div>
                        <div class="empty-state-title">Inbox Zero</div>
                        <p class="empty-state-desc">No direct inquiries from members at this moment. New consultation messages will appear here.</p>
                    </div>
                <% } else { %>
                    <div style="display: flex; flex-direction: column; gap: 0.85rem;">
                        <% for (Message m : recentMessages) { %>
                            <div style="background: rgba(15, 23, 42, 0.5); padding: 0.9rem; border-radius: var(--radius-sm); border: 1px solid var(--card-border);">
                                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.4rem;">
                                    <div style="display: flex; align-items: center; gap: 0.5rem;">
                                        <span style="display: inline-flex; width: 24px; height: 24px; border-radius: 50%; background: rgba(59, 130, 246, 0.2); color: #60a5fa; align-items: center; justify-content: center; font-size: 0.72rem; font-weight: 700;">
                                            <%= m.getSenderName() != null && !m.getSenderName().isEmpty() ? m.getSenderName().substring(0, 1).toUpperCase() : "U" %>
                                        </span>
                                        <strong style="font-size: 0.88rem; color: #f1f5f9;"><%= m.getSenderName() %></strong>
                                    </div>
                                    <span style="font-size: 0.75rem; color: var(--text-dim);"><%= m.getFormattedTimeIST() %></span>
                                </div>
                                <p style="font-size: 0.85rem; color: var(--text-secondary); line-height: 1.4; margin: 0;"><%= m.getMessage() %></p>
                            </div>
                        <% } %>
                    </div>
                <% } %>
            </div>
        </div>

        <!-- Assigned Trainees & Adherence Card -->
        <% 
            @SuppressWarnings("unchecked")
            List<com.fittrack.model.UserWorkoutPlan> enrolledTrainees = (List<com.fittrack.model.UserWorkoutPlan>) request.getAttribute("enrolledMembers");
            if (enrolledTrainees != null && !enrolledTrainees.isEmpty()) { 
        %>
            <div class="card" style="margin-bottom: 2rem;">
                <div class="card-header">
                    <div>
                        <h2 class="card-title">Assigned Trainees Adherence</h2>
                        <p class="card-subtitle">Weekly completion percentage of enrolled trainees</p>
                    </div>
                    <a href="<%= request.getContextPath() %>/trainer/workouts" class="btn btn-secondary btn-sm">Assign New Plan</a>
                </div>

                <div class="table-responsive">
                    <table class="custom-table">
                        <thead>
                            <tr>
                                <th>Trainee</th>
                                <th>Plan</th>
                                <th>Adherence Progress</th>
                                <th>Status</th>
                                <th style="text-align: right;">Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (com.fittrack.model.UserWorkoutPlan uwp : enrolledTrainees) { %>
                                <tr>
                                    <td>
                                        <strong style="color: #f1f5f9;"><%= uwp.getUserName() %></strong>
                                        <span style="display: block; font-size: 0.8rem; color: var(--text-dim);"><%= uwp.getUserEmail() %></span>
                                    </td>
                                    <td><%= uwp.getPlanTitle() %></td>
                                    <td style="min-width: 140px;">
                                        <div style="display: flex; justify-content: space-between; font-size: 0.8rem; margin-bottom: 0.25rem;">
                                            <span style="color: var(--emerald-400); font-weight: 600;"><%= uwp.getCompletionPercentage() %>%</span>
                                        </div>
                                        <div style="width: 100%; height: 6px; background: rgba(255,255,255,0.08); border-radius: 999px; overflow: hidden;">
                                            <div style="width: <%= uwp.getCompletionPercentage() %>%; height: 100%; background: linear-gradient(90deg, #10b981, #059669); border-radius: 999px;"></div>
                                        </div>
                                    </td>
                                    <td><span class="badge <%= "ACTIVE".equalsIgnoreCase(uwp.getStatus()) ? "badge-success" : "badge-secondary" %>"><%= uwp.getStatus() %></span></td>
                                    <td style="text-align: right;">
                                        <a href="<%= request.getContextPath() %>/trainer/messages?userId=<%= uwp.getUserId() %>" class="btn btn-secondary btn-sm">Message</a>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        <% } %>

    </div>

    <footer class="footer">
        <p>FitTrack Coach Portal &copy; 2026. Java Web &amp; PostgreSQL SaaS Platform.</p>
    </footer>

</body>
</html>
