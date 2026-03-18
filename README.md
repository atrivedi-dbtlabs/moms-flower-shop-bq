# Mom's Flower Shop - dbt Project
```
                    _
                  _(_)_                          wWWWw   _
      @@@@       (_)@(_)   vVVVv     _     @@@@  (___) _(_)_
     @@()@@ wWWWw  (_)\    (___)   _(_)_  @@()@@   Y  (_)@(_)
      @@@@  (___)     `|/    Y    (_)@(_)  @@@@   \|/   (_)\
       /      Y       \|    \|/    /(_)    \|      |/      |
    \ |     \ |/       | / \ | /  \|/       |/    \|      \|/
    \\|//   \\|///  \\\|//\\\|/// \|///  \\\|//  \\|//  \\\|// 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
```

This project was the default sample project for SDF, now available to use with the dbt Fusion Engine. Here, we are using it for the University Partners program.

The project contains data about Mom's Flower Shop, including:
1. **Customers** - Customer information
2. **Marketing campaigns** - Marketing campaign events and costs  
3. **Website events** - User interactions within the website
4. **Street addresses** - Customer address information
5. **Flower Shop Orders** - Flower, Chocolates, and Vase orders from Mom's Flower Shop! 

## Project Models Organization

### `staging`
Staging models live in `models/staging/`. These are lightweight views, prefixed with `stg_` that clean and standardize source data for reuse by downstream models.

### `marts`
Marts models live in `models/marts/`. These models consume staging outputs and produce business-facing tables and views (aggregations, fact tables, etc). They may be materialized as tables, incremental models, or ephemeral models depending on performance and use case.

## Model Lineage

```
Raw (source tables)
    ↓  
Staging Models (Views with stg_ prefix)
    ↓
Marts Models 
```

## What this project answers
This project helps you answer:
- How many customers move through the funnel from first site visit to checkout to placing an order
- Conversion performance by **platform** (for example, web vs mobile)
- How long it takes customers to place an order after their first interaction (**time-to-order**)

## How to interpret the metrics 
### Primary table: `mart_platform_funnel_metrics` (one row per platform)

This table is meant for quick comparisons across platforms (for example, Android vs iOS). Common fields include:

- `platform`
	- The platform associated with the order event when present.
	- If the order event does not include platform, the platform may be **derived** from the latest available event.

- `conversion_rate`
	- **Definition:** customers who placed an order ÷ customers who reached checkout
	- **In words:** “Of the customers who got to checkout, what fraction placed an order?”

- `avg_time_to_order_seconds` (or similar)
	- **Definition:** average of `time_to_order_seconds` for customers who placed an order
	- **Time origin:** measured from the **first page hit** (or **first add to cart** where page hit is unavailable), not from checkout

### Debug table: `fct_customer_funnel` (one row per customer)

Use this table when you need to understand *why* an aggregate metric looks the way it does.

Key fields:
- `first_page_hit_time`
	- First observed `page_hit` timestamp for the customer.
- `first_go_to_checkout_time`
	- First observed checkout timestamp for the customer.
- `placed_order`
	- True if a `place_order` event was observed.
- `time_to_order_seconds`
	- Seconds from first page hit or first add to cart to first place order.
	- **Null behavior:** null if no order was placed.

## What tables to use
Use these models (in order of “most useful first”):
- **Primary output:** `mart_platform_funnel_metrics`
	- One row per platform with conversion rate and average time-to-order metrics
- **Debug / deeper detail:** `fct_customer_funnel`
	- One row per customer with first timestamps for each funnel step and derived conversion flags
- **Staging (inputs, cleaned):**
	- `stg_website_events` (cleaned website events, timestamps converted from epoch ms)
	- `stg_flower_orders` (cleaned orders, timestamps converted from epoch ms)

## How to run it
Build the final mart plus its dependencies:
`dbt build -s +mart_platform_funnel_metrics`

Helpful alternative:
- Build everything:
`dbt build`

## Where outputs land in BigQuery
When you run the commands above, dbt will write tables/views to BigQuery in your configured target (from `profiles.yml`):
- **Project:** `<your_gcp_project>`
- **Dataset:** `<your_dataset>` (often the value of `dataset` in your profile/target)

At minimum, expect to find:
- `<your_dataset>.mart_platform_funnel_metrics`
- `<your_dataset>.fct_customer_funnel`
