<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.fittrack.model.SystemSetting" %>
<%@ page import="java.util.List" %>
<%
    List<SystemSetting> settings = (List<SystemSetting>) request.getAttribute("settings");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>System Settings - FitTrack Admin</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <script src="<%= request.getContextPath() %>/js/main.js"></script>
</head>
<body>

    <nav class="navbar">
        <a href="<%= request.getContextPath() %>/admin/dashboard" class="nav-brand">
            <div class="brand-icon">⚡</div>
            <span>FitTrack Admin</span>
        </a>
        <ul class="nav-menu">
            <li><a href="<%= request.getContextPath() %>/admin/dashboard" class="nav-link">Dashboard</a></li>
            <li><a href="<%= request.getContextPath() %>/admin/users" class="nav-link">Users</a></li>
            <li><a href="<%= request.getContextPath() %>/admin/workouts" class="nav-link">Workouts</a></li>
            <li><a href="<%= request.getContextPath() %>/admin/settings" class="nav-link active">Settings</a></li>
            <li><a href="<%= request.getContextPath() %>/logout" class="btn btn-secondary btn-sm">Logout</a></li>
        </ul>
    </nav>

    <div class="main-container" style="max-width: 800px;">

        <% if (request.getParameter("success") != null) { %>
            <div class="alert alert-success">
                <span><%= request.getParameter("success") %></span>
            </div>
        <% } %>

        <div class="card">
            <div class="card-header">
                <div>
                    <h2 class="card-title">Platform Global Settings</h2>
                    <p style="color: var(--text-muted); font-size: 0.85rem;">Modify application constants stored in PostgreSQL.</p>
                </div>
            </div>

            <div class="table-responsive" style="margin-bottom: 2rem;">
                <table class="custom-table">
                    <thead>
                        <tr>
                            <th>Setting Parameter</th>
                            <th>Current Value</th>
                            <th>Last Updated</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (settings != null) {
                            for (SystemSetting s : settings) { %>
                            <tr>
                                <td><code><%= s.getSettingName() %></code></td>
                                <td><strong><%= s.getSettingValue() %></strong></td>
                                <td><%= s.getUpdatedAt() != null ? s.getUpdatedAt().toString().substring(0, 16) : "-" %></td>
                            </tr>
                        <%  }
                           } %>
                    </tbody>
                </table>
            </div>

            <h3 style="font-size: 1.1rem; margin-bottom: 1rem; border-top: 1px solid var(--card-border); padding-top: 1.25rem;">
                Update Setting Value
            </h3>

            <form action="<%= request.getContextPath() %>/admin/settings" method="POST">
                <input type="hidden" name="action" value="save_setting">

                <div class="form-group">
                    <label class="form-label" for="settingName">Select Setting</label>
                    <select id="settingName" name="settingName" class="form-control" required>
                        <% if (settings != null) {
                            for (SystemSetting s : settings) { %>
                            <option value="<%= s.getSettingName() %>"><%= s.getSettingName() %></option>
                        <%  }
                           } %>
                    </select>
                </div>

                <div class="form-group">
                    <label class="form-label" for="settingValue">New Value</label>
                    <input type="text" id="settingValue" name="settingValue" class="form-control" required placeholder="Enter new configuration value">
                </div>

                <button type="submit" class="btn btn-primary">Save Setting</button>
            </form>
        </div>

    </div>

    <footer class="footer">
        <p>FitTrack Administrator Console &copy; 2026.</p>
    </footer>

</body>
</html>
