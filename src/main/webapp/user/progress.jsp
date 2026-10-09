<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.fittrack.model.Progress" %>
<%@ page import="java.util.List, java.util.Map" %>
<%
    List<Progress> progressList = (List<Progress>) request.getAttribute("progressList");
    Map<String, Object> summary = (Map<String, Object>) request.getAttribute("summary");
    String cachedReport = (String) request.getAttribute("cachedReport");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Progress & Metrics - FitTrack</title>
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
            <li><a href="<%= request.getContextPath() %>/user/workouts" class="nav-link">Workouts</a></li>
            <li><a href="<%= request.getContextPath() %>/user/progress" class="nav-link active">My Progress</a></li>
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

        <div style="margin-bottom: 1.5rem;">
            <h1 style="font-size: 1.75rem; font-weight: 700;">Fitness Transformation Tracker</h1>
            <p style="color: var(--text-muted); font-size: 0.95rem;">Record body measurements, track weight progression, and analyze body composition.</p>
        </div>

        <!-- Metric summary cards -->
        <div class="stats-grid">
            <div class="stat-card">
                <span class="stat-label">Current Weight</span>
                <span class="stat-value" style="color: #34d399;">
                    <%= (summary != null && (Boolean) summary.get("hasData")) ? summary.get("currentWeight") + " kg" : "--" %>
                </span>
                <span class="stat-desc">Latest logged weight</span>
            </div>

            <div class="stat-card">
                <span class="stat-label">Net Transformation</span>
                <span class="stat-value" style="color: #60a5fa;">
                    <% if (summary != null && (Boolean) summary.get("hasData")) { 
                        double delta = (Double) summary.get("netChange"); %>
                        <%= (delta > 0 ? "+" : "") + delta + " kg" %>
                    <% } else { %>
                        0.0 kg
                    <% } %>
                </span>
                <span class="stat-desc">Since starting journey</span>
            </div>

            <div class="stat-card">
                <span class="stat-label">Current BMI</span>
                <span class="stat-value">
                    <%= (summary != null && (Boolean) summary.get("hasData")) ? summary.get("currentBmi") : "--" %>
                </span>
                <span class="stat-desc">
                    <span class="badge badge-primary"><%= (summary != null && (Boolean) summary.get("hasData")) ? summary.get("bmiCategory") : "N/A" %></span>
                </span>
            </div>

            <div class="stat-card">
                <span class="stat-label">Total Logged Check-ins</span>
                <span class="stat-value"><%= summary != null ? summary.get("logsCount") : 0 %></span>
                <span class="stat-desc">Consistent accountability</span>
            </div>
        </div>

        <!-- Multithreaded Background Report Section (Rubric 3.3 & 18 Viva) -->
        <div class="card" style="border: 1px solid rgba(59, 130, 246, 0.4); background: rgba(59, 130, 246, 0.03);">
            <div class="card-header">
                <div>
                    <h2 class="card-title" style="color: #60a5fa;">Automated Progress Intelligence Report</h2>
                    <span style="font-size: 0.8rem; color: var(--text-muted);">
                        Asynchronously calculated by ProgressReportThread (Multithreading & Synchronization)
                    </span>
                </div>

                <form action="<%= request.getContextPath() %>/user/progress/generate-report" method="POST">
                    <button type="submit" class="btn btn-secondary btn-sm">⚡ Re-run Analytics Thread</button>
                </form>
            </div>

            <div style="background: #090e17; padding: 1.25rem; border-radius: var(--radius-sm); border: 1px solid var(--card-border);">
                <pre style="color: #93c5fd; font-family: monospace; font-size: 0.9rem; white-space: pre-wrap;"><%= cachedReport != null ? cachedReport : "Submit a progress check-in to generate your first automated performance report." %></pre>
            </div>
        </div>

        <div style="display: grid; grid-template-columns: 1fr 2fr; gap: 1.5rem;">
            
            <!-- New Check-in Form Card -->
            <div class="card">
                <div class="card-header">
                    <h2 class="card-title">Log Today's Metrics</h2>
                </div>

                <form action="<%= request.getContextPath() %>/user/progress/log" method="POST">
                    <div class="form-group">
                        <label class="form-label" for="weight">Weight (kg)</label>
                        <input type="number" step="0.1" id="weight" name="weight" class="form-control" required placeholder="e.g. 70.0">
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="height">Height (cm)</label>
                        <input type="number" step="0.5" id="height" name="height" class="form-control" required placeholder="e.g. 170.0">
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="fitnessGoal">Primary Fitness Goal</label>
                        <input type="text" id="fitnessGoal" name="fitnessGoal" class="form-control" required placeholder="e.g. Muscle Gain">
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="bodyMeasurement">Measurements (Tape / Notes)</label>
                        <input type="text" id="bodyMeasurement" name="bodyMeasurement" class="form-control" placeholder="e.g. Chest: 38in, Waist: 31in">
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="recordDate">Date of Weigh-in</label>
                        <input type="date" id="recordDate" name="recordDate" class="form-control">
                    </div>

                    <button type="submit" class="btn btn-primary" style="width: 100%;">Record Progress</button>
                </form>
            </div>

            <!-- Historical Log Table -->
            <div class="card">
                <div class="card-header">
                    <h2 class="card-title">Progress History (<%= progressList != null ? progressList.size() : 0 %>)</h2>
                </div>

                <% if (progressList == null || progressList.isEmpty()) { %>
                    <p style="color: var(--text-muted); padding: 1.5rem 0;">No logs yet. Use the form on the left to submit your first entry!</p>
                <% } else { %>
                    <div class="table-responsive">
                        <table class="custom-table">
                            <thead>
                                <tr>
                                    <th>Date</th>
                                    <th>Weight</th>
                                    <th>Change</th>
                                    <th>BMI</th>
                                    <th>Measurements</th>
                                    <th>Goal</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (Progress p : progressList) { %>
                                    <tr>
                                        <td><%= p.getRecordDate() %></td>
                                        <td><strong><%= p.getWeight() %> kg</strong></td>
                                        <td>
                                            <% if (p.getWeightChange() != 0.0) { 
                                                boolean isMuscleGoal = p.getFitnessGoal() != null && 
                                                    (p.getFitnessGoal().toLowerCase().contains("gain") || p.getFitnessGoal().toLowerCase().contains("muscle") || p.getFitnessGoal().toLowerCase().contains("bulk"));
                                                String badgeClass = (p.getWeightChange() > 0)
                                                    ? (isMuscleGoal ? "badge-success" : "badge-warning")
                                                    : (isMuscleGoal ? "badge-warning" : "badge-success");
                                            %>
                                                <span class="badge <%= badgeClass %>">
                                                    <%= (p.getWeightChange() > 0 ? "+" : "") + p.getWeightChange() %> kg
                                                </span>
                                            <% } else { %>
                                                <span style="color: var(--text-dim);">-</span>
                                            <% } %>
                                        </td>
                                        <td>
                                            <span class="badge badge-primary"><%= p.calculateBMI() %></span>
                                        </td>
                                        <td><%= p.getBodyMeasurement() != null ? p.getBodyMeasurement() : "-" %></td>
                                        <td><%= p.getFitnessGoal() %></td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                <% } %>
            </div>

        </div>

    </div>

    <footer class="footer">
        <p>FitTrack Fitness Member Portal &copy; 2026.</p>
    </footer>

</body>
</html>
