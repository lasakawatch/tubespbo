<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.mycompany.dao.RoomDAO" %>
<%@ page import="com.mycompany.model.Room" %>
<%@ page import="com.mycompany.model.enums.RoomStatus" %>

<%
    // Check if user is admin
    String role = (String) session.getAttribute("role");
    if (role == null || !role.equals("ADMIN")) {
        response.sendRedirect("../../index.jsp?error=unauthorized");
        return;
    }
    
    // Get form data
    String idStr = request.getParameter("id");
    String name = request.getParameter("name");
    String capacityStr = request.getParameter("capacity");
    String rateStr = request.getParameter("rate");
    String statusStr = request.getParameter("status");
    
    try {
        int id = Integer.parseInt(idStr);
        int capacity = Integer.parseInt(capacityStr);
        double rate = Double.parseDouble(rateStr);
        RoomStatus status = RoomStatus.valueOf(statusStr);
        
        RoomDAO dao = new RoomDAO();
        Room room = dao.findById(id);
        
        if (room != null) {
            room.setName(name);
            room.setCapacity(capacity);
            room.setRatePerHour(rate);
            room.setStatus(status);
            
            boolean success = dao.update(room);
            
            if (success) {
                response.sendRedirect("../dashboard.jsp?tab=inventori&success=Ruangan berhasil diupdate");
            } else {
                response.sendRedirect("../dashboard.jsp?tab=inventori&error=Gagal mengupdate ruangan");
            }
        } else {
            response.sendRedirect("../dashboard.jsp?tab=inventori&error=Ruangan tidak ditemukan");
        }
    } catch (Exception e) {
        response.sendRedirect("../dashboard.jsp?tab=inventori&error=" + e.getMessage());
    }
%>
