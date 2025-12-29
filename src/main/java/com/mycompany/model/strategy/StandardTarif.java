package com.mycompany.model.strategy;

import com.mycompany.model.RentalSession;

/**
 * StandardTarif - Implementasi Strategy Pattern
 * Tarif standard untuk hari kerja (weekday)
 */
public class StandardTarif implements RentalTarifStrategy {
    
    @Override
    public int calculateFee(RentalSession session) {
        int durationMinutes = session.getActualDurationMinutes();
        int hourlyRate = session.getConsoleUnit() != null ? 
                         session.getConsoleUnit().getBaseHourlyRate() : 15000;
        
        // Hitung berdasarkan menit (proporsional)
        double hours = durationMinutes / 60.0;
        int totalFee = (int) Math.ceil(hours * hourlyRate);
        
        // Minimum charge 30 menit
        if (durationMinutes > 0 && durationMinutes < 30) {
            totalFee = (int) (hourlyRate / 2);
        }
        
        return totalFee;
    }
    
    @Override
    public String getLabel() {
        return "Standard (Weekday)";
    }
}
