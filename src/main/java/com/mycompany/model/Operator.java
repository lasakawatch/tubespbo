package com.mycompany.model;

import com.mycompany.model.enums.Role;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * Class Operator - extends Person (Inheritance)
 * Mengelola sesi rental, pembayaran, dan reservasi
 */
public class Operator extends Person {
    private int id;
    private String username;
    private String passwordHash;
    private String email;
    private String shift;
    private final Role role = Role.OPERATOR;
    
    public Operator() {
        super("", "", "");
    }
    
    public Operator(String name, String phoneNumber, String address, String username, String password) {
        super(name, phoneNumber, address);
        this.username = username;
        this.passwordHash = hashPassword(password);
    }
    
    public Operator(int id, String name, String phoneNumber, String address, String username, String passwordHash) {
        super(name, phoneNumber, address);
        this.id = id;
        this.username = username;
        this.passwordHash = passwordHash;
    }
    
    // Hash password menggunakan SHA-256
    public static String hashPassword(String password) {
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
            return password;
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
    
    public String getPassword() {
        return passwordHash;
    }
    
    public void setPassword(String password) {
        this.passwordHash = password;
    }
    
    public String getEmail() {
        return email;
    }
    
    public void setEmail(String email) {
        this.email = email;
    }
    
    public String getShift() {
        return shift;
    }
    
    public void setShift(String shift) {
        this.shift = shift;
    }
    
    public String getPhone() {
        return getPhoneNumber();
    }
    
    public void setPhone(String phone) {
        setPhoneNumber(phone);
    }
    
    @Override
    public String getRole() {
        return role.getDisplayName();
    }
    
    public Role getRoleEnum() {
        return role;
    }
}
