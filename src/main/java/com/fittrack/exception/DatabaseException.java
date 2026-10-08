package com.fittrack.exception;

/**
 * Exception thrown when database operation errors occur (SQL, connection failure).
 */
public class DatabaseException extends RuntimeException {
    public DatabaseException(String message) {
        super(message);
    }

    public DatabaseException(String message, Throwable cause) {
        super(message, cause);
    }
}
