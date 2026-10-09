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
                <h1 class="page-title">Welcome, <%= currentUser != null ? currentUser.getName() : "Member" %>!</h1>
                <p class="page-subtitle">
                    Role: <span class="badge badge-success">MEMBER</span> | Track your daily fitness metrics and achieve your milestones.
                </p>
            </div>
            <div style="display: flex; gap: 0.5rem; flex-wrap: wrap;">
                <a href="<%= request.getContextPath() %>/user/progress" class="btn btn-primary btn-sm">+ Log New Weight</a>
                <a href="<%= request.getContextPath() %>/user/workouts" class="btn btn-secondary btn-sm">Browse Workouts</a>
            </div>
        </div>

        <!-- 4 Metric Cards with Consistent SaaS Icons -->
        <div class="stats-grid">
            <div class="stat-card stat-emerald">
                <div style="display: flex; justify-content: space-between; align-items: flex-start;">
                    <span class="stat-label">Current Weight</span>
                    <div class="stat-icon stat-icon-emerald">⚖️</div>
                </div>
                <span class="stat-value" style="color: #34d399;">
                    <%= latestProgress != null ? latestProgress.getWeight() + " kg" : "Not Logged" %>
                </span>
                <span class="stat-desc">
                    <%= latestProgress != null ? "Logged on " + latestProgress.getRecordDate() : "Record your first check-in" %>
                </span>
            </div>

            <div class="stat-card stat-blue">
                <div style="display: flex; justify-content: space-between; align-items: flex-start;">
                    <span class="stat-label">Net Weight Change</span>
                    <div class="stat-icon stat-icon-blue">📈</div>
                </div>
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

            <div class="stat-card stat-indigo">
                <div style="display: flex; justify-content: space-between; align-items: flex-start;">
                    <span class="stat-label">Body Mass Index (BMI)</span>
                    <div class="stat-icon stat-icon-indigo">🩺</div>
                </div>
                <span class="stat-value">
                    <%= (progressSummary != null && (Boolean) progressSummary.get("hasData")) ? progressSummary.get("currentBmi") : "N/A" %>
                </span>
                <span class="stat-desc">
                    Category: <span class="badge badge-primary"><%= (progressSummary != null && (Boolean) progressSummary.get("hasData")) ? progressSummary.get("bmiCategory") : "Pending Data" %></span>
                </span>
            </div>

            <div class="stat-card stat-amber">
                <div style="display: flex; justify-content: space-between; align-items: flex-start;">
                    <span class="stat-label">Available Programs</span>
                    <div class="stat-icon stat-icon-amber">🎯</div>
                </div>
                <span class="stat-value" style="color: #fbbf24;"><%= availablePlans != null ? availablePlans.size() : 0 %></span>
                <span class="stat-desc">Approved workouts to explore</span>
            </div>
        </div>

        <!-- Active Workout Plan Banner -->
        <div class="card" style="border: 1px solid rgba(16, 185, 129, 0.4); background: linear-gradient(180deg, rgba(16, 185, 129, 0.08) 0%, rgba(30, 41, 59, 1) 100%);">
            <div class="card-header">
                <div>
                    <span class="badge badge-success" style="margin-bottom: 0.35rem;">Active Training Program</span>
                    <h2 class="card-title" style="font-size: 1.35rem;">
                        <%= activePlan != null ? activePlan.getPlanTitle() : "No Active Program Selected" %>
                    </h2>
                </div>
                <div style="display: flex; gap: 0.5rem; align-items: center;">
                    <% if (activePlan != null) { %>
                        <a href="<%= request.getContextPath() %>/user/workouts/details?id=<%= activePlan.getPlanId() %>" class="btn btn-primary btn-sm">
                            🏋️ Daily Exercises
                        </a>
                        <form action="<%= request.getContextPath() %>/user/workouts/complete" method="POST" style="margin: 0; display: inline;">
                            <input type="hidden" name="planId" value="<%= activePlan.getPlanId() %>">
                            <button type="submit" class="btn btn-secondary btn-sm" onclick="return confirm('Complete this workout program?');">Mark Complete</button>
                        </form>
                    <% } else { %>
                        <a href="<%= request.getContextPath() %>/user/workouts" class="btn btn-primary btn-sm">Explore Programs</a>
                    <% } %>
                </div>
            </div>

            <% if (activePlan != null) { 
                @SuppressWarnings("unchecked")
                Map<String, Object> actProg = (Map<String, Object>) request.getAttribute("activePlanProgress");
                int actPct = (actProg != null && actProg.containsKey("percentage")) ? (int) actProg.get("percentage") : 0;
                int actComp = (actProg != null && actProg.containsKey("completedWeekly")) ? (int) actProg.get("completedWeekly") : 0;
                int actTot = (actProg != null && actProg.containsKey("totalExercises")) ? (int) actProg.get("totalExercises") : 0;
            %>
                <div style="display: flex; gap: 2.5rem; flex-wrap: wrap; margin-top: 0.5rem; padding-top: 0.5rem;">
                    <div>
                        <span style="font-size: 0.78rem; color: var(--text-dim); text-transform: uppercase; letter-spacing: 0.04em; display: block;">Coach</span>
                        <strong style="color: #f1f5f9;"><%= activePlan.getTrainerName() %></strong>
                    </div>
                    <div>
                        <span style="font-size: 0.78rem; color: var(--text-dim); text-transform: uppercase; letter-spacing: 0.04em; display: block;">Intensity</span>
                        <span class="badge badge-warning"><%= activePlan.getDifficulty() %></span>
                    </div>
                    <div>
                        <span style="font-size: 0.78rem; color: var(--text-dim); text-transform: uppercase; letter-spacing: 0.04em; display: block;">Duration</span>
                        <strong style="color: #f1f5f9;"><%= activePlan.getDuration() %> Weeks</strong>
                    </div>
                    <div>
                        <span style="font-size: 0.78rem; color: var(--text-dim); text-transform: uppercase; letter-spacing: 0.04em; display: block;">Enrolled Date</span>
                        <strong style="color: #f1f5f9;"><%= activePlan.getEnrolledAt() != null ? activePlan.getEnrolledAt().toString().substring(0, 10) : "-" %></strong>
                    </div>
                </div>

                <!-- Weekly Completion Bar -->
                <div style="margin-top: 1rem; border-top: 1px solid rgba(255, 255, 255, 0.08); padding-top: 0.85rem;">
                    <div style="display: flex; justify-content: space-between; font-size: 0.82rem; margin-bottom: 0.4rem;">
                        <span style="color: var(--text-muted);">Weekly Routine Progress</span>
                        <strong style="color: var(--emerald-400);"><%= actPct %>% (<%= actComp %> of <%= actTot %> exercises done this week)</strong>
                    </div>
                    <div style="width: 100%; height: 7px; background: rgba(255, 255, 255, 0.08); border-radius: 999px; overflow: hidden;">
                        <div style="width: <%= actPct %>%; height: 100%; background: linear-gradient(90deg, #10b981, #059669); border-radius: 999px;"></div>
                    </div>
                </div>
            <% } else { %>
                <div class="empty-state" style="padding: 1.5rem 1rem;">
                    <div class="empty-state-icon">🏃</div>
                    <div class="empty-state-title">No Active Workout Enrolled</div>
                    <p class="empty-state-desc">You are not following an active fitness routine right now. Choose a structured workout plan designed by our coaches to stay consistent.</p>
                    <a href="<%= request.getContextPath() %>/user/workouts" class="btn btn-primary btn-sm" style="margin-top: 0.75rem;">Browse Programs Catalog</a>
                </div>
            <% } %>
        </div>

        <!-- Available Workout Plans Section -->
        <div class="card">
            <div class="card-header">
                <div>
                    <h2 class="card-title">Featured Training Programs</h2>
                    <p class="card-subtitle">Recommended training routines by certified fitness trainers</p>
                </div>
                <a href="<%= request.getContextPath() %>/user/workouts" class="btn btn-secondary btn-sm">View All Plans</a>
            </div>

            <% if (availablePlans == null || availablePlans.isEmpty()) { %>
                <div class="empty-state">
                    <div class="empty-state-icon">📋</div>
                    <div class="empty-state-title">No Workout Plans Available</div>
                    <p class="empty-state-desc">There are no approved workout plans in the library yet. Please check back shortly.</p>
                </div>
            <% } else { %>
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 1.25rem;">
                    <% for (WorkoutPlan wp : availablePlans) { %>
                        <div style="background: rgba(15, 23, 42, 0.6); border: 1px solid var(--card-border); border-radius: var(--radius-md); padding: 1.25rem; display: flex; flex-direction: column; justify-content: space-between; transition: transform 0.2s ease, border-color 0.2s ease;">
                            <div>
                                <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 0.5rem;">
                                    <h3 style="font-size: 1.1rem; color: #fff; font-weight: 600;"><%= wp.getTitle() %></h3>
                                    <span class="badge <%= wp.getDifficultyBadgeClass() %>"><%= wp.getDifficulty() %></span>
                                </div>
                                <p style="font-size: 0.86rem; color: var(--text-muted); line-height: 1.5; margin-bottom: 1.25rem;"><%= wp.getDescription() %></p>
                            </div>
                            <div style="border-top: 1px solid var(--card-border); padding-top: 0.85rem; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 0.5rem;">
                                <span style="font-size: 0.82rem; color: var(--text-dim); display: flex; align-items: center; gap: 0.35rem;">
                                    <span>🏋️</span> Coach <%= wp.getTrainerName() %>
                                </span>
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
        <p>FitTrack Fitness Member Portal &copy; 2026. Java Web &amp; PostgreSQL SaaS Platform.</p>
    </footer>

</body>
</html>
