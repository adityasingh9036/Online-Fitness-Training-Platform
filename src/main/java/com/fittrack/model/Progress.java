package com.fittrack.model;

import java.io.Serializable;
import java.sql.Date;

/**
 * Model representing recorded fitness progress of a user.
 * Encapsulates BMI calculation and fitness metrics.
 */
public class Progress implements Serializable {

    private static final long serialVersionUID = 1L;

    private int id;
    private int userId;
    private String userName;
    private double weight; // kg
    private double height; // cm
    private String bodyMeasurement;
    private String fitnessGoal;
    private Date recordDate;
    private double weightChange; // calculated relative to previous record

    public Progress() {
    }

    public Progress(int id, int userId, double weight, double height,
                    String bodyMeasurement, String fitnessGoal, Date recordDate) {
        this.id = id;
        this.userId = userId;
        this.weight = weight;
        this.height = height;
        this.bodyMeasurement = bodyMeasurement;
        this.fitnessGoal = fitnessGoal;
        this.recordDate = recordDate;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public double getWeight() {
        return weight;
    }

    public void setWeight(double weight) {
        this.weight = weight;
    }

    public double getHeight() {
        return height;
    }

    public void setHeight(double height) {
        this.height = height;
    }

    public String getBodyMeasurement() {
        return bodyMeasurement;
    }

    public void setBodyMeasurement(String bodyMeasurement) {
        this.bodyMeasurement = bodyMeasurement;
    }

    public String getFitnessGoal() {
        return fitnessGoal;
    }

    public void setFitnessGoal(String fitnessGoal) {
        this.fitnessGoal = fitnessGoal;
    }

    public Date getRecordDate() {
        return recordDate;
    }

    public void setRecordDate(Date recordDate) {
        this.recordDate = recordDate;
    }

    public double getWeightChange() {
        return weightChange;
    }

    public void setWeightChange(double weightChange) {
        this.weightChange = weightChange;
    }

    /**
     * Calculates Body Mass Index (BMI).
     * Formula: weight (kg) / (height (m) ^ 2)
     */
    public double calculateBMI() {
        if (height <= 0 || weight <= 0) {
            return 0.0;
        }
        double heightMeters = height / 100.0;
        double bmi = weight / (heightMeters * heightMeters);
        return Math.round(bmi * 10.0) / 10.0;
    }

    /**
     * Returns standard WHO BMI category.
     */
    public String getBMICategory() {
        double bmi = calculateBMI();
        if (bmi <= 0) return "N/A";
        if (bmi < 18.5) return "Underweight";
        if (bmi < 25.0) return "Normal Weight";
        if (bmi < 30.0) return "Overweight";
        return "Obese";
    }
}
