<%@ page import="java.sql.*" %>
<%
    String error = "";
    String success = "";
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String firstName = request.getParameter("first_name");
        String lastName  = request.getParameter("last_name");
        String email     = request.getParameter("email");
        String username  = request.getParameter("username");
        String password  = request.getParameter("password");
        String phone     = request.getParameter("phone");

        Connection conn = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/group11", "root", "YOUR_PASSWORD_HERE");

            // Check for duplicate username or email
            String checkSql = "SELECT member_id FROM Members WHERE username = ? OR email = ?";
            PreparedStatement checkPs = conn.prepareStatement(checkSql);
            checkPs.setString(1, username);
            checkPs.setString(2, email);
            ResultSet rs = checkPs.executeQuery();

            if (rs.next()) {
                error = "Username or email already exists. Please choose another.";
            } else {
                String insertSql = "INSERT INTO Members (phone_number, first_name, last_name, username, email, password_hash, date_joined, status) VALUES (?, ?, ?, ?, ?, ?, CURDATE(), 'Active')";
                PreparedStatement insertPs = conn.prepareStatement(insertSql);
                insertPs.setString(1, phone);
                insertPs.setString(2, firstName);
                insertPs.setString(3, lastName);
                insertPs.setString(4, username);
                insertPs.setString(5, email);
                insertPs.setString(6, password);
                insertPs.executeUpdate();
                success = "Account created! You can now log in.";
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
  <title>Register - FitHub</title>
  <style>
    body { font-family: Arial, sans-serif; background: #1a1a1a; color: #fff; display: flex; flex-direction: column; align-items: center; justify-content: center; min-height: 100vh; margin: 0; }
    h2 { color: #e8ff3a; }
    form { display: flex; flex-direction: column; gap: 12px; width: 320px; }
    input { padding: 10px; border-radius: 6px; border: 1px solid #444; background: #2a2a2a; color: #fff; font-size: 1rem; }
    button { padding: 10px; background: #e8ff3a; color: #000; font-weight: bold; border: none; border-radius: 6px; cursor: pointer; font-size: 1rem; }
    .error { color: #ff4444; }
    .success { color: #44ff88; }
    a { color: #e8ff3a; }
  </style>
</head>
<body>
  <h2>Create Account</h2>
  <% if (!error.isEmpty()) { %><p class="error"><%= error %></p><% } %>
  <% if (!success.isEmpty()) { %><p class="success"><%= success %> <a href="member_login.jsp">Login</a></p><% } %>
  <form method="post">
    <input type="text"  name="first_name" placeholder="First Name" required>
    <input type="text"  name="last_name"  placeholder="Last Name"  required>
    <input type="text"  name="phone"      placeholder="Phone Number">
    <input type="email" name="email"      placeholder="Email"       required>
    <input type="text"  name="username"   placeholder="Username"    required>
    <input type="password" name="password" placeholder="Password"   required>
    <button type="submit">Register</button>
  </form>
  <br>
  <p><a href="member_login.jsp">Back to Login</a></p>
</body>
</html>
