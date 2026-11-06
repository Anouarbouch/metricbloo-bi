-- ==============================================================================
-- MetricBloo BI: GA4 E-Commerce Funnel & Step Drop-Off Model
-- Dialect: Google BigQuery / dbt
-- Target: Zero-API Quota Extraction & Fast Aggregation View
-- ==============================================================================
-- Solves: GA4 UI funnel charts time out under high traffic or hit token quota errors.
-- This model flattens the standard 5-step e-commerce journey into a single daily aggregation:
-- Step 1: view_item
-- Step 2: add_to_cart
-- Step 3: begin_checkout
-- Step 4: add_shipping_info / add_payment_info
-- Step 5: purchase

WITH raw_events AS (
  SELECT
    PARSE_DATE('%Y%m%d', event_date) AS event_date,
    user_pseudo_id,
    (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS session_id,
    event_name,
    traffic_source.source AS session_source,
    traffic_source.medium AS session_medium,
    device.category AS device_category,
    geo.country AS country,
    ecommerce.purchase_revenue_in_usd AS purchase_revenue
  FROM
    `{{ var('ga4_project') }}.analytics_{{ var('ga4_property_id') }}.events_*`
  WHERE
    event_name IN (
      'view_item', 'add_to_cart', 'begin_checkout', 
      'add_shipping_info', 'add_payment_info', 'purchase'
    )
    AND _TABLE_SUFFIX BETWEEN FORMAT_DATE('%Y%m%d', DATE_SUB(CURRENT_DATE(), INTERVAL 60 DAY))
    AND FORMAT_DATE('%Y%m%d', CURRENT_DATE())
),

session_funnel_flags AS (
  SELECT
    event_date,
    device_category,
    country,
    session_source,
    session_medium,
    CONCAT(user_pseudo_id, CAST(session_id AS STRING)) AS session_key,
    MAX(CASE WHEN event_name = 'view_item' THEN 1 ELSE 0 END) AS has_view_item,
    MAX(CASE WHEN event_name = 'add_to_cart' THEN 1 ELSE 0 END) AS has_add_to_cart,
    MAX(CASE WHEN event_name = 'begin_checkout' THEN 1 ELSE 0 END) AS has_begin_checkout,
    MAX(CASE WHEN event_name = 'add_payment_info' THEN 1 ELSE 0 END) AS has_payment_info,
    MAX(CASE WHEN event_name = 'purchase' THEN 1 ELSE 0 END) AS has_purchase,
    SUM(COALESCE(purchase_revenue, 0)) AS total_revenue
  FROM
    raw_events
  GROUP BY
    1, 2, 3, 4, 5, 6
)

SELECT
  event_date,
  device_category,
  country,
  session_source,
  session_medium,
  COUNT(DISTINCT session_key) AS sessions_with_ecommerce_intent,
  SUM(has_view_item) AS step_1_view_item_sessions,
  SUM(has_add_to_cart) AS step_2_add_to_cart_sessions,
  SUM(has_begin_checkout) AS step_3_begin_checkout_sessions,
  SUM(has_payment_info) AS step_4_payment_info_sessions,
  SUM(has_purchase) AS step_5_purchase_sessions,
  ROUND(SUM(total_revenue), 2) AS total_purchase_revenue,
  
  -- Calculated conversion drop-offs
  ROUND(SAFE_DIVIDE(SUM(has_add_to_cart), SUM(has_view_item)) * 100, 2) AS cart_add_rate_pct,
  ROUND(SAFE_DIVIDE(SUM(has_begin_checkout), SUM(has_add_to_cart)) * 100, 2) AS checkout_start_rate_pct,
  ROUND(SAFE_DIVIDE(SUM(has_purchase), SUM(has_begin_checkout)) * 100, 2) AS checkout_completion_rate_pct,
  ROUND(SAFE_DIVIDE(SUM(has_purchase), SUM(has_view_item)) * 100, 2) AS overall_funnel_conversion_pct
FROM
  session_funnel_flags
GROUP BY
  1, 2, 3, 4, 5
ORDER BY
  event_date DESC;
