# Plan
Please note that there's a missing table, addresses, which might have a big impact on the plan downstream.

## Question
How long does it take to get from first interaction to ordering?
How does sucess versus abandonment differ by platform?
Conversion rate by platform?

## Inputs
Usage of minimum raw data sources to answer questions

### Required
- 'raw_website_events'
- 'raw_flower_orders'

### Optional (v2)
- 'raw_customers'
- 'raw_marketing_campaign_events'	

### 1) fct_customer_funnel
grain: one row per customer

### 2) agg_platform_funnel_metrics
grain: one row per platform

## Acceptance Criteria:
- time stamps are converted
- platforms should show different conversion rates
- dbt build command passes for the models created
