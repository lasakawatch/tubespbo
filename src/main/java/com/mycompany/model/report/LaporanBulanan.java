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
 * LaporanBulanan - extends Laporan (Inheritance)
 * Laporan pendapatan bulanan
 */
public class LaporanBulanan extends Laporan {
    private int bulan; // 1-12
    private int tahun;
    private List<Payment> payments = new ArrayList<>();
    
    /**
     * Default constructor
     */
    public LaporanBulanan() {
        super();
        Calendar cal = Calendar.getInstance();
        this.bulan = cal.get(Calendar.MONTH) + 1;
        this.tahun = cal.get(Calendar.YEAR);
    }
    
    public LaporanBulanan(int bulan, int tahun) {
        super();
        this.bulan = bulan;
        this.tahun = tahun;
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
        Calendar cal = Calendar.getInstance();
        cal.setTime(date);
        this.bulan = cal.get(Calendar.MONTH) + 1;
        this.tahun = cal.get(Calendar.YEAR);
    }
    
    /**
     * Filter by month and year (overload)
     */
    public void filterByMonth(int month, int year) {
        this.bulan = month;
        this.tahun = year;
        filterByMonth(this.dataSessions);
    }
    
    /**
     * Generate report (alias for generateLaporan)
     */
    public String generateReport() {
        return generateLaporan();
    }
    
    /**
     * Filter sesi berdasarkan bulan dan tahun
     * @param sessions List semua sesi
     * @return List sesi yang sesuai dengan bulan dan tahun laporan
     */
    public List<RentalSession> filterByMonth(List<RentalSession> sessions) {
        List<RentalSession> filtered = new ArrayList<>();
        
        for (RentalSession session : sessions) {
            if (session.getStatus() == SessionStatus.COMPLETED && session.getActualEndTime() != null) {
                Calendar sessionCal = Calendar.getInstance();
                sessionCal.setTimeInMillis(session.getActualEndTime().getTime());
                
                if ((sessionCal.get(Calendar.MONTH) + 1) == bulan && 
                    sessionCal.get(Calendar.YEAR) == tahun) {
                    filtered.add(session);
                }
            }
        }
        
        this.dataSessions = filtered;
        return filtered;
    }
    
    @Override
    public String generateLaporan() {
        SimpleDateFormat sdf = new SimpleDateFormat("dd MMMM yyyy HH:mm");
        String[] namaBulan = {"", "Januari", "Februari", "Maret", "April", "Mei", "Juni",
                              "Juli", "Agustus", "September", "Oktober", "November", "Desember"};
        
        StringBuilder report = new StringBuilder();
        
        report.append("╔════════════════════════════════════════════════════════════╗\n");
        report.append("║          📊 LAPORAN BULANAN PSRent Max 📊                  ║\n");
        report.append("╠════════════════════════════════════════════════════════════╣\n");
        report.append(String.format("║ Periode: %-49s ║\n", namaBulan[bulan] + " " + tahun));
        report.append(String.format("║ Generated: %-47s ║\n", sdf.format(tanggalGenerate)));
        report.append("╠════════════════════════════════════════════════════════════╣\n");
        report.append(String.format("║ Jumlah Sesi      : %-39d ║\n", dataSessions.size()));
        report.append(String.format("║ Total Pendapatan : Rp %-36s ║\n", String.format("%,d", hitungTotalPendapatan())));
        report.append(String.format("║ Rata-rata/Sesi   : Rp %-36s ║\n", 
            String.format("%,d", dataSessions.isEmpty() ? 0 : hitungTotalPendapatan() / dataSessions.size())));
        report.append("╠════════════════════════════════════════════════════════════╣\n");
        report.append("║                  RINGKASAN PER TANGGAL                     ║\n");
        report.append("╠════════════════════════════════════════════════════════════╣\n");
        
        if (dataSessions.isEmpty()) {
            report.append("║ Tidak ada sesi pada bulan ini                              ║\n");
        } else {
            // Group by date and count
            SimpleDateFormat dateFmt = new SimpleDateFormat("dd/MM/yyyy");
            java.util.Map<String, int[]> dailyStats = new java.util.TreeMap<>();
            
            for (RentalSession session : dataSessions) {
                String dateKey = dateFmt.format(session.getActualEndTime());
                if (!dailyStats.containsKey(dateKey)) {
                    dailyStats.put(dateKey, new int[]{0, 0}); // [count, total]
                }
                dailyStats.get(dateKey)[0]++;
                dailyStats.get(dateKey)[1] += session.getTotalFee();
            }
            
            for (java.util.Map.Entry<String, int[]> entry : dailyStats.entrySet()) {
                report.append(String.format("║ %s | %3d sesi | Rp %-23s ║\n", 
                    entry.getKey(), entry.getValue()[0], String.format("%,d", entry.getValue()[1])));
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
    public int getBulan() {
        return bulan;
    }
    
    public void setBulan(int bulan) {
        this.bulan = bulan;
    }
    
    public int getTahun() {
        return tahun;
    }
    
    public void setTahun(int tahun) {
        this.tahun = tahun;
    }
}
