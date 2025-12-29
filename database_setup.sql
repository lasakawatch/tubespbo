-- =====================================================
-- PSRent Max - Database Schema
-- Sistem Manajemen Rental PlayStation
-- 
-- Kelompok 6 - Tugas Besar PBO
-- Anggota:
--   1. Muhammad Rafadi Kurniawan (103062300089)
--   2. Aditya Attabby Hidayat (103062300078)
--   3. Naufal Saifullah Yusuf (10302300091)
--
-- Database: tubespbo
-- Port Default: 3306 (phpMyAdmin standard)
-- =====================================================

-- Buat database jika belum ada
CREATE DATABASE IF NOT EXISTS tubespbo CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE tubespbo;

-- Drop tables if exist (untuk fresh install)
-- Urutan penting karena foreign key constraints
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS reservations;
DROP TABLE IF EXISTS rental_sessions;
DROP TABLE IF EXISTS members;
DROP TABLE IF EXISTS rooms;
DROP TABLE IF EXISTS consoles;
DROP TABLE IF EXISTS operators;
DROP TABLE IF EXISTS admins;

-- =====================================================
-- TABEL ADMINS (extends Person)
-- Inheritance: Person -> Admin
-- =====================================================
CREATE TABLE admins (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20),
    address TEXT,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(64) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Insert default admin (password: admin123)
-- SHA-256 hash of 'admin123'
INSERT INTO admins (name, phone_number, address, username, password_hash) VALUES
('Administrator', '08123456789', 'Bandung', 'admin', '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9');

-- =====================================================
-- TABEL OPERATORS (extends Person)
-- Inheritance: Person -> Operator
-- =====================================================
CREATE TABLE operators (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20),
    address TEXT,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(64) NOT NULL,
    email VARCHAR(100),
    shift VARCHAR(20) DEFAULT 'Pagi',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Insert default operator (password: op123)
-- SHA-256 hash of 'op123'
INSERT INTO operators (name, phone_number, address, username, password_hash, email, shift) VALUES
('Operator Default', '08987654321', 'Bandung', 'operator', 'e99b3552940ce7af00402747c59913b4a3b1a3867f4bb24cd1c536ddf4ce2ab6', 'operator@psrentmax.com', 'Pagi'),
('Rafadi Operator', '08111222333', 'Jakarta', 'rafadi_op', 'e99b3552940ce7af00402747c59913b4a3b1a3867f4bb24cd1c536ddf4ce2ab6', 'rafadi.op@psrentmax.com', 'Siang'),
('Aditya Operator', '08222333444', 'Surabaya', 'aditya_op', 'e99b3552940ce7af00402747c59913b4a3b1a3867f4bb24cd1c536ddf4ce2ab6', 'aditya.op@psrentmax.com', 'Malam');

-- =====================================================
-- TABEL MEMBERS (extends Person)
-- Inheritance: Person -> Member
-- Level: SILVER (5%), GOLD (10%), PLATINUM (15%), VVIP (20%)
-- =====================================================
CREATE TABLE members (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20),
    email VARCHAR(100),
    member_id VARCHAR(20) UNIQUE NOT NULL,
    level ENUM('SILVER', 'GOLD', 'PLATINUM', 'VVIP') DEFAULT 'SILVER',
    points INT DEFAULT 0,
    total_rentals INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Insert sample members dengan level sesuai aplikasi
INSERT INTO members (name, phone_number, email, member_id, level, points, total_rentals) VALUES
('Muhammad Rafadi Kurniawan', '081234567890', 'rafadi@email.com', 'MEM001', 'GOLD', 1500, 25),
('Aditya Attabby Hidayat', '081234567891', 'aditya@email.com', 'MEM002', 'SILVER', 150, 10),
('Naufal Saifullah Yusuf', '081234567892', 'naufal@email.com', 'MEM003', 'PLATINUM', 3500, 50),
('Player One', '081111111111', 'player1@email.com', 'MEM004', 'SILVER', 50, 5),
('Gamer Pro', '082222222222', 'gamerpro@email.com', 'MEM005', 'GOLD', 1200, 35),
('VIP Player', '083333333333', 'vipplayer@email.com', 'MEM006', 'VVIP', 6000, 100);

-- =====================================================
-- TABEL CONSOLES
-- Model: ConsoleUnit
-- Type: PS4 (Rp15.000/jam), PS5 (Rp25.000/jam)
-- =====================================================
CREATE TABLE consoles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    type ENUM('PS4', 'PS5') NOT NULL,
    serial_number VARCHAR(50) UNIQUE NOT NULL,
    status ENUM('AVAILABLE', 'IN_USE', 'MAINTENANCE') DEFAULT 'AVAILABLE',
    base_hourly_rate INT NOT NULL,
    controllers_available INT DEFAULT 2,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Insert sample consoles
INSERT INTO consoles (type, serial_number, status, base_hourly_rate, controllers_available) VALUES
('PS5', 'PS5-001-2024', 'AVAILABLE', 25000, 2),
('PS5', 'PS5-002-2024', 'AVAILABLE', 25000, 2),
('PS5', 'PS5-003-2024', 'AVAILABLE', 25000, 4),
('PS4', 'PS4-001-2023', 'AVAILABLE', 15000, 2),
('PS4', 'PS4-002-2023', 'AVAILABLE', 15000, 2),
('PS4', 'PS4-003-2023', 'MAINTENANCE', 15000, 2),
('PS5', 'PS5-004-2024', 'AVAILABLE', 25000, 2),
('PS4', 'PS4-004-2023', 'AVAILABLE', 15000, 4);

-- =====================================================
-- TABEL ROOMS
-- Model: Room
-- Status: AVAILABLE, OCCUPIED, IN_USE, RESERVED, MAINTENANCE
-- =====================================================
CREATE TABLE rooms (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    capacity INT DEFAULT 4,
    hourly_rate INT DEFAULT 10000,
    status ENUM('AVAILABLE', 'OCCUPIED', 'IN_USE', 'RESERVED', 'MAINTENANCE') DEFAULT 'AVAILABLE',
    console_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (console_id) REFERENCES consoles(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Insert sample rooms
INSERT INTO rooms (name, capacity, hourly_rate, status, console_id) VALUES
('Room VIP 1', 6, 20000, 'AVAILABLE', 1),
('Room VIP 2', 6, 20000, 'AVAILABLE', 2),
('Room Standard 1', 4, 15000, 'AVAILABLE', 3),
('Room Standard 2', 4, 15000, 'AVAILABLE', 4),
('Room Standard 3', 4, 15000, 'AVAILABLE', 5),
('Room Economy 1', 2, 10000, 'AVAILABLE', 7),
('Room Economy 2', 2, 10000, 'AVAILABLE', 8),
('Room Economy 3', 2, 8000, 'AVAILABLE', NULL);

-- =====================================================
-- TABEL RENTAL_SESSIONS
-- Model: RentalSession
-- Association: Room, ConsoleUnit, Member
-- Status: ACTIVE, PAUSED, COMPLETED, CANCELLED
-- =====================================================
CREATE TABLE rental_sessions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    room_id INT,
    console_id INT NOT NULL,
    member_id INT,
    customer_name VARCHAR(100),
    start_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    planned_end_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actual_end_time TIMESTAMP NULL DEFAULT NULL,
    paused_minutes INT DEFAULT 0,
    status ENUM('ACTIVE', 'PAUSED', 'COMPLETED', 'CANCELLED') DEFAULT 'ACTIVE',
    total_fee INT DEFAULT 0,
    tarif_type VARCHAR(20) DEFAULT 'STANDARD',
    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (room_id) REFERENCES rooms(id) ON DELETE SET NULL,
    FOREIGN KEY (console_id) REFERENCES consoles(id),
    FOREIGN KEY (member_id) REFERENCES members(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Insert sample completed sessions for reporting
INSERT INTO rental_sessions (room_id, console_id, member_id, customer_name, start_time, planned_end_time, actual_end_time, status, total_fee, tarif_type) VALUES
(1, 1, 1, 'Muhammad Rafadi Kurniawan', DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY) + INTERVAL 2 HOUR, DATE_SUB(NOW(), INTERVAL 2 DAY) + INTERVAL 2 HOUR, 'COMPLETED', 40000, 'MEMBER'),
(2, 2, 2, 'Aditya Attabby Hidayat', DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY) + INTERVAL 3 HOUR, DATE_SUB(NOW(), INTERVAL 1 DAY) + INTERVAL 3 HOUR, 'COMPLETED', 71250, 'STANDARD'),
(3, 3, NULL, 'Guest Player', DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY) + INTERVAL 1 HOUR, DATE_SUB(NOW(), INTERVAL 1 DAY) + INTERVAL 1 HOUR, 'COMPLETED', 25000, 'STANDARD'),
(4, 4, 3, 'Naufal Saifullah Yusuf', NOW() - INTERVAL 5 HOUR, NOW() - INTERVAL 3 HOUR, NOW() - INTERVAL 3 HOUR, 'COMPLETED', 25500, 'MEMBER'),
(5, 5, 4, 'Player One', DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 3 DAY) + INTERVAL 2 HOUR, DATE_SUB(NOW(), INTERVAL 3 DAY) + INTERVAL 2 HOUR, 'COMPLETED', 37500, 'WEEKEND'),
(1, 1, 5, 'Gamer Pro', DATE_SUB(NOW(), INTERVAL 7 DAY), DATE_SUB(NOW(), INTERVAL 7 DAY) + INTERVAL 4 HOUR, DATE_SUB(NOW(), INTERVAL 7 DAY) + INTERVAL 4 HOUR, 'COMPLETED', 90000, 'MEMBER');

-- =====================================================
-- TABEL PAYMENTS
-- Model: Payment
-- Association: RentalSession
-- Method: CASH, EWALLET, TRANSFER
-- =====================================================
CREATE TABLE payments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    session_id INT NOT NULL,
    amount INT NOT NULL,
    method ENUM('CASH', 'EWALLET', 'TRANSFER') NOT NULL,
    paid_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes VARCHAR(255),
    FOREIGN KEY (session_id) REFERENCES rental_sessions(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Insert sample payments
INSERT INTO payments (session_id, amount, method, notes) VALUES
(1, 40000, 'CASH', 'Member discount applied'),
(2, 71250, 'EWALLET', 'Standard weekday rate'),
(3, 25000, 'TRANSFER', 'Guest player'),
(4, 25500, 'CASH', 'Member Platinum discount'),
(5, 37500, 'EWALLET', 'Weekend rate'),
(6, 90000, 'TRANSFER', 'Member Gold discount');

-- =====================================================
-- TABEL RESERVATIONS
-- Model: Reservation
-- Association: Room
-- Status: ACTIVE, PENDING, COMPLETED, CANCELLED, CONFIRMED
-- =====================================================
CREATE TABLE reservations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    customer_phone VARCHAR(20) NOT NULL,
    room_id INT NOT NULL,
    console_type ENUM('PS4', 'PS5') DEFAULT 'PS4',
    start_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    end_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deposit INT DEFAULT 0,
    status ENUM('ACTIVE', 'PENDING', 'COMPLETED', 'CANCELLED', 'CONFIRMED') DEFAULT 'PENDING',
    notes VARCHAR(255),
    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (room_id) REFERENCES rooms(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Insert sample reservations
INSERT INTO reservations (customer_name, customer_phone, room_id, console_type, start_time, end_time, deposit, status, notes) VALUES
('Budi Santoso', '081234567893', 1, 'PS5', NOW() + INTERVAL 1 DAY, NOW() + INTERVAL 1 DAY + INTERVAL 3 HOUR, 50000, 'PENDING', 'Birthday party reservation'),
('Ani Wijaya', '081234567894', 2, 'PS5', NOW() + INTERVAL 2 DAY, NOW() + INTERVAL 2 DAY + INTERVAL 2 HOUR, 30000, 'ACTIVE', 'Regular customer'),
('Doni Gamer', '081234567895', 3, 'PS4', NOW() + INTERVAL 3 DAY, NOW() + INTERVAL 3 DAY + INTERVAL 4 HOUR, 40000, 'PENDING', 'Group gaming session');

-- =====================================================
-- INDEXES untuk performa query
-- =====================================================
CREATE INDEX idx_sessions_status ON rental_sessions(status);
CREATE INDEX idx_sessions_date ON rental_sessions(start_time);
CREATE INDEX idx_sessions_console ON rental_sessions(console_id);
CREATE INDEX idx_sessions_room ON rental_sessions(room_id);
CREATE INDEX idx_reservations_room ON reservations(room_id, status);
CREATE INDEX idx_reservations_date ON reservations(start_time, end_time);
CREATE INDEX idx_payments_session ON payments(session_id);
CREATE INDEX idx_members_level ON members(level);
CREATE INDEX idx_consoles_status ON consoles(status);
CREATE INDEX idx_rooms_status ON rooms(status);

-- =====================================================
-- VIEWS untuk kemudahan query laporan
-- =====================================================

-- View untuk laporan harian
CREATE OR REPLACE VIEW v_daily_report AS
SELECT 
    DATE(rs.actual_end_time) AS report_date,
    COUNT(*) AS total_sessions,
    SUM(rs.total_fee) AS total_revenue,
    AVG(rs.total_fee) AS avg_revenue,
    COUNT(DISTINCT rs.member_id) AS unique_members
FROM rental_sessions rs
WHERE rs.status = 'COMPLETED'
GROUP BY DATE(rs.actual_end_time);

-- View untuk laporan bulanan
CREATE OR REPLACE VIEW v_monthly_report AS
SELECT 
    YEAR(rs.actual_end_time) AS report_year,
    MONTH(rs.actual_end_time) AS report_month,
    COUNT(*) AS total_sessions,
    SUM(rs.total_fee) AS total_revenue,
    AVG(rs.total_fee) AS avg_revenue,
    COUNT(DISTINCT rs.member_id) AS unique_members
FROM rental_sessions rs
WHERE rs.status = 'COMPLETED'
GROUP BY YEAR(rs.actual_end_time), MONTH(rs.actual_end_time);

-- View untuk sesi aktif
CREATE OR REPLACE VIEW v_active_sessions AS
SELECT 
    rs.id,
    rs.customer_name,
    r.name AS room_name,
    c.type AS console_type,
    c.serial_number,
    rs.start_time,
    rs.planned_end_time,
    rs.status,
    rs.paused_minutes,
    m.name AS member_name,
    m.level AS member_level
FROM rental_sessions rs
LEFT JOIN rooms r ON rs.room_id = r.id
LEFT JOIN consoles c ON rs.console_id = c.id
LEFT JOIN members m ON rs.member_id = m.id
WHERE rs.status IN ('ACTIVE', 'PAUSED');

-- =====================================================
-- STORED PROCEDURES (Opsional - untuk fitur lanjutan)
-- =====================================================

DELIMITER //

-- Procedure untuk menghitung total pendapatan harian
CREATE PROCEDURE sp_get_daily_revenue(IN p_date DATE)
BEGIN
    SELECT 
        p_date AS report_date,
        COUNT(*) AS total_sessions,
        COALESCE(SUM(total_fee), 0) AS total_revenue
    FROM rental_sessions
    WHERE DATE(actual_end_time) = p_date
    AND status = 'COMPLETED';
END //

-- Procedure untuk menghitung total pendapatan bulanan
CREATE PROCEDURE sp_get_monthly_revenue(IN p_year INT, IN p_month INT)
BEGIN
    SELECT 
        p_year AS report_year,
        p_month AS report_month,
        COUNT(*) AS total_sessions,
        COALESCE(SUM(total_fee), 0) AS total_revenue
    FROM rental_sessions
    WHERE YEAR(actual_end_time) = p_year
    AND MONTH(actual_end_time) = p_month
    AND status = 'COMPLETED';
END //

-- Procedure untuk cek overlap reservasi
CREATE PROCEDURE sp_check_reservation_overlap(
    IN p_room_id INT, 
    IN p_start_time TIMESTAMP, 
    IN p_end_time TIMESTAMP,
    OUT p_has_overlap BOOLEAN
)
BEGIN
    DECLARE overlap_count INT;
    
    SELECT COUNT(*) INTO overlap_count
    FROM reservations
    WHERE room_id = p_room_id
    AND status IN ('ACTIVE', 'PENDING', 'CONFIRMED')
    AND ((start_time < p_end_time AND end_time > p_start_time));
    
    SET p_has_overlap = (overlap_count > 0);
END //

DELIMITER ;

-- =====================================================
-- KETERANGAN AKUN DEFAULT
-- =====================================================
-- 
-- ADMIN:
--   Username: admin
--   Password: admin123
--
-- OPERATOR:
--   Username: operator
--   Password: op123
--
-- MEMBER LEVELS & DISCOUNTS:
--   SILVER   : 5% discount  (Points < 1000)
--   GOLD     : 10% discount (Points >= 1000)
--   PLATINUM : 15% discount (Points >= 2000)
--   VVIP     : 20% discount (Points >= 5000)
--
-- CONSOLE RATES:
--   PS4: Rp 15.000/jam
--   PS5: Rp 25.000/jam
--
-- TARIF STRATEGIES:
--   Standard (Weekday): Base rate
--   Weekend: Base rate + 50%
--   Member: Base rate - (discount sesuai level)
--
-- =====================================================
