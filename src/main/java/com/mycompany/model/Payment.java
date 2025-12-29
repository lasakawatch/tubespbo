package com.mycompany.model;

import com.mycompany.model.enums.PaymentMethod;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * Class Payment - Merepresentasikan pembayaran
 * Association dengan RentalSession
 */
public class Payment {
    private int id;
    private int sessionId;
    private RentalSession session;
    private double amount;
    private PaymentMethod method;
    private Date paymentTime;
    
    public Payment() {
        this.paymentTime = new Date();
    }
    
    public Payment(RentalSession session, int amount, PaymentMethod method) {
        this.session = session;
        this.sessionId = session.getId();
        this.amount = amount;
        this.method = method;
        this.paymentTime = new Date();
    }
    
    public Payment(int id, RentalSession session, int amount, PaymentMethod method, Timestamp paidAt) {
        this.id = id;
        this.session = session;
        this.sessionId = session != null ? session.getId() : 0;
        this.amount = amount;
        this.method = method;
        this.paymentTime = paidAt;
    }
    
    // Process payment
    public boolean process() {
        // In real implementation, this would process actual payment
        return true;
    }
    
    // Generate receipt/struk
    public String getReceipt() {
        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
        StringBuilder receipt = new StringBuilder();
        
        receipt.append("╔══════════════════════════════════════════╗\n");
        receipt.append("║         🎮 PSRent Max - STRUK 🎮         ║\n");
        receipt.append("╠══════════════════════════════════════════╣\n");
        receipt.append(String.format("║ ID Payment   : %-25s ║\n", "PAY-" + String.format("%05d", id)));
        receipt.append(String.format("║ ID Session   : %-25s ║\n", "SES-" + String.format("%05d", sessionId)));
        receipt.append("╠══════════════════════════════════════════╣\n");
        receipt.append(String.format("║ TOTAL BAYAR  : Rp %-21s ║\n", String.format("%,.0f", amount)));
        receipt.append(String.format("║ Metode       : %-25s ║\n", method != null ? method.getDisplayName() : "Cash"));
        receipt.append(String.format("║ Tanggal      : %-25s ║\n", sdf.format(paymentTime)));
        receipt.append("╠══════════════════════════════════════════╣\n");
        receipt.append("║      Terima kasih telah bermain!         ║\n");
        receipt.append("║         Sampai jumpa kembali!            ║\n");
        receipt.append("╚══════════════════════════════════════════╝\n");
        
        return receipt.toString();
    }
    
    // Getters and Setters
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public int getSessionId() {
        return sessionId;
    }
    
    public void setSessionId(int sessionId) {
        this.sessionId = sessionId;
    }
    
    public RentalSession getSession() {
        return session;
    }
    
    public void setSession(RentalSession session) {
        this.session = session;
    }
    
    public double getAmount() {
        return amount;
    }
    
    public void setAmount(double amount) {
        this.amount = amount;
    }
    
    public PaymentMethod getPaymentMethod() {
        return method;
    }
    
    public void setPaymentMethod(PaymentMethod method) {
        this.method = method;
    }
    
    public Date getPaymentTime() {
        return paymentTime;
    }
    
    public void setPaymentTime(Date paymentTime) {
        this.paymentTime = paymentTime;
    }
}
