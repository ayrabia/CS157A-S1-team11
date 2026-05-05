<%@ include file="header.jsp" %>
<%@ page import="java.sql.*" %>
<%@ page session="true" %>
<%
    // Staff-only page for managing member accounts.
    // Supports walk-in registration, freezing active memberships, and reactivating frozen ones.
    if (session.getAttribute("staff_id") == null) {
        response.sendRedirect("staff_login.jsp");
        return;
    }

    String message = "";
    String messageType = "";

    Connection conn = null;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/group11", "root", "YOUR_PASSWORD_HERE");

        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String action = request.getParameter("action");

            if ("freeze".equals(action)) {
                int memberId = Integer.parseInt(request.getParameter("member_id"));

                PreparedStatement updatePs = conn.prepareStatement(
                    "UPDATE Members SET status = 'Frozen' WHERE member_id = ? AND status = 'Active'"
                );
                updatePs.setInt(1, memberId);
                int rows = updatePs.executeUpdate();
                updatePs.close();

                PreparedStatement membershipPs = conn.prepareStatement(
                    "UPDATE Membership SET status = 'Frozen', freeze_flag = 'Yes' " +
                    "WHERE membership_id = (" +
                    "   SELECT membership_id FROM (" +
                    "       SELECT MAX(membership_id) AS membership_id FROM Membership WHERE member_id = ?" +
                    "   ) AS latest" +
                    ")"
                );
                membershipPs.setInt(1, memberId);
                membershipPs.executeUpdate();
                membershipPs.close();

                message = rows > 0 ? "Account and membership frozen." : "Account is already frozen or not found.";
                messageType = rows > 0 ? "success" : "error";

            } else if ("reactivate".equals(action)) {
                int memberId = Integer.parseInt(request.getParameter("member_id"));

                PreparedStatement updatePs = conn.prepareStatement(
                    "UPDATE Members SET status = 'Active' WHERE member_id = ? AND status = 'Frozen'"
                );
                updatePs.setInt(1, memberId);
                int rows = updatePs.executeUpdate();
                updatePs.close();

                PreparedStatement membershipPs = conn.prepareStatement(
                    "UPDATE Membership SET status = 'Active', freeze_flag = 'No' " +
                    "WHERE membership_id = (" +
                    "   SELECT membership_id FROM (" +
                    "       SELECT MAX(membership_id) AS membership_id FROM Membership WHERE member_id = ?" +
                    "   ) AS latest" +
                    ")"
                );
                membershipPs.setInt(1, memberId);
                membershipPs.executeUpdate();
                membershipPs.close();

                message = rows > 0 ? "Account and membership reactivated." : "Account is already active or not found.";
                messageType = rows > 0 ? "success" : "error";

            } else if ("assign_membership".equals(action)) {
                int memberId = Integer.parseInt(request.getParameter("member_id"));
                int planId = Integer.parseInt(request.getParameter("plan_id"));

                PreparedStatement planPs = conn.prepareStatement(
                    "SELECT duration_months FROM Membership_Plan WHERE plan_id = ? AND is_active = 'Yes'"
                );
                planPs.setInt(1, planId);
                ResultSet planRs = planPs.executeQuery();

                if (!planRs.next()) {
                    message = "Selected plan is not active or does not exist.";
                    messageType = "error";
                } else {
                    int duration = planRs.getInt("duration_months");
                    planRs.close();
                    planPs.close();

                    ResultSet idRs = conn.prepareStatement(
                        "SELECT COALESCE(MAX(membership_id), 0) + 1 AS next_id FROM Membership"
                    ).executeQuery();
                    idRs.next();
                    int nextMembershipId = idRs.getInt("next_id");
                    idRs.close();

                    PreparedStatement assignPs = conn.prepareStatement(
                        "INSERT INTO Membership " +
                        "(membership_id, member_id, plan_id, start_date, end_date, status, freeze_flag) " +
                        "VALUES (?, ?, ?, CURDATE(), DATE_ADD(CURDATE(), INTERVAL ? MONTH), 'Pending', 'No')"
                    );
                    assignPs.setInt(1, nextMembershipId);
                    assignPs.setInt(2, memberId);
                    assignPs.setInt(3, planId);
                    assignPs.setInt(4, duration);
                    assignPs.executeUpdate();
                    assignPs.close();

                    response.sendRedirect("process_payment.jsp?member_id=" + memberId + "&membership_id=" + nextMembershipId);
                    return;
                }

            } else if ("pay_membership".equals(action)) {

                int memberId = Integer.parseInt(request.getParameter("member_id"));
                int planId   = Integer.parseInt(request.getParameter("plan_id"));

                PreparedStatement planPs = conn.prepareStatement(
                    "SELECT duration_months FROM Membership_Plan WHERE plan_id = ? AND is_active = 'Yes'"
                );
                planPs.setInt(1, planId);
                ResultSet planRs = planPs.executeQuery();

                if (planRs.next()) {
                    int duration = planRs.getInt("duration_months");

                    // check if pending membership exists
                    PreparedStatement checkPs = conn.prepareStatement(
                        "SELECT membership_id FROM Membership WHERE member_id = ? AND status = 'Pending' ORDER BY membership_id DESC LIMIT 1"
                    );
                    checkPs.setInt(1, memberId);
                    ResultSet checkRs = checkPs.executeQuery();

                    int membershipId;

                    if (checkRs.next()) {
                        // UPDATE existing pending membership
                        membershipId = checkRs.getInt("membership_id");

                        PreparedStatement updatePs = conn.prepareStatement(
                            "UPDATE Membership SET plan_id = ?, start_date = CURDATE(), " +
                            "end_date = DATE_ADD(CURDATE(), INTERVAL ? MONTH) " +
                            "WHERE membership_id = ?"
                        );
                        updatePs.setInt(1, planId);
                        updatePs.setInt(2, duration);
                        updatePs.setInt(3, membershipId);
                        updatePs.executeUpdate();

                    } else {
                        // CREATE new pending membership (same as your assign logic)
                        ResultSet idRs = conn.prepareStatement(
                            "SELECT COALESCE(MAX(membership_id), 0) + 1 AS next_id FROM Membership"
                        ).executeQuery();
                        idRs.next();
                        membershipId = idRs.getInt("next_id");

                        PreparedStatement insertPs = conn.prepareStatement(
                            "INSERT INTO Membership (membership_id, member_id, plan_id, start_date, end_date, status, freeze_flag) " +
                            "VALUES (?, ?, ?, CURDATE(), DATE_ADD(CURDATE(), INTERVAL ? MONTH), 'Pending', 'No')"
                        );
                        insertPs.setInt(1, membershipId);
                        insertPs.setInt(2, memberId);
                        insertPs.setInt(3, planId);
                        insertPs.setInt(4, duration);
                        insertPs.executeUpdate();
                    }

                    // redirect to payment page
                    response.sendRedirect("process_payment.jsp?member_id=" + memberId + "&membership_id=" + membershipId);
                    return;
                }
            } else if ("walkin".equals(action)) {
                // Walk-in registration: staff creates a member account on the spot
                String username = request.getParameter("username");
                String email    = request.getParameter("email");

                // Reject duplicate username or email
                String checkSql = "SELECT member_id FROM Members WHERE username = ? OR email = ?";
                PreparedStatement checkPs = conn.prepareStatement(checkSql);
                checkPs.setString(1, username);
                checkPs.setString(2, email);
                ResultSet checkRs = checkPs.executeQuery();

                if (checkRs.next()) {
                    message = "Username or email already exists.";
                    messageType = "error";
                } else {
                    // Generate next member_id since the table has no AUTO_INCREMENT
                    ResultSet idRs = conn.prepareStatement(
                        "SELECT COALESCE(MAX(member_id), 0) + 1 AS next_id FROM Members"
                    ).executeQuery();
                    idRs.next();
                    int nextId = idRs.getInt("next_id");

                    String insertSql = "INSERT INTO Members (member_id, phone_number, first_name, last_name, username, email, password_hash, date_joined, status) VALUES (?, ?, ?, ?, ?, ?, ?, CURDATE(), 'Active')";
                    PreparedStatement insertPs = conn.prepareStatement(insertSql);
                    insertPs.setInt(1, nextId);
                    insertPs.setString(2, request.getParameter("phone"));
                    insertPs.setString(3, request.getParameter("first_name"));
                    insertPs.setString(4, request.getParameter("last_name"));
                    insertPs.setString(5, username);
                    insertPs.setString(6, email);
                    insertPs.setString(7, request.getParameter("password"));
                    insertPs.executeUpdate();
                    message = "Walk-in member registered. Member ID: " + nextId;
                    messageType = "success";
                }
            }
        }

        // Load all members joined with their most recent membership status
        ResultSet members = conn.prepareStatement(
            "SELECT m.member_id, m.first_name, m.last_name, m.email, m.status AS account_status, " +
            "ms.membership_id, " +
            "COALESCE(ms.status, 'No Membership') AS membership_status " +
            "FROM Members m " +
            "LEFT JOIN Membership ms ON m.member_id = ms.member_id " +
            "   AND ms.membership_id = (SELECT MAX(membership_id) FROM Membership WHERE member_id = m.member_id) " +
            "ORDER BY m.member_id"
        ).executeQuery();

        // Load active plans for the assign membership dropdown
        ResultSet plans = conn.prepareStatement(
            "SELECT plan_id, plan_name, price, duration_months FROM Membership_Plan WHERE is_active = 'Yes' ORDER BY plan_name"
        ).executeQuery();
        java.util.List<int[]> planIds = new java.util.ArrayList<>();
        java.util.List<String> planLabels = new java.util.ArrayList<>();
        while (plans.next()) {
            planIds.add(new int[]{ plans.getInt("plan_id") });
            planLabels.add(plans.getString("plan_name") + " ($" + plans.getInt("price") + " / " + plans.getInt("duration_months") + " mo)");
        }
        plans.close();
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Manage Members - FitHub</title>
  <style>
    body { font-family: Arial, sans-serif; background: #1a1a1a; color: #fff; margin: 0; padding: 2rem; }
    h1, h2 { color: #e8ff3a; }
    table { width: 100%; border-collapse: collapse; margin-bottom: 2rem; }
    th { background: #2a2a2a; color: #e8ff3a; padding: 10px; text-align: left; }
    td { padding: 10px; border-bottom: 1px solid #333; }
    input[type=text], input[type=email], input[type=password] { padding: 8px; border-radius: 6px; border: 1px solid #444; background: #333; color: #fff; font-size: 0.9rem; width: 100%; box-sizing: border-box; margin-bottom: 8px; }
    button { padding: 7px 14px; border: none; border-radius: 6px; cursor: pointer; font-weight: bold; font-size: 0.9rem; }
    .btn-yellow { background: #e8ff3a; color: #000; }
    .btn-red { background: #ff4444; color: #fff; }
    .btn-green { background: #44ff88; color: #000; }
    .walkin-form { background: #2a2a2a; border-radius: 10px; padding: 1.5rem; max-width: 380px; margin-bottom: 2rem; display: flex; flex-direction: column; }
    .success { color: #44ff88; }
    .error { color: #ff4444; }
    a { color: #e8ff3a; }
    .ms-active { color: #44ff88; }
    .ms-frozen { color: #aaaaff; }
    .ms-none { color: #888; }
    form.inline { display: inline; }
  </style>
</head>
<body>
  <h1>Manage Members</h1>
  <% if (!message.isEmpty()) { %><p class="<%= messageType %>"><%= message %></p><% } %>

  <h2>Walk-In Registration</h2>
  <div class="walkin-form">
    <form method="post">
      <input type="hidden"   name="action"     value="walkin">
      <input type="text"     name="first_name" placeholder="First Name"   required>
      <input type="text"     name="last_name"  placeholder="Last Name"    required>
      <input type="text"     name="phone"      placeholder="Phone Number">
      <input type="email"    name="email"      placeholder="Email"        required>
      <input type="text"     name="username"   placeholder="Username"     required>
      <input type="password" name="password"   placeholder="Password"     required>
      <button class="btn-yellow" type="submit">Register Walk-In</button>
    </form>
  </div>

  <h2>All Members</h2>
  <table>
    <tr>
      <th>ID</th><th>Name</th><th>Email</th><th>Account</th><th>Membership</th><th>Actions</th>
    </tr>
    <%
        while (members.next()) {
            int memberId          = members.getInt("member_id");
            String fullName       = members.getString("first_name") + " " + members.getString("last_name");
            String email          = members.getString("email");
            String accountStatus  = members.getString("account_status");
            String membershipStatus = members.getString("membership_status");
            int membershipId = members.getInt("membership_id");
            boolean isActive  = "Active".equals(accountStatus);
            boolean isFrozen  = "Frozen".equals(accountStatus);
            String msClass    = "Active".equals(membershipStatus) ? "ms-active" : "Frozen".equals(membershipStatus) ? "ms-frozen" : "ms-none";
    %>
    <tr>
      <td><%= memberId %></td>
      <td><%= fullName %></td>
      <td><%= email %></td>
      <td><%= accountStatus %></td>
      <td class="<%= msClass %>"><%= membershipStatus %></td>
      <td>
        <% if ("Pending".equalsIgnoreCase(membershipStatus)) { %>

            <!-- PAY NOW BUTTON -->
            <form class="inline" method="post" style="margin-top:6px; display:block;">
                <input type="hidden" name="action" value="pay_membership">
                <input type="hidden" name="member_id" value="<%= memberId %>">
                <input type="hidden" name="membership_id" value="<%= membershipId %>">

                <select name="plan_id" style="padding:4px; border-radius:4px;">
                    <% for (int i = 0; i < planIds.size(); i++) { %>
                        <option value="<%= planIds.get(i)[0] %>">
                            <%= planLabels.get(i) %>
                        </option>
                    <% } %>
                </select>

                <button class="btn-yellow" type="submit" style="margin-top:4px;">
                    <%= "Pending".equalsIgnoreCase(membershipStatus) ? "Pay Now" : "Pay" %>
                </button>
            </form>

        <% } else if (isActive) { %>

            <form class="inline" method="post">
                <input type="hidden" name="action" value="freeze">
                <input type="hidden" name="member_id" value="<%= memberId %>">
                <button class="btn-red" type="submit">Freeze</button>
            </form>

        <% } else if (isFrozen) { %>

            <form class="inline" method="post">
                <input type="hidden" name="action" value="reactivate">
                <input type="hidden" name="member_id" value="<%= memberId %>">
                <button class="btn-green" type="submit">Reactivate</button>
            </form>

        <% } else { %>

            <span class="ms-none">—</span>

        <% } %>

        <% if ("No Membership".equals(membershipStatus)) { %>

            <!-- Assign Membership -->
            <form class="inline" method="post" style="margin-top:6px; display:block;">
                <input type="hidden" name="action" value="assign_membership">
                <input type="hidden" name="member_id" value="<%= memberId %>">

                <select name="plan_id" style="padding:4px; border-radius:4px;">
                    <% for (int i = 0; i < planIds.size(); i++) { %>
                        <option value="<%= planIds.get(i)[0] %>">
                            <%= planLabels.get(i) %>
                        </option>
                    <% } %>
                </select>

                <button class="btn-yellow" type="submit" style="margin-top:4px;">
                    Pay
                </button>
            </form>

        <% } %>

      </td>
    </tr>
    <% } %>
  </table>

  <a href="staff_dashboard.jsp">Back to Dashboard</a>

<%
    } catch (Exception e) {
%>
  <p class="error">Database error: <%= e.getMessage() %></p>
<%
    } finally {
        if (conn != null) try { conn.close(); } catch (SQLException ex) {}
    }
%>

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
