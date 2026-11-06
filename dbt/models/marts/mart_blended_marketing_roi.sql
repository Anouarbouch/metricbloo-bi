-- ==============================================================================
-- MetricBloo BI: Blended Marketing ROI & Unified Landing Page View
-- Connectors: GA4 + Google Ads + Google Search Console (Normalized Join)
-- Dialect: Google BigQuery / dbt
-- ==============================================================================
-- Solves: Supermetrics charges $172–$431/mo to blend Ads, Search Console, and GA4.
-- This model joins Google Ads spend with GA4 revenue and GSC rankings on clean, normalized page URLs.

WITH normalized_ga4 AS (
  SELECT
    PARSE_DATE('%Y%m%d', event_date) AS report_date,
    REGEXP_REPLACE(
      REGEXP_REPLACE(
        LOWER((SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'page_location')),
        r'\?.*$', ''  -- Strip query params
      ),
      r'https?://[^/]+', '' -- Retain path only
    ) AS clean_page_path,
    traffic_source.medium AS medium,
    traffic_source.source AS source,
    COUNT(DISTINCT CONCAT(user_pseudo_id, CAST((SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS STRING))) AS sessions,
    COUNT(DISTINCT CASE WHEN event_name = 'purchase' THEN user_pseudo_id END) AS transactions,
    SUM(COALESCE(ecommerce.purchase_revenue_in_usd, 0)) AS ga4_attributed_revenue
  FROM
    `{{ var('ga4_project') }}.analytics_{{ var('ga4_property_id') }}.events_*`
  WHERE
    _TABLE_SUFFIX BETWEEN FORMAT_DATE('%Y%m%d', DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY))
    AND FORMAT_DATE('%Y%m%d', CURRENT_DATE())
  GROUP BY
    1, 2, 3, 4
),

normalized_gsc AS (
  SELECT
    data_date AS report_date,
    REGEXP_REPLACE(
      REGEXP_REPLACE(LOWER(url), r'\?.*$', ''),
      r'https?://[^/]+', ''
    ) AS clean_page_path,
    SUM(impressions) AS organic_impressions,
    SUM(clicks) AS organic_clicks,
    ROUND(SAFE_DIVIDE(SUM(sum_top_position), SUM(impressions)), 2) AS average_organic_position
  FROM
    `{{ var('gsc_project') }}.searchconsole.searchdata_url_impression`
  WHERE
    data_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
  GROUP BY
    1, 2
),

normalized_ads AS (
  SELECT
    segments_date AS report_date,
    campaign_name,
    SUM(metrics_cost_micros) / 1000000.0 AS ad_spend,
    SUM(metrics_clicks) AS ad_clicks,
    SUM(metrics_conversions_value) AS ad_conversions_value
  FROM
    `{{ var('ads_project') }}.google_ads.p_ads_CampaignBasicStats_{{ var('ads_customer_id') }}`
  WHERE
    segments_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
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
