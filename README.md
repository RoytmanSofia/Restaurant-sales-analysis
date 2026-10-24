# Restaurant Sales & Ordering Patterns

I work as a restaurant shift manager, so I chose a familiar subject for my first SQL portfolio project. I wanted to explore questions that come up at work: when orders peak, which dishes sell most, and whether the most frequently ordered dishes also bring in the most revenue.

For this project, I used the Maven Analytics Restaurant Orders dataset for January–March 2023. These are sample data, not records from my workplace.

I prepared and analysed the data in MySQL and built five charts in Apple Numbers.

## What I looked at

- Sales and revenue by dish and menu category.
- Orders by hour and by weekday-hour combination.
- Monthly revenue, adjusted for the number of calendar days.
- The distribution of order sizes.
- The composition of the ten orders with the highest known revenue.

## Preparing the data

The source files contain menu items and order details.

The order CSV used dates and times such as `3/31/23` and `11:38:36 AM`. Importing them directly into DATE and TIME columns failed, so I first loaded the orders into a staging table with text columns. I then converted the values using `STR_TO_DATE`.

I kept rows with missing item IDs. They still tell us when an order was placed and how many positions were recorded, even though their prices are unknown.

After conversion, the data contained:

| Metric | Result |
|---|---:|
| Menu items | 32 |
| Order detail rows | 12,234 |
| Distinct orders | 5,370 |
| Identified item rows | 12,097 |
| Rows with missing item IDs | 137 |
| Non-null item IDs without a menu match | 0 |

All order detail rows had dates and times after conversion. The period covered 1 January to 31 March 2023.

## How revenue was calculated

I matched identified order items to the menu and summed their listed prices.

This gave **159,217.90 in known revenue** from **12,097 identified items**. The 137 rows with missing item IDs were excluded from revenue calculations but retained for order counts and timing analysis.

The calculation assumes menu prices remained constant during the period. It is reconstructed revenue at menu prices, not profit or a verified payment total.

## Main findings

### The most ordered dish was not the revenue leader

Hamburger led by quantity, with **622 items sold**. Korean Beef Bowl led by known revenue, generating **10,554.60** from **588 items**.

Edamame sold almost as often as Hamburger, with **620 items**, but generated **3,100.00**. Quantity and revenue rankings answer different questions.

### Italian led revenue, while Asian led quantity

| Category | Items sold | Known revenue |
|---|---:|---:|
| Italian | 2,948 | 49,462.70 |
| Asian | 3,470 | 46,720.65 |
| Mexican | 2,945 | 34,796.80 |
| American | 2,734 | 28,237.75 |

Italian generated the most revenue despite selling fewer items than Asian. The difference reflects the prices and mix of dishes sold. Without cost data, it does not tell us which category was more profitable.

### Orders peaked at lunch and again in the evening

Across the quarter, **12:00–12:59** was the busiest hour, with **647 orders**. The evening peak was **17:00–17:59**, with **623 orders**.

The weekday-hour breakdown showed the highest average on **Saturday at 12:00: 9.17 orders**, followed by **Sunday at 13:00: 8.92 orders**.

For each weekday-hour combination, I divided the order count by all dates of that weekday represented in the dataset. This includes dates with zero orders in that particular hour. Entirely missing dates would not be included.

### February looked different after adjusting for month length

| Month | Orders | Known revenue | Revenue per calendar day |
|---|---:|---:|---:|
| January | 1,845 | 53,816.95 | 1,736.03 |
| February | 1,685 | 50,790.35 | 1,813.94 |
| March | 1,840 | 54,610.60 | 1,761.63 |

February had the lowest monthly revenue but the highest revenue per calendar day. Its shorter length matters when comparing monthly totals.

This adjustment does not account for weekday mix, holidays or other possible influences.

### Most orders contained one or two positions

**67.26% of orders contained one or two item rows.** Orders with up to four rows accounted for **96.48%** of all orders.

The largest orders contained 14 rows. Order size includes unidentified item rows and should not be interpreted as the number of guests.

### The ten highest-value orders contained a mix of categories

Each of the ten orders with the highest known revenue contained **13 or 14 item rows**.

Italian dishes appeared in all ten orders and contributed **45 positions** and **753.00** in known revenue. Asian and Mexican dishes also appeared in all ten.

One order contained an unidentified item, making its calculated revenue incomplete. This is a small group selected by revenue, so it cannot establish what causes customers to spend more.

## What I would investigate next in a restaurant

**Preparation before peak hours.** I would compare the observed lunch and evening peaks with preparation schedules, breaks and service times. Order counts alone are not enough to decide how many employees a shift needs.

**Availability of key dishes.** Hamburger and Korean Beef Bowl would be useful items to monitor for stockouts because they lead quantity and revenue respectively. Any decision to increase stock or promote them would also need information about costs, waste and kitchen capacity.

**An optional add-on test.** The share of one- and two-position orders provides a reason to test a relevant addition. It does not mean those orders are too small. I would compare contribution margin per order and add-on uptake, while monitoring service time and customer feedback.

These are proposals for testing, not improvements demonstrated by this analysis.

## Repository contents

- `01_setup.sql` — schema, tables and conversion from the staging table.
- `02_data_checks.sql` — structure, missing value, date, time and menu-match checks.
- `03_sales_analysis.sql` — analysis queries.
- CSV files — exported query results.
- PDF — five charts built in Apple Numbers.

## How to reproduce

The analysis uses CTEs and window functions and requires MySQL 8.0 or later.

1. Obtain the Restaurant Orders CSV files from Maven Analytics.
2. Run the schema and table creation statements in `01_setup.sql`.
3. Import the menu CSV into `menu_items`.
4. Import the orders CSV into `order_details_raw`.
5. Run the conversion INSERT in `01_setup.sql` once.
6. Run `02_data_checks.sql`.
7. Run `03_sales_analysis.sql`.

CSV imports are manual steps between table creation and conversion. The setup file should not be executed as one uninterrupted script before importing the data.

Running the conversion INSERT again will produce duplicate primary key errors.

During import, I also encountered a CSV decoding problem. Removing the UTF-8 byte order mark from a copy of the file resolved it; the original source files were preserved.

## Limitations

Revenue is based on listed menu prices and excludes unidentified items. Discounts, refunds, taxes and historical price changes are not accounted for.

The data contain no customer identifiers, guest counts, ingredient costs, staffing records or service durations. They cannot establish customer retention, profitability or staffing requirements.

The analysis covers three months of sample data. It describes observed patterns rather than proving their causes or predicting future performance.

## Source

Maven Analytics — Restaurant Orders dataset.Order size here means the number of recorded item rows, including rows with missing item IDs. It is not the number of customers or guests at a table.

### The highest-value orders were large and mixed

The ten orders with the highest known revenue each contained **13 or 14 item rows**.

Italian dishes appeared in all ten and contributed **45 positions** and **753.00** in known revenue. Asian and Mexican dishes also appeared in all ten.

One of these orders contained an unidentified item, so its calculated value is incomplete. Selecting orders by revenue also favours expensive items; this small group cannot establish what causes customers to spend more.

## Actions worth testing

### Prepare around the observed peaks

Use the lunch and evening patterns as a starting point for reviewing preparation schedules and breaks. Before changing staffing, compare them with service times, the number of items per order and the existing shift structure.

### Monitor availability of key dishes

Hamburger and Korean Beef Bowl are worth tracking for stock availability because they lead quantity and revenue respectively. Ingredient costs, waste and preparation effort would be needed before recommending greater promotion or larger stock levels.

### Test an optional add-on

The high share of one- and two-position orders gives a reason to test a relevant add-on offer. It does not prove that those orders are too small or that customers want another item.

A test should compare contribution margin per order and add-on uptake, while monitoring service time and customer feedback. The current dataset cannot measure the effect of such an offer.

## Files

- `01_setup.sql` — table creation and conversion from the staging table.
- `02_data_checks.sql` — checks of structures, missing values, dates, times and menu matches.
- `03_sales_analysis.sql` — sales, timing, order size and category analysis.
- CSV files — exported query results.
- PDF — five charts created in Apple Numbers.

## Reproducing the analysis

Use MySQL 8.0 or later for the CTEs and window functions.

1. Obtain the Restaurant Orders CSV files from Maven Analytics.
2. Run the schema and table creation statements in `01_setup.sql`.
3. Import the menu CSV into `menu_items` and the orders CSV into `order_details_raw`.
4. Run the INSERT statement that converts the staging data into `order_details`.
5. Run `02_data_checks.sql`, followed by `03_sales_analysis.sql`.

The CSV imports are manual steps between table creation and conversion. Do not run the conversion INSERT twice: the primary keys prevent duplicate order detail IDs.

If Workbench reports a decoding error, check the CSV encoding and whether it contains a UTF-8 byte order mark. Keep the original files and use cleaned copies for import.

## Scope

This is an exploratory analysis of three months of sample restaurant data. It contains no customer identifiers, guest counts, food costs, staffing records or service durations.

The findings describe this dataset. The proposed actions are hypotheses for further investigation or testing, not measured business improvements.

## Source

Maven Analytics — Restaurant Orders dataset.
