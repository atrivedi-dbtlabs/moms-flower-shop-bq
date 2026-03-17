with funnel as (

    select
        platform,
        reached_checkout,
        placed_order,
        time_to_order_seconds
    from {{ ref('fct_customer_funnel') }}

),

final as (
    select
        coalesce(platform, 'unknown') as platform,

        countif(reached_checkout) as customers_reached_checkout,
        countif(placed_order) as customers_placed_order,

        safe_divide(
            countif(placed_order),
            nullif(countif(reached_checkout), 0)
        ) as conversion_rate,

        avg(if(
            placed_order, 
            time_to_order_seconds, 
            null
            )) as avg_time_to_order_seconds

    from funnel
    group by 1
)

select * from final
order by platform