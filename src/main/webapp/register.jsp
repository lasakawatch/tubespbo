<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PSRent Max - Register Operator</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Poppins', sans-serif;
        }

        body {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
            overflow-y: auto;
            padding: 20px;
        }

        /* Animated Background */
        .bg-animation {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            overflow: hidden;
            z-index: 0;
        }

        .bg-animation span {
            position: absolute;
            display: block;
            width: 20px;
            height: 20px;
            background: rgba(255, 255, 255, 0.1);
            animation: move 25s linear infinite;
            bottom: -150px;
        }

        .bg-animation span:nth-child(1) { left: 25%; width: 80px; height: 80px; animation-delay: 0s; }
        .bg-animation span:nth-child(2) { left: 10%; width: 20px; height: 20px; animation-delay: 2s; }
        .bg-animation span:nth-child(3) { left: 70%; width: 20px; height: 20px; animation-delay: 4s; }
        .bg-animation span:nth-child(4) { left: 40%; width: 60px; height: 60px; animation-delay: 0s; }
        .bg-animation span:nth-child(5) { left: 65%; width: 20px; height: 20px; animation-delay: 0s; }
        .bg-animation span:nth-child(6) { left: 75%; width: 110px; height: 110px; animation-delay: 3s; }

        @keyframes move {
            0% { transform: translateY(0) rotate(0deg); opacity: 1; border-radius: 0; }
            100% { transform: translateY(-1000px) rotate(720deg); opacity: 0; border-radius: 50%; }
        }

        /* Register Container */
        .register-container {
            position: relative;
            z-index: 10;
            width: 100%;
            max-width: 500px;
        }

        .register-box {
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(20px);
            border-radius: 20px;
            padding: 40px;
            border: 1px solid rgba(255, 255, 255, 0.2);
            box-shadow: 0 25px 50px rgba(0, 0, 0, 0.3);
            animation: slideUp 0.8s ease-out;
        }

        @keyframes slideUp {
            from { opacity: 0; transform: translateY(50px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* Logo */
        .logo {
            text-align: center;
            margin-bottom: 30px;
        }

        .logo-icon {
            width: 70px;
            height: 70px;
            background: linear-gradient(135deg, #2ed573, #7bed9f);
            border-radius: 18px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 15px;
            animation: pulse 2s infinite;
        }

        @keyframes pulse {
            0%, 100% { transform: scale(1); box-shadow: 0 0 0 0 rgba(46, 213, 115, 0.4); }
            50% { transform: scale(1.05); box-shadow: 0 0 20px 10px rgba(46, 213, 115, 0); }
        }

        .logo-icon i {
            font-size: 35px;
            color: white;
        }

        .logo h1 {
            color: white;
            font-size: 24px;
            font-weight: 700;
        }

        .logo p {
            color: rgba(255, 255, 255, 0.7);
            font-size: 14px;
            margin-top: 5px;
        }

        /* Form */
        .form-group {
            margin-bottom: 18px;
        }

        .form-group label {
            display: block;
            color: rgba(255, 255, 255, 0.8);
            font-size: 14px;
            margin-bottom: 8px;
            font-weight: 500;
        }

        .input-wrapper {
            position: relative;
        }

        .input-wrapper i {
            position: absolute;
            left: 15px;
            top: 50%;
            transform: translateY(-50%);
            color: rgba(255, 255, 255, 0.5);
            transition: color 0.3s;
        }

        .form-group input {
            width: 100%;
            padding: 14px 14px 14px 45px;
            background: rgba(255, 255, 255, 0.1);
            border: 2px solid rgba(255, 255, 255, 0.1);
            border-radius: 12px;
            color: white;
            font-size: 14px;
            transition: all 0.3s ease;
        }

        .form-group input::placeholder {
            color: rgba(255, 255, 255, 0.4);
        }

        .form-group input:focus {
            outline: none;
            border-color: #2ed573;
            background: rgba(255, 255, 255, 0.15);
            box-shadow: 0 0 20px rgba(46, 213, 115, 0.3);
        }

        /* Buttons */
        .btn {
            width: 100%;
            padding: 14px;
            border: none;
            border-radius: 12px;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            margin-bottom: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            text-decoration: none;
        }

        .btn-primary {
            background: linear-gradient(135deg, #2ed573, #7bed9f);
            color: white;
            box-shadow: 0 10px 30px rgba(46, 213, 115, 0.4);
        }

        .btn-primary:hover {
            transform: translateY(-3px);
            box-shadow: 0 15px 40px rgba(46, 213, 115, 0.5);
        }

        .btn-secondary {
            background: rgba(255, 255, 255, 0.1);
            color: white;
            border: 2px solid rgba(255, 255, 255, 0.2);
        }

        .btn-secondary:hover {
            background: rgba(255, 255, 255, 0.2);
        }

        /* Alert */
        .alert {
            padding: 14px;
            border-radius: 12px;
            margin-bottom: 18px;
            display: flex;
            align-items: center;
            gap: 10px;
            animation: shake 0.5s ease-out;
        }

        @keyframes shake {
            0%, 100% { transform: translateX(0); }
            10%, 30%, 50%, 70%, 90% { transform: translateX(-5px); }
            20%, 40%, 60%, 80% { transform: translateX(5px); }
        }

        .alert-error {
            background: rgba(255, 71, 87, 0.2);
            border: 1px solid rgba(255, 71, 87, 0.5);
            color: #ff6b6b;
        }

        .alert-success {
            background: rgba(46, 213, 115, 0.2);
            border: 1px solid rgba(46, 213, 115, 0.5);
            color: #2ed573;
        }

        /* Loading */
        .loading {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.8);
            z-index: 1000;
            align-items: center;
            justify-content: center;
        }

        .loading.active {
            display: flex;
        }

        .loading-spinner {
            width: 60px;
            height: 60px;
            border: 5px solid rgba(255, 255, 255, 0.1);
            border-top-color: #2ed573;
            border-radius: 50%;
            animation: spin 1s linear infinite;
        }

        @keyframes spin {
            to { transform: rotate(360deg); }
        }
    </style>
</head>
<body>
    <!-- Background Animation -->
    <div class="bg-animation">
        <span></span><span></span><span></span>
        <span></span><span></span><span></span>
    </div>

    <!-- Register Container -->
    <div class="register-container">
        <div class="register-box">
            <!-- Logo -->
            <div class="logo">
                <div class="logo-icon">
                    <i class="fas fa-user-plus"></i>
                </div>
                <h1>Daftar Operator Baru</h1>
                <p>Lengkapi data untuk membuat akun operator</p>
            </div>

            <!-- Alert Messages -->
            <% String error = request.getParameter("error"); %>
            <% if (error != null && !error.isEmpty()) { %>
                <div class="alert alert-error">
                    <i class="fas fa-exclamation-circle"></i>
                    <span>
                        <% if (error.equals("exists")) { %>
                            Username sudah digunakan!
                        <% } else if (error.equals("empty")) { %>
                            Mohon isi semua field!
                        <% } else if (error.equals("failed")) { %>
                            Gagal mendaftarkan operator!
                        <% } else { %>
                            <%= error %>
                        <% } %>
                    </span>
                </div>
            <% } %>

            <!-- Register Form -->
            <form action="proses_register.jsp" method="POST" id="registerForm">
                <div class="form-group">
                    <label for="name">Nama Lengkap</label>
                    <div class="input-wrapper">
                        <input type="text" id="name" name="name" placeholder="Masukkan nama lengkap" required>
                        <i class="fas fa-user"></i>
                    </div>
                </div>

                <div class="form-group">
                    <label for="phone">Nomor HP</label>
                    <div class="input-wrapper">
                        <input type="tel" id="phone" name="phone" placeholder="Contoh: 08123456789" required>
                        <i class="fas fa-phone"></i>
                    </div>
                </div>

                <div class="form-group">
                    <label for="address">Alamat</label>
                    <div class="input-wrapper">
                        <input type="text" id="address" name="address" placeholder="Masukkan alamat" required>
                        <i class="fas fa-map-marker-alt"></i>
                    </div>
                </div>

                <div class="form-group">
                    <label for="username">Username</label>
                    <div class="input-wrapper">
                        <input type="text" id="username" name="username" placeholder="Buat username" required>
                        <i class="fas fa-at"></i>
                    </div>
                </div>

                <div class="form-group">
                    <label for="password">Password</label>
                    <div class="input-wrapper">
                        <input type="password" id="password" name="password" placeholder="Buat password" required>
                        <i class="fas fa-lock"></i>
                    </div>
                </div>

                <button type="submit" class="btn btn-primary">
                    <i class="fas fa-user-check"></i>
                    Daftar Sekarang
                </button>

                <a href="index.jsp" class="btn btn-secondary">
                    <i class="fas fa-arrow-left"></i>
                    Kembali ke Login
                </a>
            </form>
        </div>
    </div>

    <!-- Loading -->
    <div class="loading" id="loading">
        <div class="loading-spinner"></div>
    </div>

    <script>
        document.getElementById('registerForm').addEventListener('submit', function() {
            document.getElementById('loading').classList.add('active');
        });
    </script>
</body>
</html>

<!-- LAST ATTEMPT COPY -->