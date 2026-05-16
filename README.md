# FitHub - Gym Management System

**CS157A - Group 11**
Ayman Rabia, Rachel Tran, Minh Trinh
San Jose State University

---

## Overview

FitHub is a web-based gym management system built for CS157A. It supports member account management, class enrollment, attendance tracking, and payment processing. Members have a portal for their own gym activity. Staff and admins have tools to manage day-to-day operations.

---

## Features

### Member
- Log in and manage a personal account
- View membership plan, status (Active / Frozen / Expired), and dates
- Enroll in or cancel fitness classes (waitlist support when full)
- View personal attendance history
- Delete account

### Staff
- Check members in and verify active membership status
- Manage member accounts (walk-in registration, freeze, reactivate, assign plan)
- Create and manage membership plans (add, update price/duration, deactivate)
- Record and view membership payments
- Create and manage class sessions (schedule, capacity, trainer assignment)
- View check-in logs and payment history
- Find gym locations

### Admin
- All staff capabilities
- Add staff, update staff role and status

---

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | HTML, CSS, JavaScript |
| Backend | Java, JSP |
| Web Server | Apache Tomcat 11.0.18 |
| Database | MySQL Community Server 8.0 |
| DB Tool | MySQL Workbench 8.0 |
| JDBC Driver | mysql-connector-j 9.6.0 |

---

## Database Schema

| Table | Description |
|---|---|
| `Members` | Registered gym members |
| `Admin` | Admin accounts (separate from Staff) |
| `Staff` | Gym employees -- role is Trainer or Host |
| `Trainer` | Subclass of Staff with specialization and certification |
| `Membership_Plan` | Available membership tiers and pricing |
| `Membership` | A member's subscription, linked to a plan |
| `Payment` | Payment transactions tied to a membership |
| `Class` | Scheduled fitness classes assigned to trainers |
| `Class_Enrollment` | Member-class enrollment (with waitlist flag) |
| `AttendanceLog` | Check-in and check-out records |
| `Gym` | Physical gym location info |

---

## Access Control

| Role | Access |
|---|---|
| Member | Own profile, own enrollment, own attendance and membership |
| Staff | Member management, classes, payments, check-ins, plans, gym lookup |
| Admin | All staff actions + manage staff accounts |

---

## Setup

### Prerequisites
- Apache Tomcat 11.0.18
- MySQL Community Server 8.0
- MySQL JDBC driver (mysql-connector-j-9.6.0.jar) placed in Tomcat's `lib/` folder
- Java JDK 17+

### Database
1. Open MySQL Workbench
2. Run `sql/database_setup.sql` to create the `group11` schema and tables
3. Run `sql/sample_data.sql` to load sample records

### Application
1. Clone the repo
   ```bash
   git clone https://github.com/ayrabia/CS157A-S1-team11
   ```
2. Update the MySQL password in each JSP file's `DriverManager.getConnection(...)` call
3. Copy the `FitHub/` folder into Tomcat's `webapps/` directory as `fithub/`
4. Start Tomcat
   ```bash
   /path/to/tomcat/bin/startup.sh
   ```
5. Open `http://localhost:8080/fithub/` in a browser

---

## Sample Data

Each table has 10 rows. Highlights:

- 10 Members with statuses Active, Frozen, and Expired
- 13 Staff (3 Hosts, 10 Trainers)
- 10 Membership Plans including Basic Monthly, VIP Access, Student Semester, and more
- 10 Scheduled and completed fitness classes
- 10 Gym locations across the South Bay

---

## Authors

| Name | Email |
|---|---|
| Ayman Rabia | ayman.rabia@sjsu.edu |
| Rachel Tran | rachel.n.tran@sjsu.edu |
| Minh Trinh | minh.trinh@sjsu.edu |
