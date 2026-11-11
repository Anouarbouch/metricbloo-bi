# MetricBloo BI: Distribution Notes & Corrections

> **REDDIT PERMANENTLY DISABLED:** Do NOT post AI-generated marketing copy or promotional GitHub links to Reddit (`r/dataengineering` banned `u/Spite_Famous` under Rule #9). Never automate social media posts without manual review.

---

## Verified Reference SQL (5-Step E-Commerce Funnel, Session-Keyed)

```sql
WITH raw_events AS (
  SELECT
    PARSE_DATE('%Y%m%d', event_date) AS event_date,
    user_pseudo_id,
    (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS session_id,
    event_name,
    traffic_source.source AS session_source,
    device.category AS device_category,
    ecommerce.purchase_revenue_in_usd AS purchase_revenue
  FROM
    `your-project.analytics_123456789.events_*`
  WHERE
    event_name IN ('view_item', 'add_to_cart', 'begin_checkout', 'add_payment_info', 'purchase')
    AND _TABLE_SUFFIX >= FORMAT_DATE('%Y%m%d', DATE_SUB(CURRENT_DATE(), INTERVAL 60 DAY))
)
SELECT
  event_date,
  device_category,
  session_source,
  COUNT(DISTINCT CONCAT(user_pseudo_id, '_', CAST(session_id AS STRING))) AS sessions,
  COUNT(DISTINCT CASE WHEN event_name = 'view_item' THEN CONCAT(user_pseudo_id, '_', CAST(session_id AS STRING)) END) AS step_1_view_item,
  COUNT(DISTINCT CASE WHEN event_name = 'add_to_cart' THEN CONCAT(user_pseudo_id, '_', CAST(session_id AS STRING)) END) AS step_2_cart_add,
  COUNT(DISTINCT CASE WHEN event_name = 'begin_checkout' THEN CONCAT(user_pseudo_id, '_', CAST(session_id AS STRING)) END) AS step_3_checkout,
  COUNT(DISTINCT CASE WHEN event_name = 'add_payment_info' THEN CONCAT(user_pseudo_id, '_', CAST(session_id AS STRING)) END) AS step_4_payment_info,
  COUNT(DISTINCT CASE WHEN event_name = 'purchase' THEN CONCAT(user_pseudo_id, '_', CAST(session_id AS STRING)) END) AS step_5_purchases,
  ROUND(SUM(COALESCE(purchase_revenue, 0)), 2) AS total_revenue
FROM raw_events
WHERE session_id IS NOT NULL
GROUP BY 1, 2, 3
ORDER BY event_date DESC;
```

## Canonical Links
- Repository: https://github.com/Anouarbouch/metricbloo-bi
- Documentation & SQL Playground: https://anouarbouch.github.io/metricbloo-bi/
