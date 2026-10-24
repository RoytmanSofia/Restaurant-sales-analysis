USE restaurant_analysis;

-- Check table structures
DESCRIBE menu_items;
DESCRIBE order_details;
DESCRIBE order_details_raw;

-- Check menu size
SELECT COUNT(*) AS menu_items_count
FROM menu_items;

-- Check imported raw rows
SELECT COUNT(*) AS raw_rows
FROM order_details_raw;

-- Check row counts, missing values, dates and times
SELECT
    COUNT(*) AS total_rows,
    COUNT(item_id) AS rows_with_item,
    COUNT(*) - COUNT(item_id) AS missing_items,
    COUNT(order_date) AS rows_with_date,
    COUNT(order_time) AS rows_with_time,
    MIN(order_date) AS first_date,
    MAX(order_date) AS last_date,
    MIN(order_time) AS earliest_time,
    MAX(order_time) AS latest_time
FROM order_details;

-- Check that every non-null item ID exists in the menu
SELECT COUNT(*) AS unmatched_items
FROM order_details AS od
LEFT JOIN menu_items AS mi
    ON od.item_id = mi.menu_item_id
WHERE od.item_id IS NOT NULL
  AND mi.menu_item_id IS NULL;

-- Check for missing menu information or invalid prices
SELECT *
FROM menu_items
WHERE item_name IS NULL
   OR TRIM(item_name) = ''
   OR category IS NULL
   OR TRIM(category) = ''
   OR price IS NULL
   OR price <= 0;