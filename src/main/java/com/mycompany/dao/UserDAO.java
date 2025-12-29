package com.mycompany.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.mycompany.db.DatabaseConnection;
import com.mycompany.model.Admin;
import com.mycompany.model.Operator;

/**
 * UserDAO - Data Access Object untuk Admin dan Operator
 * Versi Perbaikan: Menangani Null Connection
 */
public class UserDAO {
    
    /**
     * Login untuk Admin
     */
    public Admin loginAdmin(String username, String password) {
        String sql = "SELECT * FROM admins WHERE username = ? AND password_hash = ?";
        String passwordHash = Operator.hashPassword(password);
        
        Connection conn = DatabaseConnection.connect();
        if (conn == null) return null; // Cegah NullPointerException

        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, username);
            pstmt.setString(2, passwordHash);
            
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return new Admin(
                    rs.getInt("id"),
                    rs.getString("name"),
                    rs.getString("phone_number"),
                    rs.getString("address"),
                    rs.getString("username"),
                    rs.getString("password_hash")
                );
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    /**
     * Login untuk Operator
     */
    public Operator loginOperator(String username, String password) {
        String sql = "SELECT * FROM operators WHERE username = ? AND password_hash = ?";
        String passwordHash = Operator.hashPassword(password);
        
        // Debug logging
        System.out.println("[DEBUG] Login Operator - Username: " + username);
        System.out.println("[DEBUG] Password Hash: " + passwordHash);
        
        Connection conn = DatabaseConnection.connect();
        if (conn == null) return null; // Cegah error koneksi

        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, username);
            pstmt.setString(2, passwordHash);
            
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return new Operator(
                    rs.getInt("id"),
                    rs.getString("name"),
                    rs.getString("phone_number"),
                    rs.getString("address"),
                    rs.getString("username"),
                    rs.getString("password_hash")
                );
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    /**
     * Register Operator baru
     */
    public boolean registerOperator(Operator operator) {
        String sql = "INSERT INTO operators (name, phone_number, address, username, password_hash) VALUES (?, ?, ?, ?, ?)";
        
        Connection conn = DatabaseConnection.connect();
        if (conn == null) {
            System.err.println("Gagal Register: Koneksi Database Null");
            return false;
        }

        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, operator.getName());
            pstmt.setString(2, operator.getPhoneNumber());
            pstmt.setString(3, operator.getAddress());
            pstmt.setString(4, operator.getUsername());
            pstmt.setString(5, operator.getPasswordHash());
            
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Get all operators
     */
    public List<Operator> getAllOperators() {
        List<Operator> operators = new ArrayList<>();
        String sql = "SELECT * FROM operators ORDER BY id DESC";
        
        Connection conn = DatabaseConnection.connect();
        if (conn == null) return operators;

        try (Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                operators.add(new Operator(
                    rs.getInt("id"),
                    rs.getString("name"),
                    rs.getString("phone_number"),
                    rs.getString("address"),
                    rs.getString("username"),
                    rs.getString("password_hash")
                ));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return operators;
    }
    
    /**
     * Check if username exists (Tempat Error Sebelumnya)
     */
    public boolean usernameExists(String username) {
        String sql = "SELECT COUNT(*) FROM operators WHERE username = ?";
        
        // AMBIL KONEKSI DULU
        Connection conn = DatabaseConnection.connect();
        
        // CEK KONEKSI: Jika null, print error di console server, jangan biarkan crash
        if (conn == null) {
            System.err.println("CRITICAL ERROR: Database connection is NULL in usernameExists!");
            System.err.println("Pastikan MySQL XAMPP Running dan Port 3306 benar.");
            return false; 
        }

        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, username);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            System.err.println("SQL Error di usernameExists: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Find all operators with additional fields
     */
    public List<Operator> findAllOperators() {
        List<Operator> operators = new ArrayList<>();
        String sql = "SELECT * FROM operators ORDER BY id DESC";
        
        Connection conn = DatabaseConnection.connect();
        if (conn == null) return operators;

        try (Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                Operator op = new Operator(
                    rs.getInt("id"),
                    rs.getString("name"),
                    rs.getString("phone_number"),
                    rs.getString("address"),
                    rs.getString("username"),
                    rs.getString("password_hash")
                );
                op.setEmail(rs.getString("email"));
                op.setShift(rs.getString("shift"));
                operators.add(op);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return operators;
    }
    
    /**
     * Find operator by ID
     */
    public Operator findOperatorById(int id) {
        String sql = "SELECT * FROM operators WHERE id = ?";
        
        Connection conn = DatabaseConnection.connect();
        if (conn == null) return null;

        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                Operator op = new Operator(
                    rs.getInt("id"),
                    rs.getString("name"),
                    rs.getString("phone_number"),
                    rs.getString("address"),
                    rs.getString("username"),
                    rs.getString("password_hash")
                );
                op.setEmail(rs.getString("email"));
                op.setShift(rs.getString("shift"));
                return op;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    /**
     * Save new operator (Admin Dashboard)
     */
    public boolean saveOperator(Operator operator) {
        String sql = "INSERT INTO operators (name, phone_number, address, username, password_hash, email, shift) VALUES (?, ?, ?, ?, ?, ?, ?)";
        
        Connection conn = DatabaseConnection.connect();
        if (conn == null) return false;

        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, operator.getName());
            pstmt.setString(2, operator.getPhone());
            pstmt.setString(3, operator.getAddress());
            pstmt.setString(4, operator.getUsername());
            pstmt.setString(5, operator.getPassword());
            pstmt.setString(6, operator.getEmail());
            pstmt.setString(7, operator.getShift());
            
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Update operator
     */
    public boolean updateOperator(Operator operator) {
        String sql = "UPDATE operators SET name = ?, phone_number = ?, username = ?, email = ?, shift = ? WHERE id = ?";
        
        Connection conn = DatabaseConnection.connect();
        if (conn == null) return false;

        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, operator.getName());
            pstmt.setString(2, operator.getPhone());
            pstmt.setString(3, operator.getUsername());
            pstmt.setString(4, operator.getEmail());
            pstmt.setString(5, operator.getShift());
            pstmt.setInt(6, operator.getId());
            
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Delete operator
     */
    public boolean deleteOperator(int id) {
        String sql = "DELETE FROM operators WHERE id = ?";
        
        Connection conn = DatabaseConnection.connect();
        if (conn == null) return false;

        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}