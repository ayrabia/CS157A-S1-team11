<%@ include file="header.jsp" %>
<%@ page import="java.sql.*" %>
<%@ page session="true" %>

<%
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
        "jdbc:mysql://localhost:3306/group11",
        "root",
        "YOUR_PASSWORD_HERE"
    );

    String action = request.getParameter("action");
    String classIdParam = request.getParameter("class_id");

    if (action != null && classIdParam != null) {
        int classId = Integer.parseInt(classIdParam);

        if ("enroll".equals(action)) {
            PreparedStatement checkPs = conn.prepareStatement(
                "SELECT c.max_capacity, c.status, c.schedule_date, c.start_time, c.end_time, " +
                "COUNT(CASE WHEN ce.enrollment_status = 'Enrolled' THEN 1 END) AS enrolled_count " +
                "FROM `Class` c " +
                "LEFT JOIN `Class_Enrollment` ce ON c.class_id = ce.class_id " +
                "WHERE c.class_id = ? " +
                "GROUP BY c.class_id, c.max_capacity, c.status, c.schedule_date, c.start_time, c.end_time"
            );
            checkPs.setInt(1, classId);
            ResultSet checkRs = checkPs.executeQuery();

            if (checkRs.next()) {
                int maxCapacity = checkRs.getInt("max_capacity");
                int enrolledCount = checkRs.getInt("enrolled_count");
                String status = checkRs.getString("status");
                String date = checkRs.getString("schedule_date");
                String start = checkRs.getString("start_time");
                String end = checkRs.getString("end_time");

                boolean hasSession =
                    "Scheduled".equalsIgnoreCase(status) &&
                    date != null && !date.trim().equals("") &&
                    start != null && !start.trim().equals("") &&
                    end != null && !end.trim().equals("");

                if (!hasSession) {
                    message = "This class is unavailable.";
                } else if (enrolledCount >= maxCapacity) {
                    message = "This class is closed because it is full.";
                } else {
                    PreparedStatement alreadyPs = conn.prepareStatement(
                        "SELECT enrollment_id FROM `Class_Enrollment` WHERE member_id = ? AND class_id = ?"
                    );
                    alreadyPs.setInt(1, memberId);
                    alreadyPs.setInt(2, classId);
                    ResultSet alreadyRs = alreadyPs.executeQuery();

                    if (alreadyRs.next()) {
                        message = "You are already enrolled in this class.";
                    } else {
                        Statement idStmt = conn.createStatement();
                        ResultSet idRs = idStmt.executeQuery(
                            "SELECT IFNULL(MAX(enrollment_id), 0) + 1 AS next_id FROM `Class_Enrollment`"
                        );
                        idRs.next();
                        int nextId = idRs.getInt("next_id");
                        idRs.close();
                        idStmt.close();

                        PreparedStatement enrollPs = conn.prepareStatement(
                            "INSERT INTO `Class_Enrollment` " +
                            "(enrollment_id, member_id, class_id, enrollment_date, enrollment_status, waitlist_flag) " +
                            "VALUES (?, ?, ?, CURDATE(), 'Enrolled', 'No')"
                        );
                        enrollPs.setInt(1, nextId);
                        enrollPs.setInt(2, memberId);
                        enrollPs.setInt(3, classId);
                        enrollPs.executeUpdate();
                        enrollPs.close();

                        message = "Successfully enrolled.";
                    }

                    alreadyRs.close();
                    alreadyPs.close();
                }
            }

            checkRs.close();
            checkPs.close();
        }

        if ("cancel".equals(action)) {
            PreparedStatement deletePs = conn.prepareStatement(
                "DELETE FROM `Class_Enrollment` WHERE member_id = ? AND class_id = ?"
            );
            deletePs.setInt(1, memberId);
            deletePs.setInt(2, classId);
            int rows = deletePs.executeUpdate();
            deletePs.close();

            if (rows > 0) {
                message = "Enrollment cancelled.";
            } else {
                message = "You were not enrolled in that class.";
            }
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Member Classes</title>
    <style>
        body { font-family: Arial; background:#1a1a1a; color:white; padding:2rem; }
        h1, h2 { color:#e8ff3a; }
        .card { background:#2a2a2a; padding:1.5rem; border-radius:10px; margin-bottom:1.5rem; }
        table { width:100%; border-collapse:collapse; background:#2a2a2a; }
        th, td { padding:12px; border-bottom:1px solid #444; text-align:left; }
        th { color:#e8ff3a; background:#222; }
        .message { background:#333; border-left:4px solid #e8ff3a; padding:1rem; margin-bottom:1rem; }
        .status { padding:4px 10px; border-radius:20px; font-weight:bold; font-size:0.85rem; }
        .open { background:#1d3f5a; color:#a8ddff; }
        .closed { background:#5a1f1f; color:#ffb3b3; }
        .unavailable { background:#555; color:#ccc; }
        .enrolled { background:#244d24; color:#b9ffb9; }
        .btn {
            display:inline-block;
            padding:8px 14px;
            border-radius:6px;
            font-weight:bold;
            text-decoration:none;
            background:#e8ff3a;
            color:black;
        }
        .btn-gray {
            background:#666;
            color:#bbb;
            pointer-events:none;
            cursor:not-allowed;
        }
        .btn-outline {
            background:transparent;
            color:#e8ff3a;
            border:1px solid #e8ff3a;
        }
        .muted { color:#aaa; }
        a { color:#e8ff3a; }
    </style>
</head>
<body>

<h1>Classes</h1>
<p class="muted">Welcome, <%= firstName %>.</p>

<% if (!message.equals("")) { %>
    <div class="message"><%= message %></div>
<% } %>

<div class="card" id="myClassesSection" data-realtime>
<h2>My Classes</h2>

<table>
    <tr>
        <th>Class</th>
        <th>Date</th>
        <th>Time</th>
        <th>Status</th>
        <th>Action</th>
    </tr>

<%
    PreparedStatement myPs = conn.prepareStatement(
        "SELECT c.class_id, c.class_name, c.schedule_date, c.start_time, c.end_time, " +
        "c.status AS class_status, ce.enrollment_status " +
        "FROM `Class_Enrollment` ce " +
        "JOIN `Class` c ON ce.class_id = c.class_id " +
        "WHERE ce.member_id = ? " +
        "ORDER BY c.schedule_date, c.start_time"
    );
    myPs.setInt(1, memberId);
    ResultSet myRs = myPs.executeQuery();

    boolean hasMyClasses = false;

    while (myRs.next()) {
        hasMyClasses = true;
%>
    <tr>
        <td><%= myRs.getString("class_name") %></td>
        <td><%= myRs.getString("schedule_date") %></td>
        <td><%= myRs.getString("start_time") %> - <%= myRs.getString("end_time") %></td>
        <td><span class="status enrolled"><%= myRs.getString("enrollment_status") %></span></td>
        <td>
            <a class="btn btn-outline" href="member_classes.jsp?action=cancel&class_id=<%= myRs.getInt("class_id") %>">
                Cancel
            </a>
        </td>
    </tr>
<%
    }

    if (!hasMyClasses) {
%>
    <tr>
        <td colspan="5">You are not enrolled in any classes.</td>
    </tr>
<%
    }

    myRs.close();
    myPs.close();
%>
</table>
</div>

<div class="card" id="availableClassesSection" data-realtime>
<h2>Available Classes</h2>

<table>
    <tr>
        <th>Class</th>
        <th>Description</th>
        <th>Trainer</th>
        <th>Date</th>
        <th>Time</th>
        <th>Capacity</th>
        <th>Availability</th>
        <th>Action</th>
    </tr>

<%
    String classSql =
        "SELECT c.class_id, c.class_name, c.description, c.max_capacity, " +
        "c.schedule_date, c.start_time, c.end_time, c.status, " +
        "CONCAT(s.first_name, ' ', s.last_name) AS trainer_name, " +
        "COUNT(CASE WHEN ce.enrollment_status = 'Enrolled' THEN 1 END) AS enrolled_count, " +
        "MAX(CASE WHEN ce.member_id = ? THEN ce.enrollment_status ELSE NULL END) AS my_status " +
        "FROM `Class` c " +
        "LEFT JOIN `Staff` s ON c.staff_id = s.staff_id " +
        "LEFT JOIN `Class_Enrollment` ce ON c.class_id = ce.class_id " +
        "GROUP BY c.class_id, c.class_name, c.description, c.max_capacity, " +
        "c.schedule_date, c.start_time, c.end_time, c.status, s.first_name, s.last_name " +
        "ORDER BY c.schedule_date, c.start_time, c.class_name";

    PreparedStatement classPs = conn.prepareStatement(classSql);
    classPs.setInt(1, memberId);
    ResultSet classRs = classPs.executeQuery();

    while (classRs.next()) {
        int classId = classRs.getInt("class_id");
        int maxCapacity = classRs.getInt("max_capacity");
        int enrolledCount = classRs.getInt("enrolled_count");

        String status = classRs.getString("status");
        String date = classRs.getString("schedule_date");
        String start = classRs.getString("start_time");
        String end = classRs.getString("end_time");
        String myStatus = classRs.getString("my_status");

        boolean hasSession =
            "Scheduled".equalsIgnoreCase(status) &&
            date != null && !date.trim().equals("") &&
            start != null && !start.trim().equals("") &&
            end != null && !end.trim().equals("");

        boolean isFull = enrolledCount >= maxCapacity;
%>
    <tr>
        <td><%= classRs.getString("class_name") %></td>
        <td><%= classRs.getString("description") %></td>
        <td><%= classRs.getString("trainer_name") == null ? "Not assigned" : classRs.getString("trainer_name") %></td>
        <td><%= hasSession ? date : "Unknown" %></td>
        <td><%= hasSession ? start + " - " + end : "Unknown" %></td>
        <td><%= hasSession ? enrolledCount + " / " + maxCapacity : "Unknown" %></td>
        <td>
            <% if (!hasSession) { %>
                <span class="status unavailable">Unavailable</span>
            <% } else if (isFull) { %>
                <span class="status closed">Closed</span>
            <% } else { %>
                <span class="status open">Open</span>
            <% } %>
        </td>
        <td>
            <% if (myStatus != null) { %>
                <span class="status enrolled">Enrolled</span>
            <% } else if (!hasSession) { %>
                <a class="btn btn-gray">Unavailable</a>
            <% } else if (isFull) { %>
                <a class="btn btn-gray">Closed</a>
            <% } else { %>
                <a class="btn" href="member_classes.jsp?action=enroll&class_id=<%= classId %>">Enroll</a>
            <% } %>
        </td>
    </tr>
<%
    }

    classRs.close();
    classPs.close();
%>
</table>
</div>

<a href="member_dashboard.jsp">Back to Dashboard</a>

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

// refresh every 2 seconds
setInterval(refreshRealtimeSections, 2000);
</script>

</body>
</html>

<%
} catch (Exception e) {
    out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
} finally {
    if (conn != null) try { conn.close(); } catch (Exception e) {}
}
%>