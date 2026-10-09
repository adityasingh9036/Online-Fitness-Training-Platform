package com.fittrack.servlet;

import com.fittrack.model.Progress;
import com.fittrack.model.User;
import com.fittrack.model.UserWorkoutPlan;
import com.fittrack.model.WorkoutPlan;
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
 * Servlet handling Workout Plan browsing, details inspection, and Member enrollment.
 */
@WebServlet(name = "WorkoutServlet", urlPatterns = {
        "/workouts",
        "/user/workouts",
        "/user/workouts/details",
        "/user/workouts/enroll",
        "/user/workouts/complete",
        "/user/workouts/exercise/complete",
        "/user/workouts/exercise/uncomplete"
})
public class WorkoutServlet extends HttpServlet {

    private final WorkoutService workoutService = new WorkoutService();
    private final ProgressService progressService = new ProgressService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String path = request.getServletPath();
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if ("/user/workouts/details".equals(path)) {
            int planId = Integer.parseInt(request.getParameter("id"));
            WorkoutPlan plan;
            if (user != null) {
                plan = workoutService.getPlanWithExerciseProgress(planId, user.getId());
                Map<String, Object> weeklyProgress = workoutService.getWeeklyProgress(user.getId(), planId);
                request.setAttribute("weeklyProgress", weeklyProgress);
            } else {
                plan = workoutService.getPlanById(planId);
            }
            request.setAttribute("plan", plan);
            request.getRequestDispatcher("/user/workout_details.jsp").forward(request, response);
            return;
        }

        // List approved workout plans with optional goal filter
        List<WorkoutPlan> approvedPlans = workoutService.getApprovedPlans();
        String goalFilter = request.getParameter("goal");
        if (goalFilter != null && !goalFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(goalFilter)) {
            final String filterVal = goalFilter.trim();
            approvedPlans = approvedPlans.stream()
                    .filter(p -> p.getGoalType().equalsIgnoreCase(filterVal) || p.matchesGoal(filterVal))
                    .toList();
        }
        request.setAttribute("plans", approvedPlans);
        request.setAttribute("selectedGoal", goalFilter != null ? goalFilter : "ALL");

        if (user != null) {
            List<UserWorkoutPlan> enrolledPlans = workoutService.getUserEnrolledPlans(user.getId());
            UserWorkoutPlan activePlan = workoutService.getUserActivePlan(user.getId());
            request.setAttribute("enrolledPlans", enrolledPlans);
            request.setAttribute("activePlan", activePlan);

            if (activePlan != null) {
                request.setAttribute("activePlanProgress", workoutService.getWeeklyProgress(user.getId(), activePlan.getPlanId()));
            }

            Progress latest = progressService.getLatestProgress(user.getId());
            if (latest != null && latest.getFitnessGoal() != null) {
                request.setAttribute("userFitnessGoal", latest.getFitnessGoal());
            }
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

            } else if ("/user/workouts/exercise/complete".equals(path)) {
                int planId = Integer.parseInt(request.getParameter("planId"));
                int exerciseId = Integer.parseInt(request.getParameter("exerciseId"));
                workoutService.markExerciseCompleted(user.getId(), planId, exerciseId);
                response.sendRedirect(request.getContextPath() + "/user/workouts/details?id=" + planId + "&success=Exercise+marked+as+completed!");

            } else if ("/user/workouts/exercise/uncomplete".equals(path)) {
                int planId = Integer.parseInt(request.getParameter("planId"));
                int exerciseId = Integer.parseInt(request.getParameter("exerciseId"));
                workoutService.unmarkExerciseCompleted(user.getId(), planId, exerciseId);
                response.sendRedirect(request.getContextPath() + "/user/workouts/details?id=" + planId + "&success=Exercise+unmarked+as+completed!");

            } else {
                response.sendRedirect(request.getContextPath() + "/user/workouts");
            }
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/user/workouts?error=" + e.getMessage());
        }
    }
}
