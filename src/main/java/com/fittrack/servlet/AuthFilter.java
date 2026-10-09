package com.fittrack.servlet;

import com.fittrack.model.User;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Role-Based Access Control (RBAC) Filter.
 * Restricts protected URLs based on user authentication and assigned role.
 */
@WebFilter(urlPatterns = {"/admin/*", "/trainer/*", "/user/*", "/notifications/*"})
public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        HttpSession session = httpRequest.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        String uri = httpRequest.getRequestURI();
        String contextPath = httpRequest.getContextPath();
        String path = uri.substring(contextPath.length());

        if (currentUser == null) {
            // User is not logged in -> redirect to login page with return message
            httpResponse.sendRedirect(contextPath + "/login?error=Please+login+to+access+this+page");
            return;
        }

        String role = currentUser.getRole();

        // RBAC Verification
        if (path.startsWith("/admin/") && !"ADMIN".equalsIgnoreCase(role)) {
            httpResponse.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: Admin privileges required.");
            return;
        }

        if (path.startsWith("/trainer/") && !"TRAINER".equalsIgnoreCase(role) && !"ADMIN".equalsIgnoreCase(role)) {
            httpResponse.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: Trainer privileges required.");
            return;
        }

        if (path.startsWith("/user/") && !"USER".equalsIgnoreCase(role) && !"ADMIN".equalsIgnoreCase(role)) {
            httpResponse.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: User dashboard access required.");
            return;
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
    }
}
