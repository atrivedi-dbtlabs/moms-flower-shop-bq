{{ config(severity = 'warn') }}

select *
from {{ ref('fct_customer_funnel') }}
where placed_order and time_to_order_seconds < 0