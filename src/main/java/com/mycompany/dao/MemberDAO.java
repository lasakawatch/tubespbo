package com.mycompany.dao;

import com.mycompany.db.DatabaseConnection;
import com.mycompany.model.Member;
import com.mycompany.model.enums.MemberLevel;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * MemberDAO - Data Access Object untuk Member
 * Mengelola operasi CRUD untuk tabel members
 * 
 * @author Kelompok 6
 */
public class MemberDAO {
    
    /**
     * Find all members
     */
    public List<Member> findAll() {
        List<Member> members = new ArrayList<>();
        String sql = "SELECT * FROM members ORDER BY id DESC";
        
        try (Connection conn = DatabaseConnection.connect();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                Member member = new Member();
                member.setId(rs.getInt("id"));
                member.setName(rs.getString("name"));
                member.setPhone(rs.getString("phone_number"));
                member.setEmail(rs.getString("email"));
                member.setMemberId(rs.getString("member_id"));
                
                // Safe parsing of MemberLevel dengan fallback ke SILVER
                String levelStr = rs.getString("level");
                try {
                    member.setLevel(MemberLevel.valueOf(levelStr));
                } catch (IllegalArgumentException e) {
                    // Fallback untuk nilai REGULAR lama dari database
                    if ("REGULAR".equalsIgnoreCase(levelStr)) {
                        member.setLevel(MemberLevel.SILVER);
                    } else {
                        member.setLevel(MemberLevel.SILVER);
                    }
                }
                
                member.setPoints(rs.getInt("points"));
                member.setTotalRentals(rs.getInt("total_rentals"));
                members.add(member);
            }
        } catch (SQLException e) {
            System.err.println("[MemberDAO] Error findAll: " + e.getMessage());
            e.printStackTrace();
        }
        return members;
    }
    
    /**
     * Find member by ID
     */
    public Member findById(int id) {
        String sql = "SELECT * FROM members WHERE id = ?";
        
        try (Connection conn = DatabaseConnection.connect();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, id);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                Member member = new Member();
                member.setId(rs.getInt("id"));
                member.setName(rs.getString("name"));
                member.setPhone(rs.getString("phone_number"));
                member.setEmail(rs.getString("email"));
                member.setMemberId(rs.getString("member_id"));
                
                // Safe parsing of MemberLevel
                String levelStr = rs.getString("level");
                try {
                    member.setLevel(MemberLevel.valueOf(levelStr));
                } catch (IllegalArgumentException e) {
                    member.setLevel(MemberLevel.SILVER);
                }
                
                member.setPoints(rs.getInt("points"));
                member.setTotalRentals(rs.getInt("total_rentals"));
                return member;
            }
        } catch (SQLException e) {
            System.err.println("[MemberDAO] Error findById: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }
    
    /**
     * Find member by member_id string (e.g., "MEM001")
     */
    public Member findByMemberId(String memberId) {
        String sql = "SELECT * FROM members WHERE member_id = ?";
        
        try (Connection conn = DatabaseConnection.connect();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, memberId);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                Member member = new Member();
                member.setId(rs.getInt("id"));
                member.setName(rs.getString("name"));
                member.setPhone(rs.getString("phone_number"));
                member.setEmail(rs.getString("email"));
                member.setMemberId(rs.getString("member_id"));
                
                String levelStr = rs.getString("level");
                try {
                    member.setLevel(MemberLevel.valueOf(levelStr));
                } catch (IllegalArgumentException e) {
                    member.setLevel(MemberLevel.SILVER);
                }
                
                member.setPoints(rs.getInt("points"));
                member.setTotalRentals(rs.getInt("total_rentals"));
                return member;
            }
        } catch (SQLException e) {
            System.err.println("[MemberDAO] Error findByMemberId: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }
    
    /**
     * Save new member
     */
    public boolean save(Member member) {
        String sql = "INSERT INTO members (name, phone_number, email, member_id, level, points, total_rentals) VALUES (?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DatabaseConnection.connect();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            // Generate member ID jika belum ada
            String memberId = member.getMemberId();
            if (memberId == null || memberId.isEmpty()) {
                memberId = "MEM" + String.format("%03d", getNextId());
            }
            
            pstmt.setString(1, member.getName());
            pstmt.setString(2, member.getPhone());
            pstmt.setString(3, member.getEmail());
            pstmt.setString(4, memberId);
            pstmt.setString(5, member.getLevel() != null ? member.getLevel().name() : "SILVER");
            pstmt.setInt(6, member.getPoints());
            pstmt.setInt(7, member.getTotalRentals());
            
            int affected = pstmt.executeUpdate();
            if (affected > 0) {
                ResultSet keys = pstmt.getGeneratedKeys();
                if (keys.next()) {
                    member.setId(keys.getInt(1));
                    member.setMemberId(memberId);
                }
                return true;
            }
        } catch (SQLException e) {
            System.err.println("[MemberDAO] Error save: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Update member
     */
    public boolean update(Member member) {
        String sql = "UPDATE members SET name = ?, phone_number = ?, email = ?, level = ?, points = ?, total_rentals = ? WHERE id = ?";
        
        try (Connection conn = DatabaseConnection.connect();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, member.getName());
            pstmt.setString(2, member.getPhone());
            pstmt.setString(3, member.getEmail());
            pstmt.setString(4, member.getLevel().name());
            pstmt.setInt(5, member.getPoints());
            pstmt.setInt(6, member.getTotalRentals());
            pstmt.setInt(7, member.getId());
            
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Delete member
     */
    public boolean delete(int id) {
        String sql = "DELETE FROM members WHERE id = ?";
        
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
     * Get next ID for member
     */
    private int getNextId() {
        String sql = "SELECT COALESCE(MAX(id), 0) + 1 FROM members";
        
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
}
