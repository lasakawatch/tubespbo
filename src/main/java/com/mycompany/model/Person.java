package com.mycompany.model;

/**
 * Abstract Class Person - Implementasi Abstraction & Inheritance
 * Kelas induk untuk Admin, Operator, dan Member
 */
public abstract class Person {
    // Encapsulation - private attributes
    private String name;
    private String phoneNumber;
    private String address;
    
    // Constructor
    public Person(String name, String phoneNumber, String address) {
        this.name = name;
        this.phoneNumber = phoneNumber;
        this.address = address;
    }
    
    // Getter dan Setter - Encapsulation
    public String getName() {
        return name;
    }
    
    public void setName(String name) {
        this.name = name;
    }
    
    public String getPhoneNumber() {
        return phoneNumber;
    }
    
    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }
    
    public String getAddress() {
        return address;
    }
    
    public void setAddress(String address) {
        this.address = address;
    }
    
    // Abstract method - untuk polymorphism
    public abstract String getRole();
    
    @Override
    public String toString() {
        return "Person{" +
                "name='" + name + '\'' +
                ", phoneNumber='" + phoneNumber + '\'' +
                ", address='" + address + '\'' +
                '}';
    }
}
