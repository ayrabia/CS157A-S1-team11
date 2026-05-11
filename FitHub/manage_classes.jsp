<%@ include file="header.jsp" %>
<%@ page import="java.sql.*" %>
<%@ page session="true" %>

<%
if (session.getAttribute("staff_id") == null && 
    session.getAttribute("admin_id") == null) {
    response.sendRedirect("staff_login.jsp");
    return;
}

String message = "";
String messageType = "";

Connection conn = null;
PreparedStatement ps = null;
ResultSet rs = null;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/group11",
        "root",
        "YOUR_PASSWORD_HERE"
    );

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String action = request.getParameter("action");

        if ("add".equals(action)) {
            String status = request.getParameter("status");
            String scheduleDate = request.getParameter("schedule_date");
            String startTime = request.getParameter("start_time");
            String endTime = request.getParameter("end_time");

            boolean scheduled = "Scheduled".equalsIgnoreCase(status);

            String insertSql =
                "INSERT INTO `Class` " +
                "(class_name, description, max_capacity, schedule_date, start_time, end_time, staff_id, status) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

            ps = conn.prepareStatement(insertSql);
            ps.setString(1, request.getParameter("class_name"));
            ps.setString(2, request.getParameter("description"));
            ps.setInt(3, Integer.parseInt(request.getParameter("max_capacity")));

            if (scheduled) {
                ps.setString(4, scheduleDate);
                ps.setString(5, startTime);
                ps.setString(6, endTime);
            } else {
                ps.setNull(4, java.sql.Types.DATE);
                ps.setNull(5, java.sql.Types.TIME);
                ps.setNull(6, java.sql.Types.TIME);
            }

            ps.setInt(7, Integer.parseInt(request.getParameter("staff_id")));
            ps.setString(8, scheduled ? "Scheduled" : "Unscheduled");
            ps.executeUpdate();

            message = scheduled ? "Scheduled class created successfully." : "Unscheduled class created successfully.";
            messageType = "success";
        }

        if ("delete".equals(action)) {
            int classId = Integer.parseInt(request.getParameter("class_id"));

            ps = conn.prepareStatement("DELETE FROM `Class_Enrollment` WHERE class_id = ?");
            ps.setInt(1, classId);
            ps.executeUpdate();
            ps.close();

            ps = conn.prepareStatement("DELETE FROM `Class` WHERE class_id = ?");
            ps.setInt(1, classId);
            ps.executeUpdate();

            message = "Class session removed successfully.";
            messageType = "success";
        }

        if ("toggle_status".equals(action)) {
            int classId = Integer.parseInt(request.getParameter("class_id"));

            PreparedStatement getStatusPs = conn.prepareStatement(
                "SELECT status FROM `Class` WHERE class_id = ?"
            );
            getStatusPs.setInt(1, classId);
            ResultSet statusRs = getStatusPs.executeQuery();

            if (statusRs.next()) {
                String currentStatus = statusRs.getString("status");

                if ("Scheduled".equalsIgnoreCase(currentStatus)) {
                    PreparedStatement updateClassPs = conn.prepareStatement(
                        "UPDATE `Class` " +
                        "SET status = 'Unscheduled', schedule_date = NULL, start_time = NULL, end_time = NULL " +
                        "WHERE class_id = ?"
                    );
                    updateClassPs.setInt(1, classId);
                    updateClassPs.executeUpdate();
                    updateClassPs.close();

                    PreparedStatement cancelEnrollmentsPs = conn.prepareStatement(
                        "DELETE FROM `Class_Enrollment` WHERE class_id = ?"
                    );
                    cancelEnrollmentsPs.setInt(1, classId);
                    cancelEnrollmentsPs.executeUpdate();
                    cancelEnrollmentsPs.close();

                    message = "Class unscheduled and all member enrollments removed.";
                    messageType = "success";
                } else {
                    // do nothing (handled by schedule_with_time instead)
                }
            }

            statusRs.close();
            getStatusPs.close();
        }

        if ("schedule_with_time".equals(action)) {
            int classId = Integer.parseInt(request.getParameter("class_id"));
            String scheduleDate = request.getParameter("schedule_date");
            String startTime = request.getParameter("start_time");
            String endTime = request.getParameter("end_time");

            if (scheduleDate == null || scheduleDate.trim().equals("") ||
                startTime == null || startTime.trim().equals("") ||
                endTime == null || endTime.trim().equals("")) {

                message = "Date, start time, and end time are required to schedule a class.";
                messageType = "error";
            } else {
                PreparedStatement updateClassPs = conn.prepareStatement(
                    "UPDATE `Class` " +
                    "SET status = 'Scheduled', schedule_date = ?, start_time = ?, end_time = ? " +
                    "WHERE class_id = ?"
                );
                updateClassPs.setString(1, scheduleDate);
                updateClassPs.setString(2, startTime);
                updateClassPs.setString(3, endTime);
                updateClassPs.setInt(4, classId);
                updateClassPs.executeUpdate();
                updateClassPs.close();

                message = "Class scheduled successfully.";
                messageType = "success";
            }
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Manage Classes</title>
    <style>
        body { font-family: Arial; background:#1a1a1a; color:white; padding:2rem; }
        h1, h2 { color:#e8ff3a; }
        .box { background:#2a2a2a; padding:1.5rem; border-radius:10px; margin-bottom:2rem; }
        input, select {
            width:100%;
            padding:8px;
            margin:6px 0;
            border-radius:6px;
            border:1px solid #444;
            background:#333;
            color:white;
        }
        button {
            padding:8px 14px;
            border:none;
            border-radius:6px;
            font-weight:bold;
            cursor:pointer;
        }
        .btn-yellow { background:#e8ff3a; color:black; }
        .btn-red { background:#ff6666; color:black; }
        table { width:100%; border-collapse:collapse; background:#2a2a2a; }
        th, td { padding:10px; border-bottom:1px solid #444; text-align:left; }
        th { color:#e8ff3a; background:#222; }
        .success { color:#44ff88; }
        .error { color:#ff6666; }
        a { color:#e8ff3a; }
    </style>
</head>
<body>

<h1>Manage Class Sessions</h1>

<% if (!message.equals("")) { %>
    <p id="statusMessage" class="<%= messageType %>"><%= message %></p>
<% } %>

<h2>Create Class Session</h2>

<form method="post" class="box">
    <input type="hidden" name="action" value="add">

    <input type="text" name="class_name" placeholder="Class Name" required>
    <input type="text" name="description" placeholder="Description" required>
    <input type="number" name="max_capacity" min="1" placeholder="Max Capacity" required>
    
    <select name="status" id="createStatus" onchange="toggleCreateScheduleFields()">
    <option value="Scheduled">Scheduled</option>
    <option value="Unscheduled">Unscheduled</option>
    </select>

    <div id="createScheduleFields">
        <input type="date" name="schedule_date" id="createDate">
        <input type="time" name="start_time" id="createStartTime">
        <input type="time" name="end_time" id="createEndTime">
    </div>

    <select name="staff_id" required>
        <option value="">Select Trainer</option>
        <%
            PreparedStatement trainerPs = conn.prepareStatement(
                "SELECT s.staff_id, s.first_name, s.last_name, t.specialization " +
                "FROM `Staff` s " +
                "JOIN `Trainer` t ON s.staff_id = t.staff_id " +
                "WHERE s.role = 'Trainer' AND s.status = 'Active' " +
                "ORDER BY s.first_name, s.last_name"
            );
            ResultSet trainerRs = trainerPs.executeQuery();

            while (trainerRs.next()) {
        %>
            <option value="<%= trainerRs.getInt("staff_id") %>">
                <%= trainerRs.getString("first_name") %>
                <%= trainerRs.getString("last_name") %>
                - <%= trainerRs.getString("specialization") %>
            </option>
        <%
            }
            trainerRs.close();
            trainerPs.close();
        %>
    </select>

    <button class="btn-yellow" type="submit">Create Class</button>
</form>

<h2>Existing Class Sessions</h2>

<div id="classTableSection" data-realtime>
<table>
    <tr>
        <th>ID</th>
        <th>Class</th>
        <th>Description</th>
        <th>Date</th>
        <th>Time</th>
        <th>Trainer</th>
        <th>Capacity</th>
        <th>Enrolled</th>
        <th>Status</th>
        <th>Action</th>
    </tr>

<%
    String classSql =
        "SELECT c.class_id, c.class_name, c.description, c.max_capacity, " +
        "c.schedule_date, c.start_time, c.end_time, c.status, " +
        "CONCAT(s.first_name, ' ', s.last_name) AS trainer_name, " +
        "COUNT(CASE WHEN ce.enrollment_status = 'Enrolled' THEN 1 END) AS enrolled_count " +
        "FROM `Class` c " +
        "LEFT JOIN `Staff` s ON c.staff_id = s.staff_id " +
        "LEFT JOIN `Class_Enrollment` ce ON c.class_id = ce.class_id " +
        "GROUP BY c.class_id, c.class_name, c.description, c.max_capacity, " +
        "c.schedule_date, c.start_time, c.end_time, c.status, s.first_name, s.last_name " +
        "ORDER BY c.schedule_date, c.start_time";

    ps = conn.prepareStatement(classSql);
    rs = ps.executeQuery();

    while (rs.next()) {
%>
    <tr>
        <td><%= rs.getInt("class_id") %></td>
        <td><%= rs.getString("class_name") %></td>
        <td><%= rs.getString("description") %></td>
        <td><%= "Scheduled".equalsIgnoreCase(rs.getString("status")) ? rs.getString("schedule_date") : "--" %></td>
        <td>
            <%= "Scheduled".equalsIgnoreCase(rs.getString("status")) 
                ? rs.getString("start_time") + " - " + rs.getString("end_time") 
                : "--" 
            %>
        </td>
        <td><%= rs.getString("trainer_name") %></td>
        <td><%= rs.getInt("max_capacity") %></td>
        <td><%= rs.getInt("enrolled_count") %></td>
        <td><%= rs.getString("status") %></td>
        <td>
            <form method="post" onsubmit="return confirm('Remove this class session?');">
                <input type="hidden" name="action" value="delete">
                <input type="hidden" name="class_id" value="<%= rs.getInt("class_id") %>">
                <button class="btn-red" type="submit">Remove</button>
            </form>
            <% if ("Scheduled".equalsIgnoreCase(rs.getString("status"))) { %>
                <form method="post" style="display:inline;">
                    <input type="hidden" name="action" value="toggle_status">
                    <input type="hidden" name="class_id" value="<%= rs.getInt("class_id") %>">
                    <button type="submit" class="btn-yellow">
                        Cancel
                    </button>
                </form>
            <% } else { %>
                <button type="button"
                        class="btn-yellow"
                        data-id="<%= rs.getInt("class_id") %>"
                        onclick="showScheduleForm(this)">
                    Schedule
                </button>

                <form method="post"
                      id="scheduleForm_<%= rs.getInt("class_id") %>"
                      style="display:none; margin-top:8px;">
                    <input type="hidden" name="action" value="schedule_with_time">
                    <input type="hidden" name="class_id" value="<%= rs.getInt("class_id") %>">

                    <br>
                    <input type="date" name="schedule_date" required style="width:auto;">
                    <input type="time" name="start_time" required style="width:auto;">
                    <input type="time" name="end_time" required style="width:auto;">

                    <button type="submit" class="btn-yellow">Confirm</button>

                    <button type="button"
                            class="btn-red"
                            data-id="<%= rs.getInt("class_id") %>"
                            onclick="hideScheduleForm(this)">
                        Close
                    </button>
                </form>
            <% } %>
        </td>
    </tr>
<%
    }
%>
</table>
</div>

<br>
<a href="staff_dashboard.jsp">Back to Dashboard</a>

<script>
let pauseRealtime = false;

function refreshRealtimeSections() {
    if (pauseRealtime) {
        return;
    }

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

setInterval(refreshRealtimeSections, 5000);
</script>

<script>
function showScheduleForm(btn) {
    pauseRealtime = true;

    const classId = btn.getAttribute("data-id");
    const form = document.getElementById("scheduleForm_" + classId);

    if (form) {
        form.style.display = "inline-block";
    }
}

function hideScheduleForm(btn) {
    pauseRealtime = false;

    const classId = btn.getAttribute("data-id");
    const form = document.getElementById("scheduleForm_" + classId);

    if (form) {
        form.style.display = "none";
    }
}
</script>

<script>
function toggleCreateScheduleFields() {
    const status = document.getElementById("createStatus").value;
    const fields = document.getElementById("createScheduleFields");

    if (status === "Scheduled") {
        fields.style.display = "block";
    } else {
        fields.style.display = "none";
    }
}

// run on page load
document.addEventListener("DOMContentLoaded", function () {
    toggleCreateScheduleFields();
});
</script>

<script>
window.addEventListener("DOMContentLoaded", function () {
    const msg = document.getElementById("statusMessage");

    if (msg) {
        setTimeout(() => {
            msg.style.transition = "opacity 0.5s ease";
            msg.style.opacity = "0";

            setTimeout(() => {
                msg.style.display = "none";
            }, 500);
        }, 5000); // 5 seconds
    }
});
</script>

</body>
</html>

<%
} catch (Exception e) {
    out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
} finally {
    if (rs != null) try { rs.close(); } catch (Exception e) {}
    if (ps != null) try { ps.close(); } catch (Exception e) {}
    if (conn != null) try { conn.close(); } catch (Exception e) {}
}
%>