package com.mycompany.model.strategy;

import com.mycompany.model.RentalSession;

/**
 * WeekendTarif - Implementasi Strategy Pattern
 * Tarif weekend dengan tambahan 50% dari tarif standard
 */
public class WeekendTarif implements RentalTarifStrategy {
    
    private static final double WEEKEND_MULTIPLIER = 1.5; // +50%
    
    @Override
    public int calculateFee(RentalSession session) {
        int durationMinutes = session.getActualDurationMinutes();
        int hourlyRate = session.getConsoleUnit() != null ? 
                         session.getConsoleUnit().getBaseHourlyRate() : 15000;
        
        // Hitung berdasarkan menit (proporsional)
        double hours = durationMinutes / 60.0;
        int baseFee = (int) Math.ceil(hours * hourlyRate);
        
        // Minimum charge 30 menit
        if (durationMinutes > 0 && durationMinutes < 30) {
            baseFee = (int) (hourlyRate / 2);
        }
        
        // Apply weekend multiplier (+50%)
        int totalFee = (int) (baseFee * WEEKEND_MULTIPLIER);
        
        return totalFee;
    }
    
    @Override
    public String getLabel() {
        return "Weekend (+50%)";
    }
}
