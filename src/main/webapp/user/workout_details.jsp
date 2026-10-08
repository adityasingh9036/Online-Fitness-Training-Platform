<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.fittrack.model.WorkoutPlan, com.fittrack.model.Exercise" %>
<%
    WorkoutPlan plan = (WorkoutPlan) request.getAttribute("plan");
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
            <li><a href="<%= request.getContextPath() %>/logout" class="btn btn-secondary btn-sm">Logout</a></li>
        </ul>
    </nav>

    <div class="main-container" style="max-width: 900px;">

        <div style="margin-bottom: 1.5rem;">
            <a href="<%= request.getContextPath() %>/user/workouts" style="font-size: 0.9rem; color: var(--text-muted);">&larr; Back to Workout Catalog</a>
        </div>

        <% if (plan != null) { %>
            <div class="card" style="margin-bottom: 2rem;">
                <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 1rem;">
                    <div>
                        <h1 style="font-size: 2rem; font-weight: 700; color: #fff;"><%= plan.getTitle() %></h1>
                        <p style="color: var(--text-muted); font-size: 1rem; margin-top: 0.4rem;"><%= plan.getDescription() %></p>
                    </div>
                    <span class="badge <%= plan.getDifficultyBadgeClass() %>" style="font-size: 0.9rem; padding: 0.4rem 0.8rem;">
                        <%= plan.getDifficulty() %>
                    </span>
                </div>

                <div style="display: flex; gap: 2rem; border-top: 1px solid var(--card-border); padding-top: 1rem; margin-top: 1rem;">
                    <div>
                        <span style="font-size: 0.8rem; color: var(--text-dim); display: block;">Coach:</span>
                        <strong><%= plan.getTrainerName() %></strong>
                    </div>
                    <div>
                        <span style="font-size: 0.8rem; color: var(--text-dim); display: block;">Program Duration:</span>
                        <strong><%= plan.getDuration() %> Weeks</strong>
                    </div>
                    <div>
                        <span style="font-size: 0.8rem; color: var(--text-dim); display: block;">Exercise Count:</span>
                        <strong><%= plan.getExercises() != null ? plan.getExercises().size() : 0 %> Routine Items</strong>
                    </div>
                </div>

                <div style="margin-top: 1.5rem;">
                    <form action="<%= request.getContextPath() %>/user/workouts/enroll" method="POST">
                        <input type="hidden" name="planId" value="<%= plan.getId() %>">
                        <button type="submit" class="btn btn-primary">Enroll in this Program</button>
                    </form>
                </div>
            </div>

            <!-- Exercises List -->
            <div class="card">
                <div class="card-header">
                    <h2 class="card-title">Constituent Exercises & Sets</h2>
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
                                    <th>Volume / Sets</th>
                                    <th>Reps</th>
                                    <th>Form Notes</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% int idx = 1;
                                   for (Exercise ex : plan.getExercises()) { %>
                                    <tr>
                                        <td><%= idx++ %></td>
                                        <td><strong><%= ex.getName() %></strong></td>
                                        <td><span class="badge badge-primary"><%= ex.getMuscleGroup() %></span></td>
                                        <td><%= ex.getSets() %> Sets</td>
                                        <td><%= ex.getReps() %> Reps</td>
                                        <td style="color: var(--text-muted); font-size: 0.85rem;"><%= ex.getDescription() %></td>
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
