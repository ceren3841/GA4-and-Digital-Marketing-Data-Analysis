WITH session_landing_pages AS(
SELECT
CONCAT(user_pseudo_id,
'-',
COALESCE(CAST((SELECT value.int_value FROM UNNEST(event_params) WHERE key='ga_session_id') AS STRING), '')
) AS unique_session_id,
(SELECT value.string_value FROM UNNEST(event_params) WHERE key='page_location') AS landing_page_url
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20200101' AND '20201231'
  AND event_name = 'session_start'
),
session_purchases AS (
SELECT DISTINCT
CONCAT(user_pseudo_id, '-', COALESCE(CAST((SELECT value.int_value FROM UNNEST(event_params) WHERE key='ga_session_id') AS STRING), '')) AS unique_session_id,
 1 AS is_purchase
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20200101' AND '20201231'
  AND event_name = 'purchase'
),
joined_data AS(
SELECT
REGEXP_EXTRACT(lp.landing_page_url, r'https?://[^/]+(/[^?#]*)') AS page_path,
lp.unique_session_id,
COALESCE(p.is_purchase, 0) AS purchase_count
FROM session_landing_pages lp
LEFT JOIN session_purchases p ON lp.unique_session_id = p.unique_session_id
)
 
SELECT
COALESCE(page_path,'/') AS page_path,
COUNT(DISTINCT unique_session_id) AS unique_user_session_count,
SUM(purchase_count) AS purchase_count,

CASE
WHEN COUNT(DISTINCT unique_session_id) > 0 THEN SUM(purchase_count) / COUNT(DISTINCT unique_session_id)
ELSE 0 
END AS purchase_conversion_rate

FROM joined_data
GROUP BY page_path
ORDER BY unique_user_session_count DESC;





