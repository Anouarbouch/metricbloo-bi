-- ==============================================================================
-- MetricBloo BI: AI & LLM Referral Traffic Attribution Model
-- Dialect: Google BigQuery / dbt (GA4 Export)
-- License: MIT (Free Lead Magnet Asset)
-- ==============================================================================
-- Isolates AI referrals at session grain first (no self-join fan-out),
-- then aggregates daily sessions, unique users, and engaged session rate.

WITH raw_events AS (
  SELECT
    PARSE_DATE('%Y%m%d', event_date) AS event_date,
    user_pseudo_id,
    (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS session_id,
    COALESCE(
      NULLIF(collected_traffic_source.manual_source, ''),
      NULLIF(traffic_source.source, ''),
      ''
    ) AS raw_source,
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'page_referrer') AS page_referrer,
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'page_location') AS page_location,
    COALESCE(
      SAFE_CAST((SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'session_engaged') AS INT64),
      SAFE_CAST((SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'session_engaged') AS INT64),
      0
    ) AS is_engaged
  FROM
    `{{ var('ga4_project') }}.analytics_{{ var('ga4_property_id') }}.events_*`
  WHERE
    _TABLE_SUFFIX BETWEEN FORMAT_DATE('%Y%m%d', DATE_SUB(CURRENT_DATE(), INTERVAL 90 DAY))
    AND FORMAT_DATE('%Y%m%d', CURRENT_DATE())
),

session_grain AS (
  SELECT
    MIN(event_date) AS report_date,
    user_pseudo_id,
    CONCAT(user_pseudo_id, '_', CAST(session_id AS STRING)) AS session_key,
    ARRAY_AGG(page_location IGNORE NULLS ORDER BY event_date LIMIT 1)[SAFE_OFFSET(0)] AS landing_page,
    MAX(is_engaged) AS is_engaged,
    LOWER(
      COALESCE(
        ARRAY_AGG(NULLIF(page_referrer, '') IGNORE NULLS LIMIT 1)[SAFE_OFFSET(0)],
        ARRAY_AGG(NULLIF(raw_source, '') IGNORE NULLS LIMIT 1)[SAFE_OFFSET(0)],
        ''
      )
    ) AS attribution_signal
  FROM
    raw_events
  WHERE
    session_id IS NOT NULL
  GROUP BY
    user_pseudo_id, session_key
),

categorized_sessions AS (
  SELECT
    report_date,
    user_pseudo_id,
    session_key,
    landing_page,
    is_engaged,
    CASE
      WHEN REGEXP_CONTAINS(attribution_signal, r'(chatgpt|openai\.com|chat\.openai)') THEN 'OpenAI / ChatGPT'
      WHEN REGEXP_CONTAINS(attribution_signal, r'(claude\.ai|anthropic)') THEN 'Anthropic Claude'
      WHEN REGEXP_CONTAINS(attribution_signal, r'perplexity\.ai') THEN 'Perplexity AI'
      WHEN REGEXP_CONTAINS(attribution_signal, r'(gemini\.google\.com|bard\.google)') THEN 'Google Gemini'
      WHEN REGEXP_CONTAINS(attribution_signal, r'(copilot\.microsoft\.com|bing\.com/chat)') THEN 'Microsoft Copilot'
      WHEN REGEXP_CONTAINS(attribution_signal, r'(grok\.x\.ai|x\.ai)') THEN 'xAI Grok'
      ELSE 'Other / Non-AI'
    END AS ai_referrer_platform
  FROM
    session_grain
)

SELECT
  report_date,
  ai_referrer_platform,
  landing_page,
  COUNT(DISTINCT session_key) AS total_sessions,
  COUNT(DISTINCT user_pseudo_id) AS total_users,
  COUNT(DISTINCT CASE WHEN is_engaged = 1 THEN session_key END) AS engaged_sessions,
  ROUND(
    SAFE_DIVIDE(
      COUNT(DISTINCT CASE WHEN is_engaged = 1 THEN session_key END),
      COUNT(DISTINCT session_key)
    ) * 100,
    2
  ) AS engagement_rate_pct
FROM
  categorized_sessions
WHERE
  ai_referrer_platform != 'Other / Non-AI'
GROUP BY
  1, 2, 3
ORDER BY
  report_date DESC, total_sessions DESC;
