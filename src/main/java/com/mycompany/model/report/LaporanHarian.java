package com.mycompany.model.report;

import com.mycompany.model.RentalSession;
import com.mycompany.model.Payment;
import com.mycompany.model.enums.SessionStatus;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

/**
 * LaporanHarian - extends Laporan (Inheritance)
 * Laporan pendapatan harian
 */
public class LaporanHarian extends Laporan {
    private Date tanggal;
    private List<Payment> payments = new ArrayList<>();
    
    /**
     * Default constructor
     */
    public LaporanHarian() {
        super();
        this.tanggal = new Date();
    }
    
    public LaporanHarian(Date tanggal) {
        super();
        this.tanggal = tanggal;
    }
    
    /**
     * Set sessions
     */
    public void setSessions(List<RentalSession> sessions) {
        this.dataSessions = sessions;
    }
    
    /**
     * Set payments
     */
    public void setPayments(List<Payment> payments) {
        this.payments = payments;
    }
    
    /**
     * Set report date
     */
    public void setReportDate(Date date) {
        this.tanggal = date;
    }
    
    /**
     * Filter sesi berdasarkan tanggal tertentu (accepts Date)
     */
    public void filterByDate(Date date) {
        this.tanggal = date;
        filterByDate(this.dataSessions);
    }
    
    /**
     * Filter sesi berdasarkan tanggal tertentu
     * @param sessions List semua sesi
     * @return List sesi yang sesuai dengan tanggal laporan
     */
    public List<RentalSession> filterByDate(List<RentalSession> sessions) {
        List<RentalSession> filtered = new ArrayList<>();
        Calendar filterCal = Calendar.getInstance();
        filterCal.setTime(tanggal);
        
        for (RentalSession session : sessions) {
            if (session.getStatus() == SessionStatus.COMPLETED && session.getActualEndTime() != null) {
                Calendar sessionCal = Calendar.getInstance();
                sessionCal.setTimeInMillis(session.getActualEndTime().getTime());
                
                if (filterCal.get(Calendar.YEAR) == sessionCal.get(Calendar.YEAR) &&
                    filterCal.get(Calendar.DAY_OF_YEAR) == sessionCal.get(Calendar.DAY_OF_YEAR)) {
                    filtered.add(session);
                }
            }
        }
        
        this.dataSessions = filtered;
        return filtered;
    }
    
    /**
     * Generate report (alias for generateLaporan)
     */
    public String generateReport() {
        return generateLaporan();
    }
    
    @Override
    public String generateLaporan() {
        SimpleDateFormat sdf = new SimpleDateFormat("dd MMMM yyyy");
        StringBuilder report = new StringBuilder();
        
        report.append("╔════════════════════════════════════════════════════════════╗\n");
        report.append("║           📊 LAPORAN HARIAN PSRent Max 📊                  ║\n");
        report.append("╠════════════════════════════════════════════════════════════╣\n");
        report.append(String.format("║ Tanggal: %-49s ║\n", sdf.format(tanggal)));
        report.append(String.format("║ Generated: %-47s ║\n", sdf.format(tanggalGenerate)));
        report.append("╠════════════════════════════════════════════════════════════╣\n");
        report.append(String.format("║ Jumlah Sesi   : %-42d ║\n", dataSessions.size()));
        report.append(String.format("║ Total Pendapatan : Rp %-36s ║\n", String.format("%,d", hitungTotalPendapatan())));
        report.append("╠════════════════════════════════════════════════════════════╣\n");
        report.append("║                    DETAIL SESI                             ║\n");
        report.append("╠════════════════════════════════════════════════════════════╣\n");
        
        if (dataSessions.isEmpty()) {
            report.append("║ Tidak ada sesi pada tanggal ini                            ║\n");
        } else {
            SimpleDateFormat timeFmt = new SimpleDateFormat("HH:mm");
            for (RentalSession session : dataSessions) {
                String roomName = session.getRoom() != null ? session.getRoom().getName() : "-";
                String startTime = timeFmt.format(session.getStartTime());
                String endTime = session.getActualEndTime() != null ? timeFmt.format(session.getActualEndTime()) : "-";
                
                report.append(String.format("║ %-15s | %s - %s | Rp %-18s ║\n", 
                    roomName, startTime, endTime, String.format("%,d", session.getTotalFee())));
            }
        }
        
        report.append("╚════════════════════════════════════════════════════════════╝\n");
        
        return report.toString();
    }
    
    @Override
    public int hitungTotalPendapatan() {
        int total = 0;
        for (RentalSession session : dataSessions) {
            total += session.getTotalFee();
        }
        return total;
    }
    
    // Getters and Setters
    public Date getTanggal() {
        return tanggal;
    }
    
    public void setTanggal(Date tanggal) {
        this.tanggal = tanggal;
    }
}
