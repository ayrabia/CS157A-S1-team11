<%@ include file="header.jsp" %>
<%@ page session="true" %>
<%
    // Staff dashboard: session guard redirects unauthenticated users to login.
    // Displays navigation cards for all staff functions; role is shown for context.
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
      <h3>Payment History</h3>
      <p>View member payment records and payment statuses</p>
      <a class="btn" href="staff_payment_history.jsp">Payments</a>
    </div>

    <div class="card">
      <h3>Check-In Logs</h3>
      <p>Review member gym check-in history</p>
      <a class="btn" href="staff_checkin_logs.jsp">Check-In Logs</a>
    </div>
    <div class="card">
      <h3>Manage Members</h3>
      <p>Register, freeze, or reactivate member accounts</p>
      <a class="btn" href="manage_members.jsp">Members</a>
    </div>
    <div class="card">
      <h3>Membership Plans</h3>
      <p>Add, update, or deactivate membership plans</p>
      <a class="btn" href="manage_plans.jsp">Plans</a>
    </div>
    <div class="card">
      <h3>Find a Gym</h3>
      <p>Search FitHub gym locations</p>
      <a href="find_gym.jsp?role=staff" class="btn">Find Gym</a>
    </div>
    <div class="card">
      <h3>Manage Classes</h3>
      <p>Create, schedule, assign trainers, or remove class sessions</p>
      <a class="btn" href="manage_classes.jsp">Manage Classes</a>
    </div>
    <% if ("Admin".equalsIgnoreCase(staffRole)) { %>
      <div class="card">
        <h3>Manage Staff</h3>
        <p>Add staff accounts and assign roles</p>
        <a class="btn" href="manage_staff.jsp">Manage Staff</a>
      </div>
    <% } %>
  </div>

  <br><br>
  <a href="logout.jsp" class="logout">Logout</a>

<script>
function refreshRealtimeSections() {
    fetch(window.location.href)
        .then(response => response.text())
        .then(html => {
            const parser = new DOMParser();
            const newDoc = parser.parseFromString(html, "text/html");

            document.querySelectorAll("[data-realtime]").forEach(section => {
                const id = section.id;
                const newSection = newDoc.getElementById(id);

                if (newSection) {
                    section.innerHTML = newSection.innerHTML;
                }
            });
        })
        .catch(error => console.log("Realtime update failed:", error));
}

// refresh every 5 seconds
setInterval(refreshRealtimeSections, 5000);
</script>

</body>
</html>
