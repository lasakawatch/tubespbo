package com.mycompany.model.report;

import com.mycompany.model.RentalSession;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * Abstract Class Laporan - Implementasi Abstraction
 * Kelas induk untuk berbagai jenis laporan
 */
public abstract class Laporan {
    protected Date tanggalGenerate;
    protected List<RentalSession> dataSessions;
    
    public Laporan() {
        this.tanggalGenerate = new Date();
        this.dataSessions = new ArrayList<>();
    }
    
    /**
     * Abstract method untuk generate laporan
     * Akan diimplementasikan oleh kelas anak
     */
    public abstract String generateLaporan();
    
    /**
     * Abstract method untuk menghitung total pendapatan
     */
    public abstract int hitungTotalPendapatan();
    
    /**
     * Export laporan ke format PDF (placeholder)
     */
    public void exportPDF() {
        // Placeholder untuk export PDF
        System.out.println("Exporting to PDF...");
    }
    
    // Getters and Setters
    public Date getTanggalGenerate() {
        return tanggalGenerate;
    }
    
    public void setTanggalGenerate(Date tanggalGenerate) {
        this.tanggalGenerate = tanggalGenerate;
    }
    
    public List<RentalSession> getDataSessions() {
        return dataSessions;
    }
    
    public void setDataSessions(List<RentalSession> dataSessions) {
        this.dataSessions = dataSessions;
    }
}
