with raw_data as (
    select
      index,
      event_id,
      customer_id,
      event_time,
      event_name,
      event_value,
      additional_details,
      platform,
      campaign_id
    from {{ source('moms_flower_shop', 'raw_website_events') }}
),
renamed as (
    select
        -- IDs:
        --index,
        cast(event_id as string) as event_id,
        cast(customer_id as string) as customer_id,
        cast(campaign_id as string) as campaign_id,

        -- Platform:
        cast(platform as string) as platform,
        
        -- Date and Time Situation:
        --event_time,
        timestamp_millis(event_time) as date_time_utc,
        date(timestamp_millis(event_time)) as wse_date_output,
        
        -- Event Details:
        cast(event_name as string) as event_name,
        round(event_value, 2) as event_value,
        --additional_details
        
    from raw_data
)
select * from renamed
