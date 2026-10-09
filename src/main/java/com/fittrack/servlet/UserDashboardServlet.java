package com.fittrack.servlet;

import com.fittrack.model.Progress;
import com.fittrack.model.User;
import com.fittrack.model.UserWorkoutPlan;
import com.fittrack.model.WorkoutPlan;
import com.fittrack.service.MessageService;
import com.fittrack.service.NotificationService;
import com.fittrack.service.ProgressService;
import com.fittrack.service.WorkoutService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;
import java.util.Map;

/**
 * Controller servlet for Member User Dashboard.
 * Prepares dashboard cards: Active Plan, Latest Weight, Progress Summary, and Available Plans.
 */
@WebServlet(name = "UserDashboardServlet", urlPatterns = {"/user/dashboard"})
public class UserDashboardServlet extends HttpServlet {

    private final WorkoutService workoutService = new WorkoutService();
    private final ProgressService progressService = new ProgressService();
    private final NotificationService notificationService = new NotificationService();
    private final MessageService messageService = new MessageService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("currentUser");

        UserWorkoutPlan activePlan = workoutService.getUserActivePlan(user.getId());
        if (activePlan != null) {
            Map<String, Object> activePlanProgress = workoutService.getWeeklyProgress(user.getId(), activePlan.getPlanId());
            request.setAttribute("activePlanProgress", activePlanProgress);
        }
        List<WorkoutPlan> availablePlans = workoutService.getApprovedPlans();
        Map<String, Object> progressSummary = progressService.calculateProgressSummary(user.getId());
        Progress latestProgress = progressService.getLatestProgress(user.getId());
        int unreadNotifs = notificationService.getUnreadCount(user.getId());
        int unreadMessages = messageService.getUnreadMessageCount(user.getId());

        request.setAttribute("activePlan", activePlan);
        request.setAttribute("availablePlans", availablePlans);
        request.setAttribute("progressSummary", progressSummary);
        request.setAttribute("latestProgress", latestProgress);
        request.setAttribute("unreadNotifs", unreadNotifs);
        request.setAttribute("unreadMessages", unreadMessages);

        request.getRequestDispatcher("/user/dashboard.jsp").forward(request, response);
    }
}
