<%@ page import="java.sql.*" %>
<%@ page session="true" %>
<%
    // Allows a logged-in member to permanently delete their account.
    // Deactivates all associated memberships before removing the member record, then invalidates the session.
    Integer memberId = (Integer) session.getAttribute("member_id");
    if (memberId == null) {
        response.sendRedirect("member_login.jsp");
        return;
    }

    String message = "";

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        Connection conn = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/group11", "root", "YOUR_PASSWORD_HERE");

            // Mark all memberships as Expired before deleting the member record
            String deactivateSql = "UPDATE Membership SET status = 'Expired' WHERE member_id = ?";
            PreparedStatement deactivatePs = conn.prepareStatement(deactivateSql);
            deactivatePs.setInt(1, memberId);
            deactivatePs.executeUpdate();

            // Remove the member record from the database
            String deleteSql = "DELETE FROM Members WHERE member_id = ?";
            PreparedStatement deletePs = conn.prepareStatement(deleteSql);
            deletePs.setInt(1, memberId);
            deletePs.executeUpdate();

            // End the session and send user back to the landing page
            session.invalidate();
            response.sendRedirect("index.html");
            return;
        } catch (Exception e) {
            message = "Database error: " + e.getMessage();
        } finally {
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Delete Account - FitHub</title>
  <style>
    body { font-family: Arial, sans-serif; background: #1a1a1a; color: #fff; display: flex; flex-direction: column; align-items: center; justify-content: center; height: 100vh; margin: 0; }
    h2 { color: #ff4444; }
    p { max-width: 400px; text-align: center; color: #ccc; }
    .actions { display: flex; gap: 1rem; margin-top: 1.5rem; }
    button { padding: 10px 24px; font-weight: bold; border: none; border-radius: 6px; cursor: pointer; font-size: 1rem; }
    .danger { background: #ff4444; color: #fff; }
    .cancel { background: #444; color: #fff; }
    .error { color: #ff4444; }
  </style>
</head>
<body>
  <h2>Delete Account</h2>
  <% if (!message.isEmpty()) { %><p class="error"><%= message %></p><% } %>
  <p>This will permanently remove your account and deactivate all associated memberships. This action cannot be undone.</p>
  <div class="actions">
    <form method="post">
      <button class="danger" type="submit">Yes, Delete My Account</button>
    </form>
    <form method="get" action="member_dashboard.jsp">
      <button class="cancel" type="submit">Cancel</button>
    </form>
  </div>
</body>
</html>
