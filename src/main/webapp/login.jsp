<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign In - FitTrack Platform</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <script src="<%= request.getContextPath() %>/js/main.js"></script>
</head>
<body>

    <nav class="navbar">
        <a href="<%= request.getContextPath() %>/" class="nav-brand">
            <div class="brand-icon">⚡</div>
            <span>FitTrack</span>
        </a>
        <ul class="nav-menu">
            <li><a href="<%= request.getContextPath() %>/" class="nav-link">Home</a></li>
            <li><a href="<%= request.getContextPath() %>/register" class="btn btn-primary btn-sm">Register</a></li>
        </ul>
    </nav>

    <div class="main-container" style="max-width: 460px; margin-top: 2rem;">

        <% if (request.getAttribute("errorMessage") != null) { %>
            <div class="alert alert-error">
                <span><%= request.getAttribute("errorMessage") %></span>
            </div>
        <% } %>

        <% if (request.getParameter("error") != null) { %>
            <div class="alert alert-error">
                <span><%= request.getParameter("error") %></span>
            </div>
        <% } %>

        <% if (request.getParameter("success") != null) { %>
            <div class="alert alert-success">
                <span><%= request.getParameter("success") %></span>
            </div>
        <% } %>

        <div class="card">
            <div class="card-header" style="justify-content: center; text-align: center;">
                <h2 class="card-title" style="font-size: 1.5rem;">Sign In to FitTrack</h2>
            </div>

            <form action="<%= request.getContextPath() %>/login" method="POST">
                <div class="form-group">
                    <label class="form-label" for="email">Email Address</label>
                    <input type="email" id="email" name="email" class="form-control" 
                           placeholder="name@example.com" required 
                           value="<%= request.getAttribute("email") != null ? request.getAttribute("email") : "" %>">
                </div>

                <div class="form-group">
                    <label class="form-label" for="password">Password</label>
                    <input type="password" id="password" name="password" class="form-control" 
                           placeholder="••••••••" required>
                </div>

                <button type="submit" class="btn btn-primary" style="width: 100%; margin-top: 0.5rem;">
                    Sign In
                </button>
            </form>

            <div style="margin-top: 1.5rem; padding-top: 1.25rem; border-top: 1px solid var(--card-border); text-align: center;">
                <p style="font-size: 0.85rem; color: var(--text-muted); margin-bottom: 0.8rem;">
                    Quick-Fill Demo Credentials (For Evaluation & Viva):
                </p>
                <div style="display: flex; gap: 0.5rem; justify-content: center; flex-wrap: wrap;">
                    <button type="button" class="btn btn-danger btn-sm" 
                            onclick="fillCredentials('admin@fittrack.com', 'admin123')">
                        Admin
                    </button>
                    <button type="button" class="btn btn-secondary btn-sm" 
                            onclick="fillCredentials('trainer@fittrack.com', 'trainer123')">
                        Trainer
                    </button>
                    <button type="button" class="btn btn-success btn-sm" 
                            onclick="fillCredentials('user@fittrack.com', 'user123')">
                        Member
                    </button>
                </div>
            </div>

            <div style="margin-top: 1.25rem; text-align: center;">
                <p style="font-size: 0.85rem; color: var(--text-dim);">
                    Don't have an account? 
                    <a href="<%= request.getContextPath() %>/register">Create account</a>
                </p>
            </div>
        </div>

    </div>

    <footer class="footer">
        <p>FitTrack &copy; 2026. Java Web & PostgreSQL Platform.</p>
    </footer>

</body>
</html>
