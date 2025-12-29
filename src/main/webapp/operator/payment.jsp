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
    
    // Ambil parameter dari end_session.jsp
    String normalPriceStr = request.getParameter("normalPrice");
    String weekendSurchargeStr = request.getParameter("weekendSurcharge");
    String discountAmountStr = request.getParameter("discountAmount");
    String discountPercentStr = request.getParameter("discountPercent");
    String finalPriceStr = request.getParameter("finalPrice");
    String durationHoursStr = request.getParameter("durationHours");
    String isWeekendStr = request.getParameter("isWeekend");
    
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
    
    // Parse nilai atau hitung ulang jika tidak ada parameter
    int normalPrice = 0;
    int weekendSurcharge = 0;
    int discountAmount = 0;
    int discountPercent = 0;
    int finalPrice = rentSession.getTotalFee();
    double durationHours = 1.0;
    boolean isWeekend = false;
    
    if (normalPriceStr != null) {
        normalPrice = Integer.parseInt(normalPriceStr);
        weekendSurcharge = Integer.parseInt(weekendSurchargeStr);
        discountAmount = Integer.parseInt(discountAmountStr);
        discountPercent = Integer.parseInt(discountPercentStr);
        finalPrice = Integer.parseInt(finalPriceStr);
        durationHours = Double.parseDouble(durationHoursStr);
        isWeekend = Boolean.parseBoolean(isWeekendStr);
    } else {
        // Fallback: hitung ulang jika tidak ada parameter (untuk backward compatibility)
        long startTime = rentSession.getStartTime().getTime();
        long plannedEnd = rentSession.getPlannedEndTime().getTime();
        long plannedDurationMs = plannedEnd - startTime;
        durationHours = Math.ceil(plannedDurationMs / (1000.0 * 60 * 60));
        if (durationHours < 1.0) durationHours = 1.0;
        
        double consoleRate = (console != null) ? console.getRatePerHour() : 0;
        double roomRate = (room != null) ? room.getRatePerHour() : 0;
        normalPrice = (int) (durationHours * (consoleRate + roomRate));
        
        // Check weekend
        Calendar cal = Calendar.getInstance();
        cal.setTimeInMillis(rentSession.getStartTime().getTime());
        int dayOfWeek = cal.get(Calendar.DAY_OF_WEEK);
        isWeekend = (dayOfWeek == Calendar.SATURDAY || dayOfWeek == Calendar.SUNDAY);
        
        if (isWeekend) {
            weekendSurcharge = (int) (normalPrice * 0.5);
        }
        
        int subtotal = normalPrice + weekendSurcharge;
        
        if (member != null) {
            discountPercent = member.getLevel().getDiscountPercent();
            discountAmount = (int) (subtotal * (discountPercent / 100.0));
        }
        
        finalPrice = subtotal - discountAmount;
    }
    
    int subtotalAfterSurcharge = normalPrice + weekendSurcharge;
    
    // Format tanggal
    java.text.SimpleDateFormat dateFormat = new java.text.SimpleDateFormat("dd MMMM yyyy", new java.util.Locale("id", "ID"));
    java.text.SimpleDateFormat timeFormat = new java.text.SimpleDateFormat("HH:mm");
    java.text.SimpleDateFormat fullFormat = new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm");
    
    String tanggalStr = dateFormat.format(rentSession.getStartTime());
    String jamMulai = timeFormat.format(rentSession.getStartTime());
    String jamSelesai = rentSession.getActualEndTime() != null ? timeFormat.format(rentSession.getActualEndTime()) : timeFormat.format(new java.util.Date());
    
    // Hitung poin yang didapat
    int pointsEarned = finalPrice / 10000;
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
        .payment-container { width: 100%; max-width: 500px; }
        .payment-card { background: var(--white); border-radius: 16px; overflow: hidden; box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3); }
        .payment-header { background: linear-gradient(135deg, #10b981 0%, #059669 100%); color: var(--white); padding: 25px; text-align: center; }
        .payment-header.weekend { background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%); }
        .receipt-container { padding: 25px; }
        .receipt { background: #fafafa; border: 2px dashed #ddd; padding: 20px; font-family: 'Courier New', monospace; font-size: 13px; line-height: 1.8; margin-bottom: 20px; border-radius: 8px; }
        .receipt-header { text-align: center; border-bottom: 2px dashed #ccc; padding-bottom: 15px; margin-bottom: 15px; }
        .receipt-header h3 { margin: 0; font-size: 20px; letter-spacing: 2px; }
        .receipt-header p { margin: 5px 0 0; font-size: 12px; color: #666; }
        .receipt-row { display: flex; justify-content: space-between; padding: 4px 0; }
        .receipt-row.highlight { background: #fff3cd; margin: 0 -10px; padding: 4px 10px; border-radius: 4px; }
        .receipt-row.discount { color: #10b981; }
        .receipt-row.surcharge { color: #f59e0b; }
        .receipt-divider { border: 0; border-top: 1px dashed #ccc; margin: 12px 0; }
        .receipt-total { border-top: 2px dashed #333; margin-top: 15px; padding-top: 15px; }
        .receipt-total .receipt-row { font-weight: bold; font-size: 18px; }
        .badge-weekend { background: #fef3c7; color: #92400e; padding: 4px 10px; border-radius: 12px; font-size: 11px; font-weight: bold; }
        .badge-member { background: #dbeafe; color: #1e40af; padding: 4px 10px; border-radius: 12px; font-size: 11px; font-weight: bold; }
        .points-box { background: linear-gradient(135deg, #8b5cf6 0%, #6d28d9 100%); color: white; padding: 12px; border-radius: 8px; text-align: center; margin-top: 15px; }
        .btn-print { background: #333; color: white; border: none; padding: 14px; width: 100%; border-radius: 8px; cursor: pointer; font-weight: bold; font-size: 15px; transition: all 0.3s; }
        .btn-print:hover { background: #000; transform: translateY(-2px); }
        .btn-back { display: block; text-align: center; margin-top: 12px; color: #666; text-decoration: none; font-size: 14px; }
        .btn-back:hover { color: #333; }
        
        @media print { 
            body { margin: 0; padding: 0; }
            .payment-page { background: white; padding: 0; display: block; min-height: auto; }
            .payment-card { box-shadow: none; border-radius: 0; } 
            .payment-header { display: none; } 
            .payment-actions { display: none; }
            .receipt { border: none; padding: 0; font-size: 11pt; background: white; }
            .receipt-header h3 { font-size: 16pt; }
        }
    </style>
</head>
<body>
    <div class="payment-page">
        <div class="payment-container">
            <div class="payment-card">
                <div class="payment-header <%= isWeekend ? "weekend" : "" %>">
                    <i class="fas fa-check-circle" style="font-size: 48px; margin-bottom: 12px;"></i>
                    <h2 style="margin:0; font-size: 22px;">Pembayaran Berhasil!</h2>
                    <% if (isWeekend) { %>
                    <p style="margin: 8px 0 0; opacity: 0.9;"><i class="fas fa-calendar-alt"></i> Tarif Weekend Berlaku</p>
                    <% } %>
                </div>
                
                <div class="receipt-container">
                    <div class="receipt">
                        <!-- Header Struk -->
                        <div class="receipt-header">
                            <h3>PSRENT MAX</h3>
                            <p>PlayStation Rental Center</p>
                            <p style="margin-top: 10px;"><%= fullFormat.format(new java.util.Date()) %></p>
                        </div>
                        
                        <!-- Info Transaksi -->
                        <div class="receipt-row"><span>No. Transaksi</span><span><strong>#<%= String.format("%06d", sessionId) %></strong></span></div>
                        <div class="receipt-row"><span>Tanggal Main</span><span><%= tanggalStr %></span></div>
                        <div class="receipt-row"><span>Jam</span><span><%= jamMulai %> - <%= jamSelesai %></span></div>
                        
                        <hr class="receipt-divider">
                        
                        <!-- Info Pelanggan -->
                        <div class="receipt-row">
                            <span>Pelanggan</span>
                            <span><%= rentSession.getCustomerName() != null ? rentSession.getCustomerName() : "Guest" %></span>
                        </div>
                        <% if (member != null) { %>
                        <div class="receipt-row">
                            <span>Status</span>
                            <span class="badge-member"><i class="fas fa-crown"></i> <%= member.getLevel().getDisplayName() %></span>
                        </div>
                        <% } %>
                        
                        <hr class="receipt-divider">
                        
                        <!-- Detail Unit -->
                        <div class="receipt-row">
                            <span>Unit</span>
                            <span><%= console != null ? console.getType().getDisplayName() : "PlayStation" %></span>
                        </div>
                        <% if (room != null) { %>
                        <div class="receipt-row"><span>Ruangan</span><span><%= room.getName() %></span></div>
                        <% } %>
                        <div class="receipt-row"><span>Durasi</span><span><%= (int)durationHours %> Jam</span></div>
                        
                        <hr class="receipt-divider">
                        
                        <!-- Rincian Biaya -->
                        <div style="font-weight: bold; margin-bottom: 8px;">RINCIAN BIAYA:</div>
                        
                        <div class="receipt-row">
                            <span>Harga Normal (<%= (int)durationHours %> jam)</span>
                            <span>Rp <%= String.format("%,d", normalPrice) %></span>
                        </div>
                        
                        <% if (isWeekend && weekendSurcharge > 0) { %>
                        <div class="receipt-row surcharge highlight">
                            <span><i class="fas fa-sun"></i> Surcharge Weekend (+50%)</span>
                            <span>+ Rp <%= String.format("%,d", weekendSurcharge) %></span>
                        </div>
                        <% } %>
                        
                        <% if (isWeekend || weekendSurcharge > 0) { %>
                        <div class="receipt-row" style="font-size: 12px; color: #666;">
                            <span>Subtotal</span>
                            <span>Rp <%= String.format("%,d", subtotalAfterSurcharge) %></span>
                        </div>
                        <% } %>
                        
                        <% if (member != null && discountAmount > 0) { %>
                        <div class="receipt-row discount">
                            <span><i class="fas fa-tag"></i> Diskon Member <%= member.getLevel().getDisplayName() %> (<%= discountPercent %>%)</span>
                            <span>- Rp <%= String.format("%,d", discountAmount) %></span>
                        </div>
                        <% } %>
                        
                        <!-- Total -->
                        <div class="receipt-total">
                            <div class="receipt-row">
                                <span>TOTAL BAYAR</span>
                                <span style="color: #10b981;">Rp <%= String.format("%,d", finalPrice) %></span>
                            </div>
                        </div>
                        
                        <% if (member != null) { %>
                        <div class="points-box">
                            <i class="fas fa-star"></i> Anda mendapat <strong>+<%= pointsEarned %> Poin</strong><br>
                            <small>Total Poin: <%= member.getPoints() %></small>
                        </div>
                        <% } %>
                        
                        <!-- Footer Struk -->
                        <div style="text-align: center; margin-top: 20px; padding-top: 15px; border-top: 1px dashed #ccc;">
                            <p style="margin: 0; font-size: 12px;">Terima kasih telah bermain!</p>
                            <p style="margin: 5px 0 0; font-size: 11px; color: #999;">Simpan struk ini sebagai bukti pembayaran</p>
                        </div>
                    </div>
                    
                    <div class="payment-actions">
                        <button class="btn-print" onclick="window.print()">
                            <i class="fas fa-print"></i> Cetak Struk
                        </button>
                        <a href="dashboard.jsp" class="btn-back">
                            <i class="fas fa-arrow-left"></i> Kembali ke Dashboard
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
