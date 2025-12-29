<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>
<%@ page import="com.mycompany.dao.*" %>
<%@ page import="com.mycompany.model.*" %>
<%@ page import="com.mycompany.model.report.*" %>

<%
    // Cek Admin
    String role = (String) session.getAttribute("role");
    if (role == null || !role.equals("ADMIN")) {
        response.sendRedirect("../../index.jsp?error=unauthorized");
        return;
    }
    
    String reportType = request.getParameter("reportType");
    String reportDateStr = request.getParameter("reportDate");
    
    try {
        SimpleDateFormat sdfInput = new SimpleDateFormat("yyyy-MM-dd");
        Date reportDate = sdfInput.parse(reportDateStr);
        
        SessionDAO sessionDAO = new SessionDAO();
        PaymentDAO paymentDAO = new PaymentDAO();
        
        List<RentalSession> allSessions = sessionDAO.findAll();
        List<Payment> allPayments = paymentDAO.findAll();
        
        // Setup Logic Filter
        Laporan laporan = null;
        String periodeTitle = "";
        
        if ("daily".equals(reportType)) {
            LaporanHarian lh = new LaporanHarian();
            lh.setSessions(allSessions);
            lh.setReportDate(reportDate);
            lh.filterByDate(reportDate);
            laporan = lh;
            periodeTitle = new SimpleDateFormat("dd MMMM yyyy", new Locale("id", "ID")).format(reportDate);
            
        } else if ("monthly".equals(reportType)) {
            LaporanBulanan lb = new LaporanBulanan();
            lb.setSessions(allSessions);
            lb.setReportDate(reportDate);
            
            Calendar cal = Calendar.getInstance();
            cal.setTime(reportDate);
            int month = cal.get(Calendar.MONTH) + 1;
            int year = cal.get(Calendar.YEAR);
            
            lb.filterByMonth(month, year);
            laporan = lb;
            periodeTitle = new SimpleDateFormat("MMMM yyyy", new Locale("id", "ID")).format(reportDate);
        }
        
        // --- BUILD HTML REPORT MODERN ---
        StringBuilder html = new StringBuilder();
        SimpleDateFormat timeFmt = new SimpleDateFormat("HH:mm");
        SimpleDateFormat dateFmt = new SimpleDateFormat("dd/MM/yyyy");
        
        // 1. KOP SURAT
        html.append("<div class='report-header'>");
        html.append("<div class='company-info'>");
        html.append("<h1>PSRent Max</h1>");
        html.append("<p>Jl. Telekomunikasi No. 1, Bandung, Jawa Barat</p>");
        html.append("<p>Telp: (022) 7564108 | Email: admin@psrentmax.com</p>");
        html.append("</div>");
        html.append("<div class='report-meta'>");
        html.append("<h2>LAPORAN PENDAPATAN " + (reportType.equals("daily") ? "HARIAN" : "BULANAN") + "</h2>");
        html.append("<p>Periode: <strong>" + periodeTitle + "</strong></p>");
        html.append("<p>Dicetak: " + new SimpleDateFormat("dd/MM/yyyy HH:mm").format(new Date()) + "</p>");
        html.append("</div>");
        html.append("</div>");
        
        html.append("<hr class='report-divider'>");
        
        // 2. RINGKASAN KARTU
        html.append("<div class='report-summary'>");
        html.append("<div class='summary-box'>");
        html.append("<span class='label'>Total Transaksi</span>");
        html.append("<span class='value'>" + laporan.getDataSessions().size() + " Sesi</span>");
        html.append("</div>");
        html.append("<div class='summary-box highlight'>");
        html.append("<span class='label'>Total Pendapatan</span>");
        html.append("<span class='value'>Rp " + String.format("%,d", laporan.hitungTotalPendapatan()).replace(',', '.') + "</span>");
        html.append("</div>");
        html.append("</div>");
        
        // 3. TABEL DATA
        html.append("<table class='report-table'>");
        html.append("<thead><tr>");
        html.append("<th>No</th>");
        html.append("<th>Tanggal</th>");
        html.append("<th>Unit / Room</th>");
        html.append("<th>Durasi</th>");
        html.append("<th>Pelanggan</th>");
        html.append("<th style='text-align:right'>Total Biaya</th>");
        html.append("</tr></thead><tbody>");
        
        List<RentalSession> data = laporan.getDataSessions();
        if (data.isEmpty()) {
            html.append("<tr><td colspan='6' style='text-align:center; padding:20px;'>Tidak ada data transaksi pada periode ini.</td></tr>");
        } else {
            int no = 1;
            for (RentalSession s : data) {
                String roomName = (s.getRoom() != null) ? s.getRoom().getName() : "-";
                String consoleName = (s.getConsoleUnit() != null) ? s.getConsoleUnit().getType().getDisplayName() : "Unknown";
                String startTime = s.getStartTime() != null ? timeFmt.format(s.getStartTime()) : "-";
                String endTime = s.getActualEndTime() != null ? timeFmt.format(s.getActualEndTime()) : "-";
                String dateStr = s.getActualEndTime() != null ? dateFmt.format(s.getActualEndTime()) : "-";
                
                html.append("<tr>");
                html.append("<td>" + (no++) + "</td>");
                html.append("<td>" + dateStr + "</td>");
                html.append("<td><strong>" + roomName + "</strong><br><small>" + consoleName + "</small></td>");
                html.append("<td>" + startTime + " - " + endTime + "</td>");
                html.append("<td>" + s.getCustomerName() + "</td>");
                html.append("<td style='text-align:right; font-weight:bold;'>Rp " + String.format("%,d", s.getTotalFee()).replace(',', '.') + "</td>");
                html.append("</tr>");
            }
        }
        html.append("</tbody></table>");
        
        // 4. FOOTER / TTD
        html.append("<div class='report-footer'>");
        html.append("<div class='signature'>");
        html.append("<p>Bandung, " + new SimpleDateFormat("dd MMMM yyyy", new Locale("id", "ID")).format(new Date()) + "</p>");
        html.append("<p>Mengetahui,</p>");
        html.append("<br><br><br>");
        html.append("<p><strong>( Administrator )</strong></p>");
        html.append("</div>");
        html.append("</div>");
        
        // Simpan ke Session
        session.setAttribute("reportContent", html.toString());
        
        response.sendRedirect("../dashboard.jsp?tab=laporan&success=Laporan berhasil digenerate");
        
    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("../dashboard.jsp?tab=laporan&error=" + e.getMessage());
    }
%>