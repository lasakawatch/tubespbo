<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.mycompany.dao.*" %>
<%@ page import="com.mycompany.model.*" %>
<%@ page import="com.mycompany.model.enums.*" %>

<%
    // Check if user is operator
    String role = (String) session.getAttribute("role");
    if (role == null || !role.equals("OPERATOR")) {
        response.sendRedirect("../../index.jsp?error=unauthorized");
        return;
    }
    
    // Get form data
    String name = request.getParameter("name");
    String email = request.getParameter("email");
    String phone = request.getParameter("phone");
    
    try {
        Member member = new Member();
        member.setName(name);
        member.setEmail(email);
        member.setPhone(phone);
        
        // PERBAIKAN: Gunakan SILVER sebagai level awal, bukan REGULAR
        member.setLevel(MemberLevel.SILVER);
        
        member.setPoints(0);
        member.setTotalRentals(0);
        
        MemberDAO dao = new MemberDAO();
        boolean success = dao.save(member);
        
        if (success) {
            response.sendRedirect("../dashboard.jsp?tab=member&success=Member berhasil didaftarkan");
        } else {
            response.sendRedirect("../dashboard.jsp?tab=member&error=Gagal mendaftarkan member");
        }
    } catch (Exception e) {
        e.printStackTrace(); // Agar error muncul di console jika ada
        response.sendRedirect("../dashboard.jsp?tab=member&error=" + e.getMessage());
    }
%>