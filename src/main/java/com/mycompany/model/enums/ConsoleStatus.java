package com.mycompany.model.enums;

/**
 * Enum untuk status Console
 */
public enum ConsoleStatus {
    AVAILABLE("Tersedia"),
    IN_USE("Sedang Digunakan"),
    MAINTENANCE("Maintenance");
    
    private final String displayName;
    
    ConsoleStatus(String displayName) {
        this.displayName = displayName;
    }
    
    public String getDisplayName() {
        return displayName;
    }
}
