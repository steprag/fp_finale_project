CREATE SCHEMA `final_project`;

CREATE TABLE `final_project`.`age_cat` (
  `age_cat_id` INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `age_cat` VARCHAR(10) DEFAULT null,
  `age_cat_desc` VARCHAR(10) DEFAULT null
);

CREATE TABLE `final_project`.`establishment` (
  `CODGEO` TEXT DEFAULT null,
  `total_establishment` BIGINT DEFAULT null,
  `micro_firms` BIGINT DEFAULT null,
  `small_firms` BIGINT DEFAULT null,
  `medium_firms` BIGINT DEFAULT null,
  `large_firms` BIGINT DEFAULT null,
  `agriculture_est` BIGINT DEFAULT null,
  `industry_est` BIGINT DEFAULT null,
  `construction_est` BIGINT DEFAULT null,
  `commerce_transport_est` BIGINT DEFAULT null,
  `public_est` BIGINT DEFAULT null
);

CREATE TABLE `final_project`.`gender` (
  `gender_id` BIGINT PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `gender` VARCHAR(10) DEFAULT null
);

CREATE TABLE `final_project`.`geography` (
  `CODGEO` TEXT DEFAULT null,
  `postcode` BIGINT DEFAULT null,
  `town_fullname` TEXT DEFAULT null,
  `town_name` TEXT DEFAULT null,
  `latitude` DOUBLE DEFAULT null,
  `longitude` DOUBLE DEFAULT null,
  `code_departement` TEXT DEFAULT null,
  `departement_name` TEXT DEFAULT null,
  `code_region` DOUBLE DEFAULT null,
  `region_name` TEXT DEFAULT null
);

CREATE TABLE `final_project`.`job_cat` (
  `job_cat_id` INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `job_cat` VARCHAR(50) DEFAULT null
);

CREATE TABLE `final_project`.`population` (
  `CODGEO` TEXT DEFAULT null,
  `LIBGEO` TEXT DEFAULT null,
  `job_cat_id` INT DEFAULT null,
  `gender` BIGINT DEFAULT null,
  `age_cat_id` INT DEFAULT null,
  `total_population` BIGINT DEFAULT null
);

CREATE TABLE `final_project`.`salary` (
  `CODGEO` TEXT DEFAULT null,
  `mean_salary` DOUBLE DEFAULT null,
  `mean_salary_executive` DOUBLE DEFAULT null,
  `mean_salary_middlemanagement` DOUBLE DEFAULT null,
  `mean_salary_employee` DOUBLE DEFAULT null,
  `mean_salary_worker` DOUBLE DEFAULT null,
  `mean_salary_youngage` DOUBLE DEFAULT null,
  `mean_salary_mediumage` DOUBLE DEFAULT null,
  `mean_salary_oldage` DOUBLE DEFAULT null,
  `gender` BIGINT DEFAULT null
);

CREATE INDEX `gender_fk1` ON `final_project`.`population` (`gender`);

CREATE INDEX `job_cat_fk1` ON `final_project`.`population` (`job_cat_id`);

CREATE INDEX `age_cat_fk1` ON `final_project`.`population` (`age_cat_id`);

ALTER TABLE `final_project`.`population` ADD CONSTRAINT `age_cat_fk1` FOREIGN KEY (`age_cat_id`) REFERENCES `final_project`.`age_cat` (`age_cat_id`);

ALTER TABLE `final_project`.`population` ADD CONSTRAINT `gender_fk1` FOREIGN KEY (`gender`) REFERENCES `final_project`.`gender` (`gender_id`);

ALTER TABLE `final_project`.`population` ADD CONSTRAINT `job_cat_fk1` FOREIGN KEY (`job_cat_id`) REFERENCES `final_project`.`job_cat` (`job_cat_id`);

ALTER TABLE `final_project`.`salary` ADD CONSTRAINT `gender_fk2` FOREIGN KEY (`gender`) REFERENCES `final_project`.`gender` (`gender_id`);

ALTER TABLE `final_project`.`salary` ADD CONSTRAINT `geo_fk` FOREIGN KEY (`CODGEO`) REFERENCES `final_project`.`geography` (`CODGEO`);

ALTER TABLE `final_project`.`population` ADD CONSTRAINT `geo_fk2` FOREIGN KEY (`CODGEO`) REFERENCES `final_project`.`geography` (`CODGEO`);

ALTER TABLE `final_project`.`establishment` ADD CONSTRAINT `geo_fk` FOREIGN KEY (`CODGEO`) REFERENCES `final_project`.`geography` (`CODGEO`);
