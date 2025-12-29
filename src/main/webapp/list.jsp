<%@page import="java.sql.*"%>
<%@page import="com.mycompany.db.dbcconnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Daftar Produk</title>
    <style>
        table, th, td {
            border: 1px solid black;
            border-collapse: collapse;
            padding: 8px;
        }
        th {
            background-color: #f2f2f2;
        }
    </style>
</head>
<body>
    <h1>Daftar Produk Tokoku</h1>
    <p><a href="add.jsp">Tambah Produk Baru</a></p>
    <hr>

    <table>
        <thead>
            <tr>
                <th>ID</th>
                <th>Nama Produk</th>
                <th>Harga</th>
            </tr>
        </thead>
        <tbody>
        <% 
            Connection conn = null;
            Statement stmt = null;
            ResultSet rs = null;
            
            try {
                conn = dbcconnection.getConnection();
                stmt = conn.createStatement();
                String sql = "SELECT id, nama, harga FROM produk ORDER BY id DESC";
                rs = stmt.executeQuery(sql);
                
                // Iterasi dan tampilkan data
                while (rs.next()) {
        %>
            <tr>
                <td><%= rs.getInt("id") %></td>
                <td><%= rs.getString("nama") %></td>
                <td>Rp <%= rs.getInt("harga") %></td>
            </tr>
        <% 
                }
            } catch (SQLException e) {
                out.println("<tr><td colspan='3' style='color:red;'>Error saat mengambil data: " + e.getMessage() + "</td></tr>");
            } finally {
                // Tutup koneksi
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            }
        %>
        </tbody>
    </table>
</body>
</html>