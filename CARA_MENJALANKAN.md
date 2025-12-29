# 🚀 CARA MENJALANKAN APLIKASI PSRENT MAX

## ✅ Checklist Persiapan

- [x] Java 17 sudah terinstall
- [ ] MySQL XAMPP running
- [ ] Database `tubespbo` sudah dibuat
- [ ] Maven terinstall (atau gunakan IDE)
- [ ] Tomcat terinstall (atau gunakan IDE)

---

## 📋 LANGKAH 1: Setup MySQL Database

### Opsi A: Manual via phpMyAdmin

1. **Buka XAMPP Control Panel**
   - Start MySQL

2. **Buka phpMyAdmin**
   - Browser: `http://localhost/phpmyadmin`

3. **Import Database**
   - Klik tab "SQL"
   - Copy-paste isi file `database_setup.sql`
   - Klik "Go"
   - Database `tubespbo` akan otomatis terbuat beserta semua tabelnya

### Opsi B: Via Command Line (jika MySQL di PATH)

```bash
# Masuk ke direktori XAMPP MySQL bin
cd C:\xampp\mysql\bin

# Login ke MySQL
mysql -u root -p
# (tekan Enter saja karena password kosong)

# Di MySQL prompt:
source C:/Users/NAUFAL/Downloads/pbo/porjecttubes_rev1/database_setup.sql
exit;
```

---

## 📋 LANGKAH 2: Verifikasi Koneksi Database

File: `src/main/java/com/mycompany/db/DatabaseConnection.java`

Pastikan konfigurasi sesuai:
```java
private static final String URL = "jdbc:mysql://localhost:3306/tubespbo"; 
private static final String USER = "root";
private static final String PASSWORD = "";
```

**Jika port MySQL Anda 3307**, ubah menjadi:
```java
private static final String URL = "jdbc:mysql://localhost:3307/tubespbo"; 
```

---

## 📋 LANGKAH 3: Build & Deploy Aplikasi

### Opsi A: Menggunakan NetBeans (RECOMMENDED)

1. **Buka Project di NetBeans**
   - File → Open Project
   - Pilih folder `porjecttubes_rev1`

2. **Clean & Build**
   - Klik kanan project → Clean and Build
   - Tunggu sampai BUILD SUCCESSFUL

3. **Run Project**
   - Klik kanan project → Run
   - NetBeans akan otomatis deploy ke Tomcat
   - Browser akan terbuka ke: `http://localhost:8080/webtest-1.0-SNAPSHOT/`

### Opsi B: Menggunakan IntelliJ IDEA

1. **Buka Project**
   - File → Open
   - Pilih folder `porjecttubes_rev1`

2. **Add Maven Configuration**
   - Run → Edit Configurations
   - Tambahkan Maven goal: `clean package`

3. **Deploy ke Tomcat**
   - Run → Edit Configurations
   - Add New Configuration → Tomcat Server → Local
   - Deployment tab → Add Artifact → `webtest:war exploded`
   - Application context: `/webtest-1.0-SNAPSHOT`
   - Run

### Opsi C: Manual dengan Maven (jika sudah install)

```bash
# Build WAR file
mvn clean package

# File WAR akan ada di:
# target/webtest-1.0-SNAPSHOT.war

# Copy ke Tomcat webapps:
copy target\webtest-1.0-SNAPSHOT.war C:\apache-tomcat\webapps\

# Start Tomcat
cd C:\apache-tomcat\bin
startup.bat

# Akses aplikasi:
# http://localhost:8080/webtest-1.0-SNAPSHOT/
```

---

## 📋 LANGKAH 4: Akses Aplikasi

### URL Aplikasi
```
http://localhost:8080/webtest-1.0-SNAPSHOT/
```

### Login Credentials

| Role | Username | Password |
|------|----------|----------|
| **Admin** | admin | admin123 |
| **Operator** | operator | op123 |

---

## 🔧 TROUBLESHOOTING

### Problem 1: Port MySQL sudah digunakan
**Solusi:**
- Buka XAMPP Config MySQL
- Ubah port ke 3307
- Edit `DatabaseConnection.java` sesuaikan port

### Problem 2: BUILD FAILED - dependency error
**Solusi:**
```bash
# Update Maven dependencies
mvn clean install -U
```

### Problem 3: Connection refused
**Solusi:**
- Pastikan MySQL XAMPP sudah running
- Cek port di XAMPP (3306 atau 3307)
- Test koneksi di phpMyAdmin

### Problem 4: Tomcat port 8080 sudah digunakan
**Solusi:**
- Ubah port Tomcat di `server.xml`
- Atau stop aplikasi lain yang pakai port 8080

### Problem 5: WAR tidak otomatis deploy
**Solusi:**
```bash
# Manual deploy:
1. Stop Tomcat
2. Delete folder webapps/webtest-1.0-SNAPSHOT
3. Copy WAR baru ke webapps
4. Start Tomcat
```

---

## 📊 STRUKTUR URL APLIKASI

| URL | Keterangan |
|-----|------------|
| `/` atau `/index.jsp` | Halaman Login |
| `/admin/dashboard.jsp` | Dashboard Admin |
| `/operator/dashboard.jsp` | Dashboard Operator |
| `/register.jsp` | Registrasi Operator (Admin only) |

---

## ✅ VERIFIKASI INSTALASI

Setelah aplikasi running, coba:

1. ✅ Login sebagai Admin (`admin` / `admin123`)
2. ✅ Lihat Inventori Console (harus ada 8 console)
3. ✅ Lihat Inventori Room (harus ada 8 room)
4. ✅ Logout
5. ✅ Login sebagai Operator (`operator` / `op123`)
6. ✅ Lihat Dashboard Operator
7. ✅ Coba Start Session baru
8. ✅ Coba buat Reservasi

---

## 📦 FILE PENTING

| File | Keterangan |
|------|------------|
| `database_setup.sql` | Script database lengkap |
| `pom.xml` | Maven dependencies |
| `DatabaseConnection.java` | Konfigurasi koneksi DB |
| `LAPORAN_AKHIR_PSRENT_MAX.md` | Dokumentasi lengkap |

---

## 🆘 BUTUH BANTUAN?

Jika masih error, check:
1. **Console Log** di NetBeans/IDE (lihat error message)
2. **Tomcat Log** di `tomcat/logs/catalina.out`
3. **MySQL Error Log** di XAMPP
4. **Browser Console** (F12) untuk error JavaScript

---

## 📸 SCREENSHOT YANG HARUS DIAMBIL UNTUK LAPORAN

1. Halaman Login
2. Dashboard Admin - Tab Inventori
3. Dashboard Admin - Tab Operator
4. Dashboard Admin - Tab Laporan
5. Dashboard Operator - Sesi Aktif
6. Dashboard Operator - Start Session
7. Dashboard Operator - Reservasi
8. Struk Pembayaran (console log atau file)
9. Laporan Harian
10. Laporan Bulanan

---

**Good luck! 🎮🎯**

*Kelompok 6 - Tugas Besar PBO*
