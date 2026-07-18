with monthly_reach as(
select 
date_trunc('month',ad_date)::date as ad_month,
campaign_name,
sum(reach) as total_reach
from(
select 
ad_date,campaign_name,reach from google_ads_basic_daily 
union all
select 
f.ad_date,c.campaign_name,f.reach
from facebook_ads_basic_daily f
inner join facebook_campaign c on f.campaign_id=c.campaign_id
) combined
group by 1,2
),

reach_with_lag as(

select 
ad_month,
campaign_name,
total_reach,
LAG(total_reach) over (partition by campaign_name order by ad_month) as previous_month_reach
from
monthly_reach
)

select 
ad_month as final_analysis_month,
campaign_name,
total_reach as current_month_reach,
coalesce(previous_month_reach,0) as last_month_reach,
(total_reach-coalesce(previous_month_reach,0)) as reach_increase
from reach_with_lag
where previous_month_reach is not null
order by reach_increase desc
limit 1;
