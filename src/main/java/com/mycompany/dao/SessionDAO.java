package com.mycompany.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

import com.mycompany.db.DatabaseConnection;
import com.mycompany.model.ConsoleUnit;
import com.mycompany.model.Member;
import com.mycompany.model.RentalSession;
import com.mycompany.model.Room;
import com.mycompany.model.enums.SessionStatus;

/**
 * SessionDAO - Data Access Object untuk RentalSession
 * Versi Final: Fix Nama Pelanggan, Pause/Resume, & Laporan
 */
public class SessionDAO {
    private RoomDAO roomDAO = new RoomDAO();
    private ConsoleDAO consoleDAO = new ConsoleDAO();
    private MemberDAO memberDAO = new MemberDAO();
    
    // --- TAMBAHAN: Method findAll() untuk kompatibilitas Laporan ---
    public List<RentalSession> findAll() {
        return getAllSessions();
    }

    /**
     * Get all sessions
     */
    public List<RentalSession> getAllSessions() {
        return getSessionsByQuery("SELECT * FROM rental_sessions ORDER BY id DESC");
    }
    
    /**
     * Find active sessions
     */
    public List<RentalSession> findActiveSession() {
        return getActiveSessions();
    }
    
    /**
     * Get active sessions (ACTIVE or PAUSED)
     */
    public List<RentalSession> getActiveSessions() {
        return getSessionsByQuery("SELECT * FROM rental_sessions WHERE status IN ('ACTIVE', 'PAUSED') ORDER BY id DESC");
    }
    
    /**
     * Helper method to execute query and build list
     */
    private List<RentalSession> getSessionsByQuery(String sql) {
        List<RentalSession> sessions = new ArrayList<>();
        
        try (Connection conn = DatabaseConnection.connect();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                try {
                    RentalSession session = buildSessionFromResultSet(rs);
                    if (session != null) {
                        sessions.add(session);
                    }
                } catch (Exception e) {
                    System.err.println("Error mapping session ID " + rs.getInt("id") + ": " + e.getMessage());
                    e.printStackTrace();
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return sessions;
    }
    
    /**
     * Get session by ID
     */
    public RentalSession getSessionById(int id) {
        String sql = "SELECT * FROM rental_sessions WHERE id = ?";
        
        try (Connection conn = DatabaseConnection.connect();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, id);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                return buildSessionFromResultSet(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    /**
     * FindById alias
     */
    public RentalSession findById(int id) {
        return getSessionById(id);
    }
    
    /**
     * Create new session (Save)
     */
    public boolean save(RentalSession session) {
        String sql = "INSERT INTO rental_sessions (room_id, console_id, member_id, customer_name, start_time, planned_end_time, status, paused_minutes, total_fee) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DatabaseConnection.connect();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            Timestamp startTime = session.getStartTime() != null ? session.getStartTime() : new Timestamp(System.currentTimeMillis());
            Timestamp plannedEndTime = session.getPlannedEndTime() != null ? session.getPlannedEndTime() : new Timestamp(startTime.getTime() + (60 * 60 * 1000));
            
            if (session.getRoomId() != null && session.getRoomId() > 0) {
                pstmt.setInt(1, session.getRoomId());
            } else {
                pstmt.setNull(1, Types.INTEGER);
            }
            
            pstmt.setInt(2, session.getConsoleId() != null ? session.getConsoleId() : 1);
            
            if (session.getMemberId() != null && session.getMemberId() > 0) {
                pstmt.setInt(3, session.getMemberId());
            } else {
                pstmt.setNull(3, Types.INTEGER);
            }
            
            pstmt.setString(4, session.getCustomerName());
            pstmt.setTimestamp(5, startTime);
            pstmt.setTimestamp(6, plannedEndTime);
            
            String statusStr = session.getStatus() != null ? session.getStatus().name() : "ACTIVE";
            pstmt.setString(7, statusStr);
            
            pstmt.setInt(8, session.getPausedMinutes());
            pstmt.setInt(9, session.getTotalFee());
            
            int affected = pstmt.executeUpdate();
            if (affected > 0) {
                ResultSet rs = pstmt.getGeneratedKeys();
                if (rs.next()) {
                    session.setId(rs.getInt(1));
                    return true;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Update session
     */
    public boolean update(RentalSession session) {
        String sql = "UPDATE rental_sessions SET status = ?, actual_end_time = ?, total_fee = ?, paused_minutes = ?, tarif_type = ? WHERE id = ?";
        try (Connection conn = DatabaseConnection.connect();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, session.getStatus().name());
            pstmt.setTimestamp(2, session.getActualEndTime());
            pstmt.setInt(3, session.getTotalFee());
            pstmt.setInt(4, session.getPausedMinutes());
            pstmt.setString(5, session.getTarifType() != null ? session.getTarifType() : "STANDARD");
            pstmt.setInt(6, session.getId());
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // --- LOGIKA PAUSE & RESUME (FIXED - Proper Time Tracking) ---
    public boolean pauseSession(int id) {
        RentalSession s = getSessionById(id);
        if(s != null && s.getStatus() == SessionStatus.ACTIVE) { 
            s.setStatus(SessionStatus.PAUSED);
            // Simpan waktu saat tombol pause ditekan ke kolom actual_end_time sementara
            // (sebagai penanda kapan pause dimulai)
            s.setActualEndTime(new Timestamp(new java.util.Date().getTime()));
            return update(s); 
        }
        return false;
    }
    
    // --- PERBAIKAN LOGIKA RESUME (FIXED - Extend planned_end_time) ---
    public boolean resumeSession(int id) {
        RentalSession s = getSessionById(id);
        if(s != null && s.getStatus() == SessionStatus.PAUSED) { 
            // Jika sebelumnya ada waktu pause tersimpan di actual_end_time
            if (s.getActualEndTime() != null) {
                long currentTime = new java.util.Date().getTime();
                long pauseStartTime = s.getActualEndTime().getTime();
                long pauseDurationMs = currentTime - pauseStartTime;
                
                // Hitung durasi pause dalam menit (pembulatan)
                int pauseDurationMinutes = (int) Math.round(pauseDurationMs / 60000.0);
                
                // Akumulasikan ke total paused_minutes
                s.setPausedMinutes(s.getPausedMinutes() + pauseDurationMinutes);
                
                // PENTING: Perpanjang planned_end_time dengan durasi pause
                // Agar countdown tidak "loncat" seolah waktu terus berjalan
                if (s.getPlannedEndTime() != null) {
                    long newPlannedEnd = s.getPlannedEndTime().getTime() + pauseDurationMs;
                    s.setPlannedEndTime(new Timestamp(newPlannedEnd));
                }
                
                // Reset actual_end_time jadi null (karena sesi aktif lagi)
                s.setActualEndTime(null); 
            }
            s.setStatus(SessionStatus.ACTIVE);
            
            // Update dengan planned_end_time yang baru
            return updateWithPlannedEndTime(s); 
        }
        return false;
    }
    
    /**
     * Update session dengan planned_end_time (untuk resume)
     */
    public boolean updateWithPlannedEndTime(RentalSession session) {
        String sql = "UPDATE rental_sessions SET status = ?, actual_end_time = ?, total_fee = ?, paused_minutes = ?, planned_end_time = ? WHERE id = ?";
        try (Connection conn = DatabaseConnection.connect();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, session.getStatus().name());
            pstmt.setTimestamp(2, session.getActualEndTime());
            pstmt.setInt(3, session.getTotalFee());
            pstmt.setInt(4, session.getPausedMinutes());
            pstmt.setTimestamp(5, session.getPlannedEndTime());
            pstmt.setInt(6, session.getId());
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // --- METHOD MAPPING UTAMA (FIX MASALAH NAMA GUEST) ---
    private RentalSession buildSessionFromResultSet(ResultSet rs) throws SQLException {
        // 1. Ambil data Relasi (Room, Console, Member)
        int roomIdDb = rs.getInt("room_id");
        Room room = null;
        if (!rs.wasNull() && roomIdDb > 0) {
            room = roomDAO.getRoomById(roomIdDb);
        }
        
        int consoleId = rs.getInt("console_id");
        ConsoleUnit console = consoleDAO.getConsoleById(consoleId);
        
        Member member = null;
        int memberId = rs.getInt("member_id");
        if (!rs.wasNull() && memberId > 0) {
            member = memberDAO.findById(memberId);
        }
        
        // 2. Ambil Status Enum dengan aman
        SessionStatus status = SessionStatus.ACTIVE;
        try {
            String statusStr = rs.getString("status");
            if (statusStr != null) {
                status = SessionStatus.valueOf(statusStr.toUpperCase());
            }
        } catch (IllegalArgumentException e) {
            System.err.println("Warning: Invalid status in DB: " + rs.getString("status"));
        }

        // 3. Construct Objek Session
        RentalSession session = new RentalSession(
            rs.getInt("id"),
            room,
            console,
            member,
            rs.getTimestamp("start_time"),
            rs.getTimestamp("planned_end_time"),
            rs.getTimestamp("actual_end_time"),
            rs.getInt("paused_minutes"),
            status,
            rs.getInt("total_fee")
        );
        
        // 4. FIX NAMA PELANGGAN
        // Ambil nama manual dari kolom customer_name di database
        String dbCustomerName = rs.getString("customer_name");
        
        // Logic Prioritas:
        // 1. Jika ada nama manual (Reservasi/Walk-in Non-member), PAKAI ITU.
        // 2. Jika tidak ada, tapi ada Member ID, pakai nama Member.
        // 3. Jika tidak ada semua, baru Guest.
        if (dbCustomerName != null && !dbCustomerName.trim().isEmpty()) {
            session.setCustomerName(dbCustomerName);
        } else if (member != null) {
            session.setCustomerName(member.getName());
        } else {
            session.setCustomerName("Guest");
        }
        
        // Set ulang ID relasi biar konsisten
        session.setConsoleId(consoleId);
        session.setRoomId(roomIdDb);
        session.setMemberId(memberId);
        
        // Set tarif type
        String tarifType = rs.getString("tarif_type");
        session.setTarifType(tarifType != null ? tarifType : "STANDARD");
        
        return session;
    }
}