package com.fittrack.servlet;

import com.fittrack.dao.UserDAO;
import com.fittrack.model.Exercise;
import com.fittrack.model.Progress;
import com.fittrack.model.User;
import com.fittrack.model.WorkoutPlan;
import com.fittrack.service.MessageService;
import com.fittrack.service.ProgressService;
import com.fittrack.service.WorkoutService;
import com.fittrack.thread.ProgressReportThread;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * Controller servlet for Fitness Trainers.
 * Handles workout creation, exercise catalog, client progress tracking, and client messaging.
 */
@WebServlet(name = "TrainerServlet", urlPatterns = {
        "/trainer/dashboard",
        "/trainer/workouts",
        "/trainer/progress",
        "/trainer/messages"
})
public class TrainerServlet extends HttpServlet {

    private final WorkoutService workoutService = new WorkoutService();
    private final ProgressService progressService = new ProgressService();
    private final MessageService messageService = new MessageService();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User trainer = (User) session.getAttribute("currentUser");
        String servletPath = request.getServletPath();

        try {
            if ("/trainer/dashboard".equals(servletPath)) {
                handleDashboard(request, response, trainer);
            } else if ("/trainer/workouts".equals(servletPath)) {
                handleWorkouts(request, response, trainer);
            } else if ("/trainer/progress".equals(servletPath)) {
                handleProgress(request, response);
            } else if ("/trainer/messages".equals(servletPath)) {
                handleMessages(request, response, trainer);
            } else {
                response.sendRedirect(request.getContextPath() + "/trainer/dashboard");
            }
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error: " + e.getMessage());
            request.getRequestDispatcher("/trainer/dashboard.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User trainer = (User) session.getAttribute("currentUser");
        String action = request.getParameter("action");

        try {
            if ("create_workout".equals(action)) {
                String title = request.getParameter("title");
                String description = request.getParameter("description");
                String difficulty = request.getParameter("difficulty");
                int duration = Integer.parseInt(request.getParameter("duration"));
                String[] exerciseIdStrs = request.getParameterValues("exerciseIds");

                List<Integer> exerciseIds = new ArrayList<>();
                if (exerciseIdStrs != null) {
                    for (String ex : exerciseIdStrs) {
                        exerciseIds.add(Integer.parseInt(ex));
                    }
                }

                workoutService.createPlan(trainer.getId(), title, description, difficulty, duration, exerciseIds);
                response.sendRedirect(request.getContextPath() + "/trainer/workouts?success=Workout+plan+submitted+for+admin+approval!");

            } else if ("delete_workout".equals(action)) {
                int planId = Integer.parseInt(request.getParameter("planId"));
                workoutService.deletePlan(planId);
                response.sendRedirect(request.getContextPath() + "/trainer/workouts?success=Workout+plan+deleted");

            } else if ("create_exercise".equals(action)) {
                String name = request.getParameter("name");
                String description = request.getParameter("description");
                String muscleGroup = request.getParameter("muscleGroup");
                int sets = Integer.parseInt(request.getParameter("sets"));
                int reps = Integer.parseInt(request.getParameter("reps"));
                int duration = Integer.parseInt(request.getParameter("duration"));

                workoutService.createExercise(name, description, muscleGroup, sets, reps, duration);
                response.sendRedirect(request.getContextPath() + "/trainer/workouts?success=Exercise+added+to+catalog!");

            } else if ("send_message".equals(action)) {
                int receiverId = Integer.parseInt(request.getParameter("receiverId"));
                String content = request.getParameter("message");
                messageService.sendMessage(trainer.getId(), receiverId, content);
                response.sendRedirect(request.getContextPath() + "/trainer/messages?userId=" + receiverId + "&success=Message+sent");

            } else if ("assign_plan".equals(action)) {
                int memberId = Integer.parseInt(request.getParameter("memberId"));
                int planId = Integer.parseInt(request.getParameter("planId"));
                workoutService.assignPlanToMember(trainer.getId(), memberId, planId);
                response.sendRedirect(request.getContextPath() + "/trainer/workouts?success=Workout+plan+assigned+to+member+successfully!");

            } else if ("generate_report".equals(action)) {
                // Multithreading demonstration: Triggers ProgressReportThread
                int targetUserId = Integer.parseInt(request.getParameter("userId"));
                ProgressReportThread reportThread = new ProgressReportThread(targetUserId);
                reportThread.start();
                reportThread.join(1000); // Wait briefly or read from cached report
                String report = ProgressReportThread.getCachedReport(targetUserId);
                response.sendRedirect(request.getContextPath() + "/trainer/progress?userId=" + targetUserId + "&reportGenerated=true");

            } else {
                response.sendRedirect(request.getContextPath() + "/trainer/dashboard");
            }
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/trainer/dashboard?error=" + e.getMessage());
        }
    }

    private void handleDashboard(HttpServletRequest request, HttpServletResponse response, User trainer) 
            throws ServletException, IOException {
        List<WorkoutPlan> myPlans = workoutService.getPlansByTrainer(trainer.getId());
        long pendingCount = myPlans.stream().filter(WorkoutPlan::isPending).count();
        List<User> members = userDAO.findByRole("USER");
        List<com.fittrack.model.UserWorkoutPlan> enrolledMembers = workoutService.getEnrolledMembersForTrainer(trainer.getId());

        request.setAttribute("myPlans", myPlans);
        request.setAttribute("pendingCount", pendingCount);
        request.setAttribute("members", members);
        request.setAttribute("enrolledMembers", enrolledMembers);
        request.setAttribute("recentMessages", messageService.getRecentInteractions(trainer.getId()));
        request.getRequestDispatcher("/trainer/dashboard.jsp").forward(request, response);
    }

    private void handleWorkouts(HttpServletRequest request, HttpServletResponse response, User trainer) 
            throws ServletException, IOException {
        List<WorkoutPlan> myPlans = workoutService.getPlansByTrainer(trainer.getId());
        List<Exercise> allExercises = workoutService.getAllExercises();
        List<User> members = userDAO.findByRole("USER");
        List<com.fittrack.model.UserWorkoutPlan> enrolledMembers = workoutService.getEnrolledMembersForTrainer(trainer.getId());

        request.setAttribute("myPlans", myPlans);
        request.setAttribute("exercises", allExercises);
        request.setAttribute("members", members);
        request.setAttribute("enrolledMembers", enrolledMembers);
        request.getRequestDispatcher("/trainer/workouts.jsp").forward(request, response);
    }

    private void handleProgress(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        List<User> members = userDAO.findByRole("USER");
        request.setAttribute("members", members);

        String userIdParam = request.getParameter("userId");
        if (userIdParam != null && !userIdParam.isEmpty()) {
            int selectedUserId = Integer.parseInt(userIdParam);
            List<Progress> logs = progressService.getProgressHistory(selectedUserId);
            request.setAttribute("selectedUserId", selectedUserId);
            request.setAttribute("progressLogs", logs);
            request.setAttribute("cachedReport", ProgressReportThread.getCachedReport(selectedUserId));
        }

        request.getRequestDispatcher("/trainer/progress.jsp").forward(request, response);
    }

    private void handleMessages(HttpServletRequest request, HttpServletResponse response, User trainer) 
            throws ServletException, IOException {
        List<User> members = userDAO.findByRole("USER");
        request.setAttribute("contacts", members);

        String userIdParam = request.getParameter("userId");
        if (userIdParam != null && !userIdParam.isEmpty()) {
            int chatPartnerId = Integer.parseInt(userIdParam);
            request.setAttribute("activeChatPartnerId", chatPartnerId);
            request.setAttribute("conversation", messageService.getConversation(trainer.getId(), chatPartnerId));
        }

        request.getRequestDispatcher("/trainer/messages.jsp").forward(request, response);
    }
}
