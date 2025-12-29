<%@page import="java.sql.*"%>
<%@page import="com.mycompany.db.dbcconnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Input Produk</title>
</head>
<body>
    <h1>Tambah Produk Baru</h1>

    <%
        // 1. Cek apakah ada data yang di-submit (POST request)
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String nama = request.getParameter("nama");
            String hargaStr = request.getParameter("harga");
            int harga = 0;
            String pesan = "";
            
            // Validasi input
            if (nama == null || nama.trim().isEmpty() || hargaStr == null || hargaStr.trim().isEmpty()) {
                pesan = "<p style='color:red;'>Nama dan Harga tidak boleh kosong!</p>";
            } else {
                try {
                    harga = Integer.parseInt(hargaStr);
                    
                    // 2. Lakukan Operasi JDBC
                    Connection conn = null;
                    PreparedStatement pstmt = null;
                    
                    try {
                        conn = dbcconnection.getConnection();
                        String sql = "INSERT INTO produk (nama, harga) VALUES (?, ?)";
                        pstmt = conn.prepareStatement(sql);
                        
                        pstmt.setString(1, nama);
                        pstmt.setInt(2, harga);
                        
                        int rowsAffected = pstmt.executeUpdate();
                        
                        if (rowsAffected > 0) {
                            pesan = "<p style='color:green;'>Data produk **" + nama + "** berhasil disimpan!</p>";
                        } else {
                            pesan = "<p style='color:red;'>Gagal menyimpan data.</p>";
                        }
                    } catch (SQLException e) {
                        pesan = "<p style='color:red;'>Error Database: " + e.getMessage() + "</p>";
                    } finally {
                        // Tutup koneksi
                        if (pstmt != null) pstmt.close();
                        if (conn != null) conn.close();
                    }
                    
                } catch (NumberFormatException e) {
                    pesan = "<p style='color:red;'>Harga harus berupa angka!</p>";
                }
            }
            // Tampilkan pesan setelah submission
            out.print(pesan);
        }
    %>
    
    <form method="POST" action="add.jsp">
        <label for="nama">Nama Produk:</label><br>
        <input type="text" id="nama" name="nama" required><br><br>
        
        <label for="harga">Harga:</label><br>
        <input type="number" id="harga" name="harga" required><br><br>
        
        <input type="submit" value="Simpan Produk">
    </form>
    
    <hr>
    <p><a href="list.jsp">Lihat Daftar Produk</a></p>
</body>
</html>