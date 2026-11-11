# SKU 01: Free AI & LLM Referral Traffic Attribution Dashboard (GA4)

**Zero-Cost Growth Lead Magnet**  
*Directly isolates incoming traffic from ChatGPT, Claude, Perplexity, Gemini, Copilot, and Grok in Looker Studio and BigQuery.*

---

## 1. The Business Problem
Standard GA4 default channel groupings lump AI assistant referrals into generic `Referral` or `Direct` traffic. Marketers cannot tell:
- How much organic traffic AI chatbots are driving to their site.
- What content AI models are citing and recommending.
- Which AI platform delivers the highest engagement and conversion rates.

---

## 2. Quick Setup in Looker Studio (Zero SQL Required)

If you connect Looker Studio directly to GA4 via the free native connector, create a **Calculated Field** named `AI Referral Channel`:

```lookerstudio
CASE 
  WHEN REGEXP_MATCH(Session source, '.*(chatgpt|openai\.com|chat\.openai).*') THEN "OpenAI / ChatGPT"
  WHEN REGEXP_MATCH(Session source, '.*(claude\.ai|anthropic).*') THEN "Anthropic Claude"
  WHEN REGEXP_MATCH(Session source, '.*(perplexity\.ai).*') THEN "Perplexity AI"
  WHEN REGEXP_MATCH(Session source, '.*(gemini\.google\.com|bard\.google).*') THEN "Google Gemini"
  WHEN REGEXP_MATCH(Session source, '.*(copilot\.microsoft\.com|bing\.com/chat).*') THEN "Microsoft Copilot"
  WHEN REGEXP_MATCH(Session source, '.*(grok\.x\.ai|x\.ai).*') THEN "xAI Grok"
  ELSE "Non-AI Traffic"
END
```

**Recommended Chart Settings:**
- **Dimension:** `AI Referral Channel`, `Landing page + query string`
- **Metrics:** `Sessions`, `Engaged sessions`, `Engagement rate`, `Conversions`
- **Filter:** `AI Referral Channel` Does Not Equal `"Non-AI Traffic"`

---

## 3. High-Scale BigQuery Model (For High Traffic Properties)
To bypass GA4 API quota limits (`10 concurrent requests limit`), use our optimized BigQuery unnest query in [`ga4_ai_channel_regex.sql`](./ga4_ai_channel_regex.sql).

---

## 4. Live Interactive SQL & Demo Preview
Open the interactive storefront and copy the production SQL directly:
🔗 **[MetricBloo BI Interactive SQL Engine](https://anouarbouch.github.io/metricbloo-bi/#sql-engine)**
