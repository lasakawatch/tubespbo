package com.mycompany.model.enums;

public enum MemberLevel {
    // Definisi Level dan Persentase Diskonnya
    REGULAR(0, "Regular"),   // 0%
    SILVER(5, "Silver"),     // 5%
    GOLD(10, "Gold"),        // 10%
    PLATINUM(15, "Platinum"), // 15%
    VVIP(20, "VVIP");        // 20%

    private final int discountPercent;
    private final String displayName;

    MemberLevel(int discountPercent, String displayName) {
        this.discountPercent = discountPercent;
        this.displayName = displayName;
    }

    public int getDiscountPercent() {
        return discountPercent;
    }

    public String getDisplayName() {
        return displayName;
    }
}