package com.fittrack.servlet;

import com.fittrack.model.User;
import com.fittrack.model.UserWorkoutPlan;
import com.fittrack.model.WorkoutPlan;
import com.fittrack.service.WorkoutService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

/**
 * Servlet handling Workout Plan browsing, details inspection, and Member enrollment.
 */
@WebServlet(name = "WorkoutServlet", urlPatterns = {
        "/workouts",
        "/user/workouts",
        "/user/workouts/details",
        "/user/workouts/enroll",
        "/user/workouts/complete"
})
public class WorkoutServlet extends HttpServlet {

    private final WorkoutService workoutService = new WorkoutService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String path = request.getServletPath();
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if ("/user/workouts/details".equals(path)) {
            int planId = Integer.parseInt(request.getParameter("id"));
            WorkoutPlan plan = workoutService.getPlanById(planId);
            request.setAttribute("plan", plan);
            request.getRequestDispatcher("/user/workout_details.jsp").forward(request, response);
            return;
        }

        // List approved workout plans and user's enrolled plans
        List<WorkoutPlan> approvedPlans = workoutService.getApprovedPlans();
        request.setAttribute("plans", approvedPlans);

        if (user != null) {
            List<UserWorkoutPlan> enrolledPlans = workoutService.getUserEnrolledPlans(user.getId());
            UserWorkoutPlan activePlan = workoutService.getUserActivePlan(user.getId());
            request.setAttribute("enrolledPlans", enrolledPlans);
            request.setAttribute("activePlan", activePlan);
        }

        request.getRequestDispatcher("/user/workouts.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String path = request.getServletPath();
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            if ("/user/workouts/enroll".equals(path)) {
                int planId = Integer.parseInt(request.getParameter("planId"));
                workoutService.enrollUserInPlan(user.getId(), planId);
                response.sendRedirect(request.getContextPath() + "/user/workouts?success=Enrolled+in+workout+plan+successfully!");

            } else if ("/user/workouts/complete".equals(path)) {
                int planId = Integer.parseInt(request.getParameter("planId"));
                workoutService.completePlan(user.getId(), planId);
                response.sendRedirect(request.getContextPath() + "/user/workouts?success=Workout+plan+marked+as+completed!");

            } else {
                response.sendRedirect(request.getContextPath() + "/user/workouts");
            }
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/user/workouts?error=" + e.getMessage());
        }
    }
}
