-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS = @@UNIQUE_CHECKS, UNIQUE_CHECKS = 0;
SET @OLD_FOREIGN_KEY_CHECKS = @@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS = 0;
SET @OLD_SQL_MODE = @@SQL_MODE, SQL_MODE =
        'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema yelpdb
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `yelpdb`;
CREATE SCHEMA IF NOT EXISTS `yelpdb` DEFAULT CHARACTER SET utf8;
USE `yelpdb`;

-- -----------------------------------------------------
-- Table `yelpdb`.`Usernames`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `yelpdb`.`Usernames`;

CREATE TABLE IF NOT EXISTS `yelpdb`.`Usernames`
(
    `UsernameId`      INT          NOT NULL AUTO_INCREMENT,
    `Username`        VARCHAR(255) NOT NULL,
    `FirstName`       VARCHAR(45)  NULL,
    `LastName`        VARCHAR(45)  NULL,
    `Email`           VARCHAR(45)  NULL,
    `PhoneNum`        VARCHAR(45)  NULL,
    `Bio`             TEXT         NULL,

    `UserCity`        VARCHAR(45)  NULL,
    `UserState`       VARCHAR(45)  NULL,
    `Elite`           INT          NULL,
    `FriendCount`     INT          NULL,
    `UserReviewCount` INT          NULL,
    `PhotoCount`      INT          NULL,
    `Yelp_User_id`    TEXT         NULL,
    PRIMARY KEY (`UsernameId`)
)
    ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `yelpdb`.`Businesses`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `yelpdb`.`Businesses`;

CREATE TABLE IF NOT EXISTS `yelpdb`.`Businesses`
(
    `idBusiness`          INT           NOT NULL AUTO_INCREMENT,
    `BusinessName`        VARCHAR(255)  NULL,
    `BusinessReviewCount` INT           NULL,
    `Rating`              DECIMAL(3, 1) NULL,
    `latitude`            DOUBLE        NULL,
    `Longitude`           DOUBLE        NULL,
    `price`               VARCHAR(45)   NULL,
    `city`                VARCHAR(45)   NULL,
    `state`               VARCHAR(45)   NULL,
    `ZipCode`             VARCHAR(45)   NULL,
    `Address`             VARCHAR(45)   NULL,
    `Phone`               VARCHAR(45)   NULL,
    `yelp_business_id`    TEXT          NULL,

    PRIMARY KEY (`idBusiness`)
)
    ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `yelpdb`.`Reviews`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `yelpdb`.`Reviews`;

CREATE TABLE IF NOT EXISTS `yelpdb`.`Reviews`
(
    `idReviews`        INT           NOT NULL AUTO_INCREMENT,
    `Yelp_business_id` VARCHAR(255)  NULL,
    `Rating`           DECIMAL(2, 1) NULL,
    `Reviews`          TEXT          NULL,
    `UsernameId`       INT           NOT NULL,
    `idBusiness`       INT           NOT NULL,
    `ReviewDate`       DATE          NULL,
    `yelp_review_id`   TEXT          NULL,

    PRIMARY KEY (`idReviews`),
    INDEX `fk_Reviews_Users1_idx` (`UsernameId` ASC) VISIBLE,
    INDEX `fk_Reviews_Businesses1_idx` (`idBusiness` ASC) VISIBLE,
    CONSTRAINT `fk_Reviews_Users1`
        FOREIGN KEY (`UsernameId`)
            REFERENCES `yelpdb`.`Usernames` (`UsernameId`)
            ON DELETE NO ACTION
            ON UPDATE NO ACTION,
    CONSTRAINT `fk_Reviews_Businesses1`
        FOREIGN KEY (`idBusiness`)
            REFERENCES `yelpdb`.`Businesses` (`idBusiness`)
            ON DELETE NO ACTION
            ON UPDATE NO ACTION
)
    ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `yelpdb`.`Businesses_Categories`
-- -----------------------------------------------------
DROP TABLE IF EXISTS Businesses_Categories;
CREATE TABLE IF NOT EXISTS Businesses_Categories
(
    `category_id`      INT AUTO_INCREMENT NOT NULL,
    `business_id`      INT,
    `business_name`    TEXT,
    `category`         TEXT,
    `yelp_business_id` TEXT,
    PRIMARY KEY (`category_id`),
    INDEX `fk_business_id_idx` (`business_id` ASC) VISIBLE,
    CONSTRAINT `fk_business_id_idx`
        FOREIGN KEY (`business_id`)
            REFERENCES `yelpdb`.`businesses` (`idBusiness`)
            ON DELETE NO ACTION
            ON UPDATE NO ACTION
)
    ENGINE = InnoDB;


SET SQL_MODE = @OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS = @OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS = @OLD_UNIQUE_CHECKS;


-- -----------------------------------------------------
-- Business and review Staging
-- -----------------------------------------------------
DROP TABLE IF EXISTS Businesses_Staging;
CREATE TABLE IF NOT EXISTS Businesses_Staging
(
    `business_id`     TEXT,
    `business_name`   TEXT,
    `price`           INT,
    `latitude`        TEXT,
    `longitude`       TEXT,
    `address1`        TEXT,
    `address2`        TEXT,
    `address3`        TEXT,
    `BusinessCity`    TEXT,
    `zip_code`        TEXT,
    `country`         TEXT,
    `BusinessState`   TEXT,
    `display_address` TEXT,
    `rating`          TEXT,
    `review_count`    TEXT
)
    ENGINE = InnoDB;

DROP TABLE IF EXISTS Categories_Staging;
CREATE TABLE IF NOT EXISTS Categories_Staging
(

    `business_id`   TEXT,
    `business_name` TEXT,
    `category`      TEXT
)
    ENGINE = InnoDB;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/yelp_data_business_categories.csv' INTO TABLE yelpdb.Categories_Staging
    FIELDS TERMINATED BY ',' ENCLOSED BY '"'
    LINES TERMINATED BY '\r\n'
    IGNORE 1 LINES
    (business_id, business_name, category);



SELECT *
FROM businesses_staging;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/yelp_data_business.csv' IGNORE INTO TABLE yelpdb.Businesses_Staging
    FIELDS TERMINATED BY ',' ENCLOSED BY '"'
    LINES TERMINATED BY '\r\n'
    IGNORE 1 LINES
    (business_id, business_name, price, latitude, longitude, address1, address2, address3, BusinessCity, zip_code,
     country,
     BusinessState, display_address, rating, review_count);


INSERT INTO yelpdb.businesses (BusinessName, Rating, BusinessReviewCount, latitude, Longitude, price, city, state,
                               ZipCode,
                               Address,
                               yelp_business_id)
SELECT business_name,
       rating,
       review_count,
       CAST(latitude AS DOUBLE)  as Latitude,
       CAST(longitude AS DOUBLE) as Longitude,
       price,
       BusinessCity,
       BusinessState,
       LPAD(zip_code, 5, '0'),
       address1,
       business_id
from yelpdb.Businesses_Staging;

INSERT INTO Businesses_Categories (business_id, business_name, category, yelp_business_id)
SELECT idBusiness, business_name, category, b.yelp_business_id
FROM categories_staging
         LEFT JOIN businesses b on categories_staging.business_id = b.yelp_business_id;
ALTER TABLE Businesses_Categories
    DROP yelp_business_id;

SELECT idBusiness, business_name, category, b.yelp_business_id
FROM categories_staging
         LEFT JOIN businesses b on categories_staging.business_id = b.yelp_business_id;


DROP TABLE IF EXISTS Yelp_Users_stagings;
CREATE TABLE IF NOT EXISTS Yelp_Users_stagings
(
    `user_id`      TEXT,
    `username`     TEXT,
    `city`         TEXT,
    `state`        TEXT,
    `elite`        INT,
    `friend_count` INT,
    `review_count` INT,
    `photo_count`  INT
)
    ENGINE = InnoDB;


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/yelp_data_users_processed.csv' IGNORE INTO TABLE yelpdb.Yelp_Users_stagings
    FIELDS TERMINATED BY ','
    LINES TERMINATED BY '\n'
    IGNORE 1 LINES
    (user_id, username, city, state, elite, friend_count, review_count, photo_count);

SELECT *
FROM yelp_users_stagings;

INSERT INTO yelpdb.Usernames (Username, UserCity, UserState, Elite, FriendCount, UserReviewCount, PhotoCount,
                              Yelp_User_id)
SELECT username,
       city,
       state,
       elite,
       friend_count,
       review_count,
       photo_count,
       user_id
from yelpdb.yelp_users_stagings;


DROP TABLE IF EXISTS reviews_staging;
CREATE TABLE IF NOT EXISTS reviews_staging
(
    `yelp_review_id`  TEXT,
    `business_id`     TEXT,
    `business_name`   TEXT,
    `user_yelp_id`    TEXT,
    `user_name`       TEXT,
    `review_date`     TEXT,
    `review_rating`   TEXT,
    `feedback_cool`   TEXT,
    `feedback_funny`  TEXT,
    `feedback_useful` TEXT,
    `owner_reply`     TEXT,
    `written_content` TEXT
)
    ENGINE = InnoDB;


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/yelp_data_business_reviews.csv' IGNORE INTO TABLE yelpdb.reviews_staging
    FIELDS TERMINATED BY ',' ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 LINES
    (yelp_review_id, business_id, business_name, user_yelp_id, user_name, review_date, review_rating, feedback_cool,
     feedback_funny,
     feedback_useful,
     owner_reply, written_content);


INSERT INTO reviews (`Yelp_business_id`, `Rating`, `UsernameId`, `idBusiness`, `ReviewDate`, `Reviews`)
SELECT yelp_business_id,
       rating,
       UsernameId,
       idBusiness,
       str_to_date(review_date, '%m/%d/%Y'),
       written_content
FROM (SELECT *
      FROM reviews_staging
               LEFT OUTER JOIN businesses on businesses.yelp_business_id = reviews_staging.business_id
               LEFT OUTER JOIN usernames on usernames.Yelp_User_id = reviews_staging.user_yelp_id) as Subtable;

SELECT COUNT(*)
FROM reviews_staging

         INNER  JOIN usernames on usernames.Yelp_User_id = reviews_staging.user_yelp_id;

SELECT COUNT(*) FROM reviews_staging;

SELECT * FROM usernames where usernames.username = 'Shirley W.';
SELECT * FROM usernames where usernames.Yelp_User_id = 'h-3Nq3XQVoeuB0C17s76UQ';
SELECT * FROM reviews_staging where user_yelp_id = 'h-3Nq3XQVoeuB0C17s76UQ';
SELECT * FROM usernames;
SELECT * FROM reviews_staging LEFT JOIN usernames ON Yelp_User_id = user_yelp_id where UsernameId is null;
INNER JOIN businesses on yelp_business_id = business_id where UsernameId is null;


SELECT business_id,
       business_name,
       yelp_business_id,
       rating,
       UsernameId,
       businesses.idBusiness,
       str_to_date(review_date, '%m/%d/%Y'),
       written_content
FROM reviews_staging
         JOIN businesses ON yelp_business_id = business_id
         JOIN usernames u on user_yelp_id = Yelp_User_id
WHERE idbusiness IS NULL;

SELECT *
FROM reviews;
SELECT *
FROM reviews_staging;


#
#
# LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/yelp_boston_restaurants.csv' INTO TABLE yelpdb.Businesses_staging
#     FIELDS TERMINATED BY ',' ENCLOSED BY '"'
#     LINES TERMINATED BY '\n'
#     IGNORE 1 LINES
#     (business_id, business_name, review_count, rating, latitude, longitude, price, city, zip_code, state, country,
#      display_address, phone)
#      SET business_type = "restaurant";
#
#  SELECT * FROM businesses_staging;
#
#  DROP TABLE IF EXISTS Reviews_Staging;
#
#  CREATE TABLE IF NOT EXISTS Reviews_Staging
# (
#     `business_id`     TEXT,
#     `business_name`   TEXT,
#     `author`    TEXT,
#     `review_date`    TEXT,
#     `rating`    TEXT,
#     `review`    LONGTEXT
# )
#     ENGINE = InnoDB;
#
#
# LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/yelp_boston_coffee_shop_reviews.csv' INTO TABLE yelpdb.reviews_staging
# 	FIELDS TERMINATED BY ',' ENCLOSED BY '"'
# 	LINES TERMINATED BY '\n'
# 	IGNORE 1 LINES
# 	(business_id, business_name, author, review_date, rating, review);
#
# LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/yelp_boston_restaurant_reviews.csv' IGNORE INTO TABLE yelpdb.reviews_staging
# 	FIELDS TERMINATED BY ',' ENCLOSED BY '"'
# 	LINES TERMINATED BY '\n'
# 	IGNORE 1 LINES
# 	(business_id, business_name, author, review_date, rating, review);
#
# SELECT * FROM reviews_staging;
#
#
# SELECT reviews_staging.business_name, businesses_staging.display_address, businesses_staging.business_id
# 	FROM reviews_staging
#     LEFT JOIN businesses_staging ON reviews_staging.business_id = businesses_staging.business_id;
#
# SELECT *
# 	FROM reviews_staging
#     LEFT JOIN businesses_staging ON reviews_staging.business_id = businesses_staging.business_id;
#
# -- LOADING IN DATA FROM BUSINESSES STAGING TO BUSINESSES
#
# ALTER TABLE yelpdb.businesses
# 	ADD column business_id TEXT;
#
# SET foreign_key_checks = 0;
# INSERT INTO yelpdb.businesses (BusinessName, ReviewCount, Rating, Latitude, Longitude, Price, City_idCity, ZipCode, Address, Phone, BusinessType, business_id)
# 	SELECT business_name, review_count, rating, latitude, longitude, price, 1, zip_code, display_address, phone, business_type, business_id
# 	FROM yelpdb.businesses_staging;
# SET foreign_key_checks = 1;
#
#
# ALTER TABLE yelpdb.reviews_staging
# 	ADD column idBusiness TEXT;
#
# SELECT * FROM yelpdb.businesses;
# SELECT * FROM reviews_staging;
#
# SELECT *
# 	FROM reviews_staging
#     LEFT JOIN businesses ON reviews_staging.business_id = businesses.business_id;
#
#
# SET SQL_SAFE_UPDATES = 0;
# UPDATE
# 	yelpdb.reviews_staging t1
# LEFT JOIN
# 	yelpdb.businesses t2
# ON t1.business_id = t2.business_id
# SET
# 	t1.idBusiness = t2.idBusiness
# WHERE t1.idBusiness IS NULL;
# SET SQL_SAFE_UPDATES = 1;
# SELECT * FROM yelpdb.reviews_staging;
#
# SET foreign_key_checks = 0;
# INSERT INTO yelpdb.reviews (Username, Rating, Reviews, ReviewDate, idBusiness)
# 	SELECT 1, CAST(rating AS DECIMAL(3,2)), review, STR_TO_DATE(Review_date, '%Y-%m-%d'), idBusiness
# 	FROM yelpdb.reviews_staging;
# SET foreign_key_checks = 1;
#
# SELECT * FROM businesses;
# SELECT * FROM reviews;
#
# DROP TABLE reviews_staging;
# DROP TABLE businesses_staging;
#
# -- -----------------------------------------------------
# -- End of Business and review Staging
# -- -----------------------------------------------------
# -- -----------------------------------------------------
# -- Crime Staging
# -- -----------------------------------------------------
#
#  -- LOAD OFFENSE CODES FIRST
# -- DROP TABLE yelpdb.crimetype;
#  LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/boston_crime_offense_codes.csv' INTO TABLE yelpdb.crimetype
# 	FIELDS TERMINATED BY ',' ENCLOSED BY '"'
# 	LINES TERMINATED BY '\r\n'
# 	IGNORE 1 LINES
# 	(CrimeCode, CrimeDescription, CrimeGroup);
#
#
#  DROP TABLE IF EXISTS Crime_Staging;
#  CREATE TABLE IF NOT EXISTS `Crime_Staging`(
# 	`INCIDENT_NUMBER`  TEXT,
# 	`OFFENSE_CODE`  TEXT,
# 	`OFFENSE_CODE_GROUP`  TEXT,
# 	`OFFENSE_DESCRIPTION`  TEXT,
# 	`DISTRICT`  TEXT,
# 	`REPORTING_AREA`  TEXT,
# 	`SHOOTING`  TEXT,
# 	`OCCURRED_ON_DATE`  TEXT,
# 	`YEAR`  TEXT,
# 	`MONTH`  TEXT,
# 	`DAY_OF_WEEK`  TEXT,
# 	`HOUR`  TEXT,
# 	`UCR_PART`  TEXT,
# 	`STREET`  TEXT,
# 	`Latitude`  TEXT,
# 	`Longitude`  TEXT,
# 	`Location`  TEXT
# )
#     ENGINE = InnoDB;
#
# LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/boston_crime_2015_to_date.csv' INTO TABLE yelpdb.Crime_Staging
# 	FIELDS TERMINATED BY ',' ENCLOSED BY '"'
# 	LINES TERMINATED BY '\r\n'
# 	IGNORE 1 LINES
# 	(`INCIDENT_NUMBER`, `OFFENSE_CODE`, `OFFENSE_CODE_GROUP`, `OFFENSE_DESCRIPTION`, `DISTRICT`, `REPORTING_AREA`, `SHOOTING`,`OCCURRED_ON_DATE`, @dummy,@dummy,@dummy,@dummy,`UCR_PART`, `STREET`, `Latitude`, `Longitude`, `Location`);
#
# SELECT * from yelpdb.crime_staging;
# SELECT * FROM yelpdb.crimeType;
#
# -- LOAD FROM CRIME STAGING INTO CRIME - NOTE: TURNING OFF AND BACK OUT THE FOREIGN KEY CHECKS FOR DEMO
# -- NOTE CRIME TABLE HAS OccurredOnDate SET to DATETIME
# -- NOTE, Latitude and Longitude is also inserting 0. Should be null but we don't need to fix it for PM2 I'm guessing.
# SET foreign_key_checks = 0;
# INSERT INTO yelpdb.Crime (City_idCity, CrimeCode, OccurredOnDate, Latitude, Longitude)
# 	SELECT 1, Offense_Code, STR_TO_DATE(OCCURRED_ON_DATE, '%Y-%m-%d %H:%i:%s'), CAST(Latitude as Double), CAST(Longitude AS DOUBLE)
# 	FROM yelpdb.crime_staging;
# SET foreign_key_checks = 1;
#
# SELECT * FROM yelpdb.CrimeType;
# SELECT * FROM yelpdb.Crime;
# -- -----------------------------------------------------
# -- End of Crime Staging
# -- -----------------------------------------------------
# -- -----------------------------------------------------
# -- Book Staging
# -- -----------------------------------------------------
# DROP TABLE IF EXISTS BooksStage ;
#
# CREATE TABLE IF NOT EXISTS BooksStage (
#   BibNum VARCHAR(500) NULL,
#   Title VARCHAR(1500) NULL,
#   Author VARCHAR(500) NULL,
#   ISBN VARCHAR(1500) NULL,
#   PublicationYear VARCHAR(500) NULL,
#   Publisher VARCHAR(500) NULL,
#   Subjects VARCHAR(5000) NULL,
#   ItemType VARCHAR(500) NULL,
#   ItemCollection VARCHAR(500) NULL,
#   FloatingItem VARCHAR(500) NULL,
#   ItemLocation VARCHAR(500) NULL,
#   ReportDate VARCHAR(500) NULL,
#   ItemCount VARCHAR(500) NULL
# )
# ENGINE = InnoDB;
#
# LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Library_Collection_Inventory.csv'
# INTO TABLE BooksStage
# FIELDS TERMINATED BY ','
# ENCLOSED BY '"'
# LINES TERMINATED BY '\n'
# IGNORE 1 ROWS;
#
#
# DROP TABLE IF EXISTS CheckoutStage ;
#
# CREATE TABLE IF NOT EXISTS CheckoutStage (
#   BibNum VARCHAR(500) NULL,
#   ItemBarcode VARCHAR(500) NULL,
#   ItemType VARCHAR(500) NULL,
#   Collection VARCHAR(500) NULL,
#   CallNumber VARCHAR(500) NULL,
#   CheckoutDateTime VARCHAR(500) NULL
# )
# ENGINE = InnoDB;
#
# LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Checkouts_By_Title_Data_Lens_2017.csv'
# INTO TABLE CheckoutStage
# FIELDS TERMINATED BY ','
# ENCLOSED BY '"'
# LINES TERMINATED BY '\n'
# IGNORE 1 ROWS;
#
#
#
#
# SET @@AUTOCOMMIT=0;
# LOCK TABLES authors WRITE, booksstage READ;
# INSERT INTO authors(FirstName, LastNAme)
# SELECT DISTINCT LEFT(SUBSTRING_INDEX(SUBSTRING_INDEX(Author,',',2),',',1),45), LEFT(SUBSTRING_INDEX(SUBSTRING_INDEX(Author,',',2),',',-1),45) FROM booksstage WHERE Author LIKE '%,%';
# UNLOCK TABLES;
#
#
#
# SET @@AUTOCOMMIT=0;
# LOCK TABLES book WRITE, booksstage READ;
# INSERT INTO books(Title, BibNum, ISBN, Subject, Publisher, Authors_idAuthors, BookCheckOut_idBookCheckOut)
# SELECT LEFT(SUBSTRING_INDEX(Title,'/',1), 500), BibNum, LEFT(ISBN, 200), LEFT(SUBSTRING_INDEX(Subjects,',',1), 500), LEFT(Publisher, 100), 1, NULL FROM booksstage WHERE char_length(Title) > 0;
# UNLOCK TABLES;
#
#
#
# SET @@AUTOCOMMIT=0;
# LOCK TABLES bookcheckout WRITE, checkoutstage READ;
# INSERT INTO bookcheckout(BibNum, CheckOutDate, City_idCity)
# SELECT BibNum, STR_TO_DATE(SUBSTRING_INDEX(CheckoutDateTime,' ',1), '%m/%d/%Y'), 1 FROM checkoutstage WHERE char_length(Bibnum) > 0;
# UNLOCK TABLES;
#
# -- -----------------------------------------------------
# -- End of Book Staging
# -- -----------------------------------------------------
# -- -----------------------------------------------------
# -- Staging the Seattle Library Collection
# -- -----------------------------------------------------
#
# DROP TABLE IF EXISTS LibraryCollectionStaging;
# CREATE TABLE LibraryCollectionStaging (
# 	BibNumber TEXT,
# 	Title TEXT,
# 	Author TEXT,
# 	ISBN TEXT,
# 	PublicationYear TEXT,
# 	Publisher TEXT,
# 	Subjects TEXT,
# 	ItemType TEXT,
# 	ItemCollection TEXT,
# 	FloatingItem TEXT,
# 	ItemLocation TEXT,
# 	ReportDate TEXT,
# 	ItemCount TEXT
# );
#
#
# LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Library_Collection_Inventory.csv' IGNORE INTO TABLE `yelpdb`.`LibraryCollectionStaging`
# 	FIELDS TERMINATED BY ',' ENCLOSED BY '"'
# 	LINES TERMINATED BY '\n'
# 	IGNORE 1 LINES
# 	(`BibNumber`, `Title`,`Author`,`ISBN`,`PublicationYear`,`Publisher`,`Subjects`,`ItemType`,`ItemCollection`,`FloatingItem`,`ItemLocation`,`ReportDate`,`ItemCount`);
#
# SELECT * FROM libraryCollectionStaging;
#
# DROP TABLE IF EXISTS LibraryCheckoutStaging;
# CREATE TABLE LibraryCheckoutStaging (
# 	BibNumber	Text,
# 	ItemBarcode	Text,
# 	ItemType	Text,
# 	Collection	Text,
# 	CallNumber	Text,
# 	CheckoutDateTime	Text);
#
# LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Checkouts_By_Title_Data_Lens_2017.csv' IGNORE INTO TABLE `yelpdb`.`LibraryCheckoutStaging`
# 	FIELDS TERMINATED BY ',' ENCLOSED BY '"'
# 	LINES TERMINATED BY '\n'
# 	IGNORE 1 LINES
# 	(`BibNumber`,`ItemBarcode`,`ItemType`,`Collection`,`CallNumber`,`CheckoutDateTime`);
#
# LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Checkouts_By_Title_Data_Lens_2016.csv' IGNORE INTO TABLE `yelpdb`.`LibraryCheckoutStaging`
# 	FIELDS TERMINATED BY ',' ENCLOSED BY '"'
# 	LINES TERMINATED BY '\n'
# 	IGNORE 1 LINES
# 	(`BibNumber`,`ItemBarcode`,`ItemType`,`Collection`,`CallNumber`,`CheckoutDateTime`);
#
# LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Checkouts_By_Title_Data_Lens_2015.csv' IGNORE INTO TABLE `yelpdb`.`LibraryCheckoutStaging`
# 	FIELDS TERMINATED BY ',' ENCLOSED BY '"'
# 	LINES TERMINATED BY '\n'
# 	IGNORE 1 LINES
# 	(`BibNumber`,`ItemBarcode`,`ItemType`,`Collection`,`CallNumber`,`CheckoutDateTime`);
#
# LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Checkouts_By_Title_Data_Lens_2014.csv' IGNORE INTO TABLE `yelpdb`.`LibraryCheckoutStaging`
# 	FIELDS TERMINATED BY ',' ENCLOSED BY '"'
# 	LINES TERMINATED BY '\n'
# 	IGNORE 1 LINES
# 	(`BibNumber`,`ItemBarcode`,`ItemType`,`Collection`,`CallNumber`,`CheckoutDateTime`);
#
# SELECT * FROM LibraryCheckoutStaging;
#
# SELECT BibNumber, COUNT(*) AS CNT
# 	FROM LibraryCheckoutStaging
#     GROUP By BibNumber
#     ORDER BY COUNT(*) DESC
#     LIMIT 10;
#
# SELECT Title from libraryCollectionStaging WHERE BibNum = "3030520";
#
#
# SELECT *
# 	FROM reviews_staging
#     LEFT JOIN businesses ON reviews_staging.business_id = businesses.business_id;
#
# SELECT *
# 	FROM librarycheckoutstaging
#     LEFT JOIN librarycollectionstaging ON librarycheckoutstaging.bibnumber= librarycollectionstaging .bibnumber;
#
#
# SET SQL_SAFE_UPDATES = 0;
# UPDATE
# 	yelpdb.reviews_staging t1
# LEFT JOIN
# 	yelpdb.businesses t2
# ON t1.business_id = t2.business_id
# SET
# 	t1.idBusiness = t2.idBusiness
# WHERE t1.idBusiness IS NULL;
# SET SQL_SAFE_UPDATES = 1;
# SELECT * FROM yelpdb.reviews_staging;
#
# SET foreign_key_checks = 0;
# INSERT INTO yelpdb.reviews (Username, Rating, Reviews, ReviewDate, idBusiness)
# 	SELECT 1, CAST(rating AS DECIMAL(3,2)), review, STR_TO_DATE(Review_date, '%Y-%m-%d'), idBusiness
# 	FROM yelpdb.reviews_staging;
# SET foreign_key_checks = 1;
#
#
# -- -----------------------------------------------------
# -- End of the Seattle Library Collection
# -- -----------------------------------------------------
# -- -----------------------------------------------------
# -- Staging City Data
# -- -----------------------------------------------------
# DROP TABLE IF EXISTS City_Staging;
# CREATE TABLE IF NOT EXISTS City_Staging(
# 	City TEXT,
#     Country TEXT,
#     Latitude TEXT,
#     Longitude TEXT
# );
#
# SELECT * FROM city;
# LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/city_attributes.csv' INTO TABLE `yelpdb`.`City_Staging`
# FIELDS TERMINATED BY ',' ENCLOSED BY '"'
# 	LINES TERMINATED BY '\r\n'
# 	IGNORE 1 LINES
#     (`City`, `Country`, `Latitude`, `Longitude`);
# SELECT * FROM City_Staging;
#
# SET foreign_key_checks = 0;
# INSERT INTO yelpdb.city (CityName, Latitude, Longitude, County_idCounty)
# 	SELECT City, Latitude, Longitude, 1
# 	FROM yelpdb.City_staging;
#
# SET foreign_key_checks = 1;
# SELECT * FROM City;
#
# -- -----------------------------------------------------
# -- End of City Data
# -- -----------------------------------------------------
# -- -----------------------------------------------------
# -- Staging Usernames
# -- ----------------------------------------------------
# DROP TABLE IF EXISTS Username_Staging;
# CREATE TABLE IF NOT EXISTS Username_Staging(
#
#     Username TEXT,
#     FirstName TEXT,
#     BirthYear TEXT,
#     Gender TEXT
# );
#
#
# LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/usernames_optimized.csv' INTO TABLE `yelpdb`.`username_staging`
# FIELDS TERMINATED BY ','
# 	LINES TERMINATED BY '\n'
# 	IGNORE 1 LINES
#     (`Username`, `FirstName`, `BirthYear`, `Gender`, @dummy, @dummy);
#
# INSERT INTO yelpdb.usernames (Username, FirstName)
# 	SELECT Username, FirstName
# 	FROM yelpdb.username_staging;
# DROP TABLE username_staging;
#
# SELECT * FROM businesses;
# SELECT * FROM reviews;
# SELECT * FROM crime;
# SELECT * FROM crimetype;
# SELECT * FROM city;
# SELECT * FROM usernames;
#
# SELECT * FROM usernames;
#
