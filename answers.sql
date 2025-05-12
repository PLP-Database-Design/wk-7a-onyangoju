-- 1NF Transformation: Unlisting products into individual rows
WITH RECURSIVE NumberSequence AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM NumberSequence WHERE n < 100  -- Adjust this limit as needed based on the maximum number of products
)
SELECT OrderID, CustomerName, 
       TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(Products, ',', n.n), ',', -1)) AS Product
FROM ProductDetail
JOIN NumberSequence n
  ON CHAR_LENGTH(Products) - CHAR_LENGTH(REPLACE(Products, ',', '')) >= n.n - 1;


-- 2NF Transformation: Normalisation
-- Create 'Orders' table to store OrderID and CustomerName
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerName VARCHAR(100)
);

-- Create 'OrderItems' table to store OrderID, Product, and Quantity
CREATE TABLE OrderItems (
    OrderID INT,
    Product VARCHAR(100),
    Quantity INT,
    PRIMARY KEY (OrderID, Product),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

-- Insert unique OrderID and CustomerName into 'Orders' table
INSERT INTO Orders (OrderID, CustomerName)
SELECT DISTINCT OrderID, CustomerName
FROM ProductDetail_1NF;

-- Insert OrderID, Product, and Quantity into 'OrderItems' table
INSERT INTO OrderItems (OrderID, Product, Quantity)
SELECT OrderID, Product, 1 AS Quantity -- Assuming quantity is 1 for each product
FROM ProductDetail_1NF;

-- Drop the original 'OrderDetails' table
DROP TABLE OrderDetails;
