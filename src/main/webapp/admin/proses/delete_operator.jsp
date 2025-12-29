<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.mycompany.dao.UserDAO" %>

<%
    // Check if user is admin
    String role = (String) session.getAttribute("role");
    if (role == null || !role.equals("ADMIN")) {
        response.sendRedirect("../../index.jsp?error=unauthorized");
        return;
    }
    
    // Get operator ID
    String idStr = request.getParameter("id");
    
    try {
        int id = Integer.parseInt(idStr);
        
        UserDAO dao = new UserDAO();
        boolean success = dao.deleteOperator(id);
        
        if (success) {
            response.sendRedirect("../dashboard.jsp?tab=operator&success=Operator berhasil dihapus");
        } else {
            response.sendRedirect("../dashboard.jsp?tab=operator&error=Gagal menghapus operator");
        }
    } catch (Exception e) {
        response.sendRedirect("../dashboard.jsp?tab=operator&error=" + e.getMessage());
    }
%>
