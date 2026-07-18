with all_ads AS(
select
ad_date,
spend,
impressions,
reach,
value,
campaign_name,
'Google' as media_source
from google_ads_basic_daily

union all

select
fabd.ad_date,
fabd.spend,
fabd.impressions,
fabd.reach,
fabd.value,
fc.campaign_name,
'Facebook' AS media_source
FROM facebook_ads_basic_daily fabd
left join facebook_adset fa ON fabd.adset_id = fa.adset_id
left join facebook_campaign fc ON fabd.campaign_id = fc.campaign_id
)

select
ad_date,
media_source,
round(avg(spend)) as avg_spend,
round(max(spend)) as max_spend,
round(min(spend)) as min_spend
from all_ads
group by ad_date,media_source
order by ad_date;
