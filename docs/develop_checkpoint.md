# Develop checkpoint

**Goal of this stage:** turn the Plan into working dbt models in small, reviewable steps using **VS Code extension + dbt Fusion**.

## What you should have by the end of Develop
You will create these models (in this order):

1. `stg_website_events`
2. `stg_flower_orders`
3. `fct_customer_funnel` (main deliverable)
4. *(Optional)* `mart_platform_funnel_metrics`

You should be able to run each model by itself:

```bash
dbt run -s stg_website_events
dbt run -s stg_flower_orders
dbt run -s fct_customer_funnel
dbt run -s mart_platform_funnel_metrics
```


## Working rules for this stage
- Make one small change at a time.
- Run a single model after each change.
- Preview a few rows to sanity check.
- Commit in small chunks once a step is working.

## Required inputs
You will reference raw data via dbt **sources**:
- `raw_website_events`
- `raw_flower_orders`

Before writing models, declare sources in a YAML file (for example `models/staging/_sources.yml`) so you can use `source()`.

## Model requirements (minimum)
### `stg_website_events`
Must include:
- `customer_id`
- `event_name`
- `event_ts` (convert from epoch ms)
- `event_date` (derived from `event_ts`)
- `platform`

Also:
- Make event names consistent (you will rely on these downstream):
	- `page_hit`
	- `add_to_cart`
	- `go_to_checkout`
	- `place_order`

### `stg_flower_orders`
Must include:
- `order_id`
- `customer_id`
- `order_ts` (convert from epoch ms)
- `order_date`
- `order_value`
- `platform`

### `fct_customer_funnel`
**Grain:** one row per `customer_id`.

Must include first timestamps (per customer):
- `first_page_hit_time`
- `first_add_to_cart_time`
- `first_go_to_checkout_time`
- `first_place_order_time`

Must include:
- `reached_checkout` (true when checkout timestamp exists)
- `placed_order` (true when place order timestamp exists)
- `time_to_order_seconds` (difference between first page hit and first place order)
- `platform` (platform at `place_order` if present, else from latest event)

*(Optional)* Join `stg_flower_orders` to validate `place_order` events roughly match orders, and to pull `order_value` if desired.

### *(Optional)* `mart_platform_funnel_metrics`
Aggregate `fct_customer_funnel` by `platform`:
- `customers_reached_checkout`
- `customers_placed_order`
- `conversion_rate` = placed / reached_checkout
- `avg_time_to_order_seconds` (only for customers who placed an order)

## Quick self-checks (do these before you move to Test)
- Timestamps look like real timestamps (not epoch numbers).
- `fct_customer_funnel` has **one row per customer**.
- `time_to_order_seconds` is **never negative** for customers who placed an order.
- Counts of `place_order` events are in the same ballpark as rows in `raw_flower_orders`.

## Common pitfalls
- Forgetting to convert epoch milliseconds to timestamps.
- Event name mismatches (typos or inconsistent casing) causing funnel steps to look “missing”.
- Accidentally generating multiple rows per customer in `fct_customer_funnel` (usually a join issue).

## Suggested development loop (repeat)
1. Edit the model.
2. Use dbt Fusion/VS Code extension previews to sanity check logic.
3. Run the single model you changed.
4. Preview results.
5. Commit once it looks correct.