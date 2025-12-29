<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Clear session
    session.invalidate();
    response.sendRedirect("index.jsp");
%>
