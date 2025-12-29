<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.mycompany.dao.ConsoleDAO" %>
<%@ page import="com.mycompany.model.ConsoleUnit" %>
<%@ page import="com.mycompany.model.enums.ConsoleType" %>
<%@ page import="com.mycompany.model.enums.ConsoleStatus" %>

<%
    // Check if user is admin
    String role = (String) session.getAttribute("role");
    if (role == null || !role.equals("ADMIN")) {
        response.sendRedirect("../../index.jsp?error=unauthorized");
        return;
    }
    
    // Get form data
    String typeStr = request.getParameter("type");
    String rateStr = request.getParameter("rate");
    String statusStr = request.getParameter("status");
    
    try {
        ConsoleType type = ConsoleType.valueOf(typeStr);
        double rate = Double.parseDouble(rateStr);
        ConsoleStatus status = ConsoleStatus.valueOf(statusStr);
        
        ConsoleUnit console = new ConsoleUnit();
        console.setType(type);
        console.setRatePerHour(rate);
        console.setStatus(status);
        
        ConsoleDAO dao = new ConsoleDAO();
        boolean success = dao.save(console);
        
        if (success) {
            response.sendRedirect("../dashboard.jsp?tab=inventori&success=Konsol berhasil ditambahkan");
        } else {
            response.sendRedirect("../dashboard.jsp?tab=inventori&error=Gagal menambahkan konsol");
        }
    } catch (Exception e) {
        response.sendRedirect("../dashboard.jsp?tab=inventori&error=" + e.getMessage());
    }
%>
