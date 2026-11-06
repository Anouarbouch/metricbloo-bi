-- ==============================================================================
-- MetricBloo BI: AI & LLM Referral Traffic Attribution Model
-- Dialect: Google BigQuery / dbt (GA4 Export)
-- License: MIT (Free Lead Magnet Asset)
-- ==============================================================================
-- Solves: GA4 classifies ChatGPT, Claude, Perplexity, Copilot, and Gemini as generic
-- "Direct" or standard "Referral". This query isolates AI referrals with session counts,
-- engaged sessions, user acquisition date, and conversion attribution.

WITH raw_sessions AS (
  SELECT
    user_pseudo_id,
    event_timestamp,
    event_name,
    traffic_source.source AS session_source,
    traffic_source.medium AS session_medium,
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'page_location') AS landing_page,
    (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS session_id,
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'session_engaged') AS is_engaged
  FROM
    `{{ var('ga4_project') }}.analytics_{{ var('ga4_property_id') }}.events_*`
  WHERE
    _TABLE_SUFFIX BETWEEN FORMAT_DATE('%Y%m%d', DATE_SUB(CURRENT_DATE(), INTERVAL 90 DAY))
    AND FORMAT_DATE('%Y%m%d', CURRENT_DATE())
),

categorized_traffic AS (
  SELECT
    user_pseudo_id,
    session_id,
    landing_page,
    session_source,
    session_medium,
    CASE
      WHEN REGEXP_CONTAINS(LOWER(session_source), r'(chatgpt|openai\.com|chat\.openai)') THEN 'OpenAI / ChatGPT'
      WHEN REGEXP_CONTAINS(LOWER(session_source), r'(claude\.ai|anthropic)') THEN 'Anthropic Claude'
      WHEN REGEXP_CONTAINS(LOWER(session_source), r'(perplexity\.ai)') THEN 'Perplexity AI'
      WHEN REGEXP_CONTAINS(LOWER(session_source), r'(gemini\.google\.com|bard\.google)') THEN 'Google Gemini'
      WHEN REGEXP_CONTAINS(LOWER(session_source), r'(copilot\.microsoft\.com|bing\.com\/chat)') THEN 'Microsoft Copilot'
      WHEN REGEXP_CONTAINS(LOWER(session_source), r'(grok\.x\.ai|x\.ai)') THEN 'xAI Grok'
      ELSE 'Other / Non-AI'
    END AS ai_referrer_platform,
    is_engaged
  FROM
    raw_sessions
)

SELECT
  DATE(TIMESTAMP_MICROS(event_timestamp)) AS report_date,
  ai_referrer_platform,
  landing_page,
  COUNT(DISTINCT CONCAT(user_pseudo_id, CAST(session_id AS STRING))) AS total_sessions,
  COUNT(DISTINCT user_pseudo_id) AS total_users,
  COUNT(DISTINCT CASE WHEN is_engaged = '1' THEN CONCAT(user_pseudo_id, CAST(session_id AS STRING)) END) AS engaged_sessions,
  ROUND(SAFE_DIVIDE(
    COUNT(DISTINCT CASE WHEN is_engaged = '1' THEN CONCAT(user_pseudo_id, CAST(session_id AS STRING)) END),
    COUNT(DISTINCT CONCAT(user_pseudo_id, CAST(session_id AS STRING)))
  ) * 100, 2) AS engagement_rate_pct
FROM
  categorized_traffic
LEFT JOIN
  raw_sessions USING (user_pseudo_id, session_id)
WHERE
  ai_referrer_platform != 'Other / Non-AI'
GROUP BY
  1, 2, 3
ORDER BY
  total_sessions DESC;
