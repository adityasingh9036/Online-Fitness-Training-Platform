<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.fittrack.model.WorkoutPlan, com.fittrack.model.UserWorkoutPlan" %>
<%@ page import="java.util.List" %>
<%
    List<WorkoutPlan> plans = (List<WorkoutPlan>) request.getAttribute("plans");
    List<UserWorkoutPlan> enrolledPlans = (List<UserWorkoutPlan>) request.getAttribute("enrolledPlans");
    UserWorkoutPlan activePlan = (UserWorkoutPlan) request.getAttribute("activePlan");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Workout Programs - FitTrack</title>
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
            <li><a href="<%= request.getContextPath() %>/user/workouts" class="nav-link active">Workouts</a></li>
            <li><a href="<%= request.getContextPath() %>/user/progress" class="nav-link">My Progress</a></li>
            <li><a href="<%= request.getContextPath() %>/user/messages" class="nav-link">Coach Chat</a></li>
            <li><a href="<%= request.getContextPath() %>/user/notifications" class="nav-link">Notifications</a></li>
            <li><a href="<%= request.getContextPath() %>/logout" class="btn btn-secondary btn-sm">Logout</a></li>
        </ul>
    </nav>

    <div class="main-container">

        <% if (request.getParameter("success") != null) { %>
            <div class="alert alert-success">
                <span><%= request.getParameter("success") %></span>
            </div>
        <% } %>

        <div style="margin-bottom: 2rem;">
            <h1 style="font-size: 1.75rem; font-weight: 700;">Workout Catalog</h1>
            <p style="color: var(--text-muted); font-size: 0.95rem;">Select and follow structured workout schedules curated by our coaching team.</p>
        </div>

        <!-- My Enrolled Plan History -->
        <% if (enrolledPlans != null && !enrolledPlans.isEmpty()) { %>
            <div class="card" style="margin-bottom: 2rem;">
                <div class="card-header">
                    <h2 class="card-title">My Enrolled Programs History</h2>
                </div>
                <div class="table-responsive">
                    <table class="custom-table">
                        <thead>
                            <tr>
                                <th>Plan Title</th>
                                <th>Trainer</th>
                                <th>Difficulty</th>
                                <th>Duration</th>
                                <th>Status</th>
                                <th>Enrolled Date</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (UserWorkoutPlan uwp : enrolledPlans) { %>
                                <tr>
                                    <td><strong><%= uwp.getPlanTitle() %></strong></td>
                                    <td><%= uwp.getTrainerName() %></td>
                                    <td><span class="badge badge-warning"><%= uwp.getDifficulty() %></span></td>
                                    <td><%= uwp.getDuration() %> Wks</td>
                                    <td>
                                        <span class="badge <%= "ACTIVE".equalsIgnoreCase(uwp.getStatus()) ? "badge-success" : "badge-primary" %>">
                                            <%= uwp.getStatus() %>
                                        </span>
                                    </td>
                                    <td><%= uwp.getEnrolledAt() != null ? uwp.getEnrolledAt().toString().substring(0, 10) : "-" %></td>
                                    <td>
                                        <div style="display: flex; gap: 0.5rem;">
                                            <a href="<%= request.getContextPath() %>/user/workouts/details?id=<%= uwp.getPlanId() %>" class="btn btn-secondary btn-sm">View Exercises</a>
                                            <% if ("ACTIVE".equalsIgnoreCase(uwp.getStatus())) { %>
                                                <form action="<%= request.getContextPath() %>/user/workouts/complete" method="POST" style="display:inline;">
                                                    <input type="hidden" name="planId" value="<%= uwp.getPlanId() %>">
                                                    <button type="submit" class="btn btn-success btn-sm">Complete</button>
                                                </form>
                                            <% } %>
                                        </div>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        <% } %>

        <!-- Catalog of Approved Workout Plans -->
        <div class="card">
            <div class="card-header">
                <h2 class="card-title">All Approved Programs (<%= plans != null ? plans.size() : 0 %>)</h2>
            </div>

            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 1.5rem;">
                <% if (plans != null) {
                    for (WorkoutPlan p : plans) { 
                        boolean isCurrent = (activePlan != null && activePlan.getPlanId() == p.getId());
                    %>
                    <div style="background: rgba(15, 23, 42, 0.7); border: 1px solid var(--card-border); border-radius: var(--radius-md); padding: 1.5rem; display: flex; flex-direction: column; justify-content: space-between;">
                        <div>
                            <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 0.5rem;">
                                <h3 style="font-size: 1.2rem; color: #fff;"><%= p.getTitle() %></h3>
                                <span class="badge <%= p.getDifficultyBadgeClass() %>"><%= p.getDifficulty() %></span>
                            </div>
                            <p style="font-size: 0.9rem; color: var(--text-muted); margin-bottom: 1rem;"><%= p.getDescription() %></p>
                            <div style="font-size: 0.85rem; color: #94a3b8; margin-bottom: 1rem;">
                                ⏱ <strong><%= p.getDuration() %> Weeks</strong> &bull; 🏋️ <strong><%= p.getExercises() != null ? p.getExercises().size() : 0 %> Exercises</strong>
                            </div>
                        </div>

                        <div style="border-top: 1px solid var(--card-border); padding-top: 1rem; display: flex; justify-content: space-between; align-items: center;">
                            <span style="font-size: 0.8rem; color: var(--text-dim);">Coach: <%= p.getTrainerName() %></span>
                            <div style="display: flex; gap: 0.5rem;">
                                <a href="<%= request.getContextPath() %>/user/workouts/details?id=<%= p.getId() %>" class="btn btn-secondary btn-sm">Exercises</a>
                                <% if (isCurrent) { %>
                                    <span class="badge badge-success">ACTIVE PLAN</span>
                                <% } else { %>
                                    <form action="<%= request.getContextPath() %>/user/workouts/enroll" method="POST" style="display:inline;">
                                        <input type="hidden" name="planId" value="<%= p.getId() %>">
                                        <button type="submit" class="btn btn-primary btn-sm">Follow Plan</button>
                                    </form>
                                <% } %>
                            </div>
                        </div>
                    </div>
                <%  }
                   } %>
            </div>
        </div>

    </div>

    <footer class="footer">
        <p>FitTrack Fitness Member Portal &copy; 2026.</p>
    </footer>

</body>
</html>
