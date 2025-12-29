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
    String name = request.getParameter("name");
    String capacityStr = request.getParameter("capacity");
    String rateStr = request.getParameter("rate");
    String statusStr = request.getParameter("status");
    
    try {
        int capacity = Integer.parseInt(capacityStr);
        double rate = Double.parseDouble(rateStr);
        RoomStatus status = RoomStatus.valueOf(statusStr);
        
        Room room = new Room();
        room.setName(name);
        room.setCapacity(capacity);
        room.setRatePerHour(rate);
        room.setStatus(status);
        
        RoomDAO dao = new RoomDAO();
        boolean success = dao.save(room);
        
        if (success) {
            response.sendRedirect("../dashboard.jsp?tab=inventori&success=Ruangan berhasil ditambahkan");
        } else {
            response.sendRedirect("../dashboard.jsp?tab=inventori&error=Gagal menambahkan ruangan");
        }
    } catch (Exception e) {
        response.sendRedirect("../dashboard.jsp?tab=inventori&error=" + e.getMessage());
    }
%>
