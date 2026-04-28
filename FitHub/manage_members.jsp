<%@ page import="java.sql.*" %>
<%@ page session="true" %>
<%
    // Staff-only page for managing member accounts.
    // Supports walk-in registration, freezing active memberships, and reactivating frozen ones.
    if (session.getAttribute("staff_id") == null) {
        response.sendRedirect("staff_login.jsp");
        return;
    }

    String message = "";
    String messageType = "";

    Connection conn = null;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/group11", "root", "");

        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String action = request.getParameter("action");

            if ("freeze".equals(action)) {
                // Freeze the member account — blocks login and check-in
                String updateSql = "UPDATE Members SET status = 'Frozen' WHERE member_id = ? AND status = 'Active'";
                PreparedStatement updatePs = conn.prepareStatement(updateSql);
                updatePs.setInt(1, Integer.parseInt(request.getParameter("member_id")));
                int rows = updatePs.executeUpdate();
                message = rows > 0 ? "Account frozen." : "Account is already frozen or not found.";
                messageType = rows > 0 ? "success" : "error";

            } else if ("reactivate".equals(action)) {
                // Reactivate the member account — restores login and check-in access
                String updateSql = "UPDATE Members SET status = 'Active' WHERE member_id = ? AND status = 'Frozen'";
                PreparedStatement updatePs = conn.prepareStatement(updateSql);
                updatePs.setInt(1, Integer.parseInt(request.getParameter("member_id")));
                int rows = updatePs.executeUpdate();
                message = rows > 0 ? "Account reactivated." : "Account is already active or not found.";
                messageType = rows > 0 ? "success" : "error";

            } else if ("walkin".equals(action)) {
                // Walk-in registration: staff creates a member account on the spot
                String username = request.getParameter("username");
                String email    = request.getParameter("email");

                // Reject duplicate username or email
                String checkSql = "SELECT member_id FROM Members WHERE username = ? OR email = ?";
                PreparedStatement checkPs = conn.prepareStatement(checkSql);
                checkPs.setString(1, username);
                checkPs.setString(2, email);
                ResultSet checkRs = checkPs.executeQuery();

                if (checkRs.next()) {
                    message = "Username or email already exists.";
                    messageType = "error";
                } else {
                    // Generate next member_id since the table has no AUTO_INCREMENT
                    ResultSet idRs = conn.prepareStatement(
                        "SELECT COALESCE(MAX(member_id), 0) + 1 AS next_id FROM Members"
                    ).executeQuery();
                    idRs.next();
                    int nextId = idRs.getInt("next_id");

                    String insertSql = "INSERT INTO Members (member_id, phone_number, first_name, last_name, username, email, password_hash, date_joined, status) VALUES (?, ?, ?, ?, ?, ?, ?, CURDATE(), 'Active')";
                    PreparedStatement insertPs = conn.prepareStatement(insertSql);
                    insertPs.setInt(1, nextId);
                    insertPs.setString(2, request.getParameter("phone"));
                    insertPs.setString(3, request.getParameter("first_name"));
                    insertPs.setString(4, request.getParameter("last_name"));
                    insertPs.setString(5, username);
                    insertPs.setString(6, email);
                    insertPs.setString(7, request.getParameter("password"));
                    insertPs.executeUpdate();
                    message = "Walk-in member registered. Member ID: " + nextId;
                    messageType = "success";
                }
            }
        }

        // Load all members joined with their most recent membership status
        ResultSet members = conn.prepareStatement(
            "SELECT m.member_id, m.first_name, m.last_name, m.email, m.status AS account_status, " +
            "COALESCE(ms.status, 'No Membership') AS membership_status " +
            "FROM Members m " +
            "LEFT JOIN Membership ms ON m.member_id = ms.member_id " +
            "   AND ms.membership_id = (SELECT MAX(membership_id) FROM Membership WHERE member_id = m.member_id) " +
            "ORDER BY m.member_id"
        ).executeQuery();
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Manage Members - FitHub</title>
  <style>
    body { font-family: Arial, sans-serif; background: #1a1a1a; color: #fff; margin: 0; padding: 2rem; }
    h1, h2 { color: #e8ff3a; }
    table { width: 100%; border-collapse: collapse; margin-bottom: 2rem; }
    th { background: #2a2a2a; color: #e8ff3a; padding: 10px; text-align: left; }
    td { padding: 10px; border-bottom: 1px solid #333; }
    input[type=text], input[type=email], input[type=password] { padding: 8px; border-radius: 6px; border: 1px solid #444; background: #333; color: #fff; font-size: 0.9rem; width: 100%; box-sizing: border-box; margin-bottom: 8px; }
    button { padding: 7px 14px; border: none; border-radius: 6px; cursor: pointer; font-weight: bold; font-size: 0.9rem; }
    .btn-yellow { background: #e8ff3a; color: #000; }
    .btn-red { background: #ff4444; color: #fff; }
    .btn-green { background: #44ff88; color: #000; }
    .walkin-form { background: #2a2a2a; border-radius: 10px; padding: 1.5rem; max-width: 380px; margin-bottom: 2rem; display: flex; flex-direction: column; }
    .success { color: #44ff88; }
    .error { color: #ff4444; }
    a { color: #e8ff3a; }
    .ms-active { color: #44ff88; }
    .ms-frozen { color: #aaaaff; }
    .ms-none { color: #888; }
    form.inline { display: inline; }
  </style>
</head>
<body>
  <h1>Manage Members</h1>
  <% if (!message.isEmpty()) { %><p class="<%= messageType %>"><%= message %></p><% } %>

  <h2>Walk-In Registration</h2>
  <div class="walkin-form">
    <form method="post">
      <input type="hidden"   name="action"     value="walkin">
      <input type="text"     name="first_name" placeholder="First Name"   required>
      <input type="text"     name="last_name"  placeholder="Last Name"    required>
      <input type="text"     name="phone"      placeholder="Phone Number">
      <input type="email"    name="email"      placeholder="Email"        required>
      <input type="text"     name="username"   placeholder="Username"     required>
      <input type="password" name="password"   placeholder="Password"     required>
      <button class="btn-yellow" type="submit">Register Walk-In</button>
    </form>
  </div>

  <h2>All Members</h2>
  <table>
    <tr>
      <th>ID</th><th>Name</th><th>Email</th><th>Account</th><th>Membership</th><th>Actions</th>
    </tr>
    <%
        while (members.next()) {
            int memberId          = members.getInt("member_id");
            String fullName       = members.getString("first_name") + " " + members.getString("last_name");
            String email          = members.getString("email");
            String accountStatus  = members.getString("account_status");
            String membershipStatus = members.getString("membership_status");
            boolean isActive  = "Active".equals(accountStatus);
            boolean isFrozen  = "Frozen".equals(accountStatus);
            String msClass    = "Active".equals(membershipStatus) ? "ms-active" : "Frozen".equals(membershipStatus) ? "ms-frozen" : "ms-none";
    %>
    <tr>
      <td><%= memberId %></td>
      <td><%= fullName %></td>
      <td><%= email %></td>
      <td><%= accountStatus %></td>
      <td class="<%= msClass %>"><%= membershipStatus %></td>
      <td>
        <% if (isActive) { %>
          <form class="inline" method="post">
            <input type="hidden" name="action"    value="freeze">
            <input type="hidden" name="member_id" value="<%= memberId %>">
            <button class="btn-red" type="submit">Freeze</button>
          </form>
        <% } else if (isFrozen) { %>
          <form class="inline" method="post">
            <input type="hidden" name="action"    value="reactivate">
            <input type="hidden" name="member_id" value="<%= memberId %>">
            <button class="btn-green" type="submit">Reactivate</button>
          </form>
        <% } else { %>
          <span class="ms-none">—</span>
        <% } %>
      </td>
    </tr>
    <% } %>
  </table>

  <a href="staff_dashboard.jsp">Back to Dashboard</a>

<%
    } catch (Exception e) {
%>
  <p class="error">Database error: <%= e.getMessage() %></p>
<%
    } finally {
        if (conn != null) try { conn.close(); } catch (SQLException ex) {}
    }
%>
</body>
</html>
