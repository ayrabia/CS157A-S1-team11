<%@ page import="java.sql.*" %>
<%@ page session="true" %>
<%
    if (session.getAttribute("staff_id") == null) {
        response.sendRedirect("staff_login.jsp");
        return;
    }

    String message = "";
    String messageType = "";

    String prefillMemberId = request.getParameter("member_id") == null ? "" : request.getParameter("member_id");
    String prefillMembershipId = request.getParameter("membership_id") == null ? "" : request.getParameter("membership_id");

    Connection conn = null;

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            int memberId = Integer.parseInt(request.getParameter("member_id"));
            int membershipId = Integer.parseInt(request.getParameter("membership_id"));
            int amount = Integer.parseInt(request.getParameter("amount"));
            String method = request.getParameter("payment_method");

            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/group11", "root", "YOUR_PASSWORD_HERE");

            // ACID transaction starts here
            conn.setAutoCommit(false);

            // Verify membership belongs to member and is not already active
            ps = conn.prepareStatement(
                "SELECT membership_id, status FROM Membership WHERE membership_id = ? AND member_id = ?"
            );
            ps.setInt(1, membershipId);
            ps.setInt(2, memberId);
            rs = ps.executeQuery();

            if (!rs.next()) {
                throw new Exception("Membership not found for this member.");
            }

            String currentStatus = rs.getString("status");
            rs.close();
            ps.close();

            if ("Active".equalsIgnoreCase(currentStatus)) {
                throw new Exception("This membership is already active.");
            }

            // Generate payment_id manually
            ps = conn.prepareStatement(
                "SELECT COALESCE(MAX(payment_id), 0) + 1 AS next_id FROM Payment"
            );
            rs = ps.executeQuery();
            rs.next();
            int paymentId = rs.getInt("next_id");
            rs.close();
            ps.close();

            // Insert payment record
            ps = conn.prepareStatement(
                "INSERT INTO Payment " +
                "(payment_id, membership_id, member_id, amount, payment_method, payment_date, payment_status) " +
                "VALUES (?, ?, ?, ?, ?, CURDATE(), 'Completed')"
            );
            ps.setInt(1, paymentId);
            ps.setInt(2, membershipId);
            ps.setInt(3, memberId);
            ps.setInt(4, amount);
            ps.setString(5, method);
            ps.executeUpdate();
            ps.close();

            // Activate membership only after payment is recorded
            ps = conn.prepareStatement(
                "UPDATE Membership SET status = 'Active' WHERE membership_id = ? AND member_id = ?"
            );
            ps.setInt(1, membershipId);
            ps.setInt(2, memberId);
            ps.executeUpdate();

            conn.commit();

            message = "Payment completed. Membership is now active.";
            messageType = "success";

        } catch (Exception e) {
            if (conn != null) {
                try { conn.rollback(); } catch (Exception rollbackError) {}
            }
            message = "Payment failed: " + e.getMessage();
            messageType = "error";
        } finally {
            if (conn != null) try { conn.setAutoCommit(true); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Process Payment - FitHub</title>
  <style>
    body { font-family: Arial, sans-serif; background:#1a1a1a; color:#fff; display:flex; flex-direction:column; align-items:center; justify-content:center; min-height:100vh; margin:0; }
    h2 { color:#e8ff3a; }
    form { display:flex; flex-direction:column; gap:12px; width:320px; }
    input, select { padding:10px; border-radius:6px; border:1px solid #444; background:#2a2a2a; color:#fff; font-size:1rem; }
    button { padding:10px; background:#e8ff3a; color:#000; font-weight:bold; border:none; border-radius:6px; cursor:pointer; font-size:1rem; }
    .error { color:#ff4444; }
    .success { color:#44ff88; }
    a { color:#e8ff3a; }
  </style>
</head>
<body>
  <h2>Process Payment</h2>

  <% if (!message.isEmpty()) { %>
    <p class="<%= messageType %>"><%= message %></p>
  <% } %>

  <form method="post">
    <input type="number" name="member_id" value="<%= prefillMemberId %>" placeholder="Member ID" required>
    <input type="number" name="membership_id" value="<%= prefillMembershipId %>" placeholder="Membership ID" required>
    <input type="number" name="amount" placeholder="Amount ($)" required>

    <select name="payment_method" required>
      <option value="Credit Card">Credit Card</option>
      <option value="Debit Card">Debit Card</option>
      <option value="Cash">Cash</option>
    </select>

    <button type="submit">Complete Payment</button>
  </form>

  <br>
  <a href="manage_members.jsp">Back to Manage Members</a>
</body>
</html>