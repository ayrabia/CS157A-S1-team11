<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Staff Dashboard - FitHub</title>
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
        <h1>Staff Dashboard</h1>
        <a href="index.html" class="logout-btn">Logout</a>
    </header>

    <div class="container">
        <h2>Welcome, Staff Member!</h2>
        <p>This is your staff dashboard. Here you can manage gym operations.</p>

        <div class="dashboard-grid">
            <div class="card">
                <h3>Member Management</h3>
                <p>Create, update, and manage member accounts.</p>
                <ul>
                    <li>Active Members: 150</li>
                    <li>Pending Approvals: 5</li>
                    <li>Frozen Accounts: 3</li>
                </ul>
            </div>

            <div class="card">
                <h3>Class Management</h3>
                <p>Create and schedule fitness classes.</p>
                <ul>
                    <li>Yoga Class - Monday 9:00 AM (15/20 enrolled)</li>
                    <li>HIIT Training - Wednesday 6:00 PM (18/20 enrolled)</li>
                    <li>Spin Class - Friday 7:00 PM (12/15 enrolled)</li>
                </ul>
            </div>

            <div class="card">
                <h3>Payment Processing</h3>
                <p>Record and track membership payments.</p>
                <ul>
                    <li>Pending Payments: 8</li>
                    <li>Overdue: 2</li>
                    <li>This Month's Revenue: $7,450</li>
                </ul>
            </div>

            <div class="card">
                <h3>Attendance Tracking</h3>
                <p>Monitor member check-ins and class attendance.</p>
                <ul>
                    <li>Today's Check-ins: 45</li>
                    <li>Class Attendance Rate: 85%</li>
                    <li>Late Arrivals: 3</li>
                </ul>
            </div>
        </div>
    </div>
</body>
</html>