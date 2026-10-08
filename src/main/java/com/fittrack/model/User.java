package com.fittrack.model;

import com.fittrack.util.PasswordUtil;
import java.io.Serializable;
import java.sql.Timestamp;

/**
 * Abstract Base Class for FitTrack Users.
 * 
 * Demonstrates:
 * - Abstraction: Abstract methods representing polymorphic role behavior
 * - Encapsulation: Private member variables with public getters and setters
 * - Interface Implementation: Authenticatable and DashboardAccess
 */
public abstract class User implements Authenticatable, DashboardAccess, Serializable {

    private static final long serialVersionUID = 1L;

    private int id;
    private String name;
    private String email;
    private String password;
    private String role;
    private Timestamp createdAt;

    public User() {
    }

    public User(int id, String name, String email, String password, String role, Timestamp createdAt) {
        this.id = id;
        this.name = name;
        this.email = email;
        this.password = password;
        this.role = role;
        this.createdAt = createdAt;
    }

    // Encapsulation - Getters & Setters
    @Override
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    @Override
    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    @Override
    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    @Override
    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    // Authentication Contract
    @Override
    public boolean authenticate(String rawPassword) {
        return PasswordUtil.verifyPassword(rawPassword, this.password);
    }

    // Abstract polymorphic methods to be implemented by sub-classes
    public abstract String getRoleTitle();

    public abstract String getPermissionsOverview();

    @Override
    public String toString() {
        return "User{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", email='" + email + '\'' +
                ", role='" + role + '\'' +
                '}';
    }
}
