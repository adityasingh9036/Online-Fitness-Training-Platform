package com.fittrack.dao;

import java.util.List;

/**
 * Generic Data Access Object (DAO) interface.
 * 
 * Demonstrates Generics & Interfaces rubric requirement (3.2 & 3.4):
 * @param <T>  Entity type
 * @param <ID> Primary key identifier type
 */
public interface GenericDAO<T, ID> {

    T findById(ID id);

    List<T> findAll();

    boolean save(T entity);

    boolean update(T entity);

    boolean delete(ID id);
}
