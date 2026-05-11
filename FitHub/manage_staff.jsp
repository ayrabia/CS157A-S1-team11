<%@ page import="java.sql.*" %>
<%@ page session="true" %>
<%
    String staffRole = (String) session.getAttribute("staff_role");

    if (session.getAttribute("staff_id") == null && 
        session.getAttribute("admin_id") == null) {
        response.sendRedirect("staff_login.jsp");
        return;
    }

    if (!"Admin".equalsIgnoreCase(staffRole)) {
        response.sendRedirect("staff_dashboard.jsp");
        return;
    }

    String message = "";
    String messageType = "";

    Connection conn = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/group11", "root", "YOUR_PASSWORD_HERE"
        );

        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String action = request.getParameter("action");

            if ("add_staff".equals(action)) {
                String role = request.getParameter("role");

                ResultSet idRs = conn.prepareStatement(
                        "SELECT COALESCE(MAX(staff_id), 0) + 1 AS next_id FROM Staff"
                    ).executeQuery();
                    idRs.next();
                    int nextStaffId = idRs.getInt("next_id");
                    idRs.close();

                    PreparedStatement insertPs = conn.prepareStatement(
                        "INSERT INTO Staff " +
                        "(staff_id, first_name, last_name, username, password_hash, role, email, status) " +
                        "VALUES (?, ?, ?, ?, ?, ?, ?, 'Active')"
                    );
                    insertPs.setInt(1, nextStaffId);
                    insertPs.setString(2, request.getParameter("first_name"));
                    insertPs.setString(3, request.getParameter("last_name"));
                    insertPs.setString(4, request.getParameter("username"));
                    insertPs.setString(5, request.getParameter("password"));
                    insertPs.setString(6, role);
                    insertPs.setString(7, request.getParameter("email"));
                    insertPs.executeUpdate();
                    insertPs.close();

                    message = "Staff account created. Staff ID: " + nextStaffId;
                    messageType = "success";
                    response.sendRedirect("manage_staff.jsp");
                    return;

            } else if ("update_staff".equals(action)) {
                int staffId = Integer.parseInt(request.getParameter("staff_id"));
                String role = request.getParameter("role");

                PreparedStatement updatePs = conn.prepareStatement(
                    "UPDATE Staff SET role = ?, status = ? WHERE staff_id = ?"
                );

                updatePs.setString(1, role);
                updatePs.setString(2, request.getParameter("status"));
                updatePs.setInt(3, staffId);
                updatePs.executeUpdate();
                updatePs.close();

                message = "Staff account updated.";
                messageType = "success";
                response.sendRedirect("manage_staff.jsp");
                return;
            }
        }

        ResultSet staff = conn.prepareStatement(
            "SELECT staff_id, first_name, last_name, username, role, email, status " +
            "FROM Staff ORDER BY staff_id"
        ).executeQuery();
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Manage Staff - FitHub</title>
  <style>
    body { font-family: Arial, sans-serif; background:#1a1a1a; color:#fff; margin:0; padding:2rem; }
    h1, h2 { color:#e8ff3a; }
    table { width:100%; border-collapse:collapse; margin-bottom:2rem; }
    th { background:#2a2a2a; color:#e8ff3a; padding:10px; text-align:left; }
    td { padding:10px; border-bottom:1px solid #333; vertical-align:top; }
    input, select { padding:8px; border-radius:6px; border:1px solid #444; background:#333; color:#fff; margin-bottom:8px; }
    button { padding:7px 14px; border:none; border-radius:6px; cursor:pointer; font-weight:bold; }
    .btn-yellow { background:#e8ff3a; color:#000; }
    .box { background:#2a2a2a; border-radius:10px; padding:1.5rem; max-width:420px; margin-bottom:2rem; }
    .success { color:#44ff88; }
    .error { color:#ff4444; }
    a { color:#e8ff3a; }
  </style>
</head>
<body>

<h1>Manage Staff</h1>

<% if (!message.isEmpty()) { %>
  <p class="<%= messageType %>"><%= message %></p>
<% } %>

<h2>Add Staff</h2>
<div class="box">
  <form method="post">
    <input type="hidden" name="action" value="add_staff">

    <p><input type="text" name="first_name" placeholder="First Name" required></p>
    <p><input type="text" name="last_name" placeholder="Last Name" required></p>
    <p><input type="text" name="username" placeholder="Username" required></p>
    <p><input type="password" name="password" placeholder="Password" required></p>
    <p><input type="email" name="email" placeholder="Email" required></p>

    <p>
      <select name="role" required>
        <option value="Host">Host</option>
        <option value="Trainer">Trainer</option>
      </select>
    </p>

    <button class="btn-yellow" type="submit">Add Staff</button>
  </form>
</div>

<h2>All Staff</h2>
<table>
  <tr>
    <th>ID</th>
    <th>Name</th>
    <th>Username</th>
    <th>Email</th>
    <th>Role</th>
    <th>Status</th>
    <th>Update</th>
  </tr>

<%
    while (staff.next()) {
%>
  <tr>
    <form method="post">
      <input type="hidden" name="action" value="update_staff">
      <input type="hidden" name="staff_id" value="<%= staff.getInt("staff_id") %>">

      <td><%= staff.getInt("staff_id") %></td>

      <td>
        <%= staff.getString("first_name") %> <%= staff.getString("last_name") %>
      </td>

      <td>
        <%= staff.getString("username") %>
      </td>

      <td>
        <%= staff.getString("email") %>

      <td>
        <select name="role" required>
          <option value="Host" <%= "Host".equals(staff.getString("role")) ? "selected" : "" %>>Host</option>
          <option value="Trainer" <%= "Trainer".equals(staff.getString("role")) ? "selected" : "" %>>Trainer</option>
        </select>
      </td>

      <td>
        <select name="status" required>
          <option value="Active" <%= "Active".equals(staff.getString("status")) ? "selected" : "" %>>Active</option>
          <option value="Inactive" <%= "Inactive".equals(staff.getString("status")) ? "selected" : "" %>>Inactive</option>
        </select>
      </td>

      <td>
        <button class="btn-yellow" type="submit">Update</button>
      </td>
    </form>
  </tr>
<%
    }
    staff.close();
%>
</table>

<a href="staff_dashboard.jsp">Back to Dashboard</a>

</body>
</html>

<%
    } catch (Exception e) {
%>
<p style="color:#ff4444;">Database error: <%= e.getMessage() %></p>
<a href="staff_dashboard.jsp" style="color:#e8ff3a;">Back to Dashboard</a>
<%
    } finally {
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
%>