# FitHub — Gym Management System

**CS157A — Group 11**
Ayman Rabia · Rachel Tran · Minh Trinh
San José State University

---

## Overview

FitHub is a web-based gym management system designed to centralize and streamline fitness center operations. The platform supports member account management, class enrollment, attendance tracking, and payment processing — all backed by a structured relational database. Members get an easy-to-use portal for their gym activity, while staff and administrators get powerful tools to manage daily operations.

---

## Features

### Member Features
- Register and manage a personal account
- View current membership plan, status (Active / Frozen / Expired), start and end dates
- Enroll in or cancel fitness classes (with waitlist support if a class is full)
- View check-in and check-out attendance history

### Staff Features
- Manage member accounts (create, update, freeze, reactivate)
- Create and manage membership plans (add, update, deactivate)
- Record and track membership payments
- Create and manage class sessions (schedule, capacity, trainer assignment)
- Check in members and verify active membership status

### Administrator Features
- All staff capabilities
- Reset staff passwords and change staff roles
- Delete staff accounts
- Override membership statuses
- Access all system records

---

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | HTML, CSS, JavaScript |
| Backend | Java, JSP |
| Web Server | Apache Tomcat 9.0.105 |
| Database | MySQL Community Server 8.0.42 |
| DB Tool | MySQL Workbench 8.0.42 |


---

## System Architecture

FitHub uses a **three-tier architecture**:

```
Browser Client  →  Web Server (Apache Tomcat / Java / JSP)  →  Database Server (MySQL)
```

1. **Client Layer** — Users interact via a web browser. The frontend is built with HTML, CSS, and JavaScript.
2. **Web Server Layer** — Apache Tomcat hosts the application. Java/JSP handles authentication, role-based access control, enrollment validation, and all database communication.
3. **Database Layer** — MySQL stores all persistent data: members, staff, classes, memberships, payments, and attendance logs.

---

## Database Schema

The system uses the following relational tables:

| Table | Description |
|---|---|
| `Members` | Registered gym members and their profile info |
| `Staff` | Gym employees and administrators |
| `Trainer` | Subclass of Staff with specialization and certification |
| `MembershipPlan` | Available gym membership tiers and pricing |
| `Membership` | A member's active subscription, linked to a plan |
| `Payment` | Payment transactions tied to a membership |
| `Class` | Scheduled fitness classes assigned to trainers |
| `ClassEnrollment` | Many-to-many associative table for member-class enrollment |
| `AttendanceLog` | Check-in and check-out records for members |
| `Gym` | Physical gym location information |

### Key Relationships
- A **Member** can have many **Memberships**; each Membership is based on one **MembershipPlan**
- A **Member** can make many **Payments**; each Payment pays for one Membership
- A **Trainer** (subclass of Staff) can lead many **Classes**
- A **Member** can enroll in many **Classes** through **ClassEnrollment** (with waitlist support)
- Member gym visits are tracked in **AttendanceLog**, optionally linked to a class

---

## Security

- Passwords are stored as **cryptographic hashes** — never plain text
- All sensitive communication uses **HTTPS**
- **Input validation** is enforced to prevent SQL injection and malicious form submissions
- **Role-based access control (RBAC)** ensures users can only access data and actions permitted by their role

---

## Access Control

| Role | Permissions |
|---|---|
| **Member** | View/edit own profile, manage own enrollment and membership, view own attendance |
| **Staff** | Manage members, classes, trainers, payments; cannot access other staff passwords or admin actions |
| **Administrator** | Full access — includes all staff actions plus password resets, role changes, staff deletion, and membership overrides |

---

## Getting Started

### Prerequisites
- Java JDK (compatible with Apache Tomcat 9)
- Apache Tomcat 9.0.105
- MySQL Community Server 8.0.42
- MySQL Workbench 8.0.42
- IntelliJ IDEA

### Setup

1. **Clone the repository**
   ```bash
   git clone <https://github.com/ayrabia/CS157A-S1-team11>
   cd fithub
   ```

2. **Configure the database**
   - Open MySQL Workbench and create a new schema (e.g., `fithub_db`)
   - Run the provided SQL scripts to create tables and seed sample data

3. **Configure database connection**
   - Update the DB connection settings (host, port, username, password, schema) in your application's configuration file

4. **Deploy to Tomcat**
   - Build the project in IntelliJ and generate the `.war` file
   - Deploy the `.war` to your Apache Tomcat `webapps` directory

5. **Start the server**
   - Launch Apache Tomcat
   - Navigate to `http://localhost:8080/fithub` in your browser

---

## Sample Data

The database is pre-seeded with sample records for development and testing:

- **5 Members** (IDs 103–107) with statuses Active and Frozen
- **3 Staff** (1 Admin, 2 Trainers)
- **2 Trainers** with CrossFit and Martial Arts specializations
- **2 Membership Plans** — Student Semester ($100 / 4 months) and VIP Access ($500 / 12 months)
- **4 Classes** — HIIT Blast, Kickboxing, Evening Yoga, Powerlifting
- **6 Enrollment records** including one Waitlisted entry
- **6 Attendance log entries**
- **1 Gym location** — Northside FitHub, 789 North Blvd, San Jose, CA (05:00–23:00)

---



## Authors

| Name | Email |
|---|---|
| Ayman Rabia | ayman.rabia@sjsu.edu |
| Rachel Tran | rachel.n.tran@sjsu.edu |
| Minh Trinh | minh.trinh@sjsu.edu |

