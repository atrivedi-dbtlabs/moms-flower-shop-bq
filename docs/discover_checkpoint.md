# Discover checkpoint

**Goal of this stage:** make your dbt project **self-explanatory** for someone new. A student (or teammate) should be able to understand what the models represent, which tables to use, and how to interpret the metrics, *without reading all the SQL*.

## What you should have by the end of Discover

You will have:
1. Clear **model-level descriptions** for the important staging + mart models
2. Clear **column-level descriptions** for the fields people actually use
3. A **“Start here”** section in the repo README that tells a beginner what to run and what to look at
4. A short **“How to interpret the metrics”** note to prevent misuse

## Working rules for this stage

- Write docs for the **next person**, not for yourself.
- Optimize for: “I opened the repo for the first time and I know what to do.”
- Prefer short, concrete descriptions over long explanations.
- Document anything that could be **misinterpreted** (especially metrics and flags).
- If a model or column name is ambiguous, its description should remove ambiguity.

## Required inputs

You will need:
- A local repo with the project checked out
- A successful build from the Test stage (or at least a working subset)
- Access to the YAML files where model + column descriptions live

## Discover requirements (minimum)

### 1) Add model descriptions (the “what is this?” layer)

Add descriptions to the models that matter most (staging + facts + marts).

**Where to do this:**
- In your model YAML files (commonly in `models/staging/*.yml`, `models/marts/*.yml`)

**Minimum models to describe (example project):**
- `stg_website_events`
	- Cleaned website events with timestamps converted from epoch ms.
- `stg_flower_orders`
	- Cleaned orders with timestamps converted from epoch ms.
- `fct_customer_funnel`
	- One row per customer. First timestamps for each funnel step plus derived conversion flags and time-to-order.
- `mart_platform_funnel_metrics`
	- One row per platform. Conversion rate and average time-to-order metrics.

**Expectation:**
- A new person can explain what each model represents after reading descriptions only.

---

### 2) Add column descriptions for key fields (prevent misinterpretation)

Add column-level descriptions for the fields people will actually use.

**Minimum columns to document (example project):**
- `first_page_hit_time`
	- First observed `page_hit` timestamp for this customer.
- `first_go_to_checkout_time`
	- First observed checkout timestamp for this customer.
- `placed_order`
	- True if a `place_order` event was observed.
- `time_to_order_seconds`
	- Seconds from first page hit or first add to cart to first place order. Null if no order was placed.
- `platform`
	- Platform associated with the order event when present, otherwise derived from the latest event.

**Expectation:**
- Someone can use the table without guessing what fields mean.

---

### 3) Create a “Start here” section in the README

Add a short section to `README.md` that answers the questions a beginner will have.

**README “Start here” must include:**
- **What this project answers**
- **What tables to use**
- **How to run it**
- **Where outputs land** (e.g., BigQuery dataset / schema)

**Example bullets you can adapt:**
- Run: `dbt build -s +mart_platform_funnel_metrics`
- Primary output: `mart_platform_funnel_metrics`
- Debug output: `fct_customer_funnel`

**Expectation:**
- A beginner can run one command and know exactly which tables to open after.

---

### 4) Add a “How to interpret the metrics” note

Add a short note (README section is fine) that prevents the most common misreadings.

**Minimum interpretation notes (example project):**
- Conversion rate is defined as customers who placed an order divided by customers who reached checkout.
- Time-to-order is measured from first page hit (or first add to cart if page hit is null), not from first go to checkout.
- These metrics are based on observed events and may differ from payment-processor truth.

**Expectation:**
- Someone reading results knows what the metric means and what it does *not* mean.

## Quick self-checks (do these before you move to Analyze)

- You can point to one place in the repo and say: “Start here.”
- A new person can answer: “Which table should I use?” in under 30 seconds.
- Your key models and key columns have descriptions.
- You have at least one short “how to interpret” note for the primary metric table.

## Common pitfalls

- Only documenting models that you personally touched, not the ones beginners will read first.
- Writing descriptions that restate the model name (“customer funnel table”) without adding meaning.
- Leaving metric definitions implicit (people will assume the wrong thing).
- Forgetting to document null behavior and flags (e.g., what makes `placed_order` true).

## Suggested Discover loop (repeat)

1. Pick the top 1–2 models a beginner should open first.
2. Add/upgrade the model description.
3. Add/upgrade descriptions for the top columns someone will query.
4. Update README “Start here” so the repo tells the story.