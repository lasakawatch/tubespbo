package com.mycompany.model.enums;

/**
 * Enum untuk status Room
 */
public enum RoomStatus {
    AVAILABLE("Tersedia"),
    OCCUPIED("Terisi"),
    IN_USE("Sedang Digunakan"),
    RESERVED("Dipesan"),
    MAINTENANCE("Maintenance");
    
    private final String displayName;
    
    RoomStatus(String displayName) {
        this.displayName = displayName;
    }
    
    public String getDisplayName() {
        return displayName;
    }
}
