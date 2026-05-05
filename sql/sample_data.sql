-- 1. Add another Gym Location
INSERT INTO `group11`.`Gym` VALUES 
('Northside FitHub', '789 North Blvd, San Jose, CA', '5:00 AM - 11:00 PM'),
('FitHub Eastside', '2100 Story Road, San Jose, CA', '5:30 AM - 10:30 PM'),
('FitHub Midtown', '455 Willow Street, San Jose, CA', '6:00 AM - 11:00 PM'),
('FitHub Silicon Valley', '789 Innovation Drive, Sunnyvale, CA', '5:00 AM - 12:00 AM'),
('FitHub Bay Area', '1200 Shoreline Blvd, Mountain View, CA', '6:00 AM - 10:00 PM'),
('FitHub Express', '300 QuickFit Lane, Fremont, CA', '24 Hours'),
('FitHub Central', '1500 Downtown Ave, San Jose, CA', '6:00 AM - 9:00 PM');
									
-- 2. Add More Staff (1 new Admin, 2 new Trainers)
INSERT INTO `group11`.`Staff` VALUES 
(1, 'Diana', 'Prince', 'dprince', 'hash001', 'Admin', 'diana@fithub.com', 'Active'),
(2, 'Ethan', 'Wong', 'ewong', 'hash002', 'Host', 'ethan.wong@fithub.com', 'Active'),
(3, 'Olivia', 'Garcia', 'ogarcia', 'hash002', 'Host', 'olivia.garcia@fithub.com', 'Active'),
(4, 'Noah', 'Patel', 'npatel', 'hash002', 'Host', 'noah.patel@fithub.com', 'Active'),
(5, 'Ava', 'Martinez', 'amartinez', 'hash002', 'Host', 'ava.martinez@fithub.com', 'Active'),
(6, 'Clark', 'Kent', 'ckent', 'hash003', 'Trainer', 'clark@fithub.com', 'Active'),
(7, 'Bruce', 'Wayne', 'bwayne', 'hash003', 'Trainer', 'bruce@fithub.com', 'Active'),
(8, 'Liam', 'Johnson', 'ljohnson', 'hash003', 'Trainer', 'liam.johnson@fithub.com', 'Active'),
(9, 'Emma', 'Brown', 'ebrown', 'hash003', 'Trainer', 'emma.brown@fithub.com', 'Active');

-- 3. Add Trainer Details (Linking to Staff IDs 5 and 6)
INSERT INTO `group11`.`Trainer` VALUES 
(6, 'HIIT Blast', 'CF-L1'), (7, 'Martial Arts', 'BB-1st'),
(8, 'Kickboxing', 'BB-1st'),(9, 'Yoga', 'BB-1st');

-- 4. Add New Membership Plans
INSERT INTO `group11`.`Membership_Plan` VALUES 
(3, 'Student Semester', 4, 100, 'Discounted student access', 'Yes'),
(4, 'VIP Access', 12, 500, 'All access + personal locker', 'Yes');

-- 5. Add 5 New Members
INSERT INTO `group11`.`Members` VALUES 
(103, '555-0103', 'Frank', 'Ocean', 'focean', 'frank@email.com', 'pass3', '2026-03-01', 'Active'),
(104, '555-0104', 'Grace', 'Hopper', 'ghopper', 'grace@email.com', 'pass4', '2026-03-05', 'Active'),
(105, '555-0105', 'Hank', 'Pym', 'hpym', 'hank@email.com', 'pass5', '2026-03-10', 'Active'),
(106, '555-0106', 'Iris', 'West', 'iwest', 'iris@email.com', 'pass6', '2026-03-12', 'Active'),
(107, '555-0107', 'John', 'Doe', 'jdoe', 'john@email.com', 'pass7', '2026-03-15', 'Frozen');

-- 6. Add Memberships for the New Members
INSERT INTO `group11`.`Membership` VALUES 
(1003, 103, 3, '2026-03-01', '2026-07-01', 'Active', 'No'),
(1004, 104, 4, '2026-03-05', '2027-03-05', 'Active', 'No'),
(1005, 105, 1, '2026-03-10', '2026-04-10', 'Active', 'No'),
(1006, 106, 2, '2026-03-12', '2027-03-12', 'Active', 'No'),
(1007, 107, 1, '2026-03-15', '2026-04-15', 'Frozen', 'Yes');

-- 7. Add Payments for the New Memberships
INSERT INTO `group11`.`Payment` VALUES 
(503, 1003, 103, 100, 'Credit Card', '2026-03-01', 'Completed'),
(504, 1004, 104, 500, 'Credit Card', '2026-03-05', 'Completed'),
(505, 1005, 105, 30, 'Cash', '2026-03-10', 'Completed'),
(506, 1006, 106, 300, 'Debit Card', '2026-03-12', 'Completed'),
(507, 1007, 107, 30, 'Cash', '2026-03-15', 'Completed');

-- 8. Add More Classes
INSERT INTO `group11`.`Class` VALUES 
(203, 'HIIT Blast', 'High intensity interval training', 20, '2026-03-22', '12:00', '13:00', 6, 'Scheduled'),
(204, 'Kickboxing', 'Cardio kickboxing', 15, '2026-03-23', '18:00', '19:00', 8, 'Scheduled'),
(205, 'Yoga', 'Wind down stretch', 25, '2026-03-24', '20:00', '21:00', 9, 'Scheduled'),
(206, 'Powerlifting', 'Advanced lifting techniques', 10, NULL, NULL, NULL, 6, 'Unscheduled'),
(207, 'Martial Art', 'Comprehensive, full-body workout', 20, '2026-05-25', '16:00', '17:30', 7, 'Scheduled');

-- 9. Add More Class Enrollments (Including a Waitlist example)
INSERT INTO `group11`.`Class_Enrollment` VALUES 
(303, 103, 203, '2026-03-20', 'Enrolled', 'No'),
(304, 104, 204, '2026-03-20', 'Enrolled', 'No'),
(305, 105, 205, '2026-03-21', 'Enrolled', 'No'),
(306, 106, 206, '2026-03-21', 'Enrolled', 'No'),
(307, 101, 203, '2026-03-21', 'Waitlisted', 'Yes'),
(308, 102, 204, '2026-03-21', 'Enrolled', 'No');

-- 10. Add More Attendance Logs (Some for classes, some just walking in)
INSERT INTO `group11`.`AttendanceLog` VALUES 
(403, 103, 203, '2026-03-22 11:50', '2026-03-22 13:10'),
(404, 104, 204, '2026-03-23 17:55', '2026-03-23 19:15'),
(405, 105, NULL, '2026-03-20 09:00', '2026-03-20 10:30'),
(406, 106, NULL, '2026-03-21 14:00', '2026-03-21 15:45'),
(407, 101, NULL, '2026-03-22 08:00', '2026-03-22 09:30'),
(408, 102, 201, '2026-03-20 07:50', '2026-03-20 09:10');