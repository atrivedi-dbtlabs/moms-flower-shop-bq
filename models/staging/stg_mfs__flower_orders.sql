with

source as (

    select * from {{ source('moms_flower_shop','raw_flower_orders') }}

),

renamed as (

    select
        -- ids
        cast(order_id as string) as order_id,
        cast(customer_id as string) as customer_id,
        cast(delivery_id as string) as delivery_id,

        -- strings
        cast(platform as string) as platform,

        -- numerics
        order_value as total_value,
        flowers_amount as flowers_subtotal,
        vase_amount as vase_subtotal,
        chocolate_amount as chocolate_subtotal,

        -- timestamps
        timestamp_millis(cast(order_time as int64)) as order_time,

        -- dates
        date(timestamp_millis(cast(order_time as int64))) as order_date

    from source

)

select * from renamed