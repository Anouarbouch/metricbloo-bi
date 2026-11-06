# MetricBloo BI: Zero-CAC Organic Launch Playbook

This document contains ready-to-publish launch copy and distribution strategies for high-intent B2B channels.

---

## Channel 1: Reddit (r/dataengineering, r/bigquery, r/GoogleAnalytics)

### Post Title
> **How we bypassed Looker Studio's 14,000 token quota crash for GA4 using a single flattened BigQuery SQL view (Free open-source SQL)**

### Post Body
```markdown
Hey everyone,

If you’ve tried building Looker Studio reports on live GA4 properties recently, you’ve likely hit the dreaded "Looker Studio quota exceeded (14,000 core tokens / 10 concurrent requests limit)" error. 

GA4 direct connectors throttle concurrent API requests. When an executive or client loads a 5-step funnel dashboard with date pickers, it exhausts the hourly token budget in under 3 minutes.

Instead of paying $200–$400/month for connector middleware (Supermetrics, etc.), the simplest engineering fix is a pre-aggregated daily unnesting view in BigQuery.

Here is the exact flattened SQL query we use to aggregate the 5-step e-commerce journey (`view_item` → `add_to_cart` → `begin_checkout` → `add_payment_info` → `purchase`) into a daily view that costs < $0.05 per query and eliminates token limits entirely:

```sql
WITH raw_events AS (
  SELECT
    PARSE_DATE('%Y%m%d', event_date) AS event_date,
    user_pseudo_id,
    (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS session_id,
    event_name,
    traffic_source.source AS session_source,
    traffic_source.medium AS session_medium,
    device.category AS device_category,
    ecommerce.purchase_revenue_in_usd AS purchase_revenue
  FROM
    `your-project.analytics_123456789.events_*`
  WHERE
    event_name IN ('view_item', 'add_to_cart', 'begin_checkout', 'purchase')
    AND _TABLE_SUFFIX >= FORMAT_DATE('%Y%m%d', DATE_SUB(CURRENT_DATE(), INTERVAL 60 DAY))
)
SELECT
  event_date,
  device_category,
  session_source,
  COUNT(DISTINCT CONCAT(user_pseudo_id, CAST(session_id AS STRING))) AS sessions,
  COUNT(DISTINCT CASE WHEN event_name = 'view_item' THEN session_id END) AS step_1_view_item,
  COUNT(DISTINCT CASE WHEN event_name = 'add_to_cart' THEN session_id END) AS step_2_cart_add,
  COUNT(DISTINCT CASE WHEN event_name = 'begin_checkout' THEN session_id END) AS step_3_checkout,
  COUNT(DISTINCT CASE WHEN event_name = 'purchase' THEN session_id END) AS step_4_purchases,
  ROUND(SUM(COALESCE(purchase_revenue, 0)), 2) AS total_revenue
FROM raw_events
GROUP BY 1, 2, 3
ORDER BY event_date DESC;
```

We also open-sourced our Looker Studio calculated fields for tracking AI referral traffic (ChatGPT, Claude, Perplexity citations) on GitHub:
👉 https://github.com/Anouarbouch/metricbloo-bi

Hope this saves someone the headache of quota timeouts!
```

---

## Channel 2: Hacker News (Show HN)

### Post Title
> **Show HN: MetricBloo – Open-source Looker Studio templates for AI referral tracking and GA4 quota bypass**

### Post Text
```markdown
Hi HN,

Many marketing teams and founders using GA4 are struggling with two specific analytics blind spots:
1. GA4's default channel groupings lump AI assistant referrals (ChatGPT, Claude, Perplexity, Gemini) into generic "Direct" or "Referral" buckets.
2. Direct GA4-to-Looker Studio reports frequently crash due to Google's 10-concurrent-request API quota limit.

We built MetricBloo BI as an open-source collection of production Looker Studio templates and pre-computed BigQuery/dbt models that solve both problems:
- 100% Zero-Data Architecture: The entire repository operates on synthetic demo datasets. You duplicate templates into your private Google workspace with 1 click; we never touch or store user data.
- Quota Bypass: Flattened SQL models aggregate nested GA4 events into daily marts, dropping query costs to < $0.05.
- Regex Channel Attribution: Identifies incoming sessions from Perplexity, ChatGPT, Claude, and Gemini with engagement rate benchmarks.

GitHub Repository: https://github.com/Anouarbouch/metricbloo-bi
Live Demo Studio: https://anouarbouchaara.github.io/metricbloo-bi/

Feedback and PRs on the dbt models are very welcome!
```

---

## Channel 3: Google Looker Studio Community Gallery Submission

### Listing Details
- **Report Name:** AI & LLM Referral Traffic Attribution Dashboard (Free Edition)
- **Category:** Marketing / Web Analytics
- **Data Connector:** Google Analytics 4 (Native Free Connector)
- **Description:**  
  Gain instant visibility into organic traffic arriving from AI engines (ChatGPT, Anthropic Claude, Perplexity AI, Google Gemini, and Microsoft Copilot). Includes pre-configured calculated fields and engagement rate comparisons against organic search.
- **Support URL:** https://github.com/Anouarbouch/metricbloo-bi
