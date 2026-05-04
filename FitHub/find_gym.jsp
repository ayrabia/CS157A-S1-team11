<%@ page import="java.sql.*" %>
<%@ page session="true" %>
<%
    String query = request.getParameter("query");
    if (query == null) query = "";

    String role = request.getParameter("role");
    if (role == null) role = "member";

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Find a Gym - FitHub</title>
  <style>
    body { font-family: Arial, sans-serif; background:#1a1a1a; color:#fff; margin:0; padding:2rem; }
    h1, h2 { color:#e8ff3a; }
    .card { background:#2a2a2a; border-radius:12px; padding:1.5rem; margin-bottom:1.2rem; }
    input { padding:10px; border-radius:6px; border:1px solid #444; background:#333; color:#fff; width:300px; }
    button { padding:10px 18px; background:#e8ff3a; color:#000; border:none; border-radius:7px; font-weight:bold; cursor:pointer; }
    .muted { color:#aaa; }
    a { color:#e8ff3a; }
  </style>
</head>
<body>

<h1>Find a Gym</h1>

<div class="card">
  <form method="get">
    <input type="hidden" name="role" value="<%= role %>">
    <input type="text" name="query" placeholder="Search by gym name or address" value="<%= query %>">
    <button type="submit">Search</button>
  </form>
</div>

<%
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/group11", "root", "YOUR_PASSWORD_HERE"
        );

        String sql =
            "SELECT gym_name, addr, hours " +
            "FROM Gym " +
            "WHERE gym_name LIKE ? OR addr LIKE ? " +
            "ORDER BY gym_name";

        ps = conn.prepareStatement(sql);
        ps.setString(1, "%" + query + "%");
        ps.setString(2, "%" + query + "%");
        rs = ps.executeQuery();

        boolean found = false;

        while (rs.next()) {
            found = true;
%>

<div class="card">
  <h2><%= rs.getString("gym_name") %></h2>
  <p><strong>Address:</strong> <%= rs.getString("addr") %></p>
  <p><strong>Hours:</strong> <%= rs.getString("hours") %></p>
</div>

<%
        }

        if (!found) {
%>
<div class="card">
  <p class="muted">No gyms found for "<%= query %>".</p>
</div>
<%
        }

    } catch (Exception e) {
%>
<div class="card">
  <p style="color:#ff6666;">Database error: <%= e.getMessage() %></p>
</div>
<%
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>

<br>

<% if ("staff".equalsIgnoreCase(role)) { %>
  <a href="staff_dashboard.jsp">Back to Staff Dashboard</a>
<% } else { %>
  <a href="member_dashboard.jsp">Back to Member Dashboard</a>
<% } %>

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