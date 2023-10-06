USE greenspotdb;

INSERT INTO Vendors(
	VendorName, 
    VendorPhone, 
    VendorEmail, 
    VendorAddress
) 
VALUES ('Bennet Farms', '3125557891', 'bennet.farms@email.com', 'Rt. 17 Evansville, Chicago, IL, 55446'),
('Freshness Inc.', '3125552468', 'freshness.inc@email.com', '202 E. Maple Street, Saint Joseph, MO, 45678'),
('Ruby Redd Produce, LLC,', '3125559753', 'ruby.redd@email.com', '1212 Milam Street, Kenosha, AL, 34567');

INSERT INTO Customers(
	CustomerName, 
    CustomerPhone, 
    CustomerEmail, 
    CustomerAddress
) 
VALUES ('John Doe', '3125557891', 'john.doe@example.com', '123 Main St, Chicago, IL'),
('Jane Smith', '3125552468', 'jane.smith@example.com', '456 Elm St, Chicago, IL'),
('Emily Johnson', '3125551357', 'emily.johnson@example.com', '789 Oak St, Chicago, IL'),
('William Brown', '3125558642', 'william.brown@example.com', '101 Maple St, Chicago, IL'),
('Sophia Davis', '3125559753', 'sophia.davis@example.com', '202 Cedar St, Chicago, IL');

INSERT INTO Units(UnitValue) VALUES('dozen'), ('bunch'), ('12 oz can'), ('36 oz can');

INSERT INTO StoredLocations(LocationName) VALUES('A2'), ('A3'), ('A7'), ('D12'), ('P12'), ('PO2');

INSERT INTO ProductTypes(ProductTypeName) VALUES('Dairy'), ('Canned'), ('Produce');

INSERT INTO Products(ProductName, ProductStock, ProductBuyPrice, ProductSellPrice, UnitID, LocationID, ProductTypeID)
VALUES('Bennet Farm free-range eggs', 29, 2.35, 5.49, 1, 4, 1),
	  ("Ruby's Kale", 28, 1.29, 3.99, 2, 5, 3),
      ("Freshness White beans", 53, 0.69, 2.49, 3, 1, 2),
      ('Freshness Green beans', 59, 0.59, 2.29, 3, 2, 2),
      ('Freshness Wax beans', 31, 0.65, 2.35, 3, 2, 2),
      ("Ruby's Organic Kale", 20, 2.19, 6.99, 2, 6, 3);


-- Inflows for Bennet Farm free-range eggs
CALL HandleInflows(20, 2.35, '2023-09-01', 1, 1);
CALL HandleInflows(30, 2.35, '2023-10-03', 1, 1);
-- Inflows for Ruby's Kale
CALL HandleInflows(30, 1.29, '2023-09-10', 3, 2);
CALL HandleInflows(75, 1.29, '2023-10-05', 3, 2);
-- Inflows for Freshness White beans
CALL HandleInflows(70, 0.69, '2023-10-05', 2, 3);
-- Inflows for Freshness Green beans
CALL HandleInflows(40, 2.29, '2023-10-05', 2, 4);
-- Inflows for Freshness Wax beans
CALL HandleInflows(56, 2.25, '2023-09-04', 2, 5);
-- Inflows for Ruby's Organic Kale
CALL HandleInflows(26, 2.19, '2023-09-04', 3, 6);
CALL HandleInflows(30, 2.19, '2023-10-05', 3, 6);

-- Sales for Bennet Farm free-range eggs
CALL HandleSales(3, '2023-09-02', 1, 1);
CALL HandleSales(2, '2023-10-02', 2, 1);
CALL HandleSales(1, '2023-10-01', 3, 1);
CALL HandleSales(2, '2023-10-05', 4, 1);
CALL HandleSales(1, '2023-08-12', 5, 1);
-- Sales for Ruby's Kale
CALL HandleSales(4, '2023-08-22', 1, 2);
CALL HandleSales(3, '2023-10-01', 2, 2);
CALL HandleSales(2, '2023-07-20', 3, 2);
CALL HandleSales(3, '2023-08-09', 4, 2);
CALL HandleSales(2, '2023-09-10', 5, 2);
-- Sales for Freshness White beans
CALL HandleSales(5, '2023-10-01', 1, 3);
CALL HandleSales(6, '2023-09-11', 2, 3);
CALL HandleSales(7, '2023-08-19', 3, 3);
CALL HandleSales(8, '2023-10-01', 4, 3);
CALL HandleSales(9, '2023-10-01', 5, 3);
-- Sales for Freshness Green beans
CALL HandleSales(6, '2023-09-12', 2, 4);
CALL HandleSales(7, '2023-08-23', 3, 4);
CALL HandleSales(8, '2023-10-05', 4, 4);
CALL HandleSales(9, '2023-10-06', 5, 4);
-- Sales for Freshness Wax beans
CALL HandleSales(7, '2023-10-03', 2, 5);
CALL HandleSales(3, '2023-09-23', 3, 5);
CALL HandleSales(8, '2023-10-05', 4, 5);
CALL HandleSales(10, '2023-10-06', 2, 5);
-- Sales for Ruby's Organic Kale
CALL HandleSales(4, '2023-10-01', 1, 6);
CALL HandleSales(6, '2023-09-11', 2, 6);
CALL HandleSales(2, '2023-08-19', 3, 6);
CALL HandleSales(5, '2023-10-01', 4, 6);
CALL HandleSales(9, '2023-10-06', 1, 6);