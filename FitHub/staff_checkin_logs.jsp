<%@ include file="header.jsp" %>
<%@ page import="java.sql.*" %>
<%@ page session="true" %>
<%
    if (session.getAttribute("staff_id") == null) {
        response.sendRedirect("staff_login.jsp");
        return;
    }

    String search = request.getParameter("search") == null ? "" : request.getParameter("search").trim();
    String fromDate = request.getParameter("from_date") == null ? "" : request.getParameter("from_date").trim();
    String toDate = request.getParameter("to_date") == null ? "" : request.getParameter("to_date").trim();

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    String errorMessage = "";
    int totalCheckins = 0;
    int uniqueMembers = 0;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/group11", "root", "YOUR_PASSWORD_HERE");

        String baseWhere = " WHERE 1 = 1 ";
        if (!search.isEmpty()) {
            baseWhere += " AND (CAST(a.member_id AS CHAR) LIKE ? " +
                         " OR m.first_name LIKE ? " +
                         " OR m.last_name LIKE ? " +
                         " OR CONCAT(m.first_name, ' ', m.last_name) LIKE ?) ";
        }
        if (!fromDate.isEmpty()) {
            baseWhere += " AND DATE(a.check_in_time) >= ? ";
        }
        if (!toDate.isEmpty()) {
            baseWhere += " AND DATE(a.check_in_time) <= ? ";
        }

        String summarySql = "SELECT COUNT(*) AS total_checkins, COUNT(DISTINCT a.member_id) AS unique_members " +
                            "FROM AttendanceLog a " +
                            "JOIN Members m ON a.member_id = m.member_id " +
                            baseWhere;
        PreparedStatement summaryPs = conn.prepareStatement(summarySql);
        int summaryIndex = 1;
        if (!search.isEmpty()) {
            String likeSearch = "%" + search + "%";
            for (int i = 0; i < 4; i++) summaryPs.setString(summaryIndex++, likeSearch);
        }
        if (!fromDate.isEmpty()) summaryPs.setString(summaryIndex++, fromDate);
        if (!toDate.isEmpty()) summaryPs.setString(summaryIndex++, toDate);
        ResultSet summaryRs = summaryPs.executeQuery();
        if (summaryRs.next()) {
            totalCheckins = summaryRs.getInt("total_checkins");
            uniqueMembers = summaryRs.getInt("unique_members");
        }
        summaryRs.close();
        summaryPs.close();

        String sql = "SELECT a.member_id, m.first_name, m.last_name, m.status, " +
                     "a.check_in_time, c.class_name " +
                     "FROM AttendanceLog a " +
                     "JOIN Members m ON a.member_id = m.member_id " +
                     "LEFT JOIN Class c ON a.class_id = c.class_id " +
                     baseWhere +
                     " ORDER BY a.check_in_time DESC";

        ps = conn.prepareStatement(sql);
        int index = 1;
        if (!search.isEmpty()) {
            String likeSearch = "%" + search + "%";
            for (int i = 0; i < 4; i++) ps.setString(index++, likeSearch);
        }
        if (!fromDate.isEmpty()) ps.setString(index++, fromDate);
        if (!toDate.isEmpty()) ps.setString(index++, toDate);
        rs = ps.executeQuery();
    } catch (Exception e) {
        errorMessage = "Database error: " + e.getMessage();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Member Check-In Logs - FitHub</title>
  <style>
    body { font-family: Arial, sans-serif; background:#1a1a1a; color:#fff; margin:0; padding:2rem; }
    h1 { color:#e8ff3a; margin-bottom:0.25rem; }
    .subtitle { color:#aaa; margin-bottom:1.5rem; }
    .stats { display:flex; flex-wrap:wrap; gap:1rem; margin-bottom:1.5rem; }
    .stat-card { background:#2a2a2a; border-radius:10px; padding:1rem 1.25rem; min-width:180px; }
    .stat-card span { display:block; color:#aaa; font-size:0.85rem; margin-bottom:0.35rem; }
    .stat-card strong { color:#e8ff3a; font-size:1.6rem; }
    .panel { background:#2a2a2a; border-radius:10px; padding:1.25rem; overflow-x:auto; }
    form.filters { display:flex; flex-wrap:wrap; gap:0.75rem; margin-bottom:1rem; }
    input { padding:10px; border-radius:6px; border:1px solid #444; background:#1f1f1f; color:#fff; font-size:0.95rem; }
    button { padding:10px 18px; background:#e8ff3a; color:#000; font-weight:bold; border:none; border-radius:6px; cursor:pointer; }
    a.clear { color:#e8ff3a; align-self:center; }
    table { width:100%; border-collapse:collapse; min-width:760px; }
    th { color:#aaa; text-align:left; font-size:0.85rem; padding:0.65rem; border-bottom:1px solid #444; }
    td { padding:0.75rem 0.65rem; border-bottom:1px solid #333; font-size:0.95rem; }
    tr:last-child td { border-bottom:none; }
    .badge { display:inline-block; padding:3px 10px; border-radius:12px; background:#3a3a3a; color:#e8ff3a; font-size:0.8rem; }
    .badge.gym { color:#aaa; }
    .empty { text-align:center; color:#888; padding:2rem; }
    .error { color:#ff4444; }
    .nav { margin-top:1.25rem; display:flex; gap:1rem; flex-wrap:wrap; }
    .nav a { color:#e8ff3a; }
  </style>
</head>
<body>
  <h1>Member Check-In Logs</h1>
  <div class="subtitle">Staff view of all recorded member visits.</div>

  <% if (!errorMessage.isEmpty()) { %>
    <p class="error"><%= errorMessage %></p>
  <% } %>

  <div class="stats">
    <div class="stat-card"><span>Matching Check-Ins</span><strong><%= totalCheckins %></strong></div>
    <div class="stat-card"><span>Unique Members</span><strong><%= uniqueMembers %></strong></div>
  </div>

  <div class="panel">
    <form class="filters" method="get">
      <input type="text" name="search" value="<%= search %>" placeholder="Search member ID or name">
      <input type="date" name="from_date" value="<%= fromDate %>">
      <input type="date" name="to_date" value="<%= toDate %>">
      <button type="submit">Filter</button>
      <a class="clear" href="staff_checkin_logs.jsp">Clear</a>
    </form>

    <table>
      <thead>
        <tr>
          <th>#</th>
          <th>Date & Time</th>
          <th>Member</th>
          <th>Status</th>
          <th>Type</th>
        </tr>
      </thead>
      <tbody>
        <%
          int rowNumber = 0;
          boolean hasRows = false;
          if (rs != null) {
              while (rs.next()) {
                  hasRows = true;
                  rowNumber++;
                  String fullName = rs.getString("first_name") + " " + rs.getString("last_name");
                  String className = rs.getString("class_name");
        %>
        <tr>
          <td><%= rowNumber %></td>
          <td><%= rs.getString("check_in_time") %></td>
          <td><%= fullName %> (#<%= rs.getInt("member_id") %>)</td>
          <td><span class="badge"><%= rs.getString("status") %></span></td>
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
        <tr><td colspan="5" class="empty">No check-in records found.</td></tr>
        <%
          }
          if (rs != null) try { rs.close(); } catch (SQLException e) {}
          if (ps != null) try { ps.close(); } catch (SQLException e) {}
          if (conn != null) try { conn.close(); } catch (SQLException e) {}
        %>
      </tbody>
    </table>
  </div>

  <div class="nav">
    <a href="checkin.jsp">Check In Member</a>
    <a href="staff_dashboard.jsp">Back to Dashboard</a>
  </div>
</body>
</html>
