<%@page import="com.mycompany.dao.UserDAO"%>
<%@page import="com.mycompany.model.Operator"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Get form data
    String name = request.getParameter("name");
    String phone = request.getParameter("phone");
    String address = request.getParameter("address");
    String username = request.getParameter("username");
    String password = request.getParameter("password");
    
    // Validate input
    if (name == null || name.trim().isEmpty() || 
        phone == null || phone.trim().isEmpty() ||
        address == null || address.trim().isEmpty() ||
        username == null || username.trim().isEmpty() ||
        password == null || password.trim().isEmpty()) {
        response.sendRedirect("register.jsp?error=empty");
        return;
    }
    
    UserDAO userDAO = new UserDAO();
    
    // Check if username exists
    if (userDAO.usernameExists(username)) {
        response.sendRedirect("register.jsp?error=exists");
        return;
    }
    
    // Create new operator
    Operator operator = new Operator(name, phone, address, username, password);
    
    if (userDAO.registerOperator(operator)) {
        response.sendRedirect("index.jsp?success=Registrasi berhasil! Silakan login.");
    } else {
        response.sendRedirect("register.jsp?error=failed");
    }
%>
