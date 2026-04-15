<%@ page import="java.sql.*" %>
<%@ page session="true" %>
<%
    if (session.getAttribute("staff_id") == null) {
        response.sendRedirect("staff_login.jsp");
        return;
    }

    String message = "";
    String messageType = "";

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String memberIdStr    = request.getParameter("member_id");
        String membershipIdStr = request.getParameter("membership_id");
        String amount         = request.getParameter("amount");
        String method         = request.getParameter("payment_method");

        Connection conn = null;
        try {
            int memberId     = Integer.parseInt(memberIdStr);
            int membershipId = Integer.parseInt(membershipIdStr);

            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/group11", "root", "YOUR_PASSWORD_HERE");

            // Verify the membership belongs to this member
            String checkSql = "SELECT membership_id FROM Membership WHERE membership_id = ? AND member_id = ?";
            PreparedStatement checkPs = conn.prepareStatement(checkSql);
            checkPs.setInt(1, membershipId);
            checkPs.setInt(2, memberId);
            ResultSet rs = checkPs.executeQuery();

            if (!rs.next()) {
                message = "Membership ID " + membershipId + " not found for Member ID " + memberId + ".";
                messageType = "error";
            } else {
                String insertSql = "INSERT INTO Payment (membership_id, member_id, amount, payment_method, payment_date, payment_status) VALUES (?, ?, ?, ?, CURDATE(), 'Completed')";
                PreparedStatement insertPs = conn.prepareStatement(insertSql);
                insertPs.setInt(1, membershipId);
                insertPs.setInt(2, memberId);
                insertPs.setString(3, amount);
                insertPs.setString(4, method);
                insertPs.executeUpdate();
                message = "Payment of $" + amount + " recorded successfully.";
                messageType = "success";
            }
        } catch (NumberFormatException e) {
            message = "Please enter valid numeric IDs.";
            messageType = "error";
        } catch (Exception e) {
            message = "Database error: " + e.getMessage();
            messageType = "error";
        } finally {
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Process Payment - FitHub</title>
  <style>
    body { font-family: Arial, sans-serif; background: #1a1a1a; color: #fff; display: flex; flex-direction: column; align-items: center; justify-content: center; min-height: 100vh; margin: 0; }
    h2 { color: #e8ff3a; }
    form { display: flex; flex-direction: column; gap: 12px; width: 320px; }
    input, select { padding: 10px; border-radius: 6px; border: 1px solid #444; background: #2a2a2a; color: #fff; font-size: 1rem; }
    button { padding: 10px; background: #e8ff3a; color: #000; font-weight: bold; border: none; border-radius: 6px; cursor: pointer; font-size: 1rem; }
    .error { color: #ff4444; }
    .success { color: #44ff88; }
    a { color: #e8ff3a; }
  </style>
</head>
<body>
  <h2>Process Payment</h2>
  <% if (!message.isEmpty()) { %>
    <p class="<%= messageType %>"><%= message %></p>
  <% } %>
  <form method="post">
    <input type="number" name="member_id"     placeholder="Member ID"     required>
    <input type="number" name="membership_id" placeholder="Membership ID" required>
    <input type="number" name="amount"        placeholder="Amount ($)"    step="0.01" required>
    <select name="payment_method">
      <option value="Credit Card">Credit Card</option>
      <option value="Debit Card">Debit Card</option>
      <option value="Cash">Cash</option>
    </select>
    <button type="submit">Record Payment</button>
  </form>
  <br>
  <a href="staff_dashboard.jsp">Back to Dashboard</a>
</body>
</html>
