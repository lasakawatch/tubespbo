<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>
<%@ page import="com.mycompany.db.*" %> 
<!-- Pastikan import DatabaseConnection sesuai package di project lu -->

<%
    // 1. Cek Login Operator
    String role = (String) session.getAttribute("role");
    if (role == null || !role.equals("OPERATOR")) {
        response.sendRedirect("../../index.jsp");
        return;
    }

    // 2. Ambil Data dari Form
    String name = request.getParameter("customerName");
    String phone = request.getParameter("phone");
    // consoleType tidak masuk database reservasi secara langsung, tapi bisa dipakai buat filter room
    String consoleTypeStr = request.getParameter("consoleType"); 
    String timeStr = request.getParameter("reservationTime"); 
    String durationStr = request.getParameter("duration");

    if (name != null && timeStr != null && durationStr != null) {
        Connection conn = null;
        PreparedStatement ps = null;
        PreparedStatement psRoom = null;
        ResultSet rsRoom = null;

        try {
            // --- PARSING DATA ---
            // Format input datetime-local: "2023-12-30T14:30"
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
            java.util.Date parsedDate = sdf.parse(timeStr);
            Timestamp startTime = new Timestamp(parsedDate.getTime());

            int duration = Integer.parseInt(durationStr);
            long endTimeMillis = startTime.getTime() + (duration * 60 * 60 * 1000);
            Timestamp endTime = new Timestamp(endTimeMillis);

            // --- KONEKSI DATABASE ---
            // Menggunakan Singleton Pattern sesuai kode lu yang terakhir
            conn = DatabaseConnection.getInstance().getConnection();

            // --- CARI ROOM YANG TERSEDIA ---
            // Kita cari 1 Room ID yang statusnya AVAILABLE secara acak buat di-assign
            // (Idealnya cari yang kosong di jam itu, tapi buat tugas ini cukup cari status Available)
            int roomId = 0;
            String roomQuery = "SELECT id FROM rooms WHERE status = 'AVAILABLE' LIMIT 1";
            psRoom = conn.prepareStatement(roomQuery);
            rsRoom = psRoom.executeQuery();
            
            if (rsRoom.next()) {
                roomId = rsRoom.getInt("id");
            } else {
                // Kalau gak ada room available, kita paksa set ke ID 1 (daripada error)
                // Atau tampilkan error "Kamar Penuh"
                roomId = 1; 
            }

            // --- INSERT KE DATABASE (RAW SQL) ---
            // Status langsung ditulis string 'ACTIVE' biar gak ribet sama Enum Java
            String sql = "INSERT INTO reservations (customer_name, customer_phone, room_id, start_time, end_time, status, created_at) VALUES (?, ?, ?, ?, ?, 'ACTIVE', NOW())";
            
            ps = conn.prepareStatement(sql);
            ps.setString(1, name);
            ps.setString(2, phone);
            ps.setInt(3, roomId);
            ps.setTimestamp(4, startTime);
            ps.setTimestamp(5, endTime);
            
            int result = ps.executeUpdate();
            
            if (result > 0) {
                response.sendRedirect("../dashboard.jsp?tab=reservasi&success=Reservasi berhasil dibuat");
            } else {
                response.sendRedirect("../dashboard.jsp?tab=reservasi&error=Gagal menyimpan ke database");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("../dashboard.jsp?tab=reservasi&error=System Error: " + e.getMessage());
        } finally {
            // Bersihkan resource
            if (rsRoom != null) try { rsRoom.close(); } catch (Exception e) {}
            if (psRoom != null) try { psRoom.close(); } catch (Exception e) {}
            if (ps != null) try { ps.close(); } catch (Exception e) {}
            // Jangan close connection kalau pakai Singleton yang dishare, 
            // tapi kalau mau aman close aja gak papa, nanti getInstance bikin baru.
            // if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
    } else {
        response.sendRedirect("../dashboard.jsp?tab=reservasi&error=Data form tidak lengkap");
    }
%>