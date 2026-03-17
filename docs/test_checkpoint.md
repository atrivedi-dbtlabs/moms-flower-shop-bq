# Test checkpoint

**Goal of this stage:** encode trust in the models with automated checks, so we can run this reliably locally now and in scheduled runs later.

## What you should have by the end of Test
You will add automated checks for (in this order):
1. Schema tests for `stg_website_events`
2. Schema tests for `stg_flower_orders`
3. Schema tests for `fct_customer_funnel` (grain + key constraints)
4. 1–2 singular (business logic) tests
5. A repeatable local test run command (`dbt test` and/or `dbt build`)

You should be able to run targeted tests as you go:

```
dbt test -s stg_website_events
dbt test -s stg_flower_orders
dbt test -s fct_customer_funnel
dbt test
```

If you want one “do it all” workflow:

```
dbt build -s +mart_platform_funnel_metrics
```

## Working rules for this stage
- Add tests **closest to the source of truth** (usually staging).
- Start with **schema tests** (fast + high signal), then add **business logic tests**.
- Make one change at a time.
- Run only the tests you just added.
- Commit once a set of tests is green.

## Required inputs
You will add tests in two places:
- YAML schema tests next to your models (for example in `models/staging/*.yml` and `models/marts/*.yml`)
- Singular tests as SQL files under `tests/`

## Test requirements (minimum)

### `stg_website_events`
**Must test:**
- `not_null` on:
	- `customer_id`
	- `event_name`
- `unique` on:
	- `customer_id` (combined with `not_null`, will form the primary key tests)
- `accepted_values` on `event_name` (so funnel steps do not silently break):
	- `page_hit`
	- `add_to_cart`
	- `go_to_checkout`
	- `place_order`

**Nice-to-have (optional):**
- Add a basic “timestamp exists” check via `not_null` on `event_ts`.

### `stg_flower_orders`
**Must test:**
- `unique` + `not_null` on `order_id` (primary key tests)
- `not_null` on:
	- `customer_id`

### `fct_customer_funnel`
**Grain:** one row per `customer_id`.

**Must test:**
- `unique` + `not_null` on `customer_id`

**Why this is required**
This is the automated guarantee that your mart has the grain you intended. If this fails, downstream metrics can double count customers.

## Singular (business logic) tests (minimum 1, recommended 2)
Schema tests validate the shape of the data. Singular tests validate the *meaning* of the funnel.

Create SQL tests under `tests/`.

### Business logic test #1 (required): time-to-order is never negative
Expectation:
- For any customer who placed an order, `time_to_order_seconds >= 0`.

Suggested file:
- `tests/test_time_to_order_non_negative.sql`

### Optional test #1: ordering of funnel timestamps makes sense
Expectation:
- For customers who placed an order, `first_place_order_time` should be after `first_page_hit_time`.

Suggested file:
- `tests/test_place_order_after_page_hit.sql`

### Optional test #2: reconciliation sanity check 
Expectation:
- Count of customers with `place_order` events should be in the same ballpark as count of customers with orders.
- This does not need to be exact, but it should not be wildly off.

Suggested file:
- `tests/test_place_order_events_roughly_match_orders.sql`

## Quick self-checks (do these before you move to Deploy)
- You can run `dbt test` locally and it passes.
- If a test fails, you can quickly locate the violating rows and explain the root cause.
- `fct_customer_funnel` has **one row per customer** (enforced by tests).
- `time_to_order_seconds` is **never negative** for customers who placed an order.
- Event names are constrained to the expected funnel values.
- For any blocking tests, consider altering their `severity` to `warn` so that you are still able to move to the next stage.

## Common pitfalls
- Adding tests too far downstream (catch issues earlier in staging when possible).
- Forgetting `accepted_values` for `event_name`, leading to silent funnel drop-offs.
- Misinterpreting a failing test as “bad data” when the assumption is wrong (sometimes the test needs to change).
- Writing singular tests that are too strict (start with invariants; add thresholds later).

## Suggested test loop (repeat)
1. Add or edit a YAML test file for one model.
2. Run targeted tests for just that model:
`dbt test -s <model_name>`
3. Add one singular test file under `tests/`.
4. Run:
`dbt test`
5. Debug using the failure output and inspect the offending rows.
6. Commit once green.