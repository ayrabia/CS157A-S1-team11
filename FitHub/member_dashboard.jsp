<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Member Dashboard - FitHub</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f4f4f4;
        }
        header {
            background-color: #4CAF50;
            color: white;
            padding: 20px;
            text-align: center;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        .dashboard-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin-top: 30px;
        }
        .card {
            background-color: white;
            padding: 20px;
            border-radius: 5px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        .card h3 {
            color: #4CAF50;
            margin-top: 0;
        }
        .logout-btn {
            background-color: #f44336;
            color: white;
            padding: 10px 20px;
            text-decoration: none;
            border-radius: 5px;
            float: right;
            margin-top: -10px;
        }
        .logout-btn:hover {
            background-color: #d32f2f;
        }
    </style>
</head>
<body>
    <header>
        <h1>Member Dashboard</h1>
        <a href="index.html" class="logout-btn">Logout</a>
    </header>

    <div class="container">
        <h2>Welcome, Member!</h2>
        <p>This is your personal dashboard. Here you can manage your gym activities.</p>

        <div class="dashboard-grid">
            <div class="card">
                <h3>Membership Status</h3>
                <p>View your current membership plan and status.</p>
                <p><strong>Status:</strong> Active</p>
                <p><strong>Plan:</strong> Premium Monthly</p>
                <p><strong>Expires:</strong> 2026-04-15</p>
            </div>

            <div class="card">
                <h3>Class Enrollment</h3>
                <p>Enroll in or manage your fitness classes.</p>
                <ul>
                    <li>Yoga Class - Monday 9:00 AM</li>
                    <li>HIIT Training - Wednesday 6:00 PM</li>
                </ul>
            </div>

            <div class="card">
                <h3>Attendance History</h3>
                <p>View your check-in and check-out history.</p>
                <ul>
                    <li>Yoga - 2026-03-10: 8:45 AM - 10:00 AM</li>
                    <li>HIIT - 2026-03-12: 5:50 PM - 7:00 PM</li>
                </ul>
            </div>

            <div class="card">
                <h3>Payment History</h3>
                <p>View your payment records.</p>
                <ul>
                    <li>$49.99 - March 1, 2026 - Completed</li>
                    <li>$49.99 - February 1, 2026 - Completed</li>
                </ul>
            </div>
        </div>
    </div>
</body>
</html>