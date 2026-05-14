with source_data as (
select 
    order_id,
    customer_id,
    order_time,
    order_value,
    flowers_amount,
    vase_amount,
    chocolate_amount,
    delivery_id,
    platform
from {{ source('moms_flower_shop', 'raw_flower_orders') }}
)

select 
    order_id,
    customer_id,
    order_time,
    order_value,
    flowers_amount,
    vase_amount,
    chocolate_amount,
    delivery_id,
    platform
from source_data