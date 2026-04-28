<%@ page import="java.sql.*" %>
<%@ page session="true" %>
<%
    // Staff-only page for managing membership plans.
    // Supports adding new plans, updating price/duration, and toggling active status.
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

            if ("add".equals(action)) {
                // Generate next plan_id since the table has no AUTO_INCREMENT
                String idSql = "SELECT COALESCE(MAX(plan_id), 0) + 1 AS next_id FROM Membership_Plan";
                ResultSet idRs = conn.prepareStatement(idSql).executeQuery();
                idRs.next();
                int nextId = idRs.getInt("next_id");

                String insertSql = "INSERT INTO Membership_Plan (plan_id, plan_name, duration_months, price, description, is_active) VALUES (?, ?, ?, ?, ?, 'Yes')";
                PreparedStatement insertPs = conn.prepareStatement(insertSql);
                insertPs.setInt(1, nextId);
                insertPs.setString(2, request.getParameter("plan_name"));
                insertPs.setInt(3, Integer.parseInt(request.getParameter("duration_months")));
                insertPs.setInt(4, Integer.parseInt(request.getParameter("price")));
                insertPs.setString(5, request.getParameter("description"));
                insertPs.executeUpdate();
                message = "Plan added successfully (ID: " + nextId + ").";
                messageType = "success";

            } else if ("update".equals(action)) {
                // Update price and duration for an existing plan
                String updateSql = "UPDATE Membership_Plan SET price = ?, duration_months = ? WHERE plan_id = ?";
                PreparedStatement updatePs = conn.prepareStatement(updateSql);
                updatePs.setInt(1, Integer.parseInt(request.getParameter("price")));
                updatePs.setInt(2, Integer.parseInt(request.getParameter("duration_months")));
                updatePs.setInt(3, Integer.parseInt(request.getParameter("plan_id")));
                updatePs.executeUpdate();
                message = "Plan updated.";
                messageType = "success";

            } else if ("deactivate".equals(action)) {
                String updateSql = "UPDATE Membership_Plan SET is_active = 'No' WHERE plan_id = ?";
                PreparedStatement updatePs = conn.prepareStatement(updateSql);
                updatePs.setInt(1, Integer.parseInt(request.getParameter("plan_id")));
                updatePs.executeUpdate();
                message = "Plan deactivated.";
                messageType = "success";

            } else if ("reactivate".equals(action)) {
                String updateSql = "UPDATE Membership_Plan SET is_active = 'Yes' WHERE plan_id = ?";
                PreparedStatement updatePs = conn.prepareStatement(updateSql);
                updatePs.setInt(1, Integer.parseInt(request.getParameter("plan_id")));
                updatePs.executeUpdate();
                message = "Plan reactivated.";
                messageType = "success";
            }
        }

        // Load all plans for display after handling any POST action
        ResultSet plans = conn.prepareStatement(
            "SELECT plan_id, plan_name, duration_months, price, description, is_active FROM Membership_Plan ORDER BY plan_id"
        ).executeQuery();
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Membership Plans - FitHub</title>
  <style>
    body { font-family: Arial, sans-serif; background: #1a1a1a; color: #fff; margin: 0; padding: 2rem; }
    h1, h2 { color: #e8ff3a; }
    table { width: 100%; border-collapse: collapse; margin-bottom: 2rem; }
    th { background: #2a2a2a; color: #e8ff3a; padding: 10px; text-align: left; }
    td { padding: 10px; border-bottom: 1px solid #333; vertical-align: top; }
    input[type=text], input[type=number] { padding: 7px; border-radius: 6px; border: 1px solid #444; background: #333; color: #fff; font-size: 0.9rem; }
    button { padding: 7px 14px; border: none; border-radius: 6px; cursor: pointer; font-weight: bold; font-size: 0.9rem; margin-top: 4px; }
    .btn-yellow { background: #e8ff3a; color: #000; }
    .btn-red { background: #ff4444; color: #fff; }
    .btn-green { background: #44ff88; color: #000; }
    .add-form { background: #2a2a2a; border-radius: 10px; padding: 1.5rem; max-width: 420px; margin-bottom: 2rem; display: flex; flex-direction: column; gap: 10px; }
    .add-form input { width: 100%; box-sizing: border-box; }
    .success { color: #44ff88; }
    .error { color: #ff4444; }
    a { color: #e8ff3a; }
    .active { color: #44ff88; }
    .inactive { color: #ff4444; }
  </style>
</head>
<body>
  <h1>Membership Plans</h1>
  <% if (!message.isEmpty()) { %><p class="<%= messageType %>"><%= message %></p><% } %>

  <h2>Add New Plan</h2>
  <form class="add-form" method="post">
    <input type="hidden" name="action" value="add">
    <input type="text"   name="plan_name"       placeholder="Plan Name"          required>
    <input type="number" name="duration_months"  placeholder="Duration (months)"  required>
    <input type="number" name="price"            placeholder="Price ($)"          required>
    <input type="text"   name="description"      placeholder="Description">
    <button class="btn-yellow" type="submit">Add Plan</button>
  </form>

  <h2>Existing Plans</h2>
  <table>
    <tr>
      <th>ID</th><th>Name</th><th>Description</th><th>Status</th><th>Update Price / Duration</th><th>Toggle</th>
    </tr>
    <%
        while (plans.next()) {
            int planId       = plans.getInt("plan_id");
            String planName  = plans.getString("plan_name");
            int duration     = plans.getInt("duration_months");
            int price        = plans.getInt("price");
            String desc      = plans.getString("description");
            String isActive  = plans.getString("is_active");
            boolean active   = "Yes".equals(isActive);
    %>
    <tr>
      <td><%= planId %></td>
      <td><%= planName %></td>
      <td><%= desc %></td>
      <td class="<%= active ? "active" : "inactive" %>"><%= isActive %></td>
      <td>
        <!-- Update price and duration inline -->
        <form method="post">
          <input type="hidden" name="action"   value="update">
          <input type="hidden" name="plan_id"  value="<%= planId %>">
          $<input type="number" name="price" value="<%= price %>" style="width:70px">
          &nbsp;
          <input type="number" name="duration_months" value="<%= duration %>" style="width:50px"> mo
          &nbsp;
          <button class="btn-yellow" type="submit">Update</button>
        </form>
      </td>
      <td>
        <!-- Toggle between active and inactive -->
        <form method="post">
          <input type="hidden" name="action"  value="<%= active ? "deactivate" : "reactivate" %>">
          <input type="hidden" name="plan_id" value="<%= planId %>">
          <button class="<%= active ? "btn-red" : "btn-green" %>" type="submit">
            <%= active ? "Deactivate" : "Reactivate" %>
          </button>
        </form>
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
