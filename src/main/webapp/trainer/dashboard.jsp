<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.fittrack.model.User, com.fittrack.model.WorkoutPlan, com.fittrack.model.Message" %>
<%@ page import="java.util.List" %>
<%
    User trainer = (User) session.getAttribute("currentUser");
    List<WorkoutPlan> myPlans = (List<WorkoutPlan>) request.getAttribute("myPlans");
    Long pendingCount = (Long) request.getAttribute("pendingCount");
    List<User> members = (List<User>) request.getAttribute("members");
    List<Message> recentMessages = (List<Message>) request.getAttribute("recentMessages");
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

        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem;">
            <div>
                <h1 style="font-size: 1.75rem; font-weight: 700;">Coach Command Center</h1>
                <p style="color: var(--text-muted); font-size: 0.95rem;">
                    Welcome back, <%= trainer != null ? trainer.getName() : "Coach" %>! 
                    Role: <span class="badge badge-primary">TRAINER</span>
                </p>
            </div>
            <div style="display: flex; gap: 0.5rem;">
                <a href="<%= request.getContextPath() %>/trainer/workouts" class="btn btn-primary btn-sm">+ New Workout Plan</a>
                <a href="<%= request.getContextPath() %>/trainer/progress" class="btn btn-secondary btn-sm">Review Trainees</a>
            </div>
        </div>

        <!-- 4 Metric Cards as per PRD Section 13 -->
        <div class="stats-grid">
            <div class="stat-card">
                <span class="stat-label">My Workout Plans</span>
                <span class="stat-value" style="color: #60a5fa;"><%= myPlans != null ? myPlans.size() : 0 %></span>
                <span class="stat-desc">Authored programs</span>
            </div>
            <div class="stat-card">
                <span class="stat-label">Pending Approval</span>
                <span class="stat-value" style="color: #fbbf24;"><%= pendingCount != null ? pendingCount : 0 %></span>
                <span class="stat-desc">Awaiting admin review</span>
            </div>
            <div class="stat-card">
                <span class="stat-label">Active Members</span>
                <span class="stat-value" style="color: #34d399;"><%= members != null ? members.size() : 0 %></span>
                <span class="stat-desc">Registered fitness trainees</span>
            </div>
            <div class="stat-card">
                <span class="stat-label">Recent Messages</span>
                <span class="stat-value"><%= recentMessages != null ? recentMessages.size() : 0 %></span>
                <span class="stat-desc">Direct trainee inquiries</span>
            </div>
        </div>

        <div style="display: grid; grid-template-columns: 3fr 2fr; gap: 1.5rem;">
            <!-- My Programs List -->
            <div class="card">
                <div class="card-header">
                    <h2 class="card-title">My Authored Programs</h2>
                    <a href="<%= request.getContextPath() %>/trainer/workouts" class="btn btn-primary btn-sm">Manage All</a>
                </div>

                <% if (myPlans == null || myPlans.isEmpty()) { %>
                    <p style="color: var(--text-muted);">You have not created any workout plans yet.</p>
                <% } else { %>
                    <div class="table-responsive">
                        <table class="custom-table">
                            <thead>
                                <tr>
                                    <th>Program Title</th>
                                    <th>Difficulty</th>
                                    <th>Duration</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (WorkoutPlan p : myPlans) { %>
                                    <tr>
                                        <td><strong><%= p.getTitle() %></strong></td>
                                        <td><span class="badge <%= p.getDifficultyBadgeClass() %>"><%= p.getDifficulty() %></span></td>
                                        <td><%= p.getDuration() %> Wks</td>
                                        <td><span class="badge <%= p.getStatusBadgeClass() %>"><%= p.getStatus() %></span></td>
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
                    <h2 class="card-title">Recent Inquiries</h2>
                    <a href="<%= request.getContextPath() %>/trainer/messages" class="btn btn-secondary btn-sm">Open Inbox</a>
                </div>

                <% if (recentMessages == null || recentMessages.isEmpty()) { %>
                    <p style="color: var(--text-muted);">No recent messages.</p>
                <% } else { %>
                    <div style="display: flex; flex-direction: column; gap: 0.75rem;">
                        <% for (Message m : recentMessages) { %>
                            <div style="background: rgba(255,255,255,0.02); padding: 0.75rem; border-radius: var(--radius-sm); border: 1px solid var(--card-border);">
                                <div style="display: flex; justify-content: space-between; margin-bottom: 0.25rem;">
                                    <strong style="font-size: 0.85rem;"><%= m.getSenderName() %></strong>
                                    <span style="font-size: 0.75rem; color: var(--text-dim);"><%= m.getCreatedAt() != null ? m.getCreatedAt().toString().substring(11, 16) : "" %></span>
                                </div>
                                <p style="font-size: 0.85rem; color: var(--text-muted);"><%= m.getMessage() %></p>
                            </div>
                        <% } %>
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
