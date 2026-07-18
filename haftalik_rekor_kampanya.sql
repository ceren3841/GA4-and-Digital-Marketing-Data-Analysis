with weekly_data AS(
select 
date_trunc('week',ad_date) as campaign_week,
campaign_name,
value
from google_ads_basic_daily gabd 

union all

select
date_trunc('week',f.ad_date) as campaign_week,
c.campaign_name,
f.value
from facebook_ads_basic_daily f
inner join facebook_campaign c on f.campaign_id=c.campaign_id 
)

select 
campaign_week::date as rekor_hafta,
campaign_name,
round(sum(value)::numeric,2) as total_value
from weekly_data
group by 1,2
order by total_value desc
limit 1;
