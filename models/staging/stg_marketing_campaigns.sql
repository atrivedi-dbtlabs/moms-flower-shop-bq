{{ config(materialized='view') }}

SELECT 
    campaign_id,
    campaign_name,
    SUBSTR(c_name, 1, LENGTH(c_name)-1) AS campaign_type,
    MIN(
        TIMESTAMP_SECONDS(CAST(event_time/1000 AS INT64)) -- convert unixtime from milliseconds to seconds
    ) AS start_time,
    MAX(
        TIMESTAMP_SECONDS(CAST(event_time/1000 AS INT64)) -- convert unixtime from milliseconds to seconds
    ) AS end_time,
    COUNT(event_time) AS campaign_duration,
    SUM(cost) AS total_campaign_spent,
    ARRAY_AGG(event_id) AS event_ids
FROM {{ source('moms_flower_shop', 'raw_marketing_campaign_events') }}
GROUP BY 
    campaign_id,
    campaign_name,
    campaign_type
