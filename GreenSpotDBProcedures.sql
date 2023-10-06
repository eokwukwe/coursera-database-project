USE greenspotdb;

-- UpdateProductSellPrice procedure
DELIMITER //
CREATE PROCEDURE UpdateProductSellPrice(
  IN p_ProductID INT, 
  IN p_SellPrice DECIMAL(10,2)
)
BEGIN
	UPDATE Products SET ProductSellPrice = p_SellPrice WHERE ProductID = p_ProductID;
END //
DELIMITER ;

-- UpdateProductName procedure
DELIMITER //
CREATE PROCEDURE UpdateProductName(
  IN p_ProductID INT, 
  IN p_ProductName VARCHAR(255)
)
BEGIN
	UPDATE Products SET ProductName = p_ProductName WHERE ProductID = p_ProductID;
END //
DELIMITER ;

-- CreateInventory
DELIMITER //
CREATE PROCEDURE CreateInventory(
    IN p_InventoryType ENUM('Inflow', 'Sales'),
    IN p_QuantityOld INT,
    IN p_QuantityNew INT,
    IN p_InventoryDate DATE,
    IN p_ProductID INT UNSIGNED,
    IN p_InflowID INT UNSIGNED,
    IN p_SaleID INT UNSIGNED
)
BEGIN
    -- Insert record into Inventories table
    INSERT INTO Inventories (
        InventoryType,
        QuantityOld,
        QuantityNew,
        InventoryDate,
        ProductID,
        InflowID,
        SaleID
    )
    VALUES (
        p_InventoryType,
        p_QuantityOld,
        p_QuantityNew,
        p_InventoryDate,
        p_ProductID,
        p_InflowID,
        p_SaleID
    );
END //
DELIMITER ;

-- HandleSales
DELIMITER //
CREATE PROCEDURE HandleSales(
    IN p_SaleQuantity INT UNSIGNED,
    IN p_SaleDate DATE,
    IN p_CustomerID INT UNSIGNED,
    IN p_ProductID INT UNSIGNED
)
BEGIN
    DECLARE v_QuantityOld INT;
    DECLARE v_QuantityNew INT;
    DECLARE v_SalePrice DECIMAL(10,2);
    DECLARE v_SaleTotalCost DECIMAL(10,2);

    -- Declare handler for potential exceptions
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Rollback the transaction in case of an error
        ROLLBACK;
        -- Resignal the caught exception
        RESIGNAL;
    END;

    -- Start transaction
    START TRANSACTION;

    -- Get the current stock and sell price of the product
    SELECT ProductStock, ProductSellPrice 
    INTO v_QuantityOld, v_SalePrice FROM Products WHERE ProductID = p_ProductID;

    -- Check if there is enough stock for the sale
    IF v_QuantityOld < p_SaleQuantity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Not enough stock for the sale.';
    END IF;

    -- Calculate the new stock after the sale
    SET v_QuantityNew = v_QuantityOld - p_SaleQuantity;

    -- Calculate SaleTotalCost and set SaleDate
    SET v_SaleTotalCost = p_SaleQuantity * v_SalePrice;

    -- Insert record into Sales table
    INSERT INTO Sales (
        SaleQuantity,
        SaleTotalCost,
        SaleDate,
        SalePrice,
        CustomerID,
        ProductID
    )
    VALUES (
        p_SaleQuantity,
        v_SaleTotalCost,
        p_SaleDate,
        v_SalePrice,
        p_CustomerID,
        p_ProductID
    );

    -- Get the last inserted SaleID
    SET @last_sale_id = LAST_INSERT_ID();

    -- Update the Products table with the new stock
    UPDATE Products 
		SET ProductStock = v_QuantityNew 
        WHERE ProductID = p_ProductID;
    
    -- Call InsertIntoInventories procedure to Insert record into Inventories table
	CALL CreateInventory('Sales', v_QuantityOld, v_QuantityNew, p_SaleDate, p_ProductID, NULL, @last_sale_id);

    -- Commit the transaction
    COMMIT;

	-- Return the @last_sale_id to the calling client
    SELECT @last_sale_id AS 'SaleID';
END //
DELIMITER ;

-- HandleInflows
DELIMITER //
CREATE PROCEDURE HandleInflows(
    IN p_InflowQuantity INT UNSIGNED,
    IN p_InflowPrice DECIMAL(10,2),
    IN p_InflowDate DATE,
    IN p_VendorID INT UNSIGNED,
    IN p_ProductID INT UNSIGNED
)
BEGIN
    DECLARE v_QuantityOld INT;
    DECLARE v_QuantityNew INT;
    DECLARE v_InflowTotalCost DECIMAL(10,2);

    -- Declare handler for potential exceptions
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Rollback the transaction in case of an error
        ROLLBACK;
        -- Resignal the caught exception
        RESIGNAL;
    END;

    -- Start transaction
    START TRANSACTION;

    -- Get the current stock of the product
    SELECT ProductStock INTO v_QuantityOld FROM Products WHERE ProductID = p_ProductID;

    -- Calculate the new stock after the inflow
    SET v_QuantityNew = v_QuantityOld + p_InflowQuantity;

    -- Calculate InflowTotalCost and set InflowDate
    SET v_InflowTotalCost = p_InflowQuantity * p_InflowPrice;

    -- Insert record into Inflows table
    INSERT INTO Inflows (
        InflowPrice,
        InflowQuantity,
        InflowDate,
        InflowTotalCost,
        ProductID,
        VendorID
    )
    VALUES (
        p_InflowPrice,
        p_InflowQuantity,
        p_InflowDate,
        v_InflowTotalCost,
        p_ProductID,
        p_VendorID
    );

    -- Get the last inserted InflowID
    SET @last_inflow_id = LAST_INSERT_ID();

    -- Update the Products table with the new stock
    UPDATE Products 
        SET ProductStock = v_QuantityNew, ProductBuyPrice = p_InflowPrice 
        WHERE ProductID = p_ProductID;

    -- Call InsertIntoInventories procedure
    CALL CreateInventory('Inflow', v_QuantityOld, v_QuantityNew, p_InflowDate, p_ProductID, @last_inflow_id, NULL);

    -- Commit the transaction
    COMMIT;
    
    -- Return the @last_inflow_id to the calling client
    SELECT @last_inflow_id AS 'InflowID';
END //
DELIMITER ;

-- GetTotalDailySalesUpTo procedure. (Get the total daily sales up to the specified date)
CREATE PROCEDURE GetTotalSalesByDate(IN p_SaleDate DATE)
	SELECT SaleDate AS 'Date', SUM(SaleTotalCost) Sales
	FROM Sales
	WHERE SaleDate = p_SaleDate
	GROUP BY SaleDate
	ORDER BY SUM(SaleTotalCost) DESC; 

-- GetSalesRecordBetween procedure. Get sales record between the specified dates
DELIMITER //
CREATE PROCEDURE GetSalesRecord(IN p_StartDate DATE, p_EndDate DATE)
BEGIN
	SELECT 
		s.SaleDate,
		p.ProductName,
		p.ProductBuyPrice AS BuyPrice,
		p.ProductSellPrice AS SellPrice,
		SUM(s.SaleQuantity) AS QuantitySold,
		SUM(s.SaleTotalCost) AS TotalSales,
		SUM(s.SaleTotalCost) - (SUM(s.SaleQuantity) * p.ProductBuyPrice) AS Profit
	FROM
		Sales s
			INNER JOIN
		Products p ON s.ProductID = p.ProductID
	WHERE s.SaleDate BETWEEN p_StartDate AND p_EndDate
	GROUP BY s.SaleDate, p.ProductName
	ORDER BY s.SaleDate DESC;
END //
DELIMITER ;

-- GetInflowsRecord 
DELIMITER //
CREATE PROCEDURE GetInflowsRecord(
    IN p_StartDate DATE, 
    IN p_EndDate DATE,
    IN p_VendorName VARCHAR(255)
)
BEGIN
    IF p_VendorName IS NULL THEN
        SELECT 
            v.VendorName,
            p.ProductName,
            inf.InflowPrice,
            inf.InflowQuantity,
            inf.InflowTotalCost,
            inf.InflowDate
        FROM
            Inflows inf
                INNER JOIN
            Vendors v USING (VendorID)
                INNER JOIN
            Products p ON inf.ProductID = p.ProductID
        WHERE 
            inf.InflowDate BETWEEN p_StartDate AND p_EndDate;
    ELSE
        SELECT 
            v.VendorName,
            p.ProductName,
            inf.InflowPrice,
            inf.InflowQuantity,
            inf.InflowTotalCost,
            inf.InflowDate
        FROM
            Inflows inf
                INNER JOIN
            Vendors v USING (VendorID)
                INNER JOIN
            Products p ON inf.ProductID = p.ProductID
        WHERE 
            inf.InflowDate BETWEEN p_StartDate AND p_EndDate
            AND LOWER(v.VendorName) LIKE CONCAT('%', LOWER(p_VendorName), '%'); -- Conditional filter
    END IF;
END //
DELIMITER ;


