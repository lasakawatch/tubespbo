# PSRent Max - Sistem Manajemen Rental PlayStation

![Java](https://img.shields.io/badge/Java-17-orange)
![Maven](https://img.shields.io/badge/Maven-3.x-blue)
![MySQL](https://img.shields.io/badge/MySQL-8.0-blue)
![Tomcat](https://img.shields.io/badge/Tomcat-9.x-yellow)

Aplikasi web-based untuk manajemen rental PlayStation dengan fitur lengkap: manajemen inventori, sesi rental, reservasi, pembayaran, dan pelaporan.

---

## 👥 Kelompok 6 - Tugas Besar PBO

| Nama | NIM | Peran |
|------|-----|-------|
| Muhammad Rafadi Kurniawan | 103062300089 | Modul Administrasi & Pelaporan |
| Aditya Attabby Hidayat | 103062300078 | Modul Arsitektur & Transaksi |
| Naufal Saifullah Yusuf | 10302300091 | Modul Operasional & Alur Kerja |

---

## 🎯 Fitur Utama

### Admin
- ✅ Login & Autentikasi
- ✅ Manajemen Operator (CRUD)
- ✅ Manajemen Console PS4/PS5 (CRUD)
- ✅ Manajemen Room (CRUD)
- ✅ Laporan Harian & Bulanan
- ✅ Statistik Pendapatan

### Operator
- ✅ Login & Autentikasi
- ✅ Start/Pause/Resume/End Session
- ✅ Manajemen Member (CRUD)
- ✅ Sistem Reservasi dengan deteksi overlap
- ✅ Pembayaran (Cash, E-Wallet, Transfer)
- ✅ Generate Struk Pembayaran
- ✅ View Sesi Aktif

---

## 🏗️ Arsitektur & Design Pattern

### Konsep OOP
- **Abstraction**: `Person`, `Laporan` (abstract class)
- **Encapsulation**: Private attributes dengan getter/setter
- **Inheritance**: `Admin`, `Operator`, `Member` extends `Person`
- **Polymorphism**: Strategy Pattern untuk perhitungan tarif
- **Interface**: `RentalTarifStrategy`

### Design Patterns
- **Singleton**: `DatabaseConnection`
- **Strategy**: `StandardTarif`, `WeekendTarif`, `MemberTarif`
- **Factory**: `TarifFactory`

---

## 💰 Sistem Tarif

### Console Rates
| Console | Rate/Hour |
|---------|-----------|
| PS4 | Rp 15.000 |
| PS5 | Rp 25.000 |

### Tarif Strategy
- **Standard (Weekday)**: Base rate
- **Weekend**: Base rate × 1.5 (+50%)
- **Member**: Base rate dengan diskon sesuai level

### Member Levels
| Level | Points Required | Discount |
|-------|----------------|----------|
| SILVER | < 1,000 | 5% |
| GOLD | ≥ 1,000 | 10% |
| PLATINUM | ≥ 2,000 | 15% |
| VVIP | ≥ 5,000 | 20% |

---

## 🚀 Quick Start

### Prerequisites
- JDK 8+
- MySQL (XAMPP)
- Apache Tomcat 9.x
- Maven (atau gunakan IDE)

### 1. Setup Database
```bash
# Buka phpMyAdmin: http://localhost/phpmyadmin
# Import file: database_setup.sql
```

### 2. Konfigurasi
Edit `DatabaseConnection.java` jika perlu:
```java
private static final String URL = "jdbc:mysql://localhost:3306/tubespbo";
```

### 3. Build & Run
```bash
mvn clean package
# Deploy WAR ke Tomcat webapps/
```

Atau gunakan IDE (NetBeans/IntelliJ) - Lihat [CARA_MENJALANKAN.md](CARA_MENJALANKAN.md)

### 4. Akses Aplikasi
```
http://localhost:8080/webtest-1.0-SNAPSHOT/
```

**Default Login:**
- Admin: `admin` / `admin123`
- Operator: `operator` / `op123`

---

## 📂 Struktur Project

```
porjecttubes_rev1/
├── src/main/java/com/mycompany/
│   ├── dao/          # Data Access Objects
│   ├── db/           # Database Connection
│   └── model/        # Model Classes
│       ├── enums/    # Enumerations
│       ├── report/   # Laporan Classes
│       └── strategy/ # Tarif Strategy Classes
│
├── src/main/webapp/
│   ├── admin/        # Admin JSP Pages
│   ├── operator/     # Operator JSP Pages
│   └── css/          # Stylesheets
│
├── database_setup.sql        # Database Schema
├── pom.xml                   # Maven Config
├── LAPORAN_AKHIR_PSRENT_MAX.md
└── CARA_MENJALANKAN.md
```

---

## 📊 Database Schema

**8 Tables:**
- `admins` - Administrator accounts
- `operators` - Operator accounts
- `members` - Member/customer data
- `consoles` - PS4/PS5 inventory
- `rooms` - Room inventory
- `rental_sessions` - Active/completed sessions
- `payments` - Payment transactions
- `reservations` - Room reservations

**3 Views:**
- `v_daily_report` - Daily revenue summary
- `v_monthly_report` - Monthly revenue summary
- `v_active_sessions` - Currently active sessions

---

## 🧪 Testing

| Feature | Status |
|---------|--------|
| Login Admin/Operator | ✅ Pass |
| Registrasi Operator | ✅ Pass |
| CRUD Console | ✅ Pass |
| CRUD Room | ✅ Pass |
| Start/Pause/Resume Session | ✅ Pass |
| End Session & Calculate Fee | ✅ Pass |
| Reservasi + Overlap Detection | ✅ Pass |
| Payment Processing | ✅ Pass |
| Generate Reports | ✅ Pass |
| Tarif Strategy (Standard/Weekend/Member) | ✅ Pass |

---

## 📚 Dokumentasi

- [LAPORAN_AKHIR_PSRENT_MAX.md](LAPORAN_AKHIR_PSRENT_MAX.md) - Laporan lengkap dengan class diagram
- [CARA_MENJALANKAN.md](CARA_MENJALANKAN.md) - Panduan instalasi & troubleshooting
- [database_setup.sql](database_setup.sql) - Database schema dengan komentar lengkap

---

## 🐛 Troubleshooting

### Database connection error
- Pastikan MySQL XAMPP running
- Cek port di `DatabaseConnection.java` (3306 atau 3307)
- Verify database `tubespbo` sudah dibuat

### Build error
```bash
mvn clean install -U
```

### Port conflict
- Ubah Tomcat port di `server.xml`
- Atau stop aplikasi lain yang menggunakan port 8080

Lihat [CARA_MENJALANKAN.md](CARA_MENJALANKAN.md) untuk troubleshooting lengkap.

---

## 📝 License

Tugas Besar - Mata Kuliah Pemrograman Berbasis Objek (PBO)

---

## 🙏 Acknowledgments

- Dosen Pengampu: [Nama Dosen]
- Asisten Dosen: [Nama Asisten]
- Universitas/Institut: [Nama Universitas]

---

**Built with ❤️ by Kelompok 6**

*December 2025*
