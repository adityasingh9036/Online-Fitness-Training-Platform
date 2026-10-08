package com.fittrack.model;

import java.sql.Timestamp;

/**
 * Concrete Admin role representation.
 * Overrides User methods with Admin-specific permissions and navigation.
 */
public class Admin extends User {

    private static final long serialVersionUID = 1L;
    private String adminLevel = "SUPER_ADMIN";

    public Admin() {
        super();
        setRole("ADMIN");
    }

    public Admin(int id, String name, String email, String password, Timestamp createdAt) {
        super(id, name, email, password, "ADMIN", createdAt);
    }

    public String getAdminLevel() {
        return adminLevel;
    }

    public void setAdminLevel(String adminLevel) {
        this.adminLevel = adminLevel;
    }

    @Override
    public String getRoleTitle() {
        return "System Administrator";
    }

    @Override
    public String getPermissionsOverview() {
        return "Full Administrative Access: User management, plan approvals, and system settings.";
    }

    @Override
    public String getDashboardUrl() {
        return "admin/dashboard";
    }

    @Override
    public String getRoleBadgeColor() {
        return "badge-danger";
    }

    @Override
    public String getRoleDescription() {
        return "Platform Manager & Content Approver";
    }
}
