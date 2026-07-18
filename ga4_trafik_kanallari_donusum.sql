WITH session_base AS(
SELECT 
EXTRACT(DATE FROM TIMESTAMP_MICROS(event_timestamp)) AS event_date,
CONCAT(
  user_pseudo_id,
  '-',
  COALESCE(CAST((SELECT value.int_value FROM UNNEST(event_params) WHERE key='ga_session_id') AS STRING), '')
) AS unique_session_id,

traffic_source.source AS source,
traffic_source.medium AS medium,
traffic_source.name AS campaign,

MAX(IF(event_name='session_start',1,0)) OVER(PARTITION BY user_pseudo_id,(SELECT value.int_value FROM UNNEST(event_params) WHERE key='ga_session_id')) AS has_session_start,

IF(event_name = 'add_to_cart', 1, 0) AS is_cart,
IF(event_name = 'begin_checkout', 1, 0) AS is_checkout,
IF(event_name = 'purchase', 1, 0) AS is_purchase
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20210101' AND '20211231'
)
SELECT 
event_date,
COALESCE(source,'(direct)') AS source,
COALESCE(medium,'(none)') AS medium,
COALESCE(campaign,'(none)') AS campaign,

COUNT(DISTINCT unique_session_id) AS user_sessions_count,

CASE 
WHEN COUNT(DISTINCT unique_session_id)>0 THEN COUNT(DISTINCT IF(is_cart=1,unique_session_id,NULL))/COUNT(DISTINCT unique_session_id)
ELSE 0
END AS visit_to_cart,

CASE 
WHEN COUNT(DISTINCT unique_session_id)>0 THEN COUNT(DISTINCT IF(is_checkout=1,unique_session_id,NULL))/COUNT(DISTINCT unique_session_id)
ELSE 0
END AS visit_to_checkout,

CASE 
WHEN COUNT(DISTINCT unique_session_id)>0 THEN COUNT(DISTINCT IF(is_purchase=1,unique_session_id,NULL))/COUNT(DISTINCT unique_session_id)
ELSE 0
END AS visit_to_purchase,
FROM session_base
WHERE has_session_start = 1
GROUP BY event_date, source, medium, campaign
ORDER BY event_date DESC, user_sessions_count DESC; 




