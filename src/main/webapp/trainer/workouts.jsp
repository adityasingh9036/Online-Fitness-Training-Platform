<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.fittrack.model.WorkoutPlan, com.fittrack.model.Exercise, com.fittrack.model.User, com.fittrack.model.UserWorkoutPlan" %>
<%@ page import="java.util.List" %>
<%
    List<WorkoutPlan> myPlans = (List<WorkoutPlan>) request.getAttribute("myPlans");
    List<Exercise> exercises = (List<Exercise>) request.getAttribute("exercises");
    List<User> members = (List<User>) request.getAttribute("members");
    List<UserWorkoutPlan> enrolledMembers = (List<UserWorkoutPlan>) request.getAttribute("enrolledMembers");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Workout Programs - FitTrack Coach</title>
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
            <li><a href="<%= request.getContextPath() %>/trainer/dashboard" class="nav-link">Dashboard</a></li>
            <li><a href="<%= request.getContextPath() %>/trainer/workouts" class="nav-link active">Workouts</a></li>
            <li><a href="<%= request.getContextPath() %>/trainer/progress" class="nav-link">Trainee Progress</a></li>
            <li><a href="<%= request.getContextPath() %>/trainer/messages" class="nav-link">Messages</a></li>
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

        <div style="margin-bottom: 2rem;">
            <h1 style="font-size: 1.75rem; font-weight: 700;">Workout Planner Management</h1>
            <p style="color: var(--text-muted); font-size: 0.95rem;">Author custom routines, manage exercise catalogs, and assign plans directly to your members.</p>
        </div>

        <!-- 3-Column Action Grid: Create Plan, Add Exercise, Assign to Member -->
        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 1.5rem; margin-bottom: 2rem;">
            
            <!-- Create Workout Plan Form -->
            <div class="card">
                <div class="card-header">
                    <h2 class="card-title">Create Workout Plan</h2>
                </div>

                <form action="<%= request.getContextPath() %>/trainer/workouts" method="POST">
                    <input type="hidden" name="action" value="create_workout">

                    <div class="form-group">
                        <label class="form-label" for="title">Program Title</label>
                        <input type="text" id="title" name="title" class="form-control" required placeholder="e.g. Upper Body Blast">
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="description">Description & Focus</label>
                        <textarea id="description" name="description" class="form-control" rows="2" required placeholder="Brief outline of goals and training style"></textarea>
                    </div>

                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem;">
                        <div class="form-group">
                            <label class="form-label" for="difficulty">Difficulty Level</label>
                            <select id="difficulty" name="difficulty" class="form-control" required>
                                <option value="BEGINNER">BEGINNER</option>
                                <option value="INTERMEDIATE">INTERMEDIATE</option>
                                <option value="ADVANCED">ADVANCED</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="duration">Duration (Weeks)</label>
                            <input type="number" id="duration" name="duration" class="form-control" min="1" max="52" value="4" required>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Include Exercises in Plan</label>
                        <div style="max-height: 120px; overflow-y: auto; background: #0f172a; padding: 0.75rem; border: 1px solid var(--card-border); border-radius: var(--radius-sm);">
                            <% if (exercises != null) {
                                for (Exercise ex : exercises) { %>
                                <label style="display: block; margin-bottom: 0.4rem; font-size: 0.85rem; color: #cbd5e1; cursor: pointer;">
                                    <input type="checkbox" name="exerciseIds" value="<%= ex.getId() %>" style="margin-right: 0.5rem;">
                                    <strong><%= ex.getName() %></strong> (<%= ex.getMuscleGroup() %> - <%= ex.getSets() %>×<%= ex.getReps() %>)
                                </label>
                            <%  }
                               } %>
                        </div>
                    </div>

                    <button type="submit" class="btn btn-primary" style="width: 100%;">Submit for Approval</button>
                </form>
            </div>

            <!-- Add Exercise to Library Form -->
            <div class="card">
                <div class="card-header">
                    <h2 class="card-title">Add Exercise to Catalog</h2>
                </div>

                <form action="<%= request.getContextPath() %>/trainer/workouts" method="POST">
                    <input type="hidden" name="action" value="create_exercise">

                    <div class="form-group">
                        <label class="form-label" for="exName">Exercise Name</label>
                        <input type="text" id="exName" name="name" class="form-control" required placeholder="e.g. Incline Dumbbell Press">
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="muscleGroup">Target Muscle Group</label>
                        <select id="muscleGroup" name="muscleGroup" class="form-control" required>
                            <option value="Chest">Chest</option>
                            <option value="Back">Back</option>
                            <option value="Legs">Legs</option>
                            <option value="Shoulders">Shoulders</option>
                            <option value="Arms">Arms</option>
                            <option value="Core">Core</option>
                            <option value="Full Body">Full Body</option>
                        </select>
                    </div>

                    <div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 0.5rem;">
                        <div class="form-group">
                            <label class="form-label" for="sets">Sets</label>
                            <input type="number" id="sets" name="sets" class="form-control" value="3" min="1" required>
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="reps">Reps</label>
                            <input type="number" id="reps" name="reps" class="form-control" value="10" min="1" required>
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="durationSec">Rest (s)</label>
                            <input type="number" id="durationSec" name="duration" class="form-control" value="60" min="0" required>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="exDesc">Form Description</label>
                        <input type="text" id="exDesc" name="description" class="form-control" placeholder="Key cues for proper technique">
                    </div>

                    <button type="submit" class="btn btn-secondary" style="width: 100%;">Add to Catalog</button>
                </form>
            </div>

            <!-- Assign Plan to Trainee Form -->
            <div class="card">
                <div class="card-header">
                    <h2 class="card-title">Assign Plan to Trainee</h2>
                </div>

                <form action="<%= request.getContextPath() %>/trainer/workouts" method="POST">
                    <input type="hidden" name="action" value="assign_plan">

                    <div class="form-group">
                        <label class="form-label" for="memberId">Select Trainee / Member</label>
                        <select id="memberId" name="memberId" class="form-control" required>
                            <option value="">-- Choose Member --</option>
                            <% if (members != null) {
                                for (User m : members) { %>
                                <option value="<%= m.getId() %>"><%= m.getName() %> (<%= m.getEmail() %>)</option>
                            <%  }
                               } %>
                        </select>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="planId">Select Workout Program</label>
                        <select id="planId" name="planId" class="form-control" required>
                            <option value="">-- Choose Program --</option>
                            <% if (myPlans != null) {
                                for (WorkoutPlan p : myPlans) { %>
                                <option value="<%= p.getId() %>"><%= p.getTitle() %> (<%= p.getDifficulty() %> - <%= p.getStatus() %>)</option>
                            <%  }
                               } %>
                        </select>
                        <span style="font-size: 0.78rem; color: var(--text-dim); margin-top: 0.25rem; display: block;">
                            The trainee will receive an instant notification upon assignment.
                        </span>
                    </div>

                    <div style="margin-top: 2rem;">
                        <button type="submit" class="btn btn-primary" style="width: 100%;">Assign Plan to Trainee</button>
                    </div>
                </form>
            </div>

        </div>

        <!-- Assigned Trainees & Weekly Progress -->
        <div class="card" style="margin-bottom: 2rem;">
            <div class="card-header">
                <div>
                    <h2 class="card-title">Assigned Trainees & Progress (<%= enrolledMembers != null ? enrolledMembers.size() : 0 %>)</h2>
                    <p class="card-subtitle">Active trainees following your training programs with weekly exercise adherence</p>
                </div>
            </div>

            <div class="table-responsive">
                <table class="custom-table">
                    <thead>
                        <tr>
                            <th>Trainee Name</th>
                            <th>Assigned Plan</th>
                            <th>Difficulty</th>
                            <th>Weekly Progress</th>
                            <th>Status</th>
                            <th>Enrolled Date</th>
                            <th style="text-align: right;">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (enrolledMembers != null && !enrolledMembers.isEmpty()) {
                            for (UserWorkoutPlan uwp : enrolledMembers) { %>
                            <tr>
                                <td>
                                    <strong style="color: #f1f5f9; display: block;"><%= uwp.getUserName() %></strong>
                                    <span style="font-size: 0.8rem; color: var(--text-dim);"><%= uwp.getUserEmail() %></span>
                                </td>
                                <td><strong><%= uwp.getPlanTitle() %></strong></td>
                                <td><span class="badge badge-warning"><%= uwp.getDifficulty() %></span></td>
                                <td style="min-width: 160px;">
                                    <div style="display: flex; justify-content: space-between; font-size: 0.8rem; margin-bottom: 0.25rem;">
                                        <span style="color: var(--emerald-400); font-weight: 600;"><%= uwp.getCompletionPercentage() %>%</span>
                                    </div>
                                    <div style="width: 100%; height: 6px; background: rgba(255,255,255,0.08); border-radius: 999px; overflow: hidden;">
                                        <div style="width: <%= uwp.getCompletionPercentage() %>%; height: 100%; background: linear-gradient(90deg, #10b981, #059669); border-radius: 999px;"></div>
                                    </div>
                                </td>
                                <td>
                                    <span class="badge <%= "ACTIVE".equalsIgnoreCase(uwp.getStatus()) ? "badge-success" : "badge-secondary" %>">
                                        <%= uwp.getStatus() %>
                                    </span>
                                </td>
                                <td><%= uwp.getEnrolledAt() != null ? uwp.getEnrolledAt().toString().substring(0, 10) : "-" %></td>
                                <td style="text-align: right;">
                                    <a href="<%= request.getContextPath() %>/trainer/messages?userId=<%= uwp.getUserId() %>" class="btn btn-secondary btn-sm">Message</a>
                                </td>
                            </tr>
                        <%  }
                           } else { %>
                            <tr>
                                <td colspan="7" style="text-align: center; color: var(--text-muted); padding: 1.5rem;">
                                    No trainees have been assigned to your programs yet. Use the assignment form above to assign a member.
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- My Authored Plans Table -->
        <div class="card">
            <div class="card-header">
                <h2 class="card-title">My Authored Programs (<%= myPlans != null ? myPlans.size() : 0 %>)</h2>
            </div>

            <div class="table-responsive">
                <table class="custom-table">
                    <thead>
                        <tr>
                            <th>Program Title</th>
                            <th>Description</th>
                            <th>Difficulty</th>
                            <th>Duration</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (myPlans != null) {
                            for (WorkoutPlan p : myPlans) { %>
                            <tr>
                                <td><strong><%= p.getTitle() %></strong></td>
                                <td style="max-width: 320px; font-size: 0.85rem;"><%= p.getDescription() %></td>
                                <td><span class="badge <%= p.getDifficultyBadgeClass() %>"><%= p.getDifficulty() %></span></td>
                                <td><%= p.getDuration() %> Weeks</td>
                                <td><span class="badge <%= p.getStatusBadgeClass() %>"><%= p.getStatus() %></span></td>
                                <td>
                                    <form action="<%= request.getContextPath() %>/trainer/workouts" method="POST" style="display:inline;">
                                        <input type="hidden" name="action" value="delete_workout">
                                        <input type="hidden" name="planId" value="<%= p.getId() %>">
                                        <button type="submit" class="btn btn-danger btn-sm" onclick="return confirmAction('Delete plan <%= p.getTitle() %>?')">Delete</button>
                                    </form>
                                </td>
                            </tr>
                        <%  }
                           } %>
                    </tbody>
                </table>
            </div>
        </div>

    </div>

    <footer class="footer">
        <p>FitTrack Coach Portal &copy; 2026.</p>
    </footer>

</body>
</html>
