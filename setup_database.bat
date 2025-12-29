@echo off
echo ========================================
echo   PSRent Max - Database Setup
echo ========================================
echo.
echo Membuat database tubespbo...
echo.

REM Cari MySQL di XAMPP
set MYSQL_PATH=C:\xampp\mysql\bin\mysql.exe

if not exist "%MYSQL_PATH%" (
    echo ERROR: MySQL tidak ditemukan di C:\xampp\mysql\bin\
    echo Pastikan XAMPP sudah terinstall!
    pause
    exit /b 1
)

REM Import database
echo Mengimport database_setup.sql...
"%MYSQL_PATH%" -u root --port=3307 < database_setup.sql

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo   DATABASE BERHASIL DIBUAT!
    echo ========================================
    echo.
    echo Database: tubespbo
    echo Port: 3307
    echo User: root
    echo Password: (kosong)
    echo.
    echo Akun Login Aplikasi:
    echo - Admin: admin / admin123
    echo - Operator: operator / op123
    echo.
) else (
    echo.
    echo ========================================
    echo   ERROR: Import database gagal!
    echo ========================================
    echo.
    echo Pastikan:
    echo 1. MySQL XAMPP sudah running
    echo 2. Port 3307 benar (cek di XAMPP Config)
    echo 3. File database_setup.sql ada
    echo.
)

pause
