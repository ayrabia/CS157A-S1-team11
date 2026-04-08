<%@ page import="java.sql.*" %>
<%@ page session="true" %>
<%
    String error = "";
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        Connection conn = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/group11", "root", "YOUR_PASSWORD_HERE");

            String sql = "SELECT staff_id, first_name, role FROM Staff WHERE username = ? AND password_hash = ? AND status = 'Active'";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, username);
            ps.setString(2, password);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                session.setAttribute("staff_id", rs.getInt("staff_id"));
                session.setAttribute("staff_name", rs.getString("first_name"));
                session.setAttribute("staff_role", rs.getString("role"));
                response.sendRedirect("staff_dashboard.jsp");
                return;
            } else {
                error = "Invalid credentials or inactive account.";
            }
        } catch (Exception e) {
            error = "Database error: " + e.getMessage();
        } finally {
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Staff Login - FitHub</title>
  <style>
    body { font-family: Arial, sans-serif; background: #1a1a1a; color: #fff; display: flex; flex-direction: column; align-items: center; justify-content: center; height: 100vh; margin: 0; }
    h2 { color: #e8ff3a; }
    form { display: flex; flex-direction: column; gap: 12px; width: 300px; }
    input { padding: 10px; border-radius: 6px; border: 1px solid #444; background: #2a2a2a; color: #fff; font-size: 1rem; }
    button { padding: 10px; background: #e8ff3a; color: #000; font-weight: bold; border: none; border-radius: 6px; cursor: pointer; font-size: 1rem; }
    .error { color: #ff4444; }
    a { color: #e8ff3a; }
  </style>
</head>
<body>
  <h2>Staff Login</h2>
  <% if (!error.isEmpty()) { %><p class="error"><%= error %></p><% } %>
  <form method="post">
    <input type="text" name="username" placeholder="Username" required>
    <input type="password" name="password" placeholder="Password" required>
    <button type="submit">Login</button>
  </form>
  <br>
  <p><a href="index.html">Back</a></p>
</body>
</html>
