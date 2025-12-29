package com.mycompany.dao;

import com.mycompany.db.DatabaseConnection;
import com.mycompany.model.ConsoleUnit;
import com.mycompany.model.enums.ConsoleType;
import com.mycompany.model.enums.ConsoleStatus;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * ConsoleDAO - Data Access Object untuk ConsoleUnit
 */
public class ConsoleDAO {
    
    /**
     * Find all consoles (alias for getAllConsoles)
     */
    public List<ConsoleUnit> findAll() {
        return getAllConsoles();
    }
    
    /**
     * Find console by ID (alias for getConsoleById)
     */
    public ConsoleUnit findById(int id) {
        return getConsoleById(id);
    }
    
    /**
     * Find consoles by status
     */
    public List<ConsoleUnit> findByStatus(ConsoleStatus status) {
        List<ConsoleUnit> consoles = new ArrayList<>();
        String sql = "SELECT * FROM consoles WHERE status = ? ORDER BY id";
        
        try (Connection conn = DatabaseConnection.connect();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, status.name());
            ResultSet rs = pstmt.executeQuery();
            
            while (rs.next()) {
                ConsoleUnit console = new ConsoleUnit(
                    rs.getInt("id"),
                    ConsoleType.valueOf(rs.getString("type")),
                    rs.getString("serial_number"),
                    ConsoleStatus.valueOf(rs.getString("status")),
                    rs.getInt("base_hourly_rate"),
                    rs.getInt("controllers_available")
                );
                consoles.add(console);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return consoles;
    }
    
    /**
     * Get all consoles
     */
    public List<ConsoleUnit> getAllConsoles() {
        List<ConsoleUnit> consoles = new ArrayList<>();
        String sql = "SELECT * FROM consoles ORDER BY id";
        
        try (Connection conn = DatabaseConnection.connect();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                ConsoleUnit console = new ConsoleUnit(
                    rs.getInt("id"),
                    ConsoleType.valueOf(rs.getString("type")),
                    rs.getString("serial_number"),
                    ConsoleStatus.valueOf(rs.getString("status")),
                    rs.getInt("base_hourly_rate"),
                    rs.getInt("controllers_available")
                );
                consoles.add(console);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return consoles;
    }
    
    /**
     * Get available consoles
     */
    public List<ConsoleUnit> getAvailableConsoles() {
        List<ConsoleUnit> consoles = new ArrayList<>();
        String sql = "SELECT * FROM consoles WHERE status = 'AVAILABLE' ORDER BY id";
        
        try (Connection conn = DatabaseConnection.connect();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                ConsoleUnit console = new ConsoleUnit(
                    rs.getInt("id"),
                    ConsoleType.valueOf(rs.getString("type")),
                    rs.getString("serial_number"),
                    ConsoleStatus.valueOf(rs.getString("status")),
                    rs.getInt("base_hourly_rate"),
                    rs.getInt("controllers_available")
                );
                consoles.add(console);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return consoles;
    }
    
    /**
     * Get console by ID
     */
    public ConsoleUnit getConsoleById(int id) {
        String sql = "SELECT * FROM consoles WHERE id = ?";
        
        try (Connection conn = DatabaseConnection.connect();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, id);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                return new ConsoleUnit(
                    rs.getInt("id"),
                    ConsoleType.valueOf(rs.getString("type")),
                    rs.getString("serial_number"),
                    ConsoleStatus.valueOf(rs.getString("status")),
                    rs.getInt("base_hourly_rate"),
                    rs.getInt("controllers_available")
                );
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    /**
     * Update console status
     */
    public boolean updateConsoleStatus(int id, ConsoleStatus status) {
        String sql = "UPDATE consoles SET status = ? WHERE id = ?";
        
        try (Connection conn = DatabaseConnection.connect();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, status.name());
            pstmt.setInt(2, id);
            
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Add new console
     */
    public boolean addConsole(ConsoleUnit console) {
        String sql = "INSERT INTO consoles (type, serial_number, status, base_hourly_rate, controllers_available) VALUES (?, ?, ?, ?, ?)";
        
        try (Connection conn = DatabaseConnection.connect();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            // Generate serial number if not set
            String serialNumber = console.getSerialNumber();
            if (serialNumber == null || serialNumber.isEmpty()) {
                serialNumber = console.getType().name() + "-" + String.format("%03d", getNextId()) + "-2024";
            }
            
            pstmt.setString(1, console.getType().name());
            pstmt.setString(2, serialNumber);
            pstmt.setString(3, console.getStatus().name());
            pstmt.setInt(4, console.getBaseHourlyRate());
            pstmt.setInt(5, console.getControllersAvailable() > 0 ? console.getControllersAvailable() : 2);
            
            int affected = pstmt.executeUpdate();
            if (affected > 0) {
                ResultSet rs = pstmt.getGeneratedKeys();
                if (rs.next()) {
                    console.setId(rs.getInt(1));
                    console.setSerialNumber(serialNumber);
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Get next ID for console
     */
    private int getNextId() {
        String sql = "SELECT COALESCE(MAX(id), 0) + 1 FROM consoles";
        
        try (Connection conn = DatabaseConnection.connect();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 1;
    }
    
    /**
     * Save console (alias for addConsole)
     */
    public boolean save(ConsoleUnit console) {
        return addConsole(console);
    }
    
    /**
     * Update console
     */
    public boolean update(ConsoleUnit console) {
        String sql = "UPDATE consoles SET type = ?, serial_number = ?, status = ?, base_hourly_rate = ?, controllers_available = ? WHERE id = ?";
        
        try (Connection conn = DatabaseConnection.connect();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, console.getType().name());
            pstmt.setString(2, console.getSerialNumber());
            pstmt.setString(3, console.getStatus().name());
            pstmt.setInt(4, console.getBaseHourlyRate());
            pstmt.setInt(5, console.getControllersAvailable());
            pstmt.setInt(6, console.getId());
            
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Delete console by ID
     */
    public boolean delete(int id) {
        String sql = "DELETE FROM consoles WHERE id = ?";
        
        try (Connection conn = DatabaseConnection.connect();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, id);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
