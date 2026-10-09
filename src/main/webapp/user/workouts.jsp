<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.fittrack.model.WorkoutPlan, com.fittrack.model.UserWorkoutPlan" %>
<%@ page import="java.util.List, java.util.Map" %>
<%
    List<WorkoutPlan> plans = (List<WorkoutPlan>) request.getAttribute("plans");
    List<UserWorkoutPlan> enrolledPlans = (List<UserWorkoutPlan>) request.getAttribute("enrolledPlans");
    UserWorkoutPlan activePlan = (UserWorkoutPlan) request.getAttribute("activePlan");
    @SuppressWarnings("unchecked")
    Map<String, Object> activePlanProgress = (Map<String, Object>) request.getAttribute("activePlanProgress");
    String selectedGoal = (String) request.getAttribute("selectedGoal");
    if (selectedGoal == null) selectedGoal = "ALL";
    String userFitnessGoal = (String) request.getAttribute("userFitnessGoal");
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
            <div class="alert alert-success" style="margin-bottom: 1.5rem;">
                <span><%= request.getParameter("success") %></span>
            </div>
        <% } %>
        <% if (request.getParameter("error") != null) { %>
            <div class="alert alert-danger" style="margin-bottom: 1.5rem;">
                <span><%= request.getParameter("error") %></span>
            </div>
        <% } %>

        <div style="margin-bottom: 2rem; display: flex; justify-content: space-between; align-items: flex-end; flex-wrap: wrap; gap: 1rem;">
            <div>
                <h1 style="font-size: 1.75rem; font-weight: 700;">Workout Planner & Catalog</h1>
                <p style="color: var(--text-muted); font-size: 0.95rem;">Structured routines, daily exercise checklists, and goal-tailored progression.</p>
            </div>
            <% if (userFitnessGoal != null && !userFitnessGoal.isEmpty()) { %>
                <div style="background: rgba(16, 185, 129, 0.1); border: 1px solid rgba(16, 185, 129, 0.3); border-radius: var(--radius-md); padding: 0.5rem 1rem; font-size: 0.85rem;">
                    <span style="color: var(--text-muted);">Your Fitness Goal:</span> <strong style="color: var(--emerald-400);"><%= userFitnessGoal %></strong>
                </div>
            <% } %>
        </div>

        <!-- Active Plan Spotlight Card -->
        <% if (activePlan != null) { 
            int actPct = (activePlanProgress != null && activePlanProgress.containsKey("percentage")) ? (int) activePlanProgress.get("percentage") : 0;
            int actComp = (activePlanProgress != null && activePlanProgress.containsKey("completedWeekly")) ? (int) activePlanProgress.get("completedWeekly") : 0;
            int actTot = (activePlanProgress != null && activePlanProgress.containsKey("totalExercises")) ? (int) activePlanProgress.get("totalExercises") : 0;
        %>
            <div class="card" style="margin-bottom: 2rem; border-left: 4px solid var(--emerald-500); background: linear-gradient(180deg, rgba(30, 41, 59, 0.9), rgba(15, 23, 42, 0.95));">
                <div style="display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 1rem; margin-bottom: 1rem;">
                    <div>
                        <span class="badge badge-success" style="margin-bottom: 0.5rem;">CURRENT ACTIVE PROGRAM</span>
                        <h2 style="font-size: 1.5rem; font-weight: 700; color: #fff;"><%= activePlan.getPlanTitle() %></h2>
                        <p style="color: var(--text-muted); font-size: 0.9rem; margin-top: 0.25rem;">
                            Coach: <strong><%= activePlan.getTrainerName() %></strong> &bull; 
                            Difficulty: <span class="badge badge-warning"><%= activePlan.getDifficulty() %></span> &bull; 
                            Duration: <strong><%= activePlan.getDuration() %> Weeks</strong>
                        </p>
                    </div>
                    <div style="display: flex; gap: 0.5rem; align-items: center;">
                        <a href="<%= request.getContextPath() %>/user/workouts/details?id=<%= activePlan.getPlanId() %>" class="btn btn-primary">
                            🏋️ View Daily Exercises
                        </a>
                        <form action="<%= request.getContextPath() %>/user/workouts/complete" method="POST" style="display: inline; margin: 0;">
                            <input type="hidden" name="planId" value="<%= activePlan.getPlanId() %>">
                            <button type="submit" class="btn btn-secondary btn-sm" onclick="return confirm('Complete this workout program?');">
                                Mark Program Completed
                            </button>
                        </form>
                    </div>
                </div>

                <!-- Weekly Completion Bar -->
                <div style="border-top: 1px solid var(--card-border); padding-top: 1rem;">
                    <div style="display: flex; justify-content: space-between; font-size: 0.85rem; margin-bottom: 0.4rem;">
                        <span style="color: var(--text-muted);">Weekly Routine Completion</span>
                        <strong style="color: var(--emerald-400);"><%= actPct %>% (<%= actComp %> of <%= actTot %> distinct exercises completed this week)</strong>
                    </div>
                    <div style="width: 100%; height: 8px; background: rgba(255,255,255,0.08); border-radius: 999px; overflow: hidden;">
                        <div style="width: <%= actPct %>%; height: 100%; background: linear-gradient(90deg, #10b981, #059669); border-radius: 999px;"></div>
                    </div>
                </div>
            </div>
        <% } %>

        <!-- Filter by Goal Tabs -->
        <div style="display: flex; gap: 0.5rem; margin-bottom: 1.5rem; flex-wrap: wrap; align-items: center;">
            <span style="font-size: 0.85rem; color: var(--text-muted); margin-right: 0.5rem;">Filter by Goal:</span>
            <a href="<%= request.getContextPath() %>/user/workouts?goal=ALL" class="btn btn-sm <%= "ALL".equalsIgnoreCase(selectedGoal) ? "btn-primary" : "btn-secondary" %>">All Programs</a>
            <a href="<%= request.getContextPath() %>/user/workouts?goal=Muscle Gain" class="btn btn-sm <%= "Muscle Gain".equalsIgnoreCase(selectedGoal) ? "btn-primary" : "btn-secondary" %>">Muscle Gain</a>
            <a href="<%= request.getContextPath() %>/user/workouts?goal=Weight Loss %26 Conditioning" class="btn btn-sm <%= "Weight Loss & Conditioning".equalsIgnoreCase(selectedGoal) ? "btn-primary" : "btn-secondary" %>">Weight Loss & Conditioning</a>
            <a href="<%= request.getContextPath() %>/user/workouts?goal=Strength %26 Power" class="btn btn-sm <%= "Strength & Power".equalsIgnoreCase(selectedGoal) ? "btn-primary" : "btn-secondary" %>">Strength & Power</a>
            <a href="<%= request.getContextPath() %>/user/workouts?goal=General Fitness" class="btn btn-sm <%= "General Fitness".equalsIgnoreCase(selectedGoal) ? "btn-primary" : "btn-secondary" %>">General Fitness</a>
        </div>

        <!-- Catalog of Approved Workout Plans -->
        <div class="card" style="margin-bottom: 2rem;">
            <div class="card-header">
                <h2 class="card-title">Approved Training Programs (<%= plans != null ? plans.size() : 0 %>)</h2>
            </div>

            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 1.5rem;">
                <% if (plans != null && !plans.isEmpty()) {
                    for (WorkoutPlan p : plans) { 
                        boolean isCurrent = (activePlan != null && activePlan.getPlanId() == p.getId());
                        boolean matchesUserGoal = (userFitnessGoal != null && p.matchesGoal(userFitnessGoal));
                    %>
                    <div style="background: rgba(15, 23, 42, 0.7); border: 1px solid <%= isCurrent ? "var(--emerald-500)" : "var(--card-border)" %>; border-radius: var(--radius-md); padding: 1.5rem; display: flex; flex-direction: column; justify-content: space-between;">
                        <div>
                            <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 0.5rem; gap: 0.5rem; flex-wrap: wrap;">
                                <div style="display: flex; gap: 0.4rem; flex-wrap: wrap;">
                                    <span class="badge <%= p.getGoalBadgeClass() %>"><%= p.getGoalType() %></span>
                                    <span class="badge <%= p.getDifficultyBadgeClass() %>"><%= p.getDifficulty() %></span>
                                    <% if (matchesUserGoal) { %>
                                        <span class="badge badge-success" style="font-size: 0.75rem;">🎯 Goal Match</span>
                                    <% } %>
                                </div>
                            </div>
                            <h3 style="font-size: 1.2rem; color: #fff; margin-bottom: 0.4rem;"><%= p.getTitle() %></h3>
                            <p style="font-size: 0.88rem; color: var(--text-muted); margin-bottom: 1rem; line-height: 1.4;"><%= p.getDescription() %></p>
                            <div style="font-size: 0.82rem; color: #94a3b8; margin-bottom: 1rem;">
                                ⏱ <strong><%= p.getDuration() %> Weeks</strong> &bull; 🏋️ <strong><%= p.getExercises() != null ? p.getExercises().size() : 0 %> Exercises</strong>
                            </div>
                        </div>

                        <div style="border-top: 1px solid var(--card-border); padding-top: 1rem; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 0.5rem;">
                            <span style="font-size: 0.8rem; color: var(--text-dim);">Coach: <%= p.getTrainerName() %></span>
                            <div style="display: flex; gap: 0.5rem; align-items: center;">
                                <a href="<%= request.getContextPath() %>/user/workouts/details?id=<%= p.getId() %>" class="btn btn-secondary btn-sm">Exercises</a>
                                <% if (isCurrent) { %>
                                    <span class="badge badge-success">ACTIVE</span>
                                <% } else { %>
                                    <form action="<%= request.getContextPath() %>/user/workouts/enroll" method="POST" style="display:inline; margin: 0;">
                                        <input type="hidden" name="planId" value="<%= p.getId() %>">
                                        <button type="submit" class="btn btn-primary btn-sm">Enroll Plan</button>
                                    </form>
                                <% } %>
                            </div>
                        </div>
                    </div>
                <%  }
                   } else { %>
                    <p style="color: var(--text-muted); padding: 1rem 0;">No workout plans match the selected fitness goal filter.</p>
                <% } %>
            </div>
        </div>

        <!-- My Enrolled Plan History -->
        <% if (enrolledPlans != null && !enrolledPlans.isEmpty()) { %>
            <div class="card">
                <div class="card-header">
                    <h2 class="card-title">Enrollment History</h2>
                </div>
                <div class="table-responsive">
                    <table class="custom-table">
                        <thead>
                            <tr>
                                <th>Plan Title</th>
                                <th>Coach</th>
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
                                        <span class="badge <%= "ACTIVE".equalsIgnoreCase(uwp.getStatus()) ? "badge-success" : "badge-secondary" %>">
                                            <%= uwp.getStatus() %>
                                        </span>
                                    </td>
                                    <td><%= uwp.getEnrolledAt() != null ? uwp.getEnrolledAt().toString().substring(0, 10) : "-" %></td>
                                    <td>
                                        <div style="display: flex; gap: 0.5rem;">
                                            <a href="<%= request.getContextPath() %>/user/workouts/details?id=<%= uwp.getPlanId() %>" class="btn btn-secondary btn-sm">Daily Exercises</a>
                                            <% if ("ACTIVE".equalsIgnoreCase(uwp.getStatus())) { %>
                                                <form action="<%= request.getContextPath() %>/user/workouts/complete" method="POST" style="display:inline; margin: 0;">
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

    </div>

    <footer class="footer">
        <p>FitTrack Fitness Member Portal &copy; 2026.</p>
    </footer>

</body>
</html>
