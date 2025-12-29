<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="com.mycompany.dao.*" %>
<%@ page import="com.mycompany.db.*" %>
<%@ page import="com.mycompany.model.*" %>
<%@ page import="com.mycompany.model.enums.*" %>

<%
    String role = (String) session.getAttribute("role");
    String username = (String) session.getAttribute("username");
    
    if (role == null || !role.equals("OPERATOR")) {
        response.sendRedirect("../index.jsp?error=unauthorized");
        return;
    }
    
    String tab = request.getParameter("tab");
    if (tab == null || tab.isEmpty()) tab = "sesi"; 
    
    ConsoleDAO consoleDAO = new ConsoleDAO();
    RoomDAO roomDAO = new RoomDAO();
    MemberDAO memberDAO = new MemberDAO();
    SessionDAO sessionDAO = new SessionDAO();
    
    // Load Data Standar
    List<ConsoleUnit> consoles = consoleDAO.findAll();
    List<ConsoleUnit> availableConsoles = consoleDAO.findByStatus(ConsoleStatus.AVAILABLE);
    List<Room> rooms = roomDAO.findAll();
    List<Room> availableRooms = roomDAO.findByStatus(RoomStatus.AVAILABLE);
    List<Member> members = memberDAO.findAll();
    List<RentalSession> activeSessions = sessionDAO.findActiveSession();
    
    // --- FIX: LOGIC PENGAMBILAN DATA RESERVASI (MANUAL JDBC) ---
    // pakai manual query agar bisa mengambil status 'ACTIVE' dan join table Rooms+Consoles
    List<Reservation> pendingReservations = new ArrayList<>();
    Connection connRes = null;
    try {
        connRes = DatabaseConnection.getInstance().getConnection();
        // Query: Ambil reservasi ACTIVE, Join ke Rooms dan Consoles buat dapet Tipe Konsolnya
        String sqlRes = "SELECT r.*, c.type as console_type_str " +
                        "FROM reservations r " +
                        "LEFT JOIN rooms rm ON r.room_id = rm.id " +
                        "LEFT JOIN consoles c ON rm.console_id = c.id " +
                        "WHERE r.status = 'ACTIVE' " +
                        "ORDER BY r.start_time ASC";
                        
        PreparedStatement psRes = connRes.prepareStatement(sqlRes);
        ResultSet rsRes = psRes.executeQuery();
        
        while(rsRes.next()) {
            Reservation res = new Reservation();
            res.setId(rsRes.getInt("id"));
            res.setCustomerName(rsRes.getString("customer_name"));
            res.setPhone(rsRes.getString("customer_phone"));
            res.setReservationTime(rsRes.getTimestamp("start_time"));
            
            // Hitung Durasi 
            long diff = rsRes.getTimestamp("end_time").getTime() - rsRes.getTimestamp("start_time").getTime();
            int dur = (int) (diff / (1000 * 60 * 60));
            res.setDuration(dur);
            
            // Set Console Type (Manual Mapping String ke Enum)
            String cTypeStr = rsRes.getString("console_type_str");
            if (cTypeStr != null) {
                try {
                    res.setConsoleType(ConsoleType.valueOf(cTypeStr));
                } catch (Exception e) {
                    // Fallback jika null/error, default PS4 biar gak error display
                    res.setConsoleType(ConsoleType.PS4); 
                }
            } else {
                res.setConsoleType(ConsoleType.PS4); // Default
            }
            
            pendingReservations.add(res);
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    // -------------------------------------------------------------
    
    int activeSessionCount = activeSessions.size();
    int availableConsoleCount = availableConsoles.size();
    int availableRoomCount = availableRooms.size();
    int pendingReservationCount = pendingReservations.size();
    
    String successMsg = request.getParameter("success");
    String errorMsg = request.getParameter("error");
%>

<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Operator Dashboard - PSRent Max</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="../css/style.css">
    <style>
        .session-timer {
            font-family: 'Courier New', monospace;
            font-size: 16px; font-weight: bold;
            padding: 5px 10px; border-radius: 5px;
            display: inline-block; width: 110px; text-align: center;
        }
        .timer-normal { color: var(--success); background: rgba(46, 213, 115, 0.1); }
        .timer-warning { color: var(--warning); background: rgba(255, 165, 2, 0.1); }
        .timer-overdue { color: var(--white); background: var(--danger); animation: pulse 1s infinite; }
        
        @keyframes pulse { 0% { opacity: 1; } 50% { opacity: 0.7; } 100% { opacity: 1; } }

        /* Console Grid Styles */
        .console-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 20px; }
        .console-card { background: var(--white); border-radius: var(--radius); padding: 20px; text-align: center; box-shadow: var(--shadow); transition: var(--transition); position: relative; overflow: hidden; border: 1px solid var(--border); }
        .console-card:hover { transform: translateY(-5px); box-shadow: var(--shadow-lg); }
        
        .console-card.available { border-top: 5px solid var(--success); }
        .console-card.in-use { border-top: 5px solid var(--warning); }
        .console-card.maintenance { border-top: 5px solid var(--danger); }
        
        .console-icon { font-size: 40px; margin-bottom: 15px; display: block; }
        .console-icon.ps4 { color: #003087; }
        .console-icon.ps5 { color: #00439C; }
        
        .tab-content { display: none; }
        .tab-content.active { display: block; animation: fadeIn 0.5s; }
        @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
    </style>
</head>
<body>
    <div class="dashboard">
        <aside class="sidebar">
            <div class="sidebar-header">
                <div class="sidebar-logo"><i class="fab fa-playstation"></i></div>
                <h2 class="sidebar-title">PSRent Max</h2>
                <p class="sidebar-subtitle">Operator Panel</p>
            </div>
            <nav class="sidebar-nav">
                <div class="nav-section">Menu Utama</div>
                <a href="dashboard.jsp?tab=sesi" class="nav-item <%= tab.equals("sesi") ? "active" : "" %>"><i class="fas fa-play-circle"></i><span>Sesi Aktif</span></a>
                <a href="dashboard.jsp?tab=mulai" class="nav-item <%= tab.equals("mulai") ? "active" : "" %>"><i class="fas fa-gamepad"></i><span>Mulai Sesi</span></a>
                <a href="dashboard.jsp?tab=reservasi" class="nav-item <%= tab.equals("reservasi") ? "active" : "" %>"><i class="fas fa-calendar-check"></i><span>Reservasi</span></a>
                <a href="dashboard.jsp?tab=member" class="nav-item <%= tab.equals("member") ? "active" : "" %>"><i class="fas fa-id-card"></i><span>Member</span></a>
                <div class="nav-section">Pengaturan</div>
                <a href="../logout.jsp" class="nav-item"><i class="fas fa-sign-out-alt"></i><span>Logout</span></a>
            </nav>
            <div class="sidebar-user">
                <div class="user-info">
                    <div class="user-avatar"><i class="fas fa-user-cog"></i></div>
                    <div class="user-details"><h4><%= username %></h4><p>Operator</p></div>
                </div>
            </div>
        </aside>
        
        <main class="main-content">
            <header class="header">
                <div class="header-title"><h1>Dashboard Operator</h1><p>Kelola sesi rental PlayStation dengan mudah</p></div>
                <div class="header-actions"><span class="badge badge-info"><i class="fas fa-clock"></i> <%= new java.text.SimpleDateFormat("dd MMM yyyy, HH:mm").format(new java.util.Date()) %></span></div>
            </header>
            
            <% if (successMsg != null) { %><div class="alert alert-success"><i class="fas fa-check-circle"></i> <%= successMsg %></div><% } %>
            <% if (errorMsg != null) { %><div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> <%= errorMsg %></div><% } %>
            
            <!-- Stats -->
            <div class="stats-grid">
                <div class="stat-card primary"><div class="stat-icon primary"><i class="fas fa-play-circle"></i></div><div class="stat-value"><%= activeSessionCount %></div><div class="stat-label">Sesi Aktif</div></div>
                <div class="stat-card success"><div class="stat-icon success"><i class="fas fa-gamepad"></i></div><div class="stat-value"><%= availableConsoleCount %></div><div class="stat-label">Konsol Tersedia</div></div>
                <div class="stat-card warning"><div class="stat-icon warning"><i class="fas fa-door-open"></i></div><div class="stat-value"><%= availableRoomCount %></div><div class="stat-label">Ruangan Tersedia</div></div>
                <div class="stat-card info"><div class="stat-icon info"><i class="fas fa-calendar-check"></i></div><div class="stat-value"><%= pendingReservationCount %></div><div class="stat-label">Reservasi Aktif</div></div>
            </div>
            
            <!-- Tab Content: Sesi Aktif -->
            <div id="sesi" class="tab-content <%= tab.equals("sesi") ? "active" : "" %>">
                <div class="card">
                    <div class="card-header"><h3><i class="fas fa-play-circle"></i> Sesi Aktif </h3><button class="btn btn-primary btn-sm" onclick="location.reload()"><i class="fas fa-sync"></i> Refresh</button></div>
                    <div class="card-body">
                        <% if (activeSessions.isEmpty()) { %>
                        <div class="empty-state"><i class="fas fa-gamepad"></i><h4>Tidak ada sesi aktif</h4><p>Silakan mulai sesi baru di menu Mulai Sesi</p></div>
                        <% } else { %>
                        <div class="table-responsive">
                            <table class="table">
                                <thead><tr><th>ID</th><th>Konsol</th><th>Pelanggan</th><th>Waktu Selesai</th><th>Sisa Waktu</th><th>Status</th><th>Aksi</th></tr></thead>
                                <tbody>
                                    <% 
                                    for (RentalSession sess : activeSessions) { 
                                        ConsoleUnit console = null; Member member = null;
                                        try {
                                            if(sess.getConsoleId() != null) console = consoleDAO.findById(sess.getConsoleId());
                                            if(sess.getMemberId() != null) member = memberDAO.findById(sess.getMemberId());
                                        } catch (Exception e) {}
                                        
                                        String custName = (member != null) ? member.getName() : sess.getCustomerName();
                                        if (custName == null) custName = "Pelanggan Umum";

                                        long currentTime = new java.util.Date().getTime();
                                        long plannedEnd = sess.getPlannedEndTime() != null ? sess.getPlannedEndTime().getTime() : currentTime;
                                        long totalPausedMs = sess.getPausedMinutes() * 60 * 1000;
                                        long adjustedPlannedEnd = plannedEnd + totalPausedMs;
                                    %>
                                    <tr>
                                        <td>#<%= sess.getId() %></td>
                                        <td><strong><%= (console != null) ? console.getType().getDisplayName() + " #" + console.getId() : "Data Hilang" %></strong></td>
                                        <td><%= custName %></td>
                                        <td><%= new java.text.SimpleDateFormat("HH:mm").format(new Date(adjustedPlannedEnd)) %></td>
                                        <td>
                                            <span class="session-timer" 
                                                  id="timer-<%= sess.getId() %>"
                                                  data-target="<%= adjustedPlannedEnd %>"
                                                  data-status="<%= sess.getStatus().name() %>"
                                                  data-actual-end="<%= sess.getActualEndTime() != null ? sess.getActualEndTime().getTime() : 0 %>">
                                                Loading...
                                            </span>
                                        </td>
                                        <td><span class="badge <%= (sess.getStatus() == SessionStatus.ACTIVE) ? "badge-success" : "badge-warning" %>"><%= sess.getStatus().getDisplayName() %></span></td>
                                        <td>
                                            <% if (sess.getStatus() == SessionStatus.ACTIVE) { %>
                                            <a href="proses/pause_session.jsp?id=<%= sess.getId() %>" class="btn btn-warning btn-sm" title="Pause"><i class="fas fa-pause"></i></a>
                                            <% } else if (sess.getStatus() == SessionStatus.PAUSED) { %>
                                            <a href="proses/resume_session.jsp?id=<%= sess.getId() %>" class="btn btn-success btn-sm" title="Resume"><i class="fas fa-play"></i></a>
                                            <% } %>
                                            <button type="button" class="btn btn-info btn-sm" title="Tambah Waktu" onclick="showExtendModal(<%= sess.getId() %>)"><i class="fas fa-plus-circle"></i></button>
                                            <a href="proses/end_session.jsp?id=<%= sess.getId() %>" class="btn btn-danger btn-sm" title="Akhiri & Bayar" onclick="return confirm('Akhiri sesi ini dan hitung biaya?')"><i class="fas fa-stop"></i></a>
                                        </td>
                                    </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                        <% } %>
                    </div>
                </div>
            </div>
            
            <!-- Tab Content: Mulai Sesi -->
            <div id="mulai" class="tab-content <%= tab.equals("mulai") ? "active" : "" %>">
                <div class="card">
                    <div class="card-header"><h3><i class="fas fa-gamepad"></i> Mulai Sesi Baru</h3></div>
                    <div class="card-body">
                        <form action="proses/start_session.jsp" method="post">
                            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px;">
                                <div class="form-group">
                                    <label>Pilih Konsol *</label>
                                    <select name="consoleId" id="consoleSelect" class="form-control" required onchange="calculatePrice()">
                                        <option value="" data-rate="0">-- Pilih Konsol --</option>
                                        <% for (ConsoleUnit c : availableConsoles) { %>
                                        <option value="<%= c.getId() %>" data-rate="<%= c.getRatePerHour() %>">
                                            <%= c.getType().getDisplayName() %> #<%= c.getId() %>
                                        </option>
                                        <% } %>
                                    </select>
                                </div>
                                <div class="form-group"><label>Pilih Ruangan (Opsional)</label><select name="roomId" class="form-control"><option value="">-- Tanpa Ruangan --</option><% for (Room r : availableRooms) { %><option value="<%= r.getId() %>"><%= r.getName() %> (<%= r.getCapacity() %> orang)</option><% } %></select></div>
                                <div class="form-group"><label>Member (Opsional)</label><select name="memberId" class="form-control" onchange="toggleCustomerName(this)"><option value="">-- Bukan Member --</option><% for (Member m : members) { %><option value="<%= m.getId() %>"><%= m.getName() %> (<%= m.getLevel().getDisplayName() %>)</option><% } %></select></div>
                                <div class="form-group" id="customerNameGroup"><label>Nama Pelanggan *</label><input type="text" name="customerName" id="customerName" class="form-control" placeholder="Nama pelanggan"></div>
                                
                                <div class="form-group">
                                    <label>Durasi (Jam) *</label>
                                    <input type="number" name="duration" id="durationInput" class="form-control" value="1" min="1" required oninput="calculatePrice()">
                                </div>
                                <div class="form-group">
                                    <label>Estimasi Harga</label>
                                    <input type="text" id="estimatedPrice" class="form-control" readonly style="background-color: #f0f0f0; font-weight: bold; color: var(--primary);">
                                </div>
                            </div>
                            <div style="margin-top: 20px"><button type="submit" class="btn btn-success"><i class="fas fa-play"></i> Mulai Sesi</button></div>
                        </form>
                    </div>
                </div>
                
                <div class="card">
                    <div class="card-header"><h3><i class="fas fa-th"></i> Status Konsol</h3></div>
                    <div class="card-body">
                        <div class="console-grid">
                            <% for (ConsoleUnit c : consoles) { %>
                            <div class="console-card <%= c.getStatus().toString().toLowerCase().replace("_", "-") %>">
                                <i class="fab fa-playstation console-icon <%= c.getType() == ConsoleType.PS4 ? "ps4" : "ps5" %>"></i>
                                <h4><%= c.getType().getDisplayName() %></h4><p>#<%= c.getId() %></p>
                                <span class="badge <%= c.getStatus() == ConsoleStatus.AVAILABLE ? "badge-success" : c.getStatus() == ConsoleStatus.IN_USE ? "badge-warning" : "badge-danger" %>"><%= c.getStatus().getDisplayName() %></span>
                            </div>
                            <% } %>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Tab Content: Reservasi (FIXED DATA SOURCE) -->
            <div id="reservasi" class="tab-content <%= tab.equals("reservasi") ? "active" : "" %>">
                <div class="card">
                    <div class="card-header"><h3><i class="fas fa-calendar-plus"></i> Buat Reservasi</h3></div>
                    <div class="card-body">
                        <form action="proses/create_reservation.jsp" method="post">
                            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px;">
                                <div class="form-group"><label>Nama Pelanggan *</label><input type="text" name="customerName" class="form-control" required></div>
                                <div class="form-group"><label>No. Telepon *</label><input type="text" name="phone" class="form-control" required></div>
                                <div class="form-group"><label>Tipe Konsol *</label><select name="consoleType" class="form-control" required><option value="PS4">PlayStation 4</option><option value="PS5">PlayStation 5</option></select></div>
                                <div class="form-group"><label>Tanggal & Waktu *</label><input type="datetime-local" name="reservationTime" class="form-control" required></div>
                                <div class="form-group"><label>Durasi (Jam) *</label><input type="number" name="duration" class="form-control" min="1" max="12" value="1" required></div>
                            </div>
                            <div style="margin-top: 20px"><button type="submit" class="btn btn-primary">Buat Reservasi</button></div>
                        </form>
                    </div>
                </div>
                
                <!-- TABEL RESERVASI FIXED -->
                <div class="card">
                    <div class="card-header"><h3><i class="fas fa-clock"></i> Daftar Reservasi</h3></div>
                    <div class="card-body">
                        <% if (pendingReservations.isEmpty()) { %>
                            <div class="empty-state">
                                <i class="fas fa-calendar-times"></i>
                                <h4>Tidak ada reservasi aktif</h4>
                                <p>Data reservasi yang baru dibuat akan muncul di sini.</p>
                            </div>
                        <% } else { %>
                            <div class="table-responsive">
                                <table class="table">
                                    <thead><tr><th>ID</th><th>Pelanggan</th><th>Telepon</th><th>Konsol</th><th>Waktu</th><th>Durasi</th><th>Aksi</th></tr></thead>
                                    <tbody>
                                        <% for (Reservation res : pendingReservations) { %>
                                        <tr>
                                            <td>#<%= res.getId() %></td>
                                            <td><strong><%= res.getCustomerName() %></strong></td>
                                            <td><%= res.getPhone() %></td>
                                            <td><span class="badge badge-info"><%= res.getConsoleType().getDisplayName() %></span></td>
                                            <td><%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(res.getReservationTime()) %></td>
                                            <td><%= res.getDuration() %> jam</td>
                                            <td>
                                                <a href="proses/confirm_reservation.jsp?id=<%= res.getId() %>" class="btn btn-success btn-sm">Konfirmasi</a>
                                                <a href="proses/cancel_reservation.jsp?id=<%= res.getId() %>" class="btn btn-danger btn-sm" onclick="return confirm('Batalkan?')">Batal</a>
                                            </td>
                                        </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                            </div>
                        <% } %>
                    </div>
                </div>
            </div>
            
            <!-- Tab Content: Member -->
            <div id="member" class="tab-content <%= tab.equals("member") ? "active" : "" %>">
                <div class="card"><div class="card-header"><h3><i class="fas fa-user-plus"></i> Tambah Member</h3></div><div class="card-body"><form action="proses/create_member.jsp" method="post"><div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px;"><div class="form-group"><label>Nama Lengkap *</label><input type="text" name="name" class="form-control" required></div><div class="form-group"><label>Email *</label><input type="email" name="email" class="form-control" required></div><div class="form-group"><label>No. Telepon *</label><input type="text" name="phone" class="form-control" required></div></div><div style="margin-top: 20px"><button type="submit" class="btn btn-primary">Daftar Member</button></div></form></div></div><div class="card"><div class="card-header"><h3><i class="fas fa-id-card"></i> Daftar Member</h3></div><div class="card-body"><div class="table-responsive"><table class="table"><thead><tr><th>ID</th><th>Nama</th><th>Email</th><th>Telepon</th><th>Level</th><th>Poin</th><th>Total Sewa</th></tr></thead><tbody><% for (Member m : members) { %><tr><td>#<%= m.getId() %></td><td><strong><%= m.getName() %></strong></td><td><%= m.getEmail() %></td><td><%= m.getPhone() %></td><td><span class="badge <%= m.getLevel() == MemberLevel.GOLD ? "badge-warning" : m.getLevel() == MemberLevel.PLATINUM ? "badge-info" : "badge-primary" %>"><%= m.getLevel().getDisplayName() %></span></td><td><%= m.getPoints() %></td><td><%= m.getTotalRentals() %> kali</td></tr><% } %></tbody></table></div></div></div>
            </div>
        </main>
    </div>
    
    <script>
        function toggleCustomerName(select) {
            const group = document.getElementById('customerNameGroup');
            const input = document.getElementById('customerName');
            if (select.value) { group.style.opacity = '0.5'; input.required = false; input.value = ''; } 
            else { group.style.opacity = '1'; input.required = true; }
        }

        function calculatePrice() {
            const select = document.getElementById('consoleSelect');
            const durationInput = document.getElementById('durationInput');
            const priceInput = document.getElementById('estimatedPrice');
            if (select.selectedIndex === 0) { priceInput.value = "Rp 0"; return; }
            const rate = parseFloat(select.options[select.selectedIndex].getAttribute('data-rate'));
            const durationHours = parseInt(durationInput.value) || 0;
            const price = Math.ceil(durationHours * rate);
            priceInput.value = "Rp " + price.toLocaleString('id-ID');
        }

        // --- NEW: ROBUST JAVASCRIPT TIMER ---
        function updateCountdowns() {
            const timers = document.querySelectorAll('.session-timer');
            const now = new Date().getTime();

            timers.forEach(timer => {
                const status = timer.dataset.status;
                const targetTime = parseInt(timer.dataset.target); 
                const actualEndTime = parseInt(timer.dataset.actualEnd); 

                let remainingMs = 0;

                if (status === 'PAUSED' && actualEndTime > 0) {
                    remainingMs = targetTime - actualEndTime;
                } else {
                    remainingMs = targetTime - now;
                }

                const isOverdue = remainingMs < 0;
                const absMs = Math.abs(remainingMs);
                const h = Math.floor(absMs / (1000 * 60 * 60));
                const m = Math.floor((absMs % (1000 * 60 * 60)) / (1000 * 60));
                const s = Math.floor((absMs % (1000 * 60)) / 1000);

                const timeString = (isOverdue ? "-" : "") + 
                                   String(h).padStart(2, '0') + ':' + 
                                   String(m).padStart(2, '0') + ':' + 
                                   String(s).padStart(2, '0');

                timer.textContent = timeString;

                timer.classList.remove('timer-normal', 'timer-warning', 'timer-overdue');
                if (isOverdue) {
                    timer.classList.add('timer-overdue');
                } else if (remainingMs < 300000 && status !== 'PAUSED') { 
                    timer.classList.add('timer-warning');
                } else {
                    timer.classList.add('timer-normal');
                }
                
                if (status === 'PAUSED') {
                    timer.textContent = "PAUSED (" + timeString + ")";
                    timer.style.opacity = "0.7";
                }
            });
        }
        setInterval(updateCountdowns, 1000);
        updateCountdowns(); 
        
        // Extend time modal function
        function showExtendModal(sessionId) {
            var hours = prompt('Tambah waktu berapa jam? (1-5):', '1');
            if (hours !== null) {
                hours = parseInt(hours);
                if (hours >= 1 && hours <= 5) {
                    window.location.href = 'proses/extend_session.jsp?id=' + sessionId + '&hours=' + hours;
                } else {
                    alert('Masukkan angka 1-5 untuk jumlah jam!');
                }
            }
        }
    </script>
</body>
</html>