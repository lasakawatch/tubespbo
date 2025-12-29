package com.mycompany.model.strategy;

import com.mycompany.model.RentalSession;

/**
 * Interface RentalTarifStrategy - Strategy Pattern
 * Interface untuk implementasi berbagai strategi perhitungan tarif
 */
public interface RentalTarifStrategy {
    
    /**
     * Menghitung biaya sesi rental berdasarkan strategi yang dipilih
     * @param session Sesi rental yang akan dihitung biayanya
     * @return Total biaya dalam Rupiah
     */
    int calculateFee(RentalSession session);
    
    /**
     * Mendapatkan label/nama strategi tarif
     * @return Nama strategi tarif
     */
    String getLabel();
}
