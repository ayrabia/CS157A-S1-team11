-- FitHub Sample Data (Complete, self-contained)
-- Each table reaches at least 10 tuple instances per final report requirement

-- --------------------------------------------------------
-- Gym (10 rows)
-- --------------------------------------------------------
INSERT INTO `group11`.`Gym` VALUES
('FitHub Downtown',      '100 Main St, San Jose, CA',           '05:00-23:00'),
('FitHub Northside',     '789 North Blvd, San Jose, CA',        '05:00-23:00'),
('FitHub Eastside',      '2100 Story Road, San Jose, CA',       '05:30-22:30'),
('FitHub Midtown',       '455 Willow Street, San Jose, CA',     '06:00-23:00'),
('FitHub Silicon Valley','789 Innovation Drive, Sunnyvale, CA', '05:00-00:00'),
('FitHub Bay Area',      '1200 Shoreline Blvd, Mountain View, CA','06:00-22:00'),
('FitHub Express',       '300 QuickFit Lane, Fremont, CA',      'Open 24 Hours'),
('FitHub Central',       '1500 Downtown Ave, San Jose, CA',     '06:00-21:00'),
('FitHub Westside',      '900 West Valley Dr, San Jose, CA',    '05:30-22:00'),
('FitHub Saratoga',      '300 Saratoga Ave, Santa Clara, CA',   '06:00-22:00');

-- --------------------------------------------------------
-- Admin (10 rows)  role_id: 1 = Super Admin, 2 = Manager
-- --------------------------------------------------------
INSERT INTO `group11`.`Admin` VALUES
(1,  'Diana',   'Chan',    'dchan',     'hash001'),
(2,  'Alex',    'Kim',     'akim',      'hash002'),
(3,  'Morgan',  'Lee',     'mlee',      'hash003'),
(4,  'Jordan',  'Park',    'jpark',     'hash004'),
(5,  'Taylor',  'Chen',    'tchen',     'hash005'),
(6,  'Casey',   'Wong',    'cwong',     'hash006'),
(7,  'Riley',   'Singh',   'rsingh',    'hash007'),
(8,  'Quinn',   'Patel',   'qpatel',    'hash008'),
(9,  'Sam',     'Garcia',  'sgarcia',   'hash009'),
(10, 'Drew',    'Lopez',   'dlopez',    'hash010');

-- --------------------------------------------------------
-- Staff (13 rows: 3 Hosts + 10 Trainers)
-- --------------------------------------------------------
INSERT INTO `group11`.`Staff` VALUES
(1,  'James',   'Wilson',  'jwilson',   'hash101', 'Host',    'james@fithub.com',   'Active'),
(2,  'Ethan',   'Wong',    'ewong',     'hash102', 'Host',    'ethan@fithub.com',   'Active'),
(3,  'Olivia',  'Garcia',  'ogarcia',   'hash103', 'Host',    'olivia@fithub.com',  'Active'),
(4,  'Noah',    'Patel',   'npatel',    'hash104', 'Trainer', 'noah@fithub.com',    'Active'),
(5,  'Ava',     'Martinez','amartinez', 'hash105', 'Trainer', 'ava@fithub.com',     'Active'),
(6,  'Clark',   'Kent',    'ckent',     'hash106', 'Trainer', 'clark@fithub.com',   'Active'),
(7,  'Bruce',   'Wayne',   'bwayne',    'hash107', 'Trainer', 'bruce@fithub.com',   'Active'),
(8,  'Liam',    'Johnson', 'ljohnson',  'hash108', 'Trainer', 'liam@fithub.com',    'Active'),
(9,  'Emma',    'Brown',   'ebrown',    'hash109', 'Trainer', 'emma@fithub.com',    'Active'),
(10, 'Sophia',  'Taylor',  'staylor',   'hash110', 'Trainer', 'sophia@fithub.com',  'Active'),
(11, 'Marcus',  'White',   'mwhite',    'hash111', 'Trainer', 'marcus@fithub.com',  'Active'),
(12, 'Zoe',     'Harris',  'zharris',   'hash112', 'Trainer', 'zoe@fithub.com',     'Active'),
(13, 'Ryan',    'Scott',   'rscott',    'hash113', 'Trainer', 'ryan@fithub.com',    'Inactive');

-- --------------------------------------------------------
-- Trainer (10 rows: staff_ids 4-13)
-- --------------------------------------------------------
INSERT INTO `group11`.`Trainer` VALUES
(4,  'Yoga',         'RYT-200'),
(5,  'HIIT',         'CF-L1'),
(6,  'CrossFit',     'CF-L2'),
(7,  'Martial Arts', 'BB-1st'),
(8,  'Kickboxing',   'BB-1st'),
(9,  'Pilates',      'PMA-CPT'),
(10, 'Zumba',        'ZUMBA-Cert'),
(11, 'Swimming',     'ARC-WSI'),
(12, 'Powerlifting', 'NSCA-CPT'),
(13, 'Spin Cycle',   'ICG-Cert');

-- --------------------------------------------------------
-- Membership_Plan (10 rows)
-- --------------------------------------------------------
INSERT INTO `group11`.`Membership_Plan` VALUES
(1,  'Basic Monthly',    1,  30,  'Basic gym access',             'Yes'),
(2,  'Standard Annual',  12, 300, 'Full year access',             'Yes'),
(3,  'Student Semester', 4,  100, 'Discounted student access',    'Yes'),
(4,  'VIP Access',       12, 500, 'All access + personal locker', 'Yes'),
(5,  'Family Plan',      12, 400, 'Up to 4 family members',       'Yes'),
(6,  'Senior Discount',  1,  20,  'Ages 60+ discount',            'Yes'),
(7,  'Premium Monthly',  1,  60,  'Premium amenities included',   'Yes'),
(8,  'Corporate',        12, 250, 'Corporate partner discount',   'Yes'),
(9,  'Trial Week',       0,  10,  '7-day trial pass',             'No'),
(10, 'Summer Special',   3,  75,  'Summer promotional plan',      'No');

-- --------------------------------------------------------
-- Members (10 rows)
-- --------------------------------------------------------
INSERT INTO `group11`.`Members` VALUES
(101, '555-0101', 'Alice',  'Smith',   'asmith',   'alice@email.com',  'pass1',  '2026-01-15', 'Active'),
(102, '555-0102', 'Bob',    'Jones',   'bjones',   'bob@email.com',    'pass2',  '2026-02-01', 'Active'),
(103, '555-0103', 'Frank',  'Ocean',   'focean',   'frank@email.com',  'pass3',  '2026-03-01', 'Active'),
(104, '555-0104', 'Grace',  'Hopper',  'ghopper',  'grace@email.com',  'pass4',  '2026-03-05', 'Active'),
(105, '555-0105', 'Hank',   'Pym',     'hpym',     'hank@email.com',   'pass5',  '2026-03-10', 'Active'),
(106, '555-0106', 'Iris',   'West',    'iwest',    'iris@email.com',   'pass6',  '2026-03-12', 'Active'),
(107, '555-0107', 'John',   'Doe',     'jdoe',     'john@email.com',   'pass7',  '2026-03-15', 'Frozen'),
(108, '555-0108', 'Kate',   'Banner',  'kbanner',  'kate@email.com',   'pass8',  '2026-04-01', 'Active'),
(109, '555-0109', 'Leo',    'Stark',   'lstark',   'leo@email.com',    'pass9',  '2026-04-05', 'Active'),
(110, '555-0110', 'Maya',   'Parker',  'mparker',  'maya@email.com',   'pass10', '2025-04-10', 'Expired');

-- --------------------------------------------------------
-- Membership (10 rows)
-- --------------------------------------------------------
INSERT INTO `group11`.`Membership` VALUES
(1001, 101, 1,  '2026-01-15', '2026-02-15', 'Active',  'No'),
(1002, 102, 2,  '2026-02-01', '2027-02-01', 'Active',  'No'),
(1003, 103, 3,  '2026-03-01', '2026-07-01', 'Active',  'No'),
(1004, 104, 4,  '2026-03-05', '2027-03-05', 'Active',  'No'),
(1005, 105, 1,  '2026-03-10', '2026-04-10', 'Active',  'No'),
(1006, 106, 2,  '2026-03-12', '2027-03-12', 'Active',  'No'),
(1007, 107, 1,  '2026-03-15', '2026-04-15', 'Frozen',  'Yes'),
(1008, 108, 7,  '2026-04-01', '2026-05-01', 'Active',  'No'),
(1009, 109, 4,  '2026-04-05', '2027-04-05', 'Active',  'No'),
(1010, 110, 1,  '2025-04-10', '2025-05-10', 'Expired', 'No');

-- --------------------------------------------------------
-- Payment (10 rows)
-- --------------------------------------------------------
INSERT INTO `group11`.`Payment` VALUES
(501, 1001, 101, 30,  'Cash',        '2026-01-15', 'Completed'),
(502, 1002, 102, 300, 'Credit Card', '2026-02-01', 'Completed'),
(503, 1003, 103, 100, 'Credit Card', '2026-03-01', 'Completed'),
(504, 1004, 104, 500, 'Credit Card', '2026-03-05', 'Completed'),
(505, 1005, 105, 30,  'Cash',        '2026-03-10', 'Completed'),
(506, 1006, 106, 300, 'Debit Card',  '2026-03-12', 'Completed'),
(507, 1007, 107, 30,  'Cash',        '2026-03-15', 'Completed'),
(508, 1008, 108, 60,  'Credit Card', '2026-04-01', 'Completed'),
(509, 1009, 109, 500, 'Debit Card',  '2026-04-05', 'Completed'),
(510, 1010, 110, 30,  'Cash',        '2025-04-10', 'Completed');

-- --------------------------------------------------------
-- Class (10 rows)
-- --------------------------------------------------------
INSERT INTO `group11`.`Class` VALUES
(201, 'Morning Yoga',  'Gentle morning stretch',              20, '2026-01-20', '07:00', '08:00', 4,  'FitHub Downtown',       'Completed'),
(202, 'Spin Cycle',    'High-energy cycling session',         15, '2026-02-10', '09:00', '10:00', 13, 'FitHub Northside',      'Completed'),
(203, 'HIIT Blast',    'High intensity interval training',    20, '2026-03-22', '12:00', '13:00', 5,  'FitHub Eastside',       'Scheduled'),
(204, 'Kickboxing',    'Cardio kickboxing',                   15, '2026-03-23', '18:00', '19:00', 8,  'FitHub Midtown',        'Scheduled'),
(205, 'Evening Yoga',  'Wind down stretch',                   25, '2026-03-24', '20:00', '21:00', 4,  'FitHub Silicon Valley', 'Scheduled'),
(206, 'Powerlifting',  'Advanced lifting techniques',         10, NULL,         NULL,    NULL,    12, 'FitHub Central',        'Unscheduled'),
(207, 'Martial Arts',  'Comprehensive full-body workout',     20, '2026-05-25', '16:00', '17:30', 7,  'FitHub Bay Area',       'Scheduled'),
(208, 'Pilates',       'Core strength and flexibility',       12, '2026-05-28', '10:00', '11:00', 9,  'FitHub Westside',       'Scheduled'),
(209, 'Zumba',         'Dance fitness class',                 30, '2026-06-01', '18:00', '19:00', 10, 'FitHub Express',        'Scheduled'),
(210, 'Swimming',      'Lap swimming session',                8,  '2026-06-05', '07:00', '08:30', 11, 'FitHub Saratoga',       'Scheduled');

-- --------------------------------------------------------
-- Class_Enrollment (10 rows)
-- --------------------------------------------------------
INSERT INTO `group11`.`Class_Enrollment` VALUES
(301, 101, 201, '2026-01-18', 'Enrolled',   'No'),
(302, 102, 202, '2026-02-08', 'Enrolled',   'No'),
(303, 103, 203, '2026-03-20', 'Enrolled',   'No'),
(304, 104, 204, '2026-03-20', 'Enrolled',   'No'),
(305, 105, 205, '2026-03-21', 'Enrolled',   'No'),
(306, 106, 206, '2026-03-21', 'Enrolled',   'No'),
(307, 101, 203, '2026-03-21', 'Waitlisted', 'Yes'),
(308, 102, 204, '2026-03-21', 'Enrolled',   'No'),
(309, 108, 207, '2026-05-20', 'Enrolled',   'No'),
(310, 109, 208, '2026-05-25', 'Enrolled',   'No');

-- --------------------------------------------------------
-- AttendanceLog (10 rows)
-- --------------------------------------------------------
INSERT INTO `group11`.`AttendanceLog` VALUES
(401, 101, 201,  '2026-01-20 07:05', '2026-01-20 08:10'),
(402, 102, 202,  '2026-02-10 09:00', '2026-02-10 10:05'),
(403, 103, 203,  '2026-03-22 11:50', '2026-03-22 13:10'),
(404, 104, 204,  '2026-03-23 17:55', '2026-03-23 19:15'),
(405, 105, NULL, '2026-03-20 09:00', '2026-03-20 10:30'),
(406, 106, NULL, '2026-03-21 14:00', '2026-03-21 15:45'),
(407, 101, NULL, '2026-03-22 08:00', '2026-03-22 09:30'),
(408, 102, 201,  '2026-03-20 07:50', '2026-03-20 09:10'),
(409, 108, NULL, '2026-04-02 10:00', '2026-04-02 11:00'),
(410, 109, 207,  '2026-05-25 15:55', '2026-05-25 17:35');
