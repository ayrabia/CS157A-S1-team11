<%@ page import="java.sql.*" %>
<%@ page session="true" %>
<%
    // Class enrollment page: session guard ensures only logged-in members can access.
    // Members can enroll, cancel, or join the waitlist depending on class capacity.
    Integer memberId = (Integer) session.getAttribute("member_id");
    String firstName = (String) session.getAttribute("first_name");
    if (memberId == null) {
        response.sendRedirect("member_login.jsp");
        return;
    }

    String message = "";
    Connection conn = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/group11", "root", "YOUR_PASSWORD_HERE");

        String action = request.getParameter("action");
        String classIdParam = request.getParameter("class_id");

        // Handle enroll/cancel actions before displaying the page
        if (action != null && classIdParam != null) {
            int classId = Integer.parseInt(classIdParam);

            // Verify the member has an active membership before allowing class actions
            String membershipSql = "SELECT 1 FROM Membership WHERE member_id = ? AND status = 'Active'";
            PreparedStatement membershipPs = conn.prepareStatement(membershipSql);
            membershipPs.setInt(1, memberId);
            ResultSet membershipRs = membershipPs.executeQuery();

            if (!membershipRs.next()) {
                message = "You must have an active membership to manage class enrollment.";
            } else {
                // Check whether the member already has an enrollment or waitlist entry for this class
                String existingSql = "SELECT enrollment_id, enrollment_status FROM Class_Enrollment " +
                                     "WHERE member_id = ? AND class_id = ?";
                PreparedStatement existingPs = conn.prepareStatement(existingSql);
                existingPs.setInt(1, memberId);
                existingPs.setInt(2, classId);
                ResultSet existingRs = existingPs.executeQuery();

                boolean alreadyExists = existingRs.next();
                int enrollmentId = alreadyExists ? existingRs.getInt("enrollment_id") : -1;
                String enrollmentStatus = alreadyExists ? existingRs.getString("enrollment_status") : "";

                existingRs.close();
                existingPs.close();

                if ("enroll".equals(action)) {
                    if (alreadyExists) {
                        if ("Waitlisted".equalsIgnoreCase(enrollmentStatus)) {
                            message = "You are already on the waitlist for this class.";
                        } else {
                            message = "You are already enrolled in this class.";
                        }
                    } else {
                        // Check class capacity and current enrolled count
                        String capacitySql = "SELECT C.max_capacity, " +
                                             "COUNT(CASE WHEN CE.waitlist_flag = 'No' AND CE.enrollment_status = 'Enrolled' THEN 1 END) AS enrolled_count " +
                                             "FROM Class C " +
                                             "LEFT JOIN Class_Enrollment CE ON C.class_id = CE.class_id " +
                                             "WHERE C.class_id = ? " +
                                             "GROUP BY C.class_id, C.max_capacity";
                        PreparedStatement capacityPs = conn.prepareStatement(capacitySql);
                        capacityPs.setInt(1, classId);
                        ResultSet capacityRs = capacityPs.executeQuery();

                        if (capacityRs.next()) {
                            int maxCapacity = capacityRs.getInt("max_capacity");
                            int enrolledCount = capacityRs.getInt("enrolled_count");

                            // Generate the next enrollment_id manually to match the project schema
                            Statement idStmt = conn.createStatement();
                            ResultSet idRs = idStmt.executeQuery(
                                "SELECT IFNULL(MAX(enrollment_id), 0) + 1 AS new_id FROM Class_Enrollment"
                            );
                            idRs.next();
                            int newEnrollmentId = idRs.getInt("new_id");
                            idRs.close();
                            idStmt.close();

                            if (enrolledCount < maxCapacity) {
                                String enrollSql = "INSERT INTO Class_Enrollment " +
                                                   "(enrollment_id, member_id, class_id, enrollment_date, enrollment_status, waitlist_flag) " +
                                                   "VALUES (?, ?, ?, NOW(), 'Enrolled', 'No')";
                                PreparedStatement enrollPs = conn.prepareStatement(enrollSql);
                                enrollPs.setInt(1, newEnrollmentId);
                                enrollPs.setInt(2, memberId);
                                enrollPs.setInt(3, classId);
                                enrollPs.executeUpdate();
                                enrollPs.close();

                                message = "Successfully enrolled in the class.";
                            } else {
                                String waitlistSql = "INSERT INTO Class_Enrollment " +
                                                     "(enrollment_id, member_id, class_id, enrollment_date, enrollment_status, waitlist_flag) " +
                                                     "VALUES (?, ?, ?, NOW(), 'Waitlisted', 'Yes')";
                                PreparedStatement waitlistPs = conn.prepareStatement(waitlistSql);
                                waitlistPs.setInt(1, newEnrollmentId);
                                waitlistPs.setInt(2, memberId);
                                waitlistPs.setInt(3, classId);
                                waitlistPs.executeUpdate();
                                waitlistPs.close();

                                message = "Class is full. You have been added to the waitlist.";
                            }
                        }

                        capacityRs.close();
                        capacityPs.close();
                    }
                } else if ("cancel".equals(action)) {
                    if (!alreadyExists) {
                        message = "You are not enrolled in this class.";
                    } else {
                        // Remove the member's enrollment or waitlist record
                        String deleteSql = "DELETE FROM Class_Enrollment WHERE enrollment_id = ?";
                        PreparedStatement deletePs = conn.prepareStatement(deleteSql);
                        deletePs.setInt(1, enrollmentId);
                        deletePs.executeUpdate();
                        deletePs.close();

                        // If the canceled record was enrolled, promote the next waitlisted member
                        if ("Enrolled".equalsIgnoreCase(enrollmentStatus)) {
                            String promoteFindSql = "SELECT enrollment_id FROM Class_Enrollment " +
                                                    "WHERE class_id = ? AND waitlist_flag = 'Yes' AND enrollment_status = 'Waitlisted' " +
                                                    "ORDER BY enrollment_date ASC LIMIT 1";
                            PreparedStatement promoteFindPs = conn.prepareStatement(promoteFindSql);
                            promoteFindPs.setInt(1, classId);
                            ResultSet promoteRs = promoteFindPs.executeQuery();

                            if (promoteRs.next()) {
                                int promoteId = promoteRs.getInt("enrollment_id");
                                String promoteSql = "UPDATE Class_Enrollment " +
                                                    "SET enrollment_status = 'Enrolled', waitlist_flag = 'No' " +
                                                    "WHERE enrollment_id = ?";
                                PreparedStatement promotePs = conn.prepareStatement(promoteSql);
                                promotePs.setInt(1, promoteId);
                                promotePs.executeUpdate();
                                promotePs.close();
                            }

                            promoteRs.close();
                            promoteFindPs.close();
                            message = "Enrollment canceled.";
                        } else {
                            message = "Removed from waitlist.";
                        }
                    }
                }
            }

            membershipRs.close();
            membershipPs.close();
        }
    } catch (Exception e) {
        message = "Error: " + e.getMessage();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Class Enrollment - FitHub</title>
  <style>
    body { font-family: Arial, sans-serif; background: #1a1a1a; color: #fff; margin: 0; padding: 2rem; }
    h1 { color: #e8ff3a; }
    .card { background: #2a2a2a; border-radius: 10px; padding: 1.5rem; margin-bottom: 1.5rem; }
    .card h3 { color: #e8ff3a; margin-top: 0; }
    .message { background: #333; border-left: 4px solid #e8ff3a; padding: 1rem; margin-bottom: 1.5rem; border-radius: 6px; }
    .section-title { color: #e8ff3a; margin-bottom: 1rem; }
    table { width: 100%; border-collapse: collapse; background: #2a2a2a; border-radius: 10px; overflow: hidden; }
    th, td { padding: 12px; text-align: left; border-bottom: 1px solid #3a3a3a; }
    th { background: #222; color: #e8ff3a; }
    tr:last-child td { border-bottom: none; }
    .status {
      display: inline-block;
      padding: 4px 10px;
      border-radius: 999px;
      font-size: 0.85rem;
      font-weight: bold;
    }
    .enrolled { background: #244d24; color: #b9ffb9; }
    .waitlisted { background: #5a4a14; color: #ffe58a; }
    .open { background: #1d3f5a; color: #a8ddff; }
    .full { background: #5a1f1f; color: #ffb3b3; }
    a.btn {
      display: inline-block;
      padding: 8px 16px;
      background: #e8ff3a;
      color: #000;
      font-weight: bold;
      border-radius: 6px;
      text-decoration: none;
    }
    a.btn.secondary {
      background: transparent;
      color: #e8ff3a;
      border: 1px solid #e8ff3a;
    }
    a.link { color: #ff6666; text-decoration: none; font-size: 0.95rem; }
    .muted { color: #aaa; }
  </style>
</head>
<body>
  <h1>Class Enrollment</h1>
  <p class="muted">Welcome, <%= firstName %>. View classes, enroll, cancel, or join a waitlist.</p>

  <% if (message != null && !message.equals("")) { %>
    <div class="message"><%= message %></div>
  <% } %>

  <div class="card">
    <h3>My Classes</h3>
    <table>
      <tr>
        <th>Class</th>
        <th>Date</th>
        <th>Time</th>
        <th>Status</th>
        <th>Action</th>
      </tr>
      <%
        try {
            String myClassesSql = "SELECT C.class_id, C.class_name, C.schedule_date, C.start_time, C.end_time, CE.enrollment_status " +
                                  "FROM Class_Enrollment CE, Class C " +
                                  "WHERE CE.class_id = C.class_id AND CE.member_id = ? " +
                                  "ORDER BY C.schedule_date, C.start_time";
            PreparedStatement myPs = conn.prepareStatement(myClassesSql);
            myPs.setInt(1, memberId);
            ResultSet myRs = myPs.executeQuery();

            boolean hasRows = false;
            while (myRs.next()) {
                hasRows = true;
                String status = myRs.getString("enrollment_status");
      %>
      <tr>
        <td><%= myRs.getString("class_name") %></td>
        <td><%= myRs.getString("schedule_date") %></td>
        <td><%= myRs.getString("start_time") %> - <%= myRs.getString("end_time") %></td>
        <td>
          <span class="status <%= "Waitlisted".equalsIgnoreCase(status) ? "waitlisted" : "enrolled" %>">
            <%= status %>
          </span>
        </td>
        <td>
          <a class="btn secondary" href="member_classes.jsp?action=cancel&class_id=<%= myRs.getInt("class_id") %>">
            <%= "Waitlisted".equalsIgnoreCase(status) ? "Leave Waitlist" : "Cancel" %>
          </a>
        </td>
      </tr>
      <%
            }
            if (!hasRows) {
      %>
      <tr>
        <td colspan="5">No current class enrollments or waitlist entries.</td>
      </tr>
      <%
            }
            myRs.close();
            myPs.close();
        } catch (Exception e) {
      %>
      <tr>
        <td colspan="5">Unable to load your classes.</td>
      </tr>
      <%
        }
      %>
    </table>
  </div>

  <div class="card">
    <h3>Available Classes</h3>
    <table>
      <tr>
        <th>Class</th>
        <th>Date</th>
        <th>Time</th>
        <th>Capacity</th>
        <th>Availability</th>
        <th>Your Status</th>
        <th>Action</th>
      </tr>
      <%
        try {
            String classSql = "SELECT C.class_id, C.class_name, C.description, C.schedule_date, C.start_time, C.end_time, C.max_capacity, " +
                              "COUNT(CASE WHEN CE.waitlist_flag = 'No' AND CE.enrollment_status = 'Enrolled' THEN 1 END) AS enrolled_count " +
                              "FROM Class C " +
                              "LEFT JOIN Class_Enrollment CE ON C.class_id = CE.class_id " +
                              "WHERE C.status = 'Scheduled' " +
                              "GROUP BY C.class_id, C.class_name, C.description, C.schedule_date, C.start_time, C.end_time, C.max_capacity " +
                              "ORDER BY C.schedule_date, C.start_time";
            PreparedStatement classPs = conn.prepareStatement(classSql);
            ResultSet classRs = classPs.executeQuery();

            while (classRs.next()) {
                int classId = classRs.getInt("class_id");
                int maxCapacity = classRs.getInt("max_capacity");
                int enrolledCount = classRs.getInt("enrolled_count");
                boolean isFull = enrolledCount >= maxCapacity;

                String statusSql = "SELECT enrollment_status FROM Class_Enrollment WHERE member_id = ? AND class_id = ?";
                PreparedStatement statusPs = conn.prepareStatement(statusSql);
                statusPs.setInt(1, memberId);
                statusPs.setInt(2, classId);
                ResultSet statusRs = statusPs.executeQuery();

                String myStatus = null;
                if (statusRs.next()) {
                    myStatus = statusRs.getString("enrollment_status");
                }

                statusRs.close();
                statusPs.close();
      %>
      <tr>
        <td>
          <strong><%= classRs.getString("class_name") %></strong><br>
          <span class="muted"><%= classRs.getString("description") %></span>
        </td>
        <td><%= classRs.getString("schedule_date") %></td>
        <td><%= classRs.getString("start_time") %> - <%= classRs.getString("end_time") %></td>
        <td><%= enrolledCount %> / <%= maxCapacity %></td>
        <td>
          <span class="status <%= isFull ? "full" : "open" %>">
            <%= isFull ? "Full" : "Open" %>
          </span>
        </td>
        <td>
          <% if ("Enrolled".equalsIgnoreCase(myStatus)) { %>
            <span class="status enrolled">Enrolled</span>
          <% } else if ("Waitlisted".equalsIgnoreCase(myStatus)) { %>
            <span class="status waitlisted">Waitlisted</span>
          <% } else { %>
            <span class="muted">Not enrolled</span>
          <% } %>
        </td>
        <td>
          <% if ("Enrolled".equalsIgnoreCase(myStatus)) { %>
            <a class="btn secondary" href="member_classes.jsp?action=cancel&class_id=<%= classId %>">Cancel</a>
          <% } else if ("Waitlisted".equalsIgnoreCase(myStatus)) { %>
            <a class="btn secondary" href="member_classes.jsp?action=cancel&class_id=<%= classId %>">Leave Waitlist</a>
          <% } else { %>
            <a class="btn" href="member_classes.jsp?action=enroll&class_id=<%= classId %>">
              <%= isFull ? "Join Waitlist" : "Enroll" %>
            </a>
          <% } %>
        </td>
      </tr>
      <%
            }
            classRs.close();
            classPs.close();
        } catch (Exception e) {
      %>
      <tr>
        <td colspan="7">Unable to load available classes.</td>
      </tr>
      <%
        } finally {
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
      %>
    </table>
  </div>

  <a href="member_dashboard.jsp" class="link">Back to Dashboard</a>
  &nbsp;&nbsp;
  <a href="logout.jsp" class="link">Logout</a>
</body>
</html>