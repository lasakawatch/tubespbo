<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="com.mycompany.dao.*" %>
<%@ page import="com.mycompany.model.*" %>
<%@ page import="com.mycompany.model.enums.*" %>

<%
    String role = (String) session.getAttribute("role");
    if (role == null || !role.equals("OPERATOR")) {
        response.sendRedirect("../index.jsp?error=unauthorized");
        return;
    }
    
    String sessionIdStr = request.getParameter("sessionId");
    if (sessionIdStr == null) {
        response.sendRedirect("dashboard.jsp?error=Session tidak ditemukan");
        return;
    }
    
    int sessionId = Integer.parseInt(sessionIdStr);
    
    SessionDAO sessionDAO = new SessionDAO();
    ConsoleDAO consoleDAO = new ConsoleDAO();
    RoomDAO roomDAO = new RoomDAO();
    MemberDAO memberDAO = new MemberDAO();
    
    RentalSession rentSession = sessionDAO.findById(sessionId);
    if (rentSession == null) {
        response.sendRedirect("dashboard.jsp?error=Data sesi tidak ditemukan di DB");
        return;
    }

    ConsoleUnit console = consoleDAO.findById(rentSession.getConsoleId());
    Room room = rentSession.getRoomId() != null ? roomDAO.findById(rentSession.getRoomId()) : null;
    Member member = rentSession.getMemberId() != null ? memberDAO.findById(rentSession.getMemberId()) : null;
    
    long endTime = rentSession.getActualEndTime() != null ? rentSession.getActualEndTime().getTime() : new java.util.Date().getTime();
    long startTime = rentSession.getStartTime().getTime();
    long pausedMs = rentSession.getPausedMinutes() * 60 * 1000;
    
    long durationMs = endTime - startTime - pausedMs;
    int durationMinutesTotal = (int) (durationMs / (1000 * 60));
    int hours = durationMinutesTotal / 60;
    int minutes = durationMinutesTotal % 60;
    
    
    double ratePerHour = (console != null) ? console.getRatePerHour() : 0;
    if (room != null) ratePerHour += room.getRatePerHour();
    
    // Gunakan logika pembulatan yang SAMA dengan end_session.jsp
    double durationHoursCalc = Math.ceil(durationMs / (1000.0 * 60 * 60));
    if (durationHoursCalc < 1.0) durationHoursCalc = 1.0;
    
    // Harga Normal
    int normalPrice = (int) (durationHoursCalc * ratePerHour);
    
    // Harga Final (Dari Database)
    int finalPrice = rentSession.getTotalFee();
    
    // Selisih Diskon
    int discountAmount = normalPrice - finalPrice;
    if (discountAmount < 0) discountAmount = 0; 
%>

<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Struk Pembayaran - PSRent Max</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="../css/style.css">
    <style>
        .payment-page { min-height: 100vh; background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%); display: flex; align-items: center; justify-content: center; padding: 30px; }
        .payment-container { width: 100%; max-width: 480px; }
        .payment-card { background: var(--white); border-radius: 16px; overflow: hidden; box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3); }
        .payment-header { background: #4f46e5; color: var(--white); padding: 25px; text-align: center; }
        .receipt-container { padding: 25px; }
        .receipt { background: #fff; border: 1px solid #eee; padding: 20px; font-family: 'Courier New', monospace; font-size: 13px; line-height: 1.6; margin-bottom: 20px; border-radius: 8px; }
        .receipt-row { display: flex; justify-content: space-between; padding: 4px 0; }
        .receipt-row.total { border-top: 2px dashed #ccc; margin-top: 10px; padding-top: 10px; font-weight: bold; font-size: 16px; }
        .strike-through { text-decoration: line-through; color: #999; font-size: 12px; margin-right: 8px; }
        .btn-print { background: #333; color: white; border: none; padding: 12px; width: 100%; border-radius: 8px; cursor: pointer; font-weight: bold; }
        .btn-back { display: block; text-align: center; margin-top: 10px; color: #666; text-decoration: none; font-size: 14px; }
        
        @media print { 
            .payment-page { background: white; padding: 0; display: block; }
            .payment-card { box-shadow: none; border-radius: 0; } 
            .payment-header, .payment-actions, .btn-back { display: none; } 
            .receipt { border: none; padding: 0; font-size: 12pt; }
        }
    </style>
</head>
<body>
    <div class="payment-page">
        <div class="payment-container">
            <div class="payment-card">
                <div class="payment-header">
                    <i class="fas fa-check-circle" style="font-size: 40px; margin-bottom: 10px;"></i>
                    <h2 style="margin:0; font-size: 20px;">Pembayaran Sukses</h2>
                </div>
                <div class="receipt-container">
                    <div class="receipt">
                        <div style="text-align:center; border-bottom:1px dashed #ccc; padding-bottom:10px; margin-bottom:15px;">
                            <h3 style="margin:0; font-size:18px;">PSRent Max</h3>
                            <p style="margin:5px 0 0;"><%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(new java.util.Date()) %></p>
                        </div>
                        
                        <div class="receipt-row"><span>Order ID:</span><span>#<%= sessionId %></span></div>
                        <div class="receipt-row"><span>Pelanggan:</span><span><%= rentSession.getCustomerName() %></span></div>
                        
                        <% if (member != null) { %>
                        <div class="receipt-row">
                            <span>Member:</span>
                            <span style="font-weight:bold; color:#4f46e5;"><%= member.getLevel().getDisplayName() %></span>
                        </div>
                        <% } else { %>
                        <div class="receipt-row"><span>Member:</span><span>-</span></div>
                        <% } %>
                        
                        <hr style="border:0; border-top:1px dashed #eee; margin:10px 0;">
                        
                        <div class="receipt-row"><span>Unit:</span><span><%= console != null ? console.getType().getDisplayName() : "Unit" %></span></div>
                        <div class="receipt-row"><span>Durasi:</span><span><%= durationHoursCalc %> Jam</span></div>
                        
                        <!-- DETAIL HARGA -->
                        <div class="receipt-row"><span>Harga Normal:</span><span>Rp <%= String.format("%,.0f", (double)normalPrice) %></span></div>
                        
                        <% if (member != null && discountAmount > 0) { %>
                        <div class="receipt-row" style="color: #10b981; font-weight:bold;">
                            <span>Diskon (<%= member.getLevel().getDiscountPercent() %>%):</span>
                            <span>- Rp <%= String.format("%,.0f", (double)discountAmount) %></span>
                        </div>
                        <% } %>
                        
                        <div class="receipt-row total">
                            <span>TOTAL:</span>
                            <span>Rp <%= String.format("%,.0f", (double)finalPrice) %></span>
                        </div>
                        
                        <% if (member != null) { %>
                        <div style="text-align:center; margin-top:15px; font-size:11px; color:#666;">
                            Poin +<%= finalPrice/10000 %> | Total Poin: <%= member.getPoints() %>
                        </div>
                        <% } %>
                        
                        <div style="text-align:center; margin-top:20px; font-size:11px; font-style:italic;">
                            Terima kasih telah bermain!
                        </div>
                    </div>
                    
                    <div class="payment-actions">
                        <button class="btn-print" onclick="window.print()"><i class="fas fa-print"></i> Cetak Struk</button>
                        <a href="dashboard.jsp" class="btn-back">Kembali ke Dashboard</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>