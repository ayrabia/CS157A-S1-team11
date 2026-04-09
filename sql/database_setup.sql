CREATE TABLE `group11`.`Members` (
  `member_id` INT NOT NULL,
  `phone_number` VARCHAR(16) NULL,
  `first_name` VARCHAR(30) NULL,
  `last_name` VARCHAR(30) NULL,
  `username` VARCHAR(30) NOT NULL,
  `email` VARCHAR(60) NULL,
  `password_hash` VARCHAR(60) NULL,
  `date_joined` VARCHAR(30) NULL,
  `status` VARCHAR(20) NULL,
  PRIMARY KEY (`member_id`)
);

CREATE TABLE `group11`.`Staff` (
  `staff_id` INT NOT NULL,
  `first_name` VARCHAR(30) NULL,
  `last_name` VARCHAR(30) NULL,
  `username` VARCHAR(30) NOT NULL,
  `password_hash` VARCHAR(60) NULL,
  `role` VARCHAR(20) NULL,
  `email` VARCHAR(60) NULL,
  `status` VARCHAR(20) NULL,
  PRIMARY KEY (`staff_id`)
);

CREATE TABLE `group11`.`Trainer` (
  `staff_id` INT NOT NULL,
  `specialization` VARCHAR(45) NULL,
  `certification` VARCHAR(45) NULL,
  PRIMARY KEY (`staff_id`)
);

CREATE TABLE `group11`.`Membership_Plan` (
  `plan_id` INT NOT NULL,
  `plan_name` VARCHAR(30) NULL,
  `duration_months` INT NULL,
  `price` INT NULL,
  `description` VARCHAR(60) NULL,
  `is_active` VARCHAR(10) NULL,
  PRIMARY KEY (`plan_id`)
);

CREATE TABLE `group11`.`Membership` (
  `membership_id` INT NOT NULL,
  `member_id` INT NOT NULL,
  `plan_id` INT NOT NULL,
  `start_date` VARCHAR(30) NULL,
  `end_date` VARCHAR(30) NULL,
  `status` VARCHAR(20) NULL,
  `freeze_flag` VARCHAR(10) NULL,
  PRIMARY KEY (`membership_id`)
);

CREATE TABLE `group11`.`Payment` (
  `payment_id` INT NOT NULL,
  `membership_id` INT NOT NULL,
  `member_id` INT NOT NULL,
  `amount` INT NULL,
  `payment_method` VARCHAR(30) NULL,
  `payment_date` VARCHAR(30) NULL,
  `payment_status` VARCHAR(20) NULL,
  PRIMARY KEY (`payment_id`)
);

CREATE TABLE `group11`.`Class` (
  `class_id` INT NOT NULL,
  `class_name` VARCHAR(30) NULL,
  `description` VARCHAR(60) NULL,
  `max_capacity` INT NULL,
  `schedule_date` VARCHAR(30) NULL,
  `start_time` VARCHAR(30) NULL,
  `end_time` VARCHAR(30) NULL,
  `staff_id` INT NOT NULL,
  `status` VARCHAR(20) NULL,
  PRIMARY KEY (`class_id`)
);

CREATE TABLE `group11`.`Class_Enrollment` (
  `enrollment_id` INT NOT NULL,
  `member_id` INT NOT NULL,
  `class_id` INT NOT NULL,
  `enrollment_date` VARCHAR(30) NULL,
  `enrollment_status` VARCHAR(20) NULL,
  `waitlist_flag` VARCHAR(10) NULL,
  PRIMARY KEY (`enrollment_id`)
);

CREATE TABLE `group11`.`AttendanceLog` (
  `attendance_id` INT NOT NULL,
  `member_id` INT NOT NULL,
  `class_id` INT NULL,
  `check_in_time` VARCHAR(30) NULL,
  `check_out_time` VARCHAR(30) NULL,
  PRIMARY KEY (`attendance_id`)
);

CREATE TABLE `group11`.`Gym` (
  `gym_name` VARCHAR(30) NOT NULL,
  `addr` VARCHAR(60) NULL,
  `hours` VARCHAR(30) NULL,
  PRIMARY KEY (`gym_name`)
);