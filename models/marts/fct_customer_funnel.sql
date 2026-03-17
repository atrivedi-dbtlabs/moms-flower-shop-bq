with

events as  (

    select
        customer_id,
        event_name,
        event_time,
        platform
    from {{ ref('stg_mfs__website_events') }}

),

firsts as (

    select
        customer_id,
        min(if(event_name = 'page_hit', event_time, null)) as first_page_hit_time,
        min(if(event_name = 'add_to_cart', event_time, null)) as first_add_to_cart_time,
        min(if(event_name = 'go_to_checkout', event_time, null)) as first_go_to_checkout_time,
        min(if(event_name = 'place_order', event_time, null)) as first_place_order_time

    from events
    group by 1

),

latest_platform as (

    select
        customer_id,
        platform as latest_platform
    from (
    select
        customer_id,
        platform,
        row_number() over (partition by customer_id order by event_time desc) as rn
    from events
    where platform is not null
    )
    where rn = 1

),

platform_at_order as (

    select
        customer_id,
        platform as platform_at_order
    from (
    select
        customer_id,
        platform,
        row_number() over (partition by customer_id order by event_time desc) as rn
    from events
    where event_name = 'place_order' and platform is not null
    )
    where rn = 1

),

final as (

    select
        firsts.customer_id,

        firsts.first_page_hit_time,
        firsts.first_add_to_cart_time,
        firsts.first_go_to_checkout_time,
        firsts.first_place_order_time,

        firsts.first_go_to_checkout_time is not null as reached_checkout,
        firsts.first_place_order_time is not null as placed_order, 

        case
            when firsts.first_place_order_time is null then null
            when coalesce(firsts.first_page_hit_time, firsts.first_add_to_cart_time) is null then null
            else timestamp_diff(
                firsts.first_place_order_time, 
                coalesce(firsts.first_page_hit_time, firsts.first_add_to_cart_time), 
                second
                )
        end as time_to_order_seconds,

        coalesce(platform_at_order.platform_at_order, latest_platform.latest_platform) as platform
    
    from firsts
    left join platform_at_order on firsts.customer_id = platform_at_order.customer_id
    left join latest_platform on firsts.customer_id = latest_platform.customer_id

)

select * from final