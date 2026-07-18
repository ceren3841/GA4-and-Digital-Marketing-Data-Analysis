WITH active_days as(
select distinct ad_date,adset_name from google_ads_basic_daily where impressions>0
union
select distinct f.ad_date,s.adset_name from facebook_ads_basic_daily f
inner join facebook_adset s on f.adset_id=s.adset_id where f.impressions >0 
),
consecutive_groups as(
select
adset_name,
ad_date,
ad_date-CAST(row_number() over(partition by adset_name order by ad_date) as int ) as group_id
from active_days

)
 select
 adset_name,
 count(*) as number_of_consecutive_days,
 min(ad_date) as start_date,
 max(ad_date) as final_date
 
 from consecutive_groups 
 group by adset_name,group_id
 order by number_of_consecutive_days desc;
