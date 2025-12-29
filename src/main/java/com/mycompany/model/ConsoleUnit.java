package com.mycompany.model;

import com.mycompany.model.enums.ConsoleType;
import com.mycompany.model.enums.ConsoleStatus;

/**
 * Class ConsoleUnit - Merepresentasikan unit console PlayStation
 */
public class ConsoleUnit {
    private int id;
    private ConsoleType type;
    private String serialNumber;
    private ConsoleStatus status;
    private int baseHourlyRate;
    private int controllersAvailable;
    
    /**
     * Default constructor
     */
    public ConsoleUnit() {
        this.status = ConsoleStatus.AVAILABLE;
        this.controllersAvailable = 2;
    }
    
    public ConsoleUnit(ConsoleType type, String serialNumber) {
        this.type = type;
        this.serialNumber = serialNumber;
        this.status = ConsoleStatus.AVAILABLE;
        this.baseHourlyRate = type.getBaseHourlyRate();
        this.controllersAvailable = 2;
    }
    
    public ConsoleUnit(int id, ConsoleType type, String serialNumber, ConsoleStatus status, int baseHourlyRate, int controllersAvailable) {
        this.id = id;
        this.type = type;
        this.serialNumber = serialNumber;
        this.status = status;
        this.baseHourlyRate = baseHourlyRate;
        this.controllersAvailable = controllersAvailable;
    }
    
    // Getters and Setters
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public ConsoleType getType() {
        return type;
    }
    
    public void setType(ConsoleType type) {
        this.type = type;
    }
    
    public String getSerialNumber() {
        return serialNumber;
    }
    
    public void setSerialNumber(String serialNumber) {
        this.serialNumber = serialNumber;
    }
    
    public ConsoleStatus getStatus() {
        return status;
    }
    
    public void setStatus(ConsoleStatus status) {
        this.status = status;
    }
    
    public int getBaseHourlyRate() {
        return baseHourlyRate;
    }
    
    /**
     * Alias for getBaseHourlyRate() - returns rate per hour as double
     */
    public double getRatePerHour() {
        return (double) baseHourlyRate;
    }
    
    public void setBaseHourlyRate(int baseHourlyRate) {
        this.baseHourlyRate = baseHourlyRate;
    }
    
    /**
     * Set rate per hour (converts double to int)
     */
    public void setRatePerHour(double rate) {
        this.baseHourlyRate = (int) rate;
    }
    
    public int getControllersAvailable() {
        return controllersAvailable;
    }
    
    public void setControllersAvailable(int controllersAvailable) {
        this.controllersAvailable = controllersAvailable;
    }
    
    public boolean isAvailable() {
        return status == ConsoleStatus.AVAILABLE;
    }
    
    @Override
    public String toString() {
        return type.getDisplayName() + " (" + serialNumber + ")";
    }
}
