package com.mycompany.model.enums;

/**
 * Enum untuk status Rental Session
 */
public enum SessionStatus {
    ACTIVE("Aktif"),
    PAUSED("Dijeda"),
    COMPLETED("Selesai"),
    CANCELLED("Dibatalkan");
    
    private final String displayName;
    
    SessionStatus(String displayName) {
        this.displayName = displayName;
    }
    
    public String getDisplayName() {
        return displayName;
    }
}
