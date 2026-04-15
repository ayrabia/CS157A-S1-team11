<%@ page session="true" %>
<%
    String staffName = (String) session.getAttribute("staff_name");
    String staffRole = (String) session.getAttribute("staff_role");
    if (staffName == null) {
        response.sendRedirect("staff_login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Staff Dashboard - FitHub</title>
  <style>
    body { font-family: Arial, sans-serif; background: #1a1a1a; color: #fff; margin: 0; padding: 2rem; }
    h1 { color: #e8ff3a; }
    .grid { display: flex; gap: 1rem; flex-wrap: wrap; margin-top: 1.5rem; }
    .card { background: #2a2a2a; border-radius: 10px; padding: 1.5rem; width: 200px; text-align: center; }
    .card h3 { color: #e8ff3a; margin-top: 0; }
    a.btn { display: inline-block; margin-top: 0.8rem; padding: 8px 20px; background: #e8ff3a; color: #000; font-weight: bold; border-radius: 6px; text-decoration: none; font-size: 0.9rem; }
    a.logout { color: #ff6666; text-decoration: none; font-size: 0.9rem; }
  </style>
</head>
<body>
  <h1>Staff Dashboard</h1>
  <p>Welcome, <%= staffName %> &mdash; Role: <%= staffRole %></p>

  <div class="grid">
    <div class="card">
      <h3>Check In Member</h3>
      <p>Record a member's gym visit</p>
      <a class="btn" href="checkin.jsp">Check In</a>
    </div>
    <div class="card">
      <h3>Process Payment</h3>
      <p>Record a membership payment</p>
      <a class="btn" href="process_payment.jsp">Payment</a>
    </div>
  </div>

  <br><br>
  <a href="logout.jsp" class="logout">Logout</a>
</body>
</html>
