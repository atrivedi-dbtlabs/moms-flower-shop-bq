with source_data as (
    select
        event_id,
        event_time,
        campaign_id,
        campaign_name,
        c_name,
        priority,
        cost
    from {{ source('moms_flower_shop', 'raw_marketing_campaign_events') }}
),

renamed as (
    select
        -- IDs:
        cast(event_id as string) as event_id,
        cast(campaign_id as string) as campaign_id,

        -- Date and Time Situation:
        --event_time,
        timestamp_millis(cast(event_time as int64)) as date_time_utc,
        date(timestamp_millis(cast(event_time as int64))) as mc_date_output,
        
        -- Campaign Details:
        cast(campaign_name as string) as detailed_campaign_name,
        cast(c_name as string) as campaign_name,
        cast(priority as string) as priority,
        cast(round(cost, 2) as float64) as cost
    from source_data
)

select * from renamed