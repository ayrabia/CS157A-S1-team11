<%@ include file="header.jsp" %>
<%@ page import="java.sql.*" %>
<%@ page session="true" %>
<%
    if (session.getAttribute("staff_id") == null) {
        response.sendRedirect("staff_login.jsp");
        return;
    }

    String search = request.getParameter("search") == null ? "" : request.getParameter("search").trim();
    String statusFilter = request.getParameter("status") == null ? "" : request.getParameter("status").trim();

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    String errorMessage = "";
    int totalPayments = 0;
    int completedPayments = 0;
    int totalAmount = 0;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/group11", "root", "YOUR_PASSWORD_HERE");

        String baseWhere = " WHERE 1 = 1 ";
        if (!search.isEmpty()) {
            baseWhere += " AND (CAST(p.payment_id AS CHAR) LIKE ? " +
                         " OR CAST(p.member_id AS CHAR) LIKE ? " +
                         " OR m.first_name LIKE ? " +
                         " OR m.last_name LIKE ? " +
                         " OR CONCAT(m.first_name, ' ', m.last_name) LIKE ?) ";
        }
        if (!statusFilter.isEmpty()) {
            baseWhere += " AND p.payment_status = ? ";
        }

        String summarySql = "SELECT COUNT(*) AS total_payments, " +
                            "SUM(CASE WHEN p.payment_status = 'Completed' THEN 1 ELSE 0 END) AS completed_payments, " +
                            "COALESCE(SUM(CASE WHEN p.payment_status = 'Completed' THEN p.amount ELSE 0 END), 0) AS total_amount " +
                            "FROM Payment p " +
                            "JOIN Members m ON p.member_id = m.member_id " +
                            baseWhere;
        PreparedStatement summaryPs = conn.prepareStatement(summarySql);
        int summaryIndex = 1;
        if (!search.isEmpty()) {
            String likeSearch = "%" + search + "%";
            for (int i = 0; i < 5; i++) summaryPs.setString(summaryIndex++, likeSearch);
        }
        if (!statusFilter.isEmpty()) summaryPs.setString(summaryIndex++, statusFilter);
        ResultSet summaryRs = summaryPs.executeQuery();
        if (summaryRs.next()) {
            totalPayments = summaryRs.getInt("total_payments");
            completedPayments = summaryRs.getInt("completed_payments");
            totalAmount = summaryRs.getInt("total_amount");
        }
        summaryRs.close();
        summaryPs.close();

        String sql = "SELECT p.payment_id, p.member_id, m.first_name, m.last_name, " +
                     "p.membership_id, mp.plan_name, p.amount, p.payment_method, " +
                     "p.payment_date, p.payment_status " +
                     "FROM Payment p " +
                     "JOIN Members m ON p.member_id = m.member_id " +
                     "LEFT JOIN Membership ms ON p.membership_id = ms.membership_id " +
                     "LEFT JOIN Membership_Plan mp ON ms.plan_id = mp.plan_id " +
                     baseWhere +
                     " ORDER BY p.payment_date DESC, p.payment_id DESC";

        ps = conn.prepareStatement(sql);
        int index = 1;
        if (!search.isEmpty()) {
            String likeSearch = "%" + search + "%";
            for (int i = 0; i < 5; i++) ps.setString(index++, likeSearch);
        }
        if (!statusFilter.isEmpty()) ps.setString(index++, statusFilter);
        rs = ps.executeQuery();
    } catch (Exception e) {
        errorMessage = "Database error: " + e.getMessage();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Payment History - FitHub</title>
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
    input, select { padding:10px; border-radius:6px; border:1px solid #444; background:#1f1f1f; color:#fff; font-size:0.95rem; }
    button, a.btn { padding:10px 18px; background:#e8ff3a; color:#000; font-weight:bold; border:none; border-radius:6px; cursor:pointer; text-decoration:none; display:inline-block; }
    a.clear { color:#e8ff3a; align-self:center; }
    table { width:100%; border-collapse:collapse; min-width:900px; }
    th { color:#aaa; text-align:left; font-size:0.85rem; padding:0.65rem; border-bottom:1px solid #444; }
    td { padding:0.75rem 0.65rem; border-bottom:1px solid #333; font-size:0.95rem; }
    tr:last-child td { border-bottom:none; }
    .badge { display:inline-block; padding:3px 10px; border-radius:12px; background:#3a3a3a; color:#e8ff3a; font-size:0.8rem; }
    .empty { text-align:center; color:#888; padding:2rem; }
    .error { color:#ff4444; }
    .nav { margin-top:1.25rem; display:flex; gap:1rem; flex-wrap:wrap; }
    .nav a { color:#e8ff3a; }
  </style>
</head>
<body>
  <h1>Payment History</h1>
  <div class="subtitle">Staff view of member membership payments.</div>

  <% if (!errorMessage.isEmpty()) { %>
    <p class="error"><%= errorMessage %></p>
  <% } %>

  <div class="stats">
    <div class="stat-card"><span>Matching Payments</span><strong><%= totalPayments %></strong></div>
    <div class="stat-card"><span>Completed Payments</span><strong><%= completedPayments %></strong></div>
    <div class="stat-card"><span>Completed Revenue</span><strong>$<%= totalAmount %></strong></div>
  </div>

  <div class="panel">
    <form class="filters" method="get">
      <input type="text" name="search" value="<%= search %>" placeholder="Search payment/member ID or name">
      <select name="status">
        <option value="" <%= statusFilter.equals("") ? "selected" : "" %>>All statuses</option>
        <option value="Completed" <%= statusFilter.equals("Completed") ? "selected" : "" %>>Completed</option>
        <option value="Pending" <%= statusFilter.equals("Pending") ? "selected" : "" %>>Pending</option>
        <option value="Failed" <%= statusFilter.equals("Failed") ? "selected" : "" %>>Failed</option>
        <option value="Refunded" <%= statusFilter.equals("Refunded") ? "selected" : "" %>>Refunded</option>
      </select>
      <button type="submit">Filter</button>
      <a class="clear" href="staff_payment_history.jsp">Clear</a>
    </form>

    <table>
      <thead>
        <tr>
          <th>Payment ID</th>
          <th>Date</th>
          <th>Member</th>
          <th>Membership ID</th>
          <th>Plan</th>
          <th>Amount</th>
          <th>Method</th>
          <th>Status</th>
        </tr>
      </thead>
      <tbody>
        <%
          boolean hasRows = false;
          if (rs != null) {
              while (rs.next()) {
                  hasRows = true;
                  String fullName = rs.getString("first_name") + " " + rs.getString("last_name");
                  String planName = rs.getString("plan_name") == null ? "N/A" : rs.getString("plan_name");
        %>
        <tr>
          <td><%= rs.getInt("payment_id") %></td>
          <td><%= rs.getString("payment_date") %></td>
          <td><%= fullName %> (#<%= rs.getInt("member_id") %>)</td>
          <td><%= rs.getInt("membership_id") %></td>
          <td><%= planName %></td>
          <td>$<%= rs.getInt("amount") %></td>
          <td><%= rs.getString("payment_method") %></td>
          <td><span class="badge"><%= rs.getString("payment_status") %></span></td>
        </tr>
        <%
              }
          }
          if (!hasRows) {
        %>
        <tr><td colspan="8" class="empty">No payment records found.</td></tr>
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
    <a href="process_payment.jsp">Process Payment</a>
    <a href="staff_dashboard.jsp">Back to Dashboard</a>
  </div>
</body>
</html>
