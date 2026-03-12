# Plan

## Question
For each customer funnel, how long does it take to get from first interaction to ordering, and how does success versus abandonment differ by platform?

## Scope (v1)
In v1, we will answer exactly two questions:
1. For customers who successfully place an order, how long is it from their **first website event** to **place order**, and does that differ by **platform**?
2. Of all funnels that **reach checkout**, what share **convert versus abandon**, by platform?

## Inputs
We will use the minimum set of raw sources required to answer the v1 questions.

### Required
- `raw_website_events`
	- Used for funnel steps and event timestamps
	- Used for platform segmentation
- `raw_flower_orders`
	- Used for order creation timestamp
	- Used to sanity-check order counts

### Optional (v2+ enrichment)
- `raw_customers` (customer attributes)
- `raw_addresses` (geo or regional analysis)

## Output models
We will build two final models.

### 1) `fct_customer_funnel`
**Grain:** one row per customer.

**Contains:**
- `customer_id`
- `first_page_hit_at`
- `first_add_to_cart_at`
- `first_go_to_checkout_at`
- `first_place_order_at`
- `reached_checkout` (boolean)
- `placed_order` (boolean)
- `time_to_order_seconds` (only for customers who placed an order)
- `platform`

### 2) `agg_platform_funnel_metrics`
**Grain:** one row per platform.

**Contains:**
- `platform`
- `customers_reached_checkout`
- `customers_placed_order`
- `conversion_rate`
- `avg_time_to_order_seconds`

## Definitions & logic notes
- **First interaction:** the first website event we observe for a customer in `raw_website_events`.
- **Funnel steps:** `page_hit` → `add_to_cart` → `go_to_checkout` → `place_order`.
- **Multiple funnels:** if a customer has multiple funnels, use the **first occurrence** of each step.
- **Platform definition:** use platform from the `place_order` event when available, otherwise use the latest platform observed for that customer.

## Acceptance criteria (definition of done)
- All event timestamps are converted from epoch milliseconds into real timestamps.
- For customers who placed an order, `time_to_order_seconds` is never negative.
- The count of `place_order` events is roughly in the same ballpark as the number of rows in `raw_flower_orders`.
- The mart shows different conversion rates or time-to-order by platform, and we can explain what we’re seeing.
- `dbt build` passes for the models we created.

## Assumptions & edge cases
- If we discover missing customer IDs, duplicated events, or out-of-order steps, we will document it and keep moving.
- The goal is a trustworthy v1, not a perfect production model.