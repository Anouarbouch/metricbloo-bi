-- ==============================================================================
-- MetricBloo BI: Blended Website Performance Model (GA4 + Search Console)
-- Dialect: Google BigQuery / dbt
-- ==============================================================================
-- Aggregates GA4 landing-page sessions/transactions strictly at
-- (report_date, clean_page_path) grain before FULL OUTER JOIN with Search Console
-- URL impressions so organic clicks are never multiplied by channel/source splits.
-- Note: Account/campaign Google Ads spend lives at (report_date, campaign_name)
-- grain and should be modeled in a separate daily channel-spend mart or joined
-- using Final URL tracking parameters to prevent spend duplication across pages.

WITH normalized_ga4 AS (
  SELECT
    PARSE_DATE('%Y%m%d', event_date) AS report_date,
    REGEXP_REPLACE(
      REGEXP_REPLACE(
        LOWER((SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'page_location')),
        r'\?.*$', ''
      ),
      r'^https?://[^/]+', ''
    ) AS clean_page_path,
    COUNT(DISTINCT CONCAT(user_pseudo_id, '_', CAST((SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS STRING))) AS sessions,
    COUNT(DISTINCT CASE
      WHEN event_name = 'purchase'
      THEN COALESCE(NULLIF(ecommerce.transaction_id, ''), CONCAT(user_pseudo_id, '_', CAST(event_timestamp AS STRING)))
    END) AS transactions,
    SUM(COALESCE(ecommerce.purchase_revenue_in_usd, 0)) AS ga4_attributed_revenue
  FROM
    `{{ var('ga4_project') }}.analytics_{{ var('ga4_property_id') }}.events_*`
  WHERE
    _TABLE_SUFFIX BETWEEN FORMAT_DATE('%Y%m%d', DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY))
    AND FORMAT_DATE('%Y%m%d', CURRENT_DATE())
  GROUP BY
    1, 2
),

normalized_gsc AS (
  SELECT
    data_date AS report_date,
    REGEXP_REPLACE(
      REGEXP_REPLACE(LOWER(url), r'\?.*$', ''),
      r'^https?://[^/]+', ''
    ) AS clean_page_path,
    SUM(impressions) AS organic_impressions,
    SUM(clicks) AS organic_clicks,
    ROUND(SAFE_DIVIDE(SUM(sum_top_position), NULLIF(SUM(impressions), 0)), 2) AS average_organic_position
  FROM
    `{{ var('gsc_project') }}.searchconsole.searchdata_url_impression`
  WHERE
    data_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
  GROUP BY
    1, 2
)

SELECT
  COALESCE(ga4.report_date, gsc.report_date) AS date,
  COALESCE(ga4.clean_page_path, gsc.clean_page_path) AS landing_page,
  COALESCE(ga4.sessions, 0) AS total_sessions,
  COALESCE(gsc.organic_clicks, 0) AS organic_search_clicks,
  COALESCE(gsc.organic_impressions, 0) AS organic_search_impressions,
  COALESCE(gsc.average_organic_position, 0) AS avg_search_rank,
  COALESCE(ga4.transactions, 0) AS transactions,
  ROUND(COALESCE(ga4.ga4_attributed_revenue, 0), 2) AS revenue,
  ROUND(SAFE_DIVIDE(COALESCE(ga4.ga4_attributed_revenue, 0), NULLIF(COALESCE(ga4.sessions, 0), 0)), 2) AS revenue_per_session
FROM
  normalized_ga4 ga4
FULL OUTER JOIN
  normalized_gsc gsc
ON
  ga4.report_date = gsc.report_date
  AND ga4.clean_page_path = gsc.clean_page_path
ORDER BY
  date DESC, revenue DESC;
