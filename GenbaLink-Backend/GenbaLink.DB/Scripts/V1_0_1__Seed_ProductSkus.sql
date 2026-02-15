-- Increase the recursion limit for MariaDB to allow 5000 iterations
SET SESSION max_recursive_iterations = 5000;

INSERT INTO ProductSkus (Id, Name, Category, Color, Size, Price, StockLevel)
WITH RECURSIVE cnt AS (
   SELECT 1 AS x
   UNION ALL
   SELECT x + 1 FROM cnt WHERE x < 5000
)
SELECT 
    CONCAT('SKU-', LPAD(x, 5, '0')) AS Id,
    CONCAT(
        (CASE (x % 10) 
            WHEN 0 THEN 'U Crew Neck Short Sleeve T-Shirt'
            WHEN 1 THEN 'Oxford Slim Fit Long Sleeve Shirt'
            WHEN 2 THEN 'Premium Lambswool Crew Neck Sweater'
            WHEN 3 THEN 'Ultra Light Down Jacket'
            WHEN 4 THEN 'Blocktech Parka'
            WHEN 5 THEN 'Smart Anchor Length Pants'
            WHEN 6 THEN 'Selvedge Slim Fit Straight Jeans'
            WHEN 7 THEN 'Chino Shorts'
            WHEN 8 THEN 'AIRism Boxer Briefs'
            ELSE 'Heattech Crew Neck T-Shirt'
        END),
        ' (',
        (CASE (FLOOR(x / 10) % 10)
            WHEN 0 THEN 'White'
            WHEN 1 THEN 'Black'
            WHEN 2 THEN 'Navy'
            WHEN 3 THEN 'Gray'
            WHEN 4 THEN 'Beige'
            WHEN 5 THEN 'Olive'
            WHEN 6 THEN 'Pink'
            WHEN 7 THEN 'Blue'
            WHEN 8 THEN 'Red'
            ELSE 'Yellow'
        END),
        ', ',
        (CASE (FLOOR(x / 100) % 6)
            WHEN 0 THEN 'XS'
            WHEN 1 THEN 'S'
            WHEN 2 THEN 'M'
            WHEN 3 THEN 'L'
            WHEN 4 THEN 'XL'
            ELSE 'XXL'
        END),
        ')'
    ) AS Name,
    (CASE (x % 10) 
        WHEN 0 THEN 'T-Shirts' 
        WHEN 1 THEN 'Shirts' 
        WHEN 2 THEN 'Sweaters' 
        WHEN 3 THEN 'Outerwear' 
        WHEN 4 THEN 'Outerwear' 
        WHEN 5 THEN 'Pants' 
        WHEN 6 THEN 'Jeans' 
        WHEN 7 THEN 'Shorts' 
        WHEN 8 THEN 'Innerwear' 
        ELSE 'Heattech'
    END) AS Category,
    (CASE (FLOOR(x / 10) % 10)
        WHEN 0 THEN 'White'
        WHEN 1 THEN 'Black'
        WHEN 2 THEN 'Navy'
        WHEN 3 THEN 'Gray'
        WHEN 4 THEN 'Beige'
        WHEN 5 THEN 'Olive'
        WHEN 6 THEN 'Pink'
        WHEN 7 THEN 'Blue'
        WHEN 8 THEN 'Red'
        ELSE 'Yellow'
    END) AS Color,
    (CASE (FLOOR(x / 100) % 6)
        WHEN 0 THEN 'XS'
        WHEN 1 THEN 'S'
        WHEN 2 THEN 'M'
        WHEN 3 THEN 'L'
        WHEN 4 THEN 'XL'
        ELSE 'XXL'
    END) AS Size,
    ROUND(14.90 + (x % 40) * 3.0, 2) AS Price,
    FLOOR(RAND() * 1000) AS StockLevel
FROM cnt;
