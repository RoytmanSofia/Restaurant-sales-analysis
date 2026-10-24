SELECT
COUNT(*) AS total_items,
COUNT(DISTINCT order_id) AS total_orders
FROM restaurant_analysis.order_details;
SELECT 
ROUND(SUM(mi.price),2) AS know_items_revenue,
COUNT(*) AS priced_items
FROM restaurant_analysis.order_details AS od
INNER JOIN  restaurant_analysis.menu_items AS mi
ON od.item_id = mi.menu_item_id;
SELECT
    mi.item_name,
    mi.category,
    COUNT(*) AS items_sold,
    ROUND(SUM(mi.price), 2) AS revenue
FROM restaurant_analysis.order_details AS od
INNER JOIN restaurant_analysis.menu_items AS mi
    ON od.item_id = mi.menu_item_id
GROUP BY
    mi.menu_item_id,
    mi.item_name,
    mi.category
ORDER BY revenue DESC
LIMIT 10;

-- sales and revenue by menu category
SELECT
    mi.category,
    COUNT(*) AS items_sold,
    ROUND(SUM(mi.price), 2) AS revenue
FROM restaurant_analysis.order_details AS od
INNER JOIN restaurant_analysis.menu_items AS mi
    ON od.item_id = mi.menu_item_id
GROUP BY mi.category
ORDER BY revenue DESC;

-- orders and items by hour
SELECT
    HOUR(order_time) AS order_hour,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(*) AS total_items
FROM restaurant_analysis.order_details
GROUP BY HOUR(order_time)
ORDER BY order_hour;

-- monthly orders and revenue from id items
SELECT
    DATE_FORMAT(od.order_date, '%Y-%m') AS order_month,
    COUNT(DISTINCT od.order_id) AS total_orders,
    COUNT(od.item_id) AS identified_items,
    ROUND(SUM(mi.price), 2) AS known_items_revenue,
    ROUND(
        SUM(mi.price) / COUNT(DISTINCT od.order_id), 2
    ) AS known_revenue_per_order
FROM restaurant_analysis.order_details AS od
LEFT JOIN restaurant_analysis.menu_items AS mi
    ON od.item_id = mi.menu_item_id
GROUP BY DATE_FORMAT(od.order_date, '%Y-%m')
ORDER BY order_month;

-- monthly revenue and average revenue per calendar day
SELECT
    DATE_FORMAT(od.order_date, '%Y-%m') AS order_month,
    DAY(LAST_DAY(MIN(od.order_date))) AS calendar_days,
    ROUND(SUM(mi.price), 2) AS known_items_revenue,
    ROUND(
        SUM(mi.price) / DAY(LAST_DAY(MIN(od.order_date))), 2
    ) AS revenue_per_calendar_day
FROM restaurant_analysis.order_details AS od
LEFT JOIN restaurant_analysis.menu_items AS mi
    ON od.item_id = mi.menu_item_id
GROUP BY DATE_FORMAT(od.order_date, '%Y-%m')
ORDER BY order_month;

-- Orders by weekday and hour, including zero-order hours
WITH weekday_dates AS (
    SELECT
        WEEKDAY(order_date) AS weekday_number,
        COUNT(DISTINCT order_date) AS total_dates
    FROM restaurant_analysis.order_details
    GROUP BY WEEKDAY(order_date)
)
SELECT
    WEEKDAY(od.order_date) AS weekday_number,
    DAYNAME(od.order_date) AS weekday_name,
    HOUR(od.order_time) AS order_hour,
    COUNT(DISTINCT od.order_id) AS total_orders,
    wd.total_dates,
    ROUND(
        COUNT(DISTINCT od.order_id) / wd.total_dates,
        2
    ) AS avg_orders_per_day
FROM restaurant_analysis.order_details AS od
INNER JOIN weekday_dates AS wd
    ON WEEKDAY(od.order_date) = wd.weekday_number
GROUP BY
    WEEKDAY(od.order_date),
    DAYNAME(od.order_date),
    HOUR(od.order_time),
    wd.total_dates
ORDER BY
    avg_orders_per_day DESC,
    weekday_number,
    order_hour;

-- Distribution of order sizes
WITH order_sizes AS (
    SELECT
        order_id,
        COUNT(*) AS item_rows,
        COUNT(*) - COUNT(item_id) AS missing_item_rows
    FROM restaurant_analysis.order_details
    GROUP BY order_id
)
SELECT
    item_rows,
    COUNT(*) AS total_orders,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2
    ) AS pct_of_orders,
    SUM(missing_item_rows) AS missing_item_rows
FROM order_sizes
GROUP BY item_rows
ORDER BY item_rows;

-- Top 10 orders by known revenue
SELECT
    od.order_id,
    MIN(od.order_date) AS order_date,
    COUNT(*) AS item_rows,
    COUNT(*) - COUNT(mi.menu_item_id) AS unpriced_rows,
    ROUND(SUM(mi.price), 2) AS known_revenue
FROM restaurant_analysis.order_details AS od
LEFT JOIN restaurant_analysis.menu_items AS mi
    ON od.item_id = mi.menu_item_id
GROUP BY od.order_id
ORDER BY known_revenue DESC, od.order_id
LIMIT 10;

-- Category composition of the top 10 orders
WITH top_orders AS (
    SELECT
        od.order_id,
        SUM(mi.price) AS known_revenue
    FROM restaurant_analysis.order_details AS od
    LEFT JOIN restaurant_analysis.menu_items AS mi
        ON od.item_id = mi.menu_item_id
    GROUP BY od.order_id
    ORDER BY known_revenue DESC, od.order_id
    LIMIT 10
)
SELECT
    COALESCE(mi.category, 'Unknown') AS category,
    COUNT(*) AS item_rows,
    COUNT(DISTINCT od.order_id) AS orders_with_category,
    ROUND(SUM(mi.price), 2) AS known_revenue
FROM top_orders AS t
INNER JOIN restaurant_analysis.order_details AS od
    ON t.order_id = od.order_id
LEFT JOIN restaurant_analysis.menu_items AS mi
    ON od.item_id = mi.menu_item_id
GROUP BY COALESCE(mi.category, 'Unknown')
ORDER BY known_revenue DESC;

-- Top 10 menu items by quantity sold
SELECT
    mi.menu_item_id,
    mi.item_name,
    mi.category,
    COUNT(*) AS items_sold,
    ROUND(SUM(mi.price), 2) AS known_revenue
FROM restaurant_analysis.order_details AS od
INNER JOIN restaurant_analysis.menu_items AS mi
    ON od.item_id = mi.menu_item_id
GROUP BY
    mi.menu_item_id,
    mi.item_name,
    mi.category
ORDER BY items_sold DESC, mi.menu_item_id
LIMIT 10;
