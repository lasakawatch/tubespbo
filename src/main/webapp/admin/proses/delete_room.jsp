<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.mycompany.dao.RoomDAO" %>

<%
    // Check if user is admin
    String role = (String) session.getAttribute("role");
    if (role == null || !role.equals("ADMIN")) {
        response.sendRedirect("../../index.jsp?error=unauthorized");
        return;
    }
    
    // Get room ID
    String idStr = request.getParameter("id");
    
    try {
        int id = Integer.parseInt(idStr);
        
        RoomDAO dao = new RoomDAO();
        boolean success = dao.delete(id);
        
        if (success) {
            response.sendRedirect("../dashboard.jsp?tab=inventori&success=Ruangan berhasil dihapus");
        } else {
            response.sendRedirect("../dashboard.jsp?tab=inventori&error=Gagal menghapus ruangan");
        }
    } catch (Exception e) {
        response.sendRedirect("../dashboard.jsp?tab=inventori&error=" + e.getMessage());
    }
%>
