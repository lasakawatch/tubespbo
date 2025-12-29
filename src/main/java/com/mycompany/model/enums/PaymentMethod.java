package com.mycompany.model.enums;

/**
 * Enum untuk metode pembayaran
 */
public enum PaymentMethod {
    CASH("Tunai"),
    EWALLET("E-Wallet"),
    TRANSFER("Transfer Bank");
    
    private final String displayName;
    
    PaymentMethod(String displayName) {
        this.displayName = displayName;
    }
    
    public String getDisplayName() {
        return displayName;
    }
}
