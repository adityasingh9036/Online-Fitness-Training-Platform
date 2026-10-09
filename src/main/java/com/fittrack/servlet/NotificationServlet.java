package com.fittrack.servlet;

import com.fittrack.model.Notification;
import com.fittrack.model.User;
import com.fittrack.service.NotificationService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

/**
 * Servlet handling user notification center, read status, and dismissals.
 */
@WebServlet(name = "NotificationServlet", urlPatterns = {
        "/user/notifications",
        "/notifications/read",
        "/notifications/read-all"
})
public class NotificationServlet extends HttpServlet {

    private final NotificationService notificationService = new NotificationService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login?error=Please+login+to+access+this+page");
            return;
        }

        String path = request.getServletPath();
        if ("/notifications/read".equals(path) || "/notifications/read-all".equals(path)) {
            response.sendRedirect(request.getContextPath() + "/user/notifications");
            return;
        }

        List<Notification> list = notificationService.getUserNotifications(currentUser.getId());
        request.setAttribute("notifications", list);
        request.getRequestDispatcher("/user/notifications.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login?error=Please+login+to+access+this+page");
            return;
        }

        String path = request.getServletPath();

        try {
            if ("/notifications/read".equals(path)) {
                String idParam = request.getParameter("id");
                if (idParam != null && !idParam.trim().isEmpty()) {
                    int id = Integer.parseInt(idParam.trim());
                    // Enforce notification ownership at database level
                    notificationService.markAsRead(id, currentUser.getId());
                }
            } else if ("/notifications/read-all".equals(path)) {
                notificationService.markAllAsRead(currentUser.getId());
            }
        } catch (Exception ignored) {
        }

        String referer = request.getHeader("Referer");
        if (referer != null) {
            response.sendRedirect(referer);
        } else {
            response.sendRedirect(request.getContextPath() + "/user/notifications");
        }
    }
}
