with hits as (
    select * from {{ ref('stg_website_hits') }}
),

campaigns as (
    select 
        campaign_type,
        count(distinct order_id) as hits
    from hits
    group by 1
)

select * from campaigns