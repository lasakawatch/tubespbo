<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.mycompany.db.*" %> 

<%
    // 1. Cek Login
    String role = (String) session.getAttribute("role");
    if (role == null || !role.equals("OPERATOR")) {
        response.sendRedirect("../../index.jsp");
        return;
    }

    String idStr = request.getParameter("id");
    
    if (idStr != null && !idStr.isEmpty()) {
        Connection conn = null;
        PreparedStatement psGet = null;
        PreparedStatement psInsert = null;
        PreparedStatement psUpdateRes = null;
        PreparedStatement psUpdateConsole = null;
        ResultSet rs = null;
        
        try {
            int reservasiId = Integer.parseInt(idStr);
            conn = DatabaseConnection.getInstance().getConnection();
            
            // --- LANGKAH A: AMBIL DATA RESERVASI & ROOM ---
            // Kita butuh console_id dari room yang dipesan
            String sqlGet = "SELECT r.*, rm.console_id " +
                            "FROM reservations r " +
                            "JOIN rooms rm ON r.room_id = rm.id " +
                            "WHERE r.id = ?";
            
            psGet = conn.prepareStatement(sqlGet);
            psGet.setInt(1, reservasiId);
            rs = psGet.executeQuery();
            
            if (rs.next()) {
                // Ambil data penting
                String customerName = rs.getString("customer_name");
                int roomId = rs.getInt("room_id");
                int consoleId = rs.getInt("console_id"); // Ini penting buat bikin sesi
                Timestamp startTime = rs.getTimestamp("start_time");
                Timestamp endTime = rs.getTimestamp("end_time");
                
                // Hitung durasi reservasi asli (dalam milidetik)
                long durationMs = endTime.getTime() - startTime.getTime();
                
                // Waktu Sesi Dimulai = SEKARANG (Saat dikonfirmasi)
                long currentTime = new java.util.Date().getTime();
                Timestamp sessionStart = new Timestamp(currentTime);
                // Waktu Selesai = Sekarang + Durasi Reservasi
                Timestamp sessionEnd = new Timestamp(currentTime + durationMs);
                
                // --- LANGKAH B: PINDAHKAN KE RENTAL_SESSION (Sesi Aktif) ---
                String sqlInsert = "INSERT INTO rental_sessions " +
                                   "(room_id, console_id, customer_name, start_time, planned_end_time, status, created_at) " +
                                   "VALUES (?, ?, ?, ?, ?, 'ACTIVE', NOW())";
                                   
                psInsert = conn.prepareStatement(sqlInsert);
                psInsert.setInt(1, roomId);
                psInsert.setInt(2, consoleId);
                psInsert.setString(3, customerName);
                psInsert.setTimestamp(4, sessionStart);
                psInsert.setTimestamp(5, sessionEnd);
                
                int insertResult = psInsert.executeUpdate();
                
                if (insertResult > 0) {
                    // --- LANGKAH C: UPDATE RESERVASI JADI 'COMPLETED' ---
                    // Biar gak muncul lagi di daftar reservasi
                    String sqlUpdateRes = "UPDATE reservations SET status = 'COMPLETED' WHERE id = ?";
                    psUpdateRes = conn.prepareStatement(sqlUpdateRes);
                    psUpdateRes.setInt(1, reservasiId);
                    psUpdateRes.executeUpdate();
                    
                    // --- LANGKAH D: UPDATE KONSOL JADI 'IN_USE' ---
                    // Biar gak bisa dipake orang lain
                    String sqlUpdateConsole = "UPDATE consoles SET status = 'IN_USE' WHERE id = ?";
                    psUpdateConsole = conn.prepareStatement(sqlUpdateConsole);
                    psUpdateConsole.setInt(1, consoleId);
                    psUpdateConsole.executeUpdate();
                    
                    // SUKSES: Redirect ke Tab Sesi Aktif biar kelihatan hasilnya
                    response.sendRedirect("../dashboard.jsp?tab=sesi&success=Reservasi dikonfirmasi! Sesi permainan dimulai.");
                } else {
                    response.sendRedirect("../dashboard.jsp?tab=reservasi&error=Gagal membuat sesi baru.");
                }
                
            } else {
                response.sendRedirect("../dashboard.jsp?tab=reservasi&error=Data reservasi tidak ditemukan.");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("../dashboard.jsp?tab=reservasi&error=Error Sistem: " + e.getMessage());
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (psGet != null) try { psGet.close(); } catch (Exception e) {}
            if (psInsert != null) try { psInsert.close(); } catch (Exception e) {}
            if (psUpdateRes != null) try { psUpdateRes.close(); } catch (Exception e) {}
            if (psUpdateConsole != null) try { psUpdateConsole.close(); } catch (Exception e) {}
        }
    } else {
        response.sendRedirect("../dashboard.jsp?tab=reservasi&error=ID tidak valid");
    }
%>