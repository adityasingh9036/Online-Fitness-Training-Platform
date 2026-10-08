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
<body>

    <nav class="navbar">
        <div class="nav-brand">
            <div class="brand-icon">⚡</div>
            <span>FitTrack</span>
        </div>
        <ul class="nav-menu">
            <% if (currentUser == null) { %>
                <li><a href="<%= request.getContextPath() %>/login" class="nav-link">Sign In</a></li>
                <li><a href="<%= request.getContextPath() %>/register" class="btn btn-primary btn-sm">Get Started</a></li>
            <% } else { %>
                <li><a href="<%= request.getContextPath() %>/<%= currentUser.getDashboardUrl() %>" class="btn btn-primary btn-sm">Go to Dashboard</a></li>
                <li><a href="<%= request.getContextPath() %>/logout" class="nav-link">Sign Out</a></li>
            <% } %>
        </ul>
    </nav>

    <div class="main-container" style="display: flex; flex-direction: column; justify-content: center; align-items: center; text-align: center; min-height: 70vh;">
        <span class="badge badge-primary" style="margin-bottom: 1rem; padding: 0.4rem 1rem;">Java Web & Supabase PostgreSQL Academic Project</span>
        <h1 style="font-size: 3rem; font-weight: 800; max-width: 800px; line-height: 1.2; margin-bottom: 1.2rem; background: linear-gradient(to right, #ffffff, #94a3b8); -webkit-background-clip: text; -webkit-text-fill-color: transparent;">
            Transform Your Fitness with Tailored Training Programs
        </h1>
        <p style="font-size: 1.15rem; color: var(--text-muted); max-width: 620px; margin-bottom: 2rem;">
            FitTrack connects fitness members with certified trainers. Access structured workout routines, log body transformations, and communicate directly with your coach.
        </p>

        <div style="display: flex; gap: 1rem; justify-content: center; margin-bottom: 3rem;">
            <a href="<%= request.getContextPath() %>/register" class="btn btn-primary" style="padding: 0.8rem 1.8rem; font-size: 1rem;">Start Your Journey</a>
            <a href="<%= request.getContextPath() %>/login" class="btn btn-secondary" style="padding: 0.8rem 1.8rem; font-size: 1rem;">Platform Login</a>
        </div>

        <div class="stats-grid" style="width: 100%; max-width: 1000px; text-align: left;">
            <div class="stat-card">
                <span class="stat-label">Role 1: Administrator</span>
                <span class="stat-value" style="font-size: 1.35rem; color: #ef4444;">Admin Control</span>
                <span class="stat-desc">Full user governance, workout approval workflows, and system settings.</span>
            </div>
            <div class="stat-card">
                <span class="stat-label">Role 2: Trainer</span>
                <span class="stat-value" style="font-size: 1.35rem; color: #3b82f6;">Fitness Coach</span>
                <span class="stat-desc">Program design, exercise curation, trainee progress monitoring & feedback.</span>
            </div>
            <div class="stat-card">
                <span class="stat-label">Role 3: Member</span>
                <span class="stat-value" style="font-size: 1.35rem; color: #10b981;">Active User</span>
                <span class="stat-desc">Enroll in programs, track weight & BMI progress, and message coaches.</span>
            </div>
        </div>
    </div>

    <footer class="footer">
        <p>FitTrack &copy; 2026. Built with Java 17, Servlets, JDBC, Collections & Supabase PostgreSQL.</p>
    </footer>

</body>
</html>
