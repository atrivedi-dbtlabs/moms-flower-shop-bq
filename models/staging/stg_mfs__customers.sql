with raw_data as (
    select
      id as customer_id,
      first_name,
      last_name,  -- IGNORE for PII concerns
      email,  -- IGNORE for PII concerns
      gender,
      address_id -- IGNORE for PII concerns
    from {{ source('moms_flower_shop', 'raw_customers') }}
),
renamed as (
select
  customer_id,
  -- Obfuscation of Name for PII concerns, while retaining some identifiable structure
  cast(
    concat(
      upper(left(last_name,1)), 
      repeat('*', cast(floor(3 + rand()*5) as int)), -- Dynamic masking length for better obfuscation
      lower(right(first_name,1))) 
    as string) as masked_name,  -- Masking for PII concerns
  cast(gender as string) as gender
from raw_data
)
select * from renamed