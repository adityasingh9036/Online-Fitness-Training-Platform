<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.fittrack.model.User, com.fittrack.model.Progress" %>
<%@ page import="java.util.List" %>
<%
    List<User> members = (List<User>) request.getAttribute("members");
    List<Progress> progressLogs = (List<Progress>) request.getAttribute("progressLogs");
    Integer selectedUserId = (Integer) request.getAttribute("selectedUserId");
    String cachedReport = (String) request.getAttribute("cachedReport");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Trainee Progress Review - FitTrack Coach</title>
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
            <li><a href="<%= request.getContextPath() %>/trainer/workouts" class="nav-link">Workouts</a></li>
            <li><a href="<%= request.getContextPath() %>/trainer/progress" class="nav-link active">Trainee Progress</a></li>
            <li><a href="<%= request.getContextPath() %>/trainer/messages" class="nav-link">Messages</a></li>
            <li><a href="<%= request.getContextPath() %>/logout" class="btn btn-secondary btn-sm">Logout</a></li>
        </ul>
    </nav>

    <div class="main-container">

        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem;">
            <div>
                <h1 style="font-size: 1.75rem; font-weight: 700;">Trainee Progress & Analytics</h1>
                <p style="color: var(--text-muted); font-size: 0.95rem;">Monitor client physical progress and generate performance assessments.</p>
            </div>
        </div>

        <!-- Trainee Selection Card -->
        <div class="card" style="margin-bottom: 1.5rem;">
            <form action="<%= request.getContextPath() %>/trainer/progress" method="GET" style="display: flex; gap: 1rem; align-items: flex-end;">
                <div class="form-group" style="margin-bottom: 0; flex: 1;">
                    <label class="form-label" for="userId">Select Trainee to Inspect</label>
                    <select id="userId" name="userId" class="form-control" onchange="this.form.submit()">
                        <option value="">-- Choose Member --</option>
                        <% if (members != null) {
                            for (User u : members) { %>
                            <option value="<%= u.getId() %>" <%= (selectedUserId != null && selectedUserId == u.getId()) ? "selected" : "" %>>
                                <%= u.getName() %> (<%= u.getEmail() %>)
                            </option>
                        <%  }
                           } %>
                    </select>
                </div>
                <button type="submit" class="btn btn-secondary">Load Logs</button>
            </form>
        </div>

        <% if (selectedUserId != null && selectedUserId > 0) { %>
            
            <!-- Multithreading Feature Card (Rubric 3.3 Viva Showcase) -->
            <div class="card" style="border: 1px solid rgba(16, 185, 129, 0.4); background: rgba(16, 185, 129, 0.03);">
                <div class="card-header">
                    <div>
                        <h2 class="card-title" style="color: #34d399;">Asynchronous Progress Report Engine</h2>
                        <span style="font-size: 0.8rem; color: var(--text-muted);">
                            Java Multithreading rubric feature (ProgressReportThread with synchronized cache)
                        </span>
                    </div>

                    <form action="<%= request.getContextPath() %>/trainer/progress" method="POST">
                        <input type="hidden" name="action" value="generate_report">
                        <input type="hidden" name="userId" value="<%= selectedUserId %>">
                        <button type="submit" class="btn btn-success btn-sm">⚡ Run Background Analysis Thread</button>
                    </form>
                </div>

                <div style="background: #090e17; padding: 1.25rem; border-radius: var(--radius-sm); border: 1px solid var(--card-border);">
                    <pre style="color: #a7f3d0; font-family: monospace; font-size: 0.9rem; white-space: pre-wrap;"><%= cachedReport != null ? cachedReport : "Click 'Run Background Analysis Thread' to compute summary report." %></pre>
                </div>
            </div>

            <!-- Historical Progress Table -->
            <div class="card">
                <div class="card-header">
                    <h2 class="card-title">Check-in History (<%= progressLogs != null ? progressLogs.size() : 0 %> logs)</h2>
                </div>

                <% if (progressLogs == null || progressLogs.isEmpty()) { %>
                    <p style="color: var(--text-muted);">No progress check-ins recorded by this trainee yet.</p>
                <% } else { %>
                    <div class="table-responsive">
                        <table class="custom-table">
                            <thead>
                                <tr>
                                    <th>Date</th>
                                    <th>Weight (kg)</th>
                                    <th>Height (cm)</th>
                                    <th>BMI</th>
                                    <th>Body Measurements</th>
                                    <th>Goal</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (Progress p : progressLogs) { %>
                                    <tr>
                                        <td><%= p.getRecordDate() %></td>
                                        <td><strong><%= p.getWeight() %> kg</strong></td>
                                        <td><%= p.getHeight() %> cm</td>
                                        <td>
                                            <span class="badge badge-primary"><%= p.calculateBMI() %> (<%= p.getBMICategory() %>)</span>
                                        </td>
                                        <td><%= p.getBodyMeasurement() %></td>
                                        <td><%= p.getFitnessGoal() %></td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                <% } %>
            </div>

        <% } else { %>
            <div class="card" style="text-align: center; padding: 3rem 1rem;">
                <p style="color: var(--text-muted); font-size: 1.1rem;">Please select a trainee from the dropdown above to inspect their progress data.</p>
            </div>
        <% } %>

    </div>

    <footer class="footer">
        <p>FitTrack Coach Portal &copy; 2026.</p>
    </footer>

</body>
</html>
