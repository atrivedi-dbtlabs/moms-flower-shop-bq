# Analyze checkpoint

**Goal of this stage:** use the trusted models to produce insights, then turn those insights into the *next* Plan (the next ADLC loop).

---

## Loop back: the original Plan questions (v1)

**Main question:**  
For each customer funnel, how long does it take to get from first interaction to ordering, and how does success versus abandonment differ by platform?

**In v1, we will answer exactly two questions:**

1. **Time-to-order (successful orders only)**  
	For customers who successfully place an order, how long is it from their **first website event** to **place order**, and does that differ by **platform**?

2. **Conversion vs abandonment (checkout-reached funnels)**  
	Of all funnels that **reach checkout**, what share **convert vs abandon**, by platform?

---

## What you should have by the end of Analyze

You will have:

1. A **headline comparison** by platform (conversion + time-to-order)
2. **2–3 plain-English insight statements** (not just numbers)
3. A **drill-down validation** using the customer-level fact table (spot checks + distributions)
4. Clear **answers to Q1 and Q2** written explicitly
5. A concrete **next Plan** for the next loop (new question + small modeling/data change)

---

## Working rules for this stage

- Start with the **mart** table for the headline, then validate with the **fact** table.
- Write insights as **statements**: “X is true, and we think it might be because Y.”
- Prefer **small numbers of high-confidence insights** over many speculative ones.
- Check **null behavior, outliers, and sample rows** before concluding.
- Every insight must produce a **next-loop Plan item** (question → build).

---

## Required inputs

You will need:

- A successful build (or at least the funnel subset)
- Access to the warehouse where models are built
- The two key models available:
	- `mart_platform_funnel_metrics` (headline)
	- `fct_customer_funnel` (drill-down / validation)

---

## Analyze requirements (minimum)

### 1) Start with the headline table (the “what changed?” layer)

**Goal:** compare platforms quickly and identify the biggest gaps.

**Primary table:** `mart_platform_funnel_metrics`  
**Grain:** one row per platform

**Query scaffold:**

```
select 
    *
from <production_dataset>.mart_platform_funnel_metrics
order by conversion_rate desc;
```

**Complete the following:**
- **Highest conversion platform:** `<platform>` at `<conversion_rate>`
- **Lowest conversion platform:** `<platform>` at `<conversion_rate>`
- **Fastest time-to-order (successful only):** `<platform>` at `<avg_time_to_order_seconds>`
- **Slowest time-to-order (successful only):** `<platform>` at `<avg_time_to_order_seconds>`
- **Largest volume (reached checkout):** `<platform>` with `<customers_reached_checkout>`

**Quick self-checks:**
- Are there platforms with tiny volume that could mislead averages?
- Do any metrics look impossible (e.g., conversion > 1, negative durations)?

---

### 2) Turn metrics into 2–3 insight statements (the “so what?” layer)

**Goal:** translate the headline metrics into plain-English insights a teammate can act on.

**Insight writing rules:**
- Not a number: an insight is a **claim**.
- It should include a **candidate explanation** (even if uncertain).
- It should point to a **validation** step.

**Complete the following:**

- **Insight 1 (conversion):**  
	`<platform>` has **lower conversion** among checkout-reached funnels than `<platform>`.  
	This suggests `<possible friction / drop-off / measurement gap>`.

- **Insight 2 (speed):**  
	Among successful orders, `<platform>` has **higher time-to-order** than `<platform>`.  
	This suggests the funnel is slower on `<platform>`, not just less successful.

- **Insight 3 (impact):**  
	`<platform>` has **high reach-to-checkout volume** but **low completion**, making it the highest-impact place to improve.

**What to capture for each insight:**
- **What is true (one sentence):** `<...>`
- **Why we think it might be true (one sentence):** `<...>`
- **What we’ll check next (one sentence):** `<...>`

---

### 3) Validate with drill-down (customer-level fact)

**Goal:** confirm the headline gap is real, understand its shape, and rule out obvious data issues.

**Primary table:** `fct_customer_funnel`  
**Grain:** one row per customer (or per customer funnel, depending on project)

#### 3A) Validate time-to-order distribution (successful orders only)

**Query scaffold:**

```
select
  platform,
  time_to_order_seconds
from <production_dataset>.fct_customer_funnel
where placed_order = true
and time_to_order_seconds is not null;
```

**What to check:**
- Is the average driven by a few extreme outliers?
- Do medians tell a different story than averages?
- Are there suspicious spikes (e.g., many values at exactly the same number)?

**Notes (fill in):**
- **Outlier handling decision (if any):** `<none / cap at X / filter obvious bad rows>`
- **Distribution looks:** `<normal-ish / heavy tail / bimodal / suspicious>`

#### 3B) Validate checkout → outcome (convert vs abandon)

**Query scaffold:**

```
select
  *
from <production_dataset>.fct_customer_funnel
where reached_checkout = true and placed_order = false;
```

**What to check:**
- Are “abandoned” funnels truly abandoned, or missing later events?
- Is drop-off happening *before* checkout or *after* checkout?
- Do you see missing or inconsistent event sequences by platform?

**Spot-check scaffold (fill in):**
- Sample 10 customers who reached checkout but did not place an order on `<platform>` and inspect their event sequences.
- What patterns show up?
	- `<pattern 1>`
	- `<pattern 2>`
	- `<pattern 3>`

---

### 4) Answer the original two questions explicitly

**Goal:** write the direct answers that the project set out to produce.

#### Q1: Time-to-order by platform (successful orders)
**Answer (fill in):**  
For customers who place an order, time from first website event to `place_order` **does / does not** differ by platform.  
The gap between `<platform A>` and `<platform B>` is `<X>` seconds.

**Evidence you’re relying on:**
- `mart_platform_funnel_metrics.avg_time_to_order_seconds`
- Drill-down distribution from `fct_customer_funnel` for `placed_order = true`

#### Q2: Conversion vs abandonment among checkout-reached funnels
**Answer (fill in):**  
Among funnels that reach checkout, `<platform>` converts at a `<higher/lower>` rate than `<platform>`.  
The biggest opportunity is improving checkout completion on `<platform>` because `<reason>`.

**Evidence you’re relying on:**
- `mart_platform_funnel_metrics.conversion_rate`
- Spot-checks / validation from `fct_customer_funnel` where `reached_checkout = true`

---

### 5) Connect Analyze back to the next Plan (the next ADLC loop)

**Goal:** every insight becomes a next-loop Plan item.

**Rule:** The next Plan is not “build more models.” It is: pick the most actionable gap, define exactly what to measure next, then repeat.

#### Next loop — Plan item A
- **Insight that triggered this:** `<Insight 1/2/3>`
- **New question:** `<precise question>`
- **What we’ll build next:** `<small model / metric / segmentation>`
- **Why this is the smallest next step:** `<one sentence>`
- **How we’ll know it worked:** `<what output should change or become clearer>`

#### Next loop — Plan item B
- **Insight that triggered this:** `<...>`
- **New question:** `<...>`
- **What we’ll build next:** `<...>`
- **How we’ll know it worked:** `<...>`

#### Next loop — Plan item C
- **Insight that triggered this:** `<...>`
- **New question:** `<...>`
- **What we’ll build next:** `<...>`

**Common next-loop directions:**
- Diagnose *where* `<platform>` drops: step-level funnel counts and step-to-step conversion rates
- Add time between funnel steps:
	- `time_page_to_cart_seconds`
	- `time_cart_to_checkout_seconds`
	- `time_checkout_to_order_seconds`
- Segment by campaign/source
- Segment by geographical location

---

## Quick self-checks (do these before you move on)

- You can answer the questions from the Plan in two sentences each.
- Your insights are written as claims, not just numbers.
- You validated at least one gap using `fct_customer_funnel`.
- You produced at least one next-loop Plan item with:
	- a new question
	- a small build

---

## Common pitfalls

- Writing “insights” that restate metrics without explaining meaning.
- Trusting averages without checking distributions or outliers.
- Mixing populations (e.g., using all customers for time-to-order instead of successful orders only).
- Treating “no order observed” as “abandoned” without checking event collection gaps.
- Ending Analyze without producing a concrete next Plan.
