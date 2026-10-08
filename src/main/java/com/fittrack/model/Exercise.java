package com.fittrack.model;

import java.io.Serializable;

/**
 * Model representing an exercise routine item.
 */
public class Exercise implements Serializable {

    private static final long serialVersionUID = 1L;

    private int id;
    private String name;
    private String description;
    private String muscleGroup;
    private int sets;
    private int reps;
    private int duration; // in seconds or minutes

    public Exercise() {
    }

    public Exercise(int id, String name, String description, String muscleGroup, int sets, int reps, int duration) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.muscleGroup = muscleGroup;
        this.sets = sets;
        this.reps = reps;
        this.duration = duration;
    }

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

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getMuscleGroup() {
        return muscleGroup;
    }

    public void setMuscleGroup(String muscleGroup) {
        this.muscleGroup = muscleGroup;
    }

    public int getSets() {
        return sets;
    }

    public void setSets(int sets) {
        this.sets = sets;
    }

    public int getReps() {
        return reps;
    }

    public void setReps(int reps) {
        this.reps = reps;
    }

    public int getDuration() {
        return duration;
    }

    public void setDuration(int duration) {
        this.duration = duration;
    }

    public String getSummary() {
        return sets + " sets × " + reps + " reps" + (duration > 0 ? " (" + duration + "s rest/duration)" : "");
    }
}
