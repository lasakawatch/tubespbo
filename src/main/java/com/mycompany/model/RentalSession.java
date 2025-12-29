package com.mycompany.model;

import com.mycompany.model.enums.SessionStatus;
import com.mycompany.model.strategy.RentalTarifStrategy;
import java.sql.Timestamp;
import java.util.Date;

/**
 * Class RentalSession - Merepresentasikan sesi rental
 * Association dengan Room, ConsoleUnit, dan Member
 */
public class RentalSession {
    private int id;
    private Member member;
    private Room room;
    private ConsoleUnit consoleUnit;
    private Timestamp startTime;
    private Timestamp plannedEndTime;
    private Timestamp actualEndTime;
    private int pausedMinutes;
    private SessionStatus status;
    private RentalTarifStrategy strategy;
    private int totalFee;
    private String customerName;
    private Integer consoleIdRef;
    private Integer roomIdRef;
    private Integer memberIdRef;
    private String tarifType; // STANDARD, WEEKEND, MEMBER
    
    /**
     * Default constructor
     */
    public RentalSession() {
        this.status = SessionStatus.ACTIVE;
        this.pausedMinutes = 0;
        this.totalFee = 0;
        this.tarifType = "STANDARD";
    }
    
    public RentalSession(Room room, ConsoleUnit consoleUnit, int durationMinutes) {
        this.room = room;
        this.consoleUnit = consoleUnit;
        this.startTime = new Timestamp(System.currentTimeMillis());
        this.plannedEndTime = new Timestamp(startTime.getTime() + (durationMinutes * 60 * 1000));
        this.status = SessionStatus.ACTIVE;
        this.pausedMinutes = 0;
        this.totalFee = 0;
    }
    
    public RentalSession(int id, Room room, ConsoleUnit consoleUnit, Member member, 
                         Timestamp startTime, Timestamp plannedEndTime, Timestamp actualEndTime,
                         int pausedMinutes, SessionStatus status, int totalFee) {
        this.id = id;
        this.room = room;
        this.consoleUnit = consoleUnit;
        this.member = member;
        this.startTime = startTime;
        this.plannedEndTime = plannedEndTime;
        this.actualEndTime = actualEndTime;
        this.pausedMinutes = pausedMinutes;
        this.status = status;
        this.totalFee = totalFee;
    }
    
    // Session Control Methods
    public void start() {
        this.status = SessionStatus.ACTIVE;
        this.startTime = new Timestamp(System.currentTimeMillis());
    }
    
    public void pause(int minutes) {
        if (this.status == SessionStatus.ACTIVE) {
            this.status = SessionStatus.PAUSED;
            this.pausedMinutes += minutes;
        }
    }
    
    public void resume() {
        if (this.status == SessionStatus.PAUSED) {
            this.status = SessionStatus.ACTIVE;
        }
    }
    
    public void extendMinutes(int minutes) {
        if (this.status == SessionStatus.ACTIVE || this.status == SessionStatus.PAUSED) {
            this.plannedEndTime = new Timestamp(plannedEndTime.getTime() + (minutes * 60 * 1000));
        }
    }
    
    public void end() {
        this.status = SessionStatus.COMPLETED;
        this.actualEndTime = new Timestamp(System.currentTimeMillis());
    }
    
    // Calculate fee using Strategy Pattern
    public int calculateFee() {
        if (strategy != null) {
            this.totalFee = strategy.calculateFee(this);
        } else {
            // Default calculation without strategy
            long durationMs = (actualEndTime != null ? actualEndTime.getTime() : System.currentTimeMillis()) - startTime.getTime();
            int durationMinutes = (int) (durationMs / (60 * 1000)) - pausedMinutes;
            int hourlyRate = consoleUnit != null ? consoleUnit.getBaseHourlyRate() : 15000;
            this.totalFee = (int) ((durationMinutes / 60.0) * hourlyRate);
        }
        return this.totalFee;
    }
    
    // Get actual duration in minutes
    public int getActualDurationMinutes() {
        long endTime = actualEndTime != null ? actualEndTime.getTime() : System.currentTimeMillis();
        long durationMs = endTime - startTime.getTime();
        return (int) (durationMs / (60 * 1000)) - pausedMinutes;
    }
    
    // Getters and Setters
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    /**
     * Get console ID (convenience method)
     */
    public Integer getConsoleId() {
        if (consoleUnit != null) return consoleUnit.getId();
        return consoleIdRef;
    }
    
    /**
     * Set console ID reference
     */
    public void setConsoleId(int consoleId) {
        this.consoleIdRef = consoleId;
    }
    
    /**
     * Get room ID (convenience method)
     */
    public Integer getRoomId() {
        if (room != null) return room.getId();
        return roomIdRef;
    }
    
    /**
     * Set room ID reference
     */
    public void setRoomId(Integer roomId) {
        this.roomIdRef = roomId;
    }
    
    /**
     * Get member ID (convenience method)
     */
    public Integer getMemberId() {
        if (member != null) return member.getId();
        return memberIdRef;
    }
    
    /**
     * Set member ID reference
     */
    public void setMemberId(Integer memberId) {
        this.memberIdRef = memberId;
    }
    
    /**
     * Get customer name - returns member name or stored customer name or "Guest"
     */
    public String getCustomerName() {
        if (member != null) return member.getName();
        if (customerName != null) return customerName;
        return "Guest";
    }
    
    /**
     * Set customer name
     */
    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }
    
    public Member getMember() {
        return member;
    }
    
    public void setMember(Member member) {
        this.member = member;
    }
    
    public Room getRoom() {
        return room;
    }
    
    public void setRoom(Room room) {
        this.room = room;
    }
    
    public ConsoleUnit getConsoleUnit() {
        return consoleUnit;
    }
    
    public void setConsoleUnit(ConsoleUnit consoleUnit) {
        this.consoleUnit = consoleUnit;
    }
    
    public Timestamp getStartTime() {
        return startTime;
    }
    
    public void setStartTime(Timestamp startTime) {
        this.startTime = startTime;
    }
    
    /**
     * Set start time from Date (overloaded for JSP compatibility)
     */
    public void setStartTime(Date date) {
        if (date != null) {
            this.startTime = new Timestamp(date.getTime());
        }
    }
    
    public Timestamp getPlannedEndTime() {
        return plannedEndTime;
    }
    
    public void setPlannedEndTime(Timestamp plannedEndTime) {
        this.plannedEndTime = plannedEndTime;
    }
    
    public Timestamp getActualEndTime() {
        return actualEndTime;
    }
    
    public void setActualEndTime(Timestamp actualEndTime) {
        this.actualEndTime = actualEndTime;
    }
    
    public int getPausedMinutes() {
        return pausedMinutes;
    }
    
    public void setPausedMinutes(int pausedMinutes) {
        this.pausedMinutes = pausedMinutes;
    }
    
    public SessionStatus getStatus() {
        return status;
    }
    
    public void setStatus(SessionStatus status) {
        this.status = status;
    }
    
    public RentalTarifStrategy getStrategy() {
        return strategy;
    }
    
    public void setStrategy(RentalTarifStrategy strategy) {
        this.strategy = strategy;
    }
    
    public int getTotalFee() {
        return totalFee;
    }
    
    public void setTotalFee(int totalFee) {
        this.totalFee = totalFee;
    }
    
    public String getTarifType() {
        return tarifType;
    }
    
    public void setTarifType(String tarifType) {
        this.tarifType = tarifType;
    }
}
