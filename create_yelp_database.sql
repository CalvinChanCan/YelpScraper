-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS = @@UNIQUE_CHECKS, UNIQUE_CHECKS = 0;
SET @OLD_FOREIGN_KEY_CHECKS = @@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS = 0;
SET @OLD_SQL_MODE = @@SQL_MODE, SQL_MODE =
        'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema yelpdb
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `yelpdb`;

-- -----------------------------------------------------
-- Schema yelpdb
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `yelpdb` DEFAULT CHARACTER SET utf8;
USE `yelpdb`;

-- -----------------------------------------------------
-- Table `yelpdb`.`Authors`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `yelpdb`.`Authors`;

CREATE TABLE IF NOT EXISTS `yelpdb`.`Authors`
(
    `idAuthors` INT         NOT NULL AUTO_INCREMENT,
    `FirstName` VARCHAR(45) NULL,
    `LastName`  VARCHAR(45) NULL,
    PRIMARY KEY (`idAuthors`)
)
    ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `yelpdb`.`Demographics`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `yelpdb`.`Demographics`;

CREATE TABLE IF NOT EXISTS `yelpdb`.`Demographics`
(
    `idDemographics`  INT NOT NULL,
    `Male`            INT NULL,
    `Female`          INT NULL,
    `Income`          INT NULL,
    `TotalPopulation` INT NULL,
    PRIMARY KEY (`idDemographics`)
)
    ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `yelpdb`.`County`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `yelpdb`.`County`;

CREATE TABLE IF NOT EXISTS `yelpdb`.`County`
(
    `idCounty`                    INT         NOT NULL,
    `Demographics_idDemographics` INT         NULL,
    `State`                       VARCHAR(45) NULL,
    PRIMARY KEY (`idCounty`),
    INDEX `fk_County_Demographics1_idx` (`Demographics_idDemographics` ASC) VISIBLE,
    CONSTRAINT `fk_County_Demographics1`
        FOREIGN KEY (`Demographics_idDemographics`)
            REFERENCES `yelpdb`.`Demographics` (`idDemographics`)
            ON DELETE NO ACTION
            ON UPDATE NO ACTION
)
    ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `yelpdb`.`City`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `yelpdb`.`City`;

CREATE TABLE IF NOT EXISTS `yelpdb`.`City`
(
    `idCity`          INT         NOT NULL AUTO_INCREMENT,
    `CityName`        VARCHAR(45) NOT NULL,
    `Latitude`        DOUBLE      NOT NULL,
    `Longitude`       DOUBLE      NOT NULL,
    `County_idCounty` INT         NOT NULL,
    PRIMARY KEY (`idCity`),
    INDEX `fk_City_County1_idx` (`County_idCounty` ASC) VISIBLE,
    CONSTRAINT `fk_City_County1`
        FOREIGN KEY (`County_idCounty`)
            REFERENCES `yelpdb`.`County` (`idCounty`)
            ON DELETE NO ACTION
            ON UPDATE NO ACTION
)
    ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `yelpdb`.`BookCheckout`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `yelpdb`.`BookCheckout`;

CREATE TABLE IF NOT EXISTS `yelpdb`.`BookCheckout`
(
    `idBookCheckout` INT  NOT NULL,
    `City_idCity`    INT  NOT NULL,
    `CheckoutDate`   DATE NOT NULL,
    PRIMARY KEY (`idBookCheckout`),
    INDEX `fk_BookCheckout_City1_idx` (`City_idCity` ASC) VISIBLE,
    CONSTRAINT `fk_BookCheckout_City1`
        FOREIGN KEY (`City_idCity`)
            REFERENCES `yelpdb`.`City` (`idCity`)
            ON DELETE NO ACTION
            ON UPDATE NO ACTION
)
    ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `yelpdb`.`Books`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `yelpdb`.`Books`;

CREATE TABLE IF NOT EXISTS `yelpdb`.`Books`
(
    `idBook`                      INT          NOT NULL AUTO_INCREMENT,
    `Subject`                     VARCHAR(500) NULL,
    `ISBN`                        VARCHAR(200) NULL,
    `Authors_idAuthors`           INT          NOT NULL,
    `BookCheckout_idBookCheckout` INT          NULL,
    `BibNum`                      VARCHAR(45)  NOT NULL,
    `Title`                       VARCHAR(500) NOT NULL,
    `Publisher`                   VARCHAR(100) NULL,
    PRIMARY KEY (`idBook`),
    INDEX `fk_Books_Authors1_idx` (`Authors_idAuthors` ASC) VISIBLE,
    INDEX `fk_Books_BookCheckout1_idx` (`BookCheckout_idBookCheckout` ASC) VISIBLE,
    CONSTRAINT `fk_Books_Authors1`
        FOREIGN KEY (`Authors_idAuthors`)
            REFERENCES `yelpdb`.`Authors` (`idAuthors`)
            ON DELETE NO ACTION
            ON UPDATE NO ACTION,
    CONSTRAINT `fk_Books_BookCheckout1`
        FOREIGN KEY (`BookCheckout_idBookCheckout`)
            REFERENCES `yelpdb`.`BookCheckout` (`idBookCheckout`)
            ON DELETE NO ACTION
            ON UPDATE NO ACTION
)
    ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `yelpdb`.`Usernames`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `yelpdb`.`Usernames`;

CREATE TABLE IF NOT EXISTS `yelpdb`.`Usernames`
(
    `Username`     VARCHAR(255) NOT NULL,
    `FirstName`    VARCHAR(45)  NULL,
    `LastName`     VARCHAR(45)  NULL,
    `Email`        VARCHAR(45)  NULL,
    `PhoneNum`     VARCHAR(45)  NULL,
    `Bio`          TEXT         NULL,

    `City`         VARCHAR(45)  NULL,
    `State`        VARCHAR(45)  NULL,
    `Elite`        INT          NULL,
    `FriendCount`  INT          NULL,
    `ReviewCount`  INT          NULL,
    `PhotoCount`   INT          NULL,
    `Yelp_User_id` TEXT         NULL,
    PRIMARY KEY (`Username`)
)
    ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `yelpdb`.`Businesses`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `yelpdb`.`Businesses`;

CREATE TABLE IF NOT EXISTS `yelpdb`.`Businesses`
(
    `idBusinesses` INT                                NOT NULL AUTO_INCREMENT,
    `BusinessName` VARCHAR(45)                        NULL,
    `ReviewCount`  INT                                NULL,
    `Rating`       DOUBLE                             NULL,
    `latitude`     DOUBLE                             NULL,
    `Longitude`    DOUBLE                             NULL,
    `price`        VARCHAR(45)                        NULL,
    `City_idCity`  INT                                NOT NULL,
    `ZipCode`      VARCHAR(45)                        NULL,
    `Address`      VARCHAR(45)                        NULL,
    `Phone`        VARCHAR(45)                        NULL,
    `BusinessType` ENUM ("Coffee Shop", "Restaurant") NULL,
    PRIMARY KEY (`idBusinesses`),
    INDEX `fk_Businesses_City1_idx` (`City_idCity` ASC) VISIBLE,
    CONSTRAINT `fk_Businesses_City1`
        FOREIGN KEY (`City_idCity`)
            REFERENCES `yelpdb`.`City` (`idCity`)
            ON DELETE NO ACTION
            ON UPDATE NO ACTION
)
    ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `yelpdb`.`Reviews`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `yelpdb`.`Reviews`;

CREATE TABLE IF NOT EXISTS `yelpdb`.`Reviews`
(
    `idReviews`      INT           NOT NULL AUTO_INCREMENT,
    `Yelp_Review_id` VARCHAR(255)  NULL,
    `Rating`         DECIMAL(2, 1) NULL,
    `Reviews`        TEXT          NULL,
    `Username`       VARCHAR(255)  NOT NULL,
    `idBusinesses`   INT           NOT NULL,
    `ReviewDate`     DATE          NULL,
    PRIMARY KEY (`idReviews`),
    INDEX `fk_Reviews_Users1_idx` (`Username` ASC) VISIBLE,
    INDEX `fk_Reviews_Businesses1_idx` (`idBusinesses` ASC) VISIBLE,
    CONSTRAINT `fk_Reviews_Users1`
        FOREIGN KEY (`Username`)
            REFERENCES `yelpdb`.`Usernames` (`Username`)
            ON DELETE NO ACTION
            ON UPDATE NO ACTION,
    CONSTRAINT `fk_Reviews_Businesses1`
        FOREIGN KEY (`idBusinesses`)
            REFERENCES `yelpdb`.`Businesses` (`idBusinesses`)
            ON DELETE NO ACTION
            ON UPDATE NO ACTION
)
    ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `yelpdb`.`Weather`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `yelpdb`.`Weather`;

CREATE TABLE IF NOT EXISTS `yelpdb`.`Weather`
(
    `idWeather`   INT    NOT NULL AUTO_INCREMENT,
    `Date`        DATE   NULL,
    `Temperature` DOUBLE NULL,
    `City_idCity` INT    NOT NULL,
    PRIMARY KEY (`idWeather`),
    INDEX `fk_Weather_City1_idx` (`City_idCity` ASC) VISIBLE,
    CONSTRAINT `fk_Weather_City1`
        FOREIGN KEY (`City_idCity`)
            REFERENCES `yelpdb`.`City` (`idCity`)
            ON DELETE NO ACTION
            ON UPDATE NO ACTION
)
    ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `yelpdb`.`CrimeType`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `yelpdb`.`CrimeType`;

CREATE TABLE IF NOT EXISTS `yelpdb`.`CrimeType`
(
    `CrimeCode`        INT          NOT NULL,
    `CrimeDescription` VARCHAR(255) NOT NULL,
    `CrimeGroup`       VARCHAR(45)  NULL,
    PRIMARY KEY (`CrimeCode`)
)
    ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `yelpdb`.`Crime`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `yelpdb`.`Crime`;

CREATE TABLE IF NOT EXISTS `yelpdb`.`Crime`
(
    `idCrime`        INT    NOT NULL AUTO_INCREMENT,
    `City_idCity`    INT    NOT NULL,
    `CrimeCode`      INT    NOT NULL,
    `OccurredOnDate` DATE   NULL,
    `Latitude`       DOUBLE NULL,
    `Longitude`      DOUBLE NULL,
    PRIMARY KEY (`idCrime`, `CrimeCode`),
    INDEX `fk_Crime_City1_idx` (`City_idCity` ASC) VISIBLE,
    INDEX `fk_Crime_CrimeType1_idx` (`CrimeCode` ASC) VISIBLE,
    CONSTRAINT `fk_Crime_City1`
        FOREIGN KEY (`City_idCity`)
            REFERENCES `yelpdb`.`City` (`idCity`)
            ON DELETE NO ACTION
            ON UPDATE NO ACTION,
    CONSTRAINT `fk_Crime_CrimeType1`
        FOREIGN KEY (`CrimeCode`)
            REFERENCES `yelpdb`.`CrimeType` (`CrimeCode`)
            ON DELETE NO ACTION
            ON UPDATE NO ACTION
)
    ENGINE = InnoDB;


SET SQL_MODE = @OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS = @OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS = @OLD_UNIQUE_CHECKS;



-- ------------------------------
-- ^^^ FOWARD ENGINEER ABOVE ^^^
-- ------------------------------
-- -----------------------------------------------------
-- Business and review Staging
-- -----------------------------------------------------
DROP TABLE IF EXISTS Businesses_Staging;
CREATE TABLE IF NOT EXISTS Businesses_Staging
(
    `business_id`     TEXT,
    `business_name`   TEXT,
    `review_count`    TEXT,
    `rating`          TEXT,
    `latitude`        TEXT,
    `longitude`       TEXT,
    `price`           TEXT,
    `city`            TEXT,
    `zip_code`        TEXT,
    `state`           TEXT,
    `country`         TEXT,
    `display_address` TEXT,
    `phone`           TEXT,
    `business_type`   TEXT
)
    ENGINE = InnoDB;


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/yelp_data_users_processed.csv' IGNORE INTO TABLE yelpdb.Yelp_Users_stagings
    FIELDS TERMINATED BY ','
    LINES TERMINATED BY '\n'
    IGNORE 1 LINES
    (user_id, username, city, state, elite, friend_count, review_count, photo_count);



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
FROM usernames;
SELECT *
FROM yelpdb.yelp_users_stagings;

SELECT user_id, city, state, elite, friend_count, review_count, photo_count
from yelpdb.yelp_users_stagings;

INSERT INTO yelpdb.Usernames (Username, FirstName, City, State, Elite, FriendCount, ReviewCount, PhotoCount)
SELECT user_id,
       username,
       city,
       state,
       elite,
       friend_count,
       review_count,
       photo_count
from yelpdb.yelp_users_stagings;

SELECT *
From usernames;

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
# 	ADD column idBusinesses TEXT;
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
# 	t1.idBusinesses = t2.idBusinesses
# WHERE t1.idBusinesses IS NULL;
# SET SQL_SAFE_UPDATES = 1;
# SELECT * FROM yelpdb.reviews_staging;
#
# SET foreign_key_checks = 0;
# INSERT INTO yelpdb.reviews (Username, Rating, Reviews, ReviewDate, idBusinesses)
# 	SELECT 1, CAST(rating AS DECIMAL(3,2)), review, STR_TO_DATE(Review_date, '%Y-%m-%d'), idBusinesses
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
# 	t1.idBusinesses = t2.idBusinesses
# WHERE t1.idBusinesses IS NULL;
# SET SQL_SAFE_UPDATES = 1;
# SELECT * FROM yelpdb.reviews_staging;
#
# SET foreign_key_checks = 0;
# INSERT INTO yelpdb.reviews (Username, Rating, Reviews, ReviewDate, idBusinesses)
# 	SELECT 1, CAST(rating AS DECIMAL(3,2)), review, STR_TO_DATE(Review_date, '%Y-%m-%d'), idBusinesses
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
