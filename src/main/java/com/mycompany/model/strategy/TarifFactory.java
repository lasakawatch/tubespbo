package com.mycompany.model.strategy;

import java.util.Calendar;

/**
 * TarifFactory - Factory Pattern
 * Memilih strategi tarif yang tepat berdasarkan konteks
 */
public class TarifFactory {
    
    /**
     * Mendapatkan strategi tarif berdasarkan tipe yang dipilih
     * @param tarifType Tipe tarif: "STANDARD", "WEEKEND", "MEMBER"
     * @return Instance dari RentalTarifStrategy yang sesuai
     */
    public static RentalTarifStrategy getTarif(String tarifType) {
        switch (tarifType.toUpperCase()) {
            case "WEEKEND":
                return new WeekendTarif();
            case "MEMBER":
                return new MemberTarif();
            case "STANDARD":
            default:
                return new StandardTarif();
        }
    }
    
    /**
     * Mendapatkan strategi tarif otomatis berdasarkan hari dan status member
     * @param isMember Apakah pelanggan adalah member
     * @return Instance dari RentalTarifStrategy yang sesuai
     */
    public static RentalTarifStrategy getAutoTarif(boolean isMember) {
        if (isMember) {
            return new MemberTarif();
        }
        
        // Check if weekend (Saturday or Sunday)
        Calendar calendar = Calendar.getInstance();
        int dayOfWeek = calendar.get(Calendar.DAY_OF_WEEK);
        
        if (dayOfWeek == Calendar.SATURDAY || dayOfWeek == Calendar.SUNDAY) {
            return new WeekendTarif();
        }
        
        return new StandardTarif();
    }
    
    /**
     * Cek apakah hari ini weekend
     * @return true jika hari ini Saturday atau Sunday
     */
    public static boolean isWeekend() {
        Calendar calendar = Calendar.getInstance();
        int dayOfWeek = calendar.get(Calendar.DAY_OF_WEEK);
        return dayOfWeek == Calendar.SATURDAY || dayOfWeek == Calendar.SUNDAY;
    }
}
