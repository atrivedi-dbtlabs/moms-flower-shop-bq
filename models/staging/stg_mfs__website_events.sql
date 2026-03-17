with

source as (

    select * from {{ source('moms_flower_shop','raw_website_events') }}

),

renamed as (

    select
        -- ids
        cast(event_id as string) as event_id,
        cast(customer_id as string) as customer_id,
        cast(campaign_id as string) as campaign_id,

        -- strings
        cast(event_name as string) as event_name,
        cast(additional_details as string) as additional_details,
        cast(platform as string) as platform,

        -- numerics
        event_value as total_value,

        -- timestamps
        timestamp_millis(cast(event_time as int64)) as event_time,

        -- dates
        date(timestamp_millis(cast(event_time as int64))) as event_date

    from source

)

select * from renamed