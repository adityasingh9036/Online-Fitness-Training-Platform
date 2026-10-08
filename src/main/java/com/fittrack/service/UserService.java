package com.fittrack.service;

import com.fittrack.dao.UserDAO;
import com.fittrack.dao.WorkoutPlanDAO;
import com.fittrack.exception.AuthenticationException;
import com.fittrack.exception.UserNotFoundException;
import com.fittrack.exception.ValidationException;
import com.fittrack.model.Admin;
import com.fittrack.model.FitnessUser;
import com.fittrack.model.Trainer;
import com.fittrack.model.User;
import com.fittrack.util.PasswordUtil;
import com.fittrack.util.ValidationUtil;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Service handling user management, authentication, and platform statistics.
 */
public class UserService {

    private final UserDAO userDAO;
    private final WorkoutPlanDAO workoutPlanDAO;

    public UserService() {
        this.userDAO = new UserDAO();
        this.workoutPlanDAO = new WorkoutPlanDAO();
    }

    public UserService(UserDAO userDAO, WorkoutPlanDAO workoutPlanDAO) {
        this.userDAO = userDAO;
        this.workoutPlanDAO = workoutPlanDAO;
    }

    /**
     * Authenticates a user by email and raw password.
     * Demonstrates Polymorphism & Interface usage (Authenticatable).
     */
    public User authenticate(String email, String rawPassword) throws AuthenticationException, ValidationException {
        ValidationUtil.validateEmail(email);
        ValidationUtil.validateNotEmpty(rawPassword, "Password");

        User user = userDAO.findByEmail(email);
        if (user == null) {
            throw new AuthenticationException("No account found with email: " + email);
        }

        if (!user.authenticate(rawPassword)) {
            throw new AuthenticationException("Invalid credentials. Please verify your password.");
        }

        return user;
    }

    /**
     * Registers a new user with hashed password.
     */
    public User registerUser(String name, String email, String rawPassword, String role) 
            throws ValidationException, AuthenticationException {
        ValidationUtil.validateNotEmpty(name, "Full Name");
        ValidationUtil.validateEmail(email);
        ValidationUtil.validatePassword(rawPassword);
        ValidationUtil.validateRole(role);

        User existing = userDAO.findByEmail(email);
        if (existing != null) {
            throw new AuthenticationException("An account already exists with email: " + email);
        }

        String hashedPassword = PasswordUtil.hashPassword(rawPassword);
        String upperRole = role.trim().toUpperCase();

        User newUser;
        if ("ADMIN".equals(upperRole)) {
            newUser = new Admin();
        } else if ("TRAINER".equals(upperRole)) {
            newUser = new Trainer();
        } else {
            newUser = new FitnessUser();
        }

        newUser.setName(name.trim());
        newUser.setEmail(email.trim().toLowerCase());
        newUser.setPassword(hashedPassword);
        newUser.setRole(upperRole);

        boolean saved = userDAO.save(newUser);
        if (!saved) {
            throw new AuthenticationException("Failed to complete user registration.");
        }

        return newUser;
    }

    public List<User> getAllUsers() {
        return userDAO.findAll();
    }

    public List<User> getUsersByRole(String role) {
        return userDAO.findByRole(role);
    }

    public User getUserById(int id) throws UserNotFoundException {
        User user = userDAO.findById(id);
        if (user == null) {
            throw new UserNotFoundException("User not found with ID: " + id);
        }
        return user;
    }

    public boolean updateUser(int id, String name, String email, String role) 
            throws ValidationException, UserNotFoundException {
        ValidationUtil.validateNotEmpty(name, "Full Name");
        ValidationUtil.validateEmail(email);
        ValidationUtil.validateRole(role);

        User user = getUserById(id);
        user.setName(name.trim());
        user.setEmail(email.trim().toLowerCase());
        user.setRole(role.trim().toUpperCase());

        return userDAO.update(user);
    }

    public boolean deleteUser(int id) throws UserNotFoundException {
        getUserById(id); // Ensure exists
        return userDAO.delete(id);
    }

    /**
     * Aggregates key metrics for the Admin Dashboard.
     */
    public Map<String, Object> getAdminDashboardStats() {
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalUsers", userDAO.countTotalUsers());
        stats.put("totalTrainers", userDAO.countByRole("TRAINER"));
        stats.put("totalMembers", userDAO.countByRole("USER"));
        stats.put("totalPlans", workoutPlanDAO.countTotalPlans());
        stats.put("pendingPlans", workoutPlanDAO.countPendingPlans());
        return stats;
    }
}
