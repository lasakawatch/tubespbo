package com.mycompany.model.enums;

/**
 * Enum untuk tipe Console PlayStation
 */
public enum ConsoleType {
    PS4("PlayStation 4", 15000),
    PS5("PlayStation 5", 25000);
    
    private final String displayName;
    private final int baseHourlyRate;
    
    ConsoleType(String displayName, int baseHourlyRate) {
        this.displayName = displayName;
        this.baseHourlyRate = baseHourlyRate;
    }
    
    public String getDisplayName() {
        return displayName;
    }
    
    public int getBaseHourlyRate() {
        return baseHourlyRate;
    }
}
