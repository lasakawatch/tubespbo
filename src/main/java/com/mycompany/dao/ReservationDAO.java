package com.mycompany.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import com.mycompany.db.DatabaseConnection;
import com.mycompany.model.Reservation;
import com.mycompany.model.Room;

/**
 * ReservationDAO - Data Access Object untuk Reservation
 */
public class ReservationDAO {
    private RoomDAO roomDAO = new RoomDAO();
    
    /**
     * PERBAIKAN 1: Find pending reservations
     * Mencari data dengan status 'PENDING' agar muncul di dashboard operator
     */
    public List<Reservation> findPending() {
        List<Reservation> reservations = new ArrayList<>();
        // Query khusus untuk status PENDING
        String sql = "SELECT * FROM reservations WHERE status = 'PENDING' ORDER BY start_time";
        
        try (Connection conn = DatabaseConnection.connect();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                Room room = roomDAO.getRoomById(rs.getInt("room_id"));
                Reservation reservation = new Reservation(
                    rs.getInt("id"),
                    rs.getString("customer_name"),
                    rs.getString("customer_phone"),
                    room,
                    rs.getTimestamp("start_time"),
                    rs.getTimestamp("end_time"),
                    rs.getInt("deposit"),
                    rs.getString("status")
                );
                
                // Tambahan: Ambil tipe console jika kolom tersedia (untuk display di tabel)
                try {
                    String consoleTypeStr = rs.getString("console_type");
                    if (consoleTypeStr != null) {
                         reservation.setConsoleType(com.mycompany.model.enums.ConsoleType.valueOf(consoleTypeStr));
                    }
                } catch (Exception e) {
                    // Abaikan jika kolom tidak ada
                }
                
                reservations.add(reservation);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return reservations;
    }
    
    /**
     * Get all reservations
     */
    public List<Reservation> getAllReservations() {
        List<Reservation> reservations = new ArrayList<>();
        String sql = "SELECT * FROM reservations ORDER BY start_time DESC";
        
        try (Connection conn = DatabaseConnection.connect();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                Room room = roomDAO.getRoomById(rs.getInt("room_id"));
                Reservation reservation = new Reservation(
                    rs.getInt("id"),
                    rs.getString("customer_name"),
                    rs.getString("customer_phone"),
                    room,
                    rs.getTimestamp("start_time"),
                    rs.getTimestamp("end_time"),
                    rs.getInt("deposit"),
                    rs.getString("status")
                );
                reservations.add(reservation);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return reservations;
    }
    
    /**
     * Get active reservations
     */
    public List<Reservation> getActiveReservations() {
        List<Reservation> reservations = new ArrayList<>();
        String sql = "SELECT * FROM reservations WHERE status = 'ACTIVE' ORDER BY start_time";
        
        try (Connection conn = DatabaseConnection.connect();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                Room room = roomDAO.getRoomById(rs.getInt("room_id"));
                Reservation reservation = new Reservation(
                    rs.getInt("id"),
                    rs.getString("customer_name"),
                    rs.getString("customer_phone"),
                    room,
                    rs.getTimestamp("start_time"),
                    rs.getTimestamp("end_time"),
                    rs.getInt("deposit"),
                    rs.getString("status")
                );
                reservations.add(reservation);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return reservations;
    }
    
    /**
     * PERBAIKAN 2: Check for overlapping reservations
     * Cek status ACTIVE maupun PENDING agar tidak bentrok
     */
    public boolean hasOverlap(int roomId, Timestamp startTime, Timestamp endTime) {
        // Cek overlap untuk status ACTIVE atau PENDING
        String sql = "SELECT COUNT(*) FROM reservations WHERE room_id = ? AND status IN ('ACTIVE', 'PENDING') " +
                     "AND ((start_time < ? AND end_time > ?) OR " +
                     "(start_time >= ? AND start_time < ?) OR " +
                     "(end_time > ? AND end_time <= ?))";
        
        try (Connection conn = DatabaseConnection.connect();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, roomId);
            pstmt.setTimestamp(2, endTime);
            pstmt.setTimestamp(3, startTime);
            pstmt.setTimestamp(4, startTime);
            pstmt.setTimestamp(5, endTime);
            pstmt.setTimestamp(6, startTime);
            pstmt.setTimestamp(7, endTime);
            
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * PERBAIKAN 3: Create new reservation
     * Menambahkan parameter 'status' agar dinamis (bisa PENDING atau ACTIVE)
     */
    public int createReservation(String customerName, String customerPhone, int roomId, 
                                  Timestamp startTime, Timestamp endTime, int deposit, String status) {
        
        if (hasOverlap(roomId, startTime, endTime)) {
            return -2; // Overlap detected
        }
        
        // Tambahkan kolom status sebagai parameter query (?)
        String sql = "INSERT INTO reservations (customer_name, customer_phone, room_id, start_time, end_time, deposit, status) VALUES (?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DatabaseConnection.connect();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            pstmt.setString(1, customerName);
            pstmt.setString(2, customerPhone);
            pstmt.setInt(3, roomId);
            pstmt.setTimestamp(4, startTime);
            pstmt.setTimestamp(5, endTime);
            pstmt.setInt(6, deposit);
            pstmt.setString(7, status); // Set status sesuai parameter
            
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
     * Cancel reservation
     */
    public boolean cancelReservation(int id) {
        String sql = "UPDATE reservations SET status = 'CANCELLED' WHERE id = ?";
        
        try (Connection conn = DatabaseConnection.connect();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, id);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * PERBAIKAN 4: Method Update General
     * Diperlukan oleh confirm_reservation.jsp untuk mengubah status PENDING -> CONFIRMED/ACTIVE
     */
    public boolean update(Reservation reservation) {
        String sql = "UPDATE reservations SET customer_name = ?, customer_phone = ?, room_id = ?, start_time = ?, end_time = ?, deposit = ?, status = ? WHERE id = ?";
        
        try (Connection conn = DatabaseConnection.connect();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, reservation.getCustomerName());
            pstmt.setString(2, reservation.getCustomerPhone());
            pstmt.setInt(3, reservation.getRoom() != null ? reservation.getRoom().getId() : 0);
            pstmt.setTimestamp(4, reservation.getStartTime());
            pstmt.setTimestamp(5, reservation.getEndTime());
            pstmt.setInt(6, reservation.getDeposit());
            pstmt.setString(7, reservation.getStatus());
            pstmt.setInt(8, reservation.getId());
            
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Get reservation by ID
     */
    public Reservation getReservationById(int id) {
        String sql = "SELECT * FROM reservations WHERE id = ?";
        
        try (Connection conn = DatabaseConnection.connect();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, id);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                Room room = roomDAO.getRoomById(rs.getInt("room_id"));
                return new Reservation(
                    rs.getInt("id"),
                    rs.getString("customer_name"),
                    rs.getString("customer_phone"),
                    room,
                    rs.getTimestamp("start_time"),
                    rs.getTimestamp("end_time"),
                    rs.getInt("deposit"),
                    rs.getString("status")
                );
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    /**
     * PERBAIKAN 5: Save reservation
     * Mengoper status dari objek Reservation ke method createReservation
     */
    public boolean save(Reservation reservation) {
        // Get a default room if not set
        int roomId = 1; // default
        if (reservation.getRoom() != null) {
            roomId = reservation.getRoom().getId();
        }
        
        // Pastikan status ada, jika null set default PENDING
        String statusToSave = reservation.getStatus();
        if (statusToSave == null || statusToSave.isEmpty()) {
            statusToSave = "PENDING";
        }

        int result = createReservation(
            reservation.getCustomerName(),
            reservation.getCustomerPhone(),
            roomId,
            reservation.getStartTime(),
            reservation.getEndTime(),
            reservation.getDeposit(),
            statusToSave // Pass status yang benar
        );
        
        if (result > 0) {
            reservation.setId(result);
            return true;
        }
        return false;
    }
}