<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.fittrack.model.User, com.fittrack.model.UserWorkoutPlan, com.fittrack.model.WorkoutPlan, com.fittrack.model.Progress" %>
<%@ page import="java.util.List, java.util.Map" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    UserWorkoutPlan activePlan = (UserWorkoutPlan) request.getAttribute("activePlan");
    List<WorkoutPlan> availablePlans = (List<WorkoutPlan>) request.getAttribute("availablePlans");
    Map<String, Object> progressSummary = (Map<String, Object>) request.getAttribute("progressSummary");
    Progress latestProgress = (Progress) request.getAttribute("latestProgress");
    Integer unreadNotifs = (Integer) request.getAttribute("unreadNotifs");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Member Dashboard - FitTrack</title>
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
            <li><a href="<%= request.getContextPath() %>/user/dashboard" class="nav-link active">Dashboard</a></li>
            <li><a href="<%= request.getContextPath() %>/user/workouts" class="nav-link">Workouts</a></li>
            <li><a href="<%= request.getContextPath() %>/user/progress" class="nav-link">My Progress</a></li>
            <li><a href="<%= request.getContextPath() %>/user/messages" class="nav-link">Coach Chat</a></li>
            <li>
                <a href="<%= request.getContextPath() %>/user/notifications" class="nav-link">
                    Notifications 
                    <% if (unreadNotifs != null && unreadNotifs > 0) { %>
                        <span class="badge badge-danger"><%= unreadNotifs %></span>
                    <% } %>
                </a>
            </li>
            <li><a href="<%= request.getContextPath() %>/logout" class="btn btn-secondary btn-sm">Logout</a></li>
        </ul>
    </nav>

    <div class="main-container">

        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem;">
            <div>
                <h1 style="font-size: 1.75rem; font-weight: 700;">Welcome, <%= currentUser != null ? currentUser.getName() : "Member" %>!</h1>
                <p style="color: var(--text-muted); font-size: 0.95rem;">
                    Role: <span class="badge badge-success">MEMBER</span> | Track your daily fitness and reach your potential.
                </p>
            </div>
            <div style="display: flex; gap: 0.5rem;">
                <a href="<%= request.getContextPath() %>/user/progress" class="btn btn-primary btn-sm">+ Log New Weight</a>
                <a href="<%= request.getContextPath() %>/user/workouts" class="btn btn-secondary btn-sm">Browse Workouts</a>
            </div>
        </div>

        <!-- 4 Metric Cards as per PRD Section 14 -->
        <div class="stats-grid">
            <div class="stat-card">
                <span class="stat-label">Current Weight</span>
                <span class="stat-value" style="color: #34d399;">
                    <%= latestProgress != null ? latestProgress.getWeight() + " kg" : "Not Logged" %>
                </span>
                <span class="stat-desc">
                    <%= latestProgress != null ? "Logged on " + latestProgress.getRecordDate() : "Record your first check-in" %>
                </span>
            </div>

            <div class="stat-card">
                <span class="stat-label">Net Weight Change</span>
                <span class="stat-value" style="color: #60a5fa;">
                    <% if (progressSummary != null && (Boolean) progressSummary.get("hasData")) { 
                        double net = (Double) progressSummary.get("netChange"); %>
                        <%= (net > 0 ? "+" : "") + net + " kg" %>
                    <% } else { %>
                        0.0 kg
                    <% } %>
                </span>
                <span class="stat-desc">Overall transformation delta</span>
            </div>

            <div class="stat-card">
                <span class="stat-label">Body Mass Index (BMI)</span>
                <span class="stat-value">
                    <%= (progressSummary != null && (Boolean) progressSummary.get("hasData")) ? progressSummary.get("currentBmi") : "N/A" %>
                </span>
                <span class="stat-desc">
                    Category: <span class="badge badge-primary"><%= (progressSummary != null && (Boolean) progressSummary.get("hasData")) ? progressSummary.get("bmiCategory") : "N/A" %></span>
                </span>
            </div>

            <div class="stat-card">
                <span class="stat-label">Available Plans</span>
                <span class="stat-value" style="color: #fbbf24;"><%= availablePlans != null ? availablePlans.size() : 0 %></span>
                <span class="stat-desc">Approved programs to explore</span>
            </div>
        </div>

        <!-- Active Workout Plan Banner -->
        <div class="card" style="border: 1px solid rgba(16, 185, 129, 0.4); background: linear-gradient(180deg, rgba(16, 185, 129, 0.08) 0%, rgba(30, 41, 59, 1) 100%);">
            <div class="card-header">
                <div>
                    <span class="badge badge-success" style="margin-bottom: 0.35rem;">Currently Active Program</span>
                    <h2 class="card-title" style="font-size: 1.35rem;">
                        <%= activePlan != null ? activePlan.getPlanTitle() : "No Active Program Selected" %>
                    </h2>
                </div>
                <% if (activePlan != null) { %>
                    <form action="<%= request.getContextPath() %>/user/workouts/complete" method="POST">
                        <input type="hidden" name="planId" value="<%= activePlan.getPlanId() %>">
                        <button type="submit" class="btn btn-success btn-sm">Mark Complete</button>
                    </form>
                <% } else { %>
                    <a href="<%= request.getContextPath() %>/user/workouts" class="btn btn-primary btn-sm">Choose a Plan</a>
                <% } %>
            </div>

            <% if (activePlan != null) { %>
                <div style="display: flex; gap: 2rem; flex-wrap: wrap; margin-top: 0.5rem;">
                    <div>
                        <span style="font-size: 0.8rem; color: var(--text-dim); display: block;">Coach:</span>
                        <strong><%= activePlan.getTrainerName() %></strong>
                    </div>
                    <div>
                        <span style="font-size: 0.8rem; color: var(--text-dim); display: block;">Difficulty:</span>
                        <span class="badge badge-warning"><%= activePlan.getDifficulty() %></span>
                    </div>
                    <div>
                        <span style="font-size: 0.8rem; color: var(--text-dim); display: block;">Program Length:</span>
                        <strong><%= activePlan.getDuration() %> Weeks</strong>
                    </div>
                    <div>
                        <span style="font-size: 0.8rem; color: var(--text-dim); display: block;">Started Date:</span>
                        <strong><%= activePlan.getEnrolledAt() != null ? activePlan.getEnrolledAt().toString().substring(0, 10) : "-" %></strong>
                    </div>
                </div>
            <% } else { %>
                <p style="color: var(--text-muted); padding: 0.5rem 0;">
                    You are not following any training schedule right now. Browse our library of certified programs to start building strength!
                </p>
            <% } %>
        </div>

        <!-- Available Workout Plans Section -->
        <div class="card">
            <div class="card-header">
                <h2 class="card-title">Featured Training Programs</h2>
                <a href="<%= request.getContextPath() %>/user/workouts" class="btn btn-secondary btn-sm">View All Plans</a>
            </div>

            <% if (availablePlans == null || availablePlans.isEmpty()) { %>
                <p style="color: var(--text-muted);">No approved workout plans currently available.</p>
            <% } else { %>
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 1.25rem;">
                    <% for (WorkoutPlan wp : availablePlans) { %>
                        <div style="background: rgba(15, 23, 42, 0.6); border: 1px solid var(--card-border); border-radius: var(--radius-md); padding: 1.25rem; display: flex; flex-direction: column; justify-content: space-between;">
                            <div>
                                <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 0.5rem;">
                                    <h3 style="font-size: 1.1rem; color: #fff;"><%= wp.getTitle() %></h3>
                                    <span class="badge <%= wp.getDifficultyBadgeClass() %>"><%= wp.getDifficulty() %></span>
                                </div>
                                <p style="font-size: 0.85rem; color: var(--text-muted); margin-bottom: 1rem;"><%= wp.getDescription() %></p>
                            </div>
                            <div style="border-top: 1px solid var(--card-border); padding-top: 0.85rem; display: flex; justify-content: space-between; align-items: center;">
                                <span style="font-size: 0.8rem; color: var(--text-dim);">By Coach <%= wp.getTrainerName() %></span>
                                <div style="display: flex; gap: 0.5rem;">
                                    <a href="<%= request.getContextPath() %>/user/workouts/details?id=<%= wp.getId() %>" class="btn btn-secondary btn-sm">Details</a>
                                    <form action="<%= request.getContextPath() %>/user/workouts/enroll" method="POST" style="display:inline;">
                                        <input type="hidden" name="planId" value="<%= wp.getId() %>">
                                        <button type="submit" class="btn btn-primary btn-sm">Follow Plan</button>
                                    </form>
                                </div>
                            </div>
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
