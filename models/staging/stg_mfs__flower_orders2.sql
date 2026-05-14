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
    from {{ source('moms_flower_shop', 'raw_flower_orders2') }}
),
renamed as (
    select
        -- IDs:
        cast(order_id as string) as order_id,
        cast(customer_id as string) as customer_id,
        cast(delivery_id as string) as delivery_id,

        -- Date and Time Situation:
        --order_time,
        timestamp_millis(cast(order_time as int64)) as order_date_time_utc,
        date(timestamp_millis(cast(order_time as int64))) as order_date,
        
        -- Amounts and Values:
        cast(chocolate_amount as float64) as chocolate_subtotal,
        cast(flowers_amount as float64) as flowers_subtotal,
        cast(vase_amount as float64) as vase_subtotal,
        cast(round(cast(order_value as float64), 2) as float64) as total_order_value,
        
        -- Platform:
        cast(platform as string) as platform
    from source_data
)

select * from renamed