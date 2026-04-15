<%@ page import="java.sql.*" %>
<%@ page session="true" %>
<%
    if (session.getAttribute("staff_id") == null) {
        response.sendRedirect("staff_login.jsp");
        return;
    }

    String message = "";
    String messageType = "";

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String memberIdStr = request.getParameter("member_id");
        Connection conn = null;
        try {
            int memberId = Integer.parseInt(memberIdStr);
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/group11", "root", "YOUR_PASSWORD_HERE");

            // Verify member exists and is active
            String checkSql = "SELECT first_name, last_name, status FROM Members WHERE member_id = ?";
            PreparedStatement checkPs = conn.prepareStatement(checkSql);
            checkPs.setInt(1, memberId);
            ResultSet rs = checkPs.executeQuery();

            if (!rs.next()) {
                message = "Member ID " + memberId + " not found.";
                messageType = "error";
            } else if (!"Active".equals(rs.getString("status"))) {
                message = rs.getString("first_name") + " " + rs.getString("last_name") +
                          " has an inactive membership. Entry denied.";
                messageType = "error";
            } else {
                String name = rs.getString("first_name") + " " + rs.getString("last_name");
                // Record check-in
                String insertSql = "INSERT INTO AttendanceLog (member_id, check_in_time) VALUES (?, NOW())";
                PreparedStatement insertPs = conn.prepareStatement(insertSql);
                insertPs.setInt(1, memberId);
                insertPs.executeUpdate();
                message = "Check-in recorded for " + name + ".";
                messageType = "success";
            }
        } catch (NumberFormatException e) {
            message = "Please enter a valid Member ID.";
            messageType = "error";
        } catch (Exception e) {
            message = "Database error: " + e.getMessage();
            messageType = "error";
        } finally {
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Check In Member - FitHub</title>
  <style>
    body { font-family: Arial, sans-serif; background: #1a1a1a; color: #fff; display: flex; flex-direction: column; align-items: center; justify-content: center; height: 100vh; margin: 0; }
    h2 { color: #e8ff3a; }
    form { display: flex; flex-direction: column; gap: 12px; width: 300px; }
    input { padding: 10px; border-radius: 6px; border: 1px solid #444; background: #2a2a2a; color: #fff; font-size: 1rem; }
    button { padding: 10px; background: #e8ff3a; color: #000; font-weight: bold; border: none; border-radius: 6px; cursor: pointer; font-size: 1rem; }
    .error { color: #ff4444; }
    .success { color: #44ff88; }
    a { color: #e8ff3a; }
  </style>
</head>
<body>
  <h2>Member Check-In</h2>
  <% if (!message.isEmpty()) { %>
    <p class="<%= messageType %>"><%= message %></p>
  <% } %>
  <form method="post">
    <input type="number" name="member_id" placeholder="Enter Member ID" required>
    <button type="submit">Check In</button>
  </form>
  <br>
  <a href="staff_dashboard.jsp">Back to Dashboard</a>
</body>
</html>
