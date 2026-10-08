package com.fittrack.model;

/**
 * Interface defining authentication contract for all system users.
 * Part of University Rubric (3.1 OOP - Interfaces).
 */
public interface Authenticatable {

    int getId();

    String getEmail();

    String getPassword();

    String getRole();

    boolean authenticate(String rawPassword);
}
