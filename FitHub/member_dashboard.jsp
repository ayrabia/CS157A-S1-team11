<%@ page import="java.sql.*" %>
<%@ page session="true" %>
<%
    Integer memberId = (Integer) session.getAttribute("member_id");
    String firstName = (String) session.getAttribute("first_name");
    if (memberId == null) {
        response.sendRedirect("member_login.jsp");
        return;
    }

    // Fetch membership info
    String planName = "N/A", startDate = "N/A", endDate = "N/A", membershipStatus = "N/A";
    Connection conn = null;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/group11", "root", "YOUR_PASSWORD_HERE");

        String sql = "SELECT M.status, M.start_date, M.end_date, P.plan_name " +
                     "FROM Membership M, Membership_Plan P " +
                     "WHERE M.plan_id = P.plan_id AND M.member_id = ?";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setInt(1, memberId);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            membershipStatus = rs.getString("status");
            startDate        = rs.getString("start_date");
            endDate          = rs.getString("end_date");
            planName         = rs.getString("plan_name");
        }
    } catch (Exception e) {
        membershipStatus = "Error: " + e.getMessage();
    } finally {
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Member Dashboard - FitHub</title>
  <style>
    body { font-family: Arial, sans-serif; background: #1a1a1a; color: #fff; margin: 0; padding: 2rem; }
    h1 { color: #e8ff3a; }
    .card { background: #2a2a2a; border-radius: 10px; padding: 1.5rem; max-width: 500px; margin-bottom: 1.5rem; }
    .card h3 { color: #e8ff3a; margin-top: 0; }
    .label { color: #aaa; font-size: 0.9rem; }
    .value { font-size: 1.1rem; margin-bottom: 0.8rem; }
    a.btn { display: inline-block; margin-top: 1rem; padding: 10px 24px; background: #e8ff3a; color: #000; font-weight: bold; border-radius: 6px; text-decoration: none; }
    a.logout { color: #ff6666; text-decoration: none; font-size: 0.9rem; }
  </style>
</head>
<body>
  <h1>Welcome, <%= firstName %>!</h1>

  <div class="card">
    <h3>Membership Status</h3>
    <div class="label">Plan</div>
    <div class="value"><%= planName %></div>
    <div class="label">Status</div>
    <div class="value"><%= membershipStatus %></div>
    <div class="label">Start Date</div>
    <div class="value"><%= startDate %></div>
    <div class="label">End Date</div>
    <div class="value"><%= endDate %></div>
  </div>

  <a href="logout.jsp" class="logout">Logout</a>
</body>
</html>
