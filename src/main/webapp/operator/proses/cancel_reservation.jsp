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

    // 2. Ambil ID
    String idStr = request.getParameter("id");
    
    if (idStr != null && !idStr.isEmpty()) {
        Connection conn = null;
        PreparedStatement ps = null;
        
        try {
            int id = Integer.parseInt(idStr);
            
            // 3. Koneksi
            conn = DatabaseConnection.getInstance().getConnection();
            
            // 4. Update Status jadi 'CANCELLED'
            String sql = "UPDATE reservations SET status = 'CANCELLED' WHERE id = ?";
            
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            
            int result = ps.executeUpdate();
            
            if (result > 0) {
                response.sendRedirect("../dashboard.jsp?tab=reservasi&success=Reservasi berhasil dibatalkan");
            } else {
                response.sendRedirect("../dashboard.jsp?tab=reservasi&error=Data tidak ditemukan");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("../dashboard.jsp?tab=reservasi&error=Error: " + e.getMessage());
        } finally {
            if (ps != null) try { ps.close(); } catch (Exception e) {}
        }
    } else {
        response.sendRedirect("../dashboard.jsp?tab=reservasi&error=ID tidak valid");
    }
%>