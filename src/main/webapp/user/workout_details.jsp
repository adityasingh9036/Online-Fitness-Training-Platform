<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.fittrack.model.WorkoutPlan, com.fittrack.model.Exercise" %>
<%@ page import="java.util.Map" %>
<%
    WorkoutPlan plan = (WorkoutPlan) request.getAttribute("plan");
    @SuppressWarnings("unchecked")
    Map<String, Object> weeklyProgress = (Map<String, Object>) request.getAttribute("weeklyProgress");
    int progressPct = (weeklyProgress != null && weeklyProgress.containsKey("percentage")) ? (int) weeklyProgress.get("percentage") : 0;
    int completedWeekly = (weeklyProgress != null && weeklyProgress.containsKey("completedWeekly")) ? (int) weeklyProgress.get("completedWeekly") : 0;
    int totalExercises = (weeklyProgress != null && weeklyProgress.containsKey("totalExercises")) ? (int) weeklyProgress.get("totalExercises") : 0;
    int completedTodayCount = (weeklyProgress != null && weeklyProgress.containsKey("completedTodayCount")) ? (int) weeklyProgress.get("completedTodayCount") : 0;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= plan != null ? plan.getTitle() : "Workout Details" %> - FitTrack</title>
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

    <div class="main-container" style="max-width: 960px;">

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

        <div style="margin-bottom: 1.5rem;">
            <a href="<%= request.getContextPath() %>/user/workouts" style="font-size: 0.9rem; color: var(--text-muted);">&larr; Back to Workout Catalog</a>
        </div>

        <% if (plan != null) { %>
            <div class="card" style="margin-bottom: 2rem;">
                <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 1rem; flex-wrap: wrap; gap: 1rem;">
                    <div>
                        <div style="display: flex; gap: 0.5rem; align-items: center; margin-bottom: 0.5rem;">
                            <span class="badge <%= plan.getGoalBadgeClass() %>"><%= plan.getGoalType() %></span>
                            <span class="badge <%= plan.getDifficultyBadgeClass() %>"><%= plan.getDifficulty() %></span>
                        </div>
                        <h1 style="font-size: 2rem; font-weight: 700; color: #fff;"><%= plan.getTitle() %></h1>
                        <p style="color: var(--text-muted); font-size: 1rem; margin-top: 0.4rem;"><%= plan.getDescription() %></p>
                    </div>
                    <div>
                        <form action="<%= request.getContextPath() %>/user/workouts/enroll" method="POST">
                            <input type="hidden" name="planId" value="<%= plan.getId() %>">
                            <button type="submit" class="btn btn-primary">Enroll in this Program</button>
                        </form>
                    </div>
                </div>

                <div style="display: flex; gap: 2rem; border-top: 1px solid var(--card-border); padding-top: 1rem; margin-top: 1rem; flex-wrap: wrap;">
                    <div>
                        <span style="font-size: 0.8rem; color: var(--text-dim); display: block;">Coach:</span>
                        <strong><%= plan.getTrainerName() %></strong>
                    </div>
                    <div>
                        <span style="font-size: 0.8rem; color: var(--text-dim); display: block;">Program Duration:</span>
                        <strong><%= plan.getDuration() %> Weeks</strong>
                    </div>
                    <div>
                        <span style="font-size: 0.8rem; color: var(--text-dim); display: block;">Total Exercises:</span>
                        <strong><%= plan.getExercises() != null ? plan.getExercises().size() : 0 %> Routine Items</strong>
                    </div>
                </div>
            </div>

            <!-- Weekly Completion Progress Card -->
            <% if (weeklyProgress != null) { %>
            <div class="card" style="margin-bottom: 2rem; border-left: 4px solid var(--emerald-500);">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.75rem; flex-wrap: wrap; gap: 0.5rem;">
                    <div>
                        <h2 class="card-title" style="margin: 0; font-size: 1.15rem;">Weekly Routine Progress</h2>
                        <p style="color: var(--text-muted); font-size: 0.85rem; margin: 0.2rem 0 0 0;">
                            Track your exercise execution over the rolling 7-day period.
                        </p>
                    </div>
                    <div style="text-align: right;">
                        <span style="font-size: 1.5rem; font-weight: 700; color: var(--emerald-400);"><%= progressPct %>%</span>
                        <span style="font-size: 0.8rem; color: var(--text-muted); display: block;">Weekly Completion</span>
                    </div>
                </div>

                <!-- Progress Bar -->
                <div style="width: 100%; height: 10px; background: rgba(255,255,255,0.08); border-radius: 999px; overflow: hidden; margin-bottom: 1rem;">
                    <div style="width: <%= progressPct %>%; height: 100%; background: linear-gradient(90deg, #10b981, #059669); border-radius: 999px; transition: width 0.4s ease;"></div>
                </div>

                <div style="display: flex; gap: 1.5rem; font-size: 0.85rem; color: var(--text-dim); flex-wrap: wrap;">
                    <span>Completed this week: <strong style="color: #fff;"><%= completedWeekly %> / <%= totalExercises %> exercises</strong></span>
                    <span>Completed today: <strong style="color: #fff;"><%= completedTodayCount %> exercises</strong></span>
                </div>
            </div>
            <% } %>

            <!-- Exercises List -->
            <div class="card">
                <div class="card-header" style="display: flex; justify-content: space-between; align-items: center;">
                    <h2 class="card-title">Daily Exercises & Sets Execution</h2>
                    <span style="font-size: 0.85rem; color: var(--text-dim);">Mark items done as you complete each exercise</span>
                </div>

                <% if (plan.getExercises() == null || plan.getExercises().isEmpty()) { %>
                    <p style="color: var(--text-muted);">No exercises registered under this routine yet.</p>
                <% } else { %>
                    <div class="table-responsive">
                        <table class="custom-table">
                            <thead>
                                <tr>
                                    <th>#</th>
                                    <th>Exercise Name</th>
                                    <th>Muscle Group</th>
                                    <th>Sets</th>
                                    <th>Reps</th>
                                    <th>Rest / Duration</th>
                                    <th>Notes</th>
                                    <th style="text-align: right;">Daily Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% int idx = 1;
                                   for (Exercise ex : plan.getExercises()) { %>
                                    <tr>
                                        <td><%= idx++ %></td>
                                        <td>
                                            <strong style="color: #fff;"><%= ex.getName() %></strong>
                                        </td>
                                        <td><span class="badge badge-primary"><%= ex.getMuscleGroup() %></span></td>
                                        <td><strong><%= ex.getSets() %></strong> sets</td>
                                        <td><strong><%= ex.getReps() %></strong> reps</td>
                                        <td>
                                            <span style="color: var(--emerald-400); font-size: 0.85rem;">
                                                ⏱ <%= ex.getRestTimeFormatted() %>
                                            </span>
                                        </td>
                                        <td style="color: var(--text-muted); font-size: 0.85rem; max-width: 220px;"><%= ex.getDescription() != null ? ex.getDescription() : "-" %></td>
                                        <td style="text-align: right;">
                                            <% if (ex.isCompletedToday()) { %>
                                                <div style="display: inline-flex; align-items: center; gap: 0.4rem;">
                                                    <span class="badge badge-success" style="padding: 0.35rem 0.6rem;">✓ Done Today</span>
                                                    <form action="<%= request.getContextPath() %>/user/workouts/exercise/uncomplete" method="POST" style="display: inline; margin: 0;">
                                                        <input type="hidden" name="planId" value="<%= plan.getId() %>">
                                                        <input type="hidden" name="exerciseId" value="<%= ex.getId() %>">
                                                        <button type="submit" class="btn btn-secondary btn-sm" style="padding: 0.2rem 0.5rem; font-size: 0.75rem;" title="Undo completion">↺</button>
                                                    </form>
                                                </div>
                                            <% } else { %>
                                                <form action="<%= request.getContextPath() %>/user/workouts/exercise/complete" method="POST" style="display: inline; margin: 0;">
                                                    <input type="hidden" name="planId" value="<%= plan.getId() %>">
                                                    <input type="hidden" name="exerciseId" value="<%= ex.getId() %>">
                                                    <button type="submit" class="btn btn-primary btn-sm" style="padding: 0.35rem 0.75rem;">
                                                        ✓ Mark Done
                                                    </button>
                                                </form>
                                            <% } %>
                                        </td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                <% } %>
            </div>

        <% } else { %>
            <div class="card">
                <p style="color: var(--text-muted);">Workout plan not found.</p>
            </div>
        <% } %>

    </div>

    <footer class="footer">
        <p>FitTrack Fitness Member Portal &copy; 2026.</p>
    </footer>

</body>
</html>
