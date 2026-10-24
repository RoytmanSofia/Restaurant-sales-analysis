CREATE SCHEMA restaurant_analysis;
USE restaurant_analysis;
CREATE TABLE menu_items(
menu_item_id INT NOT NULL,
item_name VARCHAR(100),
category VARCHAR(100),
price DECIMAL(6,2),
PRIMARY KEY (menu_item_id)
);

CREATE TABLE order_details(
order_details_id INT NOT NULL,
order_id INT NOT NULL,
order_date DATE,
order_time TIME,
item_id INT,
PRIMARY KEY (order_details_id)
);

CREATE TABLE order_details_raw (
    order_details_id INT NOT NULL,
    order_id INT NOT NULL,
    order_date VARCHAR(30),
    order_time VARCHAR(30),
    item_id VARCHAR(10),
    PRIMARY KEY (order_details_id)
);
-- Before this step, import:
-- menu_items_utf8.csv into menu_items
-- order_details_utf8.csv into order_details_raw
-- Run the INSERT once, after importing the CSV files.
INSERT INTO restaurant_analysis.order_details (
    order_details_id,
    order_id,
    order_date,
    order_time,
    item_id
)
SELECT
    order_details_id,
    order_id,
    STR_TO_DATE(order_date, '%m/%d/%y'),
    STR_TO_DATE(order_time, '%h:%i:%s %p'),
    CAST(NULLIF(item_id, 'NULL') AS UNSIGNED)
FROM restaurant_analysis.order_details_raw;