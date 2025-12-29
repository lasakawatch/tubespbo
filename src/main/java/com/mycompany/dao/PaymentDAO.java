package com.mycompany.dao;

import com.mycompany.db.DatabaseConnection;
import com.mycompany.model.Payment;
import com.mycompany.model.RentalSession;
import com.mycompany.model.enums.PaymentMethod;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * PaymentDAO - Data Access Object untuk Payment
 */
public class PaymentDAO {
    private SessionDAO sessionDAO = new SessionDAO();
    
    /**
     * Create new payment
     */
    public int createPayment(int sessionId, int amount, PaymentMethod method) {
        String sql = "INSERT INTO payments (session_id, amount, method, paid_at) VALUES (?, ?, ?, ?)";
        
        try (Connection conn = DatabaseConnection.connect();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            pstmt.setInt(1, sessionId);
            pstmt.setInt(2, amount);
            pstmt.setString(3, method.name());
            pstmt.setTimestamp(4, new Timestamp(System.currentTimeMillis()));
            
            int affected = pstmt.executeUpdate();
            if (affected > 0) {
                ResultSet rs = pstmt.getGeneratedKeys();
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }
    
    /**
     * Get payment by ID
     */
    public Payment getPaymentById(int id) {
        String sql = "SELECT * FROM payments WHERE id = ?";
        
        try (Connection conn = DatabaseConnection.connect();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, id);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                RentalSession session = sessionDAO.getSessionById(rs.getInt("session_id"));
                return new Payment(
                    rs.getInt("id"),
                    session,
                    rs.getInt("amount"),
                    PaymentMethod.valueOf(rs.getString("method")),
                    rs.getTimestamp("paid_at")
                );
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    /**
     * Get payment by session ID
     */
    public Payment getPaymentBySessionId(int sessionId) {
        String sql = "SELECT * FROM payments WHERE session_id = ?";
        
        try (Connection conn = DatabaseConnection.connect();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, sessionId);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                RentalSession session = sessionDAO.getSessionById(sessionId);
                return new Payment(
                    rs.getInt("id"),
                    session,
                    rs.getInt("amount"),
                    PaymentMethod.valueOf(rs.getString("method")),
                    rs.getTimestamp("paid_at")
                );
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    /**
     * Get all payments
     */
    public List<Payment> getAllPayments() {
        List<Payment> payments = new ArrayList<>();
        String sql = "SELECT * FROM payments ORDER BY paid_at DESC";
        
        try (Connection conn = DatabaseConnection.connect();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                RentalSession session = sessionDAO.getSessionById(rs.getInt("session_id"));
                Payment payment = new Payment(
                    rs.getInt("id"),
                    session,
                    rs.getInt("amount"),
                    PaymentMethod.valueOf(rs.getString("method")),
                    rs.getTimestamp("paid_at")
                );
                payments.add(payment);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return payments;
    }
    
    /**
     * Find all payments
     */
    public List<Payment> findAll() {
        return getAllPayments();
    }
    
    /**
     * Find payment by session ID
     */
    public Payment findBySessionId(int sessionId) {
        String sql = "SELECT * FROM payments WHERE session_id = ?";
        
        try (Connection conn = DatabaseConnection.connect();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, sessionId);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                Payment payment = new Payment();
                payment.setId(rs.getInt("id"));
                payment.setSessionId(rs.getInt("session_id"));
                payment.setAmount(rs.getDouble("amount"));
                payment.setPaymentMethod(PaymentMethod.valueOf(rs.getString("method")));
                payment.setPaymentTime(rs.getTimestamp("paid_at"));
                return payment;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    /**
     * Save payment
     */
    public boolean save(Payment payment) {
        String sql = "INSERT INTO payments (session_id, amount, method, paid_at) VALUES (?, ?, ?, ?)";
        
        try (Connection conn = DatabaseConnection.connect();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            pstmt.setInt(1, payment.getSessionId());
            pstmt.setDouble(2, payment.getAmount());
            pstmt.setString(3, payment.getPaymentMethod().name());
            pstmt.setTimestamp(4, new Timestamp(payment.getPaymentTime().getTime()));
            
            int affected = pstmt.executeUpdate();
            if (affected > 0) {
                ResultSet rs = pstmt.getGeneratedKeys();
                if (rs.next()) {
                    payment.setId(rs.getInt(1));
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
