<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.fittrack.model.User" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FitTrack - Online Fitness Training Platform</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body style="min-height: 100vh; display: flex; flex-direction: column; background-color: #0b1120; margin: 0; padding: 0;">

    <!-- Navbar -->
    <nav class="navbar hero-navbar" style="background-color: rgba(11, 17, 32, 0.95); border-bottom: 1px solid rgba(255, 255, 255, 0.08); padding: 0.75rem 2rem; display: flex; align-items: center; justify-content: space-between; height: 64px; box-sizing: border-box;">
        <div class="nav-brand-group" style="display: flex; align-items: center; gap: 0.85rem;">
            <a href="<%= request.getContextPath() %>/" class="nav-brand" style="display: flex; align-items: center; gap: 0.65rem; text-decoration: none;">
                <div class="brand-icon">⚡</div>
                <span style="font-size: 1.25rem; font-weight: 700; color: #ffffff; letter-spacing: -0.01em;">FitTrack</span>
            </a>
            <span class="nav-divider" style="width: 1px; height: 18px; background-color: rgba(255, 255, 255, 0.18); display: inline-block;"></span>
            <span class="nav-tagline" style="font-size: 0.85rem; color: #94a3b8; font-weight: 500; letter-spacing: 0.01em;">Online Fitness Training Platform</span>
        </div>
        <ul class="nav-actions" style="display: flex; align-items: center; gap: 0.65rem; list-style: none; margin: 0; padding: 0;">
            <% if (currentUser == null) { %>
                <li><a href="<%= request.getContextPath() %>/login" class="btn btn-secondary btn-sm">Sign In</a></li>
                <li><a href="<%= request.getContextPath() %>/register" class="btn btn-primary btn-sm">Get Started</a></li>
            <% } else { %>
                <li><a href="<%= request.getContextPath() %>/<%= currentUser.getDashboardUrl() %>" class="btn btn-primary btn-sm">Go to Dashboard</a></li>
                <li><a href="<%= request.getContextPath() %>/logout" class="btn btn-secondary btn-sm">Sign Out</a></li>
            <% } %>
        </ul>
    </nav>

    <!-- Hero Section -->
    <main class="hero-container" style="flex: 1; display: flex; flex-direction: column; align-items: center; justify-content: center; text-align: center; min-height: calc(100vh - 64px); padding: 4rem 1.5rem 6rem; width: 100%; box-sizing: border-box; background: radial-gradient(ellipse 80% 50% at 50% 30%, rgba(16, 185, 129, 0.07) 0%, rgba(15, 23, 42, 0) 65%), linear-gradient(180deg, #0b1120 0%, #0d1527 50%, #0b1120 100%);">
        <div class="hero-content" style="max-width: 860px; width: 100%; margin: -35px auto 0 auto; display: flex; flex-direction: column; align-items: center; text-align: center;">
            <h1 class="hero-headline" style="font-size: 56px; font-weight: 800; max-width: 860px; line-height: 1.18; margin: 0 auto 1.5rem auto; letter-spacing: -0.03em; color: #ffffff; text-align: center;">
                Transform Your Fitness with<br>
                Tailored Training Programs
            </h1>
            
            <p class="hero-description" style="font-size: 1.18rem; color: #94a3b8; max-width: 660px; margin: 0 auto 2.5rem auto; line-height: 1.65; text-align: center;">
                FitTrack connects fitness members with certified trainers. Access structured workout routines, log body transformations, and communicate directly with your coach.
            </p>

            <div class="hero-cta-group" style="display: flex; gap: 1.15rem; justify-content: center; align-items: center; flex-wrap: wrap;">
                <% if (currentUser == null) { %>
                    <a href="<%= request.getContextPath() %>/register" class="btn btn-primary btn-lg">
                        Start Your Journey &rarr;
                    </a>
                    <a href="<%= request.getContextPath() %>/login" class="btn btn-secondary btn-lg">
                        Platform Login
                    </a>
                <% } else { %>
                    <a href="<%= request.getContextPath() %>/<%= currentUser.getDashboardUrl() %>" class="btn btn-primary btn-lg">
                        Continue to Dashboard &rarr;
                    </a>
                    <a href="<%= request.getContextPath() %>/logout" class="btn btn-secondary btn-lg">
                        Sign Out
                    </a>
                <% } %>
            </div>
        </div>
    </main>

</body>
</html>
