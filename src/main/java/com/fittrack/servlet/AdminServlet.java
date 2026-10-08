package com.fittrack.servlet;

import com.fittrack.dao.MessageDAO;
import com.fittrack.dao.SystemSettingsDAO;
import com.fittrack.model.SystemSetting;
import com.fittrack.model.User;
import com.fittrack.model.WorkoutPlan;
import com.fittrack.service.UserService;
import com.fittrack.service.WorkoutService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;
import java.util.Map;

/**
 * Controller servlet for Administrative management.
 * Handles user CRUD, workout approvals, settings, and platform metrics.
 */
@WebServlet(name = "AdminServlet", urlPatterns = {
        "/admin/dashboard",
        "/admin/users",
        "/admin/workouts",
        "/admin/settings"
})
public class AdminServlet extends HttpServlet {

    private final UserService userService = new UserService();
    private final WorkoutService workoutService = new WorkoutService();
    private final SystemSettingsDAO settingsDAO = new SystemSettingsDAO();
    private final MessageDAO messageDAO = new MessageDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String servletPath = request.getServletPath();

        try {
            if ("/admin/dashboard".equals(servletPath)) {
                handleDashboard(request, response);
            } else if ("/admin/users".equals(servletPath)) {
                handleUsersList(request, response);
            } else if ("/admin/workouts".equals(servletPath)) {
                handleWorkouts(request, response);
            } else if ("/admin/settings".equals(servletPath)) {
                handleSettings(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            }
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error: " + e.getMessage());
            request.getRequestDispatcher("/admin/dashboard.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");

        try {
            if ("create_user".equals(action)) {
                String name = request.getParameter("name");
                String email = request.getParameter("email");
                String password = request.getParameter("password");
                String role = request.getParameter("role");
                userService.registerUser(name, email, password, role);
                response.sendRedirect(request.getContextPath() + "/admin/users?success=User+created+successfully");

            } else if ("update_user".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                String name = request.getParameter("name");
                String email = request.getParameter("email");
                String role = request.getParameter("role");
                userService.updateUser(id, name, email, role);
                response.sendRedirect(request.getContextPath() + "/admin/users?success=User+updated+successfully");

            } else if ("delete_user".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                userService.deleteUser(id);
                response.sendRedirect(request.getContextPath() + "/admin/users?success=User+deleted+successfully");

            } else if ("approve_plan".equals(action)) {
                int planId = Integer.parseInt(request.getParameter("planId"));
                workoutService.approvePlan(planId);
                response.sendRedirect(request.getContextPath() + "/admin/workouts?success=Workout+plan+approved");

            } else if ("reject_plan".equals(action)) {
                int planId = Integer.parseInt(request.getParameter("planId"));
                workoutService.rejectPlan(planId);
                response.sendRedirect(request.getContextPath() + "/admin/workouts?success=Workout+plan+rejected");

            } else if ("save_setting".equals(action)) {
                String key = request.getParameter("settingName");
                String val = request.getParameter("settingValue");
                settingsDAO.updateSetting(key, val);
                response.sendRedirect(request.getContextPath() + "/admin/settings?success=Setting+updated+successfully");

            } else {
                response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            }
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard?error=" + e.getMessage());
        }
    }

    private void handleDashboard(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        Map<String, Object> stats = userService.getAdminDashboardStats();
        request.setAttribute("stats", stats);
        request.setAttribute("pendingPlans", workoutService.getPendingPlans());
        request.setAttribute("recentMessages", messageDAO.findAll().stream().limit(8).toList());
        request.getRequestDispatcher("/admin/dashboard.jsp").forward(request, response);
    }

    private void handleUsersList(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        List<User> users = userService.getAllUsers();
        request.setAttribute("users", users);
        request.getRequestDispatcher("/admin/users.jsp").forward(request, response);
    }

    private void handleWorkouts(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        List<WorkoutPlan> allPlans = workoutService.getAllPlans();
        request.setAttribute("plans", allPlans);
        request.getRequestDispatcher("/admin/workouts.jsp").forward(request, response);
    }

    private void handleSettings(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        List<SystemSetting> settings = settingsDAO.findAll();
        request.setAttribute("settings", settings);
        request.getRequestDispatcher("/admin/settings.jsp").forward(request, response);
    }
}
