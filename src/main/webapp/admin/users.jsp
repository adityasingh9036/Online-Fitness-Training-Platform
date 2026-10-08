<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.fittrack.model.User" %>
<%@ page import="java.util.List" %>
<%
    List<User> users = (List<User>) request.getAttribute("users");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Users - FitTrack Admin</title>
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
            <li><a href="<%= request.getContextPath() %>/admin/users" class="nav-link active">Users</a></li>
            <li><a href="<%= request.getContextPath() %>/admin/workouts" class="nav-link">Workouts</a></li>
            <li><a href="<%= request.getContextPath() %>/admin/settings" class="nav-link">Settings</a></li>
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

        <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 1.5rem;">
            
            <!-- Users Table Card -->
            <div class="card">
                <div class="card-header">
                    <h2 class="card-title">User Accounts (<%= users != null ? users.size() : 0 %>)</h2>
                </div>

                <div class="table-responsive">
                    <table class="custom-table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Name</th>
                                <th>Email</th>
                                <th>Role</th>
                                <th>Created Date</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (users != null) {
                                for (User u : users) { %>
                                <tr>
                                    <td>#<%= u.getId() %></td>
                                    <td><strong><%= u.getName() %></strong></td>
                                    <td><%= u.getEmail() %></td>
                                    <td>
                                        <span class="badge <%= "ADMIN".equalsIgnoreCase(u.getRole()) ? "badge-danger" : ("TRAINER".equalsIgnoreCase(u.getRole()) ? "badge-primary" : "badge-success") %>">
                                            <%= u.getRole() %>
                                        </span>
                                    </td>
                                    <td><%= u.getCreatedAt() != null ? u.getCreatedAt().toString().substring(0, 10) : "-" %></td>
                                    <td>
                                        <div style="display: flex; gap: 0.35rem;">
                                            <!-- Delete User Form -->
                                            <form action="<%= request.getContextPath() %>/admin/users" method="POST" style="display: inline;">
                                                <input type="hidden" name="action" value="delete_user">
                                                <input type="hidden" name="id" value="<%= u.getId() %>">
                                                <button type="submit" class="btn btn-danger btn-sm" onclick="return confirmAction('Delete user <%= u.getName() %>?')">Delete</button>
                                            </form>
                                        </div>
                                    </td>
                                </tr>
                            <%  }
                               } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Add User Form Card -->
            <div class="card">
                <div class="card-header">
                    <h2 class="card-title">Add New User</h2>
                </div>

                <form action="<%= request.getContextPath() %>/admin/users" method="POST">
                    <input type="hidden" name="action" value="create_user">

                    <div class="form-group">
                        <label class="form-label" for="name">Full Name</label>
                        <input type="text" id="name" name="name" class="form-control" required placeholder="User Name">
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="email">Email Address</label>
                        <input type="email" id="email" name="email" class="form-control" required placeholder="user@example.com">
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="password">Password</label>
                        <input type="password" id="password" name="password" class="form-control" required placeholder="••••••••">
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="role">User Role</label>
                        <select id="role" name="role" class="form-control" required>
                            <option value="USER">USER (Member)</option>
                            <option value="TRAINER">TRAINER (Coach)</option>
                            <option value="ADMIN">ADMIN (System Administrator)</option>
                        </select>
                    </div>

                    <button type="submit" class="btn btn-primary" style="width: 100%;">Create Account</button>
                </form>
            </div>

        </div>

    </div>

    <footer class="footer">
        <p>FitTrack Administrator Console &copy; 2026.</p>
    </footer>

</body>
</html>
