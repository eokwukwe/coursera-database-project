-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema GreenSpotDB
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema GreenSpotDB
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `GreenSpotDB` DEFAULT CHARACTER SET utf8 ;
USE `GreenSpotDB` ;

-- -----------------------------------------------------
-- Table `GreenSpotDB`.`Vendors`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `GreenSpotDB`.`Vendors` (
  `VendorID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `VendorName` VARCHAR(255) NOT NULL,
  `VendorPhone` VARCHAR(50) NOT NULL,
  `VendorEmail` VARCHAR(255) NULL,
  `VendorAddress` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`VendorID`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `GreenSpotDB`.`Customers`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `GreenSpotDB`.`Customers` (
  `CustomerID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `CustomerName` VARCHAR(255) NOT NULL,
  `CustomerPhone` VARCHAR(50) NOT NULL,
  `CustomerEmail` VARCHAR(255) NULL,
  `CustomerAddress` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`CustomerID`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `GreenSpotDB`.`Units`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `GreenSpotDB`.`Units` (
  `UnitID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `UnitValue` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`UnitID`),
  UNIQUE INDEX `UnitScale_UNIQUE` (`UnitValue` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `GreenSpotDB`.`StoredLocations`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `GreenSpotDB`.`StoredLocations` (
  `LocationID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `LocationName` VARCHAR(10) NOT NULL,
  PRIMARY KEY (`LocationID`),
  UNIQUE INDEX `LocationName_UNIQUE` (`LocationName` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `GreenSpotDB`.`ProductTypes`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `GreenSpotDB`.`ProductTypes` (
  `ProductTypeID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `ProductTypeName` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`ProductTypeID`),
  UNIQUE INDEX `ProductTypeName_UNIQUE` (`ProductTypeName` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `GreenSpotDB`.`Products`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `GreenSpotDB`.`Products` (
  `ProductID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `ProductName` VARCHAR(255) NOT NULL,
  `ProductStock` INT NOT NULL,
  `ProductSellPrice` DECIMAL(10,2) NOT NULL COMMENT 'The price to sell the product',
  `ProductBuyPrice` DECIMAL(10,2) NOT NULL COMMENT 'The price at which the product is bought',
  `UnitID` INT UNSIGNED NOT NULL,
  `LocationID` INT UNSIGNED NOT NULL,
  `ProductTypeID` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`ProductID`),
  UNIQUE INDEX `ProductName_UNIQUE` (`ProductName` ASC) VISIBLE,
  INDEX `product_unit_id_fk_idx` (`UnitID` ASC) VISIBLE,
  INDEX `product_location_id_fk_idx` (`LocationID` ASC) VISIBLE,
  INDEX `product_product_type_id_fk_idx` (`ProductTypeID` ASC) VISIBLE,
  CONSTRAINT `product_unit_id_fk`
    FOREIGN KEY (`UnitID`)
    REFERENCES `GreenSpotDB`.`Units` (`UnitID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `product_location_id_fk`
    FOREIGN KEY (`LocationID`)
    REFERENCES `GreenSpotDB`.`StoredLocations` (`LocationID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `product_product_type_id_fk`
    FOREIGN KEY (`ProductTypeID`)
    REFERENCES `GreenSpotDB`.`ProductTypes` (`ProductTypeID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `GreenSpotDB`.`Inflows`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `GreenSpotDB`.`Inflows` (
  `InflowID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `InflowPrice` DECIMAL(10,2) NOT NULL,
  `InflowQuantity` INT UNSIGNED NULL,
  `InflowDate` DATE NOT NULL,
  `InflowTotalCost` DECIMAL(10,2) NOT NULL,
  `ProductID` INT UNSIGNED NOT NULL,
  `VendorID` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`InflowID`),
  INDEX `inflow_product_id_fk_idx` (`ProductID` ASC) VISIBLE,
  INDEX `inflow_vendor_id_fk_idx` (`VendorID` ASC) VISIBLE,
  CONSTRAINT `inflow_product_id_fk`
    FOREIGN KEY (`ProductID`)
    REFERENCES `GreenSpotDB`.`Products` (`ProductID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `inflow_vendor_id_fk`
    FOREIGN KEY (`VendorID`)
    REFERENCES `GreenSpotDB`.`Vendors` (`VendorID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `GreenSpotDB`.`Sales`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `GreenSpotDB`.`Sales` (
  `SaleID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `SaleQuantity` INT UNSIGNED NOT NULL,
  `SaleTotalCost` DECIMAL(10,2) NOT NULL,
  `SaleDate` DATE NOT NULL,
  `SalePrice` DECIMAL(10,2) NOT NULL COMMENT 'This is added for historical purposes. We want to keep track of the price of each product at the time of the sales. The value will be the same as the ProductSellPrice at the time the sales was made. ',
  `CustomerID` INT UNSIGNED NOT NULL,
  `ProductID` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`SaleID`),
  INDEX `sale_customer_id_fk_idx` (`CustomerID` ASC) VISIBLE,
  INDEX `sale_product_id_fk_idx` (`ProductID` ASC) VISIBLE,
  CONSTRAINT `sale_customer_id_fk`
    FOREIGN KEY (`CustomerID`)
    REFERENCES `GreenSpotDB`.`Customers` (`CustomerID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `sale_product_id_fk`
    FOREIGN KEY (`ProductID`)
    REFERENCES `GreenSpotDB`.`Products` (`ProductID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `GreenSpotDB`.`Inventories`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `GreenSpotDB`.`Inventories` (
  `InventoryID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `InventoryType` ENUM("Inflow", "Sales") NOT NULL,
  `QuantityOld` INT NOT NULL COMMENT 'Quantity of product before the inventory record was created. For sales, the will be the product stock before sales. For inflow, this will be the product stock before adding the new stock',
  `QuantityNew` INT NOT NULL COMMENT 'Quantity of product after the inventory record was created. For sales, the will be the product stock after removing the sold quantity. For inflow, this will be the product stock after adding the new stock.',
  `InventoryDate` DATE NOT NULL COMMENT 'The value will always be the same for either the SaleDate or InflowDate at the time the operation is performed.',
  `ProductID` INT UNSIGNED NOT NULL,
  `InflowID` INT UNSIGNED NULL COMMENT 'This will be NULL is the type is Sales.',
  `SaleID` INT UNSIGNED NULL COMMENT 'This will be NULL if the type is Inflow.',
  PRIMARY KEY (`InventoryID`),
 CHECK (InflowID IS NOT NULL OR SaleID IS NOT NULL),
  INDEX `inventory_product_id_fk_idx` (`ProductID` ASC) VISIBLE,
  INDEX `inventory_inflow_id_fk_idx` (`InflowID` ASC) VISIBLE,
  INDEX `inventory_sale_id_fk_idx` (`SaleID` ASC) VISIBLE,
  CONSTRAINT `inventory_product_id_fk`
    FOREIGN KEY (`ProductID`)
    REFERENCES `GreenSpotDB`.`Products` (`ProductID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `inventory_inflow_id_fk`
    FOREIGN KEY (`InflowID`)
    REFERENCES `GreenSpotDB`.`Inflows` (`InflowID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `inventory_sale_id_fk`
    FOREIGN KEY (`SaleID`)
    REFERENCES `GreenSpotDB`.`Sales` (`SaleID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
