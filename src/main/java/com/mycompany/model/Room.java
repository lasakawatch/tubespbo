package com.mycompany.model;

import com.mycompany.model.enums.RoomStatus;

/**
 * Class Room - Merepresentasikan ruangan rental
 */
public class Room {
    private int id;
    private String name;
    private int capacity;
    private RoomStatus status;
    private ConsoleUnit assignedConsole;
    private double hourlyRate = 20000.0;
    
    /**
     * Default constructor
     */
    public Room() {
        this.status = RoomStatus.AVAILABLE;
    }
    
    public Room(String name, int capacity) {
        this.name = name;
        this.capacity = capacity;
        this.status = RoomStatus.AVAILABLE;
    }
    
    public Room(int id, String name, int capacity, RoomStatus status) {
        this.id = id;
        this.name = name;
        this.capacity = capacity;
        this.status = status;
    }
    
    // Getters and Setters
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public String getName() {
        return name;
    }
    
    public void setName(String name) {
        this.name = name;
    }
    
    public int getCapacity() {
        return capacity;
    }
    
    public void setCapacity(int capacity) {
        this.capacity = capacity;
    }
    
    /**
     * Get rate per hour based on assigned console or default
     */
    public double getRatePerHour() {
        if (assignedConsole != null) {
            return assignedConsole.getRatePerHour();
        }
        return hourlyRate;
    }
    
    /**
     * Set rate per hour
     */
    public void setRatePerHour(double rate) {
        this.hourlyRate = rate;
    }
    
    public RoomStatus getStatus() {
        return status;
    }
    
    public void setStatus(RoomStatus status) {
        this.status = status;
    }
    
    public ConsoleUnit getAssignedConsole() {
        return assignedConsole;
    }
    
    public void assignConsole(ConsoleUnit console) {
        this.assignedConsole = console;
    }
    
    public boolean isAvailable() {
        return status == RoomStatus.AVAILABLE;
    }
    
    @Override
    public String toString() {
        return name + " (Kapasitas: " + capacity + ")";
    }
}
