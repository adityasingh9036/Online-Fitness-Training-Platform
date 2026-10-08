package com.fittrack.dao;

import com.fittrack.exception.DatabaseException;
import com.fittrack.model.SystemSetting;
import com.fittrack.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Data Access Object for Platform System Settings.
 */
public class SystemSettingsDAO implements GenericDAO<SystemSetting, Integer> {

    @Override
    public SystemSetting findById(Integer id) {
        String sql = "SELECT id, setting_name, setting_value, updated_at FROM system_settings WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToSetting(rs);
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Error finding setting by ID: " + id, e);
        }
        return null;
    }

    public SystemSetting findBySettingName(String settingName) {
        String sql = "SELECT id, setting_name, setting_value, updated_at FROM system_settings WHERE setting_name = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, settingName.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToSetting(rs);
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Error finding setting: " + settingName, e);
        }
        return null;
    }

    public String getSettingValue(String settingName, String defaultValue) {
        SystemSetting setting = findBySettingName(settingName);
        return setting != null ? setting.getSettingValue() : defaultValue;
    }

    @Override
    public List<SystemSetting> findAll() {
        List<SystemSetting> list = new ArrayList<>();
        String sql = "SELECT id, setting_name, setting_value, updated_at FROM system_settings ORDER BY setting_name ASC";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                list.add(mapRowToSetting(rs));
            }
        } catch (SQLException e) {
            throw new DatabaseException("Error retrieving system settings", e);
        }
        return list;
    }

    public Map<String, String> getAllSettingsAsMap() {
        Map<String, String> map = new HashMap<>();
        List<SystemSetting> list = findAll();
        for (SystemSetting s : list) {
            map.put(s.getSettingName(), s.getSettingValue());
        }
        return map;
    }

    @Override
    public boolean save(SystemSetting setting) {
        String sql = "INSERT INTO system_settings (setting_name, setting_value) VALUES (?, ?) " +
                     "ON CONFLICT (setting_name) DO UPDATE SET setting_value = EXCLUDED.setting_value, updated_at = CURRENT_TIMESTAMP RETURNING id, updated_at";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, setting.getSettingName());
            ps.setString(2, setting.getSettingValue());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    setting.setId(rs.getInt("id"));
                    setting.setUpdatedAt(rs.getTimestamp("updated_at"));
                    return true;
                }
            }
        } catch (SQLException e) {
            throw new DatabaseException("Error saving system setting: " + setting.getSettingName(), e);
        }
        return false;
    }

    @Override
    public boolean update(SystemSetting setting) {
        return updateSetting(setting.getSettingName(), setting.getSettingValue());
    }

    public boolean updateSetting(String settingName, String settingValue) {
        String sql = "INSERT INTO system_settings (setting_name, setting_value) VALUES (?, ?) " +
                     "ON CONFLICT (setting_name) DO UPDATE SET setting_value = EXCLUDED.setting_value, updated_at = CURRENT_TIMESTAMP";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, settingName);
            ps.setString(2, settingValue);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new DatabaseException("Error updating setting: " + settingName, e);
        }
    }

    @Override
    public boolean delete(Integer id) {
        String sql = "DELETE FROM system_settings WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new DatabaseException("Error deleting setting ID: " + id, e);
        }
    }

    private SystemSetting mapRowToSetting(ResultSet rs) throws SQLException {
        return new SystemSetting(
                rs.getInt("id"),
                rs.getString("setting_name"),
                rs.getString("setting_value"),
                rs.getTimestamp("updated_at")
        );
    }
}
