package com.mycompany.model;

import com.mycompany.model.enums.MemberLevel;

/**
 * Class Member - extends Person (Inheritance)
 * Pelanggan yang terdaftar sebagai member
 */
public class Member extends Person {
    private int id;
    private String memberId;
    private String email;
    private MemberLevel level;
    private int points;
    private int totalRentals;
    
    // Constructor Default
    public Member() {
        super("", "", "");
        // PERBAIKAN: Default level jadi SILVER
        this.level = MemberLevel.SILVER; 
        this.points = 0;
        this.totalRentals = 0;
    }
    
    // Constructor Parameter
    public Member(String name, String phone, String email, String memberId, MemberLevel level) {
        super(name, phone, "");
        this.email = email;
        this.memberId = memberId;
        this.level = level;
        this.points = 0;
        this.totalRentals = 0;
    }
    
    // Add points to member & Check Upgrade
    public void addPoints(int pts) {
        if (pts > 0) {
            this.points += pts;
            // Auto upgrade level based on points
            checkLevelUpgrade();
        }
    }
    
    // PERBAIKAN: Logika Kenaikan Level (Silver -> Gold -> Platinum -> VVIP)
    private void checkLevelUpgrade() {
        if (this.points >= 5000) {
            this.level = MemberLevel.VVIP;
        } else if (this.points >= 2000) {
            this.level = MemberLevel.PLATINUM;
        } else if (this.points >= 1000) {
            this.level = MemberLevel.GOLD;
        } else {
            this.level = MemberLevel.SILVER;
        }
    }
    
    // Increment total rentals
    public void incrementTotalRentals() {
        this.totalRentals++;
    }
    
    // Getters and Setters
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public String getMemberId() {
        return memberId;
    }
    
    public void setMemberId(String memberId) {
        this.memberId = memberId;
    }
    
    public String getEmail() {
        return email;
    }
    
    public void setEmail(String email) {
        this.email = email;
    }
    
    public String getPhone() {
        return getPhoneNumber();
    }
    
    public void setPhone(String phone) {
        setPhoneNumber(phone);
    }
    
    public MemberLevel getLevel() {
        return level;
    }
    
    public void setLevel(MemberLevel level) {
        this.level = level;
    }
    
    public int getPoints() {
        return points;
    }
    
    public void setPoints(int points) {
        this.points = points;
        // Cek level juga saat setPoints manual
        checkLevelUpgrade();
    }
    
    public int getTotalRentals() {
        return totalRentals;
    }
    
    public void setTotalRentals(int totalRentals) {
        this.totalRentals = totalRentals;
    }
    
    @Override
    public String getRole() {
        return "Member - " + (level != null ? level.getDisplayName() : "Silver");
    }
    
    public int getDiscountPercent() {
        return level != null ? level.getDiscountPercent() : 0;
    }
}