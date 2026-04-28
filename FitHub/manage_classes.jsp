<%@ page import="java.sql.*" %>
<%@ page session="true" %>
<%
    // Make sure only logged-in staff can access this page
    if (session.getAttribute("staff_id") == null) {
        response.sendRedirect("staff_login.jsp");
        return;
    }

    String message = "";
    String messageType = "";

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        // Load MySQL JDBC driver
        Class.forName("com.mysql.cj.jdbc.Driver");

        // Open database connection
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/group11", "root", "");

        // Handle form submissions
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String action = request.getParameter("action");

            // =========================
            // CREATE NEW CLASS
            // =========================
            if ("add".equals(action)) {
                // Since class_id is not AUTO_INCREMENT, generate next id manually
                String nextIdSql = "SELECT COALESCE(MAX(class_id), 0) + 1 AS next_id FROM Class";
                ps = conn.prepareStatement(nextIdSql);
                rs = ps.executeQuery();
                rs.next();
                int nextId = rs.getInt("next_id");
                rs.close();
                ps.close();

                // Insert new class session
                String insertSql =
                    "INSERT INTO Class (class_id, class_name, description, max_capacity, schedule_date, start_time, end_time, staff_id, status) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
                ps = conn.prepareStatement(insertSql);
                ps.setInt(1, nextId);
                ps.setString(2, request.getParameter("class_name"));
                ps.setString(3, request.getParameter("description"));
                ps.setInt(4, Integer.parseInt(request.getParameter("max_capacity")));
                ps.setString(5, request.getParameter("schedule_date"));
                ps.setString(6, request.getParameter("start_time"));
                ps.setString(7, request.getParameter("end_time"));
                ps.setInt(8, Integer.parseInt(request.getParameter("staff_id")));
                ps.setString(9, request.getParameter("status"));
                ps.executeUpdate();

                message = "Class created successfully.";
                messageType = "success";
            }

            // =========================
            // UPDATE EXISTING CLASS
            // =========================
            if ("update".equals(action)) {
                String updateSql =
                    "UPDATE Class SET class_name = ?, description = ?, max_capacity = ?, schedule_date = ?, " +
                    "start_time = ?, end_time = ?, staff_id = ?, status = ? WHERE class_id = ?";
                ps = conn.prepareStatement(updateSql);
                ps.setString(1, request.getParameter("class_name"));
                ps.setString(2, request.getParameter("description"));
                ps.setInt(3, Integer.parseInt(request.getParameter("max_capacity")));
                ps.setString(4, request.getParameter("schedule_date"));
                ps.setString(5, request.getParameter("start_time"));
                ps.setString(6, request.getParameter("end_time"));
                ps.setInt(7, Integer.parseInt(request.getParameter("staff_id")));
                ps.setString(8, request.getParameter("status"));
                ps.setInt(9, Integer.parseInt(request.getParameter("class_id")));
                ps.executeUpdate();

                message = "Class updated successfully.";
                messageType = "success";
            }
        }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Manage Classes & Trainers</title>
  <style>
    body { font-family: Arial, sans-serif; background: #1a1a1a; color: #fff; margin: 0; padding: 2rem; }
    h1, h2 { color: #e8ff3a; }
    table { width: 100%; border-collapse: collapse; margin-top: 1rem; }
    th { background: #2a2a2a; color: #e8ff3a; padding: 10px; text-align: left; }
    td { padding: 10px; border-bottom: 1px solid #333; vertical-align: top; }
    input, select { padding: 7px; border-radius: 6px; border: 1px solid #444; background: #333; color: #fff; width: 100%; box-sizing: border-box; }
    button { padding: 7px 14px; border: none; border-radius: 6px; cursor: pointer; font-weight: bold; }
    .btn-yellow { background: #e8ff3a; color: #000; }
    .success { color: #44ff88; }
    .error { color: #ff6666; }
    a { color: #e8ff3a; }
    .box { background: #2a2a2a; padding: 1.5rem; border-radius: 10px; margin-bottom: 2rem; }
  </style>
</head>
<body>
  <h1>Manage Classes & Trainers</h1>

  <%-- Show confirmation or error messages --%>
  <% if (!message.isEmpty()) { %>
    <p class="<%= messageType %>"><%= message %></p>
  <% } %>

  <h2>Create Class</h2>
  <form method="post" class="box">
    <input type="hidden" name="action" value="add">

    <%-- New class basic information --%>
    <p><input type="text" name="class_name" placeholder="Class Name" required></p>
    <p><input type="text" name="description" placeholder="Description" required></p>
    <p><input type="number" name="max_capacity" min="1" placeholder="Max Capacity" required></p>
    <p><input type="text" name="schedule_date" placeholder="YYYY-MM-DD" required></p>
    <p><input type="text" name="start_time" placeholder="HH:MM" required></p>
    <p><input type="text" name="end_time" placeholder="HH:MM" required></p>

    <%-- Trainer selection from Staff + Trainer tables --%>
    <p>
      <select name="staff_id" required>
        <option value="">Select Trainer</option>
        <%
            PreparedStatement trainerPs = conn.prepareStatement(
                "SELECT s.staff_id, s.first_name, s.last_name " +
                "FROM Staff s JOIN Trainer t ON s.staff_id = t.staff_id " +
                "WHERE s.role = 'Trainer' AND s.status = 'Active' " +
                "ORDER BY s.first_name, s.last_name"
            );
            ResultSet trainerRs = trainerPs.executeQuery();
            while (trainerRs.next()) {
        %>
          <option value="<%= trainerRs.getInt("staff_id") %>">
            <%= trainerRs.getString("first_name") %> <%= trainerRs.getString("last_name") %>
          </option>
        <% } trainerRs.close(); trainerPs.close(); %>
      </select>
    </p>

    <%-- Class status selection --%>
    <p>
      <select name="status" required>
        <option value="Scheduled">Scheduled</option>
        <option value="Cancelled">Cancelled</option>
        <option value="Completed">Completed</option>
      </select>
    </p>

    <p><button class="btn-yellow" type="submit">Create Class</button></p>
  </form>

  <h2>Existing Classes</h2>
  <table>
    <tr>
      <th>ID</th>
      <th>Class</th>
      <th>Date</th>
      <th>Time</th>
      <th>Trainer</th>
      <th>Capacity</th>
      <th>Enrolled</th>
      <th>Waitlist</th>
      <th>Status</th>
      <th>Update</th>
    </tr>

    <%
        // Get all classes plus trainer name and enrollment counts
        String classSql =
            "SELECT c.class_id, c.class_name, c.description, c.max_capacity, c.schedule_date, c.start_time, c.end_time, c.staff_id, c.status, " +
            "CONCAT(s.first_name, ' ', s.last_name) AS trainer_name, " +
            "(SELECT COUNT(*) FROM Class_Enrollment ce WHERE ce.class_id = c.class_id AND ce.enrollment_status = 'Enrolled') AS enrolled_count, " +
            "(SELECT COUNT(*) FROM Class_Enrollment ce WHERE ce.class_id = c.class_id AND ce.enrollment_status = 'Waitlisted') AS waitlist_count " +
            "FROM Class c LEFT JOIN Staff s ON c.staff_id = s.staff_id " +
            "ORDER BY c.schedule_date, c.start_time";

        ps = conn.prepareStatement(classSql);
        rs = ps.executeQuery();

        while (rs.next()) {
            int classId = rs.getInt("class_id");
            int currentStaffId = rs.getInt("staff_id");
    %>
    <tr>
      <td><%= classId %></td>
      <td><%= rs.getString("class_name") %></td>
      <td><%= rs.getString("schedule_date") %></td>
      <td><%= rs.getString("start_time") %> - <%= rs.getString("end_time") %></td>
      <td><%= rs.getString("trainer_name") %></td>
      <td><%= rs.getInt("max_capacity") %></td>
      <td><%= rs.getInt("enrolled_count") %></td>
      <td><%= rs.getInt("waitlist_count") %></td>
      <td><%= rs.getString("status") %></td>
      <td>
        <%-- Inline update form for each class row --%>
        <form method="post">
          <input type="hidden" name="action" value="update">
          <input type="hidden" name="class_id" value="<%= classId %>">

          <p><input type="text" name="class_name" value="<%= rs.getString("class_name") %>" required></p>
          <p><input type="text" name="description" value="<%= rs.getString("description") %>" required></p>
          <p><input type="number" name="max_capacity" value="<%= rs.getInt("max_capacity") %>" min="1" required></p>
          <p><input type="text" name="schedule_date" value="<%= rs.getString("schedule_date") %>" required></p>
          <p><input type="text" name="start_time" value="<%= rs.getString("start_time") %>" required></p>
          <p><input type="text" name="end_time" value="<%= rs.getString("end_time") %>" required></p>

          <%-- Trainer dropdown with current trainer selected --%>
          <p>
            <select name="staff_id" required>
              <%
                  PreparedStatement trainerPs2 = conn.prepareStatement(
                      "SELECT s.staff_id, s.first_name, s.last_name " +
                      "FROM Staff s JOIN Trainer t ON s.staff_id = t.staff_id " +
                      "WHERE s.role = 'Trainer' AND s.status = 'Active' " +
                      "ORDER BY s.first_name, s.last_name"
                  );
                  ResultSet trainerRs2 = trainerPs2.executeQuery();
                  while (trainerRs2.next()) {
                      int optionId = trainerRs2.getInt("staff_id");
              %>
                <option value="<%= optionId %>" <%= optionId == currentStaffId ? "selected" : "" %>>
                  <%= trainerRs2.getString("first_name") %> <%= trainerRs2.getString("last_name") %>
                </option>
              <% } trainerRs2.close(); trainerPs2.close(); %>
            </select>
          </p>

          <%-- Status dropdown with current status selected --%>
          <p>
            <select name="status" required>
              <option value="Scheduled" <%= "Scheduled".equals(rs.getString("status")) ? "selected" : "" %>>Scheduled</option>
              <option value="Cancelled" <%= "Cancelled".equals(rs.getString("status")) ? "selected" : "" %>>Cancelled</option>
              <option value="Completed" <%= "Completed".equals(rs.getString("status")) ? "selected" : "" %>>Completed</option>
            </select>
          </p>

          <button class="btn-yellow" type="submit">Update</button>
        </form>
      </td>
    </tr>
    <% } %>
  </table>

  <br>
  <a href="staff_dashboard.jsp">Back to Dashboard</a>
</body>
</html>
<%
    } catch (Exception e) {
%>
<!DOCTYPE html>
<html>
<head><title>Error</title></head>
<body style="font-family: Arial; background:#1a1a1a; color:#fff; padding:2rem;">
  <p style="color:#ff6666;">Error: <%= e.getMessage() %></p>
  <a href="staff_dashboard.jsp" style="color:#e8ff3a;">Back to Dashboard</a>
</body>
</html>
<%
    } finally {
        // Always close database resources
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>