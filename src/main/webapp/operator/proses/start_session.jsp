<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.mycompany.dao.*" %>
<%@ page import="com.mycompany.model.*" %>
<%@ page import="com.mycompany.model.enums.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.sql.Timestamp" %>

<%
    String role = (String) session.getAttribute("role");
    if (role == null || !role.equals("OPERATOR")) {
        response.sendRedirect("../../index.jsp?error=unauthorized");
        return;
    }
    
    String consoleIdStr = request.getParameter("consoleId");
    String roomIdStr = request.getParameter("roomId");
    String memberIdStr = request.getParameter("memberId");
    String customerName = request.getParameter("customerName");
    String durationStr = request.getParameter("duration");
    
    try {
        int consoleId = Integer.parseInt(consoleIdStr);
        Integer roomId = (roomIdStr != null && !roomIdStr.isEmpty()) ? Integer.parseInt(roomIdStr) : null;
        Integer memberId = (memberIdStr != null && !memberIdStr.isEmpty()) ? Integer.parseInt(memberIdStr) : null;
        
        // UBAH DISINI: Input sekarang adalah JAM
        int durationHours = (durationStr != null && !durationStr.isEmpty()) ? Integer.parseInt(durationStr) : 1;
        
        ConsoleDAO consoleDAO = new ConsoleDAO();
        ConsoleUnit console = consoleDAO.findById(consoleId);
        
        if (console == null || console.getStatus() != ConsoleStatus.AVAILABLE) {
            response.sendRedirect("../dashboard.jsp?tab=mulai&error=Konsol tidak tersedia");
            return;
        }
        
        if (memberId != null) {
            MemberDAO memberDAO = new MemberDAO();
            Member member = memberDAO.findById(memberId);
            if (member != null) customerName = member.getName();
        }
        
        long startTimeMillis = new java.util.Date().getTime();
        Timestamp startTime = new Timestamp(startTimeMillis);
        
        // HITUNG SELESAI: Jam * 60 menit * 60 detik * 1000 ms
        long plannedEndTimeMillis = startTimeMillis + (durationHours * 60 * 60 * 1000);
        Timestamp plannedEndTime = new Timestamp(plannedEndTimeMillis);
        
        RentalSession rentSession = new RentalSession();
        rentSession.setConsoleId(consoleId);
        rentSession.setRoomId(roomId);
        rentSession.setMemberId(memberId);
        rentSession.setCustomerName(customerName);
        rentSession.setStartTime(startTime);
        rentSession.setPlannedEndTime(plannedEndTime);
        rentSession.setStatus(SessionStatus.ACTIVE);
        rentSession.setPausedMinutes(0);
        rentSession.setTotalFee(0);
        
        SessionDAO sessionDAO = new SessionDAO();
        boolean success = sessionDAO.save(rentSession);
        
        if (success) {
            console.setStatus(ConsoleStatus.IN_USE);
            consoleDAO.update(console);
            
            if (roomId != null) {
                RoomDAO roomDAO = new RoomDAO();
                Room room = roomDAO.findById(roomId);
                if (room != null) {
                    room.setStatus(RoomStatus.IN_USE);
                    roomDAO.update(room);
                }
            }
            response.sendRedirect("../dashboard.jsp?tab=sesi&success=Sesi dimulai (" + durationHours + " Jam)");
        } else {
            response.sendRedirect("../dashboard.jsp?tab=mulai&error=Gagal memulai sesi");
        }
    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("../dashboard.jsp?tab=mulai&error=" + e.getMessage());
    }
%>