<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.mycompany.dao.UserDAO" %>
<%@ page import="com.mycompany.model.Operator" %>

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
    String username = request.getParameter("username");
    String email = request.getParameter("email");
    String phone = request.getParameter("phone");
    String shift = request.getParameter("shift");
    
    try {
        int id = Integer.parseInt(idStr);
        
        UserDAO dao = new UserDAO();
        Operator operator = dao.findOperatorById(id);
        
        if (operator != null) {
            operator.setName(name);
            operator.setUsername(username);
            operator.setEmail(email);
            operator.setPhone(phone);
            operator.setShift(shift);
            
            boolean success = dao.updateOperator(operator);
            
            if (success) {
                response.sendRedirect("../dashboard.jsp?tab=operator&success=Operator berhasil diupdate");
            } else {
                response.sendRedirect("../dashboard.jsp?tab=operator&error=Gagal mengupdate operator");
            }
        } else {
            response.sendRedirect("../dashboard.jsp?tab=operator&error=Operator tidak ditemukan");
        }
    } catch (Exception e) {
        response.sendRedirect("../dashboard.jsp?tab=operator&error=" + e.getMessage());
    }
%>
