# LAPORAN AKHIR TUGAS BESAR
# PEMROGRAMAN BERBASIS OBJEK (PBO)

---

## PSRent Max – Sistem Manajemen Rental PlayStation

**Mata Kuliah:** Pemrograman Berbasis Objek (PBO)  
**Tanggal:** 29 Desember 2025  
**Kelompok:** 6

---

## ANGGOTA KELOMPOK

| No | Nama | NIM | Peran |
|----|------|-----|-------|
| 1 | Muhammad Rafadi Kurniawan | 103062300089 | Modul Administrasi & Pelaporan |
| 2 | Aditya Attabby Hidayat | 103062300078 | Modul Arsitektur & Transaksi |
| 3 | Naufal Saifullah Yusuf | 10302300091 | Modul Operasional & Alur Kerja Sesi |

---

# BAB I - PENDAHULUAN

## A. Latar Belakang

Di era digital saat ini, teknologi informasi telah menjadi bagian integral dari kehidupan sehari-hari manusia. Pemanfaatan teknologi tidak hanya terbatas pada komunikasi, tetapi juga merambah ke berbagai sektor bisnis, termasuk industri hiburan dan rekreasi.

Salah satu bentuk bisnis hiburan yang populer adalah rental PlayStation (PS). Usaha rental PlayStation memerlukan sistem yang terorganisir untuk mengelola berbagai aspek operasional seperti penjadwalan ruangan, pengelolaan perangkat konsol (PS4/PS5), perhitungan tarif rental yang dinamis, reservasi pelanggan, serta pencatatan transaksi pembayaran.

Selama ini, banyak usaha rental PlayStation masih mengandalkan sistem manual atau menggunakan aplikasi sederhana seperti Microsoft Excel untuk mencatat data pelanggan dan transaksi. Hal ini menimbulkan beberapa permasalahan seperti:
- Sulitnya melacak ketersediaan ruangan dan console secara realtime
- Risiko terjadinya double booking atau konflik jadwal
- Perhitungan tarif yang tidak konsisten (tarif weekday vs weekend, member vs non-member)
- Kesulitan dalam membuat laporan pendapatan harian maupun bulanan
- Proses pembayaran yang lambat dan rentan kesalahan pencatatan

## B. Tujuan Proyek

Tujuan dari pembuatan sistem informasi PSRent Max adalah:

1. Mengimplementasikan konsep-konsep Pemrograman Berbasis Objek (PBO):
   - **Abstraction**: Abstract class (Person, Laporan)
   - **Encapsulation**: Private attributes dengan getter/setter
   - **Inheritance**: Admin, Operator, Member extends Person
   - **Polymorphism**: Strategy pattern untuk tarif
   - **Interface**: RentalTarifStrategy

2. Mengimplementasikan Design Pattern:
   - **Singleton Pattern**: DatabaseConnection
   - **Strategy Pattern**: RentalTarifStrategy
   - **Factory Pattern**: TarifFactory

3. Membangun sistem manajemen rental PlayStation yang lengkap dengan fitur:
   - Autentikasi pengguna (Admin, Operator)
   - Manajemen inventori (Console PS4/PS5, Room)
   - Manajemen sesi rental (start, pause, resume, end)
   - Perhitungan tarif dinamis (Standard, Weekend, Member)
   - Pembayaran dan cetak struk
   - Reservasi dengan deteksi konflik jadwal
   - Laporan pendapatan harian dan bulanan

---

# BAB II - DAFTAR FITUR APLIKASI

## Fitur Lengkap per Anggota

### 1. Muhammad Rafadi Kurniawan (103062300089)
**Modul Administrasi & Pelaporan**

| Fitur | Deskripsi | File Terkait |
|-------|-----------|--------------|
| Login Admin | Autentikasi admin dengan username/password | `index.jsp`, `UserDAO.java` |
| Registrasi Operator | Admin mendaftarkan operator baru | `register.jsp`, `UserDAO.java` |
| Manajemen Inventori Console | CRUD data console (PS4/PS5) | `ConsoleDAO.java`, `ConsoleUnit.java` |
| Manajemen Inventori Room | CRUD data ruangan | `RoomDAO.java`, `Room.java` |
| Laporan Harian | Generate laporan pendapatan per hari | `LaporanHarian.java` |
| Laporan Bulanan | Generate laporan pendapatan per bulan | `LaporanBulanan.java` |

### 2. Aditya Attabby Hidayat (103062300078)
**Modul Arsitektur & Transaksi**

| Fitur | Deskripsi | File Terkait |
|-------|-----------|--------------|
| Database Connection (Singleton) | Koneksi database dengan Singleton pattern | `DatabaseConnection.java` |
| Autentikasi User | Validasi login Admin dan Operator | `UserDAO.java`, `Admin.java`, `Operator.java` |
| Standard Tarif | Perhitungan tarif weekday | `StandardTarif.java` |
| Weekend Tarif | Perhitungan tarif weekend (+50%) | `WeekendTarif.java` |
| Member Tarif | Perhitungan tarif dengan diskon member | `MemberTarif.java` |
| Tarif Factory | Factory untuk memilih strategi tarif | `TarifFactory.java` |
| Pembayaran | Proses pembayaran (Cash, E-Wallet, Transfer) | `Payment.java`, `PaymentDAO.java` |
| Generate Struk | Cetak struk pembayaran | `Payment.java` |

### 3. Naufal Saifullah Yusuf (10302300091)
**Modul Operasional & Alur Kerja Sesi**

| Fitur | Deskripsi | File Terkait |
|-------|-----------|--------------|
| Start Session | Memulai sesi rental baru | `RentalSession.java`, `SessionDAO.java` |
| Pause Session | Menjeda sesi yang sedang berjalan | `SessionDAO.java` |
| Resume Session | Melanjutkan sesi yang dijeda | `SessionDAO.java` |
| End Session | Mengakhiri sesi dan hitung biaya | `RentalSession.java` |
| Buat Reservasi | Membuat reservasi ruangan | `Reservation.java`, `ReservationDAO.java` |
| Cek Overlap Reservasi | Validasi konflik jadwal reservasi | `ReservationDAO.java` |
| Cancel Reservasi | Membatalkan reservasi | `ReservationDAO.java` |
| Manajemen Member | CRUD data member | `Member.java`, `MemberDAO.java` |

---

# BAB III - CLASS DIAGRAM

## Diagram Struktur Kelas

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                              CLASS DIAGRAM - PSRent Max                              │
│                        Sistem Manajemen Rental PlayStation                           │
└─────────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────────┐
│                                    «abstract»                                        │
│                                      Person                                          │
├─────────────────────────────────────────────────────────────────────────────────────┤
│ - name: String                                                                       │
│ - phoneNumber: String                                                                │
│ - address: String                                                                    │
├─────────────────────────────────────────────────────────────────────────────────────┤
│ + Person(name, phoneNumber, address)                                                │
│ + getName(): String                                                                  │
│ + setName(name: String): void                                                        │
│ + getPhoneNumber(): String                                                           │
│ + setPhoneNumber(phoneNumber: String): void                                          │
│ + getAddress(): String                                                               │
│ + setAddress(address: String): void                                                  │
│ + «abstract» getRole(): String                                                       │
│ + toString(): String                                                                 │
└─────────────────────────────────────────────────────────────────────────────────────┘
                                        △
                                        │ extends (Inheritance)
            ┌───────────────────────────┼───────────────────────────┐
            │                           │                           │
            ▼                           ▼                           ▼
┌─────────────────────────┐ ┌─────────────────────────┐ ┌─────────────────────────┐
│         Admin           │ │        Operator         │ │         Member          │
├─────────────────────────┤ ├─────────────────────────┤ ├─────────────────────────┤
│ - id: int               │ │ - id: int               │ │ - id: int               │
│ - username: String      │ │ - username: String      │ │ - memberId: String      │
│ - passwordHash: String  │ │ - passwordHash: String  │ │ - email: String         │
│ - role: Role            │ │ - email: String         │ │ - level: MemberLevel    │
├─────────────────────────┤ │ - shift: String         │ │ - points: int           │
│ + Admin(...)            │ │ - role: Role            │ │ - totalRentals: int     │
│ + hashPassword(): String│ ├─────────────────────────┤ ├─────────────────────────┤
│ + validatePassword():   │ │ + Operator(...)         │ │ + Member(...)           │
│   boolean               │ │ + hashPassword(): String│ │ + addPoints(pts): void  │
│ + getRole(): String     │ │ + validatePassword():   │ │ + checkLevelUpgrade():  │
│ + getId(): int          │ │   boolean               │ │   void                  │
│ + getUsername(): String │ │ + getRole(): String     │ │ + getDiscountPercent(): │
│ + setId(id): void       │ │ + getId(): int          │ │   int                   │
│ + getRoleEnum(): Role   │ │ + getEmail(): String    │ │ + getRole(): String     │
└─────────────────────────┘ │ + getShift(): String    │ │ + getLevel(): MemberLvl │
                            └─────────────────────────┘ └─────────────────────────┘


┌─────────────────────────────────────────────────────────────────────────────────────┐
│                                  «interface»                                         │
│                              RentalTarifStrategy                                     │
├─────────────────────────────────────────────────────────────────────────────────────┤
│ + calculateFee(session: RentalSession): int                                         │
│ + getLabel(): String                                                                 │
└─────────────────────────────────────────────────────────────────────────────────────┘
                                        △
                                        │ implements
            ┌───────────────────────────┼───────────────────────────┐
            │                           │                           │
            ▼                           ▼                           ▼
┌─────────────────────────┐ ┌─────────────────────────┐ ┌─────────────────────────┐
│     StandardTarif       │ │      WeekendTarif       │ │      MemberTarif        │
├─────────────────────────┤ ├─────────────────────────┤ ├─────────────────────────┤
│                         │ │ - WEEKEND_MULTIPLIER:   │ │ - DEFAULT_DISCOUNT:     │
│                         │ │   double = 1.5          │ │   double = 0.20         │
├─────────────────────────┤ ├─────────────────────────┤ ├─────────────────────────┤
│ + calculateFee(session):│ │ + calculateFee(session):│ │ + calculateFee(session):│
│   int                   │ │   int                   │ │   int                   │
│ + getLabel(): String    │ │ + getLabel(): String    │ │ + getLabel(): String    │
│ // Tarif weekday normal │ │ // Tarif + 50%          │ │ // Tarif - diskon level │
└─────────────────────────┘ └─────────────────────────┘ └─────────────────────────┘


┌─────────────────────────────────────────────────────────────────────────────────────┐
│                                    «abstract»                                        │
│                                      Laporan                                         │
├─────────────────────────────────────────────────────────────────────────────────────┤
│ # tanggalGenerate: Date                                                              │
│ # dataSessions: List<RentalSession>                                                  │
├─────────────────────────────────────────────────────────────────────────────────────┤
│ + Laporan()                                                                          │
│ + «abstract» generateLaporan(): String                                              │
│ + «abstract» hitungTotalPendapatan(): int                                           │
│ + exportPDF(): void                                                                  │
│ + getTanggalGenerate(): Date                                                         │
│ + getDataSessions(): List<RentalSession>                                             │
└─────────────────────────────────────────────────────────────────────────────────────┘
                                        △
                                        │ extends (Inheritance)
                        ┌───────────────┴───────────────┐
                        │                               │
                        ▼                               ▼
        ┌─────────────────────────────┐ ┌─────────────────────────────┐
        │       LaporanHarian         │ │       LaporanBulanan        │
        ├─────────────────────────────┤ ├─────────────────────────────┤
        │ - tanggal: Date             │ │ - bulan: int                │
        │ - payments: List<Payment>   │ │ - tahun: int                │
        ├─────────────────────────────┤ │ - payments: List<Payment>   │
        │ + LaporanHarian()           │ ├─────────────────────────────┤
        │ + LaporanHarian(tanggal)    │ │ + LaporanBulanan()          │
        │ + filterByDate(date): List  │ │ + LaporanBulanan(bulan,thn) │
        │ + generateLaporan(): String │ │ + filterByMonth(month,year) │
        │ + hitungTotalPendapatan():  │ │ + generateLaporan(): String │
        │   int                       │ │ + hitungTotalPendapatan():  │
        │ + generateReport(): String  │ │   int                       │
        └─────────────────────────────┘ └─────────────────────────────┘


┌─────────────────────────────────────────────────────────────────────────────────────┐
│                                  ConsoleUnit                                         │
├─────────────────────────────────────────────────────────────────────────────────────┤
│ - id: int                                                                            │
│ - type: ConsoleType                                                                  │
│ - serialNumber: String                                                               │
│ - status: ConsoleStatus                                                              │
│ - baseHourlyRate: int                                                                │
│ - controllersAvailable: int                                                          │
├─────────────────────────────────────────────────────────────────────────────────────┤
│ + ConsoleUnit()                                                                      │
│ + ConsoleUnit(type, serialNumber)                                                    │
│ + ConsoleUnit(id, type, serialNumber, status, baseHourlyRate, controllers)          │
│ + getId(): int                            + setId(id): void                          │
│ + getType(): ConsoleType                  + setType(type): void                      │
│ + getSerialNumber(): String               + setSerialNumber(sn): void                │
│ + getStatus(): ConsoleStatus              + setStatus(status): void                  │
│ + getBaseHourlyRate(): int                + setBaseHourlyRate(rate): void            │
│ + getRatePerHour(): double                + setRatePerHour(rate): void               │
│ + getControllersAvailable(): int          + setControllersAvailable(n): void         │
│ + isAvailable(): boolean                  + toString(): String                       │
└─────────────────────────────────────────────────────────────────────────────────────┘


┌─────────────────────────────────────────────────────────────────────────────────────┐
│                                      Room                                            │
├─────────────────────────────────────────────────────────────────────────────────────┤
│ - id: int                                                                            │
│ - name: String                                                                       │
│ - capacity: int                                                                      │
│ - status: RoomStatus                                                                 │
│ - assignedConsole: ConsoleUnit                                                       │
│ - hourlyRate: double                                                                 │
├─────────────────────────────────────────────────────────────────────────────────────┤
│ + Room()                                                                             │
│ + Room(name, capacity)                                                               │
│ + Room(id, name, capacity, status)                                                   │
│ + getId(): int                            + setId(id): void                          │
│ + getName(): String                       + setName(name): void                      │
│ + getCapacity(): int                      + setCapacity(cap): void                   │
│ + getStatus(): RoomStatus                 + setStatus(status): void                  │
│ + getRatePerHour(): double                + setRatePerHour(rate): void               │
│ + getAssignedConsole(): ConsoleUnit       + assignConsole(console): void             │
│ + isAvailable(): boolean                  + toString(): String                       │
└─────────────────────────────────────────────────────────────────────────────────────┘


┌─────────────────────────────────────────────────────────────────────────────────────┐
│                                  RentalSession                                       │
├─────────────────────────────────────────────────────────────────────────────────────┤
│ - id: int                                   - pausedMinutes: int                     │
│ - member: Member                            - status: SessionStatus                  │
│ - room: Room                                - strategy: RentalTarifStrategy          │
│ - consoleUnit: ConsoleUnit                  - totalFee: int                          │
│ - startTime: Timestamp                      - customerName: String                   │
│ - plannedEndTime: Timestamp                 - consoleIdRef: Integer                  │
│ - actualEndTime: Timestamp                  - roomIdRef: Integer                     │
│                                             - memberIdRef: Integer                   │
├─────────────────────────────────────────────────────────────────────────────────────┤
│ + RentalSession()                                                                    │
│ + RentalSession(room, consoleUnit, durationMinutes)                                 │
│ + RentalSession(id, room, consoleUnit, member, startTime, plannedEndTime, ...)     │
│ + start(): void                           + pause(minutes): void                     │
│ + resume(): void                          + extendMinutes(minutes): void             │
│ + end(): void                             + calculateFee(): int                      │
│ + getActualDurationMinutes(): int         + getCustomerName(): String                │
│ + getId(): int                            + setId(id): void                          │
│ + getMember(): Member                     + setMember(member): void                  │
│ + getRoom(): Room                         + setRoom(room): void                      │
│ + getConsoleUnit(): ConsoleUnit           + setConsoleUnit(console): void            │
│ + getStartTime(): Timestamp               + setStartTime(time): void                 │
│ + getPlannedEndTime(): Timestamp          + setPlannedEndTime(time): void            │
│ + getActualEndTime(): Timestamp           + setActualEndTime(time): void             │
│ + getStatus(): SessionStatus              + setStatus(status): void                  │
│ + getPausedMinutes(): int                 + setPausedMinutes(mins): void             │
│ + getTotalFee(): int                      + setTotalFee(fee): void                   │
│ + getConsoleId(): Integer                 + getRoomId(): Integer                     │
│ + getMemberId(): Integer                  + setStrategy(strategy): void              │
└─────────────────────────────────────────────────────────────────────────────────────┘


┌─────────────────────────────────────────────────────────────────────────────────────┐
│                                     Payment                                          │
├─────────────────────────────────────────────────────────────────────────────────────┤
│ - id: int                                                                            │
│ - sessionId: int                                                                     │
│ - session: RentalSession                                                             │
│ - amount: double                                                                     │
│ - method: PaymentMethod                                                              │
│ - paymentTime: Date                                                                  │
├─────────────────────────────────────────────────────────────────────────────────────┤
│ + Payment()                                                                          │
│ + Payment(session, amount, method)                                                   │
│ + Payment(id, session, amount, method, paidAt)                                       │
│ + process(): boolean                      + getReceipt(): String                     │
│ + getId(): int                            + setId(id): void                          │
│ + getSessionId(): int                     + setSessionId(id): void                   │
│ + getSession(): RentalSession             + setSession(session): void                │
│ + getAmount(): double                     + setAmount(amount): void                  │
│ + getPaymentMethod(): PaymentMethod       + setPaymentMethod(method): void           │
│ + getPaymentTime(): Date                  + setPaymentTime(time): void               │
└─────────────────────────────────────────────────────────────────────────────────────┘


┌─────────────────────────────────────────────────────────────────────────────────────┐
│                                   Reservation                                        │
├─────────────────────────────────────────────────────────────────────────────────────┤
│ - id: int                                   - deposit: int                           │
│ - customerName: String                      - status: String                         │
│ - customerPhone: String                     - consoleTypeRef: ConsoleType            │
│ - room: Room                                - durationHours: int                     │
│ - startTime: Timestamp                                                               │
│ - endTime: Timestamp                                                                 │
├─────────────────────────────────────────────────────────────────────────────────────┤
│ + Reservation()                                                                      │
│ + Reservation(customerName, customerPhone, room, startTime, endTime, deposit)       │
│ + Reservation(id, customerName, customerPhone, room, startTime, endTime, deposit,  │
│               status)                                                                │
│ + overlaps(otherStart, otherEnd): boolean + cancel(): void                          │
│ + getId(): int                            + setId(id): void                          │
│ + getCustomerName(): String               + setCustomerName(name): void              │
│ + getCustomerPhone(): String              + setCustomerPhone(phone): void            │
│ + getRoom(): Room                         + setRoom(room): void                      │
│ + getStartTime(): Timestamp               + setStartTime(time): void                 │
│ + getEndTime(): Timestamp                 + setEndTime(time): void                   │
│ + getDeposit(): int                       + setDeposit(deposit): void                │
│ + getStatus(): String                     + setStatus(status): void                  │
│ + getPhone(): String                      + setPhone(phone): void                    │
│ + getConsoleType(): ConsoleType           + setConsoleType(type): void               │
│ + getDuration(): int                      + setDuration(hours): void                 │
│ + getReservationTime(): Timestamp         + setReservationTime(time): void           │
└─────────────────────────────────────────────────────────────────────────────────────┘


┌─────────────────────────────────────────────────────────────────────────────────────┐
│                          «Singleton» DatabaseConnection                              │
├─────────────────────────────────────────────────────────────────────────────────────┤
│ - URL: String = "jdbc:mysql://localhost:3306/tubespbo"                              │
│ - USER: String = "root"                                                              │
│ - PASSWORD: String = ""                                                              │
│ - instance: DatabaseConnection                                                       │
├─────────────────────────────────────────────────────────────────────────────────────┤
│ - DatabaseConnection()                                                               │
│ + «static» getInstance(): DatabaseConnection                                        │
│ + «static» connect(): Connection                                                    │
│ + getConnection(): Connection                                                        │
│ + «static» testConnection(): boolean                                                │
│ + «static» getDatabaseUrl(): String                                                 │
└─────────────────────────────────────────────────────────────────────────────────────┘


┌─────────────────────────────────────────────────────────────────────────────────────┐
│                               TarifFactory (Factory Pattern)                         │
├─────────────────────────────────────────────────────────────────────────────────────┤
│ + «static» getTarif(tarifType: String): RentalTarifStrategy                         │
│ + «static» getAutoTarif(isMember: boolean): RentalTarifStrategy                     │
│ + «static» isWeekend(): boolean                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘


═══════════════════════════════════════════════════════════════════════════════════════
                                   ENUM CLASSES
═══════════════════════════════════════════════════════════════════════════════════════

┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
│   ConsoleType    │  │  ConsoleStatus   │  │   MemberLevel    │  │  PaymentMethod   │
├──────────────────┤  ├──────────────────┤  ├──────────────────┤  ├──────────────────┤
│ PS4 (15000/jam)  │  │ AVAILABLE        │  │ SILVER (5%)      │  │ CASH             │
│ PS5 (25000/jam)  │  │ IN_USE           │  │ GOLD (10%)       │  │ EWALLET          │
└──────────────────┘  │ MAINTENANCE      │  │ PLATINUM (15%)   │  │ TRANSFER         │
                      └──────────────────┘  │ VVIP (20%)       │  └──────────────────┘
                                            └──────────────────┘

┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
│      Role        │  │   RoomStatus     │  │  SessionStatus   │
├──────────────────┤  ├──────────────────┤  ├──────────────────┤
│ ADMIN            │  │ AVAILABLE        │  │ ACTIVE           │
│ OPERATOR         │  │ OCCUPIED         │  │ PAUSED           │
└──────────────────┘  │ IN_USE           │  │ COMPLETED        │
                      │ RESERVED         │  │ CANCELLED        │
                      │ MAINTENANCE      │  └──────────────────┘
                      └──────────────────┘

═══════════════════════════════════════════════════════════════════════════════════════
                                   DAO CLASSES
═══════════════════════════════════════════════════════════════════════════════════════

┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
│     UserDAO      │  │   ConsoleDAO     │  │     RoomDAO      │  │    MemberDAO     │
├──────────────────┤  ├──────────────────┤  ├──────────────────┤  ├──────────────────┤
│ + loginAdmin()   │  │ + findAll()      │  │ + findAll()      │  │ + findAll()      │
│ + loginOperator()│  │ + findById()     │  │ + findById()     │  │ + findById()     │
│ + registerOp()   │  │ + findByStatus() │  │ + findByStatus() │  │ + findByMemberId│
│ + getAllOps()    │  │ + addConsole()   │  │ + addRoom()      │  │ + save()         │
│ + usernameExists │  │ + updateStatus() │  │ + updateStatus() │  │ + update()       │
│ + findAllOps()   │  │ + updateConsole()│  │ + update()       │  │ + delete()       │
│ + findOpById()   │  │ + deleteConsole()│  │ + deleteRoom()   │  └──────────────────┘
│ + saveOperator() │  └──────────────────┘  └──────────────────┘
│ + updateOp()     │
│ + deleteOp()     │  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
└──────────────────┘  │   SessionDAO     │  │   PaymentDAO     │  │ ReservationDAO   │
                      ├──────────────────┤  ├──────────────────┤  ├──────────────────┤
                      │ + findAll()      │  │ + createPayment()│  │ + findPending()  │
                      │ + findById()     │  │ + getPaymentById │  │ + getAllReserv() │
                      │ + findActiveSes()│  │ + getBySessionId │  │ + getActiveRes() │
                      │ + save()         │  │ + getAllPayments │  │ + hasOverlap()   │
                      │ + update()       │  │ + findAll()      │  │ + createReserv() │
                      │ + pauseSession() │  │ + findBySession  │  │ + cancelReserv() │
                      │ + resumeSession()│  │ + save()         │  │ + confirmReserv()│
                      └──────────────────┘  └──────────────────┘  └──────────────────┘
```

## Relasi Antar Kelas

| Jenis Relasi | Dari Kelas | Ke Kelas | Deskripsi |
|--------------|------------|----------|-----------|
| **Inheritance** | Admin, Operator, Member | Person | Admin, Operator, dan Member adalah jenis Person |
| **Inheritance** | LaporanHarian, LaporanBulanan | Laporan | Laporan harian & bulanan mewarisi Laporan |
| **Implementation** | StandardTarif, WeekendTarif, MemberTarif | RentalTarifStrategy | Implementasi interface strategy |
| **Association** | RentalSession | Room, ConsoleUnit, Member | Sesi berelasi dengan Room, Console, dan Member |
| **Association** | Payment | RentalSession | Payment terkait dengan satu session |
| **Association** | Reservation | Room | Reservasi terkait dengan satu room |
| **Dependency** | RentalSession | RentalTarifStrategy | Menggunakan strategy untuk hitung biaya |
| **Dependency** | TarifFactory | RentalTarifStrategy | Factory membuat instance strategy |

---

# BAB IV - IMPLEMENTASI KONSEP OOP

## 1. Abstraction

**Abstract Class Person:**
```java
public abstract class Person {
    private String name;
    private String phoneNumber;
    private String address;
    
    public abstract String getRole();
}
```

**Abstract Class Laporan:**
```java
public abstract class Laporan {
    protected Date tanggalGenerate;
    protected List<RentalSession> dataSessions;
    
    public abstract String generateLaporan();
    public abstract int hitungTotalPendapatan();
}
```

## 2. Encapsulation

Semua atribut bersifat `private` dengan akses melalui getter/setter:
```java
public class ConsoleUnit {
    private int id;
    private ConsoleType type;
    private String serialNumber;
    private ConsoleStatus status;
    private int baseHourlyRate;
    private int controllersAvailable;
    
    // Getters
    public int getId() { return id; }
    public ConsoleType getType() { return type; }
    
    // Setters
    public void setId(int id) { this.id = id; }
    public void setType(ConsoleType type) { this.type = type; }
}
```

## 3. Inheritance

**Hierarki Person:**
```
Person (abstract)
├── Admin
├── Operator
└── Member
```

**Hierarki Laporan:**
```
Laporan (abstract)
├── LaporanHarian
└── LaporanBulanan
```

## 4. Polymorphism

**Strategy Pattern untuk Tarif:**
```java
public interface RentalTarifStrategy {
    int calculateFee(RentalSession session);
    String getLabel();
}

public class StandardTarif implements RentalTarifStrategy {
    @Override
    public int calculateFee(RentalSession session) {
        // Implementasi tarif standard
    }
}

public class WeekendTarif implements RentalTarifStrategy {
    @Override
    public int calculateFee(RentalSession session) {
        // Implementasi tarif weekend (+50%)
    }
}

public class MemberTarif implements RentalTarifStrategy {
    @Override
    public int calculateFee(RentalSession session) {
        // Implementasi tarif member (dengan diskon)
    }
}
```

## 5. Design Patterns

### Singleton Pattern (DatabaseConnection)
```java
public class DatabaseConnection {
    private static DatabaseConnection instance;
    
    private DatabaseConnection() {}
    
    public static synchronized DatabaseConnection getInstance() {
        if (instance == null) {
            instance = new DatabaseConnection();
        }
        return instance;
    }
}
```

### Strategy Pattern (RentalTarifStrategy)
- Interface: `RentalTarifStrategy`
- Implementations: `StandardTarif`, `WeekendTarif`, `MemberTarif`

### Factory Pattern (TarifFactory)
```java
public class TarifFactory {
    public static RentalTarifStrategy getTarif(String tarifType) {
        switch (tarifType.toUpperCase()) {
            case "WEEKEND": return new WeekendTarif();
            case "MEMBER": return new MemberTarif();
            default: return new StandardTarif();
        }
    }
    
    public static RentalTarifStrategy getAutoTarif(boolean isMember) {
        if (isMember) return new MemberTarif();
        if (isWeekend()) return new WeekendTarif();
        return new StandardTarif();
    }
}
```

---

# BAB V - STRUKTUR DATABASE

## Entity Relationship Diagram (ERD)

```
┌─────────────┐       ┌─────────────┐       ┌─────────────┐
│   admins    │       │  operators  │       │   members   │
├─────────────┤       ├─────────────┤       ├─────────────┤
│ id (PK)     │       │ id (PK)     │       │ id (PK)     │
│ name        │       │ name        │       │ name        │
│ phone_number│       │ phone_number│       │ phone_number│
│ address     │       │ address     │       │ email       │
│ username    │       │ username    │       │ member_id   │
│ password    │       │ password    │       │ level       │
│ created_at  │       │ email       │       │ points      │
└─────────────┘       │ shift       │       │ total_rental│
                      │ created_at  │       │ created_at  │
                      └─────────────┘       └──────┬──────┘
                                                   │
                                                   │ 0..1
┌─────────────┐       ┌─────────────┐              │
│  consoles   │       │    rooms    │              │
├─────────────┤       ├─────────────┤              │
│ id (PK)     │◄──────┤ id (PK)     │              │
│ type        │  0..1 │ name        │              │
│ serial_num  │       │ capacity    │              │
│ status      │       │ hourly_rate │              │
│ base_rate   │       │ status      │              │
│ controllers │       │ console_id  │──────────────┼──────┐
│ created_at  │       │ created_at  │              │      │
└──────┬──────┘       └──────┬──────┘              │      │
       │                     │                     │      │
       │ 1                   │ 0..1                │      │
       │                     │                     │      │
       │              ┌──────┴──────┐              │      │
       │              │             │              │      │
       │              ▼             ▼              ▼      │
       │     ┌────────────────────────────────────────┐   │
       └────►│          rental_sessions              │   │
             ├────────────────────────────────────────┤   │
             │ id (PK)                                │   │
             │ room_id (FK)                           │   │
             │ console_id (FK)                        │◄──┘
             │ member_id (FK)                         │
             │ customer_name                          │
             │ start_time                             │
             │ planned_end_time                       │
             │ actual_end_time                        │
             │ paused_minutes                         │
             │ status                                 │
             │ total_fee                              │
             │ tarif_type                             │
             │ created_at                             │
             └───────────────┬────────────────────────┘
                             │
                             │ 1
                             ▼
                    ┌─────────────────┐
                    │    payments     │
                    ├─────────────────┤
                    │ id (PK)         │
                    │ session_id (FK) │
                    │ amount          │
                    │ method          │
                    │ paid_at         │
                    │ notes           │
                    └─────────────────┘
                    
             ┌────────────────────────────────────────┐
             │          reservations                  │
             ├────────────────────────────────────────┤
             │ id (PK)                                │
             │ customer_name                          │
             │ customer_phone                         │
             │ room_id (FK) ─────────────────────────►│ rooms
             │ console_type                           │
             │ start_time                             │
             │ end_time                               │
             │ deposit                                │
             │ status                                 │
             │ notes                                  │
             │ created_at                             │
             └────────────────────────────────────────┘
```

## Tabel Database

| Tabel | Deskripsi |
|-------|-----------|
| `admins` | Data administrator sistem |
| `operators` | Data operator/karyawan |
| `members` | Data member/pelanggan tetap |
| `consoles` | Data unit console PS4/PS5 |
| `rooms` | Data ruangan rental |
| `rental_sessions` | Data sesi rental aktif/selesai |
| `payments` | Data pembayaran |
| `reservations` | Data reservasi/booking |

---

# BAB VI - KONFIGURASI APLIKASI

## Prasyarat

1. **JDK 8 atau lebih tinggi**
2. **Apache Tomcat 9.x**
3. **XAMPP dengan MySQL**
4. **IDE: NetBeans/IntelliJ IDEA/Eclipse**

## Setup Database

1. Buka phpMyAdmin (http://localhost/phpmyadmin)
2. Import file `database_setup.sql`
3. Atau jalankan query berikut:
   ```sql
   CREATE DATABASE tubespbo;
   USE tubespbo;
   -- lalu import isi file database_setup.sql
   ```

## Konfigurasi Koneksi

Edit file `DatabaseConnection.java` jika port MySQL berbeda:
```java
private static final String URL = "jdbc:mysql://localhost:3306/tubespbo";
private static final String USER = "root";
private static final String PASSWORD = "";
```

## Menjalankan Aplikasi

1. Build project dengan Maven: `mvn clean package`
2. Deploy WAR file ke Tomcat
3. Akses aplikasi di: `http://localhost:8080/webtest-1.0-SNAPSHOT/`

---

# BAB VII - AKUN DEFAULT

## Kredensial Login

### Admin
| Field | Value |
|-------|-------|
| Username | `admin` |
| Password | `admin123` |
| Role | Administrator |

### Operator
| Field | Value |
|-------|-------|
| Username | `operator` |
| Password | `op123` |
| Role | Operator |

### Operator Tambahan
| Username | Password |
|----------|----------|
| `rafadi_op` | `op123` |
| `aditya_op` | `op123` |

---

# BAB VIII - TARIF DAN DISKON

## Tarif Console

| Tipe Console | Tarif per Jam |
|--------------|---------------|
| PlayStation 4 (PS4) | Rp 15.000 |
| PlayStation 5 (PS5) | Rp 25.000 |

## Strategi Tarif

| Strategi | Keterangan | Perhitungan |
|----------|------------|-------------|
| Standard | Hari biasa (Senin-Jumat) | Base rate |
| Weekend | Sabtu & Minggu | Base rate × 1.5 (+50%) |
| Member | Pelanggan member | Base rate × (1 - discount%) |

## Level Member & Diskon

| Level | Syarat Poin | Diskon |
|-------|-------------|--------|
| SILVER | < 1.000 poin | 5% |
| GOLD | ≥ 1.000 poin | 10% |
| PLATINUM | ≥ 2.000 poin | 15% |
| VVIP | ≥ 5.000 poin | 20% |

---

# BAB IX - HASIL PENGUJIAN

## Pengujian Fungsional

| No | Test Case | Expected Result | Status |
|----|-----------|-----------------|--------|
| 1 | Login Admin valid | Redirect ke Admin Dashboard | ✅ Pass |
| 2 | Login Operator valid | Redirect ke Operator Dashboard | ✅ Pass |
| 3 | Login invalid | Tampil pesan error | ✅ Pass |
| 4 | Registrasi Operator baru | Operator tersimpan di database | ✅ Pass |
| 5 | Tambah Console | Console tersimpan | ✅ Pass |
| 6 | Tambah Room | Room tersimpan | ✅ Pass |
| 7 | Start Session | Session ACTIVE tersimpan | ✅ Pass |
| 8 | Pause Session | Status berubah PAUSED | ✅ Pass |
| 9 | Resume Session | Status kembali ACTIVE | ✅ Pass |
| 10 | End Session | Status COMPLETED, fee terhitung | ✅ Pass |
| 11 | Buat Reservasi | Reservasi tersimpan | ✅ Pass |
| 12 | Cek Overlap | Reservasi bentrok ditolak | ✅ Pass |
| 13 | Pembayaran CASH | Payment tersimpan | ✅ Pass |
| 14 | Pembayaran E-Wallet | Payment tersimpan | ✅ Pass |
| 15 | Generate Laporan Harian | Laporan tampil benar | ✅ Pass |
| 16 | Generate Laporan Bulanan | Laporan tampil benar | ✅ Pass |
| 17 | Tarif Standard | Perhitungan benar | ✅ Pass |
| 18 | Tarif Weekend | +50% dari standard | ✅ Pass |
| 19 | Tarif Member | Diskon sesuai level | ✅ Pass |
| 20 | Tambah Member | Member tersimpan | ✅ Pass |

## Checklist Konsep OOP

| Konsep | Implementasi | File |
|--------|--------------|------|
| ✅ Abstract Class | Person, Laporan | `Person.java`, `Laporan.java` |
| ✅ Interface | RentalTarifStrategy | `RentalTarifStrategy.java` |
| ✅ Inheritance | Admin, Operator, Member extends Person | Model classes |
| ✅ Encapsulation | Private fields + getter/setter | Semua model class |
| ✅ Polymorphism | Strategy implementations | Strategy classes |
| ✅ Singleton Pattern | DatabaseConnection | `DatabaseConnection.java` |
| ✅ Strategy Pattern | Tarif calculation | Strategy package |
| ✅ Factory Pattern | TarifFactory | `TarifFactory.java` |

---

# BAB X - KESIMPULAN

Aplikasi PSRent Max telah berhasil dikembangkan dengan menerapkan konsep-konsep Pemrograman Berbasis Objek (PBO) secara menyeluruh. Sistem ini mampu mengelola operasional rental PlayStation dengan fitur lengkap meliputi:

1. **Autentikasi Multi-Role**: Admin dan Operator dengan hak akses berbeda
2. **Manajemen Inventori**: Pengelolaan console PS4/PS5 dan ruangan
3. **Manajemen Sesi Rental**: Start, pause, resume, dan end session
4. **Perhitungan Tarif Dinamis**: Strategy pattern untuk tarif fleksibel
5. **Sistem Reservasi**: Dengan deteksi konflik jadwal otomatis
6. **Pelaporan**: Laporan harian dan bulanan untuk analisis bisnis
7. **Sistem Member**: Level dan diskon bertingkat

Dengan implementasi design pattern (Singleton, Strategy, Factory) dan arsitektur MVC, aplikasi ini mudah dipelihara dan dikembangkan di masa depan.

---

# LAMPIRAN

## Struktur File Proyek

```
porjecttubes_rev1/
├── pom.xml
├── database_setup.sql
├── LAPORAN_AKHIR_PSRENT_MAX.md
│
├── src/main/java/com/mycompany/
│   ├── dao/
│   │   ├── ConsoleDAO.java
│   │   ├── MemberDAO.java
│   │   ├── PaymentDAO.java
│   │   ├── ReservationDAO.java
│   │   ├── RoomDAO.java
│   │   ├── SessionDAO.java
│   │   └── UserDAO.java
│   │
│   ├── db/
│   │   └── DatabaseConnection.java
│   │
│   └── model/
│       ├── Admin.java
│       ├── ConsoleUnit.java
│       ├── Member.java
│       ├── Operator.java
│       ├── Payment.java
│       ├── Person.java
│       ├── RentalSession.java
│       ├── Reservation.java
│       ├── Room.java
│       │
│       ├── enums/
│       │   ├── ConsoleStatus.java
│       │   ├── ConsoleType.java
│       │   ├── MemberLevel.java
│       │   ├── PaymentMethod.java
│       │   ├── Role.java
│       │   ├── RoomStatus.java
│       │   └── SessionStatus.java
│       │
│       ├── report/
│       │   ├── Laporan.java
│       │   ├── LaporanBulanan.java
│       │   └── LaporanHarian.java
│       │
│       └── strategy/
│           ├── MemberTarif.java
│           ├── RentalTarifStrategy.java
│           ├── StandardTarif.java
│           ├── TarifFactory.java
│           └── WeekendTarif.java
│
└── src/main/webapp/
    ├── index.jsp (Login)
    ├── register.jsp
    ├── admin/
    │   ├── dashboard.jsp
    │   └── proses/
    │       ├── add_console.jsp
    │       ├── add_operator.jsp
    │       ├── add_room.jsp
    │       └── ...
    │
    └── operator/
        ├── dashboard.jsp
        ├── payment.jsp
        └── proses/
            ├── create_reservation.jsp
            ├── start_session.jsp
            └── ...
```

---

**Dokumen ini dibuat sebagai laporan akhir Tugas Besar mata kuliah Pemrograman Berbasis Objek (PBO).**

*Kelompok 6 - Desember 2025*
