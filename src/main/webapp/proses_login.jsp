<%@page import="com.mycompany.dao.UserDAO"%>
<%@page import="com.mycompany.model.Admin"%>
<%@page import="com.mycompany.model.Operator"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Get form data
    String username = request.getParameter("username");
    String password = request.getParameter("password");
    String role = request.getParameter("role");
    
    // Validate input
    if (username == null || username.trim().isEmpty() || 
        password == null || password.trim().isEmpty() ||
        role == null || role.trim().isEmpty()) {
        response.sendRedirect("index.jsp?error=empty");
        return;
    }
    
    UserDAO userDAO = new UserDAO();
    
    if ("ADMIN".equals(role)) {
        // Login as Admin
        Admin admin = userDAO.loginAdmin(username, password);
        if (admin != null) {
            session.setAttribute("user", admin);
            session.setAttribute("role", "ADMIN");
            session.setAttribute("username", admin.getUsername());
            session.setAttribute("name", admin.getName());
            response.sendRedirect("admin/dashboard.jsp");
        } else {
            response.sendRedirect("index.jsp?error=invalid");
        }
    } else if ("OPERATOR".equals(role)) {
        // Login as Operator
        Operator operator = userDAO.loginOperator(username, password);
        if (operator != null) {
            session.setAttribute("user", operator);
            session.setAttribute("role", "OPERATOR");
            session.setAttribute("username", operator.getUsername());
            session.setAttribute("name", operator.getName());
            response.sendRedirect("operator/dashboard.jsp");
        } else {
            response.sendRedirect("index.jsp?error=invalid");
        }
    } else {
        response.sendRedirect("index.jsp?error=invalid");
    }
%>
