package com.mycompany.dao;

import com.mycompany.db.DatabaseConnection;
import com.mycompany.model.Room;
import com.mycompany.model.enums.RoomStatus;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * RoomDAO - Data Access Object untuk Room
 */
public class RoomDAO {
    
    /**
     * Find all rooms (alias for getAllRooms)
     */
    public List<Room> findAll() {
        return getAllRooms();
    }
    
    /**
     * Find room by ID (alias for getRoomById)
     */
    public Room findById(int id) {
        return getRoomById(id);
    }
    
    /**
     * Find rooms by status
     */
    public List<Room> findByStatus(RoomStatus status) {
        List<Room> rooms = new ArrayList<>();
        String sql = "SELECT * FROM rooms WHERE status = ? ORDER BY id";
        
        try (Connection conn = DatabaseConnection.connect();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, status.name());
            ResultSet rs = pstmt.executeQuery();
            
            while (rs.next()) {
                Room room = new Room(
                    rs.getInt("id"),
                    rs.getString("name"),
                    rs.getInt("capacity"),
                    RoomStatus.valueOf(rs.getString("status"))
                );
                room.setRatePerHour(rs.getInt("hourly_rate"));
                rooms.add(room);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return rooms;
    }
    
    /**
     * Get all rooms
     */
    public List<Room> getAllRooms() {
        List<Room> rooms = new ArrayList<>();
        String sql = "SELECT * FROM rooms ORDER BY id";
        
        try (Connection conn = DatabaseConnection.connect();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                Room room = new Room(
                    rs.getInt("id"),
                    rs.getString("name"),
                    rs.getInt("capacity"),
                    RoomStatus.valueOf(rs.getString("status"))
                );
                room.setRatePerHour(rs.getInt("hourly_rate"));
                rooms.add(room);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return rooms;
    }
    
    /**
     * Get available rooms
     */
    public List<Room> getAvailableRooms() {
        List<Room> rooms = new ArrayList<>();
        String sql = "SELECT * FROM rooms WHERE status = 'AVAILABLE' ORDER BY id";
        
        try (Connection conn = DatabaseConnection.connect();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                Room room = new Room(
                    rs.getInt("id"),
                    rs.getString("name"),
                    rs.getInt("capacity"),
                    RoomStatus.valueOf(rs.getString("status"))
                );
                room.setRatePerHour(rs.getInt("hourly_rate"));
                rooms.add(room);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return rooms;
    }
    
    /**
     * Get room by ID
     */
    public Room getRoomById(int id) {
        String sql = "SELECT * FROM rooms WHERE id = ?";
        
        try (Connection conn = DatabaseConnection.connect();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, id);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                Room room = new Room(
                    rs.getInt("id"),
                    rs.getString("name"),
                    rs.getInt("capacity"),
                    RoomStatus.valueOf(rs.getString("status"))
                );
                room.setRatePerHour(rs.getInt("hourly_rate"));
                return room;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    /**
     * Update room status
     */
    public boolean updateRoomStatus(int id, RoomStatus status) {
        String sql = "UPDATE rooms SET status = ? WHERE id = ?";
        
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
     * Add new room
     */
    public boolean addRoom(Room room) {
        String sql = "INSERT INTO rooms (name, capacity, hourly_rate, status) VALUES (?, ?, ?, ?)";
        
        try (Connection conn = DatabaseConnection.connect();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            pstmt.setString(1, room.getName());
            pstmt.setInt(2, room.getCapacity());
            pstmt.setInt(3, (int) room.getRatePerHour());
            pstmt.setString(4, room.getStatus().name());
            
            int affected = pstmt.executeUpdate();
            if (affected > 0) {
                ResultSet rs = pstmt.getGeneratedKeys();
                if (rs.next()) {
                    room.setId(rs.getInt(1));
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Save room (alias for addRoom)
     */
    public boolean save(Room room) {
        return addRoom(room);
    }
    
    /**
     * Update room
     */
    public boolean update(Room room) {
        String sql = "UPDATE rooms SET name = ?, capacity = ?, hourly_rate = ?, status = ? WHERE id = ?";
        
        try (Connection conn = DatabaseConnection.connect();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, room.getName());
            pstmt.setInt(2, room.getCapacity());
            pstmt.setInt(3, (int) room.getRatePerHour());
            pstmt.setString(4, room.getStatus().name());
            pstmt.setInt(5, room.getId());
            
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Delete room by ID
     */
    public boolean delete(int id) {
        String sql = "DELETE FROM rooms WHERE id = ?";
        
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
