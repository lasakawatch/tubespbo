<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.mycompany.dao.SessionDAO" %>
<%@ page import="com.mycompany.model.RentalSession" %>
<%@ page import="com.mycompany.model.enums.SessionStatus" %>

<%
    // Cek Login Operator
    String role = (String) session.getAttribute("role");
    if (role == null || !role.equals("OPERATOR")) {
        response.sendRedirect("../../index.jsp");
        return;
    }

    String idStr = request.getParameter("id");
    
    try {
        int id = Integer.parseInt(idStr);
        SessionDAO dao = new SessionDAO();
        
        // Panggil fungsi pause di DAO
        if (dao.pauseSession(id)) {
            response.sendRedirect("../dashboard.jsp?tab=sesi&success=Sesi berhasil dipause");
        } else {
            response.sendRedirect("../dashboard.jsp?tab=sesi&error=Gagal mempause sesi");
        }
    } catch (Exception e) {
        response.sendRedirect("../dashboard.jsp?tab=sesi&error=" + e.getMessage());
    }
%>