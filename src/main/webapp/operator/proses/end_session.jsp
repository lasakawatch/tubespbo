<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.mycompany.dao.*" %>
<%@ page import="com.mycompany.model.*" %>
<%@ page import="com.mycompany.model.enums.*" %>

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
                
                // 2. Hitung Durasi
                // FIXED: Gunakan durasi yang sudah dipesan (planned), bukan waktu real
                // Karena waktu real bisa dipengaruhi oleh kapan user klik "Selesai"
                long endTime = new java.util.Date().getTime();
                long startTime = rentSession.getStartTime().getTime();
                long plannedEnd = rentSession.getPlannedEndTime().getTime();
                long pausedMs = rentSession.getPausedMinutes() * 60 * 1000;
                
                // Durasi yang sebenarnya dimainkan (real duration)
                long realDurationMs = endTime - startTime - pausedMs;
                
                // Durasi yang dipesan (planned duration) - tanpa hitung pause karena planned sudah di-extend
                long plannedDurationMs = plannedEnd - startTime - pausedMs;
                
                // Gunakan durasi TERPAKAI yang lebih besar
                // Jika user main lebih lama dari booking -> charge lebih
                // Jika user selesai lebih cepat -> tetap charge sesuai booking
                long billableDurationMs = Math.max(realDurationMs, plannedDurationMs);
                
                // Konversi ke Jam (Pembulatan ke atas, minimal 1 jam)
                double durationHours = Math.ceil(billableDurationMs / (1000.0 * 60 * 60));
                if (durationHours < 1.0) durationHours = 1.0;
                
                // 3. Hitung Base Rate (Harga Konsol + Harga Ruangan)
                double ratePerHour = console.getRatePerHour();
                if (room != null) ratePerHour += room.getRatePerHour();
                
                // 4. Hitung Harga Normal (Sebelum Diskon)
                double normalPrice = durationHours * ratePerHour;
                
                // 5. HITUNG DISKON MEMBER (LOGIC UTAMA)
                double discountAmount = 0;
                Member member = null;
                
                if (rentSession.getMemberId() != null && rentSession.getMemberId() > 0) {
                    member = memberDAO.findById(rentSession.getMemberId());
                    if (member != null) {
                        // Ambil persen diskon dari Enum MemberLevel yang baru kita edit
                        int discountPercent = member.getLevel().getDiscountPercent();
                        
                        // Hitung potongan
                        discountAmount = normalPrice * (discountPercent / 100.0);
                    }
                }
                
                // 6. Harga Akhir
                int finalPrice = (int) (normalPrice - discountAmount);
                
                // 7. Update Object Session
                rentSession.setActualEndTime(new Timestamp(endTime));
                rentSession.setTotalFee(finalPrice);
                rentSession.setStatus(SessionStatus.COMPLETED);
                
                // 8. Simpan ke Database
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
                    // Misal: Tiap Rp 10.000 bayar = 1 Poin
                    if (member != null) {
                        int pointsEarned = finalPrice / 10000;
                        member.setPoints(member.getPoints() + pointsEarned);
                        member.setTotalRentals(member.getTotalRentals() + 1);
                        memberDAO.update(member);
                    }
                    
                    // Simpan data pembayaran ke tabel payments (Optional tapi bagus buat laporan)
                    // Disini kita skip logic payment insert DAO biar simpel, anggap tercatat di session
                    
                    // Redirect ke Halaman Pembayaran/Struk
                    response.sendRedirect("../payment.jsp?sessionId=" + id);
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