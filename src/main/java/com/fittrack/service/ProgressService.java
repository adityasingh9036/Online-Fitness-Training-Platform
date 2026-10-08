package com.fittrack.service;

import com.fittrack.dao.ProgressDAO;
import com.fittrack.exception.ValidationException;
import com.fittrack.model.Progress;
import com.fittrack.util.ValidationUtil;

import java.sql.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Service managing user fitness logs, trend calculations, and progress analytics.
 */
public class ProgressService {

    private final ProgressDAO progressDAO;

    public ProgressService() {
        this.progressDAO = new ProgressDAO();
    }

    public ProgressService(ProgressDAO progressDAO) {
        this.progressDAO = progressDAO;
    }

    public Progress logProgress(int userId, double weight, double height,
                                String bodyMeasurement, String fitnessGoal, Date recordDate) 
            throws ValidationException {
        ValidationUtil.validatePositiveNumber(weight, "Weight");
        ValidationUtil.validatePositiveNumber(height, "Height");
        ValidationUtil.validateNotEmpty(fitnessGoal, "Fitness Goal");

        Progress p = new Progress(
                0,
                userId,
                Math.round(weight * 100.0) / 100.0,
                Math.round(height * 100.0) / 100.0,
                bodyMeasurement != null ? bodyMeasurement.trim() : "",
                fitnessGoal.trim(),
                recordDate != null ? recordDate : new Date(System.currentTimeMillis())
        );

        progressDAO.save(p);
        return p;
    }

    public List<Progress> getProgressHistory(int userId) {
        return progressDAO.findByUserId(userId);
    }

    public Progress getLatestProgress(int userId) {
        return progressDAO.findLatestByUserId(userId);
    }

    public boolean deleteProgress(int id) {
        return progressDAO.delete(id);
    }

    /**
     * Calculates overall progress summary for dashboard metrics.
     */
    public Map<String, Object> calculateProgressSummary(int userId) {
        List<Progress> list = progressDAO.findByUserId(userId);
        Map<String, Object> summary = new HashMap<>();

        if (list == null || list.isEmpty()) {
            summary.put("hasData", false);
            summary.put("currentWeight", 0.0);
            summary.put("startWeight", 0.0);
            summary.put("netChange", 0.0);
            summary.put("currentBmi", 0.0);
            summary.put("bmiCategory", "N/A");
            summary.put("logsCount", 0);
            return summary;
        }

        Progress latest = list.get(0);
        Progress earliest = list.get(list.size() - 1);
        double netChange = Math.round((latest.getWeight() - earliest.getWeight()) * 10.0) / 10.0;

        summary.put("hasData", true);
        summary.put("currentWeight", latest.getWeight());
        summary.put("startWeight", earliest.getWeight());
        summary.put("netChange", netChange);
        summary.put("currentBmi", latest.calculateBMI());
        summary.put("bmiCategory", latest.getBMICategory());
        summary.put("currentGoal", latest.getFitnessGoal());
        summary.put("logsCount", list.size());

        return summary;
    }
}
