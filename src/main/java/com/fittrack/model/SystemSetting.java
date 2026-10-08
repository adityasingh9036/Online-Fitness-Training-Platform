package com.fittrack.model;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * Model representing platform-wide configuration settings managed by Admin.
 */
public class SystemSetting implements Serializable {

    private static final long serialVersionUID = 1L;

    private int id;
    private String settingName;
    private String settingValue;
    private Timestamp updatedAt;

    public SystemSetting() {
    }

    public SystemSetting(int id, String settingName, String settingValue, Timestamp updatedAt) {
        this.id = id;
        this.settingName = settingName;
        this.settingValue = settingValue;
        this.updatedAt = updatedAt;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getSettingName() {
        return settingName;
    }

    public void setSettingName(String settingName) {
        this.settingName = settingName;
    }

    public String getSettingValue() {
        return settingValue;
    }

    public void setSettingValue(String settingValue) {
        this.settingValue = settingValue;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }
}
