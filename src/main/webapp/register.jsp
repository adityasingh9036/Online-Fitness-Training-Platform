<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create Account - FitTrack Platform</title>
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
            <li><a href="<%= request.getContextPath() %>/login" class="nav-link">Sign In</a></li>
        </ul>
    </nav>

    <div class="main-container" style="max-width: 480px; margin-top: 1.5rem;">

        <% if (request.getAttribute("errorMessage") != null) { %>
            <div class="alert alert-error">
                <span><%= request.getAttribute("errorMessage") %></span>
            </div>
        <% } %>

        <div class="card">
            <div class="card-header" style="justify-content: center; text-align: center;">
                <h2 class="card-title" style="font-size: 1.5rem;">Create Your Account</h2>
            </div>

            <form action="<%= request.getContextPath() %>/register" method="POST">
                <div class="form-group">
                    <label class="form-label" for="name">Full Name</label>
                    <input type="text" id="name" name="name" class="form-control" 
                           placeholder="John Doe" required 
                           value="<%= request.getAttribute("name") != null ? request.getAttribute("name") : "" %>">
                </div>

                <div class="form-group">
                    <label class="form-label" for="email">Email Address</label>
                    <input type="email" id="email" name="email" class="form-control" 
                           placeholder="john@example.com" required 
                           value="<%= request.getAttribute("email") != null ? request.getAttribute("email") : "" %>">
                </div>

                <div class="form-group">
                    <label class="form-label" for="role">Register As</label>
                    <select id="role" name="role" class="form-control" required>
                        <option value="USER">Fitness Member / Trainee</option>
                        <option value="TRAINER">Fitness Coach / Trainer</option>
                    </select>
                </div>

                <div class="form-group">
                    <label class="form-label" for="password">Password</label>
                    <input type="password" id="password" name="password" class="form-control" 
                           placeholder="Minimum 6 characters" minlength="6" required>
                </div>

                <div class="form-group">
                    <label class="form-label" for="confirmPassword">Confirm Password</label>
                    <input type="password" id="confirmPassword" name="confirmPassword" class="form-control" 
                           placeholder="Re-enter password" minlength="6" required>
                </div>

                <button type="submit" class="btn btn-primary" style="width: 100%; margin-top: 0.5rem;">
                    Complete Registration
                </button>
            </form>

            <div style="margin-top: 1.25rem; text-align: center;">
                <p style="font-size: 0.85rem; color: var(--text-dim);">
                    Already registered? 
                    <a href="<%= request.getContextPath() %>/login">Sign In here</a>
                </p>
            </div>
        </div>

    </div>

    <footer class="footer">
        <p>FitTrack &copy; 2026. Java Web & PostgreSQL Platform.</p>
    </footer>

</body>
</html>
