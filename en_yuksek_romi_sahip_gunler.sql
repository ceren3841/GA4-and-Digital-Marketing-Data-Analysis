with combined_data AS(
select 
ad_date,
spend,
value 
from google_ads_basic_daily

union all

select 
ad_date,
spend,
value 
from facebook_ads_basic_daily
),

daily_summary as (
select 
ad_date,
SUM(spend) as total_spend,
SUM(value) as total_value
from combined_data
group by ad_date
)

select
ad_date,
ROUND(total_spend::numeric,2) as total_spend,
ROUND(total_value::numeric,2) as total_value,
Round(((Total_value-total_spend)*100.0/NULLIF(total_spend,0))::numeric,2) as ROMI
from
daily_summary
where
total_spend>0
order by 
ROMI desc
LIMIT 5;
