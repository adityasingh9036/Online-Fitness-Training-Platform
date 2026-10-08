package com.fittrack.servlet;

import com.fittrack.model.Progress;
import com.fittrack.model.User;
import com.fittrack.service.ProgressService;
import com.fittrack.thread.ProgressReportThread;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Date;
import java.util.List;
import java.util.Map;

/**
 * Servlet handling member fitness progress logging, trend summaries,
 * and multithreaded performance report generation.
 */
@WebServlet(name = "ProgressServlet", urlPatterns = {
        "/user/progress",
        "/user/progress/log",
        "/user/progress/delete",
        "/user/progress/generate-report"
})
public class ProgressServlet extends HttpServlet {

    private final ProgressService progressService = new ProgressService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("currentUser");

        List<Progress> history = progressService.getProgressHistory(user.getId());
        Map<String, Object> summary = progressService.calculateProgressSummary(user.getId());
        String cachedReport = ProgressReportThread.getCachedReport(user.getId());

        request.setAttribute("progressList", history);
        request.setAttribute("summary", summary);
        request.setAttribute("cachedReport", cachedReport);

        request.getRequestDispatcher("/user/progress.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("currentUser");
        String path = request.getServletPath();

        try {
            if ("/user/progress/log".equals(path)) {
                double weight = Double.parseDouble(request.getParameter("weight"));
                double height = Double.parseDouble(request.getParameter("height"));
                String measurements = request.getParameter("bodyMeasurement");
                String goal = request.getParameter("fitnessGoal");
                String dateStr = request.getParameter("recordDate");

                Date recordDate = (dateStr != null && !dateStr.isEmpty()) 
                        ? Date.valueOf(dateStr) 
                        : new Date(System.currentTimeMillis());

                progressService.logProgress(user.getId(), weight, height, measurements, goal, recordDate);

                // Asynchronously trigger background report generation thread
                ProgressReportThread reportThread = new ProgressReportThread(user.getId());
                reportThread.start();

                response.sendRedirect(request.getContextPath() + "/user/progress?success=Fitness+metrics+recorded+successfully!");

            } else if ("/user/progress/delete".equals(path)) {
                int progressId = Integer.parseInt(request.getParameter("id"));
                progressService.deleteProgress(progressId);
                response.sendRedirect(request.getContextPath() + "/user/progress?success=Log+deleted+successfully");

            } else if ("/user/progress/generate-report".equals(path)) {
                // Explicitly spawn background thread to recalculate report
                ProgressReportThread reportThread = new ProgressReportThread(user.getId());
                reportThread.start();
                reportThread.join(800); // Give quick wait or refresh
                response.sendRedirect(request.getContextPath() + "/user/progress?reportGenerated=true");

            } else {
                response.sendRedirect(request.getContextPath() + "/user/progress");
            }
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/user/progress?error=" + e.getMessage());
        }
    }
}
