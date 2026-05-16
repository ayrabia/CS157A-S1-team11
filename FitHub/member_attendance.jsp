<%--
  Contributions: Ayman Rabia 100%
--%>
<%@ include file="header.jsp" %>
<%@ page import="java.sql.*" %>
<%@ page session="true" %>
<%
    Integer memberId = (Integer) session.getAttribute("member_id");
    String firstName = (String) session.getAttribute("first_name");
    if (memberId == null) {
        response.sendRedirect("member_login.jsp");
        return;
    }

    Connection conn = null;
    ResultSet rs = null;
    PreparedStatement ps = null;
    int totalVisits = 0;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/group11", "root", "YOUR_PASSWORD_HERE");

        String countSql = "SELECT COUNT(*) FROM AttendanceLog WHERE member_id = ?";
        ps = conn.prepareStatement(countSql);
        ps.setInt(1, memberId);
        rs = ps.executeQuery();
        if (rs.next()) totalVisits = rs.getInt(1);
        rs.close(); ps.close();

        String sql = "SELECT A.check_in_time, C.class_name " +
                     "FROM AttendanceLog A LEFT JOIN Class C ON A.class_id = C.class_id " +
                     "WHERE A.member_id = ? ORDER BY A.check_in_time DESC";
        ps = conn.prepareStatement(sql);
        ps.setInt(1, memberId);
        rs = ps.executeQuery();
    } catch (Exception e) {
        out.println("<p style='color:red'>Error: " + e.getMessage() + "</p>");
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>My Attendance - FitHub</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      background: #1a1a1a;
      color: #fff;
      margin: 0;
      padding: 2rem;
    }
    h1 { color: #e8ff3a; margin-bottom: 0.25rem; }
    .subtitle { color: #aaa; margin-bottom: 2rem; font-size: 0.95rem; }
    .card {
      background: #2a2a2a;
      border-radius: 10px;
      padding: 1.5rem;
      max-width: 700px;
      margin-bottom: 1.5rem;
    }
    .card h3 { color: #e8ff3a; margin-top: 0; }
    .stat { font-size: 2.5rem; font-weight: bold; color: #e8ff3a; }
    table {
      width: 100%;
      border-collapse: collapse;
      margin-top: 0.5rem;
    }
    th {
      text-align: left;
      color: #aaa;
      font-size: 0.85rem;
      padding: 0.5rem 0.75rem;
      border-bottom: 1px solid #444;
    }
    td {
      padding: 0.75rem;
      border-bottom: 1px solid #333;
      font-size: 0.95rem;
    }
    tr:last-child td { border-bottom: none; }
    .badge {
      display: inline-block;
      padding: 2px 10px;
      border-radius: 12px;
      font-size: 0.8rem;
      background: #3a3a3a;
      color: #e8ff3a;
    }
    .badge.gym { color: #aaa; }
    .empty { color: #888; text-align: center; padding: 2rem; }
    a.btn {
      display: inline-block;
      margin-top: 1rem;
      padding: 10px 24px;
      background: #e8ff3a;
      color: #000;
      font-weight: bold;
      border-radius: 6px;
      text-decoration: none;
    }
    a.btn:hover { opacity: 0.9; }
  </style>
</head>
<body>
  <h1>My Attendance</h1>
  <div class="subtitle">Gym visit history for <%= firstName %></div>

  <div class="card">
    <h3>Total Visits</h3>
    <div class="stat"><%= totalVisits %></div>
  </div>

  <div class="card">
    <h3>Visit History</h3>
    <table>
      <thead>
        <tr>
          <th>#</th>
          <th>Date & Time</th>
          <th>Type</th>
        </tr>
      </thead>
      <tbody>
        <%
          int count = 0;
          boolean hasRows = false;
          if (rs != null) {
              while (rs.next()) {
                  hasRows = true;
                  count++;
                  String checkIn = rs.getString("check_in_time");
                  String className = rs.getString("class_name");
        %>
        <tr>
          <td><%= count %></td>
          <td><%= checkIn %></td>
          <td>
            <% if (className != null) { %>
              <span class="badge"><%= className %></span>
            <% } else { %>
              <span class="badge gym">General Visit</span>
            <% } %>
          </td>
        </tr>
        <%
              }
          }
          if (!hasRows) {
        %>
        <tr><td colspan="3" class="empty">No visits recorded yet.</td></tr>
        <%
          }
          if (rs != null) try { rs.close(); } catch (SQLException e) {}
          if (ps != null) try { ps.close(); } catch (SQLException e) {}
          if (conn != null) try { conn.close(); } catch (SQLException e) {}
        %>
      </tbody>
    </table>
  </div>

  <a href="member_dashboard.jsp" class="btn">Back to Dashboard</a>
</body>
</html>
