package com.mycompany.db;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * DatabaseConnection - Singleton Pattern untuk koneksi database
 * Implementasi design pattern Singleton untuk memastikan hanya ada 
 * satu instance koneksi database di seluruh aplikasi
 * 
 * @author Kelompok 6
 */
public class DatabaseConnection {
    
    // =====================================================
    // KONFIGURASI DATABASE - SESUAIKAN DENGAN XAMPP ANDA
    // =====================================================
    // Port default phpMyAdmin/XAMPP: 3306
    // Jika XAMPP Anda menggunakan port lain (misal 3307), ubah di sini
    private static final String URL = "jdbc:mysql://localhost:3307/tubespbo"; 
    private static final String USER = "root";
    private static final String PASSWORD = "";
    
    // Singleton instance
    private static DatabaseConnection instance;
    
    // Load Driver saat kelas dimuat pertama kali
    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            System.out.println("[DB] MySQL Driver loaded successfully.");
        } catch (ClassNotFoundException e) {
            System.err.println("[DB ERROR] MySQL Driver not found!");
            e.printStackTrace();
        }
    }
    
    // Private constructor untuk Singleton Pattern
    private DatabaseConnection() {}
    
    /**
     * Mendapatkan instance Singleton dari DatabaseConnection
     * Thread-safe dengan synchronized
     */
    public static synchronized DatabaseConnection getInstance() {
        if (instance == null) {
            instance = new DatabaseConnection();
        }
        return instance;
    }
    
    /**
     * Membuat koneksi baru ke database
     * Setiap pemanggilan menghasilkan koneksi baru untuk menghindari
     * error "Connection Closed" saat DAO dipanggil beruntun
     * 
     * @return Connection object atau null jika gagal
     */
    public static Connection connect() {
        try {
            Connection conn = DriverManager.getConnection(URL, USER, PASSWORD);
            return conn;
        } catch (SQLException e) {
            System.err.println("[DB ERROR] Gagal membuat koneksi database!");
            System.err.println("[DB ERROR] URL: " + URL);
            System.err.println("[DB ERROR] Pesan: " + e.getMessage());
            System.err.println("[DB ERROR] Pastikan:");
            System.err.println("  1. XAMPP MySQL sudah running");
            System.err.println("  2. Database 'tubespbo' sudah dibuat");
            System.err.println("  3. Port sesuai (default 3306)");
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Metode getConnection (untuk kompatibilitas)
     * Memanggil connect() secara internal
     */
    public Connection getConnection() {
        return connect();
    }
    
    /**
     * Test koneksi database
     * @return true jika koneksi berhasil
     */
    public static boolean testConnection() {
        try (Connection conn = connect()) {
            if (conn != null && !conn.isClosed()) {
                System.out.println("[DB] Koneksi database berhasil!");
                return true;
            }
        } catch (SQLException e) {
            System.err.println("[DB ERROR] Test koneksi gagal: " + e.getMessage());
        }
        return false;
    }
    
    /**
     * Mendapatkan URL database
     */
    public static String getDatabaseUrl() {
        return URL;
    }
}