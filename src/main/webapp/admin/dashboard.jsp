<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="com.mycompany.dao.*" %>
<%@ page import="com.mycompany.model.*" %>
<%@ page import="com.mycompany.model.enums.*" %>

<%
    // Check if user is logged in and is admin
    String role = (String) session.getAttribute("role");
    String username = (String) session.getAttribute("username");
    
    if (role == null || !role.equals("ADMIN")) {
        response.sendRedirect("../index.jsp?error=unauthorized");
        return;
    }
    
    // Handle Tab Navigation
    String tab = request.getParameter("tab");
    if (tab == null || tab.isEmpty()) tab = "inventori"; 

    // Initialize DAOs
    ConsoleDAO consoleDAO = new ConsoleDAO();
    RoomDAO roomDAO = new RoomDAO();
    UserDAO userDAO = new UserDAO();
    SessionDAO sessionDAO = new SessionDAO();
    
    // Get data
    List<ConsoleUnit> consoles = consoleDAO.findAll();
    List<Room> rooms = roomDAO.findAll();
    List<Operator> operators = userDAO.findAllOperators();
    List<RentalSession> activeSessions = sessionDAO.findActiveSession();
    
    // Calculate stats
    int totalConsoles = consoles.size();
    int availableConsoles = 0;
    for (ConsoleUnit c : consoles) { if (c.getStatus() == ConsoleStatus.AVAILABLE) availableConsoles++; }
    
    int totalRooms = rooms.size();
    int availableRooms = 0;
    for (Room r : rooms) { if (r.getStatus() == RoomStatus.AVAILABLE) availableRooms++; }
    
    int totalOperators = operators.size();
    int activeSessionCount = activeSessions.size();
    
    // Get message if any
    String successMsg = request.getParameter("success");
    String errorMsg = request.getParameter("error");
%>

<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - PSRent Max</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="../css/style.css">
    <style>
        /* --- Console Grid Styles --- */
        .console-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 20px; }
        .console-card { background: var(--white); border-radius: var(--radius); padding: 20px; text-align: center; box-shadow: var(--shadow); transition: var(--transition); position: relative; overflow: hidden; border: 1px solid var(--border); }
        .console-card:hover { transform: translateY(-5px); box-shadow: var(--shadow-lg); }
        
        .console-card.available { border-top: 5px solid var(--success); }
        .console-card.in-use { border-top: 5px solid var(--warning); }
        .console-card.maintenance { border-top: 5px solid var(--danger); }
        
        .console-icon { font-size: 40px; margin-bottom: 15px; display: block; }
        .console-icon.ps4 { color: #003087; }
        .console-icon.ps5 { color: #00439C; }

        .console-actions { margin-top: 15px; display: flex; justify-content: center; gap: 10px; }
        
        /* --- Tab Control --- */
        .tab-content { display: none; }
        .tab-content.active { display: block; animation: fadeIn 0.5s; }
        @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }

        /* =========================================
           REPORT & PRINT STYLES (NEW)
           ========================================= */
        .receipt {
            background: white !important;
            padding: 40px !important;
            border: 1px solid #ddd !important;
            box-shadow: 0 0 10px rgba(0,0,0,0.05) !important;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif !important;
            color: #333 !important;
            max-width: 210mm; /* A4 Width */
            margin: 0 auto;
        }

        .report-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 20px;
        }
        .company-info h1 { color: var(--primary); margin-bottom: 5px; font-size: 24px; }
        .company-info p { margin: 0; font-size: 12px; color: #666; }
        
        .report-meta { text-align: right; }
        .report-meta h2 { margin: 0 0 5px 0; font-size: 18px; color: #333; text-transform: uppercase; }
        .report-meta p { margin: 0; font-size: 12px; }

        .report-divider { border: 0; border-top: 2px solid var(--primary); margin: 20px 0; }

        .report-summary {
            display: flex;
            gap: 20px;
            margin-bottom: 30px;
        }
        .summary-box {
            flex: 1;
            background: #f8f9fa;
            padding: 15px;
            border-radius: 8px;
            border: 1px solid #eee;
        }
        .summary-box.highlight { background: rgba(233, 69, 96, 0.05); border-color: rgba(233, 69, 96, 0.2); }
        .summary-box .label { display: block; font-size: 12px; color: #666; text-transform: uppercase; }
        .summary-box .value { display: block; font-size: 20px; font-weight: bold; color: #333; margin-top: 5px; }
        .summary-box.highlight .value { color: var(--primary); }

        .report-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 12px;
            margin-bottom: 30px;
        }
        .report-table th { background: #333; color: white; padding: 10px; text-align: left; }
        .report-table td { border-bottom: 1px solid #eee; padding: 10px; }
        .report-table tr:nth-child(even) { background-color: #f9f9f9; }

        .report-footer {
            display: flex;
            justify-content: flex-end;
            margin-top: 50px;
        }
        .signature { text-align: center; width: 200px; font-size: 12px; }

        /* PRINT SETTINGS (Agar pas dicetak bersih) */
        @media print {
            body { background: white; visibility: hidden; }
            .sidebar, .header, .tabs, .card-header, .alert, form { display: none !important; }
            .dashboard { display: block; }
            .main-content { margin: 0; padding: 0; width: 100%; }
            .card { box-shadow: none; border: none; margin: 0; }
            .card-body { padding: 0; }
            
            /* Tampilkan HANYA kertas laporan */
            #reportPreview, #reportPreview * {
                visibility: visible;
            }
            #reportPreview {
                position: absolute;
                left: 0;
                top: 0;
                width: 100%;
                margin: 0;
                padding: 0;
            }
            .receipt {
                border: none !important;
                box-shadow: none !important;
                padding: 0 !important;
                width: 100%;
                max-width: 100%;
            }
        }
    </style>
</head>
<body>
    <div class="dashboard">
        <!-- Sidebar -->
        <aside class="sidebar">
            <div class="sidebar-header">
                <div class="sidebar-logo">
                    <i class="fab fa-playstation"></i>
                </div>
                <h2 class="sidebar-title">PSRent Max</h2>
                <p class="sidebar-subtitle">Admin Panel</p>
            </div>
            
            <nav class="sidebar-nav">
                <div class="nav-section">Menu Utama</div>
                <a href="dashboard.jsp?tab=inventori" class="nav-item <%= tab.equals("inventori") ? "active" : "" %>">
                    <i class="fas fa-gamepad"></i>
                    <span>Inventori</span>
                </a>
                <a href="dashboard.jsp?tab=operator" class="nav-item <%= tab.equals("operator") ? "active" : "" %>">
                    <i class="fas fa-users"></i>
                    <span>Kelola Operator</span>
                </a>
                <a href="dashboard.jsp?tab=laporan" class="nav-item <%= tab.equals("laporan") ? "active" : "" %>">
                    <i class="fas fa-chart-bar"></i>
                    <span>Laporan</span>
                </a>
                
                <div class="nav-section">Pengaturan</div>
                <a href="../logout.jsp" class="nav-item">
                    <i class="fas fa-sign-out-alt"></i>
                    <span>Logout</span>
                </a>
            </nav>
            
            <div class="sidebar-user">
                <div class="user-info">
                    <div class="user-avatar">
                        <i class="fas fa-user-shield"></i>
                    </div>
                    <div class="user-details">
                        <h4><%= username %></h4>
                        <p>Administrator</p>
                    </div>
                </div>
            </div>
        </aside>
        
        <!-- Main Content -->
        <main class="main-content">
            <!-- Header -->
            <header class="header">
                <div class="header-title">
                    <h1>Dashboard Admin</h1>
                    <p>Selamat datang kembali, <%= username %>!</p>
                </div>
                <div class="header-actions">
                    <span class="badge badge-info">
                        <i class="fas fa-clock"></i>
                        <%= new java.text.SimpleDateFormat("dd MMM yyyy, HH:mm").format(new java.util.Date()) %>
                    </span>
                </div>
            </header>
            
            <!-- Alert Messages -->
            <% if (successMsg != null) { %>
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i>
                <%= successMsg %>
            </div>
            <% } %>
            
            <% if (errorMsg != null) { %>
            <div class="alert alert-error">
                <i class="fas fa-exclamation-circle"></i>
                <%= errorMsg %>
            </div>
            <% } %>
            
            <!-- Stats Cards -->
            <div class="stats-grid">
                <div class="stat-card primary animate-fade-in">
                    <div class="stat-icon primary">
                        <i class="fas fa-gamepad"></i>
                    </div>
                    <div class="stat-value"><%= totalConsoles %></div>
                    <div class="stat-label">Total Konsol</div>
                </div>
                
                <div class="stat-card success animate-fade-in" style="animation-delay: 0.1s">
                    <div class="stat-icon success">
                        <i class="fas fa-door-open"></i>
                    </div>
                    <div class="stat-value"><%= totalRooms %></div>
                    <div class="stat-label">Total Ruangan</div>
                </div>
                
                <div class="stat-card warning animate-fade-in" style="animation-delay: 0.2s">
                    <div class="stat-icon warning">
                        <i class="fas fa-users-cog"></i>
                    </div>
                    <div class="stat-value"><%= totalOperators %></div>
                    <div class="stat-label">Total Operator</div>
                </div>
                
                <div class="stat-card info animate-fade-in" style="animation-delay: 0.3s">
                    <div class="stat-icon info">
                        <i class="fas fa-play-circle"></i>
                    </div>
                    <div class="stat-value"><%= activeSessionCount %></div>
                    <div class="stat-label">Sesi Aktif</div>
                </div>
            </div>
            
            <!-- Tab Navigation -->
            <div class="tabs">
                <button class="tab-btn <%= tab.equals("inventori") ? "active" : "" %>" onclick="window.location.href='dashboard.jsp?tab=inventori'">
                    <i class="fas fa-gamepad"></i> Inventori
                </button>
                <button class="tab-btn <%= tab.equals("operator") ? "active" : "" %>" onclick="window.location.href='dashboard.jsp?tab=operator'">
                    <i class="fas fa-users"></i> Kelola Operator
                </button>
                <button class="tab-btn <%= tab.equals("laporan") ? "active" : "" %>" onclick="window.location.href='dashboard.jsp?tab=laporan'">
                    <i class="fas fa-chart-bar"></i> Laporan
                </button>
            </div>
            
            <!-- Tab Content: Inventori -->
            <div id="inventori" class="tab-content <%= tab.equals("inventori") ? "active" : "" %>">
                <!-- Console Management -->
                <div class="card">
                    <div class="card-header">
                        <h3><i class="fas fa-gamepad"></i> Daftar Konsol</h3>
                        <button class="btn btn-primary btn-sm" onclick="openModal('addConsoleModal')">
                            <i class="fas fa-plus"></i> Tambah
                        </button>
                    </div>
                    <div class="card-body">
                        <div class="console-grid">
                            <% for (ConsoleUnit c : consoles) { %>
                            <div class="console-card <%= c.getStatus().toString().toLowerCase().replace("_", "-") %>">
                                <i class="fab fa-playstation console-icon <%= c.getType() == ConsoleType.PS4 ? "ps4" : "ps5" %>"></i>
                                <h4><%= c.getType().getDisplayName() %></h4>
                                <p>#<%= c.getId() %></p>
                                <p style="font-weight:bold; color:var(--primary);">Rp <%= String.format("%,.0f", c.getRatePerHour()) %>/Jam</p>
                                <span class="badge <%= c.getStatus() == ConsoleStatus.AVAILABLE ? "badge-success" : 
                                                      c.getStatus() == ConsoleStatus.IN_USE ? "badge-warning" : "badge-danger" %>">
                                    <%= c.getStatus().getDisplayName() %>
                                </span>
                                
                                <div class="console-actions">
                                    <button class="btn btn-outline btn-sm" onclick="editConsole('<%= c.getId() %>', '<%= c.getType() %>', '<%= (int)c.getRatePerHour() %>', '<%= c.getStatus() %>')">
                                        <i class="fas fa-edit"></i>
                                    </button>
                                    <a href="proses/delete_console.jsp?id=<%= c.getId() %>" class="btn btn-danger btn-sm" onclick="return confirm('Yakin hapus konsol ini?')">
                                        <i class="fas fa-trash"></i>
                                    </a>
                                </div>
                            </div>
                            <% } %>
                        </div>
                    </div>
                </div>
                
                <!-- Room Management -->
                <div class="card">
                    <div class="card-header">
                        <h3><i class="fas fa-door-open"></i> Daftar Ruangan</h3>
                        <button class="btn btn-primary btn-sm" onclick="openModal('addRoomModal')">
                            <i class="fas fa-plus"></i> Tambah
                        </button>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table">
                                <thead>
                                    <tr>
                                        <th>Nama</th>
                                        <th>Kapasitas</th>
                                        <th>Tarif/Jam</th>
                                        <th>Status</th>
                                        <th>Aksi</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (Room r : rooms) { %>
                                    <tr>
                                        <td><strong><%= r.getName() %></strong></td>
                                        <td><%= r.getCapacity() %> orang</td>
                                        <td>Rp <%= String.format("%,.0f", r.getRatePerHour()) %></td>
                                        <td>
                                            <span class="badge <%= r.getStatus() == RoomStatus.AVAILABLE ? "badge-success" : 
                                                                  r.getStatus() == RoomStatus.IN_USE ? "badge-warning" : "badge-danger" %>">
                                                <%= r.getStatus().getDisplayName() %>
                                            </span>
                                        </td>
                                        <td>
                                            <button class="btn btn-outline btn-sm" onclick="editRoom('<%= r.getId() %>', '<%= r.getName() %>', '<%= r.getCapacity() %>', '<%= (int)r.getRatePerHour() %>', '<%= r.getStatus() %>')">
                                                <i class="fas fa-edit"></i>
                                            </button>
                                            <a href="proses/delete_room.jsp?id=<%= r.getId() %>" class="btn btn-danger btn-sm" onclick="return confirm('Yakin hapus ruangan ini?')">
                                                <i class="fas fa-trash"></i>
                                            </a>
                                        </td>
                                    </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Tab Content: Operator -->
            <div id="operator" class="tab-content <%= tab.equals("operator") ? "active" : "" %>">
                <div class="card">
                    <div class="card-header">
                        <h3><i class="fas fa-users"></i> Daftar Operator</h3>
                        <button class="btn btn-primary btn-sm" onclick="openModal('addOperatorModal')">
                            <i class="fas fa-plus"></i> Tambah
                        </button>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table">
                                <thead>
                                    <tr>
                                        <th>Nama</th>
                                        <th>Username</th>
                                        <th>Email</th>
                                        <th>No. Telepon</th>
                                        <th>Shift</th>
                                        <th>Aksi</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (Operator op : operators) { %>
                                    <tr>
                                        <td><strong><%= op.getName() %></strong></td>
                                        <td><%= op.getUsername() %></td>
                                        <td><%= op.getEmail() %></td>
                                        <td><%= op.getPhone() %></td>
                                        <td><span class="badge badge-info"><%= op.getShift() %></span></td>
                                        <td>
                                            <button class="btn btn-outline btn-sm" onclick="editOperator('<%= op.getId() %>', '<%= op.getName() %>', '<%= op.getUsername() %>', '<%= op.getEmail() %>', '<%= op.getPhone() %>', '<%= op.getShift() %>')">
                                                <i class="fas fa-edit"></i>
                                            </button>
                                            <a href="proses/delete_operator.jsp?id=<%= op.getId() %>" class="btn btn-danger btn-sm" onclick="return confirm('Yakin hapus operator ini?')">
                                                <i class="fas fa-trash"></i>
                                            </a>
                                        </td>
                                    </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Tab Content: Laporan -->
            <div id="laporan" class="tab-content <%= tab.equals("laporan") ? "active" : "" %>">
                <div class="card">
                    <div class="card-header">
                        <h3><i class="fas fa-chart-bar"></i> Generate Laporan</h3>
                    </div>
                    <div class="card-body">
                        <form action="proses/generate_report.jsp" method="post">
                            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px;">
                                <div class="form-group">
                                    <label>Jenis Laporan</label>
                                    <select name="reportType" class="form-control" required>
                                        <option value="daily">Laporan Harian</option>
                                        <option value="monthly">Laporan Bulanan</option>
                                    </select>
                                </div>
                                <div class="form-group">
                                    <label>Tanggal</label>
                                    <input type="date" name="reportDate" class="form-control" value="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>">
                                </div>
                                <div class="form-group">
                                    <label>&nbsp;</label>
                                    <button type="submit" class="btn btn-primary" style="width: 100%">
                                        <i class="fas fa-file-alt"></i> Generate Laporan
                                    </button>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>
                
                <!-- Report Preview Area -->
                <div class="card">
                    <div class="card-header">
                        <h3><i class="fas fa-file-invoice"></i> Preview Laporan</h3>
                        <% 
                            String reportContent = (String) session.getAttribute("reportContent");
                            if (reportContent != null && !reportContent.isEmpty()) {
                        %>
                            <button class="btn btn-outline btn-sm" onclick="window.print()">
                                <i class="fas fa-print"></i> Cetak
                            </button>
                        <% } %>
                    </div>
                    <div class="card-body">
                        <div id="reportPreview">
                            <% if (reportContent != null && !reportContent.isEmpty()) { %>
                                <div class="receipt">
                                    <%= reportContent %>
                                </div>
                            <% } else { %>
                                <div class="empty-state">
                                    <i class="fas fa-chart-pie"></i>
                                    <h4>Belum ada laporan</h4>
                                    <p>Pilih jenis dan tanggal laporan, lalu klik "Generate Laporan"</p>
                                </div>
                            <% } %>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>
    
    <!-- Modal: Add Console -->
    <div id="addConsoleModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h3><i class="fas fa-gamepad"></i> Tambah Konsol</h3>
                <button class="modal-close" onclick="closeModal('addConsoleModal')"><i class="fas fa-times"></i></button>
            </div>
            <form action="proses/add_console.jsp" method="post">
                <div class="modal-body">
                    <div class="form-group">
                        <label>Tipe Konsol</label>
                        <select name="type" class="form-control" required>
                            <option value="PS4">PlayStation 4</option>
                            <option value="PS5">PlayStation 5</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Tarif per Jam (Rp)</label>
                        <input type="number" name="rate" class="form-control" placeholder="Contoh: 15000" required>
                    </div>
                    <div class="form-group">
                        <label>Status</label>
                        <select name="status" class="form-control" required>
                            <option value="AVAILABLE">Tersedia</option>
                            <option value="MAINTENANCE">Maintenance</option>
                        </select>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline" onclick="closeModal('addConsoleModal')">Batal</button>
                    <button type="submit" class="btn btn-primary">Simpan</button>
                </div>
            </form>
        </div>
    </div>
    
    <!-- Modal: Edit Console -->
    <div id="editConsoleModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h3><i class="fas fa-edit"></i> Edit Konsol</h3>
                <button class="modal-close" onclick="closeModal('editConsoleModal')"><i class="fas fa-times"></i></button>
            </div>
            <form action="proses/edit_console.jsp" method="post">
                <div class="modal-body">
                    <input type="hidden" name="id" id="editConsoleId">
                    <div class="form-group">
                        <label>Tipe Konsol</label>
                        <select name="type" id="editConsoleType" class="form-control" required>
                            <option value="PS4">PlayStation 4</option>
                            <option value="PS5">PlayStation 5</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Tarif per Jam (Rp)</label>
                        <input type="number" name="rate" id="editConsoleRate" class="form-control" required>
                    </div>
                    <div class="form-group">
                        <label>Status</label>
                        <select name="status" id="editConsoleStatus" class="form-control" required>
                            <option value="AVAILABLE">Tersedia</option>
                            <option value="IN_USE">Sedang Digunakan</option>
                            <option value="MAINTENANCE">Maintenance</option>
                        </select>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline" onclick="closeModal('editConsoleModal')">Batal</button>
                    <button type="submit" class="btn btn-primary">Update</button>
                </div>
            </form>
        </div>
    </div>
    
    <!-- Modal: Add Room -->
    <div id="addRoomModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h3><i class="fas fa-door-open"></i> Tambah Ruangan</h3>
                <button class="modal-close" onclick="closeModal('addRoomModal')"><i class="fas fa-times"></i></button>
            </div>
            <form action="proses/add_room.jsp" method="post">
                <div class="modal-body">
                    <div class="form-group">
                        <label>Nama Ruangan</label>
                        <input type="text" name="name" class="form-control" placeholder="Contoh: VIP Room 1" required>
                    </div>
                    <div class="form-group">
                        <label>Kapasitas</label>
                        <input type="number" name="capacity" class="form-control" placeholder="Jumlah orang" required>
                    </div>
                    <div class="form-group">
                        <label>Tarif per Jam (Rp)</label>
                        <input type="number" name="rate" class="form-control" placeholder="Contoh: 50000" required>
                    </div>
                    <div class="form-group">
                        <label>Status</label>
                        <select name="status" class="form-control" required>
                            <option value="AVAILABLE">Tersedia</option>
                            <option value="MAINTENANCE">Maintenance</option>
                        </select>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline" onclick="closeModal('addRoomModal')">Batal</button>
                    <button type="submit" class="btn btn-primary">Simpan</button>
                </div>
            </form>
        </div>
    </div>
    
    <!-- Modal: Edit Room -->
    <div id="editRoomModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h3><i class="fas fa-edit"></i> Edit Ruangan</h3>
                <button class="modal-close" onclick="closeModal('editRoomModal')"><i class="fas fa-times"></i></button>
            </div>
            <form action="proses/edit_room.jsp" method="post">
                <div class="modal-body">
                    <input type="hidden" name="id" id="editRoomId">
                    <div class="form-group">
                        <label>Nama Ruangan</label>
                        <input type="text" name="name" id="editRoomName" class="form-control" required>
                    </div>
                    <div class="form-group">
                        <label>Kapasitas</label>
                        <input type="number" name="capacity" id="editRoomCapacity" class="form-control" required>
                    </div>
                    <div class="form-group">
                        <label>Tarif per Jam (Rp)</label>
                        <input type="number" name="rate" id="editRoomRate" class="form-control" required>
                    </div>
                    <div class="form-group">
                        <label>Status</label>
                        <select name="status" id="editRoomStatus" class="form-control" required>
                            <option value="AVAILABLE">Tersedia</option>
                            <option value="IN_USE">Sedang Digunakan</option>
                            <option value="MAINTENANCE">Maintenance</option>
                        </select>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline" onclick="closeModal('editRoomModal')">Batal</button>
                    <button type="submit" class="btn btn-primary">Update</button>
                </div>
            </form>
        </div>
    </div>
    
    <!-- Modal: Add Operator -->
    <div id="addOperatorModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h3><i class="fas fa-user-plus"></i> Tambah Operator</h3>
                <button class="modal-close" onclick="closeModal('addOperatorModal')"><i class="fas fa-times"></i></button>
            </div>
            <form action="proses/add_operator.jsp" method="post">
                <div class="modal-body">
                    <div class="form-group">
                        <label>Nama Lengkap</label>
                        <input type="text" name="name" class="form-control" placeholder="Nama lengkap" required>
                    </div>
                    <div class="form-group">
                        <label>Username</label>
                        <input type="text" name="username" class="form-control" placeholder="Username untuk login" required>
                    </div>
                    <div class="form-group">
                        <label>Password</label>
                        <input type="password" name="password" class="form-control" placeholder="Password" required>
                    </div>
                    <div class="form-group">
                        <label>Email</label>
                        <input type="email" name="email" class="form-control" placeholder="Email" required>
                    </div>
                    <div class="form-group">
                        <label>No. Telepon</label>
                        <input type="text" name="phone" class="form-control" placeholder="No. telepon" required>
                    </div>
                    <div class="form-group">
                        <label>Shift</label>
                        <select name="shift" class="form-control" required>
                            <option value="Pagi">Pagi (08:00 - 16:00)</option>
                            <option value="Siang">Siang (12:00 - 20:00)</option>
                            <option value="Malam">Malam (16:00 - 00:00)</option>
                        </select>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline" onclick="closeModal('addOperatorModal')">Batal</button>
                    <button type="submit" class="btn btn-primary">Simpan</button>
                </div>
            </form>
        </div>
    </div>
    
    <!-- Modal: Edit Operator -->
    <div id="editOperatorModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h3><i class="fas fa-edit"></i> Edit Operator</h3>
                <button class="modal-close" onclick="closeModal('editOperatorModal')"><i class="fas fa-times"></i></button>
            </div>
            <form action="proses/edit_operator.jsp" method="post">
                <div class="modal-body">
                    <input type="hidden" name="id" id="editOperatorId">
                    <div class="form-group">
                        <label>Nama Lengkap</label>
                        <input type="text" name="name" id="editOperatorName" class="form-control" required>
                    </div>
                    <div class="form-group">
                        <label>Username</label>
                        <input type="text" name="username" id="editOperatorUsername" class="form-control" required>
                    </div>
                    <div class="form-group">
                        <label>Email</label>
                        <input type="email" name="email" id="editOperatorEmail" class="form-control" required>
                    </div>
                    <div class="form-group">
                        <label>No. Telepon</label>
                        <input type="text" name="phone" id="editOperatorPhone" class="form-control" required>
                    </div>
                    <div class="form-group">
                        <label>Shift</label>
                        <select name="shift" id="editOperatorShift" class="form-control" required>
                            <option value="Pagi">Pagi (08:00 - 16:00)</option>
                            <option value="Siang">Siang (12:00 - 20:00)</option>
                            <option value="Malam">Malam (16:00 - 00:00)</option>
                        </select>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline" onclick="closeModal('editOperatorModal')">Batal</button>
                    <button type="submit" class="btn btn-primary">Update</button>
                </div>
            </form>
        </div>
    </div>
    
    <script>
        function openModal(modalId) {
            document.getElementById(modalId).classList.add('active');
        }
        
        function closeModal(modalId) {
            document.getElementById(modalId).classList.remove('active');
        }
        
        // --- LOGIC EDIT (DIPERBAIKI & DILENGKAPI) ---
        
        function editConsole(id, type, rate, status) {
            document.getElementById('editConsoleId').value = id;
            document.getElementById('editConsoleType').value = type;
            document.getElementById('editConsoleRate').value = rate;
            document.getElementById('editConsoleStatus').value = status;
            openModal('editConsoleModal');
        }
        
        function editRoom(id, name, capacity, rate, status) {
            document.getElementById('editRoomId').value = id;
            document.getElementById('editRoomName').value = name;
            document.getElementById('editRoomCapacity').value = capacity;
            document.getElementById('editRoomRate').value = rate;
            document.getElementById('editRoomStatus').value = status;
            openModal('editRoomModal');
        }
        
        function editOperator(id, name, username, email, phone, shift) {
            document.getElementById('editOperatorId').value = id;
            document.getElementById('editOperatorName').value = name;
            document.getElementById('editOperatorUsername').value = username;
            document.getElementById('editOperatorEmail').value = email;
            document.getElementById('editOperatorPhone').value = phone;
            document.getElementById('editOperatorShift').value = shift;
            openModal('editOperatorModal');
        }
        
        // Close modal on outside click
        window.onclick = function(event) {
            if (event.target.classList.contains('modal')) {
                event.target.classList.remove('active');
            }
        }
    </script>
</body>
</html>

<!-- LAST ATTEMPT COPY -->