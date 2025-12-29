<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
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
    String hoursStr = request.getParameter("hours");
    
    try {
        int id = Integer.parseInt(idStr);
        int additionalHours = Integer.parseInt(hoursStr);
        
        if (additionalHours < 1 || additionalHours > 5) {
            response.sendRedirect("../dashboard.jsp?tab=sesi&error=Tambah waktu harus 1-5 jam");
            return;
        }
        
        SessionDAO dao = new SessionDAO();
        RentalSession rentSession = dao.findById(id);
        
        if (rentSession != null && 
            (rentSession.getStatus() == SessionStatus.ACTIVE || rentSession.getStatus() == SessionStatus.PAUSED)) {
            
            // Perpanjang planned_end_time
            long currentPlannedEnd = rentSession.getPlannedEndTime().getTime();
            long additionalMs = additionalHours * 60 * 60 * 1000L;
            long newPlannedEnd = currentPlannedEnd + additionalMs;
            
            rentSession.setPlannedEndTime(new Timestamp(newPlannedEnd));
            
            if (dao.updateWithPlannedEndTime(rentSession)) {
                response.sendRedirect("../dashboard.jsp?tab=sesi&success=Waktu berhasil ditambah " + additionalHours + " jam");
            } else {
                response.sendRedirect("../dashboard.jsp?tab=sesi&error=Gagal menambah waktu");
            }
        } else {
            response.sendRedirect("../dashboard.jsp?tab=sesi&error=Sesi tidak ditemukan atau sudah selesai");
        }
    } catch (NumberFormatException e) {
        response.sendRedirect("../dashboard.jsp?tab=sesi&error=Parameter tidak valid");
    } catch (Exception e) {
        response.sendRedirect("../dashboard.jsp?tab=sesi&error=" + e.getMessage());
    }
%>
