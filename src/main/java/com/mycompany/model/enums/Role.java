package com.mycompany.model.enums;

/**
 * Enum untuk Role pengguna sistem
 */
public enum Role {
    ADMIN("Admin"),
    OPERATOR("Operator");
    
    private final String displayName;
    
    Role(String displayName) {
        this.displayName = displayName;
    }
    
    public String getDisplayName() {
        return displayName;
    }
}
