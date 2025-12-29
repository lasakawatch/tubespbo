package com.mycompany.model.strategy;

import com.mycompany.model.RentalSession;
import com.mycompany.model.Member;

/**
 * MemberTarif - Implementasi Strategy Pattern
 * Tarif untuk member dengan diskon berdasarkan level (Silver: -10%, Gold: -20%)
 */
public class MemberTarif implements RentalTarifStrategy {
    
    private static final double DEFAULT_DISCOUNT = 0.20; // 20% discount default
    
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
        
        // Get discount percentage from member level
        double discountPercent = DEFAULT_DISCOUNT;
        Member member = session.getMember();
        if (member != null) {
            discountPercent = member.getDiscountPercent() / 100.0;
        }
        
        // Apply member discount
        int totalFee = (int) (baseFee * (1 - discountPercent));
        
        return totalFee;
    }
    
    @Override
    public String getLabel() {
        return "Member (-20%)";
    }
}
