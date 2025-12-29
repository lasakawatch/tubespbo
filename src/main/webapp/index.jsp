<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PSRent Max - Login</title>
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
            overflow: hidden;
            position: relative;
        }

        /* Animated Background */
        .bg-animation {
            position: absolute;
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
        .bg-animation span:nth-child(2) { left: 10%; width: 20px; height: 20px; animation-delay: 2s; animation-duration: 12s; }
        .bg-animation span:nth-child(3) { left: 70%; width: 20px; height: 20px; animation-delay: 4s; }
        .bg-animation span:nth-child(4) { left: 40%; width: 60px; height: 60px; animation-delay: 0s; animation-duration: 18s; }
        .bg-animation span:nth-child(5) { left: 65%; width: 20px; height: 20px; animation-delay: 0s; }
        .bg-animation span:nth-child(6) { left: 75%; width: 110px; height: 110px; animation-delay: 3s; }
        .bg-animation span:nth-child(7) { left: 35%; width: 150px; height: 150px; animation-delay: 7s; }
        .bg-animation span:nth-child(8) { left: 50%; width: 25px; height: 25px; animation-delay: 15s; animation-duration: 45s; }
        .bg-animation span:nth-child(9) { left: 20%; width: 15px; height: 15px; animation-delay: 2s; animation-duration: 35s; }
        .bg-animation span:nth-child(10) { left: 85%; width: 150px; height: 150px; animation-delay: 0s; animation-duration: 11s; }

        @keyframes move {
            0% {
                transform: translateY(0) rotate(0deg);
                opacity: 1;
                border-radius: 0;
            }
            100% {
                transform: translateY(-1000px) rotate(720deg);
                opacity: 0;
                border-radius: 50%;
            }
        }

        /* Floating PlayStation Icons */
        .ps-icons {
            position: absolute;
            width: 100%;
            height: 100%;
            overflow: hidden;
            z-index: 1;
        }

        .ps-icon {
            position: absolute;
            font-size: 40px;
            color: rgba(255, 255, 255, 0.1);
            animation: float 15s ease-in-out infinite;
        }

        .ps-icon:nth-child(1) { top: 10%; left: 10%; animation-delay: 0s; }
        .ps-icon:nth-child(2) { top: 20%; right: 15%; animation-delay: 2s; }
        .ps-icon:nth-child(3) { bottom: 20%; left: 5%; animation-delay: 4s; }
        .ps-icon:nth-child(4) { bottom: 30%; right: 10%; animation-delay: 1s; }
        .ps-icon:nth-child(5) { top: 50%; left: 2%; animation-delay: 3s; }
        .ps-icon:nth-child(6) { top: 70%; right: 5%; animation-delay: 5s; }

        @keyframes float {
            0%, 100% { transform: translateY(0px) rotate(0deg); }
            25% { transform: translateY(-20px) rotate(5deg); }
            50% { transform: translateY(0px) rotate(0deg); }
            75% { transform: translateY(20px) rotate(-5deg); }
        }

        /* Login Container */
        .login-container {
            position: relative;
            z-index: 10;
            width: 100%;
            max-width: 450px;
            padding: 20px;
        }

        .login-box {
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(20px);
            border-radius: 20px;
            padding: 40px;
            border: 1px solid rgba(255, 255, 255, 0.2);
            box-shadow: 0 25px 50px rgba(0, 0, 0, 0.3);
            animation: slideUp 0.8s ease-out;
        }

        @keyframes slideUp {
            from {
                opacity: 0;
                transform: translateY(50px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* Logo */
        .logo {
            text-align: center;
            margin-bottom: 30px;
        }

        .logo-icon {
            width: 80px;
            height: 80px;
            background: linear-gradient(135deg, #e94560, #ff6b6b);
            border-radius: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 15px;
            animation: pulse 2s infinite;
        }

        @keyframes pulse {
            0%, 100% { transform: scale(1); box-shadow: 0 0 0 0 rgba(233, 69, 96, 0.4); }
            50% { transform: scale(1.05); box-shadow: 0 0 20px 10px rgba(233, 69, 96, 0); }
        }

        .logo-icon i {
            font-size: 40px;
            color: white;
        }

        .logo h1 {
            color: white;
            font-size: 28px;
            font-weight: 700;
            text-shadow: 2px 2px 10px rgba(0, 0, 0, 0.3);
        }

        .logo p {
            color: rgba(255, 255, 255, 0.7);
            font-size: 14px;
            margin-top: 5px;
        }

        /* Form */
        .form-group {
            margin-bottom: 20px;
            position: relative;
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

        .form-group input,
        .form-group select {
            width: 100%;
            padding: 15px 15px 15px 45px;
            background: rgba(255, 255, 255, 0.1);
            border: 2px solid rgba(255, 255, 255, 0.1);
            border-radius: 12px;
            color: white;
            font-size: 15px;
            transition: all 0.3s ease;
        }

        .form-group input::placeholder {
            color: rgba(255, 255, 255, 0.4);
        }

        .form-group input:focus,
        .form-group select:focus {
            outline: none;
            border-color: #e94560;
            background: rgba(255, 255, 255, 0.15);
            box-shadow: 0 0 20px rgba(233, 69, 96, 0.3);
        }

        .form-group input:focus + i,
        .form-group select:focus + i {
            color: #e94560;
        }

        .form-group select {
            cursor: pointer;
            appearance: none;
        }

        .form-group select option {
            background: #1a1a2e;
            color: white;
        }

        /* Buttons */
        .btn {
            width: 100%;
            padding: 15px;
            border: none;
            border-radius: 12px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
        }

        .btn-primary {
            background: linear-gradient(135deg, #e94560, #ff6b6b);
            color: white;
            box-shadow: 0 10px 30px rgba(233, 69, 96, 0.4);
        }

        .btn-primary:hover {
            transform: translateY(-3px);
            box-shadow: 0 15px 40px rgba(233, 69, 96, 0.5);
        }

        .btn-primary:active {
            transform: translateY(0);
        }

        .btn-secondary {
            background: rgba(255, 255, 255, 0.1);
            color: white;
            border: 2px solid rgba(255, 255, 255, 0.2);
        }

        .btn-secondary:hover {
            background: rgba(255, 255, 255, 0.2);
            border-color: rgba(255, 255, 255, 0.3);
        }

        /* Alert Messages */
        .alert {
            padding: 15px;
            border-radius: 12px;
            margin-bottom: 20px;
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

        /* Footer */
        .footer {
            text-align: center;
            margin-top: 20px;
            color: rgba(255, 255, 255, 0.5);
            font-size: 13px;
        }

        .footer a {
            color: #e94560;
            text-decoration: none;
        }

        /* Loading Animation */
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
            border-top-color: #e94560;
            border-radius: 50%;
            animation: spin 1s linear infinite;
        }

        @keyframes spin {
            to { transform: rotate(360deg); }
        }

        /* Responsive */
        @media (max-width: 480px) {
            .login-box {
                padding: 30px 20px;
            }
            
            .logo h1 {
                font-size: 24px;
            }
        }
    </style>
</head>
<body>
    <!-- Background Animation -->
    <div class="bg-animation">
        <span></span>
        <span></span>
        <span></span>
        <span></span>
        <span></span>
        <span></span>
        <span></span>
        <span></span>
        <span></span>
        <span></span>
    </div>

    <!-- PlayStation Icons -->
    <div class="ps-icons">
        <i class="fa-brands fa-playstation ps-icon"></i>
        <i class="fas fa-gamepad ps-icon"></i>
        <i class="fa-brands fa-playstation ps-icon"></i>
        <i class="fas fa-gamepad ps-icon"></i>
        <i class="fa-brands fa-playstation ps-icon"></i>
        <i class="fas fa-gamepad ps-icon"></i>
    </div>

    <!-- Login Container -->
    <div class="login-container">
        <div class="login-box">
            <!-- Logo -->
            <div class="logo">
                <div class="logo-icon">
                    <i class="fa-brands fa-playstation"></i>
                </div>
                <h1>PSRent Max</h1>
                <p>Sistem Manajemen Rental PlayStation</p>
            </div>

            <!-- Alert Messages -->
            <% String error = request.getParameter("error"); %>
            <% String success = request.getParameter("success"); %>
            
            <% if (error != null && !error.isEmpty()) { %>
                <div class="alert alert-error">
                    <i class="fas fa-exclamation-circle"></i>
                    <span>
                        <% if (error.equals("invalid")) { %>
                            Username atau password salah!
                        <% } else if (error.equals("empty")) { %>
                            Mohon isi semua field!
                        <% } else { %>
                            <%= error %>
                        <% } %>
                    </span>
                </div>
            <% } %>
            
            <% if (success != null && !success.isEmpty()) { %>
                <div class="alert alert-success">
                    <i class="fas fa-check-circle"></i>
                    <span><%= success %></span>
                </div>
            <% } %>

            <!-- Login Form -->
            <form action="proses_login.jsp" method="POST" id="loginForm">
                <div class="form-group">
                    <label for="username">Username</label>
                    <div class="input-wrapper">
                        <input type="text" id="username" name="username" placeholder="Masukkan username" required>
                        <i class="fas fa-user"></i>
                    </div>
                </div>

                <div class="form-group">
                    <label for="password">Password</label>
                    <div class="input-wrapper">
                        <input type="password" id="password" name="password" placeholder="Masukkan password" required>
                        <i class="fas fa-lock"></i>
                    </div>
                </div>

                <div class="form-group">
                    <label for="role">Login Sebagai</label>
                    <div class="input-wrapper">
                        <select id="role" name="role" required>
                            <option value="OPERATOR">Operator</option>
                            <option value="ADMIN">Admin</option>
                        </select>
                        <i class="fas fa-user-tag"></i>
                    </div>
                </div>

                <button type="submit" class="btn btn-primary">
                    <i class="fas fa-sign-in-alt"></i>
                    Login
                </button>

                <a href="register.jsp" class="btn btn-secondary">
                    <i class="fas fa-user-plus"></i>
                    Daftar Operator Baru
                </a>
            </form>

            <!-- Footer -->
            <div class="footer">
                <p>&copy; 2025 PSRent Max - Kelompok 6</p>
                <p>Muhammad Rafadi | Aditya Attabby | Naufal Saifullah</p>
            </div>
        </div>
    </div>

    <!-- Loading -->
    <div class="loading" id="loading">
        <div class="loading-spinner"></div>
    </div>

    <script>
        // Show loading on form submit
        document.getElementById('loginForm').addEventListener('submit', function() {
            document.getElementById('loading').classList.add('active');
        });

        // Add input animation
        const inputs = document.querySelectorAll('input, select');
        inputs.forEach(input => {
            input.addEventListener('focus', function() {
                this.parentElement.parentElement.classList.add('focused');
            });
            input.addEventListener('blur', function() {
                this.parentElement.parentElement.classList.remove('focused');
            });
        });
    </script>
</body>
</html>

<!-- LAST ATTEMPT COPY -->