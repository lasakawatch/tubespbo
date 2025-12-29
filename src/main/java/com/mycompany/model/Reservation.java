package com.mycompany.model;

import java.sql.Timestamp;

/**
 * Class Reservation - Merepresentasikan reservasi ruangan
 * Association dengan Room
 */
public class Reservation {
    private int id;
    private String customerName;
    private String customerPhone;
    private Room room;
    private Timestamp startTime;
    private Timestamp endTime;
    private int deposit;
    private String status;
    private com.mycompany.model.enums.ConsoleType consoleTypeRef;
    private int durationHours = 1;
    
    /**
     * Default constructor
     */
    public Reservation() {
        this.status = "ACTIVE";
    }
    
    public Reservation(String customerName, String customerPhone, Room room, 
                       Timestamp startTime, Timestamp endTime, int deposit) {
        this.customerName = customerName;
        this.customerPhone = customerPhone;
        this.room = room;
        this.startTime = startTime;
        this.endTime = endTime;
        this.deposit = deposit;
        this.status = "ACTIVE";
    }
    
    public Reservation(int id, String customerName, String customerPhone, Room room,
                       Timestamp startTime, Timestamp endTime, int deposit, String status) {
        this.id = id;
        this.customerName = customerName;
        this.customerPhone = customerPhone;
        this.room = room;
        this.startTime = startTime;
        this.endTime = endTime;
        this.deposit = deposit;
        this.status = status;
    }
    
    // Check if this reservation overlaps with another time range
    public boolean overlaps(Timestamp otherStart, Timestamp otherEnd) {
        // Two time ranges overlap if one starts before the other ends
        // and the first one ends after the second one starts
        return startTime.before(otherEnd) && endTime.after(otherStart);
    }
    
    // Cancel reservation
    public void cancel() {
        this.status = "CANCELLED";
    }
    
    // Getters and Setters
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public String getCustomerName() {
        return customerName;
    }
    
    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }
    
    public String getCustomerPhone() {
        return customerPhone;
    }
    
    public void setCustomerPhone(String customerPhone) {
        this.customerPhone = customerPhone;
    }
    
    public Room getRoom() {
        return room;
    }
    
    public void setRoom(Room room) {
        this.room = room;
    }
    
    public Timestamp getStartTime() {
        return startTime;
    }
    
    public void setStartTime(Timestamp startTime) {
        this.startTime = startTime;
    }
    
    public Timestamp getEndTime() {
        return endTime;
    }
    
    public void setEndTime(Timestamp endTime) {
        this.endTime = endTime;
    }
    
    public int getDeposit() {
        return deposit;
    }
    
    public void setDeposit(int deposit) {
        this.deposit = deposit;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    /**
     * Alias for getCustomerPhone
     */
    public String getPhone() {
        return customerPhone;
    }
    
    /**
     * Set phone (alias for setCustomerPhone)
     */
    public void setPhone(String phone) {
        this.customerPhone = phone;
    }
    
    /**
     * Get console type from assigned room's console (if available)
     */
    public com.mycompany.model.enums.ConsoleType getConsoleType() {
        if (consoleTypeRef != null) return consoleTypeRef;
        if (room != null && room.getAssignedConsole() != null) {
            return room.getAssignedConsole().getType();
        }
        return com.mycompany.model.enums.ConsoleType.PS4; // Default
    }
    
    /**
     * Set console type
     */
    public void setConsoleType(com.mycompany.model.enums.ConsoleType consoleType) {
        this.consoleTypeRef = consoleType;
    }
    
    /**
     * Alias for getStartTime
     */
    public Timestamp getReservationTime() {
        return startTime;
    }
    
    /**
     * Set reservation time (sets start time and calculates end time)
     */
    public void setReservationTime(java.util.Date reservationTime) {
        this.startTime = new Timestamp(reservationTime.getTime());
        // Calculate end time based on duration
        this.endTime = new Timestamp(startTime.getTime() + (durationHours * 60 * 60 * 1000));
    }
    
    /**
     * Calculate duration in hours
     */
    public int getDuration() {
        if (startTime != null && endTime != null) {
            long durationMs = endTime.getTime() - startTime.getTime();
            return (int) (durationMs / (1000 * 60 * 60));
        }
        return durationHours;
    }
    
    /**
     * Set duration in hours
     */
    public void setDuration(int duration) {
        this.durationHours = duration;
        if (startTime != null) {
            this.endTime = new Timestamp(startTime.getTime() + (duration * 60 * 60 * 1000));
        }
    }
}
