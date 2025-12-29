<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.mycompany.dao.*" %>
<%@ page import="com.mycompany.model.*" %>
<%@ page import="com.mycompany.model.enums.*" %>
<%@ page import="com.mycompany.model.strategy.TarifFactory" %>

<%
    String role = (String) session.getAttribute("role");
    if (role == null || !role.equals("OPERATOR")) {
        response.sendRedirect("../../index.jsp");
        return;
    }

    String idStr = request.getParameter("id");
    if (idStr != null) {
        SessionDAO sessionDAO = new SessionDAO();
        ConsoleDAO consoleDAO = new ConsoleDAO();
        RoomDAO roomDAO = new RoomDAO();
        MemberDAO memberDAO = new MemberDAO();
        PaymentDAO paymentDAO = new PaymentDAO();
        
        try {
            int id = Integer.parseInt(idStr);
            RentalSession rentSession = sessionDAO.findById(id);
            
            if (rentSession != null) {
                // 1. Ambil Data Pendukung
                ConsoleUnit console = consoleDAO.findById(rentSession.getConsoleId());
                Room room = null;
                if(rentSession.getRoomId() != null && rentSession.getRoomId() > 0) {
                    room = roomDAO.findById(rentSession.getRoomId());
                }
                
                // 2. Hitung Durasi berdasarkan PLANNED (yang sudah dipesan)
                long endTime = new java.util.Date().getTime();
                long startTime = rentSession.getStartTime().getTime();
                long plannedEnd = rentSession.getPlannedEndTime().getTime();
                
                // Durasi yang dipesan (dari start sampai planned end)
                long plannedDurationMs = plannedEnd - startTime;
                
                // Konversi ke Jam (Pembulatan ke atas, minimal 1 jam)
                double durationHours = Math.ceil(plannedDurationMs / (1000.0 * 60 * 60));
                if (durationHours < 1.0) durationHours = 1.0;
                
                // 3. Hitung Base Rate (Harga Konsol + Harga Ruangan)
                double consoleRate = console.getRatePerHour();
                double roomRate = (room != null) ? room.getRatePerHour() : 0;
                double baseRatePerHour = consoleRate + roomRate;
                
                // 4. Hitung Harga Normal (Sebelum Surcharge dan Diskon)
                double normalPrice = durationHours * baseRatePerHour;
                
                // 5. CEK WEEKEND SURCHARGE (+50%)
                boolean isWeekend = TarifFactory.isWeekend();
                double weekendSurcharge = 0;
                if (isWeekend) {
                    weekendSurcharge = normalPrice * 0.5; // +50%
                }
                
                // Subtotal setelah weekend surcharge
                double subtotalAfterSurcharge = normalPrice + weekendSurcharge;
                
                // 6. HITUNG DISKON MEMBER
                double discountAmount = 0;
                int discountPercent = 0;
                Member member = null;
                
                if (rentSession.getMemberId() != null && rentSession.getMemberId() > 0) {
                    member = memberDAO.findById(rentSession.getMemberId());
                    if (member != null) {
                        discountPercent = member.getLevel().getDiscountPercent();
                        discountAmount = subtotalAfterSurcharge * (discountPercent / 100.0);
                    }
                }
                
                // 7. Harga Akhir
                int finalPrice = (int) Math.round(subtotalAfterSurcharge - discountAmount);
                
                // 8. Update Object Session dengan info tarif
                rentSession.setActualEndTime(new Timestamp(endTime));
                rentSession.setTotalFee(finalPrice);
                rentSession.setStatus(SessionStatus.COMPLETED);
                rentSession.setTarifType(isWeekend ? "WEEKEND" : "STANDARD");
                
                // 9. Simpan ke Database
                if (sessionDAO.update(rentSession)) {
                    // Update status Konsol jadi AVAILABLE lagi
                    console.setStatus(ConsoleStatus.AVAILABLE);
                    consoleDAO.update(console);
                    
                    // Update Room jadi AVAILABLE lagi
                    if (room != null) {
                        room.setStatus(RoomStatus.AVAILABLE);
                        roomDAO.update(room);
                    }
                    
                    // UPDATE POIN MEMBER (Bonus)
                    if (member != null) {
                        int pointsEarned = finalPrice / 10000;
                        member.setPoints(member.getPoints() + pointsEarned);
                        member.setTotalRentals(member.getTotalRentals() + 1);
                        memberDAO.update(member);
                    }
                    
                    // 10. Simpan ke tabel payments untuk laporan
                    Payment payment = new Payment();
                    payment.setSessionId(rentSession.getId());
                    payment.setAmount(finalPrice);
                    payment.setPaymentMethod(com.mycompany.model.enums.PaymentMethod.CASH);
                    payment.setPaymentTime(new Timestamp(endTime));
                    paymentDAO.save(payment);
                    
                    // Redirect ke Halaman Pembayaran/Struk dengan data lengkap
                    String params = "?sessionId=" + id + 
                                   "&normalPrice=" + (int)normalPrice +
                                   "&weekendSurcharge=" + (int)weekendSurcharge +
                                   "&discountAmount=" + (int)discountAmount +
                                   "&discountPercent=" + discountPercent +
                                   "&finalPrice=" + finalPrice +
                                   "&durationHours=" + durationHours +
                                   "&isWeekend=" + isWeekend;
                    response.sendRedirect("../payment.jsp" + params);
                } else {
                    response.sendRedirect("../dashboard.jsp?error=Gagal mengupdate sesi");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("../dashboard.jsp?error=Error: " + e.getMessage());
        }
    } else {
        response.sendRedirect("../dashboard.jsp");
    }
%>