# Restaurant Sales & Ordering Patterns

I work as a restaurant shift manager, so I chose a familiar subject for my first SQL portfolio project. I wanted to explore questions that come up at work: when orders peak, which dishes sell most, and whether the most frequently ordered dishes also generate the most revenue.

I used the Maven Analytics Restaurant Orders dataset for January–March 2023. These are sample data, not records from my workplace.

I prepared and analysed the data in MySQL and built five charts in Apple Numbers.

## Questions

- Which dishes lead by quantity sold and revenue?
- How do menu categories compare?
- When are orders busiest, including differences by weekday?
- How does month length affect revenue comparisons?
- What order sizes are most common?
- Which categories appear in the ten orders with the highest known revenue?

## Data preparation

The source files contain menu items and order details.

The orders CSV used dates and times such as `3/31/23` and `11:38:36 AM`. Direct import into DATE and TIME columns failed, so I loaded the orders into a staging table with text columns, then converted the values using `STR_TO_DATE`.

I kept rows with missing item IDs. They still provide information about order timing and size, even though their prices are unknown.

| Metric | Result |
|---|---:|
| Menu items | 32 |
| Order detail rows | 12,234 |
| Distinct orders | 5,370 |
| Identified item rows | 12,097 |
| Rows with missing item IDs | 137 |
| Non-null item IDs without a menu match | 0 |

All order detail rows had dates and times after conversion. The date range was 1 January to 31 March 2023.

## Revenue calculation

I matched identified order items to the menu and summed their listed prices.

This produced **159,217.90 in known revenue** from **12,097 identified items**. The 137 rows with missing item IDs were excluded from revenue calculations but retained for order counts, timing and order size.

The calculation assumes menu prices stayed constant throughout the period. It represents reconstructed revenue at menu prices, not profit or a verified payment total.

## Findings

### Quantity and revenue had different leaders

Hamburger was the most frequently ordered dish, with **622 items sold**. Korean Beef Bowl generated the most known revenue: **10,554.60** from **588 items**.

Edamame sold almost as often as Hamburger, with **620 items**, but generated **3,100.00**. Sales volume alone does not show how much revenue an item contributes.

### Italian led revenue; Asian led quantity

| Category | Items sold | Known revenue |
|---|---:|---:|
| Italian | 2,948 | 49,462.70 |
| Asian | 3,470 | 46,720.65 |
| Mexican | 2,945 | 34,796.80 |
| American | 2,734 | 28,237.75 |

Italian generated more revenue from fewer items than Asian. This reflects the prices and mix of dishes sold. Without cost data, it does not establish which category was more profitable.

### Orders peaked at lunch and in the evening

Across the quarter, **12:00–12:59** was the busiest hour, with **647 orders**. The evening peak was **17:00–17:59**, with **623 orders**.

The weekday-hour breakdown showed the highest average on **Saturday at 12:00–12:59: 9.17 orders**, followed by **Sunday at 13:00–13:59: 8.92 orders**.

For each weekday-hour combination, I divided the order count by all dates of that weekday represented in the dataset. Dates with no orders in that particular hour remain in the denominator. Entirely missing dates would not be included.

These figures describe incoming orders, not preparation time or the number of employees needed.

### February had the highest revenue per calendar day

| Month | Orders | Known revenue | Revenue per calendar day |
|---|---:|---:|---:|
| January | 1,845 | 53,816.95 | 1,736.03 |
| February | 1,685 | 50,790.35 | 1,813.94 |
| March | 1,840 | 54,610.60 | 1,761.63 |

February had the lowest monthly revenue but the highest revenue per calendar day. Comparing monthly totals alone would overlook its shorter length.

Dividing by calendar days adjusts for month length, but not for weekday mix, holidays or other influences.

### Most orders contained one or two items

**67.26% of orders contained one or two item rows**, and **96.48% contained no more than four**. The largest orders contained 14 rows.

Order size means the number of recorded item rows, including unidentified items. It is not the number of guests.

### The highest-value orders included several categories

Each of the ten orders with the highest known revenue contained **13 or 14 item rows**.

Italian dishes appeared in all ten orders, contributing **45 items** and **753.00** in known revenue. Asian and Mexican dishes also appeared in all ten.

One order contained an unidentified item, making its calculated revenue incomplete. Selecting orders by revenue also favours more expensive dishes. This small group cannot establish what causes customers to spend more.

## What I would investigate next

### Preparation before peak hours

I would compare lunch and evening demand with preparation schedules, breaks and service times. The patterns provide a starting point for reviewing shifts, but order counts alone cannot establish staffing requirements.

### Availability of key dishes

Hamburger and Korean Beef Bowl would be useful items to monitor for stockouts because they lead quantity and revenue respectively. Decisions about increasing stock or promotion would also need information about ingredient costs, waste and kitchen capacity.

### An optional add-on test

The share of one- and two-item orders provides a reason to test a relevant add-on offer. It does not prove that these orders are too small or that customers want another item.

I would compare contribution margin per order and add-on uptake, while monitoring service time and customer feedback. The current dataset cannot measure the effect of this proposal.

## Repository contents

- `01_setup.sql` — schema, tables and conversion from the staging table.
- `02_data_checks.sql` — checks of table structures, missing values, dates, times and menu matches.
- `03_sales_analysis.sql` — analysis queries.
- CSV files — exported query results.
- PDF — five charts created in Apple Numbers.

The charts cover category revenue, orders by hour, the top ten dishes by revenue, average daily revenue by month, and order size distribution.

## How to reproduce

The analysis uses CTEs and window functions and requires MySQL 8.0 or later.

1. Obtain the Restaurant Orders CSV files from Maven Analytics.
2. Run the schema and table creation statements in `01_setup.sql`.
3. Import the menu CSV into `menu_items`.
4. Import the orders CSV into `order_details_raw`.
5. Run the conversion INSERT in `01_setup.sql` once.
6. Run `02_data_checks.sql`.
7. Run the queries in `03_sales_analysis.sql`.

The CSV imports are manual steps between table creation and conversion. Do not execute the whole setup file before importing the data.

The setup creates a new schema and tables. Running those statements again against the existing database will produce “already exists” errors. Running the conversion INSERT twice will produce duplicate primary key errors.

During import, I also encountered a CSV decoding problem. Removing the UTF-8 byte order mark from copies of the files resolved it. The original source files were preserved.

## Limitations

- Revenue uses listed menu prices and excludes unidentified items. Discounts, refunds, taxes and historical price changes are not accounted for.
- Order counts and item counts do not identify individual customers or guest numbers.
- The dataset contains no ingredient costs, staffing records or service durations, so profitability and staffing needs cannot be calculated.
- The weekday-hour averages use dates represented in the order data, rather than an independently verified opening calendar.
- Three months of sample data are not enough to establish annual seasonality.
- The recommendations are proposals for investigation or testing, not measured business improvements.

## Source

Maven Analytics — Restaurant Orders dataset.
