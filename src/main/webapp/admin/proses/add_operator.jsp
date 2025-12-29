<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.mycompany.dao.UserDAO" %>
<%@ page import="com.mycompany.model.Operator" %>
<%@ page import="java.security.MessageDigest" %>

<%
    // Check if user is admin
    String role = (String) session.getAttribute("role");
    if (role == null || !role.equals("ADMIN")) {
        response.sendRedirect("../../index.jsp?error=unauthorized");
        return;
    }
    
    // Get form data
    String name = request.getParameter("name");
    String username = request.getParameter("username");
    String password = request.getParameter("password");
    String email = request.getParameter("email");
    String phone = request.getParameter("phone");
    String shift = request.getParameter("shift");
    
    try {
        // Hash password
        MessageDigest md = MessageDigest.getInstance("SHA-256");
        byte[] hash = md.digest(password.getBytes("UTF-8"));
        StringBuilder hexString = new StringBuilder();
        for (byte b : hash) {
            String hex = Integer.toHexString(0xff & b);
            if (hex.length() == 1) hexString.append('0');
            hexString.append(hex);
        }
        String hashedPassword = hexString.toString();
        
        Operator operator = new Operator();
        operator.setName(name);
        operator.setUsername(username);
        operator.setPassword(hashedPassword);
        operator.setEmail(email);
        operator.setPhone(phone);
        operator.setShift(shift);
        
        UserDAO dao = new UserDAO();
        boolean success = dao.saveOperator(operator);
        
        if (success) {
            response.sendRedirect("../dashboard.jsp?tab=operator&success=Operator berhasil ditambahkan");
        } else {
            response.sendRedirect("../dashboard.jsp?tab=operator&error=Gagal menambahkan operator");
        }
    } catch (Exception e) {
        response.sendRedirect("../dashboard.jsp?tab=operator&error=" + e.getMessage());
    }
%>
