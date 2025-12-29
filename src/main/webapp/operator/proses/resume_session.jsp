<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.mycompany.dao.SessionDAO" %>

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
        
        // Panggil fungsi resume di DAO
        if (dao.resumeSession(id)) {
            response.sendRedirect("../dashboard.jsp?tab=sesi&success=Sesi dilanjutkan");
        } else {
            response.sendRedirect("../dashboard.jsp?tab=sesi&error=Gagal melanjutkan sesi");
        }
    } catch (Exception e) {
        response.sendRedirect("../dashboard.jsp?tab=sesi&error=" + e.getMessage());
    }
%>