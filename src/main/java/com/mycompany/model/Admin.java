package com.mycompany.model;

import com.mycompany.model.enums.Role;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * Class Admin - extends Person (Inheritance)
 * Mengelola inventori, operator, dan laporan
 */
public class Admin extends Person {
    private int id;
    private String username;
    private String passwordHash;
    private final Role role = Role.ADMIN;
    
    public Admin(String name, String phoneNumber, String address, String username, String password) {
        super(name, phoneNumber, address);
        this.username = username;
        this.passwordHash = hashPassword(password);
    }
    
    public Admin(int id, String name, String phoneNumber, String address, String username, String passwordHash) {
        super(name, phoneNumber, address);
        this.id = id;
        this.username = username;
        this.passwordHash = passwordHash;
    }
    
    // Hash password menggunakan SHA-256
    private String hashPassword(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(password.getBytes());
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (NoSuchAlgorithmException e) {
            return password; // Fallback ke plain text jika hashing gagal
        }
    }
    
    public boolean validatePassword(String password) {
        return this.passwordHash.equals(hashPassword(password));
    }
    
    // Getters and Setters
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public String getUsername() {
        return username;
    }
    
    public void setUsername(String username) {
        this.username = username;
    }
    
    public String getPasswordHash() {
        return passwordHash;
    }
    
    public void setPasswordHash(String password) {
        this.passwordHash = hashPassword(password);
    }
    
    @Override
    public String getRole() {
        return role.getDisplayName();
    }
    
    public Role getRoleEnum() {
        return role;
    }
}
